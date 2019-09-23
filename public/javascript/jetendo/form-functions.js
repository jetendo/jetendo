
var zSiteOptionGroupLastFormID="";
var zAjaxSortURLCache=[];
var zCacheSliderValues=[];
var selIndex=0;
var zAjaxData=[];
var zAjaxCounter=0;
var zAjaxLastRequestId=false;
var zAjaxLastFormName="";
var zAjaxOnLoadCallback=function(){};
var zAjaxOnErrorCallback=function(){};
var zAjaxLastOnErrorCallback=function(){};
var zInputSlideOldValue="";
var zArrSetSliderInputArray=[];
var zArrSetSliderInputUniqueArray=[];
var zExpOptionLabelHTML=[];
var zAjaxLastOnLoadCallback=false;
var zMotiontimerlen = 10;
var zMotionslideAniLen = 150;
var zMotiontimerID = new Array();
var zMotionstartTime = new Array();
var zMotionobj = new Array();
var zMotionendHeight = new Array();
var zMotionmoving = new Array();
var zMotiondir = new Array();
var zMotionLabel=new Array();
var zMotionHOC=new Array();
var zMotionObjClicked="";
var zFormOnEnterValues=new Array();
var zInputBoxLinkValues=[];
var zIsDirty=false;
var zCurrentHash="";

/*var zLastAjaxTableId="";
var zLastAjaxURL="";
var zLastAjaxVarName=""; */

