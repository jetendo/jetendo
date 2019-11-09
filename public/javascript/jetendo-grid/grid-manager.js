
var zGridEditor={
	uniqueOffset:0,
	currentGroupId:0,
	currentBoxId:0
};
var gridData={};

(function($, window, document, undefined){
	"use strict";
	var boxSettings={
		"grid_box_image_intermediate": "",
		"grid_box_sort": 0,
		"grid_box_column_size": 1,
		"grid_id": 57,
		"grid_box_button_text": "Read More",
		"grid_box_heading": "Heading",
		"grid_box_heading2": "Heading 2",
		"grid_box_visible": 1,
		"grid_box_summary": "<p>Summary</p>",
		"grid_box_image": "", 
		"grid_box_button_url": "#",
		"grid_box_id": 0,
		"grid_group_id": 0
	};
	var groupSettings={
		"grid_group_box_border_radius": 0, 
		"grid_group_visible": 1,
		"grid_group_heading": "Heading",
		"grid_group_background_type": 0,
		"grid_group_children_center": 0,
		"grid_group_box_border": "",
		"grid_group_background_value": "",
		"grid_group_padding": "",
		"grid_group_box_background_value": "",
		"grid_id": 57,
		"grid_group_box_background_type": 0,
		"grid_group_text": "<p>Summary</p>",
		"grid_group_column_count": 5,
		"grid_group_heading2": "Heading 2",
		"grid_group_sort":0,
		"grid_group_box_layout": 0,
		"grid_group_id": 0,
		"grid_group_section_center": 0
	}; 
	
	var boxLayout={
		"1":"Vertical - Image / Heading / Heading 2 / Summary / Button",
		"2":"Vertical - Heading / Image / Heading 2 / Summary / Button",
		"3":"Vertical - Heading / Heading 2 / Image / Summary / Button",
		"4":"Left: Image | Right: Heading / Heading 2 / Summary / Button",
		"5":"Left: Heading / Heading 2 / Summary / Button | Right: Image",
		"6":"Image with White Heading on Black Overlay",
		"7":"Image with Black Heading on White Overlay"
	}

function setCurrentGroup(obj){
	zGridEditor.currentGroupId=parseInt($(obj).attr("data-id"));
}
function setCurrentBox(obj){
	zGridEditor.currentBoxId=parseInt($(obj).attr("data-id"));
	zGridEditor.currentGroupId=parseInt($(obj).attr("data-group-id"));
}

var uniqueOffset=0;
function getUniqueId(){
	uniqueOffset++;
	return uniqueOffset;
}

function setFormData(formId, formData){
	console.log('setFormData'+Math.random());
	for(var field in formData){
		var value=formData[field];
		//console.log(field+":"+value);
		if($("#"+field).hasClass("zBooleanRadio")){
			if(parseInt(value) == 1){
				$("#"+field+"1").prop("checked", true);
			}else{
				$("#"+field+"0").prop("checked", true);
			}
		}else{
			$("#"+field).val(value);
		}
	}
}


function saveGridGroup(){
	// gridData
	var groupData=zGetFormDataByFormId("gridGroupForm");  

	groupData.grid_id=parseInt(groupData.grid_id);
	groupData.grid_group_id=parseInt(groupData.grid_group_id);

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == zGridEditor.currentGroupId){
			for(var field in groupData){
				group.settings[field]=groupData[field];
			}
			break;
		}
	}
}

function saveGridBox(){
	// gridData 
	var boxData=zGetFormDataByFormId("gridBoxForm"); 

	boxData.grid_box_image_intermediate=""; // temporary fix to remove image until server side save occurs.
	
	boxData.grid_id=parseInt(boxData.grid_id);
	boxData.grid_group_id=parseInt(boxData.grid_group_id);
	boxData.grid_box_id=parseInt(boxData.grid_box_id);
	console.log("Save Box");
	console.log(boxData);

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == zGridEditor.currentGroupId){
			for(var n=0;n<group.boxes.length;n++){
				var box=group.boxes[n];
				if(box.clientSettings.id == zGridEditor.currentBoxId){
					box.data=boxData;
					break;
				}
			}
			break;
		}
	}
}

