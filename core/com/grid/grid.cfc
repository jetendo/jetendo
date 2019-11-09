<cfcomponent>
<cfoutput>
<!--- 
todo:
ajax image uploader

group settings form
box settings form

background configuration and image uploader

I guess equal heights should be an option on row settings.

maybe row settings needs default heading / summary / button font size options

need "add box" to show options before appearing in the preview.

consider additional buttons for "add image", "add heading/text box" or maybe a rollover instead of single button.

need delete row

need visual versions of the layouts

integrate with other jetendo apps:
	
	show link
		| 
		<cfscript>
		ts=structnew();
		ts.saveIdURL="/z/content/admin/content-admin/saveGridId?content_id=#row.content_id#";
		ts.grid_id=row.content_grid_id;
		application.zcore.grid.getGridForm(ts); 
		</cfscript>

	see saveGridId in content-admin.cfc

	add delete to delete in content-admin.cfc
		application.zcore.grid.deleteGridId(row.content_grid_id, request.zos.globals.id);
 --->

<!---  
// image Grid form:
ts=structnew();
ts.saveIdURL="/z/content/admin/content-admin/saveGridId?content_id=#row.content_id#";
ts.grid_id=row.content_grid_id;
application.zcore.gridCom.getGridForm(ts); --->
<cffunction name="getGridForm" localmode="modern" access="public" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	rs=this.getGridById(arguments.ss.grid_id, false); 
	</cfscript>
	<cfif rs.success>
		<a href="##" onclick="zShowGridEditorWindow('#getEditorURL(rs.qGrid.grid_id)#'); return false;">Grid Editor</a>
	<cfelse>
		<a href="##" onclick="zShowGridEditorWindow('#arguments.ss.saveIdURL#'); return false;">Grid Editor</a>
	</cfif>
</cffunction>

<cffunction name="redirectToEditor" localmode="modern" access="public">
	<cfargument name="grid_id" type="numeric" required="yes">
	<cfscript>
	link=getEditorURL(arguments.grid_id);
	application.zcore.functions.zRedirect(link);
	</cfscript>
</cffunction>

<cffunction name="getEditorURL" localmode="modern" access="public" output="no"> 
	<cfargument name="grid_id" type="numeric" required="yes">
	<cfscript>
	return "/z/_com/grid/grid?method=gridform&grid_id=#arguments.grid_id#";
	</cfscript>
</cffunction>

