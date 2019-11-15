<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="public" roles="administrator">
	<cfscript>
	form.sid=application.zcore.functions.zso(form, "sid", true);
	if(not application.zcore.user.checkServerAccess()){
		form.sid=request.zos.globals.id;
	}
	request.zos.stylesetPath="/zupload/styleset/";
	request.zos.stylesetUploadPath="zupload/styleset/";
	request.zos.arrStylesetColorField=["styleset_aside_background_color", "styleset_aside_heading_1_color", "styleset_aside_heading_2_color", "styleset_aside_heading_3_color", "styleset_aside_link_color", "styleset_aside_link_hover_color", "styleset_aside_menu_link_background_color", "styleset_aside_menu_link_hover_background_color", "styleset_aside_menu_link_hover_text_color", "styleset_aside_menu_link_text_color", "styleset_aside_text_color", "styleset_background_color", "styleset_body_background_color", "styleset_body_heading_1_color", "styleset_body_heading_2_color", "styleset_body_heading_3_color", "styleset_body_link_color", "styleset_body_link_hover_color", "styleset_body_text_color", "styleset_bullet_color", "styleset_button_2_background_color", "styleset_button_2_text_color", "styleset_button_background_color", "styleset_button_text_color", "styleset_contain_background_color", "styleset_contain_border_color", "styleset_contain_bullet_color", "styleset_contain_button_2_background_color", "styleset_contain_button_2_text_color", "styleset_contain_button_background_color", "styleset_contain_button_text_color", "styleset_contain_heading_1_color", "styleset_contain_heading_2_color", "styleset_contain_heading_3_color", "styleset_contain_link_color", "styleset_contain_link_hover_color", "styleset_contain_text_color", "styleset_form_field_background_color", "styleset_form_field_border_color", "styleset_form_field_text_color", "styleset_form_submit_background_color", "styleset_form_submit_text_color", "styleset_heading_1_color", "styleset_heading_2_color", "styleset_heading_3_color", "styleset_image_border_color", "styleset_inner_container_background_color", "styleset_inner_container_border_color", "styleset_inner_container_button_2_background_color", "styleset_inner_container_button_2_text_color", "styleset_inner_container_button_background_color", "styleset_inner_container_button_text_color", "styleset_inner_container_heading_1_color", "styleset_inner_container_heading_2_color", "styleset_inner_container_heading_3_color", "styleset_inner_container_text_color", "styleset_link_color", "styleset_link_hover_color", "styleset_nocontain_border_color", "styleset_nocontain_bullet_color", "styleset_nocontain_button_background_color", "styleset_nocontain_button_text_color", "styleset_nocontain_link_color", "styleset_nocontain_link_hover_color", "styleset_nocontain_panel_bullet_color", "styleset_nocontain_panel_button_2_background_color", "styleset_nocontain_panel_button_2_text_color", "styleset_nocontain_panel_button_background_color", "styleset_nocontain_panel_button_text_color", "styleset_nocontain_panel_heading_1_color", "styleset_nocontain_panel_heading_2_color", "styleset_nocontain_panel_heading_3_color", "styleset_nocontain_panel_link_color", "styleset_nocontain_panel_link_hover_color", "styleset_nocontain_panel_text_color", "styleset_nocontain_text_color", "styleset_panel_image_border_color", "styleset_panel_overlay_background_color", "styleset_panel_overlay_text_color", "styleset_row_background_color", "styleset_slideshow_circle_active_color", "styleset_slideshow_circle_inactive_color", "styleset_slideshow_nextprevious_button_color", "styleset_text_color"];
	request.zos.arrStylesetFontField=["styleset_aside_heading_1_font", "styleset_aside_heading_2_font", "styleset_aside_heading_3_font", "styleset_aside_text_font", "styleset_body_heading_1_font", "styleset_body_heading_2_font", "styleset_body_heading_3_font", "styleset_button_font", "styleset_contain_button_font", "styleset_contain_heading_1_font", "styleset_contain_heading_2_font", "styleset_contain_heading_3_font", "styleset_contain_text_font", "styleset_heading_1_font", "styleset_heading_2_font", "styleset_heading_3_font", "styleset_inner_container_button_font", "styleset_inner_container_heading_1_font", "styleset_inner_container_heading_2_font", "styleset_inner_container_heading_3_font", "styleset_inner_container_text_font", "styleset_nocontain_button_font", "styleset_nocontain_panel_button_font", "styleset_nocontain_panel_heading_1_font", "styleset_nocontain_panel_heading_2_font", "styleset_nocontain_panel_heading_3_font", "styleset_nocontain_panel_text_font", "styleset_nocontain_text_font", "styleset_panel_overlay_font", "styleset_text_font"];
	request.zos.stylesetColorFieldStruct={};
	request.zos.stylesetFontFieldStruct={};
	for(field in request.zos.arrStylesetColorField){
		request.zos.stylesetColorFieldStruct[field]=true;
	}
	for(field in request.zos.arrStylesetFontField){
		request.zos.stylesetFontFieldStruct[field]=true;
	}
	</cfscript>
</cffunction> 