function renderGrid(){

	var a=[];
	console.log('renderGrid');
	console.log(gridData);
	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i]; 
		a.push(renderGroupStart(group));
		for(var n=0;n<group.boxes.length;n++){
			var box=group.boxes[n];
			var b=renderBox(group, box);
			console.log("box:"+n+":"+box.data.grid_box_heading);
			a.push(b);
		}
		a.push(renderGroupEnd(group));
	}


	$("#z-grid-groups").show().html(a.join("\n"));
}
/*
var boxSettings={
	"grid_box_image_intermediate": "",
	"grid_box_sort": 0,
	"grid_box_column_size": 2,
	"grid_id": 57,
	"grid_box_button_text": "",
	"grid_box_heading": "Heading",
	"grid_box_heading2": "Heading 2",
	"grid_box_visible": "1",
	"grid_box_summary": "",
	"grid_box_image": "0", 
	"grid_box_button_url": "",
	"grid_box_id": 1,
	"grid_group_id": 1
};
var	groupSettings={
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
	"grid_group_column_count": 5,
	"grid_group_heading2": "Heading2",
	"grid_group_sort": 1,
	"grid_group_box_layout": 0,
	"grid_group_id": 1,
	"grid_group_section_center": "0"
}; */
var tab="\n";
function renderGroupStart(group, isAdmin){
	var bg=getBackgroundCode(group.settings.grid_group_id, group.settings.grid_group_background_type, group.settings.grid_group_background_value);
	var arrHTML=[];
	if(bg.css!=""){
		arrHTML.push('<style>'+bg.css+'</style>');
	}


	arrHTML.push('<section id="z-grid-group-'+group.settings.grid_group_id+'" data-group-id="'+group.settings.grid_group_id+'" class="z-grid-group '+bg.class+' z-center-children" style="background-color: ##F5F5F5;">');
	if(parseInt(group.settings.grid_group_section_center)==1){
		arrHTML.push(tab+'<div class="z-grid-header z-column z-text-center">');
	}else{
		arrHTML.push(tab+'<div class="z-grid-header z-column">');
	}
	if(group.settings.grid_group_heading!=''){
		arrHTML.push(tab+tab+'<div class="z-grid-group-heading">'+group.settings.grid_group_heading+'</div>');
	}
	if(group.settings.grid_group_heading2!=''){
		arrHTML.push(tab+tab+'<div class="z-grid-group-heading2">'+group.settings.grid_group_heading2+'</div>');
	}
	if(group.settings.grid_group_text!=''){
		arrHTML.push(tab+tab+'<div class="z-grid-group-text">'+group.settings.grid_group_text+'</div>');
	}
	arrHTML.push(tab+'</div>');
		
	arrHTML.push(tab+'<div class=" z-grid-boxes" style="width:'+gridWidth+'px;">');
	//arrHTML.push(tab+tab+'<section>');
	if(parseInt(group.settings.grid_group_children_center)==1){
		arrHTML.push(tab+tab+'<section class="z-grid-box-container z-center-children">');
	}else{
		arrHTML.push(tab+tab+'<section class="z-grid-box-container">');
	}
	arrHTML.push(tab+tab+tab+'<div class=" z-grid-boxes-sortable">');
	/*
	arrHTML.push('<section id="gridGroupSection'+group.settings.grid_group_id+'" data-id="'+group.clientSettings.id+'" class="z-grid-group '+bg.class+'">');
	arrHTML.push(tab+'<div class="z-container">');
	*/
	return arrHTML.join("\n");
}
function renderGroupEnd(group, isAdmin){
	var arrHTML=[];
	arrHTML.push(tab+tab+tab+'</div>');
	arrHTML.push(tab+tab+'</section>');
	arrHTML.push(tab+tab+'</div>');
	arrHTML.push(tab+'<div class="z-grid-group-buttons-right z-1of7 z-mv-0 z-t-12">');
	arrHTML.push(tab+tab+'<a href="##" class="z-grid-group-settings z-button">Settings</a>');
	arrHTML.push(tab+tab+'<a href="##" class="z-grid-delete-group z-button">Delete Group</a>');
	arrHTML.push(tab+tab+'<a href="##" class="z-grid-add-box z-button">Add Box</a>');
	arrHTML.push(tab+tab+'<a href="##" class="z-t-14 z-grid-group-move-handle icon-left"><i class="fa fa-bars"></i>Move</a>');
	arrHTML.push(tab+'</div>');
	arrHTML.push('</section> '); 
	return arrHTML.join("\n");
}
function renderBox(group, box, isAdmin){ 
	var bg=getBackgroundCode(group.settings.grid_group_id, group.settings.grid_group_box_background_type, group.settings.grid_group_box_background_value);
	var arrHTML=[tab+tab+tab];
	if(bg.css!=""){
		arrHTML.push('<style>'+bg.css+'</style>');
	}

	var arrHTML=[]; 
	arrHTML.push('<div id="gridBoxDiv'+box.clientSettings.id+'" data-group-id="'+group.settings.grid_group_id+'" data-id="'+box.clientSettings.id+'" class="z-grid-box z-'+box.data.grid_box_column_size+'of'+group.settings.grid_group_column_count+'">');

	if(group.settings.grid_group_box_layout==1){
		renderBoxLayout1(arrHTML, group, box);
	/*}else if(group.settings.grid_group_box_layout==2){
		renderBoxLayout2(arrHTML, group, box);*/
	}else if(group.settings.grid_group_box_layout==3){
		renderBoxLayout3(arrHTML, group, box);
	}else if(group.settings.grid_group_box_layout==4){
		renderBoxLayout4(arrHTML, group, box);
	}else if(group.settings.grid_group_box_layout==5){
		renderBoxLayout5(arrHTML, group, box);
	}else if(group.settings.grid_group_box_layout==6){
		renderBoxLayout6(arrHTML, group, box);
	}else if(group.settings.grid_group_box_layout==7){
		renderBoxLayout7(arrHTML, group, box);
	}
	arrHTML.push('</div>');
	return arrHTML.join("\n"+tab+tab+tab);
}