<cffunction name="loadGrid" localmode="modern" access="remote">
	<cfscript>
	form.grid_id=application.zcore.functions.zso(form, 'grid_id');
	var db=request.zos.queryObject; 
	db.sql="select * from #db.table("grid", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("grid_group", request.zos.zcoreDatasource)# ON  
	grid.site_id=grid_group.site_id and 
	grid_group_deleted=#db.param(0)# and 
	grid.grid_id = grid_group.grid_id
	LEFT JOIN #db.table("grid_box", request.zos.zcoreDatasource)# ON 
	grid.site_id=grid_group.site_id and 
	grid_box.site_id = grid_group.site_id and 
	grid_group.grid_group_id=grid_box.grid_group_id and 
	grid_box_deleted=#db.param(0)# and 
	grid.grid_id = grid_group.grid_id
	WHERE grid.site_id =#db.param(request.zos.globals.id)# and 
	grid_deleted=#db.param(0)# and 
	grid.grid_id = #db.param(form.grid_id)# 
	ORDER BY grid_group_sort ASC, grid_box_sort ASC";
	qGrid=db.execute("qGrid");
	 
	db.sql="show fields from #db.table("grid_group", request.zos.zcoreDatasource)#";
	qGroupFields=db.execute("qGroupFields");
	db.sql="show fields from #db.table("grid_box", request.zos.zcoreDatasource)#";
	qBoxFields=db.execute("qBoxFields");
	groupFields={};
	boxFields={};
	for(row in qGroupFields){
		if(row.field NEQ "site_id" and row.field NEQ "grid_group_deleted" and row.field NEQ "grid_group_updated_datetime"){
			groupFields[row.field]=true;
		}
	}
	for(row in qBoxFields){
		if(row.field NEQ "site_id" and row.field NEQ "grid_box_deleted" and row.field NEQ "grid_box_updated_datetime"){
			boxFields[row.field]=true;
		}
	}
	
	gridStruct={
		settings:{},
		groups:[]
	};
	uniqueGroup={};
	for(row in qGrid){
		gridStruct.settings.grid_id=row.grid_id;
		gridStruct.settings.grid_active=row.grid_active;
		gridStruct.settings.grid_visible=row.grid_visible;
		if(row.grid_group_id NEQ "" and row.grid_group_id NEQ "0"){
			if(not structkeyexists(uniqueGroup, row.grid_group_id)){ 
				ts={
					boxes:[],
					settings:{}
				}
				for(field in groupFields){
					ts.settings[field]=row[field];
				}
				arrayAppend(gridStruct.groups, ts);
				uniqueGroup[row.grid_group_id]=arrayLen(gridStruct.groups);
			}

			if(row.grid_box_id NEQ "" and row.grid_box_id NEQ "0"){
				ts={
					data:{}
				};
				for(field in boxFields){
					ts.data[field]=row[field];
				}
				arrayAppend(gridStruct.groups[uniqueGroup[row.grid_group_id]].boxes, ts);
			}
		}
	}

	rs={
		success:true,
		grid:gridStruct
	}
	// writedump(gridStruct);abort;
	application.zcore.functions.zReturnJson(rs);
	</cfscript>

</cffunction>


