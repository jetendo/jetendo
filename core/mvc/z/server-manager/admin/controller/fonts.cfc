<cfcomponent>
<cfoutput> 
<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("webfont", request.zos.zcoreDatasource)# 
	WHERE webfont_id = #db.param(form.webfont_id)# and 
	webfont_deleted=#db.param(0)#";
	qwebfont=db.execute("qwebfont");
	if(qwebfont.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "webfont no longer exists.",false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/fonts/index?zsid='&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.webfont_id=form.webfont_id;
		db.sql="DELETE FROM #db.table("webfont", request.zos.zcoreDatasource)# 
		WHERE webfont_id = #db.param(form.webfont_id)# and 
		webfont_deleted=#db.param(0)# ";
		db.execute("qDelete");    
		updateFontCache();
		application.zcore.status.setStatus(request.zsid, "Webfont deleted.");
		application.zcore.functions.zRedirect('/z/server-manager/admin/fonts/index?zsid='&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this webfont?<br /><br />
		Warning: If any web sites use this font, they will revert to the inherited font, or a system font.<br><br>
		Webfont Name: #qwebfont.webfont_name#
		<br /><br />
		<a href="/z/server-manager/admin/fonts/delete?confirm=1&amp;webfont_id=#form.webfont_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/server-manager/admin/fonts/index">No</a></span></div>
	</cfif>
</cffunction>
 
<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.webfont_heading_scale=application.zcore.functions.zso(form, "webfont_heading_scale", true, 1);
	form.webfont_text_scale=application.zcore.functions.zso(form, "webfont_text_scale", true, 1);
	fail=false;
	if(fail){
		if(currentMethod EQ "update"){
			application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/edit?webfont_id=#form.webfont_id#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/add?zsid=#Request.zsid#");
		}
	}
	form.webfont_deleted=0;
	form.webfont_updated_datetime=request.zos.mysqlnow;
	form.webfont_family=replace(form.webfont_family, '"', "'", "all");

	inputStruct = StructNew();
	inputStruct.table = "webfont";
	inputStruct.struct=form;
	inputStruct.datasource=request.zos.zcoreDatasource;
	if(currentMethod EQ "insert"){
		form.webfont_id = application.zcore.functions.zInsert(inputStruct);
		if(form.webfont_id EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to add webfont",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/add?zsid=#Request.zsid#");
		} 
	}else{
		db.sql="select * FROM #db.table("webfont", request.zos.zcoreDatasource)# 
		WHERE webfont_id = #db.param(form.webfont_id)# and 
		webfont_deleted=#db.param(0)#";
		qwebfont=db.execute("qwebfont");  
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to update webfont",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/edit?sid=#form.webfont_id#&zsid=#Request.zsid#");
		}
	} 
	updateFontCache();
	application.zcore.status.setStatus(Request.zsid, "Webfont saved");
	application.zcore.functions.zRedirect('/z/server-manager/admin/fonts/index?zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	form.webfont_id=application.zcore.functions.zso(form, "webfont_id");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("webfont", request.zos.zcoreDatasource)# 
	WHERE webfont_deleted=#db.param(0)# and 
	webfont_id=#db.param(form.webfont_id)# 
	ORDER BY webfont_name ASC ";
	qFont=db.execute("qFont");
	if(qFont.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/index");	
	}
	application.zcore.functions.zQueryToStruct(qFont); 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
	<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Webfont</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/fonts/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?webfont_id=#form.webfont_id#" method="post">

	<cfscript>
	tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Basic"]);//,"Plug-ins"]);
	tabCom.setMenuName("member-font-edit");
	cancelURL="/z/server-manager/admin/fonts/index";
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()# 
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr>
		<td style="vertical-align:top; width:140px;">Name:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_name", "table-error","")#><input name="webfont_name" type="text" size="70" maxlength="100" value="#htmleditformat(form.webfont_name)#">
		<br>i.e. Open Sans Regular</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Font Family:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_family", "table-error","")#><input name="webfont_family" type="text" size="70" maxlength="100" value="#htmleditformat(form.webfont_family)#">
		<br>i.e. 'Helvetica', sans-serif</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Font Weight:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_weight", "table-error","")#><input name="webfont_weight" type="text" size="30" maxlength="30" value="#htmleditformat(form.webfont_weight)#">
		<br>i.e. normal, bold, 700, etc</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Font Style:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_style", "table-error","")#><input name="webfont_style" type="text" size="30" maxlength="30" value="#htmleditformat(form.webfont_style)#">
		<br>i.e. normal or italic</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Code:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_code", "table-error","")#><textarea name="webfont_code" style="width:100%; height:100px;">#htmleditformat(form.webfont_code)#</textarea><br>
			(recommended method)  Local hosting of fonts on same domain.</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Stylesheet URL:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_stylesheet", "table-error","")#><input name="webfont_stylesheet" type="text" size="70" maxlength="255" value="#htmleditformat(form.webfont_stylesheet)#">
		<br>i.e. may be useful when using third party fonts from adobe, fonts.com, or others.</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Heading Scale:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_heading_scale", "table-error","")#><input name="webfont_heading_scale" type="text" size="10" maxlength="10" value="#htmleditformat(application.zcore.functions.zso(form, "webfont_heading_scale", true, 1))#">
			<br>
		i.e. 1, 0.8, 1.2, etc</td>
	</tr> 
	<tr>
		<td style="vertical-align:top; width:140px;">Text Scale:</td>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "webfont_text_scale", "table-error","")#><input name="webfont_text_scale" type="text" size="70" maxlength="100" value="#htmleditformat(application.zcore.functions.zso(form, "webfont_text_scale", true, 1))#">
			<br>i.e. 1, 0.8, 1.2, etc</td>
	</tr> 
    </table>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	</form>
