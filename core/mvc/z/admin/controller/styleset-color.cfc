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
	db.sql="SELECT * FROM #db.table("styleset_color", "zgraph")# 
	WHERE styleset_color_id = #db.param(form.styleset_color_id)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_color_deleted=#db.param(0)#";
	qColor=db.execute("qColor");
	if(qColor.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "styleset_color no longer exists.",false,true);
		application.zcore.functions.zRedirect('/z/admin/styleset-color/index?zsid='&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.styleset_color_id=form.styleset_color_id;
		db.sql="DELETE FROM #db.table("styleset_color", "zgraph")# 
		WHERE styleset_color_id = #db.param(form.styleset_color_id)# and 
		site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		styleset_color_deleted=#db.param(0)# ";
		db.execute("qDelete");    
		updateCache(application.zcore);
		application.zcore.status.setStatus(request.zsid, "Color deleted.");
		application.zcore.functions.zRedirect('/z/admin/styleset-color/index?zsid='&request.zsid);
		</cfscript>
	<cfelse>
		<h2>Important TODO: check for use of color, and force user to remap it before deleting.</h2>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this styleset_color?<br /><br /> 
		Color Name: #qColor.styleset_color_name#
		<br /><br />
		<a href="/z/admin/styleset-color/delete?confirm=1&sid=#form.sid#&styleset_color_id=#form.styleset_color_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/admin/styleset-color/index">No</a></span></div>
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
	if(form.styleset_color_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Name is required", form, true);
		fail=true;
	}
	if(form.styleset_color_value EQ ""){
		application.zcore.status.setStatus(request.zsid, "Color value is required", form, true);
		fail=true;
	}
	if(fail){
		if(currentMethod EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/styleset-color/edit?styleset_color_id=#form.styleset_color_id#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/admin/styleset-color/add?zsid=#Request.zsid#");
		}
	}
	if(form.styleset_color_value DOES NOT CONTAIN "rgb" and form.styleset_color_value DOES NOT CONTAIN "##"){
		form.styleset_color_value="##"&form.styleset_color_value;
	}
	if(application.zcore.user.checkServerAccess()){
		if(form.global EQ 1){
			form.site_id=0;
		}else{
    		form.site_id=request.zos.globals.id;
    	}
    }
	form.styleset_color_deleted=0;
	form.styleset_color_updated_datetime=request.zos.mysqlnow; 
	inputStruct = StructNew();
	inputStruct.table = "styleset_color";
	inputStruct.struct=form;
	inputStruct.datasource="zgraph";
	if(currentMethod EQ "insert"){
		form.styleset_color_id = application.zcore.functions.zInsert(inputStruct);
		if(form.styleset_color_id EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to add color",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset-color/add?zsid=#Request.zsid#");
		} 
	}else{ 
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to update color",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset-color/edit?sid=#form.styleset_color_id#&zsid=#Request.zsid#");
		}
	} 
	updateCache(application.zcore);
	application.zcore.status.setStatus(Request.zsid, "Color saved");
	application.zcore.functions.zRedirect('/z/admin/styleset-color/index?zsid='&request.zsid);
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
	form.styleset_color_id=application.zcore.functions.zso(form, "styleset_color_id"); 
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("styleset_color", "zgraph")# 
	WHERE styleset_color_deleted=#db.param(0)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_color_id=#db.param(form.styleset_color_id)# 
	ORDER BY styleset_color_name ASC ";
	qColor=db.execute("qColor");
	if(qColor.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset-color/index");	
	}
	application.zcore.functions.zQueryToStruct(qColor); 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
	<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Color</h2>
	<form class="zFormCheckDirty" action="/z/admin/styleset-color/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?styleset_color_id=#form.styleset_color_id#" method="post">

	<cfscript>
	tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Basic"]);//,"Plug-ins"]);
	tabCom.setMenuName("member-color-edit");
	cancelURL="/z/admin/styleset-color/index";
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()# 
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr>
		<th style="vertical-align:top; width:140px;">Color Name:</th>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "styleset_color_name", "table-error","")#><input name="styleset_color_name" type="text" size="70" maxlength="100" value="#htmleditformat(form.styleset_color_name)#">
		<br>i.e. Red</td>
	</tr>  
	<tr>
		<th style="vertical-align:top; width:140px;">CSS Color:</th>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "styleset_color_value", "table-error","")#><input name="styleset_color_value" onkeyup="tryColorSet(this.value);" type="text" size="30" maxlength="30" value="#htmleditformat(form.styleset_color_value)#"><br> 
			You can use any valid css hex, rgb, or rgba value. rgba is used for transparent colors.
		</td>
	</tr>   
	<tr>
		<th style="vertical-align:top; width:140px;">Preview</th>
		<td><div id="previewColor" style="width:40px; height:40px; <cfif form.styleset_color_value NEQ "">background-color:#form.styleset_color_value#;</cfif> float:left;"></div>
		</td>
	</tr>  
	<cfif application.zcore.user.checkServerAccess()>
		<tr>
			<th style="vertical-align:top; width:140px;">Global</th>
			<td><input type="radio" name="global" id="global1" value="1" <cfif form.site_id EQ "0">checked="checked"</cfif>> <label for="global1">Yes</label> 
				<input type="radio" name="global" id="global0" value="0" <cfif form.site_id NEQ "0">checked="checked"</cfif>> <label for="global0">No</label> 
				
			</td>
		</tr>
	</cfif>
    </table>
    <script>
    function tryColorSet(v){
    	if(v.indexOf('rgb') == -1 && v.indexOf('##') == -1){
    		v="##"+v;
    	}
    	$("##previewColor").css("background-color", v);
    }
    </script>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	</form>
</cffunction>

<cffunction name="updateCache" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM 
	#db.table("styleset_color", "zgraph")# 
	WHERE styleset_color_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# ";
	qColor=db.execute("qColor"); 
	styleset_colorLookup={};
	for(color in qColor){
		styleset_colorLookup[color.styleset_color_id]=color;
	}
	arguments.ss.stylesetColorLookup=styleset_colorLookup;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("styleset_color", "zgraph")# 
	WHERE styleset_color_deleted=#db.param(0)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#)
	ORDER BY styleset_color_name ASC ";
	qColor=db.execute("qColor");
	if(qColor.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset-color/index");	
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
    <p><a href="/z/admin/styleset-group/index">Groups</a> | <a href="/z/admin/styleset-color/index">Colors</a> | <a href="/z/admin/styleset/index">Stylesets</a></p>
    <div class="z-float">
		<h2 style="display:inline-block; padding-right:10px;">Styleset Colors</h2>
		<a href="/z/admin/styleset-color/add" class="z-manager-search-button">Add</a>
	</div> 
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<th>Name</th>
			<th>Preview</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qColor"> 
			<tr>
				<td>#qColor.styleset_color_name#</td>
				<td><div id="previewColor" style="width:25px; height:25px; background-color:#qColor.styleset_color_value#; float:left;"></div></td>
				<td>
					<cfif qColor.site_id NEQ 0 or application.zcore.user.checkServerAccess()>
						<a href="/z/admin/styleset-color/edit?styleset_color_id=#qColor.styleset_color_id#" class="z-manager-search-button">Edit</a> 
						<a href="/z/admin/styleset-color/delete?styleset_color_id=#qColor.styleset_color_id#" class="z-manager-search-button">Delete</a>
					</cfif>
				</td>
			</tr> 
		</cfloop>
    </table> 
</cffunction>
</cfoutput>
</cfcomponent>