<cffunction name="saveGrid" localmode="modern" access="remote">
	<cfscript> 
	var db=request.zos.queryObject;  
	form.grid_id=application.zcore.functions.zso(form, 'grid_id');
	form.grid_visible=application.zcore.functions.zso(form, 'grid_visible', true, 0);
	 
	destination=request.zos.globals.privatehomedir&"zupload/grid/"&form.grid_id&"/";  
	application.zcore.functions.zCreateDirectory(destination);
	ds=deserializeJSON(application.zcore.functions.zso(form, 'grid'));
	if(not structkeyexists(ds, 'settings') or not structkeyexists(ds.settings, 'grid_id')){
		rs={success:false, errorMessage:"Save failed. Invalid format detected"};
		application.zcore.functions.zReturnJson(rs);
	}
	rs=this.getGridById(form.grid_id, false); 
	if(not rs.success){
		throw("Invalid grid_id: #ds.settings.grid_id#");
	}
	qGrid=rs.qGrid;
	gridStruct.grid.grid_active=1;
	gridStruct.grid.grid_deleted=0;
	gridStruct.grid.grid_id=form.grid_id;
	gridStruct.grid.grid_visible=form.grid_visible;
	gridStruct.grid.site_id=request.zos.globals.id;
	gridStruct.grid.grid_updated_datetime=request.zos.mysqlnow;
	ts={
		table:"grid",
		struct:gridStruct.grid,
		datasource:request.zos.zcoreDatasource
	};
	application.zcore.functions.zUpdate(ts);

	arrR=[];
	arrayAppend(arrR, 'update grid #gridStruct.grid.grid_id#<br>');

	for(group in ds.groups){
		group.settings.site_id=request.zos.globals.id;
		group.settings.grid_deleted=0;
		group.settings.grid_group_updated_datetime=request.zos.mysqlnow;
		ts={
			table:"grid_group",
			struct:group.settings,
			datasource:request.zos.zcoreDatasource
		};
		if(group.settings.grid_group_id EQ 0){
			group.settings.grid_group_id=application.zcore.functions.zInsert(ts);
			arrayAppend(arrR, 'insert group #group.settings.grid_group_id#<br>');
			if(not group.settings.grid_group_id){
				rs={success:false, 'Save failed. Group insert failed'};
				application.zcore.functions.zReturnJson(rs);
			}
		}else{
			arrayAppend(arrR, 'update group #group.settings.grid_group_id#<br>');
			application.zcore.functions.zUpdate(ts);
		}
		for(box in group.boxes){
			box.data.grid_box_updated_datetime=request.zos.mysqlnow;
			box.data.grid_box_deleted=0;
			box.data.grid_group_id=group.settings.grid_group_id;
			box.data.site_id=request.zos.globals.id;
			ts={
				table:"grid_box",
				struct:box,
				datasource:request.zos.zcoreDatasource
			};
			if(box.data.grid_box_id EQ 0){
				box.data.grid_box_id=application.zcore.functions.zInsert(ts);
				arrayAppend(arrR, 'insert box #box.data.grid_box_id#<br>');
				if(not box.data.grid_box_id){
					rs={success:false, 'Save failed. Box insert failed'};
					application.zcore.functions.zReturnJson(rs);
				}
			}else{
				arrayAppend(arrR, 'update box #box.data.grid_box_id#<br>');
				application.zcore.functions.zUpdate(ts);
			}
		}
	}
 	db.sql="SELECT * FROM #db.table("grid_group", request.zos.zcoreDatasource)# WHERE 
 	site_id = #db.param(request.zos.globals.id)# and 
 	grid_group_deleted=#db.param(0)# and 
 	grid_group_updated_datetime<#db.param(request.zos.mysqlnow)# and 
 	grid_id=#db.param(ds.settings.grid_id)#";
 	qGroup=db.execute("qGroup");
 	for(row in qGroup){
 		// delete the files
 		deleteGridGroupIdFiles(row);
 	}

 	db.sql="SELECT * FROM #db.table("grid_box", request.zos.zcoreDatasource)# WHERE 
 	site_id = #db.param(request.zos.globals.id)# and 
 	grid_box_deleted=#db.param(0)# and 
 	grid_box_updated_datetime<#db.param(request.zos.mysqlnow)# and 
 	grid_id=#db.param(ds.settings.grid_id)#";
 	qBox=db.execute("qBox");
 	for(row in qBox){
 		// delete the files
 		deleteGridBoxIdFiles(row);
 	}
 
 	db.sql="DELETE FROM #db.table("grid_group", request.zos.zcoreDatasource)# WHERE 
 	site_id = #db.param(request.zos.globals.id)# and 
 	grid_group_deleted=#db.param(0)# and 
 	grid_group_updated_datetime<#db.param(request.zos.mysqlnow)# and 
 	grid_id=#db.param(ds.settings.grid_id)#";
 	db.execute("qDelete");

 	db.sql="DELETE FROM #db.table("grid_box", request.zos.zcoreDatasource)# WHERE 
 	site_id = #db.param(request.zos.globals.id)# and 
 	grid_box_deleted=#db.param(0)# and 
 	grid_box_updated_datetime<#db.param(request.zos.mysqlnow)# and 
 	grid_id=#db.param(ds.settings.grid_id)#";
 	db.execute("qDelete");

 	rs={
 		success:true,
 		arrR:arrR
 	};
 	application.zcore.functions.zReturnJson(rs);
	</cfscript>

</cffunction>


<cffunction name="deleteGridGroupIdFiles" localmode="modern" returntype="any" output="no">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	path=application.zcore.functions.zvar('privateHomedir', ds.site_id)&'zupload/grid/'&ds.grid_id&'/';
	/*
	// TODO: loop the background images and delete them
	application.zcore.functions.zdeletefile(path&ds.grid_box_image_intermediate);
	application.zcore.functions.zdeletefile(path&ds.grid_box_image);
	*/
	</cfscript>
</cffunction>