<!--- todo: get stylesetUsage to allow remapping those too --->
<cffunction name="getStylesetUsage" localmode="modern" access="public">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getFontColorUsage" localmode="modern" access="public">
	<cfargument name="qSet" type="query" required="yes">
	<cfscript>
	ts={
		colorUsage:{},
		fontUsage:{}
	};
	for(row in qSet){
		for(field in request.zos.arrStylesetFontField){
			if(arguments.qSet[field] NEQ "" and arguments.qSet[field] NEQ "0"){
				ts.fontUsage[arguments.qSet[field]]=true;
			}
		}
		for(field in request.zos.arrStylesetColorField){
			if(arguments.qSet[field] NEQ "" and arguments.qSet[field] NEQ "0"){
				ts.colorUsage[arguments.qSet[field]]=true;
			}
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="updateCache" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM 
	#db.table("styleset", "zgraph")# 
	WHERE styleset_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# ";
	qStyle=db.execute("qStyle"); 
	stylesetLookup={};
	for(style in qStyle){
		stylesetLookup[style.styleset_id]=style;
	}
	arguments.ss.stylesetLookup=stylesetLookup;
	</cfscript>
</cffunction>

<cffunction name="remapFontColorSave" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	form.styleset_id=application.zcore.functions.zso(form, "styleset_id", true);
	form.remap=application.zcore.functions.zso(form, "remap", true, 2); // 0 is fonts, 1 is colors, 2 is both

	// TODO: select * from feature_field WHERE feature_type_id=#db.param(color)#

	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE ";
	if(form.styleset_id NEQ 0){
		db.sql&=" styleset_id = #db.param(form.styleset_id)# and ";
	}
	db.sql&=" site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_deleted=#db.param(0)#";
	qSet=db.execute("qSet");

	colorRemap={};
	for(i=1;i<=form.colorCount;i++){
		if(form["newColor#i#"] NEQ ""){
			colorRemap[form["colorId#i#"]]=form["newColor#i#"];
		}
	}
	fontRemap={};
	for(i=1;i<=form.fontCount;i++){
		if(form["newFont#i#"] NEQ ""){
			fontRemap[form["fontId#i#"]]=form["newFont#i#"];
		}
	}
	updateCount=0;
	for(row in qSet){
		ts={
			table:"styleset",
			datasource:"zgraph",
			struct:{
				styleset_id:row.styleset_id,
				site_id:row.site_id,
				styleset_updated_datetime:request.zos.mysqlnow,
				styleset_deleted:0
			}
		};
		update=false;
		for(field in request.zos.arrStylesetFontField){
			if(arguments.qSet[field] NEQ "" and arguments.qSet[field] NEQ "0"){
				if(structkeyexists(fontRemap, arguments.qSet[field])){
					ts.struct[field]=fontRemap[arguments.qSet[field]];
					update=true;
				}
			}
		}
		for(field in request.zos.arrStylesetColorField){
			if(arguments.qSet[field] NEQ "" and arguments.qSet[field] NEQ "0"){
				if(structkeyexists(colorRemap, arguments.qSet[field])){
					ts.struct[field]=colorRemap[arguments.qSet[field]];
					update=true;
				}
			}
		}
		if(update){
			updateCount++;
			application.zcore.functions.zUpdate(ts);

		}
	}
	updateCache(application.zcore);
	application.zcore.status.setStatus(request.zsid, "#updateCount# stylesets updated.");
	application.zcore.functions.zRedirect("/z/admin/styleset/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<!--- /z/admin/styleset/remapFontColor --->
<cffunction name="remapFontColor" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	form.styleset_id=application.zcore.functions.zso(form, "styleset_id", true, 3);
	form.remap=application.zcore.functions.zso(form, "remap", true, 2); // 0 is fonts, 1 is colors, 2 is both

	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE ";
	if(form.styleset_id NEQ 0){
		db.sql&=" styleset_id = #db.param(form.styleset_id)# and ";
	}
	db.sql&=" site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_deleted=#db.param(0)#";
	qSet=db.execute("qSet");
	fontColorUsage=getFontColorUsage(qSet);


	echo('
	<form action="/z/admin/styleset/remapFontColorSave" method="post">
	<input type="hidden" name="styleset_id" value="#form.styleset_id#">
	<input type="hidden" name="remap" value="#form.remap#">
	<table style=" border-spacing:0px;" class="table-list">');
	if(form.remap EQ 2 or form.remap EQ 1){
		echo('<tr><td colspan="2"><h2>Remap Colors</h2></td></tr>');
		echo('<tr><td>Original Color</td><td>New Color</td></tr>');
		colorCount=0;
		for(color in fontColorUsage.colorUsage){
			colorCount++;
			if(structkeyexists(application.zcore.stylesetColorLookup, color)){
				oldColor=application.zcore.stylesetColorLookup[color];
			}else{
				oldColor={ styleset_color_name: "Color Missing", styleset_color_value: "##FFFFFF" };
			}
			form["newColor#colorCount#"]="";
			echo('<tr>
				<td><div style="width:25px; height:25px; background-color:#oldColor.styleset_color_value#; margin-right:10px; float:left;"></div> #oldColor.styleset_color_name#
					<input type="hidden" name="colorId#colorCount#" value="#color#">
				</td>
				<td>');
			colorSelectField("newColor#colorCount#");
			echo('</td>
			</tr>');
		}
	}
	if(form.remap EQ 2 or form.remap EQ 0){
		fontCount=0;
		for(font in fontColorUsage.fontUsage){
			fontCount++;
			if(structkeyexists(application.zcore.webfontLookup, font)){
				oldFont=application.zcore.webfontLookup[font];
			}else{
				oldFont={ webfont_name: "Font Missing" };
			}
			form["newfont#fontCount#"]="";
			echo('<tr><td colspan="2"><h2>Remap Fonts</h2></td></tr>');
			echo('<tr><td>Original Font</td><td>New Font</td></tr>');
			echo('<tr><td>
				#oldFont.webfont_name#
					<input type="hidden" name="fontId#fontCount#" value="#font#">
			</td><td>');
			fontSelectField("newfont#fontCount#");
			echo('</td></tr>');
		}
	}

	echo('
		<tr><td colspan="2"><input type="submit" name="submit1" value="Submit"> <input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/admin/styleset/index'';"></td></tr>
	</table>
	<input type="hidden" name="colorCount" value="#colorCount#">
	<input type="hidden" name="fontCount" value="#fontCount#">
	</form>');
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE styleset_id = #db.param(form.styleset_id)# and 
	site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_deleted=#db.param(0)#";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "styleset no longer exists.",false,true);
		application.zcore.functions.zRedirect('/z/admin/styleset/index?zsid='&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.styleset_id=form.styleset_id;
	    deleteImage(qSet.styleset_bullet_image, qSet.site_id);
	    deleteImage(qSet.styleset_row_background_image, qSet.site_id);
	    deleteImage(qSet.styleset_row_background_mobile_image, qSet.site_id);
	    deleteImage(qSet.styleset_contain_bullet_image, qSet.site_id);
	    deleteImage(qSet.styleset_nocontain_bullet_image, qSet.site_id);
	    deleteImage(qSet.styleset_nocontain_panel_bullet_image, qSet.site_id);
	    deleteImage(qSet.styleset_slideshow_next_button_image, qSet.site_id);
	    deleteImage(qSet.styleset_slideshow_previous_button_image, qSet.site_id);
		db.sql="DELETE FROM #db.table("styleset", "zgraph")# 
		WHERE styleset_id = #db.param(form.styleset_id)# and 
		site_id = #db.param(qSet.site_id)# and 
		styleset_deleted=#db.param(0)# ";
		db.execute("qDelete"); 
		updateCache(application.zcore);
		application.zcore.status.setStatus(request.zsid, "Styleset deleted.");
		application.zcore.functions.zRedirect('/z/admin/styleset/index?zsid='&request.zsid);
		</cfscript>
	<cfelse> 
		<div style="text-align:center;"><span class="medium">
		Are you sure you want to delete this styleset?<br /><br /> 
		Styleset Name: #qSet.styleset_name#
		<br /><br />
		<a href="/z/admin/styleset/delete?confirm=1&sid=#form.sid#&styleset_id=#form.styleset_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/admin/styleset/index">No</a></span></div>
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
	if(form.styleset_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Name is required", form, true);
		fail=true;
	}
	if(fail){
		if(currentMethod EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/styleset/edit?styleset_id=#form.styleset_id#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/admin/styleset/add?zsid=#Request.zsid#");
		}
	}
    form.site_id=request.zos.globals.id;
	if(application.zcore.user.checkServerAccess()){
		if(form.preset EQ 1){
			form.site_id=0;
    	}
    }

	if(currentMethod EQ "update"){
		db.sql="select * from #db.table("styleset", "zgraph")# WHERE 
		styleset_id=#db.param(form.styleset_id)# and 
		site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		styleset_deleted=#db.param(0)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.site_id NEQ form.site_id){
			db.sql="update #db.table("styleset", "zgraph")# 
			SET 
			site_id=#db.param(form.site_id)# 
			WHERE 
			styleset_id=#db.param(form.styleset_id)# and 
			site_id = #db.param(qCheck.site_id)# and 
			styleset_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}
	} 
    if(form.site_id EQ 0){
    	request.uploadPath=request.zos.globals.serverprivatehomedir&request.zos.stylesetUploadPath;
	}else{
    	request.uploadPath=request.zos.globals.privatehomedir&request.zos.stylesetUploadPath;
    }
    application.zcore.functions.zCreateDirectory(request.uploadPath);

    handleImageUpload("styleset_bullet_image", "62x62", form.site_id);
    handleImageUpload("styleset_row_background_image", "1920x1080", form.site_id);
    handleImageUpload("styleset_row_background_mobile_image", "960x960", form.site_id);
    handleImageUpload("styleset_contain_bullet_image", "62x62", form.site_id);
    handleImageUpload("styleset_nocontain_bullet_image", "62x62", form.site_id);
    handleImageUpload("styleset_nocontain_panel_bullet_image", "62x62", form.site_id);
    handleImageUpload("styleset_slideshow_next_button_image", "200x200", form.site_id);
    handleImageUpload("styleset_slideshow_previous_button_image", "200x200", form.site_id);

	form.styleset_deleted=0;
	form.styleset_updated_datetime=request.zos.mysqlnow; 
	inputStruct = StructNew();
	inputStruct.table = "styleset";
	inputStruct.struct=form;
	inputStruct.datasource="zgraph";
	if(currentMethod EQ "insert"){
		form.styleset_id = application.zcore.functions.zInsert(inputStruct);
		if(form.styleset_id EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to add styleset",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset/add?zsid=#Request.zsid#");
		} 
	}else{   

		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Failed to update styleset",form,true);
			application.zcore.functions.zRedirect("/z/admin/styleset/edit?sid=#form.styleset_id#&zsid=#Request.zsid#");
		}
	}  
	updateCache(application.zcore);
	application.zcore.status.setStatus(Request.zsid, "Styleset saved");
	application.zcore.functions.zRedirect('/z/admin/styleset/index?zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="deleteImage" localmode="modern" access="public">
	<cfargument name="fileName" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
    if(arguments.fileName NEQ ""){
	    if(arguments.site_id EQ 0){
	    	uploadPath=request.zos.globals.serverprivatehomedir&request.zos.stylesetUploadPath;
		}else{
	    	uploadPath=request.zos.globals.privatehomedir&request.zos.stylesetUploadPath;
	    }
    	application.zcore.functions.zDeleteFile(uploadPath&arguments.fileName);
    }
	return true;
	</cfscript>
</cffunction>

<!--- handleImageUpload(field, size, site_id); --->
<cffunction name="handleImageUpload" localmode="modern" access="public">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="size" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	arrList=ArrayNew(1);
	form[arguments.field]=application.zcore.functions.zso(form, arguments.field);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.field, request.uploadPath, arguments.size);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.field, request.uploadPath, arguments.size, 'styleset', 'styleset_id', arguments.field&"_delete", "zgraph", "", arguments.site_id);
	}  
	if(isarray(arrList) EQ false){
		return false;
	}else if(ArrayLen(arrList) NEQ 0){
		form[arguments.field]=arrList[1];
	}else{
		StructDelete(form, arguments.field);
	}
	if(application.zcore.functions.zso(form, arguments.field&'_delete',true) EQ 1){
		form[arguments.field]='';	
	}
	return true;
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
	form.styleset_id=application.zcore.functions.zso(form, "styleset_id"); 
	currentMethod=form.method;
	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE styleset_deleted=#db.param(0)# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_id=#db.param(form.styleset_id)# 
	ORDER BY styleset_name ASC ";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset/index");	
	}
	application.zcore.functions.zQueryToStruct(qSet); 
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
	<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Styleset</h2>
	<form class="zFormCheckDirty" action="/z/admin/styleset/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?styleset_id=#form.styleset_id#" method="post" enctype="multipart/form-data">

	<cfscript>
	tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs([
		"Default",
		"Row",
		"Inner Container",
		"Contained",
		"Uncontained",
		"Body",
		"Aside",
		"Form",
		"Slideshow"
	]);
	tabCom.setMenuName("member-color-edit");
	cancelURL="/z/admin/styleset/index";
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()# 
	#tabCom.beginFieldSet("Default")#
	<p>Setting Font and Padding Scale fields to 0 will let them inherit their value.</p>

	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<cfif application.zcore.user.checkServerAccess()>
		<tr>
			<th style="vertical-align:top; width:140px;">Preset</th>
			<td><input type="radio" name="preset" id="preset1" value="1" <cfif form.site_id EQ "0">checked="checked"</cfif>> <label for="preset1">Yes</label> 
				<input type="radio" name="preset" id="preset0" value="0" <cfif form.site_id NEQ "0">checked="checked"</cfif>> <label for="preset0">No</label> 
				
			</td>
		</tr>
	</cfif>

	<tr>
		<th style="vertical-align:top; width:140px;">Group:</th>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "styleset_name", "table-error","")#>
		<cfscript>
		db.sql="select * FROM #db.table("styleset_group", "zgraph")# 
		WHERE 
		site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		styleset_group_deleted=#db.param(0)# 
		ORDER BY styleset_group_name ASC";
		qGroup=db.execute("qGroup", "", 10000, "query", false);  
	
		ts = StructNew();
		ts.name = "styleset_group_id"; 
		ts.size = 1; // more for multiple select 
		ts.query = qGroup;
		ts.queryLabelField = "styleset_group_name";
		ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
		ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
		ts.queryValueField = "styleset_group_id"; 
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript>
		</td>
	</tr>   
	<tr>
		<th style="vertical-align:top; width:140px;">Styleset Name: *</th>
		<td  #application.zcore.status.getErrorStyle(Request.zsid, "styleset_name", "table-error","")#><input name="styleset_name" type="text" size="70" maxlength="100" value="#htmleditformat(form.styleset_name)#"></td>
	</tr>   
	<tr><th>Background Color</th><td>#colorSelectField("styleset_background_color")#</td></tr>
	<tr><th>Text Color</th><td>#colorSelectField("styleset_text_color")#</td></tr>
	<tr><th>Text Font</th><td>#fontSelectField("styleset_text_font")#</td></tr>
	<tr><th>Text Font Scale</th><td><input type="number" name="styleset_text_font_scale" value="#htmleditformat(form["styleset_text_font_scale"])#"></td></tr>
	<tr><th>Text Padding Scale</th><td><input type="number" name="styleset_text_padding_scale" value="#htmleditformat(form["styleset_text_padding_scale"])#"></td></tr>
	<tr><th>Paragraph Padding Scale</th><td><input type="number" name="styleset_paragraph_padding_scale" value="#htmleditformat(form["styleset_paragraph_padding_scale"])#"></td></tr>
	<tr><th>Line Height</th><td><input type="number" name="styleset_line_height" value="#htmleditformat(form["styleset_line_height"])#"></td></tr>
	<tr><th>Link Color</th><td>#colorSelectField("styleset_link_color")#</td></tr>
	<tr><th>Link Hover Color</th><td>#colorSelectField("styleset_link_hover_color")#</td></tr>
	<tr><th>Heading 1 Color</th><td>#colorSelectField("styleset_heading_1_color")#</td></tr>
	<tr><th>Heading 1 Font</th><td>#fontSelectField("styleset_heading_1_font")#</td></tr>
	<tr><th>Heading 1 Font Scale</th><td><input type="number" name="styleset_heading_1_font_scale" value="#htmleditformat(form["styleset_heading_1_font_scale"])#"></td></tr>
	<tr><th>Heading 1 Padding Scale</th><td><input type="number" name="styleset_heading_1_padding_scale" value="#htmleditformat(form["styleset_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Heading 2 Color</th><td>#colorSelectField("styleset_heading_2_color")#</td></tr>
	<tr><th>Heading 2 Font</th><td>#fontSelectField("styleset_heading_2_font")#</td></tr>
	<tr><th>Heading 2 Font Scale</th><td><input type="number" name="styleset_heading_2_font_scale" value="#htmleditformat(form["styleset_heading_2_font_scale"])#"></td></tr>
	<tr><th>Heading 2 Padding Scale</th><td><input type="number" name="styleset_heading_2_padding_scale" value="#htmleditformat(form["styleset_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Heading 3 Color</th><td>#colorSelectField("styleset_heading_3_color")#</td></tr>
	<tr><th>Heading 3 Font</th><td>#fontSelectField("styleset_heading_3_font")#</td></tr>
	<tr><th>Heading 3 Font Scale</th><td><input type="number" name="styleset_heading_3_font_scale" value="#htmleditformat(form["styleset_heading_3_font_scale"])#"></td></tr>
	<tr><th>Heading 3 Padding Scale</th><td><input type="number" name="styleset_heading_3_padding_scale" value="#htmleditformat(form["styleset_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Bullet Color</th><td>#colorSelectField("styleset_bullet_color")#</td></tr>
	<tr><th>Bullet Image</th><td>
		#application.zcore.functions.zInputImage('styleset_bullet_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#
	</td></tr>
	<tr><th>Button 2 Background Color</th><td>#colorSelectField("styleset_button_2_background_color")#</td></tr>
	<tr><th>Button 2 Text Color</th><td>#colorSelectField("styleset_button_2_text_color")#</td></tr>
	<tr><th>Button Background Color</th><td>#colorSelectField("styleset_button_background_color")#</td></tr>
	<tr><th>Button Border Radius</th><td><input type="number" name="styleset_button_border_radius" value="#htmleditformat(form["styleset_button_border_radius"])#"></td></tr>
	<tr><th>Button Font</th><td>#fontSelectField("styleset_button_font")#</td></tr>
	<tr><th>Button Font Scale</th><td><input type="number" name="styleset_button_font_scale" value="#htmleditformat(form["styleset_button_font_scale"])#"></td></tr>
	<tr><th>Button Padding Scale</th><td><input type="number" name="styleset_button_padding_scale" value="#htmleditformat(form["styleset_button_padding_scale"])#"></td></tr>
	<tr><th>Button Text Color</th><td>#colorSelectField("styleset_button_text_color")#</td></tr>
	<tr><th>Image Border Color</th><td>#colorSelectField("styleset_image_border_color")#</td></tr>
	<tr><th>Image Border Size</th><td>#borderSelectField("styleset_image_border_size")#</td></tr>
	<tr><th>Panel Image Border Color</th><td>#colorSelectField("styleset_panel_image_border_color")#</td></tr>
	<tr><th>Panel Image Border Size</th><td>#borderSelectField("styleset_panel_image_border_size")#</td></tr>
	<tr><th>Panel Overlay Background Color</th><td>#colorSelectField("styleset_panel_overlay_background_color")#</td></tr>
	<tr><th>Panel Overlay Font</th><td>#fontSelectField("styleset_panel_overlay_font")#</td></tr>
	<tr><th>Panel Overlay Font Scale</th><td><input type="number" name="styleset_panel_overlay_font_scale" value="#htmleditformat(form["styleset_panel_overlay_font_scale"])#"></td></tr>
	<tr><th>Panel Overlay Padding Scale</th><td><input type="number" name="styleset_panel_overlay_padding_scale" value="#htmleditformat(form["styleset_panel_overlay_padding_scale"])#"></td></tr>
	<tr><th>Panel Overlay Text Color</th><td>#colorSelectField("styleset_panel_overlay_text_color")#</td></tr>
    </table> 
    #tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Row")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Row Background Attachment</th><td><input type="text" name="styleset_row_background_attachment" value="#htmleditformat(form["styleset_row_background_attachment"])#"></td></tr>
	<tr><th>Row Background Color</th><td>#colorSelectField("styleset_row_background_color")#</td></tr>
	<tr><th>Row Background Image</th><td>
		#application.zcore.functions.zInputImage('styleset_row_background_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#
	</td></tr>
	<tr><th>Row Background Mobile Image</th><td>
		#application.zcore.functions.zInputImage('styleset_row_background_mobile_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#

	</td></tr>
	<tr><th>Row Background Position</th><td><input type="text" name="styleset_row_background_position" value="#htmleditformat(form["styleset_row_background_position"])#"></td></tr>
	<tr><th>Row Background Repeat</th><td><input type="text" name="styleset_row_background_repeat" value="#htmleditformat(form["styleset_row_background_repeat"])#"></td></tr>
	<tr><th>Row Background Size</th><td>#borderSelectField("styleset_row_background_size")#</td></tr>
	<tr><th>Row Footer Padding Scale</th><td><input type="number" name="styleset_row_footer_padding_scale" value="#htmleditformat(form["styleset_row_footer_padding_scale"])#"></td></tr>
	<tr><th>Row Header Padding Scale</th><td><input type="number" name="styleset_row_header_padding_scale" value="#htmleditformat(form["styleset_row_header_padding_scale"])#"></td></tr>
	<tr><th>Row Margin Bottom Scale</th><td><input type="number" name="styleset_row_margin_bottom_scale" value="#htmleditformat(form["styleset_row_margin_bottom_scale"])#"></td></tr>
	<tr><th>Row Margin Top Scale</th><td><input type="number" name="styleset_row_margin_top_scale" value="#htmleditformat(form["styleset_row_margin_top_scale"])#"></td></tr>
	<tr><th>Row Padding Scale</th><td><input type="number" name="styleset_row_padding_scale" value="#htmleditformat(form["styleset_row_padding_scale"])#"></td></tr>
	<tr><th>Row Text Align</th><td><input type="text" name="styleset_row_text_align" value="#htmleditformat(form["styleset_row_text_align"])#"></td></tr>
	</table>
    #tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Inner Container")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Inner Container Background Color</th><td>#colorSelectField("styleset_inner_container_background_color")#</td></tr>
	<tr><th>Inner Container Border Color</th><td>#colorSelectField("styleset_inner_container_border_color")#</td></tr>
	<tr><th>Inner Container Border Size</th><td>#borderSelectField("styleset_inner_container_border_size")#</td></tr>
	<tr><th>Inner Container Border Radius</th><td><input type="number" name="styleset_inner_container_border_radius" value="#htmleditformat(form["styleset_inner_container_border_radius"])#"></td></tr>
	<tr><th>Inner Container Button 2 Background Color</th><td>#colorSelectField("styleset_inner_container_button_2_background_color")#</td></tr>
	<tr><th>Inner Container Button 2 Text Color</th><td>#colorSelectField("styleset_inner_container_button_2_text_color")#</td></tr>
	<tr><th>Inner Container Button Background Color</th><td>#colorSelectField("styleset_inner_container_button_background_color")#</td></tr>
	<tr><th>Inner Container Button Font</th><td>#fontSelectField("styleset_inner_container_button_font")#</td></tr>
	<tr><th>Inner Container Button Font Scale</th><td><input type="number" name="styleset_inner_container_button_font_scale" value="#htmleditformat(form["styleset_inner_container_button_font_scale"])#"></td></tr>
	<tr><th>Inner Container Button Padding Scale</th><td><input type="number" name="styleset_inner_container_button_padding_scale" value="#htmleditformat(form["styleset_inner_container_button_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Button Text Color</th><td>#colorSelectField("styleset_inner_container_button_text_color")#</td></tr>
	<tr><th>Inner Container Heading 1 Color</th><td>#colorSelectField("styleset_inner_container_heading_1_color")#</td></tr>
	<tr><th>Inner Container Heading 1 Font</th><td>#fontSelectField("styleset_inner_container_heading_1_font")#</td></tr>
	<tr><th>Inner Container Heading 1 Font Scale</th><td><input type="number" name="styleset_inner_container_heading_1_font_scale" value="#htmleditformat(form["styleset_inner_container_heading_1_font_scale"])#"></td></tr>
	<tr><th>Inner Container Heading 1 Padding Scale</th><td><input type="number" name="styleset_inner_container_heading_1_padding_scale" value="#htmleditformat(form["styleset_inner_container_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Heading 2 Color</th><td>#colorSelectField("styleset_inner_container_heading_2_color")#</td></tr>
	<tr><th>Inner Container Heading 2 Font</th><td>#fontSelectField("styleset_inner_container_heading_2_font")#</td></tr>
	<tr><th>Inner Container Heading 2 Font Scale</th><td><input type="number" name="styleset_inner_container_heading_2_font_scale" value="#htmleditformat(form["styleset_inner_container_heading_2_font_scale"])#"></td></tr>
	<tr><th>Inner Container Heading 2 Padding Scale</th><td><input type="number" name="styleset_inner_container_heading_2_padding_scale" value="#htmleditformat(form["styleset_inner_container_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Heading 3 Color</th><td>#colorSelectField("styleset_inner_container_heading_3_color")#</td></tr>
	<tr><th>Inner Container Heading 3 Font</th><td>#fontSelectField("styleset_inner_container_heading_3_font")#</td></tr>
	<tr><th>Inner Container Heading 3 Font Scale</th><td><input type="number" name="styleset_inner_container_heading_3_font_scale" value="#htmleditformat(form["styleset_inner_container_heading_3_font_scale"])#"></td></tr>
	<tr><th>Inner Container Heading 3 Padding Scale</th><td><input type="number" name="styleset_inner_container_heading_3_padding_scale" value="#htmleditformat(form["styleset_inner_container_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Horizontal Padding Scale</th><td><input type="number" name="styleset_inner_container_x_padding_scale" value="#htmleditformat(form["styleset_inner_container_x_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Size</th><td>#borderSelectField("styleset_inner_container_size")#</td></tr>
	<tr><th>Inner Container Text Align</th><td><input type="text" name="styleset_inner_container_text_align" value="#htmleditformat(form["styleset_inner_container_text_align"])#"></td></tr>
	<tr><th>Inner Container Text Color</th><td>#colorSelectField("styleset_inner_container_text_color")#</td></tr>
	<tr><th>Inner Container Text Font</th><td>#fontSelectField("styleset_inner_container_text_font")#</td></tr>
	<tr><th>Inner Container Text Font Scale</th><td><input type="number" name="styleset_inner_container_text_font_scale" value="#htmleditformat(form["styleset_inner_container_text_font_scale"])#"></td></tr>
	<tr><th>Inner Container Text Padding Scale</th><td><input type="number" name="styleset_inner_container_text_padding_scale" value="#htmleditformat(form["styleset_inner_container_text_padding_scale"])#"></td></tr>
	<tr><th>Inner Container Vertical Padding Scale</th><td><input type="number" name="styleset_inner_container_y_padding_scale" value="#htmleditformat(form["styleset_inner_container_y_padding_scale"])#"></td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Contained")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Contained Background Color</th><td>#colorSelectField("styleset_contain_background_color")#</td></tr>
	<tr><th>Contained Border Color</th><td>#colorSelectField("styleset_contain_border_color")#</td></tr>
	<tr><th>Contained Border Radius</th><td><input type="number" name="styleset_contain_border_radius" value="#htmleditformat(form["styleset_contain_border_radius"])#"></td></tr>
	<tr><th>Contained Border Size</th><td>#borderSelectField("styleset_contain_border_size")#</td></tr>
	<tr><th>Contained Bullet Color</th><td>#colorSelectField("styleset_contain_bullet_color")#</td></tr>
	<tr><th>Contained Bullet Image</th><td>

		#application.zcore.functions.zInputImage('styleset_contain_bullet_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#
	</td></tr>
	<tr><th>Contained Button 2 Background Color</th><td>#colorSelectField("styleset_contain_button_2_background_color")#</td></tr>
	<tr><th>Contained Button 2 Text Color</th><td>#colorSelectField("styleset_contain_button_2_text_color")#</td></tr>
	<tr><th>Contained Button Background Color</th><td>#colorSelectField("styleset_contain_button_background_color")#</td></tr>
	<tr><th>Contained Button Font</th><td>#fontSelectField("styleset_contain_button_font")#</td></tr>
	<tr><th>Contained Button Font Scale</th><td><input type="number" name="styleset_contain_button_font_scale" value="#htmleditformat(form["styleset_contain_button_font_scale"])#"></td></tr>
	<tr><th>Contained Button Padding Scale</th><td><input type="number" name="styleset_contain_button_padding_scale" value="#htmleditformat(form["styleset_contain_button_padding_scale"])#"></td></tr>
	<tr><th>Contained Button Text Color</th><td>#colorSelectField("styleset_contain_button_text_color")#</td></tr>
	<tr><th>Contained Header Horizontal Padding Scale</th><td><input type="number" name="styleset_contain_header_x_padding_scale" value="#htmleditformat(form["styleset_contain_header_x_padding_scale"])#"></td></tr>
	<tr><th>Contained Header Vertical Padding Scale</th><td><input type="number" name="styleset_contain_header_y_padding_scale" value="#htmleditformat(form["styleset_contain_header_y_padding_scale"])#"></td></tr>
	<tr><th>Contained Heading 1 Color</th><td>#colorSelectField("styleset_contain_heading_1_color")#</td></tr>
	<tr><th>Contained Heading 1 Font</th><td>#fontSelectField("styleset_contain_heading_1_font")#</td></tr>
	<tr><th>Contained Heading 1 Font Scale</th><td><input type="number" name="styleset_contain_heading_1_font_scale" value="#htmleditformat(form["styleset_contain_heading_1_font_scale"])#"></td></tr>
	<tr><th>Contained Heading 1 Padding Scale</th><td><input type="number" name="styleset_contain_heading_1_padding_scale" value="#htmleditformat(form["styleset_contain_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Contained Heading 2 Color</th><td>#colorSelectField("styleset_contain_heading_2_color")#</td></tr>
	<tr><th>Contained Heading 2 Font</th><td>#fontSelectField("styleset_contain_heading_2_font")#</td></tr>
	<tr><th>Contained Heading 2 Font Scale</th><td><input type="number" name="styleset_contain_heading_2_font_scale" value="#htmleditformat(form["styleset_contain_heading_2_font_scale"])#"></td></tr>
	<tr><th>Contained Heading 2 Padding Scale</th><td><input type="number" name="styleset_contain_heading_2_padding_scale" value="#htmleditformat(form["styleset_contain_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Contained Heading 3 Color</th><td>#colorSelectField("styleset_contain_heading_3_color")#</td></tr>
	<tr><th>Contained Heading 3 Font</th><td>#fontSelectField("styleset_contain_heading_3_font")#</td></tr>
	<tr><th>Contained Heading 3 Font Scale</th><td><input type="number" name="styleset_contain_heading_3_font_scale" value="#htmleditformat(form["styleset_contain_heading_3_font_scale"])#"></td></tr>
	<tr><th>Contained Heading 3 Padding Scale</th><td><input type="number" name="styleset_contain_heading_3_padding_scale" value="#htmleditformat(form["styleset_contain_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Contained Line Height</th><td><input type="number" name="styleset_contain_line_height" value="#htmleditformat(form["styleset_contain_line_height"])#"></td></tr>
	<tr><th>Contained Link Color</th><td>#colorSelectField("styleset_contain_link_color")#</td></tr>
	<tr><th>Contained Link Hover Color</th><td>#colorSelectField("styleset_contain_link_hover_color")#</td></tr>
	<tr><th>Contained Panel Container Horizontal Padding Scale</th><td><input type="number" name="styleset_contain_panel_container_x_padding_scale" value="#htmleditformat(form["styleset_contain_panel_container_x_padding_scale"])#"></td></tr>
	<tr><th>Contained Panel Container Vertical Padding Scale</th><td><input type="number" name="styleset_contain_panel_container_y_padding_scale" value="#htmleditformat(form["styleset_contain_panel_container_y_padding_scale"])#"></td></tr>
	<tr><th>Contained Panel Heading Vertical Padding Scale</th><td><input type="number" name="styleset_contain_panel_heading_y_padding_scale" value="#htmleditformat(form["styleset_contain_panel_heading_y_padding_scale"])#"></td></tr>
	<tr><th>Contained Panel Text Container Horizontal Padding Scale</th><td><input type="number" name="styleset_contain_panel_text_container_x_padding_scale" value="#htmleditformat(form["styleset_contain_panel_text_container_x_padding_scale"])#"></td></tr>
	<tr><th>Contained Panel Text Container Vertical Padding Scale</th><td><input type="number" name="styleset_contain_panel_text_container_y_padding_scale" value="#htmleditformat(form["styleset_contain_panel_text_container_y_padding_scale"])#"></td></tr>
	<tr><th>Contained Text Align</th><td><input type="text" name="styleset_contain_text_align" value="#htmleditformat(form["styleset_contain_text_align"])#"></td></tr>
	<tr><th>Contained Text Color</th><td>#colorSelectField("styleset_contain_text_color")#</td></tr>
	<tr><th>Contained Text Font</th><td>#fontSelectField("styleset_contain_text_font")#</td></tr>
	<tr><th>Contained Text Font Scale</th><td><input type="number" name="styleset_contain_text_font_scale" value="#htmleditformat(form["styleset_contain_text_font_scale"])#"></td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Uncontained")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Uncontained Border Color</th><td>#colorSelectField("styleset_nocontain_border_color")#</td></tr>
	<tr><th>Uncontained Border Radius</th><td><input type="number" name="styleset_nocontain_border_radius" value="#htmleditformat(form["styleset_nocontain_border_radius"])#"></td></tr>
	<tr><th>Uncontained Border Size</th><td>#borderSelectField("styleset_nocontain_border_size")#</td></tr>
	<tr><th>Uncontained Bullet Color</th><td>#colorSelectField("styleset_nocontain_bullet_color")#</td></tr>
	<tr><th>Uncontained Bullet Image</th><td>
		#application.zcore.functions.zInputImage('styleset_nocontain_bullet_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#
	</td></tr>
	<tr><th>Uncontained Button Background Color</th><td>#colorSelectField("styleset_nocontain_button_background_color")#</td></tr>
	<tr><th>Uncontained Button Font</th><td>#fontSelectField("styleset_nocontain_button_font")#</td></tr>
	<tr><th>Uncontained Button Font Scale</th><td><input type="number" name="styleset_nocontain_button_font_scale" value="#htmleditformat(form["styleset_nocontain_button_font_scale"])#"></td></tr>
	<tr><th>Uncontained Button Text Color</th><td>#colorSelectField("styleset_nocontain_button_text_color")#</td></tr>
	<tr><th>Uncontained Header Horizontal Padding Scale</th><td><input type="number" name="styleset_nocontain_header_x_padding_scale" value="#htmleditformat(form["styleset_nocontain_header_x_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Header Vertical Padding Scale</th><td><input type="number" name="styleset_nocontain_header_y_padding_scale" value="#htmleditformat(form["styleset_nocontain_header_y_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Line Height</th><td><input type="number" name="styleset_nocontain_line_height" value="#htmleditformat(form["styleset_nocontain_line_height"])#"></td></tr>
	<tr><th>Uncontained Link Color</th><td>#colorSelectField("styleset_nocontain_link_color")#</td></tr>
	<tr><th>Uncontained Link Hover Color</th><td>#colorSelectField("styleset_nocontain_link_hover_color")#</td></tr>
	<tr><th>Uncontained Panel Bullet Color</th><td>#colorSelectField("styleset_nocontain_panel_bullet_color")#</td></tr>
	<tr><th>Uncontained Panel Bullet Image</th><td>
		#application.zcore.functions.zInputImage('styleset_nocontain_panel_bullet_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#

	</td></tr>
	<tr><th>Uncontained Panel Button 2 Background Color</th><td>#colorSelectField("styleset_nocontain_panel_button_2_background_color")#</td></tr>
	<tr><th>Uncontained Panel Button 2 Text Color</th><td>#colorSelectField("styleset_nocontain_panel_button_2_text_color")#</td></tr>
	<tr><th>Uncontained Panel Button Background Color</th><td>#colorSelectField("styleset_nocontain_panel_button_background_color")#</td></tr>
	<tr><th>Uncontained Panel Button Font</th><td>#fontSelectField("styleset_nocontain_panel_button_font")#</td></tr>
	<tr><th>Uncontained Panel Button Font Scale</th><td><input type="number" name="styleset_nocontain_panel_button_font_scale" value="#htmleditformat(form["styleset_nocontain_panel_button_font_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Button Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_button_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_button_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Button Text Color</th><td>#colorSelectField("styleset_nocontain_panel_button_text_color")#</td></tr>
	<tr><th>Uncontained Panel Container Horizontal Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_container_x_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_container_x_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Container Vertical Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_container_y_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_container_y_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 1 Color</th><td>#colorSelectField("styleset_nocontain_panel_heading_1_color")#</td></tr>
	<tr><th>Uncontained Panel Heading 1 Font</th><td>#fontSelectField("styleset_nocontain_panel_heading_1_font")#</td></tr>
	<tr><th>Uncontained Panel Heading 1 Font Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_1_font_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_1_font_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 1 Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_1_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 2 Color</th><td>#colorSelectField("styleset_nocontain_panel_heading_2_color")#</td></tr>
	<tr><th>Uncontained Panel Heading 2 Font</th><td>#fontSelectField("styleset_nocontain_panel_heading_2_font")#</td></tr>
	<tr><th>Uncontained Panel Heading 2 Font Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_2_font_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_2_font_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 2 Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_2_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 3 Color</th><td>#colorSelectField("styleset_nocontain_panel_heading_3_color")#</td></tr>
	<tr><th>Uncontained Panel Heading 3 Font</th><td>#fontSelectField("styleset_nocontain_panel_heading_3_font")#</td></tr>
	<tr><th>Uncontained Panel Heading 3 Font Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_3_font_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_3_font_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading 3 Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_3_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Heading Vertical Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_heading_y_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_heading_y_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Image Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_image_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_image_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Line Height</th><td><input type="number" name="styleset_nocontain_panel_line_height" value="#htmleditformat(form["styleset_nocontain_panel_line_height"])#"></td></tr>
	<tr><th>Uncontained Panel Link Color</th><td>#colorSelectField("styleset_nocontain_panel_link_color")#</td></tr>
	<tr><th>Uncontained Panel Link Hover Color</th><td>#colorSelectField("styleset_nocontain_panel_link_hover_color")#</td></tr>
	<tr><th>Uncontained Panel Summary Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_summary_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_summary_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Text Color</th><td>#colorSelectField("styleset_nocontain_panel_text_color")#</td></tr>
	<tr><th>Uncontained Panel Text Container Horizontal Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_text_container_x_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_text_container_x_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Text Container Vertical Padding Scale</th><td><input type="number" name="styleset_nocontain_panel_text_container_y_padding_scale" value="#htmleditformat(form["styleset_nocontain_panel_text_container_y_padding_scale"])#"></td></tr>
	<tr><th>Uncontained Panel Text Font</th><td>#fontSelectField("styleset_nocontain_panel_text_font")#</td></tr>
	<tr><th>Uncontained Panel Text Font Scale</th><td><input type="number" name="styleset_nocontain_panel_text_font_scale" value="#htmleditformat(form["styleset_nocontain_panel_text_font_scale"])#"></td></tr>
	<tr><th>Uncontained Text Align</th><td><input type="text" name="styleset_nocontain_text_align" value="#htmleditformat(form["styleset_nocontain_text_align"])#"></td></tr>
	<tr><th>Uncontained Text Color</th><td>#colorSelectField("styleset_nocontain_text_color")#</td></tr>
	<tr><th>Uncontained Text Font</th><td>#fontSelectField("styleset_nocontain_text_font")#</td></tr>
	<tr><th>Uncontained Text Font Scale</th><td><input type="number" name="styleset_nocontain_text_font_scale" value="#htmleditformat(form["styleset_nocontain_text_font_scale"])#"></td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Body")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Body Background Color</th><td>#colorSelectField("styleset_body_background_color")#</td></tr>
	<tr><th>Body Heading 1 Color</th><td>#colorSelectField("styleset_body_heading_1_color")#</td></tr>
	<tr><th>Body Heading 1 Font</th><td>#fontSelectField("styleset_body_heading_1_font")#</td></tr>
	<tr><th>Body Heading 1 Font Scale</th><td><input type="number" name="styleset_body_heading_1_font_scale" value="#htmleditformat(form["styleset_body_heading_1_font_scale"])#"></td></tr>
	<tr><th>Body Heading 1 Padding Scale</th><td><input type="number" name="styleset_body_heading_1_padding_scale" value="#htmleditformat(form["styleset_body_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Body Heading 1 Scale</th><td><input type="number" name="styleset_body_heading_1_scale" value="#htmleditformat(form["styleset_body_heading_1_scale"])#"></td></tr>
	<tr><th>Body Heading 2 Color</th><td>#colorSelectField("styleset_body_heading_2_color")#</td></tr>
	<tr><th>Body Heading 2 Font</th><td>#fontSelectField("styleset_body_heading_2_font")#</td></tr>
	<tr><th>Body Heading 2 Font Scale</th><td><input type="number" name="styleset_body_heading_2_font_scale" value="#htmleditformat(form["styleset_body_heading_2_font_scale"])#"></td></tr>
	<tr><th>Body Heading 2 Padding Scale</th><td><input type="number" name="styleset_body_heading_2_padding_scale" value="#htmleditformat(form["styleset_body_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Body Heading 2 Scale</th><td><input type="number" name="styleset_body_heading_2_scale" value="#htmleditformat(form["styleset_body_heading_2_scale"])#"></td></tr>
	<tr><th>Body Heading 3 Color</th><td>#colorSelectField("styleset_body_heading_3_color")#</td></tr>
	<tr><th>Body Heading 3 Font</th><td>#fontSelectField("styleset_body_heading_3_font")#</td></tr>
	<tr><th>Body Heading 3 Font Scale</th><td><input type="number" name="styleset_body_heading_3_font_scale" value="#htmleditformat(form["styleset_body_heading_3_font_scale"])#"></td></tr>
	<tr><th>Body Heading 3 Padding Scale</th><td><input type="number" name="styleset_body_heading_3_padding_scale" value="#htmleditformat(form["styleset_body_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Body Heading 3 Scale</th><td><input type="number" name="styleset_body_heading_3_scale" value="#htmleditformat(form["styleset_body_heading_3_scale"])#"></td></tr>
	<tr><th>Body Horizontal Padding Scale</th><td><input type="number" name="styleset_body_x_padding_scale" value="#htmleditformat(form["styleset_body_x_padding_scale"])#"></td></tr>
	<tr><th>Body Link Color</th><td>#colorSelectField("styleset_body_link_color")#</td></tr>
	<tr><th>Body Link Hover Color</th><td>#colorSelectField("styleset_body_link_hover_color")#</td></tr>
	<tr><th>Body Text Color</th><td>#colorSelectField("styleset_body_text_color")#</td></tr>
	<tr><th>Body Text Scale</th><td><input type="number" name="styleset_body_text_scale" value="#htmleditformat(form["styleset_body_text_scale"])#"></td></tr>
	<tr><th>Body Vertical Padding Scale</th><td><input type="number" name="styleset_body_y_padding_scale" value="#htmleditformat(form["styleset_body_y_padding_scale"])#"></td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Aside")#

	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Aside Background Color</th><td>#colorSelectField("styleset_aside_background_color")#</td></tr>
	<tr><th>Aside Heading 1 Color</th><td>#colorSelectField("styleset_aside_heading_1_color")#</td></tr>
	<tr><th>Aside Heading 1 Font</th><td>#fontSelectField("styleset_aside_heading_1_font")#</td></tr>
	<tr><th>Aside Heading 1 Font Scale</th><td><input type="number" name="styleset_aside_heading_1_font_scale" value="#htmleditformat(form["styleset_aside_heading_1_font_scale"])#"></td></tr>
	<tr><th>Aside Heading 1 Padding Scale</th><td><input type="number" name="styleset_aside_heading_1_padding_scale" value="#htmleditformat(form["styleset_aside_heading_1_padding_scale"])#"></td></tr>
	<tr><th>Aside Heading 2 Color</th><td>#colorSelectField("styleset_aside_heading_2_color")#</td></tr>
	<tr><th>Aside Heading 2 Font</th><td>#fontSelectField("styleset_aside_heading_2_font")#</td></tr>
	<tr><th>Aside Heading 2 Font Scale</th><td><input type="number" name="styleset_aside_heading_2_font_scale" value="#htmleditformat(form["styleset_aside_heading_2_font_scale"])#"></td></tr>
	<tr><th>Aside Heading 2 Padding Scale</th><td><input type="number" name="styleset_aside_heading_2_padding_scale" value="#htmleditformat(form["styleset_aside_heading_2_padding_scale"])#"></td></tr>
	<tr><th>Aside Heading 3 Color</th><td>#colorSelectField("styleset_aside_heading_3_color")#</td></tr>
	<tr><th>Aside Heading 3 Font</th><td>#fontSelectField("styleset_aside_heading_3_font")#</td></tr>
	<tr><th>Aside Heading 3 Font Scale</th><td><input type="number" name="styleset_aside_heading_3_font_scale" value="#htmleditformat(form["styleset_aside_heading_3_font_scale"])#"></td></tr>
	<tr><th>Aside Heading 3 Padding Scale</th><td><input type="number" name="styleset_aside_heading_3_padding_scale" value="#htmleditformat(form["styleset_aside_heading_3_padding_scale"])#"></td></tr>
	<tr><th>Aside Horizontal Padding Scale</th><td><input type="number" name="styleset_aside_x_padding_scale" value="#htmleditformat(form["styleset_aside_x_padding_scale"])#"></td></tr>
	<tr><th>Aside Link Color</th><td>#colorSelectField("styleset_aside_link_color")#</td></tr>
	<tr><th>Aside Link Hover Color</th><td>#colorSelectField("styleset_aside_link_hover_color")#</td></tr>
	<tr><th>Aside Menu Link Background Color</th><td>#colorSelectField("styleset_aside_menu_link_background_color")#</td></tr>
	<tr><th>Aside Menu Link Hover Background Color</th><td>#colorSelectField("styleset_aside_menu_link_hover_background_color")#</td></tr>
	<tr><th>Aside Menu Link Hover Text Color</th><td>#colorSelectField("styleset_aside_menu_link_hover_text_color")#</td></tr>
	<tr><th>Aside Menu Link Text Color</th><td>#colorSelectField("styleset_aside_menu_link_text_color")#</td></tr>
	<tr><th>Aside Text Color</th><td>#colorSelectField("styleset_aside_text_color")#</td></tr>
	<tr><th>Aside Text Font</th><td>#fontSelectField("styleset_aside_text_font")#</td></tr>
	<tr><th>Aside Text Font Scale</th><td><input type="number" name="styleset_aside_text_font_scale" value="#htmleditformat(form["styleset_aside_text_font_scale"])#"></td></tr>
	<tr><th>Aside Vertical Padding Scale</th><td><input type="number" name="styleset_aside_y_padding_scale" value="#htmleditformat(form["styleset_aside_y_padding_scale"])#"></td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Form")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Form Field Background Color</th><td>#colorSelectField("styleset_form_field_background_color")#</td></tr>
	<tr><th>Form Field Border Color</th><td>#colorSelectField("styleset_form_field_border_color")#</td></tr>
	<tr><th>Form Field Border Radius</th><td><input type="number" name="styleset_form_field_border_radius" value="#htmleditformat(form["styleset_form_field_border_radius"])#"></td></tr>
	<tr><th>Form Field Border Size</th><td>#borderSelectField("styleset_form_field_border_size")#</td></tr>
	<tr><th>Form Field Padding Scale</th><td><input type="number" name="styleset_form_field_padding_scale" value="#htmleditformat(form["styleset_form_field_padding_scale"])#"></td></tr>
	<tr><th>Form Field Text Color</th><td>#colorSelectField("styleset_form_field_text_color")#</td></tr>
	<tr><th>Form Submit Background Color</th><td>#colorSelectField("styleset_form_submit_background_color")#</td></tr>
	<tr><th>Form Submit Font Scale</th><td><input type="number" name="styleset_form_submit_font_scale" value="#htmleditformat(form["styleset_form_submit_font_scale"])#"></td></tr>
	<tr><th>Form Submit Text Color</th><td>#colorSelectField("styleset_form_submit_text_color")#</td></tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Slideshow")#
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
	<tr><th>Slideshow Circle Active Color</th><td>#colorSelectField("styleset_slideshow_circle_active_color")#</td></tr>
	<tr><th>Slideshow Circle Inactive Color</th><td>#colorSelectField("styleset_slideshow_circle_inactive_color")#</td></tr>
	<tr><th>Slideshow Next Button Image</th><td>
		#application.zcore.functions.zInputImage('styleset_slideshow_next_button_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)# 
	</td></tr>
	<tr><th>Slideshow Next / Previous Button Color</th><td>#colorSelectField("styleset_slideshow_nextprevious_button_color")#</td></tr>
	<tr><th>Slideshow Previous Button Image</th><td>
		#application.zcore.functions.zInputImage('styleset_slideshow_previous_button_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.stylesetPath,1,1), request.zos.globals.siteroot&request.zos.stylesetPath)#

	</td></tr>
	</table>
	#tabCom.endFieldSet()# 
	#tabCom.endTabMenu()#
	</form>
</cffunction> 

<cffunction name="borderSelectField" localmode="modern" access="public">
	<cfargument name="field" type="string" required="yes">
	<cfscript>
	ts = StructNew();
	ts.name = arguments.field;
	ts.friendlyName="";
	ts.labelList = "0|1|2|3|4|5|6|7|8|9|10";
	ts.valueList = "|1|2|3|4|5|6|7|8|9|10";
	ts.delimiter="|"; 
	ts.output=true;
	ts.struct=form;
	application.zcore.functions.zInput_RadioGroup(ts);
	</cfscript>
</cffunction>

<cffunction name="colorSelectField" localmode="modern" access="public">
	<cfargument name="field" type="string" required="yes">
	<cfscript>
	if(form.method EQ "edit" and not structkeyexists(request.zos.stylesetColorFieldStruct, arguments.field)){
		throw("#arguments.field# missing | All color fields must be manually added to request.zos.stylesetColorFieldStruct for the remapping system to work.");
	}
	db=request.zos.queryObject;
	if(not structkeyexists(request, "qColor")){
		db.sql="select * FROM #db.table("styleset_color", "zgraph")# 
		WHERE 
		site_id in (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		styleset_color_deleted=#db.param(0)# 
		ORDER BY styleset_color_name ASC";
		request.qColor=db.execute("qColor", "", 10000, "query", false); 
		request.colorStruct={};
		for(color in request.qColor){
			request.colorStruct[color.styleset_color_id]=color.styleset_color_value;
		}
	}
	
	ts = StructNew();
	ts.name = arguments.field; 
	ts.size = 1; // more for multiple select 
	ts.query = request.qColor;
	ts.queryLabelField = "styleset_color_name";
	ts.onchange="updateColorPreview(this);";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "styleset_color_id"; 
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>
	<div id="#arguments.field#_preview" style="width:25px; height:25px; vertical-align:middle; display:inline-block;  padding-left:10px; <cfif form[arguments.field] NEQ "" and form[arguments.field] NEQ "0">background-color:#request.colorStruct[form[arguments.field]]#;</cfif>"></div>
	<cfif not structkeyexists(request, "colorJavascriptOutput")>
		<cfset request.colorJavascriptOutput=true>
		<script>
		var colorLookup=#serializeJson(request.colorStruct)#;
		function updateColorPreview(obj){
			var color=obj.options[obj.selectedIndex].value;
			if(typeof colorLookup[color] != "undefined"){
				$("##"+obj.id+"_preview").css("background-color", colorLookup[color]);
			}
		}
		</script>
	</cfif>
</cffunction>

<cffunction name="fontSelectField" localmode="modern" access="public">
	<cfargument name="field" type="string" required="yes">
	<cfscript>
	if(form.method EQ "edit" and not structkeyexists(request.zos.stylesetFontFieldStruct, arguments.field)){
		throw("#arguments.field# missing | All font fields must be manually added to request.zos.stylesetFontFieldStruct for the remapping system to work.");
	}
	db=request.zos.queryObject;
	if(not structkeyexists(request.zos, "qWebFont")){
		db.sql="select * FROM #db.table("webfont", request.zos.zcoreDatasource)# 
		WHERE 
		webfont_deleted=#db.param(0)# 
		ORDER BY webfont_name ASC";
		request.zos.qwebfont=db.execute("qwebfont", "", 10000, "query", false); 
	}
	
	ts = StructNew();
	ts.name = arguments.field; 
	ts.size = 1; // more for multiple select 
	ts.query = request.zos.qwebfont;
	ts.queryLabelField = "webfont_name";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "webfont_id"; 
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>
</cffunction>


<cffunction name="view" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	form.styleset_id=application.zcore.functions.zso(form, "styleset_id"); 
	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE styleset_deleted=#db.param(0)# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_id=#db.param(form.styleset_id)# 
	ORDER BY styleset_name ASC ";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid styleset id", form, true);
		application.zcore.functions.zRedirect("/z/admin/styleset/index?zsid=#request.zsid#");	
	}
	application.zcore.functions.zQueryToStruct(qSet); 
	</cfscript>
	<h2>Previewing: #form.styleset_name#</h2>