function renderBoxLayout1(arrHTML, group, box){
	// Vertical - Image / Heading / Heading 2 / Summary / Button   
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading">');
		if(box.data.grid_box_button_url!=""){
			arrHTML.push('<a href="'+box.data.grid_box_button_url+'">'+box.data.grid_box_heading+'</a>');
		}else{
			arrHTML.push(box.data.grid_box_heading);
		}
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_heading2!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading2">'); 
		arrHTML.push(box.data.grid_box_heading2); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_summary!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-summary">'+box.data.grid_box_summary+'</div>');
	}
	if(box.data.grid_box_button_url!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-button">');
		arrHTML.push('<a href="'+box.data.grid_box_button_url+'" class="z-grid-button-link z-button">'+box.data.grid_box_button_text+'</a>');
		arrHTML.push('</div>');
	}
	return arrHTML;
}
/*
function renderBoxLayout2(arrHTML, group, box){
	// Vertical - Heading / Image / Heading 2 / Summary / Button
	return arrHTML;
}*/

function renderBoxLayout3(arrHTML, group, box){
	// Vertical - Heading / Heading 2 / Image / Summary / Button
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading">');
		if(box.data.grid_box_button_url!=""){
			arrHTML.push('<a href="'+box.data.grid_box_button_url+'">'+box.data.grid_box_heading+'</a>');
		}else{
			arrHTML.push(box.data.grid_box_heading);
		}
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_heading2!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading2">'); 
		arrHTML.push(box.data.grid_box_heading2); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_summary!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-summary">'+box.data.grid_box_summary+'</div>');
	}
	if(box.data.grid_box_button_url!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-button">');
		arrHTML.push('<a href="'+box.data.grid_box_button_url+'" class="z-grid-button-link z-button">'+box.data.grid_box_button_text+'</a>');
		arrHTML.push('</div>');
	}
	return arrHTML;
}

function renderBoxLayout4(arrHTML, group, box){
	// Left: Image | Right: Heading / Heading 2 / Summary / Button
	//arrHTML.push('<div id="z-grid-box-{{grid_column_id}}" class="z-{{column_width}} z-grid-box" style="background-color: ##CCCCCC;">');
	arrHTML.push('<div class="z-1of3">');
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push(tab+'</div>');
	} 
	arrHTML.push('</div>');
	arrHTML.push('<div class="z-2of3">');
				
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-heading z-h-40 z-pb-0">'); 
		arrHTML.push(box.data.grid_box_heading); 
		arrHTML.push('</div>');
	}

	if(box.data.grid_box_heading2!=""){
		arrHTML.push('<div class="z-grid-heading2 z-h-30 z-normal">'); 
		arrHTML.push(box.data.grid_box_heading2); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_summary!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-summary z-t-18">'+box.data.grid_box_summary+'</div>');
	}
	if(box.data.grid_box_button_url!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-button">');
		arrHTML.push('<a href="'+box.data.grid_box_button_url+'" class="z-grid-button-link z-button z-t-20 z-mt-10">'+box.data.grid_box_button_text+'</a>');
		arrHTML.push('</div>');
	}
	arrHTML.push('</div>');
	return arrHTML;
}