<cffunction name="deleteGridBoxIdFiles" localmode="modern" returntype="any" output="no">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	path=application.zcore.functions.zvar('privateHomedir', ds.site_id)&'zupload/grid/'&ds.grid_id&'/';
	application.zcore.functions.zdeletefile(path&ds.grid_box_image_intermediate);
	application.zcore.functions.zdeletefile(path&ds.grid_box_image);
	</cfscript>
</cffunction>

<cffunction name="deleteGridId" localmode="modern" returntype="any" output="no">
	<cfargument name="grid_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var db=request.zos.queryObject;
	if(arguments.grid_id NEQ 0 and arguments.grid_id NEQ ""){
		application.zcore.functions.zdeletedirectory(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&"zupload/grid/"&arguments.grid_id&"/");
		db.sql="DELETE FROM #db.table("grid_box", request.zos.zcoreDatasource)#  
		WHERE grid_id = #db.param(arguments.grid_id)# and 
		grid_box_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
		db.sql="DELETE FROM #db.table("grid_group", request.zos.zcoreDatasource)#  
		WHERE grid_id = #db.param(arguments.grid_id)# and 
		grid_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
		db.sql="DELETE FROM #db.table("grid", request.zos.zcoreDatasource)#  
		WHERE grid_id = #db.param(arguments.grid_id)# and 
		grid_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
	}
	</cfscript>
</cffunction>

<cffunction name="getNewGridId" localmode="modern" access="public" returntype="any" output="no">
	<cfscript>
	var grid_id=0;
	var ts=structnew();
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="grid";
	ts.struct=structnew();
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.grid_active=0; 
	ts.struct.grid_deleted=0;
	ts.struct.grid_updated_datetime=request.zos.mysqlnow;
	grid_id=application.zcore.functions.zInsert(ts);
	if(grid_id EQ false){
		application.zcore.template.fail("Error: zcorerootmapping.com.grid.grid.cfc - getNewGridId() failed to insert into grid.");
	}
	return grid_id;
	</cfscript>
</cffunction>

<cffunction name="activateGridId" localmode="modern" returntype="any" output="no">
	<cfargument name="grid_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="UPDATE #db.table("grid", request.zos.zcoreDatasource)# 
	SET grid_active = #db.param('1')#,
	grid_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE grid_id=#db.param(arguments.grid_id)# and 
	grid_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	</cfscript>
</cffunction>


<cffunction name="getGridById" localmode="modern" returntype="any" output="yes">
	<cfargument name="grid_id" type="string" required="yes">
	<cfargument name="newOnMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	var qGrid=0;
	var db=request.zos.queryObject;
	if(not structkeyexists(request.zos, 'GridIdQueryCache')){
		request.zos.GridIdQueryCache={};
	}
	if(structkeyexists(request.zos.GridIdQueryCache, arguments.grid_id)){
		return request.zos.GridIdQueryCache[arguments.grid_id];
	}else{
		if(arguments.grid_id EQ 0){
			if(arguments.newOnMissing){
				arguments.grid_id=this.getNewGridId();
				db.sql="SELECT * FROM #db.table("grid", request.zos.zcoreDatasource)# grid 
				WHERE grid_id = #db.param(arguments.grid_id)# and 
				grid_deleted = #db.param(0)# and 
				site_id =#db.param(request.zos.globals.id)#";
				qGrid=db.execute("qGrid");
				request.zos.GridIdQueryCache[arguments.grid_id]={success:true, qGrid:qGrid, newRecord:false};
				return {success:true, qGrid:qGrid, newRecord:true};
			}else{
				return {success:false};
			}
		}else{
			db.sql="SELECT * FROM #db.table("grid", request.zos.zcoreDatasource)# grid 
			WHERE grid_id = #db.param(arguments.grid_id)# and 
			grid_deleted = #db.param(0)# and 
			site_id =#db.param(request.zos.globals.id)#";
			qGrid=db.execute("qGrid");
			if(qGrid.recordcount EQ 0){
				if(arguments.newOnMissing){
					arguments.grid_id=this.getNewGridId();
					db.sql="SELECT * FROM #db.table("grid", request.zos.zcoreDatasource)# grid 
					WHERE grid_id = #db.param(arguments.grid_id)# and 
					grid_deleted = #db.param(0)# and 
					site_id =#db.param(request.zos.globals.id)#";
					qGrid=db.execute("qGrid");
					request.zos.GridIdQueryCache[arguments.grid_id]={success:true, qGrid:qGrid, newRecord:false};
					return {success:true, qGrid:qGrid, newRecord:true};
				}else{
					return {success:false};
				}
			}
		}
		rs={success:true, qGrid:qGrid, newRecord:false};
		request.zos.GridIdQueryCache[arguments.grid_id]=rs;
		return rs;
	}
	</cfscript>
