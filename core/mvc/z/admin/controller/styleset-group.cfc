<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="public" roles="administrator">
	<cfscript>
	form.sid=application.zcore.functions.zso(form, "sid", true);
	if(not application.zcore.user.checkServerAccess()){
		form.sid=request.zos.globals.id;
	}
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("styleset_group", "zgraph")# 
	WHERE styleset_group_id = #db.param(form.styleset_group_id)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_group_deleted=#db.param(0)#";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "styleset_group no longer exists.",false,true);
		application.zcore.functions.zRedirect('/z/admin/styleset-group/index?zsid='&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.styleset_group_id=form.styleset_group_id;
		db.sql="DELETE FROM #db.table("styleset_group", "zgraph")# 
		WHERE styleset_group_id = #db.param(form.styleset_group_id)# and 
		site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		styleset_group_deleted=#db.param(0)# ";
		db.execute("qDelete");    
		updateStylesetGroupCache();
		application.zcore.status.setStatus(request.zsid, "Styleset Group deleted.");
		application.zcore.functions.zRedirect('/z/admin/styleset-group/index?zsid='&request.zsid);
		</cfscript>
	<cfelse> 
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this styleset_group?<br /><br /> 
		Styleset Group Name: #qGroup.styleset_group_name#
		<br /><br />
		<a href="/z/admin/styleset-group/delete?confirm=1&sid=#form.sid#&styleset_group_id=#form.styleset_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/admin/styleset-group/index">No</a></span></div>
	</cfif>
</cffunction>
 
<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	var currentMethod=form.method;  
	fail=false;
	if(form.styleset_group_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Name is required", form, true);
		fail=true;
	} 
	if(fail){
		if(currentMethod EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/styleset-group/edit?styleset_group_id=#form.styleset_group_id#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/admin/styleset-group/add?zsid=#Request.zsid#");
		}
	} 
	if(application.zcore.user.checkServerAccess()){
		if(form.preset EQ 1){
			form.site_id=0;
		}else{
    		form.site_id=request.zos.globals.id;
    	}
    }
	form.styleset_group_deleted=0;
	form.styleset_group_updated_datetime=request.zos.mysqlnow; 
	inputStruct = StructNew();
	inputStruct.table = "styleset_group";
	inputStruct.struct=form;
	inputStruct.datasource="zgraph";
	if(currentMethod EQ "insert"){
		form.styleset_group_id = application.zcore.functions.zInsert(inputStruct);
		if(form.styleset_group_id EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to add styleset group",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset-group/add?zsid=#Request.zsid#");
		} 
	}else{ 
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to update styleset group",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset-group/edit?sid=#form.styleset_group_id#&zsid=#Request.zsid#");
		}
	} 
	updateStylesetGroupCache();
	application.zcore.status.setStatus(Request.zsid, "Styleset Group saved");
	application.zcore.functions.zRedirect('/z/admin/styleset-group/index?zsid='&request.zsid);
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
	var db=request.zos.queryObject;
	form.styleset_group_id=application.zcore.functions.zso(form, "styleset_group_id"); 
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("styleset_group", "zgraph")# 
	WHERE styleset_group_deleted=#db.param(0)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_group_id=#db.param(form.styleset_group_id)# 
	ORDER BY styleset_group_name ASC ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset-group/index");	
	}
	application.zcore.functions.zQueryToStruct(qGroup); 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
	<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Styleset Group</h2>
	<form class="zFormCheckDirty" action="/z/admin/styleset-group/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?styleset_group_id=#form.styleset_group_id#" method="post">

	<cfscript>
	tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Basic"]);//,"Plug-ins"]);
	tabCom.setMenuName("member-color-edit");
	cancelURL="/z/admin/styleset-group/index";
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()# 
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr>
		<td style="vertical-align:top; width:140px;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "styleset_group_name", "table-error","")#><input name="styleset_group_name" type="text" size="70" maxlength="100" value="#htmleditformat(form.styleset_group_name)#"></td>
	</tr>   
	<cfif application.zcore.user.checkServerAccess()>
		<tr>
			<td style="vertical-align:top; width:140px;">Preset</td>
			<td><input type="radio" name="preset" id="preset1" value="1" <cfif form.site_id EQ "0">checked="checked"</cfif>> <label for="preset1">Yes</label> 
				<input type="radio" name="preset" id="preset0" value="0" <cfif form.site_id NEQ "0">checked="checked"</cfif>> <label for="preset0">No</label> 
				
			</td>
		</tr>
	</cfif>
    </table> 
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	</form>
</cffunction>

<cffunction name="updateStylesetGroupCache" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM 
	#db.table("styleset_group", "zgraph")# 
	WHERE styleset_group_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# ";
	qGroup=db.execute("qGroup"); 
	stylesetGroupLookup={};
	for(group in qGroup){
		stylesetGroupLookup[group.styleset_group_id]=group;
	}
	application.zcore.stylesetStylesetGroupLookup=stylesetGroupLookup;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("styleset_group", "zgraph")# 
	WHERE styleset_group_deleted=#db.param(0)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#)
	ORDER BY styleset_group_name ASC ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset-group/index");	
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
    <p><a href="/z/admin/styleset-group/index">Groups</a> | <a href="/z/admin/styleset-color/index">Colors</a> | <a href="/z/admin/styleset/index">Stylesets</a></p>
    <div class="z-float">
		<h2 style="display:inline-block; padding-right:10px;">Styleset Groups</h2>
		<a href="/z/admin/styleset-group/add" class="z-manager-search-button">Add</a>
	</div> 
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<th>Name</th> 
			<th>Admin</th>
		</tr>
		<cfloop query="qGroup"> 
			<tr>
				<th>#qGroup.styleset_group_name#</th> 
				<td>
					<cfif qGroup.site_id NEQ 0 or application.zcore.user.checkServerAccess()>
						<a href="/z/admin/styleset-group/edit?styleset_group_id=#qGroup.styleset_group_id#" class="z-manager-search-button">Edit</a> 
						<a href="/z/admin/styleset-group/delete?styleset_group_id=#qGroup.styleset_group_id#" class="z-manager-search-button">Delete</a>
					</cfif>
				</td>
			</tr> 
		</cfloop>
    </table> 
</cffunction>
</cfoutput>
</cfcomponent>