function renderBoxLayout5(arrHTML, group, box){
	// Left: Heading / Heading 2 / Summary / Button | Right: Image 
	arrHTML.push('<div class="z-2of3">');
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+'<div class="z-grid-heading z-h-40 z-pb-0">'); 
		arrHTML.push(box.data.grid_box_heading); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_heading2!=""){
		arrHTML.push(tab+'<div class="z-grid-heading2 z-h-30 z-normal">'); 
		arrHTML.push(box.data.grid_box_heading2); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_summary!=""){
		arrHTML.push(tab+'<div class="z-grid-summary z-t-18">'); 
		arrHTML.push(box.data.grid_box_summary); 
		arrHTML.push('</div>');
	}
	if(box.data.grid_box_button_url!=""){
		arrHTML.push(tab+tab+'<div class="z-grid-button">');
		arrHTML.push('<a href="'+box.data.grid_box_button_url+'" class="z-grid-button-link z-button z-t-20 z-mt-10">'+box.data.grid_box_button_text+'</a>');
		arrHTML.push('</div>');
	}
	arrHTML.push('</div>');
	arrHTML.push('<div class="z-1of3">'); 
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push(tab+'</div>');
	} 
	arrHTML.push('</div>');
	return arrHTML;
}

function renderBoxLayout6(arrHTML, group, box){
	// Image with White Heading on Black Overlay
	arrHTML.push('<div class="z-index-1">');
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push(tab+'</div>');
	}  
	arrHTML.push('</div>');
	arrHTML.push('<div class="z-overlay-bottom z-bg-black-transparent z-index-2 z-p-10">');
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+'<div class="z-grid-heading z-h-20 z-pb-0">'); 
		arrHTML.push(box.data.grid_box_heading); 
		arrHTML.push('</div>');
	}
	arrHTML.push('</div>'); 
	return arrHTML;
}

function renderBoxLayout7(arrHTML, group, box){
	// Image with Black Heading on White Overlay
	arrHTML.push('<div class="z-index-1">');
	if(box.data.grid_box_image_intermediate!=""){
		arrHTML.push(tab+'<div class="z-grid-image">');
		if(box.data.grid_box_button_url!=""){ 
			arrHTML.push('<a href="'+box.data.grid_box_image+'"><img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" /></a>');
		}else{ 
			arrHTML.push('<img src="'+box.data.grid_box_image_intermediate+'" alt="'+zStringReplaceAll(box.data.grid_box_heading, '&', '&amp;')+'" class="z-grid-image z-fluid" />');
		}
		arrHTML.push(tab+'</div>');
	}  
	arrHTML.push('</div>');
	arrHTML.push('<div class="z-overlay-bottom z-bg-white-transparent z-index-2 z-p-10">');
	if(box.data.grid_box_heading!=""){
		arrHTML.push(tab+'<div class="z-grid-heading z-h-20 z-pb-0">'); 
		arrHTML.push(box.data.grid_box_heading); 
		arrHTML.push('</div>');
	}
	arrHTML.push('</div>'); 
	return arrHTML;
}

function getBackgroundCode(id, backgroundType, backgroundValue){ 
	var arrClass=[];
	var arrCSS=[];
	if(backgroundType==1){ // White Overlay
		arrClass.push("z-bg-white");
	}else if(backgroundType==2){ // Black Overlay
		arrClass.push("z-bg-black");
	}else if(backgroundType==3){ // White 80% Overlay
		arrClass.push("z-bg-white-transparent");
	}else if(backgroundType==4){ // Black 80% Overlay
		arrClass.push("z-bg-black-transparent");
	}else if(backgroundType==5){ // Image and Color Picker 
		var v=zStringReplaceAll(backgroundValue, ".backgroundClass{", "gridBackgroundInstance"+id+"{"); 
		arrCSS.push(v);
	}else if(backgroundType==6){ // Color Picker
		arrCSS.push(".backgroundClass"+id+"{ background-color:#"+backgroundValue+"; }"); 
	}
	var rs={
		class:arrClass.join(" "),
		css:arrCSS.join(" ")
	};
	return rs;
}