</cffunction>





<cffunction name="copyGrid" localmode="modern" access="remote" returntype="any" output="yes">
	<cfargument name="grid_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("grid", request.zos.zcoreDatasource)# WHERE 
	grid_id = #db.param(arguments.grid_id)# and 
	grid_deleted=#db.param(0)# and 
	site_id = #db.param(arguments.site_id)#";
	qGrid=db.execute("qGrid");
	for(row in qGrid){
		row.grid_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
		structdelete(row, 'grid_id');
		ts=structnew();
		ts.struct=row;
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="grid";
		newGridId=application.zcore.functions.zInsert(ts);

		oldPath=application.zcore.functions.zvar('privateHomedir', arguments.site_id)&'zupload/grid/'&arguments.grid_id&'/';
		path=application.zcore.functions.zvar('privateHomedir', arguments.site_id)&'zupload/grid/'&newGridId&'/';
		application.zcore.functions.zcreatedirectory(path);

		db.sql="select * from #db.table("grid_group", request.zos.zcoreDatasource)# WHERE 
		grid_id = #db.param(arguments.grid_id)# and 
		grid_group_deleted=#db.param(0)# and 
		site_id = #db.param(arguments.site_id)# 
		ORDER BY grid_group_sort ASC";
		qGroup=db.execute("qGroup");
		for(row2 in qGroup){
			structdelete(row2, 'grid_group_id');
			row2.grid_id=newGridId;
			row2.image_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
			ts=structnew();
			ts.struct=row2;
			ts.datasource=request.zos.zcoreDatasource;
			ts.table="grid_group";
			groupId=application.zcore.functions.zInsert(ts);
			if(not groupId){
				throw("Failed to save grid group");
			}

			db.sql="select * from #db.table("grid_box", request.zos.zcoreDatasource)# WHERE 
			grid_id = #db.param(arguments.grid_id)# and 
			grid_group_id=#db.param(row2.grid_group_id)# and 
			grid_box_deleted=#db.param(0)# and 
			site_id = #db.param(arguments.site_id)# 
			ORDER BY grid_box_sort ASC";
			qBox=db.execute("qBox");
			for(row3 in qBox){
				structdelete(row3, 'grid_box_id');
				row3.grid_id=newGridId;
				row3.grid_group_id=groupId;
				row3.grid_box_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
				/*
				newPath=application.zcore.functions.zcopyfile(oldPath&row3.grid_box_image, path&row3.grid_box_image, false);
				row3.grid_box_image=getfilefrompath(newPath);  
				newPath=application.zcore.functions.zcopyfile(oldPath&row3.grid_box_image_intermediate, path&row3.grid_box_image_intermediate, false);
				row3.grid_box_image_intermediate=getfilefrompath(newPath);
				*/
				ts=structnew();
				ts.struct=row3;
				ts.datasource=request.zos.zcoreDatasource;
				ts.table="grid_box";
				boxId=application.zcore.functions.zInsert(ts);
				if(not boxId){
					throw("Failed to save grid box");
				}
			}

		}
		return newGridId;
	}
	return "0";
	</cfscript>