(function($, window, document, undefined){
	"use strict";
 
	$.fn.filterByText = function(textbox, selectSingleMatch) {
		return this.each(function() {
			var select = this;
			var options = [];
			$(select).find('option').each(function() {
				options.push({value: $(this).val(), text: $(this).text()});
			});
			$(select).data('options', options);

			$(textbox).bind('change keyup', function() {
				var options = $(select).empty().data('options');
				var search = $.trim($(this).val());
				var regex = new RegExp(search,"gi");

				$.each(options, function(i) {
					var option = options[i];
					if(option.text.match(regex) !== null) {
						$(select).append(
							$('<option>').text(option.text).val(option.value)
						);
					}
				});
				if (typeof selectSingleMatch != "undefined" && selectSingleMatch === true && $(select).children().length === 1) {
					$(select).children().get(0).selected = true;
				}
			});
		});
	}; 
	function zUpdateImageLibraryCount(){
		var d=document.getElementById("sortable");

		$(window.parent.zImageCountObj).html($("li", d).length+" images in library");
		//$("#imageLibraryDivCount", window.parent.document).html($("li", d).length+" images in library");
	}
	function ajaxSaveSorting(){
		var arrId=$( "#sortable" ).sortable("toArray");
		for(var i=0;i<arrId.length;i++){
			arrId[i]=arrId[i].substr(5);
		}
		var link="/z/_com/app/image-library?method=saveSortingPositions&image_library_id="+currentImageLibraryId+"&image_id_list="+arrId.join(",");
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		}, "html");  

		if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveSorting(): array of image_id:\n"+arrId+"\nLINK:"+link;
	}
	function ajaxSaveImage(id){
		if(debugImageLibrary) document.getElementById("forimagedata").value+="ajaxSaveImage(): image_id:"+id+"\n";
		var link="/z/_com/app/image-library?method=saveImageId&action=update&image_library_id="+currentImageLibraryId+"&image_id="+id+"&image_caption="+escape(document.getElementById('caption'+id).value);
		if(debugImageLibrary) document.getElementById("forimagedata").value+="\n\n"+link+"\n\n";
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX SAVE IMAGE RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		},     "html");  
	}

	function toggleImageCaptionUpdate(id,state,skipUpdate){
		var d=document.getElementById(id);
		var ajaxCall=false;
		if(d.style.display==="block" && state ==="none"){
			ajaxCall=true;	
		}
		var image_id=id.substr("imagecaptionupdate".length);
		d.style.display=state; 
		if(ajaxCall && typeof arrImageLibraryCaptions[image_id] !== "undefined" && arrImageLibraryCaptions[image_id] !== document.getElementById("caption"+image_id).value){
			ajaxSaveImage(image_id);
			arrImageLibraryCaptions[image_id]=document.getElementById("caption"+image_id).value;
		}
	}
	function confirmDeleteImageId(id){
		if(window.confirm("Are you sure you want to PERMANENTLY DELETE this image?")){
			deleteImageId(id);	
		}
	}
	function deleteImageId(id){
		var d = document.getElementById('sortable');
		var olddiv = document.getElementById("image"+id);
		d.removeChild(olddiv);
		var link="/z/_com/app/image-library?method=remoteDeleteImageId&image_id="+id;
		if(debugImageLibrary) document.getElementById("forimagedata").value+="\nDelete Image ID:"+id+"\n\n"+link+"\n\n";
		$.get(link, "",     function(data) { 
			if(debugImageLibrary){
				document.getElementById("forimagedata").value+="\n\nAJAX DELETE IMAGE RESULT:\n"+data+"\n"; 
			}
			zUpdateImageLibraryCount();
		},     "html"); 
		ajaxSaveSorting();
	}
	function setUploadField(){
		var hasFlash = false;
		return;
		/*try {
			var fo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
			if(fo) hasFlash = true;
		}catch(e){
			if(navigator.mimeTypes ["application/x-shockwave-flash"] !== "undefined") hasFlash = true;
		}
		var d = document.getElementById("imagefiles");
		// temporarily disable html 5 multiple file upload until cfml server has fixed the bug with it.
		if(1===0){// typeof d.multiple === "boolean" || !hasFlash){
			document.getElementById("flashFileUpload").style.display="none";
		}else{
			document.getElementById("htmlFileUpload").style.display="none";
			document.getElementById("flashFileUpload").style.display="block";
		}*/
	}
	function zOptionGroupAutoMap(){
		var matchCount=0;
		$("#optionGroupMapForm .fieldLabelDiv").each(function(){
			var id=$(this).attr("data-id");
			var text=this.innerHTML.toLowerCase();
			text=text.replace(/ /, "_");

			var matched=false;
			var s=document.getElementById("mapField"+id);
			if(s.selectedIndex != 0){
				return;
			}
			var custom=0;
			for(var i=0;i<s.options.length;i++){
				if(s.options[i].value == 'inquiries_custom_json'){
					custom=i;
					break;
				}
			}
			for(var i=0;i<s.options.length;i++){
				var v=s.options[i].value.replace(/inquiries_/, '');
				if(v==text){
					//console.log('Matched: '+v);
					s.selectedIndex=i;
					matched=true;
						matchCount++;
					break;
				}
			}
			if(!matched){
				for(var i=0;i<s.options.length;i++){
					var v=s.options[i].value.replace(/inquiries_/, '');
					if(v.indexOf(text) != -1){
						//console.log('Partial match: '+v);
						s.selectedIndex=i;
						matched=true;
						matchCount++;
						break;
					}
				}
			}
			if(!matched){
				//console.log('no match found for '+text, 'should be custom_json now.');
				s.selectedIndex=custom;
			}
		});
		return matchCount;
	}
	 
	$(".zOptionGroupAutoMap").bind("click", function(){
		var matchCount=zOptionGroupAutoMap();
		alert(matchCount+" fields were automatically mapped.");
	}); 

	function zOptionGroupErrorCallback(){
		alert("There was a problem with the submission. Please try again later.");
		$(".zOptionGroupSubmitButton", $("#"+zOptionGroupLastFormID)).show();
		$(".zOptionGroupWaitDiv", $("#"+zOptionGroupLastFormID)).hide();
	}
	function zOptionGroupCallback(d){
		var rs=eval("("+d+")");
		$(".zOptionGroupSubmitButton", $("#"+zOptionGroupLastFormID)).show();
		$(".zOptionGroupWaitDiv", $("#"+zOptionGroupLastFormID)).hide();
		if(zOptionGroupLastFormID != ""){
			$("#"+zOptionGroupLastFormID+" input, #"+zOptionGroupLastFormID+" textarea, #"+zOptionGroupLastFormID+" select").bind("change", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			}).bind("keyup", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			}).bind("paste", function(){
				if(zGetFormFieldDataById(this.id) != ""){
					$(this).closest("tr").removeClass("zFieldError");
				}
			});
			zJumpToId(zOptionGroupLastFormID, -50);
		}
		if(rs.success){
			var link=$("#"+zOptionGroupLastFormID).attr("data-thank-you-url");
			if(link != ""){
				window.location.href=link;
			}else{
				alert("Your submission was received.");
			}
		}else{
			for(var i=0;i<rs.arrErrorField.length;i++){
				$("#"+rs.arrErrorField[i]).closest("tr").addClass("zFieldError");
			}
			alert("Please correct the following errors and submit the form again\n"+rs.errorMessage);
		}
	}
	function zOptionGroupPostForm(formId){
		zOptionGroupLastFormID=formId;
		$(".zOptionGroupSubmitButton", $("#"+zOptionGroupLastFormID)).hide();
		$(".zOptionGroupWaitDiv", $("#"+zOptionGroupLastFormID)).show();
		var postObj=zGetFormDataByFormId(formId);
		var obj={
			id:"ajaxOptionGroup",
			method:"post",
			postObj:postObj,
			ignoreOldRequests:false,
			callback:zOptionGroupCallback,
			errorCallback:zOptionGroupErrorCallback,
			url:'/z/misc/display-site-option-group/ajaxInsert'
		}; 
		zAjax(obj);
	} 
	function zSetupAjaxTableSortAgain(){
		for(var tableId in zAjaxCacheTableSort){
			var c=zAjaxCacheTableSort[tableId];
			zSetupAjaxTableSort(c.tableId, c.ajaxURL, c.ajaxVarName, c.ajaxVarNameOriginal, c.ajaxCallback);
		}
	}
	var zAjaxCacheTableSort={};
	function zSetupAjaxTableSort(tableId, ajaxURL, ajaxVarName, ajaxVarNameOriginal, ajaxCallback){
		/*zLastAjaxTableId=tableId;
		zLastAjaxURL=ajaxURL;
		zLastAjaxVarName=ajaxVarName;*/

		zAjaxCacheTableSort[tableId]={
			tableId:tableId, 
			ajaxURL:ajaxURL, 
			ajaxVarName:ajaxVarName, 
			ajaxVarNameOriginal:ajaxVarNameOriginal, 
			ajaxCallback:ajaxCallback
		};

		var validated=true;
		var arrError=[];
		zAjaxSortURLCache[tableId]={
			url:ajaxURL
			/*,
			cache:$("#"+tableId).html()*/
		};
		if($( '#'+tableId).length == 0){
			validated=false; 
			return;
		}
		if($( '#'+tableId+' thead' ).length == 0){
			validated=false;
			arrError.push('queueSortCom.ajaxTableId is set to "'+tableId+'", but this table is missing the <thead> tag around the header rows, which is required for table row sorting to function.');
		}
		if($( '#'+tableId+' tbody' ).length == 0){
			validated=false;
			arrError.push('queueSortCom.ajaxTableId is set to "'+tableId+'", but this table is missing the <tbody> tag around the body rows, which is required for table row sorting to function.');
		}
		var arrSort=[];
		$( '#'+tableId+' tbody tr' ).each(function(){
			if(this.id == ''){
				validated=false;
			}else{
				if($("."+tableId+"_handle", this).length){
					var v=$("."+tableId+"_handle", this)[0].getAttribute('data-ztable-sort-primary-key-id');
					if(v != ""){
						arrSort.push(v);
					}
				}
			}
		}); 
		var originalSortOrderList=arrSort.join("|"); 
		$("#"+tableId+" tbody").attr("data-original-sort", originalSortOrderList);
		if(validated){
			$('#'+tableId+' tbody' ).sortable({
				handle: '.'+tableId+'_handle',
				stop:function(e, e2){
					var originalSortOrderList=$("#"+tableId+" tbody").attr("data-original-sort");
					var arrId=$("#"+tableId+" tbody").sortable("toArray");
					var arrId2=[]; 
					for(var i=0;i<arrId.length;i++){
						var v=$("#"+arrId[i]+" ."+tableId+"_handle").attr("data-ztable-sort-primary-key-id"); 
						if(typeof v != "undefined" && v != ""){
							arrId2.push(v); 
						}
					} 

					var reloadOnSuccess=false;
					// when using parent field, we can't let use sort children outside their parent.
					var parentId=$(e2.item[0]).attr("data-ztable-sort-parent-id");
					if(parentId != null && parentId != ""){
						reloadOnSuccess=true;
					}

					var sortOrderList=arrId2.join("|");
					//console.log("sorted list:"+sortOrderList);
					var tempObj={};
					tempObj.id="zAjaxChangeSortOrder";
					tempObj.url=zAjaxSortURLCache[tableId].url;
					tempObj.method="post";
					tempObj.postObj={};
					if(reloadOnSuccess){
						tempObj.postObj.zDisableSortValidation=1;
					}
					tempObj.postObj[ajaxVarName]=sortOrderList;
					tempObj.postObj[ajaxVarNameOriginal]=originalSortOrderList; 
					tempObj.callback=function(r){
						var d=eval('('+r+')');
						if(!d.success){
							//$("#"+tableId).html(zAjaxSortURLCache[tableId].cache);
							alert(d.errorMessage);
						}else{
							zAjaxSortURLCache[tableId].cache=$("#"+tableId).html();

							arrSort=[];
							$( '#'+tableId+' tbody tr' ).each(function(){
								if(this.id == ''){
									validated=false;
								}else{
									if($("."+tableId+"_handle", this).length){
										var v=$("."+tableId+"_handle", this)[0].getAttribute('data-ztable-sort-primary-key-id');
										if(v != ""){
											arrSort.push(v);
										}
									}
								}
							}); 
							originalSortOrderList=arrSort.join("|");
							$("#"+tableId+" tbody").attr("data-original-sort", originalSortOrderList); 
							ajaxCallback(tempObj);  

							if(reloadOnSuccess){
								window.location.reload();
							}
						}
					};
					tempObj.errorCallback=function(){
						//$("#"+tableId).html(zAjaxSortURLCache[tableId].cache);
						alert("Failed to sort records.");
					};
					tempObj.cache=false; 
					tempObj.ignoreOldRequests=false;
					zAjax(tempObj);
				}
			});
		}else{
			arrError.push('Each <tr> row must have a unique id attribute and a data-ztable-sort-primary-key-id attribute with the value set to the primary key id for the current record.');
		}
		if(arrError.length){
			alert(arrError.join("\n"));
		}
	}

	function zGetSelectValues(select) {
		var result = [];
		var options = select && select.options;
		var opt;
		var hasValue=false;
		
		for (var i=0, iLen=options.length; i<iLen; i++) {
			if(options[i].value != ""){
				hasValue=true;
				break;
			}
		}
		for (var i=0, iLen=options.length; i<iLen; i++) {
			opt = options[i];

			if (opt.selected) {
				if(hasValue){
					result.push(opt.value);
				}else{
					result.push(opt.text);
				}
			}
		}
		return result;
	}

	function zGetFormDataByFormId(formId){
		var obj={};
		$("input, textarea, select", $("#"+formId)).each(function(e, e2){ 
			if(typeof obj[this.name] === 'undefined'){
				if(this.type === 'checkbox' || this.type === 'radio'){
					if(this.checked){
						obj[this.name]=this.value;
					}
				}else if(this.type.substr(0, 6) === 'select'){
					obj[this.name]=zGetSelectValues(this).join(","); 
				}else{
					obj[this.name]=this.value;
				}
			}else{
				if(this.type === 'checkbox' || this.type === 'radio'){
					if(this.checked){
						obj[this.name]+=","+this.value;
					}
				}else if(this.type.substr(0, 6) === 'select'){
					obj[this.name]+=","+zGetSelectValues(this).join(","); 
				}else{
					obj[this.name]+=","+this.value;
				} 
			}
		});
		return obj;
	} 
	function zGetFormFieldDataById(id){
		var field=$("#"+id);
		if(field.length){
			var f=field[0];
			if(this.type === 'checkbox' || this.type === 'radio'){
				if(this.checked){
					return this.value;
				}
			}else if(this.type.substr(0, 6) === 'select'){
				return zGetSelectValues(this).join(","); 
			}else{
				return this.value;
			}
			return ""; 
		}else{
			return "";
		}
	}
	function zDisableEnter(e){
		var key;
	     if(window.event) key = window.event.keyCode;     //IE
	     else key = e.which;     //firefox
	     if(key === 13 || key === 40 || key ===38){
	          return false;
		 }else{
	          return true;
		 }
	}

	function zKeyboardEvent(e, obj,obj2,forceEnter){
		var keynum;
		if(e===null) return;
		var numcheck;
		if(!selIndex){
			selIndex=0;
		}
		if(window.event){
			keynum = e.keyCode;
		}else{
			keynum = e.which;
		}
		if(obj.value.length > 2){	
			var doc = document.getElementById("zTOB");
			//var allLinks = doc.getElementsByTagName('a');
			//arrNewLink
			if(keynum === 13 || forceEnter === true){
				// enter
				if(obj.value === "") return;
				if(doc.style.display==="block"){
					var textToForm = document.getElementById("lid"+arrNewLink[selIndex]).innerHTML;
					var textValue=textToForm;
					for(var i=0;i<zArrCityLookup.length;i++){
						var arrJ=zArrCityLookup[i].split("\t");
						if(arrJ[0]===textToForm){
							textValue=arrJ[1];
							break;
						}
					}
					obj.value=textToForm;
					obj2.value=textValue;
					//zInputPutIntoForm(textToForm,textValue, formName,obj2.id,false);
					zInputHideDiv(formName);
				}else{
					obj2.value=obj.value;
				}
				selIndex=-1;
			}else if(keynum === 40){
				//down
				selIndex++;
				selIndex=Math.min(selIndex,arrNewLink.length-1);
			}else if(keynum===38){
				// up	
				selIndex--;
				selIndex=Math.max(0,selIndex);
			}else{
				if(doc.style.display!=="block"){
					obj2.value=obj.value;
					selIndex=-1;
				}
				return;	
			}
			var firstBlock=-1;
			var matched=false;
			for(i=0;i<arrNewLink.length;i++){
				var c=document.getElementById('lid'+arrNewLink[i]);
				/*if(firstBlock==-1 && c.style.display=="block"){
				//	firstBlock=i;	
				}
				if(c.style.display=="none"){
				//	selIndex++;	
				}*/
				if(i===selIndex){
					matched=true;
					c.className="zTOB-selected";
					// set new value here
					var textToForm = c.innerHTML;
					var textValue=textToForm;
					for(var n=0;n<zArrCityLookup.length;n++){
						var arrJ=zArrCityLookup[n].split("\t");
						if(arrJ[0]===textToForm){
							textValue=arrJ[1];
							break;
						}
					}
					obj.value=textToForm;
					obj2.value=textValue;
				}else{
					c.className="zTOB-link";
				}
			}
		}
	}	


	function zInputHideDiv(name){
		var z=document.getElementById("zTOB");
		if(z!==null){z.style.display="none";}
	}

	function zFormOnKeyUp(formName, fieldIndex){
		var f=zFormData[formName].arrFields[fieldIndex];
		var o=document.getElementById(f.id);
		if(zFormData[formName].error){
			zFormSubmit(formName,true,false);
		}
		
	}
	function zFormOnChange(formName, fieldIndex){
		var f=zFormData[formName].arrFields[fieldIndex];
		var o=document.getElementById(f.id);
		if(zFormData[formName].error){
			zFormSubmit(formName,true,false);
		}
		if(typeof zFormData[formName].onChangeCallback === "undefined") return;
		zFormData[formName].onChangeCallback(formName);
	}
	function zFormSetError(id,error){
		var tr=document.getElementById(id+'_container');
		if(tr !== null){
			if(error){
				tr.className="tr_error";
			}else{
				tr.className="";
			}
		}
	}
	function zResetManagerTabEdit(){ 
		$(".tabWaitButton").hide();
		$(".tabSaveButton").show();
	}

	/*
	var tempObj={};
	// variables can be posted with tempObj.formId or with tempObj.postObj, but not both.  
	// tempObj.formId is recommended because it supports ajax file uploads.
	tempObj.formId="zManagerEditForm";
	// tempObj.postObj={}; // deprecated legacy method of posting specific variables.
	tempObj.id="zManagerEditForm";
	tempObj.url="/urlInQuotes.html";
	tempObj.callback=function(r){
		var r=JSON.parse(r);
		if(r.success){
			// use the data
		}else{
			alert(r.errorMessage);
		}
	};
	tempObj.errorCallback=function(){
		// alert("Sorry, there was a problem with your submission, please try again later.");
	};
	tempObj.cache=false; // set to true to disable ajax request when already downloaded same URL
	tempObj.ignoreOldRequests=true; // causes only the most recent request to have its callback function called.
	zAjax(tempObj);
	*/
	function zAjax(obj){
		var req = null;  
		if(window.XMLHttpRequest){ 
		  req = new XMLHttpRequest();  
		}else if (window.ActiveXObject){ 
		  req = new ActiveXObject('Microsoft.XMLHTTP');  
		}
		if(typeof zAjaxData[obj.id]==="undefined"){
			zAjaxData[obj.id]=new Object();
			zAjaxData[obj.id].requestCount=0;
			zAjaxData[obj.id].requestEndCount=0;
			zAjaxData[obj.id].cacheData=[];
		}
		if(typeof obj.formId != "undefined" && typeof obj.postObj != "undefined"){
			alert("Only obj.formId should be used, obj.postObj is deprecated.");
		}
		if(typeof obj.formId == "undefined"){
			if(typeof obj.postObj === "undefined"){
				obj.postObj={};	
			}
			var postData="";
			for(var i in obj.postObj){
				postData+=i+"="+encodeURIComponent(obj.postObj[i])+"&";
			}
		}
		if(typeof obj.cache==="undefined"){
			obj.cache=false;	
		}
		if(typeof obj.method==="undefined"){
			obj.method="get";	
		}
		if(typeof obj.debug==="undefined"){
			obj.debug=false;	
		}
		if(typeof obj.errorCallback==="undefined"){
			obj.errorCallback=function(){};	
		}
		if(typeof obj.ignoreOldRequests==="undefined"){
			obj.ignoreOldRequests=false;	
		}
		if(typeof obj.url==="undefined" || typeof obj.callback==="undefined"){
			alert('zAjax() Error: obj.url and obj.callback are required');	
		}
		
		zAjaxData[obj.id].requestCount++;
		zAjaxData[obj.id].cache=obj.cache;
		zAjaxData[obj.id].debug=obj.debug;
		zAjaxData[obj.id].method=obj.method;
		zAjaxData[obj.id].url=obj.url;
		zAjaxData[obj.id].ignoreOldRequests=obj.ignoreOldRequests;
		zAjaxData[obj.id].callback=obj.callback;
		zAjaxData[obj.id].errorCallback=obj.errorCallback;
		if(zAjaxData[obj.id].cache && zAjaxData[obj.id].cacheData[obj.url] && zAjaxData[obj.id].cacheData[obj.url].success){
			zAjaxData[obj.id].callback(zAjaxData[obj.id].cacheData[obj.url].responseText);
		}
		req.showRequestError=function(m){ 
			if(zIsDeveloper() || zIsTestServer()){
				alert("Unexpected response.  See console for request and response objects.  Click ok to view response."); 
				console.log("zAjax Request Object");
				console.log(zAjaxData[obj.id]); 
				console.log("zAjax Response Object");
				console.log(req); 
				zShowModal(req.responseText,{'width':zWindowSize.width-100,'height':zWindowSize.height-100});
				zResetManagerTabEdit();
				return false;
			}else{
				if(m!= ""){
					alert(m);
				}
				return true;
			}
		}
		req.onerror = function(e){ 
			req.showRequestError("Sorry, but that server request failed to load right now, please refresh your browser or come back later.");
		}
		req.onreadystatechange = function(){  
			if(req.readyState === 4 || req.readyState === "complete" || (zMSIEBrowser!==-1 && zMSIEVersion<=7 && this.readyState==="loaded")){
				var id=req.getResponseHeader("x_ajax_id");
				if(typeof id !== "undefined" && new String(id).indexOf(",") !== -1){
					id=id.split(",")[0];
				}
				if(req.status!==200 && req.status!==301 && req.status!==302){
					if(id===null || id===""){
						if(zIsDeveloper() || zIsTestServer()){
							alert("You must return a x_ajax_id header with a value that matches the x_ajax_id that was sent with the request.");
						}
						if(zAjaxLastRequestId !== false){
							id=zAjaxLastRequestId; 
							var continueExecution=req.showRequestError("");
							if(continueExecution){
								zAjaxData[id].errorCallback(req);
							}
						}else{
							req.showRequestError("Sorry, but that request response failed to load right now, please refresh your browser or come back later.");
						}
					}else{
						if(zAjaxData[id].debug){
							req.showRequestError(""); 
						}else{ 
							var continueExecution=req.showRequestError("");
							if(continueExecution){
								zAjaxData[id].errorCallback(req);
							}
						}
					}
					//return;
				}else if(id===null || id===""){
					if(!zIsDeveloper()){
						req.showRequestError("Invalid response.  You may need to login again or refresh the page.");
					}else{
						req.showRequestError("");  
					}
					return;
				}
				if(typeof zAjaxData[id] !== "undefined"){
					zAjaxData[id].requestEndCount++;
					if(!zAjaxData[id].ignoreOldRequests || zAjaxData[id].requestCount === zAjaxData[id].requestEndCount){
						if(req.status === 200 || req.status===301 || req.status===302){
							if(zAjaxData[id].cache){
								zAjaxData[id].cacheData[zAjaxData[id].url]=new Object();
								zAjaxData[id].cacheData[zAjaxData[id].url].responseText=req.responseText.trim();
								zAjaxData[id].cacheData[zAjaxData[id].url].success=true;
							}
							zAjaxData[id].callback(req.responseText.trim());
						/*}else{ 
							if(zAjaxData[id].debug){
								document.write('AJAX SERVER ERROR - (Click back and refresh to continue):<br />'+req.responseText);
							}else{
								zAjaxData[id].errorCallback(req);
							}
							zAjaxLastRequestId=false;*/
						}
					}
					
				}
				zAjaxLastRequestId=false;
			} 
		};
		var randomNumber = Math.random()*1000;
		var derrUrl="";
		if(!zIsDeveloper() && !zIsTestServer()){
			derrUrl="&zFPE=1";
		}
		if(zAjaxData[obj.id].debug){
			derrUrl="";
		}
		zAjaxLastRequestId=obj.id;
		var action=zAjaxData[obj.id].url;
		/*if(action.indexOf("x_ajax_id=") !== -1){
			alert("zAjax() Error: Invalid URL.  \"x_ajax_id\" can only be added by the system.\nDo not put this CGI variable in the action URL.");
		}*/
		if(action.indexOf("?") === -1){
			action+='?'+derrUrl+'&ztmp='+randomNumber;
		}else{
			action+='&'+derrUrl+'&ztmp='+randomNumber;
		}
		action+="&x_ajax_id="+escape(obj.id);

		var isMacSafari=false;
		if(navigator.userAgent.indexOf("Safari") != -1 && (navigator.userAgent.indexOf("Mac OS") != -1)){
			isMacSafari=true;
			var fileFieldCache={};
		}  
		if(typeof window.FormData != "undefined" && typeof obj.formId != "undefined"){
			var form = document.getElementById(obj.formId);
			if(isMacSafari){
				var offset1=0;
				$('input[type="file"]', $("#"+obj.formId)).each(function(){
					if(this.files.length == 0){
						fileFieldCache[offset1]={parent:$(this).parent(), element:$(this).detach()};
						offset1++; 
					}
				});
			}

			var formData = new FormData(form);

			var postObjTemp=zGetFormDataByFormId(obj.formId);
			for(var i in postObjTemp){
				if(postObjTemp[i] == ""){
					formData.append(i, ""); 
				}
			} 

			req.open(zAjaxData[obj.id].method, action, true); 
			req.send(formData);
			setTimeout(function(){
				if(isMacSafari){
					for(var id in fileFieldCache){
						fileFieldCache[id].parent.append(fileFieldCache[id].element);
					} 
				} 
			}, 500);

		}else{ 
			if(zAjaxData[obj.id].method.toLowerCase() === "get"){
				req.open(zAjaxData[obj.id].method,action,true);
				//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
				//req.setRequestHeader("TE","gzip,deflate;q=0.5");
				req.send("");  
			}else if(zAjaxData[obj.id].method.toLowerCase() === "post"){
				//alert('not implemented - use zForm() instead');
				req.open(zAjaxData[obj.id].method,action,true);
				req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");

				if(typeof obj.formId != "undefined"){
					var postObj=zGetFormDataByFormId(obj.formId);
					var postData="";
					for(var i in postObj){
						postData+=i+"="+encodeURIComponent(postObj[i])+"&";
					}
				}
				req.send(postData);  
			}
		}
	}
 


	function zEmailValidate(e){ 
  		var filter = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
		if (filter.test(e)) {
			return true;
		}else{
			return false;
		}
	}


	// makes it easier to fill out forms on a touchscreen device.
	function setupTouchFriendlyInputs(){ 
		if(!zIsTouchscreen()){
			return;
		}
		var selector=".zEnableMobileInputOKButton input, .zEnableMobileInputOKButton select, .zEnableMobileInputOKButton textarea";
		var $inputs=$(selector);

		function resizeMobileInput(){
			if(typeof currentInput == "boolean"){
				return;
			}
			setOKPosition(currentInput);
		}
		function setOKPosition(obj){ 
			var position=zGetAbsPosition(obj);  

			var leftPosition=position.x+position.width+2;
			if(zWindowSize.width-55 < leftPosition){
				leftPosition=zWindowSize.width-55;
			}
			$okButton.css({
				"left":(leftPosition)+"px",
				"top":(position.y)+"px",
				"display":"block"
			});
		}


		
		if($inputs.length){
			if($(".zMobileInputOKButton").length=='0'){
				$("body").append('<a href="#" class="zMobileInputOKButton">OK</a>');
			}
			var $okButton=$(".zMobileInputOKButton");
			$okButton.on("click", function(e){
				$(".zMobileInputOKButton").hide();
				currentInput=false;
			});
			$(document).on("keyup", selector, function(e){ 
			    if(e.which==13){
			    	e.preventDefault();
			    	e.stopImmediatePropagation();
			    	$(this).trigger("blur");
			    }
			});
			var currentInput=false;
			zArrResizeFunctions.push({functionName:resizeMobileInput});
			$(document).on("focus", selector, function(e){ 
				var target=this; 
				if(target.type == "radio" || target.type=="checkbox" || target.type=="select-multiple" || target.type=="select" || target.type=="select-one"){
					return;
				} 
				var position=zGetAbsPosition(target); 
				setOKPosition(target);
				currentInput=target;

				// TODO: get next input to focus on, and trigger focus
				// $('input[tabindex=7]')
				// var tabIndex=$(target).attr("tabindex"); 
				// $element=...
				// $element.trigger("focus");

			});
			$(document).on("blur", selector, function(e){
				$(".zMobileInputOKButton").hide();
				currentInput=false;
			});
		} 
	}
	zArrDeferredFunctions.push(setupTouchFriendlyInputs);
	
	function zFormSubmit(formName,validationOnly,onChange,debug, returnObject){	
		// validation for all fields...
		if(typeof zFormData[formName] === "undefined" || typeof zFormData[formName].arrFields === "undefined"){
			return;
		}
		if((validationOnly===null || !validationOnly) && onChange===false){
			if(zFormData[formName].submitContainer !== ""){
				var sc=document.getElementById(zFormData[formName].submitContainer);
				if(sc !== null){
					zFormData[formName].submitContainerBackup=sc.innerHTML;
					sc.innerHTML="Please wait...";
				}
			}
		}
		//addHistoryEvent();
		var arrQuery=new Array();
		var error=false;
		var anyError=false;
		var arrError=new Array();
		var obj=new Object();
		for(var i=0;i<zFormData[formName].arrFields.length;i++){
			error=false;
			var f=zFormData[formName].arrFields[i];
			if(typeof f === "undefined"){
				continue;
			}
			var value="";
			if(f.type === "file" && zFormData[formName].ajax){
				alert('File upload doesn\'t work with AJAX. Must use iframe and server-side progress bar (php for non-breaking uploads)');
				return false;
			}else if(f.type === "text" || f.type==="file" || f.type==="hidden"){
				var o=document.getElementById(f.id);
				value=o.value;
			}else if(f.type === "select"){
				var o=document.getElementById(f.id);
				if(typeof o.multiple !== "undefined" && o.multiple){
					for(var g=0;g<o.options.length;g++){
						if(o.options[g].selected){
							if(value.length !== 0){
								value+=",";
							}
							value+=o.options[g].value;
						}
					}
				}else{
					if(o.selectedIndex===-1){
						o.selectedIndex=0;
					}
					if(o.options[o.selectedIndex].value !== ""){
						value=o.options[o.selectedIndex].value;
					}
				}
			}else if(f.type === "radio"){
				var o=document.getElementById(f.id);
				var arrF=document[formName][f.id];
				for(var g=0;g<arrF.length;g++){
					if(arrF[g].checked){
						value=arrF[g].value;
					}
				}
			}else if(f.type === "checkbox"){
				var o=document.getElementById(f.id);
				if(o.checked){
					value=o.value;
				}
			}else if(f.type === "zExpandingBox"){
	            arrV=new Array();
	            for(var g=0;g<zExpArrMenuBox.length;g++){
	            	if(zExpArrMenuBox[g]===f.id){
			            var c=document.getElementById('zExpMenuBoxCount'+g).value;
	                    for(var n=0;n<c;n++){
	                    	var cr=document.getElementById('zExpMenuOption'+g+'_'+n);
	                        if(cr.checked){
	                        	arrV.push(cr.value);
	                        }
	                    }
	                }
	            }
	            value=arrV.join(",");
			}
			value=value.replace(/^\s+|\s+$/g,"");
			obj[f.id]=escape(value);
			arrQuery.push(f.id+"="+escape(value));
			if(value===""){
				if(f.allowNull !== null & f.allowNull){
					continue;
				}else if(f.required !== null && f.required){
					arrError.push(f.friendlyName+' is required.');
					zFormSetError(f.id,true);
					error=true;
					anyError=true;
					continue;
				}
			}
			if(f.number !== null & f.number){
				value2 = parseFloat(value);
				if(value !== value2){
					arrError.push(f.friendlyName+' must be a number.');
					zFormSetError(f.id,true);
					error=true;
					anyError=true;
					continue;
				}
			}
			if(f.email !== null & f.email){
				var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
				if (!filter.test(value)) {
					arrError.push(f.friendlyName+' must be a well formatted email address, (ex. johndoe@domain.com).');
					zFormSetError(f.id,true);
					error=true;
					anyError=true;
					continue;
				}
			}
			zFormSetError(f.id,false);
		}
		if(typeof returnObject !== "undefined" && returnObject){
			return obj;	
		}
		var queryString=arrQuery.join("&");
		var fm=document.getElementById("zFormMessage_"+formName);
		if(anyError){
			fm.innerHTML='<table style="width:100%;border-spacing:5px;"><tr><th>Please correct your entry and try again.</th></tr><tr><td>'+arrError.join("</td></tr><tr><td>")+'</td></tr></table>';
			fm.style.display="block";
			zFormData[formName].error=true;
		}else{
			zFormData[formName].error=false;
			fm.style.display="none";
		}
		if(validationOnly!==null && validationOnly){
			return false;
		}
		if(anyError){
			window.location.href='#anchor_'+formName;
			if(zFormData[formName].submitContainer !== ""){
				var sc=document.getElementById(zFormData[formName].submitContainer);
				if(sc !== null){
					sc.innerHTML=zFormData[formName].submitContainerBackup;
				}
			}
			return false;
		}
		// ignore double clicks / incomplete requests.
		if(zFormData[formName].ajax){
			if(zFormData[formName].ignoreOldRequests && zFormData[formName].ajaxStartCount !== zFormData[formName].ajaxEndCount){
				/*if(zFormData[formName].ajaxSuccess){
					// no new data needed
					//alert('already done');
				}*/
			}else{
				var req = null;  
				if(window.XMLHttpRequest){ 
				  req = new XMLHttpRequest();  
				}else if (window.ActiveXObject){ 
				  req = new ActiveXObject('Microsoft.XMLHTTP');  
				}
				zAjaxLastFormName=formName;
				zAjaxLastOnLoadCallback=zFormData[formName].onLoadCallback;
				zAjaxLastOnErrorCallback=zFormData[formName].onErrorCallback;
				//req.formName=formName;
				//req.onLoadCallback=zFormData[formName].onLoadCallback;
				//req.onErrorCallback=zFormData[formName].onErrorCallback;
				req.onreadystatechange = function(){  
					if(req.readyState === 4 || req.readyState === "complete" || (zMSIEBrowser!==-1 && zMSIEVersion<=7 && this.readyState==="loaded")){
						//alert(req.status+":complete"+req.responseText);
						if(typeof zFormData[zAjaxLastFormName] !== "undefined"){
							zFormData[zAjaxLastFormName].ajaxEndCount++;
							if(req.status === 200){
								zAjaxLastOnLoadCallback(req.responseText);
								//zFormData[zAjaxLastFormName].onLoadCallback(req.responseText);
								zFormData[zAjaxLastFormName].ajaxSuccess=true;
								if(zFormData[zAjaxLastFormName].successMessage !== false){
									var fm=document.getElementById("zFormMessage_"+zAjaxLastFormName);
									fm.style.display="block";
									fm.innerHTML='<div class="successBox">Form submitted successfully.<br />'+req.responseText+'</div>';
								}
							}else{ 
								zFormData[zAjaxLastFormName].ajaxStartCount=0;
								zFormData[zAjaxLastFormName].ajaxEndCount=0;
								zFormData[zAjaxLastFormName].ajaxSuccess = false;
								if(zFormData[zAjaxLastFormName].debug){
									document.write('AJAX SERVER ERROR - (Click back and refresh to continue):<br />'+req.responseText);
									//zAjaxLastOnLoadCallback(req.responseText);
								}else{
									zAjaxLastOnErrorCallback(req.status+": The server failed to process your request.\nPlease try again later.");
								}
							} 
							if(zFormData[zAjaxLastFormName].submitContainerBackup !== null && zFormData[zAjaxLastFormName].submitContainer !== ""){
								var sc=document.getElementById(zFormData[zAjaxLastFormName].submitContainer);
								if(sc !== null){
									sc.innerHTML=zFormData[zAjaxLastFormName].submitContainerBackup;
								}
							}
						}
					} 
				};		
				// reset the ajax request status variables
				zFormData[formName].ajaxSuccess=false;
				zFormData[formName].ajaxStartCount++;
				var randomNumber = Math.random()*1000;
				var action=zFormData[formName].action;
				
				var derrUrl="&zFPE=1";
				if(zFormData[formName].debug){
					derrUrl="";
				}
				if(zFormData[formName].method.toLowerCase() === "get"){
					if(action.indexOf("?") === -1){
						action+='?'+queryString+derrUrl+'&ztmp='+randomNumber;
					}else{
						action+='&'+queryString+derrUrl+'&ztmp='+randomNumber;
					}
					req.open(zFormData[formName].method,action,true);
					//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
					//req.setRequestHeader("TE","gzip,deflate;q=0.5");
					req.send("");  
				}else if(zFormData[formName].method.toLowerCase() === "post"){
					if(action.indexOf("?") === -1){
						action+=derrUrl+'&ztmp='+randomNumber;
					}else{
						action+=derrUrl+'&ztmp='+randomNumber;
					}
					queryString=encodeURI(queryString);
					req.open(zFormData[formName].method,action,true);
					// call open before sending headers
					//req.setRequestHeader("Accept-Encoding","gzip,deflate;q=0.5");
					//req.setRequestHeader("TE","gzip,deflate;q=0.5");
					req.setRequestHeader("Content-type", zFormData[formName].contentType);
					//req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
					req.send(queryString);  
				}
			}
			return false;
		}else{
			return true;
		}
	}


	function zInputSlideOnChange(oid,v1,v2,zExpValue){
		var d1=document.getElementById(oid);
		if(v1==="") v1="min";
		if(v2==="") v2="max";
		var newValue=v1+"-"+v2;
		if(newValue !== zInputSlideOldValue){
			d1.value=newValue;
			zInputSlideOldValue=newValue;
			if(zExpValue!==null){
				zExpOptionSetValue(zExpValue,newValue);
			}
			d1.onchange();
		}
	}

	function zSetSliderInputArray(id){
		if(typeof zArrSetSliderInputUniqueArray[id] === "undefined"){
			zArrSetSliderInputUniqueArray[id]=true;
			var d1=document.getElementById(id); 
			zArrSetSliderInputArray.push(d1);
		}
	}
	function zSliderInputResize(){
		for(var i=0;i<zArrSetSliderInputArray.length;i++){
			zArrSetSliderInputArray[i].onclick();
			zArrSetSliderInputArray[i].onblur();
		}
	}

	zArrResizeFunctions.push({functionName:zSliderInputResize});

	function zInputSliderSetValue(id, zV, zOff, v, zExpValue, sliderIndex){
		var d1=document.getElementById(id);
		var d2=document.getElementById(id+"_label");
		var f=false; 
		var alphaExp = /[^\+0-9\.]/;
		var v=d2.value;//zValues[zV+2];
		v=new String(v).split(",").join("").split("$").join("");
		if(v.match(alphaExp) && v!=="min" && v!=="max"){
			if(zV+3===zOff){
				v=zValues[zV+5];
			}else{
				v=zValues[zV+4];
			}
			d2.value=v; 
			f=true;
			alert('You may type only numbers 0-9.');
		} 
		if(v==="min" || v==="max"){
			return;
		} 
		var a1=zValues[zV];
		var lastV=a1[0];
		var curV=a1[0];
		var curPosition=0;
		var t1=document.getElementById("zInputSliderBox"+(zV-(sliderIndex-1)));
		var curPos=zGetAbsPosition(t1);
		var curSlider=document.getElementById("zInputDragBox"+sliderIndex+"_"+(zV-(sliderIndex-1)));
		var curValue=d2.value;
		curValue=parseFloat(curValue.split(",").join("").split("$").join(""));
		var found=false;
		for(var i=0;i<a1.length;i++){
			var curA=parseFloat(a1[i].split(",").join("").split("$").join(""));
			if(curValue < curA){
				if(i>0){
					found=true;
					var tempLastV=parseFloat(lastV.split(",").join("").split("$").join(""));
					// somewhere between lastV and curV
					curPosition=(i+((curValue-tempLastV)/(curA-tempLastV)));
				}
				break;
			}
			lastV=a1[i];
		} 
		if(!found){
			curPosition=a1.length;	
		}
		
		d2.value=v;
		v=parseFloat(v); 
		/*if(zV+2===zOff){
			if(parseFloat(zValues[zV+1])>parseFloat(v)){
				v=zValues[zV+2];
				if(d1.value===""){
					if(sliderIndex===2){
						d2.value=zValues[zV+3];
					}else{
						d2.value=zValues[zV+2];
					}
				}else{
					d2.value=d1.value;//zValues[zV+5];
				}
				alert('The first value must be smaller than the second value. Your data has been reset..');
				return;
			}
		}else{
			if(parseFloat(v)>parseFloat(zValues[zV+2])){
				v=zValues[zV+2];
				if(d1.value===""){
					if(sliderIndex===2){
						d2.value=zValues[zV+2];
					}else{
						d2.value=zValues[zV+1];
					}
				}else{
					d2.value=d1.value;//zValues[zV+4];
				}
				alert('The first value must be smaller than the second value. Your data has been reset...');
				return;
			}
		}*/
		// get width of the bar
		var tWidth=curPos.width-20;
		var newSliderPos=Math.round((curPosition/(a1.length))*tWidth);
		if(typeof curSlider != "undefined"){
			if(sliderIndex === 2){
				curSlider.style.marginRight=(tWidth-newSliderPos)+"px";
			}else{
				curSlider.style.marginLeft=newSliderPos+"px";
			}
		}
		d1.value=v;
		zValues[zOff]=v;
		var zOff9=(zV-(sliderIndex-1));
		zInputSlideOnChange('zInputHiddenValues'+(zV-(sliderIndex-1)),zValues[zOff9+2],zValues[zOff9+3],zExpValue);
	}

	function zInputSlideLimit(obj,paramObj,forceOnChange){
		var dd1=document.getElementById(paramObj.valueId);
		var dd2=document.getElementById(paramObj.labelId);
		var firstLoad=false;
		if(zDrag_dragObject===null){
			firstLoad=true;
			if(dd2.value===""){
				if(paramObj.constrainLeft){
					dd2.value="max";
					dd1.value="";
				}else{
					dd2.value="min";
					dd1.value="";
				}
			}
		}
		// if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){ - need to double or halve the value to force this to work on IE 6.
		if(!firstLoad){
			var rightSlider=false;
			if(paramObj.zValue+3===paramObj.zValueValue){
				rightSlider=true;
			}
			var d1=zDrag_getPosition(obj);
			var d2=document.getElementById("zInputSliderBox"+paramObj.zValue);
			var d2pos=zGetAbsPosition(d2);
			var d3=zDrag_getPosition(d2);
			if(paramObj.constrainObj){
				var sw=parseInt(d2pos.width)-parseInt(obj.style.width);
			}else{
				var sw=parseInt(d2pos.width);
			}
			var dw=parseInt(obj.style.width);
			if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
				dw/=2;
				sw/=2;
			}
			var y=d3.y;
			if(rightSlider){
				var x=parseInt(obj.style.marginRight);
			}else{
				var x=parseInt(obj.style.marginLeft);
			}
			var first=false;
			var last=false;
			if(paramObj.constrainObj){
				var d4=document.getElementById(paramObj.constrainObj);
				d4.style.zIndex=1;
				obj.style.zIndex=3;
				if(rightSlider){
					var dx=sw-(dw+parseInt(d4.style.marginLeft));
				}else{
					var dx=sw-(dw+parseInt(d4.style.marginRight));
				}
				var d5=zDrag_getPosition(d4);
				if(paramObj.constrainLeft){
					if(x>=dx){
						x=dx;
						if(x>=sw-dw){
							first=true;
						}
					}else if(x<=0){
						x=0;
						if(x<=0){
							last=true;
						}
					}
				}else{
					var sw2=dx-0;
					if(x<=0){
						x=0;
						first=true;
					}else if(x>=dx){
						x=dx;
						if(x+dw>=0+sw){
							last=true;
						}
					}
				}
			}else{
				if(x<=0){
					x=0;
					first=true;
				}else if(x+dw>=0+sw){
					x=((0+sw)-dw);
					last=true;
				}
			}
			var percent=0;
			if(paramObj.zValue+3===paramObj.zValueValue){
				obj.style.marginRight=x+"px";
				x=sw-(x+dw);
				percent=Math.max(0,(x)/(sw-dw));
			}else{
				obj.style.marginLeft=x+"px";
				percent=Math.min(1,Math.max(0,(x)/(sw-dw)));
			}
			var arrLabel=zValues[paramObj.zValue];
			var arrValue=zValues[paramObj.zValue+1];
			var offset=Math.min(arrLabel.length-1,Math.round(percent*(arrLabel.length-0.5)));
			if(first){
				dd1.value="";
				dd2.value="min";
			}else if(last){
				dd1.value="";
				dd2.value="max";
			}else{
				dd1.value=arrValue[offset];
				dd2.value=arrLabel[offset];
			}
			zValues[paramObj.zValueLabel]=dd2.value;
			zValues[paramObj.zValueValue]=dd1.value;
		}
		if(forceOnChange!==null && forceOnChange){
			zInputSlideOnChange('zInputHiddenValues'+paramObj.zValue,zValues[paramObj.zValue+2],zValues[paramObj.zValue+3],paramObj.zExpOptionValue);
		}
	}

	function zExpOptionSetValue(i,v,h){
		var d1=document.getElementById('zExpOption'+i+'_button');
		if(h===null || typeof h == "undefined") h="none"; 
		if(d1!==null) d1.innerHTML=zExpOptionLabelHTML[i]+" <span id=\"zExpOption"+i+"_value\" style=\"display:"+h+";\">"+zStringReplaceAll(v,",",", ")+"</span>";
	}

	function zCheckboxOnChange(obj,zv){
		var running=true;
		var n=0;
		var arrV=[];
		var arrL=[];
		while(running){
			n++;
			var d2=document.getElementById(obj.name+"label"+n);
			if(d2===null) break;
			var d1=document.getElementById(obj.name+n);
			if(d1.checked){
				arrL.push(d2.innerHTML);
				arrV.push(d1.value);
			}
		}
		var dn=obj.name.substr(0,obj.name.length-5);
		var d1=document.getElementById(dn);
		d1.value=arrV.join(",");
		if(zv!==-1){
			zExpOptionSetValue(zv,"<br />"+arrL.join("<br />"));
		}
		if(d1.onchange != null){
			d1.onchange();
		}
	}



	function zMotionOnMouseDown(objname){
		zMotionObjClicked=objname;
		return false;
	}
	function zMotiontoggleSlide(objname, label, hoc){
		zMotionLabel[objname]=document.getElementById(label);
		if(hoc!==""){
			zMotionHOC[objname]=document.getElementById(hoc);
		}else{
			zMotionHOC[objname]="";	
		}
		if(zMotionObjClicked!==objname) return;
		if(document.getElementById(objname).style.display === "none"){
			zMotionHOC[objname].style.display="none";
			zMotionslidedown(objname);
		}else{
			zMotionslideup(objname);
		}
	}
	function zMotionslidedown(objname){
		if(zMotionmoving[objname])
				return;

		if(document.getElementById(objname).style.display !== "none")
				return; // cannot slide down something that is already visible

		zMotionmoving[objname] = true;
		zMotiondir[objname] = "down";
		zMotionstartslide(objname);
	}

	function zMotionslideup(objname){
		if(zMotionmoving[objname])
				return;

		if(document.getElementById(objname).style.display === "none")
				return; // cannot slide up something that is already hidden

		zMotionmoving[objname] = true;
		zMotiondir[objname] = "up";
		zMotionstartslide(objname);
	}

	function zMotionstartslide(objname){
		zMotionobj[objname] = document.getElementById(objname);

		zMotionendHeight[objname] = parseInt(zMotionobj[objname].style.height);
		zMotionstartTime[objname] = (new Date()).getTime();

		if(zMotiondir[objname] === "down"){
			zMotionobj[objname].style.height = "1px";
		}
		zMotionobj[objname].style.overflow="hidden";
		zMotionobj[objname].style.display = "block";
		zMotiontimerID[objname] = setInterval('zMotionslidetick("' + objname + '");',zMotiontimerlen);
	}

	function zMotionslidetick(objname){
		var elapsed = (new Date()).getTime() - zMotionstartTime[objname];
		if (elapsed > zMotionslideAniLen){
			zMotionendSlide(objname);
		}else{
			var d =Math.round(elapsed / zMotionslideAniLen * zMotionendHeight[objname]);
			if(zMotiondir[objname] === "up") d = zMotionendHeight[objname] - d;
			zMotionobj[objname].style.height = d + "px";
		}
	}

	function zMotionendSlide(objname){
		clearInterval(zMotiontimerID[objname]);

		if(zMotiondir[objname] === "up"){
			zMotionobj[objname].style.display = "none";
			zMotionHOC[objname].style.display="inline";
		}else{
			zMotionobj[objname].style.overflow="auto";
		}
		zMotionobj[objname].style.height = zMotionendHeight[objname] + "px";

		delete(zMotionHOC[objname]);
		delete(zMotionLabel[objname]);
		delete(zMotionmoving[objname]);
		delete(zMotiontimerID[objname]);
		delete(zMotionstartTime[objname]);
		delete(zMotionendHeight[objname]);
		delete(zMotionobj[objname]);
		delete(zMotiondir[objname]);

		return;
	}

	function zCLink(d){d.href='#';}
	function zSetInput(id,v){
		var d=document.getElementById(id);d.value=v;
		if(d.onchange!==null){
			d.onchange();
		}
	}
	function zFormOnEnterAdd(id,d){
		zFormOnEnterValues[id]=d;
	}
	function zFormOnEnter(e,obj){
		if(zFormOnEnterValues[obj.id]!==null){
			if(e===null){
				eval(zFormOnEnterValues[obj.id]);
			}else{
				if(window.event){
					var keynum= e.keyCode;
				}else{
					var keynum = e.which;
				}
				if(keynum===13){
					eval(zFormOnEnterValues[obj.id]);
				}
			}
		}
	}
	function zInputRemoveOption(id,zOffset){
	    var ab=new Array();
	    var ab2=new Array();
	    var ab3=new Array();
	    for(var i=0;i<zValues[zOffset].length;i++){
	        if(id!==i){ 
				ab.push(zValues[zOffset+1][i]); ab2.push(zValues[zOffset][i]); ab3.push(zValues[zOffset+2][i]); 
			}else{
				if(zValues[zOffset+2][i] !== "" && zValues[zOffset+6] === false){
					var d=document.getElementById(zValues[zOffset+2][i]);
					d.style.display="block";
				}
			}
	    }
	    zValues[zOffset+2]=ab3;
	    zValues[zOffset+1]=ab;
	    zValues[zOffset]=ab2;
		var ofield=document.getElementById(zValues[zOffset+4]);
		var ofieldlabel=document.getElementById(zValues[zOffset+4]+"_zlabel");
		ofield.value=zValues[zOffset+1].join(",");
		ofieldlabel.value=zValues[zOffset].join(",");
		if(ofield.type !== "select-one" && ofield.onchange!==null){
			ofield.onchange();
		}
	    zInputSetSelectedOptions(false,zOffset);
		if(ofield.type === "select-one"){
			ofield.selectedIndex=0;	
		}
	}
	function zHasInnerText(){
		return (document.getElementsByTagName("body")[0].innerText !== "undefined") ? true : false;	
	}


	function zInputSetSelectedOptions(checkField,zOffset,fieldName,linkId,allowAnyText,onlyOneSelection){
		if(checkField){
			var ofield=document.getElementById(fieldName);
			var ofieldlabel=document.getElementById(fieldName+"_zlabel");
			var ofL=document.getElementById(fieldName+"_zmanual");
			var ofV=document.getElementById(fieldName+"_zmanualv");
			var cid=ofV.value;
			var cname=ofL.value;
			var obj=ofL;
			var it=zHasInnerText() ? obj.innerText : obj.textContent;
			if(zValues[zOffset+6]===true && zValues[zOffset+1].length>0 && cname!==""){
				alert('Only one value can be selected for this field');
				ofV.value="";
				ofL.value="";
				return;	
			}
			if(allowAnyText && cname!==""){
				// ignore
			}else if(cid==="0"){
			    alert('Please make a selection before clicking the add button.');
			    return;
			}else if(cname===""){
				return;	
			}
			for(var i=0;i<zValues[zOffset].length;i++){
				if(zValues[zOffset+1][i] === cid){// && zValues[zOffset][i]==cname){
					alert('The option, '+zValues[zOffset][i]+', has already been selected.');
					return;
				}
			}
			// loop links here with the zOffset
			for(var i=0;i<zValues[zOffset+3].length;i++){
				if(zValues[zOffset+3][i] === cid){
					linkId="zInputLinkBox"+zOffset+"_link"+(i+1);
					var d1=document.getElementById(linkId);
					d1.style.display="none";
					break;
				}
			}
			if(!allowAnyText && cid===cname){
				alert('Only valid entries are accepted. Please type an entry that appears in the suggestion box and than select it or press enter.');
				return;
			}
			ofV.value="";
			ofL.value="";
			if(linkId===null) linkId="";
			zValues[zOffset+2].push(linkId);
			zValues[zOffset+1].push(cid);
			zValues[zOffset].push(cname);
			ofield.value=zValues[zOffset+1].join(",");
			ofieldlabel.value=zValues[zOffset].join(",");
			if(ofield.onchange!==null){
				ofield.onchange();
			}
			var arrM=[];
			for(var i=0;i<zValues[zOffset].length;i++){
				arrM[zValues[zOffset][i]]=i;
			}
			zValues[zOffset].sort();
			var arrN=[];
			var arrN2=[];
			for(var i=0;i<zValues[zOffset].length;i++){
				arrN[i]=zValues[zOffset+1][arrM[zValues[zOffset][i]]];
				arrN2[i]=zValues[zOffset+2][arrM[zValues[zOffset][i]]];
			}
			zValues[zOffset+1]=arrN;
			zValues[zOffset+2]=arrN2;
		}
		zExpOptionSetValue(zValues[zOffset+5],"<br />"+zValues[zOffset].join("<br />"));
		var cb=document.getElementById("zInputOptionBlock"+zOffset);
		var arrBlock2=new Array();
		if(zValues[zOffset].length!==0){
			arrBlock2.push('<div class="zInputLinkBoxSelected"><div class="zInputLinkBoxSelectedHead">SELECTED VALUES:<br /><span style="font-weight:normal">Click X to remove a value.</span></div>');
			for(var i=0;i<zValues[zOffset].length;i++){
				var s='zInputLinkBoxRow1';
				if(i%2===0){
					s="zInputLinkBoxRow2";
				}
				if(zValues[zOffset+2][i] !== ""){
					var d1=document.getElementById(zValues[zOffset+2][i]);
					if(d1){
						d1.style.display="none";
					}
				}
				arrBlock2.push('<div style="float:left;width:100%;" class="'+s+'"><a href="javascript:zInputRemoveOption('+(arrBlock2.length-1)+','+zOffset+');" style="float:left;text-decoration:none;display:block;" class="zInputLinkBoxSItem '+s+'"><span title="Click the X to remove this option." class="zTOB-closeBox">X</span>'+zValues[zOffset][i]+'</a></div>');
			}
			arrBlock2.push('</div><br style="clear:both;" />');
		}
		cb.innerHTML=arrBlock2.join('');
		if(arrBlock2.length===0){
			cb.style.display="inline";
		}else{
			cb.style.display="block";
		}
	}


	function zOS_mode_check(){
		if(document.zOS_mode_form.zOS_modeVarDumpName){
			if(document.zOS_mode_form.zOS_modeVarDumpName.value.length !== 0){
				document.zOS_mode_form.zOS_mode.value = 'varDump';
				document.zOS_mode_form.zOS_modeValue.value = 'true';					
			}
		}
		return true;
	}
	function zOS_mode_submit(mode, value, value2, value3){
		var theform=document.getElementById("zOS_mode_form");
		var theaction=theform.getAttribute("action"); 
		if(typeof value3 === "undefined"){ value3=""; }
		document.getElementById("zOS_mode").setAttribute("value", mode);
		document.getElementById("zOS_modeValue").setAttribute("value", value);
		if(mode === 'viewAsXML'){
			theaction=zURLAppend(theaction, 'zOS_viewAsXML=1'+value3);
		}
		if(mode === 'validateXHTML' && value2 !== "undefined"){
			theaction=zURLAppend(theaction, 'zOS_viewXHTMLError=1'+value3);
		}
		if(mode === 'reset'){
			theaction=zURLAppend(theaction, 'zReset='+value2+value3);
		}
		theform.setAttribute("action", theaction);
		theform.submit();
	}
	function zOS_mode_status(){
		window.status = 'Warning: All variables will be reposted.';
	}
	function zOS_mode_status_off(){
		window.status = '';
	}
	function zOS_mode_hide(){
		var el = document.getElementById("zOS_mode_table_tag");
		el.style.display='none';
	}
	function zOS_mode_show(){
		var el = document.getElementById("zOS_mode_table_tag");
		el.style.display='block';
	}

	zArrDeferredFunctions.push(function(){
		$(".zEditReadOnly").bind("click", function(){
			var id=$(this).attr("data-fieldid");
			var id2=$(this).attr("data-readonlyid");
			$("#"+id).removeClass("zHideReadOnlyField");
			$("#"+id2).hide();
			alert('Warning: Changing read only values may cause things to break, or your changes may be overwritten during a future import process.');
			return false;
		});
	});




	function zCalculateTableCells(table){
		var max = 0;
		for(var i=0;i<table.rows.length;i++) {
			if(max < table.rows[i].cells.length){
				max = table.rows[i].cells.length;
			}
		}
		return max;
	}
	var zRowBeingEdited=false;
	var zBodyBeingEdited=false;
	var zBodyInsertPosition="bottom";
	var zRowEditIndex=0;
	function zTableRecordAdd(obj, id, position){
		// store table body 
		if(typeof position == "undefined"){
			position="bottom";
		}
		zBodyInsertPosition=position;
		try{
			zShowModalStandard(obj.href, 2000,2000, true, true);
			zCurrentHash="#zAddTableRecord"+new Date().getTime()+"-"+Math.random();
			window.location.href=zCurrentHash;
			zBodyBeingEdited=window.parent.$("#"+id+" tbody");  
			if(zBodyBeingEdited.length==0){
				//alert('Invalid table html structure, tbody missing.');
				zBodyBeingEdited=false;
			} 
		}catch(e){
			console.log('error in zTableRecordAdd');
			console.log(e);
		}
	}
	function zTableRecordEdit(obj){
		zShowModalStandard(obj.href, 2000,2000, true, true);
		zRowEditIndex++;
		zCurrentHash="#zEditTableRecord"+zRowEditIndex+"-"+new Date().getTime()+"-"+Math.random();
		window.location.href=zCurrentHash;
		var i=0;
		while(true){
			i++;
			if(obj.tagName.toLowerCase() == 'tr'){ 
				break;
			}
			obj=obj.parentNode;
			if(i > 50){
				alert('infinite loop. invalid table html structure');
				return false;
			}
		}
		zRowBeingEdited=obj;
	}
	function zAddTableRecordRow(id, html){  
		if(typeof zBodyBeingEdited == "boolean"){
			window.location.reload();
			return;
		} 
		var s='<tr id="newSortRowTable_row'+id+'" data-ztable-sort-primary-key-id="'+id+'">'+html+'</tr>';
		if(zBodyInsertPosition == "bottom"){
			zBodyBeingEdited.append(s); 
		}else{
			zBodyBeingEdited.prepend(s); 
		}
		zBodyBeingEdited=false;
		zSetupAjaxTableSortAgain();
	}
	function zReplaceTableRecordRow(html){
		$(zRowBeingEdited).html(html); 
		zRowBeingEdited=false;
	}
	function zDeleteTableRecordRow(obj, deleteLink){
		var tr, table;
		var i=0;
		while(true){
			i++;
			if(obj.tagName.toLowerCase() == 'tr'){
				tr=obj;
			}else if(obj.tagName.toLowerCase() == 'table'){
				table=obj;
				break;
			}
			obj=obj.parentNode;
			if(i > 50){
				alert('infinite loop. invalid table html structure');
				return false;
			}
		}
		var cellCount=zCalculateTableCells(table);

		$("td", tr).css("border-top", "2px solid #900");
		$("td", tr).css("border-bottom", "2px solid #900");
		$("td", tr).css("background-color", "#FFF0F0");
		var r=confirm("Are you sure you want to delete this record?");
		$("td", tr).css("border-top", "0px solid #CCC");
		$("td", tr).css("border-bottom", "1px solid #CCC");
		$("td", tr).css("background-color", "inherit");
		if(r){
			var obj={
				id:"ajaxDeleteTableRecord",
				method:"get",
				ignoreOldRequests:true,
				callback:function(r){
					r=eval('('+r+')');
					if(r.success){
						$(tr).html('<td class="zDeletedRow" colspan="'+cellCount+'">Row Deleted</td>');
						zSetupAjaxTableSortAgain();
					}else{
						alert('Failed to delete the record. Error: '+r.errorMessage);
					}

				},
				errorCallback:function(r){
					alert('Failed to delete the record. Unknown error');
				},
				url:deleteLink
			}; 
			zAjax(obj);
		}
		return false;
		
	}
 

	(function(){
		// prevent losing work when navigating away from a page, except when submitting a form.
		var ignoreDirtyCheck=false;
		var formDataCache={};  
		var unloadCalled=false;
		var formDirtyTempCache={};
		function zIsFormDirty(id){ 
			var form=document.getElementById(id);
			zCheckFormDataForChangesByObj(form);
			if(typeof formDirtyTempCache[id] != "undefined"){
				delete formDirtyTempCache[id]; 
				return true;
			}else{
				return false;
			}
		}
		function zCheckFormDataForChangesByObj(obj){ 
			if(obj.id == "" || typeof formDataCache[obj.id] == "undefined"){
				return true;
			}
			var cachedData=formDataCache[obj.id];
			var newData=zGetFormDataByFormId(obj.id);
			var changed=false;
			for(var i in cachedData){
				if(typeof newData[i]== "undefined"){
					changed=true;
					break;
				}else if(newData[i] != cachedData[i]){
					changed=true;
					break;
				}
			}
			for(var i in newData){
				if(typeof cachedData[i]== "undefined"){
					changed=true;
					break;
				}
			} 
			if(changed){
				formDirtyTempCache[obj.id]=true;
				formDataCache[obj.id]=newData;
				zSetDirty(true);
			}
			return true; 
		}
		function zCheckFormDataForChanges(){ 
			$(".zFormCheckDirty").each(function(e){
				return zCheckFormDataForChangesByObj(this);
			});
		} 
		$(window).bind("hashchange", function() {

			if (window.location.hash.indexOf(zCurrentHash) == -1){ 
				var iframe=document.getElementById(window.zCurrentModalIframeId);
				if(iframe){
					iframe.contentWindow.zCheckFormDataForChanges(); 
					if(!iframe.contentWindow.zIsDirty || zConfirmCloseModal()){
						zCloseModal();
					}else{
						window.location.href+=zCurrentHash;
					}
				}
			}else{

			}
		});
		$(window).bind("beforeunload", function(e){
			zCheckFormDataForChanges(); 
			if(!zIsDirty || ignoreDirtyCheck){
				return;
			}  
			if(unloadCalled){
				return;
			}
			if(e.target && e.target.activeElement && e.target.activeElement.href && e.target.activeElement.href.indexOf("mailto:") != -1){
				return;
			}
			unloadCalled=true;
			setTimeout(function(){
				unloadCalled=false;
			}, 10);
			e.preventDefault();
		    return false;
		});

		zArrDeferredFunctions.push(function(){
			var formIndex=1;
			$(".zFormCheckDirty").each(function(){
				if(this.id == ""){
					this.id="zFormUniqueId"+formIndex;
					formIndex++;
				}
				formDataCache[this.id]=zGetFormDataByFormId(this.id);
			});
			$(".zFormCheckDirty").bind("submit",function(e){
				if(typeof formDirtyTempCache[this.id] != "undefined"){
					delete formDirtyTempCache[this.id];
				}
				formDataCache[this.id]={};
				ignoreDirtyCheck=true;
			});
		});

		

		function zConfirmCloseModal(){
			var r=window.confirm("Do you want to leave this page?\n\nChanges you made may not be saved.");
			if(r){ 
				return true;
			}
			return false;
		}
		function zSetDirty(value){ 
			if(value){
				zIsDirty=value; 
			}else{ 
				zIsDirty=value;
			}
		}
		window.zCheckFormDataForChanges=zCheckFormDataForChanges;
		window.zConfirmCloseModal=zConfirmCloseModal; 
		window.zSetDirty=zSetDirty;
		window.zIsFormDirty=zIsFormDirty;
	})();  




	function zSubmitManagerEditForm(obj, customCallback){
		if(typeof tinyMCE != "undefined"){
			tinyMCE.triggerSave();
		}
		if(typeof obj.checkValidity != "undefined" && !obj.checkValidity()){
			return false;
		}
		$(".zSiteOptionGroupWaitDiv").show();
		$(".zSiteOptionGroupSubmitButton").hide();
		var tempObj={};
		tempObj.formId=obj.id;
		var form=document.getElementById(tempObj.formId);
		tempObj.id=obj.id;
		tempObj.url=form.action;
		tempObj.method="POST";
		tempObj.callback=function(r){ 
			var r=JSON.parse(r);
			if(r.success){
				if(typeof customCallback != "undefined"){
					customCallback(r);
					return;
				}
				//alert(r.reload + " " + r.redirect)
				if(typeof r.reload != "undefined" && r.reload){
					window.parent.location.reload();
				}else if(typeof r.redirectFrame != "undefined" && r.redirectFrame){
					window.location.href=r.redirectLink;
				}else if(typeof r.redirect != "undefined" && r.redirect){
					window.parent.location.href=r.redirectLink;
				}else{
					if(r.newRecord){ 
						window.parent.zAddTableRecordRow(r.id, r.rowHTML);
					}else{
						window.parent.zReplaceTableRecordRow(r.rowHTML);
					}
					window.parent.zCloseModal();
				}
			}else{
				zResetManagerTabEdit();
				$(".z-manager-edit-errors").html(r.errorMessage);
				window.scrollTo(0,0);
			}
		};
		tempObj.errorCallback=function(resp){
			$(".z-manager-edit-errors").html('<div style="background-color:#900; color:#FFF; padding:10px; float:left; width:100%;">Sorry, there was a problem with your submission, please try again later.</div>');
			zResetManagerTabEdit();
			window.scrollTo(0,0);
		};
		tempObj.cache=false; // set to true to disable ajax request when already downloaded same URL
		tempObj.ignoreOldRequests=true; // causes only the most recent request to have its callback function called.
		zAjax(tempObj);

		return false;
	}
 
	window.htmlEntities = {
		encode : function(str) {
			var buf = [];
			
			for (var i=str.length-1;i>=0;i--) {
				buf.unshift(['&#', str[i].charCodeAt(), ';'].join(''));
			}
			
			return buf.join('');
		},
		decode : function(str) {
			return str.replace(/&#(\d+);/g, function(match, dec) {
				return String.fromCharCode(dec);
			});
		}
	}; 

	zArrDeferredFunctions.push(function(){
		$(document).on("click", ".zMapPickerButton", function(e){
			e.preventDefault();
			var field=$(this).attr("data-map-field");
			var address=zMapPickerGetAddress(this); 
			var c=$('#'+this.id).val(); 
			address=zStringReplaceAll(address, '-- Select --', ''); 
			address=zStringReplaceAll(address, ', , ', ', '); 
			zShowModalStandard('/z/misc/map/modalMarkerPicker?field='+encodeURIComponent(field)+'&coordinates='+c+'&address='+encodeURIComponent(address), 4000,4000, 10);
		});
	});
	function zMapPickerGetAddress(obj){
		var address=document.getElementById($(obj).attr("data-map-address"));
		var city=document.getElementById($(obj).attr("data-map-city"));
		var state=document.getElementById($(obj).attr("data-map-state"));
		var zip=document.getElementById($(obj).attr("data-map-zip"));
		var country=document.getElementById($(obj).attr("data-map-country"));
		
		var arrField=[address, city, state, zip, country];
		var arrAddress=[];
		for(var i=0;i<arrField.length;i++){
			var d=arrField[i];
			var v="";
			if(d != null && typeof d != "undefined"){
				if(d.type == "select-one"){
					if(d.options[d.selectedIndex].text !=""){
						v=d.options[d.selectedIndex].text;
					}
				}else if(d.type == "text"){
					v=d.value;
				}
			}
			if(v != ""){
				if(arrAddress.length){
					arrAddress.push(", "+v);
				}else{
					arrAddress.push(v);
				}
			}
		}
		return arrAddress.join(" ");
		
	}


	var zEmailTokenInput={};
	zEmailTokenInput.setupTokenizeInput=function(field){ 
		var $field=$('#'+field);
		$field.keypress(function(e) { 
			// detect ENTER key 
			if (e.keyCode == 13) { 
				e.stopImmediatePropagation();
				e.preventDefault();
				return false;
			}
		});
		$field.attr( 'multiple', 'multiple' );
		$field.tokenize2( {
			dataSource: 'select',
			searchFromStart: false,
			tokensAllowCustom: true
		} );
		$field.on("tokenize:tokens:add", function(e, token){
			zEmailTokenInput.preventInvalidToken(this, e, token, field); 
		}); 
		$(document).on("keyup paste", "#"+field+"_container .token-search input", function(){ 
			zEmailTokenInput.forceSetEmail(this, "#"+field, false);
		}); 
		$(document).on("blur", "#"+field+"_container .token-search input", function(){  
			zEmailTokenInput.forceSetEmail(this, "#"+field, true);
		}); 
	}
	zEmailTokenInput.preventInvalidToken=function(obj, e, token, field){
		var arrToken=token.split("`");
		var email=arrToken.pop().trim();
		if(!zEmailValidate(email)){ 
			$(obj).trigger('tokenize:tokens:remove', [token]);    
			// add it back as text to avoid frustration
			$("#"+field+"_container .token-search input").val(token);
			var h="";
			// tracking whether to append or not
			if(obj.lastActionCount!=obj.currentActionCount){
				h=$("#"+field+"_error").html();
			} 
			obj.lastActionCount++;
			if(h !=""){
				h+=", ";
			} 
			h+='"'+token+'" is not a valid email address';
			$("#"+field+"_error").show().html(h);
		}
	}

	zEmailTokenInput.forceSetEmail=function(obj, f, triggerAdd){
		var fieldElement=$(f)[0];
		if(typeof fieldElement.lastActionCount == "undefined"){
			fieldElement.lastActionCount=0;
			fieldElement.currentActionCount=0;
		}
		fieldElement.lastActionCount++;
		fieldElement.currentActionCount=fieldElement.lastActionCount; 
		if(obj.value != ""){
			/*if(!zEmailValidate(obj.value.trim())){
				$(f+"_error").show().html('"'+obj.value+'", is not a valid email address.');
				return false;
			}*/
			//$(f+"_error").hide();
			if(triggerAdd){
				$(f).trigger('tokenize:tokens:add', [obj.value, obj.value, true]);
				obj.value="";
			}
		}
		return true;
	} 
	window.zEmailTokenInput=zEmailTokenInput;  
	window.zSubmitManagerEditForm=zSubmitManagerEditForm;
	window.zCalculateTableCells=zCalculateTableCells;
	window.zTableRecordEdit=zTableRecordEdit;
	window.zTableRecordAdd=zTableRecordAdd;
	window.zAddTableRecordRow=zAddTableRecordRow;
	window.zReplaceTableRecordRow=zReplaceTableRecordRow;
	window.zDeleteTableRecordRow=zDeleteTableRecordRow;
	window.zUpdateImageLibraryCount=zUpdateImageLibraryCount;
	window.ajaxSaveSorting=ajaxSaveSorting;
	window.ajaxSaveImage=ajaxSaveImage;
	window.toggleImageCaptionUpdate=toggleImageCaptionUpdate;
	window.confirmDeleteImageId=confirmDeleteImageId;
	window.deleteImageId=deleteImageId;
	window.setUploadField=setUploadField;
	window.zOptionGroupErrorCallback=zOptionGroupErrorCallback;
	window.zOptionGroupCallback=zOptionGroupCallback;
	window.zOptionGroupPostForm=zOptionGroupPostForm;
	window.zSetupAjaxTableSort=zSetupAjaxTableSort;
	window.zGetFormDataByFormId=zGetFormDataByFormId;
	window.zGetFormFieldDataById=zGetFormFieldDataById;
	window.zDisableEnter=zDisableEnter;
	window.zKeyboardEvent=zKeyboardEvent;
	window.zInputHideDiv=zInputHideDiv;
	window.zFormOnKeyUp=zFormOnKeyUp;
	window.zFormOnChange=zFormOnChange;
	window.zFormSetError=zFormSetError;
	window.zAjax=zAjax;
	window.zFormSubmit=zFormSubmit;
	window.zInputSlideOnChange=zInputSlideOnChange;
	window.zSetSliderInputArray=zSetSliderInputArray;
	window.zSliderInputResize=zSliderInputResize;
	window.zInputSliderSetValue=zInputSliderSetValue;
	window.zInputSlideLimit=zInputSlideLimit;
	window.zExpOptionSetValue=zExpOptionSetValue;
	window.zCheckboxOnChange=zCheckboxOnChange;
	window.zMotionOnMouseDown=zMotionOnMouseDown;
	window.zMotiontoggleSlide=zMotiontoggleSlide;
	window.zMotionslidedown=zMotionslidedown;
	window.zMotionslideup=zMotionslideup;
	window.zMotionstartslide=zMotionstartslide;
	window.zMotionslidetick=zMotionslidetick;
	window.zMotionendSlide=zMotionendSlide;
	window.zCLink=zCLink;
	window.zSetInput=zSetInput;
	window.zFormOnEnterAdd=zFormOnEnterAdd;
	window.zFormOnEnter=zFormOnEnter;
	window.zInputRemoveOption=zInputRemoveOption;
	window.zHasInnerText=zHasInnerText;
	window.zInputSetSelectedOptions=zInputSetSelectedOptions;
	window.zOS_mode_check=zOS_mode_check;
	window.zOS_mode_submit=zOS_mode_submit;
	window.zOS_mode_status=zOS_mode_status;
	window.zOS_mode_status_off=zOS_mode_status_off;
	window.zOS_mode_hide=zOS_mode_hide;
	window.zOS_mode_show=zOS_mode_show;
	window.zEmailValidate=zEmailValidate;
	window.zResetManagerTabEdit=zResetManagerTabEdit;
	window.zSetupAjaxTableSortAgain=zSetupAjaxTableSortAgain;

})(jQuery, window, document, "undefined"); 