// This function reads the DOM to find the current sort position of all groups and boxes. If a box or group is removed from the DOM, the underlying data will also be automtically removed by this function
function setSortOrder(){
	var arrGroup={};
	var boxGroups={};
	$(".z-grid-group").each(function(){
		var id=parseInt($(this).attr("data-id"));
		arrGroup.push(id);
		boxGroups[id]=[];

		$(".z-grid-box", this).each(function(){
			var id=parseInt($(this).attr("data-id"));
			boxGroups[id].push(id);
		});
	});
 	
 	var newGridData={
 		groups:[],
 		settings:{}
 	};
 	for(var i=0;i<arrGroup.length;i++){
 		var group=getGroupById(arrGroup[i]);
 		var newGroup={
 			settings:group.settings,
 			clientSettings:group.clientSettings,
 			boxes:[]
 		};
 		newGroup.settings.grid_group_sort=i;
 		for(var n=0;n<group.boxes.length;n++){
 			var box=getBoxById(group, group.boxes[n].clientSettings.id);
 			box.data.grid_box_sort=n;
 			newGroup.boxes.push(box);
 		}
 		newGridData.groups.push(newGroup);
 	}
 	gridData=newGridData;
}

function getGroupById(id){
	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i];
		if(group.clientSettings.id == id){
			return group;
		}
	}
	throw("Failed to getGroupById:"+id);
}
function getBoxById(group, id){
	for(var i=0;i<group.boxes.length;i++){
		var box=group.boxes[i];
		if(box.clientSettings.id == id){
			return box;
		}
	}
	throw("Failed to getBoxById:"+id);
}

function setupGroupForm(){
	var group=getGroupById(zGridEditor.currentGroupId);

	setFormData("gridGroupForm", group.settings);  
	if(parseInt(group.settings.grid_group_children_center) == 1){
		$("#grid_group_children_center1").prop("checked", true);
	}else{
		$("#grid_group_children_center0").prop("checked", true);
	}
	if(parseInt(group.settings.grid_group_section_center) == 1){
		$("#grid_group_section_center1").prop("checked", true);
	}else{
		$("#grid_group_section_center0").prop("checked", true);
	}
	if(parseInt(group.settings.grid_group_visible) == 1){
		$("#grid_group_visible1").prop("checked", true);
	}else{
		$("#grid_group_visible0").prop("checked", true);
	}
	


	$("#gridGroupForm .tabWaitButton").click("click", function(e){
		e.preventDefault();
	});
	$("#gridGroupForm .tabSaveButton").click("click", function(e){
		e.preventDefault();

		// update the main data structure
		saveGridGroup();

		// render group only (not possible yet)
		console.log('TODO: need to render group on save');

		closeGroupForm();
		//zCloseModal();
	});
	$("#gridGroupForm .tabCancelButton").click("click", function(e){
		e.preventDefault();

		closeGroupForm();
		//zCloseModal();
	}); 
}
function setupBoxForm(){
	console.log('setupBoxForm:'+zGridEditor.currentGroupId);
	var group=getGroupById(zGridEditor.currentGroupId);
	var box=getBoxById(group, zGridEditor.currentBoxId);

	//setFormData("gridGroupForm", group.settings); 
	setFormData("gridBoxForm", box.data);

	if(parseInt(box.data.grid_box_visible) == 1){
		$("#grid_box_visible1").prop("checked", true);
	}else{
		$("#grid_box_visible0").prop("checked", true);
	}

	group.settings.grid_group_column_count=parseInt(group.settings.grid_group_column_count);
	box.data.grid_box_column_size=parseInt(box.data.grid_box_column_size);

	var columnSize=document.getElementById("grid_box_column_size");
	for(var i=0;i<columnSize.options.length;i++){
		var n=columnSize.options[i];
		if(parseInt(n.value) > group.settings.grid_group_column_count){
			n.disabled=true;
		}else{
			n.disabled=false;
		}
	}
	$("#gridBoxForm .tabWaitButton").click("click", function(e){
		e.preventDefault();
	});
	$("#gridBoxForm .tabSaveButton").click("click", function(e){
		e.preventDefault();

		// update the main data structure
		saveGridBox();
		
		// render box only (not possible yet)
		var group=getGroupById(zGridEditor.currentGroupId);
		var box=getBoxById(group, zGridEditor.currentBoxId);
		var html=renderBox(group, box); 
		var boxElement=$('#gridBoxDiv'+box.clientSettings.id);
		boxElement.replaceWith(html);

		//console.log('TODO: need to render box on save');

		closeBoxForm();
		//zCloseModal();
	});
	$("#gridBoxForm .tabCancelButton").click("click", function(e){
		e.preventDefault();
		closeBoxForm();
		//zCloseModal();
	}); 
}

