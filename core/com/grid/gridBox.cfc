<cfcomponent>
<cfoutput>
<cffunction name="displayBoxForm" localmode="modern" access="public">

<div id="gridBoxFormContainer" style="display:none;">
<form class="zFormCheckDirty" id="gridBoxForm" action="" method="get">
	<cfscript> 
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Box Settings"]); 
	tabCom.setMenuName("grid-box-edit");
	tabCom.setCancelURL("");
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Box Settings")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="width:120px;">Image</th>
			<td><input type="text" name="grid_box_image" id="grid_box_image" value="" /></td>
		</tr>
		<tr>
			<th>Heading</th>
			<td><input type="text" name="grid_box_heading" id="grid_box_heading" value="" /></td>
		</tr>
		<tr>
			<th>Heading 2</th>
			<td><input type="text" name="grid_box_heading2" id="grid_box_heading2" value="" /></td>
		</tr>
		<tr>
			<th>Summary</th>
			<td>
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "grid_box_summary";
				htmlEditor.value= "";
				htmlEditor.width= "100%";
				htmlEditor.height= 250;
				htmlEditor.create();
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Button Text</th>
			<td><input type="text" name="grid_box_button_text" id="grid_box_button_text" value="" /></td>
		</tr>
		<tr>
			<th>Button Url</th>
			<td><input type="text" name="grid_box_button_url" id="grid_box_button_url" value="" /></td>
		</tr>
		<tr>
			<th>Column Size</th>
			<td>
				<select size="1" name="grid_box_column_size" id="grid_box_column_size"> 
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
			<th>Visible</th>
			<td>#application.zcore.functions.zInput_Boolean("grid_box_visible")#</td>
		</tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	<input type="hidden" name="grid_id" id="grid_id" value="" />
	<input type="hidden" name="grid_group_id" id="grid_group_id" value="" />
	<input type="hidden" name="grid_box_id" id="grid_box_id" value="" />
	<input type="hidden" name="grid_box_sort" id="grid_box_sort" value="" />
	<!--- <input type="text" name="grid_box_image_intermediate" id="grid_box_image_intermediate" value="" /> --->
</form>
</div>
<cfsavecontent variable="out">
</cfsavecontent>
<script>
//var gridBoxFormTemplate="#jsstringformat(out)#";
var gridBoxTabIndex=#tabCom.getIndex()#;
</script>
</cffunction>
</cfoutput>
</cfcomponent>