</cffunction>


<cffunction name="copy" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	form.copyPreset=application.zcore.functions.zso(form, "copyPreset", true); 
	form.styleset_id=application.zcore.functions.zso(form, "styleset_id"); 
	db.sql="SELECT * FROM #db.table("styleset", "zgraph")# 
	WHERE styleset_deleted=#db.param(0)# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	styleset_id=#db.param(form.styleset_id)# 
	ORDER BY styleset_name ASC ";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid styleset id", form, true);
		application.zcore.functions.zRedirect("/z/admin/styleset/index?zsid=#request.zsid#");	
	}
	application.zcore.functions.zQueryToStruct(qSet); 

	if(structkeyexists(form, "confirm")){
		if(form.newname EQ ""){
			application.zcore.status.setStatus(request.zsid, "New Name is required", form, true);
			application.zcore.functions.zRedirect("/z/admin/styleset/copy?zsid=#request.zsid#");
		}
		form.newsiteid=application.zcore.functions.zso(form, "newsiteid", true);
		if(form.newsiteid EQ 0){
			form.newsiteid=request.zos.globals.id;
		}
		// copy any files
	    if(qSet.site_id EQ 0){
	    	uploadPath=request.zos.globals.serverprivatehomedir&request.zos.stylesetUploadPath;
			form.site_id=0;
		}else{
	    	uploadPath=request.zos.globals.privatehomedir&request.zos.stylesetUploadPath;
	    	if(form.newsiteid NEQ request.zos.globals.id){
	    		form.styleset_group_id=0;
	    		// TODO: interface to reassign the colors
	    		// TODO: interface to reassign the fonts
	    	}
			form.site_id=form.newsiteid;
	    }
		if(form.copyPreset EQ 1){
			form.site_id=form.newsiteid;
			form.styleset_group_id=0;
		}
	    application.zcore.functions.zCreateDirectory(uploadPath);
	    currentUploadPath=application.zcore.functions.zvar("privatehomedir", form.newsiteid)&request.zos.stylesetUploadPath;

	    arrFile=[
		    "styleset_bullet_image",
		    "styleset_row_background_image",
		    "styleset_row_background_mobile_image",
		    "styleset_contain_bullet_image",
		    "styleset_nocontain_bullet_image",
		    "styleset_nocontain_panel_bullet_image",
		    "styleset_slideshow_next_button_image",
		    "styleset_slideshow_previous_button_image"
	    ];
	    for(fieldName in arrFile){
		    filePath=uploadPath&qSet[fieldName];
			path=application.zcore.functions.zCopyFile(filePath, currentUploadPath, false);
			form[fieldName]=getfilefrompath(path);
		}
		form.styleset_name=form.newname;
		form.styleset_deleted=0;
		form.styleset_updated_datetime=request.zos.mysqlnow; 
		inputStruct = StructNew();
		inputStruct.table = "styleset";
		inputStruct.struct=form;
		inputStruct.datasource="zgraph";
		form.styleset_id = application.zcore.functions.zInsert(inputStruct);

		application.zcore.status.setStatus(request.zsid, "Styleset Copied");
		application.zcore.functions.zRedirect("/z/admin/styleset/index?zsid=#request.zsid#");
	}else{
		echo('
		<form action="/z/admin/styleset/copy" method="get">
		<h2>Copy Styleset: #form.styleset_name#</h2>
		<p>Site: (optional)</p>
		<p>');
		application.zcore.functions.zGetSiteSelect('newsiteid');
		echo('</p>
		<p>New Name: *</p>
			<input type="hidden" name="copyPreset" value="#form.copyPreset#">
			<input type="hidden" name="styleset_id" value="#form.styleset_id#">
			<input type="hidden" name="confirm" value="1">
		<p><input type="text" name="newname" value="" required="required"></p>
		<p><input type="submit" name="submit1" value="Copy"> 
			<input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/admin/styleset/index'';"></p>
		</form>
		');
	}
	</cfscript>
</cffunction>


<cffunction name="copyPreset" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	form.styleset_group_id=application.zcore.functions.zso(form, "styleset_group_id", true);
	db.sql="SELECT * FROM 
	#db.table("styleset", "zgraph")# 
	LEFT JOIN 
	#db.table("styleset_group", "zgraph")# ON 
	styleset.site_id = styleset_group.site_id and 
	styleset.styleset_group_id = styleset_group.styleset_group_id and 
	styleset_group_deleted=#db.param(0)# 
	WHERE styleset_deleted=#db.param(0)# and ";
	if(form.styleset_group_id NEQ 0){
		db.sql&=" styleset.styleset_group_id =#db.param(form.styleset_group_id)# and ";
	}
	db.sql&="
	styleset.site_id =  #db.param(0)# 
	ORDER BY styleset_name ASC ";
	qSet=db.execute("qSet");
	</cfscript>
    
    <p><a href="/z/admin/styleset-group/index">Groups</a> | <a href="/z/admin/styleset-color/index">Colors</a> | <a href="/z/admin/styleset/index">Stylesets</a></p>
    <div class="z-float">
		<h2 style="display:inline-block; padding-right:10px;">Copy Styleset From Preset</h2>
	</div> 
 	<p>Filter by Preset Group: 
 	<cfscript>

	db.sql="select * FROM #db.table("styleset_group", "zgraph")# 
	WHERE 
	site_id =#db.param(request.zos.globals.id)# and 
	styleset_group_deleted=#db.param(0)# 
	ORDER BY styleset_group_name ASC";
	qGroup=db.execute("qGroup", "", 10000, "query", false);  

	ts = StructNew();
	ts.name = "styleset_group_id"; 
	ts.size = 1; // more for multiple select 
	ts.query = qGroup;
	ts.queryLabelField = "styleset_group_name";
	ts.onchange="window.location.href='/z/admin/styleset/copyPreset?styleset_group_id='+this.options[this.selectedIndex].value;";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "styleset_group_id"; 
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript></p>
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<th>Name</th> 
			<th>Group</th> 
			<th>Admin</th>
		</tr>
		<cfloop query="qSet"> 
			<tr>
				<td>#qSet.styleset_name#</td> 
				<td>#qSet.styleset_group_name#</td> 
				<td>
					<a href="/z/admin/styleset/copy?styleset_id=#qSet.styleset_id#&copyPreset=1" class="z-manager-search-button">Copy</a> 
				</td>
			</tr> 
		</cfloop>
    </table> 
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	form.styleset_group_id=application.zcore.functions.zso(form, "styleset_group_id", true);
	db.sql="SELECT * FROM 
	#db.table("styleset", "zgraph")# 
	LEFT JOIN 
	#db.table("styleset_group", "zgraph")# ON 
	styleset.site_id = styleset_group.site_id and 
	styleset.styleset_group_id = styleset_group.styleset_group_id and 
	styleset_group_deleted=#db.param(0)# 
	WHERE styleset_deleted=#db.param(0)# and ";
	if(form.styleset_group_id NEQ 0){
		db.sql&=" styleset.styleset_group_id =#db.param(form.styleset_group_id)# and ";
	}
	db.sql&="
	styleset.site_id =  #db.param(request.zos.globals.id)# 
	ORDER BY styleset_name ASC ";
	qSet=db.execute("qSet"); 
	if(qSet.recordcount EQ 0 and currentMethod EQ "edit"){
		application.zcore.functions.zRedirect("/z/admin/styleset/index");	
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
    
    <p><a href="/z/admin/styleset-group/index">Groups</a> | <a href="/z/admin/styleset-color/index">Colors</a> | <a href="/z/admin/styleset/index">Stylesets</a></p>
    <div class="z-float">
		<h2 style="display:inline-block; padding-right:10px;">Stylesets</h2>
		<a href="/z/admin/styleset/add" class="z-manager-search-button">Add</a>
		<a href="/z/admin/styleset/copyPreset" class="z-manager-search-button">Copy Preset</a>
	</div> 
 	
 	<p>Filter by Preset Group: 
 	<cfscript>

	db.sql="select * FROM #db.table("styleset_group", "zgraph")# 
	WHERE 
	site_id =#db.param(request.zos.globals.id)# and 
	styleset_group_deleted=#db.param(0)# 
	ORDER BY styleset_group_name ASC";
	qGroup=db.execute("qGroup", "", 10000, "query", false);  

	ts = StructNew();
	ts.name = "styleset_group_id"; 
	ts.size = 1; // more for multiple select 
	ts.query = qGroup;
	ts.queryLabelField = "styleset_group_name";
	ts.onchange="window.location.href='/z/admin/styleset/copyPreset?styleset_group_id='+this.options[this.selectedIndex].value;";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "styleset_group_id"; 
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript></p>
	<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr>
			<th>Name</th> 
			<th>Group</th> 
			<th>Admin</th>
		</tr>
		<cfloop query="qSet"> 
			<tr>
				<td>#qSet.styleset_name#</td> 
				<td>#qSet.styleset_group_name#</td>  
				<td>
					<a href="/z/admin/styleset/view?styleset_id=#qSet.styleset_id#" target="_blank" class="z-manager-search-button">View</a> 
					<a href="/z/admin/styleset/copy?styleset_id=#qSet.styleset_id#" class="z-manager-search-button">Copy</a> 
					<a href="/z/admin/styleset/edit?styleset_id=#qSet.styleset_id#" class="z-manager-search-button">Edit</a> 
					<a href="/z/admin/styleset/delete?styleset_id=#qSet.styleset_id#" class="z-manager-search-button">Delete</a></td>
			</tr> 
		</cfloop>
    </table> 
</cffunction>
</cfoutput>
</cfcomponent>