function setupGridEditor(){

	for(var i=0;i<gridData.groups.length;i++){
		var group=gridData.groups[i]; 
		group.clientSettings={
			id:getUniqueId()
		};
		for(var n=0;n<group.boxes.length;n++){
			var box=group.boxes[n];
			box.clientSettings={
				id:getUniqueId()
			};
		}
	}

	renderGrid();


	$(".z-grid-header").dblclick(function(e){
		e.preventDefault();
		var parent=this.parentNode;
		var i=0;
		while(true){
			if($(parent).hasClass("z-grid-group")){
				break;
			}
			parent=parent.parentNode;
			i++;
			if(i>10){
				throw("Invalid group structure. Unable to find z-grid-group");
				break;
			}
		}
		showModalGroupForm(parent);
	});

	$(".z-grid-box").dblclick(function(e){
		e.preventDefault();
		showModalBoxForm(this);
	});
}
function showModalGroupForm(obj){ 
	setCurrentGroup(obj); 
	var windowSize=zGetClientWindowSize(); 
	$("#gridGroupFormContainer").show().css({
		"position":"absolute",
		"left":"0px",
		"top":"0px",
		"padding":"10px",
		"overflow":"auto",
		"background-color":"rgba(0,0,0,0.7)", 
		"width":"100%",
		"height":(windowSize.height)+"px",
		"z-index":10000
	});
	$("body").css("overflow", "hidden");
	$("#gridGroupForm .tabWaitButton").hide();
	$("#gridGroupForm .tabSaveButton").show();
	//zShowModal(gridGroupFormTemplate, {'width':windowSize.width-100,'height':windowSize.height-100}); 
	//window["zSetupTabMenu"+gridGroupTabIndex]();
	setupGroupForm(); 
}
function closeGroupForm(){
	$("#gridGroupFormContainer").hide();
	$("body").css("overflow", "auto");
}
function closeBoxForm(){
	$("#gridBoxFormContainer").hide();
	$("body").css("overflow", "auto");
}
function showModalBoxForm(obj){ 
	setCurrentBox(obj);  
	var windowSize=zGetClientWindowSize();
	$("#gridBoxFormContainer").show().css({
		"position":"absolute",
		"left":"0px",
		"top":"0px",
		"padding":"10px",
		"overflow":"auto",
		"background-color":"rgba(0,0,0,0.7)",
		"float":"left",
		"width":"100%",
		"height":(windowSize.height)+"px",
		"z-index":10000
	});
	$("body").css("overflow", "hidden");
	$("#gridBoxForm .tabWaitButton").hide();
	$("#gridBoxForm .tabSaveButton").show();
	//zShowModal(gridBoxFormTemplate, {'width':windowSize.width-100,'height':windowSize.height-100}); 
	//window["zSetupTabMenu"+gridBoxTabIndex](); 
	setupBoxForm(); 
}

function saveGrid(){

	var tempObj={};
	tempObj.id="zGridSaveJson";
	tempObj.postObj={
		grid:JSON.stringify(gridData)
	};
	tempObj.url="/z/_com/grid/grid?method=saveGrid&grid_id="+document.getElementById("gridId").value;
	tempObj.method="post";
	tempObj.callback=function(r){
		var r=JSON.parse(r);
		if(!r.success){
			alert("Failed to save/parse the grid data.");
			return;
		}
		$(".debugResponseDiv").html(JSON.stringify(r)); 
		console.log('saved:'+Math.random());
	};
	tempObj.cache=false;
	zAjax(tempObj); 
} 



 