</cffunction>

<cffunction name="gridform" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject; 
	application.zcore.template.setTag("title", "Grid Editor");
	form.grid_id=application.zcore.functions.zso(form, 'grid_id'); 
	rs=this.getGridById(form.grid_id, false);
	if(not rs.success){
		throw("Invalid grid_id: #form.grid_id#");
	}
	form.grid_id=rs.qGrid.grid_id;
	application.zcore.functions.zStatusHandler(request.zsid);
	
	request.zos.debuggerEnabled=false;
	application.zcore.functions.zModalCancel();
	application.zcore.template.appendTag("stylesheets", '<style>
    *{-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box;} 

	.z-grid-group{
	cursor:pointer;
	-moz-user-select: none;
	-webkit-user-select: none;
	-ms-user-select: none;
	}
    </style>');
	application.zcore.template.appendTag("scripts", '<script>var zIsModalWindow=true;</script>');
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain-no-body-style",true,true);
	
	application.zcore.functions.zRequireJquery();
	application.zcore.functions.zRequireJqueryUI();

	gridGroupCom=createObject("component", "zcorerootmapping.com.grid.gridGroup");
	gridGroupCom.displayGroupForm();
	gridBoxCom=createObject("component", "zcorerootmapping.com.grid.gridBox");
	gridBoxCom.displayBoxForm();

	application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
	application.zcore.skin.includeCSS("/z/stylesheets/grid-manager.css");
	application.zcore.skin.includeJS("/z/javascript/jetendo-grid/grid-manager.js");
	//application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");

	form.fluid=application.zcore.functions.zso(form, 'fluid', false, 0);
	gridWidth=request.zos.globals.maximagewidth;
	if(form.fluid EQ 1){
		gridWidth=1200;
	}
	</cfscript>
	<section>
		<div class="z-container">
			<h2>Grid Editor</h2> 
			<input type="hidden" name="gridId" id="gridId" value="#htmleditformat(form.grid_id)#" /> 
			<div class="z-column debugResponseDiv"></div>
		</div>
	</section>
	<form id="form1" action="/z/_com/grid/grid?method=gridform&amp;grid_id=#form.grid_id#" enctype="multipart/form-data" method="post">
	<section id="z-grid-editor-interface">
		<div id="z-grid-groups">

			<!--- <cfloop from="1" to="2" index="i">

				<section id="z-grid-group-#i#" data-group-id="#i#" class="z-grid-group z-center-children" style=" background-color: ##F5F5F5;"> 
					<div class="z-grid-boxes" style="width:#gridWidth#px;">
						<section>
							<div class=" z-grid-boxes-sortable z-equal-heights">
								<div id="z-grid-box-1" class="z-1of4 z-grid-box" style="background-color: ##CCCCCC;">
									<div class="z-t-16">box</div>
								</div>
								<div id="z-grid-box-2" class="z-1of4 z-grid-box" style="background-color: ##CCCCCC;">
									<div class="z-t-16">
										Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
										tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
										quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
										consequat.
									</div>
								</div>
								<div id="z-grid-box-3" class="z-1of4 z-grid-box" style="background-color: ##CCCCCC;">
									<img src="#application.zcore.functions.zGetImagePlaceholderURL(350,150)#" class="z-fluid" />
								</div>
								<div id="z-grid-box-4" class="z-1of4 z-grid-box" style="background-color: ##CCCCCC;">
									<div class="z-t-16">box</div>
								</div>
							</div>
						</section>
					</div>
					<div class="z-grid-group-buttons-right z-p-10">
						<a href="##" class="z-grid-group-settings z-button">Settings</a>
						<a href="##" class="z-grid-delete-group z-button">Delete Group</a>
						<a href="##" class="z-grid-add-box z-button">Add Box</a>
						<a href="##" class="z-t-14 z-grid-group-move-handle icon-left"><i class="fa fa-bars"></i>Move</a>
					</div>
				</section>
			</cfloop> --->

		</div>

		<div id="z-grid-add-group" class="z-center-children">
			<a href="##" class="z-button" style=" padding: 20px;">Add Box Group</a>
		</div> 

	</section> 
<!--- 
		<section>
			<div class="z-container">
				<div class="z-3of5">
					<div id="gridEditorContent" style="width:100%; float:left; display:none;">
					</div>
				</div>
				<div class="z-2of5"> 
				</div>
			</div>
		</section> --->
					<textarea id="gridDebugId" cols="50" rows="5" style="font-size:12px; height:400px;  width:100% !important; "></textarea>
		<section>
			<div class="z-container">
				<div class="z-column">
					<input type="button" class="z-button gridSaveButton" value="Save">
					<input type="button" class="z-button" onclick="window.parent.zCloseModal(); return false;" value="Close Grid Editor">
				</div>
			</div>
		</section>
	</form> 

	<cfsavecontent variable="gridOverlayTemplate"> 
		<div class="z-grid-box-overlay">
			<div class="z-grid-box-buttons z-t-12">
				<a href="##" class="z-button icon-left z-grid-box-move-handle"><i class="fa fa-arrows"></i>Move</a>
				<a href="##" class="z-button icon-left z-grid-box-edit"><i class="fa fa-edit"></i>Edit</a>
				<a href="##" class="z-button icon-left z-grid-box-copy"><i class="fa fa-copy"></i>Copy</a>
				<a href="##" class="z-button icon-left z-grid-box-delete"><i class="fa fa-trash-o"></i>Delete</a>
			</div>
		</div>
	</cfsavecontent>
	<cfsavecontent variable="gridGroupTemplate">
		<section id="z-grid-group-{{grid_group_id}}" data-group-id="{{grid_group_id}}" class="z-grid-group z-center-children" style="background-color: ##F5F5F5;">
			
			<div class=" z-grid-boxes" style="width:#gridWidth#px;">
				<section>
					<div class=" z-grid-boxes-sortable">
						 
					</div>
				</section>
			</div>
			<div class="z-grid-group-buttons-right z-1of7 z-mv-0 z-t-12">
				<a href="##" class="z-grid-group-settings z-button">Settings</a>
				<a href="##" class="z-grid-delete-group z-button">Delete Group</a>
				<a href="##" class="z-grid-add-box z-button">Add Box</a>
				<a href="##" class="z-t-14 z-grid-group-move-handle icon-left"><i class="fa fa-bars"></i>Move</a>
			</div>
		</section> 
	</cfsavecontent>
	<script>
	var gridOverlayTemplate="#jsstringformat(gridOverlayTemplate)#";
	var gridGroupTemplate="#jsstringformat(gridGroupTemplate)#"; 
	var gridWidth=#gridWidth#;
	</script> 
 
</cffunction>


<cffunction name="deleteInactiveGrid" localmode="modern" access="remote">
	<cfargument name="dontAbort" type="string" required="no" default="#false#">
	<cfscript>
	var db=request.zos.queryObject; 
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	}
	var i=0; db.sql="SELECT grid.grid_id, grid.site_id FROM #db.table("grid", request.zos.zcoreDatasource)# grid, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_active = #db.param(1)# and 
	grid.site_id = site.site_id and 
	site.site_deleted = #db.param(0)# and 
	grid_deleted = #db.param(0)# and 
	grid_active=#db.param(0)# and 
	grid_updated_datetime <= #db.param(dateformat(dateadd("d",-1,now()),'yyyy-mm-dd')&" 00:00:00")#";
	qGrid=db.execute("qGrid");
	for(row in qGrid){
		this.deleteGridId(row.grid_id, row.site_id);	
	}
	if(arguments.dontAbort){
		return true;	
	}
	writeoutput('done.');
	abort;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>