</cffunction>

<cffunction name="updateFontCache" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM 
	#db.table("webfont", request.zos.zcoreDatasource)# 
	WHERE webfont_deleted=#db.param(0)#";
	qwebfont=db.execute("qwebfont"); 
	webfontLookup={};
	for(font in qwebfont){
		webfontLookup[font.webfont_id]=font;
	}
	application.zcore.webfontLookup=webfontLookup;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("webfont", request.zos.zcoreDatasource)# 
	WHERE webfont_deleted=#db.param(0)# 
	ORDER BY webfont_name ASC ";
	qFont=db.execute("qFont");
	if(qFont.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/server-manager/admin/fonts/index");	
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
    <div class="z-float">
		<h2 style="display:inline-block; padding-right:10px;">Webfonts</h2>
		<a href="/z/server-manager/admin/fonts/add" class="z-manager-search-button">Add</a>
	</div>
	<cfscript>
	stylesheetStruct={};
	</cfscript>
	<p>The feature system has a field type called font, which will allow the user to select fonts that are added here.</p>
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<th>Name</th>
			<th><span style="font-size:36px;">Heading Preview</span></th>
			<th><span style="font-size:18px;">Text Preview</span></th>
			<th>Admin</th>
		</tr>
		<cfloop query="qFont">
			<cfscript>
			stylesheetStruct[qFont.webfont_stylesheet]=true;
			application.zcore.template.appendTag("meta", '<style>'&qFont.webfont_code&'</style>');
			</cfscript>
			<tr>
				<td>#qFont.webfont_name#</td>
				<td><span style="font-size:#round(qFont.webfont_heading_scale*36)#px; font-family:#qFont.webfont_family#; font-weight:#qFont.webfont_weight#; font-style:#qFont.webfont_style#;">Heading Preview</span></td>
				<td><span style="font-size:#round(qFont.webfont_text_scale*18)#px; font-family:#qFont.webfont_family#; font-weight:#qFont.webfont_weight#; font-style:#qFont.webfont_style#;">Text Preview</span></td>
				<td><a href="/z/server-manager/admin/fonts/edit?webfont_id=#qFont.webfont_id#" class="z-manager-search-button">Edit</a> 
					<a href="/z/server-manager/admin/fonts/delete?webfont_id=#qFont.webfont_id#" class="z-manager-search-button">Delete</a></td>
			</tr> 
		</cfloop>
    </table>
    <cfscript>
    for(stylesheet in stylesheetStruct){
    	application.zcore.skin.includeCSS(stylesheet);
	}
    </cfscript>
</cffunction>
</cfoutput>
</cfcomponent>