function escapeRegExp( str ) {
	return str.replace( /([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1" );
}
 /*
function getTemplate( name ) {
	var template = $( 'script#' + name );

	if ( template.length > 0 ) {
		return template.html().trim();
	}

	return;
}
*/
function replaceTemplateVars( template_html, variables ) {
	for (var variable in variables ) {
		var search = '{{' + variable + '}}';

		template_html = template_html.replace( new RegExp( escapeRegExp( search ), 'g' ), variables[ variable ] );
	}

	return template_html;
}


function getGridGroupID( grid_group ) {
	return parseInt(grid_group.attr( 'data-group-id' ));
}

function getClosestGridGroup( element ) {
	return element.closest( '.z-grid-group' );
}

function getClosestGridBox( element ) {
	return element.closest( '.z-grid-box' );
}


function sortGridGroups() {
	$( '#z-grid-groups' ).sortable( {
		axis: 'y',
		placeholder: 'z-grid-group-placeholder',
		forcePlaceholderSize: true,
		handle: '.z-grid-group-move-handle',
		start: function( event, ui ) {
			console.log('start drag');
			$( ui.placeholder ).css( {
				'height': $( ui.item ).outerHeight() + 'px'
			} );

			$( ui.item ).css( { 'max-width': 'none' } );
		},
		stop: function( event, ui ) {
			$( ui.item ).css( { 'max-width': '100%' } );

			zForceChildEqualHeights();
		}
	} );
			console.log('setup drag: '+$( '#z-grid-groups' ).length);
}
function sortGridBoxes() {
	$( '.z-grid-boxes-sortable' ).sortable( {
		// axis: 'x',
		connectWith: '.z-grid-boxes-sortable',
		placeholder: 'z-grid-box-placeholder',
		handle: '.z-grid-box-move-handle',
		distance: 40,
		helper: 'clone',
		start: function( event, ui ) {
			$( ui.placeholder ).css( {
				'width': getWidthAsFloat( $( ui.helper ) ) + '%',
				'height': getHeightAsFloat( $( ui.helper ) ) + 'px'
			} );

			$( ui.item ).css( { 'max-width': 'none' } );
			$( ui.helper ).css( {
				'overflow': 'hidden'
			} );
		},
		stop: function( event, ui ) {
			$( ui.item ).css( { 'max-width': '100%' } );

			zForceChildEqualHeights();
		}
	} );
}

function getWidthAsFloat( element ) {
	var width = element.outerWidth();

	var parent       = element.parent();
	var parent_width = parent.get( 0 ).getBoundingClientRect().width;

	var percent_width = parseFloat( ( width / parent_width ) * 99.7608 );
	percent_width = percent_width.toFixed( 4 );

	return percent_width;
}

function getHeightAsFloat( element ) {
	var height = element.outerHeight();

	return height;
}
  
var $document = $( document );

function registerEvents(){

	$document.on( 'mouseenter', '.z-grid-box', function() {
		var box = $( this ); 

		var overlay_html =gridOverlayTemplate;

		overlay_html = replaceTemplateVars( overlay_html, {

		} );

		box.append( overlay_html );
	} ).on( 'mouseleave', '.z-grid-box', function() {
		$( '.z-grid-box-overlay', this ).remove();
	} ); 

	$document.on( 'click', '.z-grid-group-settings', function( event ) {
		event.preventDefault();

		var grid_group    = getClosestGridGroup( $( this ) );
		var grid_group_id = getGridGroupID( grid_group );
 		
 		alert('show group form:'+grid_group_id);

		return false;
	} );
 
	$document.on( 'click', '.z-grid-box-overlay', function( event ) {
		event.preventDefault();

		console.log( $( this ).parent() );

		return false;
	} );
 
	function createBox(group, groupElement){

		var box={
			data:jQuery.extend(true, {}, boxSettings),
			clientSettings:{
				id:getUniqueId()
			}
		};

		box.data.grid_box_id=0;
		box.data.grid_group_id=group.settings.grid_group_id;
		box.data.grid_box_sort=group.boxes.length+1;
 
		var html=renderBox(group, box); 
		group.boxes.push(box);
		return {html:html, box:box};
	}

	$document.on( 'click', '.z-grid-add-box', function( event ) {
		event.preventDefault();

		var groupElement    = getClosestGridGroup( $( this ) );
		var grid_group_id = getGridGroupID( groupElement ); 
  		var group=getGroupById(grid_group_id); 
		var newBox=createBox(group, groupElement);
		var grid_group_boxes_container = $( '.z-grid-boxes', groupElement );

		$(".z-grid-boxes-sortable", grid_group_boxes_container).append(newBox.html);
  
		sortGridBoxes();
		zForceChildEqualHeights();

		zGridEditor.currentGroupId=group.clientSettings.id; 
		zGridEditor.currentBoxId=newBox.box.clientSettings.id; 

		console.log(newBox);
		console.log('zGridEditor.currentGroupId:'+zGridEditor.currentGroupId);

		// get the new box as dom element
		console.log('new clientSettings box id:'+newBox.box.clientSettings.id);
		var boxElement=$('#gridBoxDiv'+newBox.box.clientSettings.id);
		showModalBoxForm(boxElement);
 

		return false;

		var layout_id    = prompt( "[TEMP] Enter layout ID (4-7):" );

		if ( layout_id < 4 ) {
			alert( 'Not Yet Implemented' );
			return;
		}

		var box_width = prompt( "[TEMP] Enter box width (i.e. '1of3' = z-1of3):" );
   
   		
		var group=getGroupById(1);
		var box=getBoxById(group, 1);
		var new_box_html=renderBox(group, box);
 

		return false;
	} );


	$document.on( 'click', '.z-grid-box-copy', function( event ) {
		event.preventDefault();

		var grid_box = getClosestGridBox( $( this ) );
		var grid_group    = getClosestGridGroup( $( this ) );

		grid_box.addClass( 'z-grid-box-new' );

		var box_html = grid_box.get( 0 ).outerHTML;

		grid_box.removeClass( 'z-grid-box-new' );
		grid_box.after( box_html );

		var new_box = $( '.z-grid-box-new', grid_group );

		$( '.z-grid-box-overlay', new_box ).remove();

		return false;
	} );


	$document.on( 'click', '.z-grid-box-delete', function( event ) {
		event.preventDefault();

		if(window.confirm("Are you sure you want to delete this box?")){

			var grid_box = getClosestGridBox( $( this ) );

			grid_box.remove();

			zForceChildEqualHeights();
		}
		return false;
	} );

	$document.on( 'click', '.z-grid-delete-group', function( event ) {
		event.preventDefault();

		if(window.confirm("Are you sure you want to delete this group?")){

			var group = getClosestGridGroup($(this))
			var groupId=group.attr("data-group-id");
			group.remove();

		}
		return false;
	} );


	function createGroup(){

		var group={
			settings:jQuery.extend(true, {}, groupSettings),
			clientSettings:{
				id:getUniqueId()
			},
			boxes:[]
		};
		group.settings.grid_group_sort=gridData.groups.length+1;
		group.settings.grid_group_id=0;

		var html=renderGroupStart(group)&renderGroupEnd(group);

		return {html:html, group:group};
	}
	$document.on( 'click', '#z-grid-add-group a', function( event ) {
		event.preventDefault();
 
		var newGroup=createGroup();
		var grid_group_boxes_container=$('#z-grid-groups');

		grid_group_boxes_container.append(newGroup.html);
 		
 		sortGridGroups();
		sortGridBoxes();
		zForceChildEqualHeights();

		console.log(newGroup);

		//showModalBoxForm(newGroup.group);
  
		/*

		var new_group_html = gridGroupTemplate;
		var total_groups   = $( '.z-grid-group', grid_groups ).length;
		var new_group_id   = ( total_groups + 1 );

		new_group_html = replaceTemplateVars( new_group_html, {
			'grid_group_id': new_group_id
		} );

		$( '#z-grid-groups' ).append( new_group_html );

		var new_group = $( '#z-grid-group-' + new_group_id );

		sortGridGroups();
		sortGridBoxes();


		zForceChildEqualHeights();

		return false;*/
	} ); 
}
var grid_editor_interface = $( '#z-grid-editor-interface' );
var grid_groups             = $( '#z-grid-groups', grid_editor_interface );

zArrDeferredFunctions.push( function() {

	registerEvents();

	sortGridGroups();
	sortGridBoxes();

	zForceChildEqualHeights();
	setTimeout(function(){
		zForceChildEqualHeights();

	}, 500);



	$(".gridSaveButton").bind("click", saveGrid);

	var tempObj={};
	tempObj.id="zGridLoadJson";
	//tempObj.postObj=zGetFormDataByFormId("loadForm"); 
	tempObj.url="/z/_com/grid/grid?method=loadGrid&grid_id="+document.getElementById("gridId").value;
	tempObj.method="get";
	tempObj.callback=function(r){
		var r=JSON.parse(r);
		if(!r.success){
			alert("Failed to load/parse the grid data.");
			return;
		}
		gridData=r.grid;  
		$("#gridDebugId").val(JSON.stringify(gridData, null, 4)); 
		setupGridEditor(); 
sortGridGroups();
sortGridBoxes();
	};
	tempObj.cache=false;
	zAjax(tempObj);  
});
 
})(jQuery, window, document, "undefined"); 
