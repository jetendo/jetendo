<cfcomponent> 
<cfoutput>
<cffunction name="displayGroupForm" localmode="modern" access="public">
	<cfscript> 
	/*var groupSettings={
		"grid_group_box_border_radius": 0, 
		"grid_group_visible": "1",
		"grid_group_heading": "Heading",
		"grid_group_background_type": 0,
		"grid_group_children_center": "0",
		"grid_group_box_border": "",
		"grid_group_background_value": "",
		"grid_group_padding": "",
		"grid_group_box_background_value": "",
		"grid_id": 57,
		"grid_group_box_background_type": 0,
		"grid_group_text": "",
		"grid_group_column_count": 0,
		"grid_group_heading2": "Heading2",
		"grid_group_sort": 1,
		"grid_group_box_layout": 0,
		"grid_group_id": 1,
		"grid_group_section_center": "0"
	}; */
	</cfscript>
	<!--- <script>
	var groupSettings=#serializeJSON(groupSettings)#;

	</script> 
<section class="z-grid-group-section">
	<div class="z-container">
		<div class="z-column">
			<div class="z-grid-group-heading">Heading 1</div>
			<div class="z-grid-group-heading2">Heading 2</div>
			<div class="z-grid-group-text">Text</div>
		</div>
		<section class="z-grid-box-container">
			<div id="gridGroupDiv" class="z-1of1">
				<div class="z-grid-image"><a href="##"><img src="/z/a/images/s.gif" alt="Text" /></a></div>
				<div class="z-grid-heading"><a href="##">Heading 1</a></div>
				<div class="z-grid-summary">Text</div>
				<div class="z-grid-button"><a href="##" class="z-grid-button-link z-button">Button</a></div>
			</div>
		</section>
	</div>
</section> --->
<div id="gridGroupFormContainer" style="display:none;">
<form class="zFormCheckDirty" id="gridGroupForm"  action="" method="get">
	<cfscript> 
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Group Settings","Group Layout", "Box Layout"]);
	tabCom.setMenuName("grid-group-edit");
	tabCom.setCancelURL("");
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Group Settings")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="width:100px;">Heading</th>
			<td><input type="text" name="grid_group_heading" id="grid_group_heading" value="" /></td>
		</tr>
		<tr>
			<th>Heading 2</th>
			<td><input type="text" name="grid_group_heading2" id="grid_group_heading2" value="" /></td>
		</tr>
		<tr>
			<th>Text</th>
			<td>
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "grid_group_text";
				htmlEditor.value= "";
				htmlEditor.width= "100%";
				htmlEditor.height= 200;
				htmlEditor.create();
				</cfscript>    
			</td>
		</tr>
		<tr>
			<th>Visible</th>
			<td>#application.zcore.functions.zInput_Boolean("grid_group_visible")#</td>
		</tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Group Layout")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="width:120px;">Column Count</th>
			<td>
				<select size="1" name="grid_group_column_count" id="grid_group_column_count"> 
					<option value="1">1</option>
					<option value="2">2</option>
					<option value="3">3</option>
					<option value="4">4</option>
					<option value="5">5</option>
					<option value="6">6</option>
					<option value="7">7</option>
				</select>
			</td> 
		</tr>
		<tr>
			<th>Section Center</th>
			<td>#application.zcore.functions.zInput_Boolean("grid_group_section_center")#</td>
		</tr>
		<!--- <tr>
			<th>Background Type</th>
			<td>
				<select size="1" name="grid_group_background_type" id="grid_group_background_type"> 
					<option value="1">White Overlay</option>
					<option value="2">Black Overlay</option>
					<option value="3">White 80% Overlay</option>
					<option value="4">Black 80% Overlay</option>
					<option value="5">Image and Color Picker</option>
					<option value="6">Color Picker</option> 
				</select>
			</td>
		</tr> --->
		<tr>
			<th>Background</th>
			<td>
				<p><a href="##">Open Background Editor</a></p>
				<input type="hidden" name="grid_group_background_type" id="grid_group_background_type" value="" />
				<input type="hidden" name="grid_group_background_value" id="grid_group_background_value" value="" />
			</td>
		</tr>
		<tr>
			<th>Children Center</th>
			<td>#application.zcore.functions.zInput_Boolean("grid_group_children_center")#</td>
		</tr>
		<tr>
			<th>Padding</th>
			<td>
				<select size="1" name="grid_group_padding" id="grid_group_padding"> 
					<cfloop from="0" to="150" index="i" step="10">
						<option value="#i#">#i#</option>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Box Layout")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="width:120px;">Border</th>
			<td>
				<select size="1" name="grid_group_box_border" id="grid_group_box_border"> 
					<option value="z-border-white-1">1 pixel white</option>
					<option value="z-border-black-1">1 pixel black</option>
					<option value="z-border-white-2">2 pixel white</option>
					<option value="z-border-black-2">2 pixel black</option>
				</select>
			</td>
		</tr>
		<tr>
			<th>Border Radius</th>
			<td>
				<select size="1" name="grid_group_box_border_radius" id="grid_group_box_border_radius"> 
					<option value="0">0</option>
					<option value="5">5</option>
					<option value="10">10</option>
					<option value="15">15</option>
				</select>
			</td>
		</tr> 
		<!--- <tr>
			<th>Background Type</th>
			<td>
				<select size="1" name="grid_group_box_background_type" id="grid_group_box_background_type"> 
					<option value="1">White Overlay</option>
					<option value="2">Black Overlay</option>
					<option value="3">White 80% Overlay</option>
					<option value="4">Black 80% Overlay</option>
					<option value="5">Image and Color Picker</option>
					<option value="6">Color Picker</option> 
				</select>
			</td>
		</tr> --->
		<tr>
			<th>Background</th>
			<td>
				<p><a href="##">Open Background Editor</a></p>
				<input type="hidden" name="grid_group_box_background_type" id="grid_group_box_background_type" value="" />
				<input type="hidden" name="grid_group_box_background_value" id="grid_group_box_background_value" value="" />
			</td>
		</tr>
		<tr>
			<th>Layout</th>
			<td>
				<select size="1" name="grid_group_box_layout" id="grid_group_box_layout"> 
					<option value="1">Vertical - Image / Heading / Heading 2 / Summary / Button</option>
					<!--- <option value="2">Vertical - Heading / Image / Heading 2 / Summary / Button</option> --->
					<option value="3">Vertical - Heading / Heading 2 / Image / Summary / Button</option> 
					<option value="4">Left: Image | Right: Heading / Heading 2 / Summary / Button</option>
					<option value="5">Left: Heading / Heading 2 / Summary / Button | Right: Image</option>
					<option value="6">Image with White Heading on Black Overlay</option>
					<option value="7">Image with Black Heading on White Overlay</option>
				</select>
			</td>
		</tr> 
	</table>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	<input type="hidden" name="grid_id" id="grid_id" value="" />
	<input type="hidden" name="grid_group_id" id="grid_group_id" value="" />
	<input type="hidden" name="grid_group_sort" id="grid_group_sort" value="" />
</form>
</div>
<cfsavecontent variable="out">
</cfsavecontent>  
<script>
//var gridGroupFormTemplate="#jsstringformat(out)#";
var gridGroupTabIndex=#tabCom.getIndex()#;
</script>
</cffunction>
</cfoutput>
</cfcomponent>