
function zClearSelection() {
    if(document.selection && document.selection.empty) {
        document.selection.empty();
    } else if(window.getSelection) {
        var sel = window.getSelection();
        sel.removeAllRanges();
    }
}
function zConvertSliderToSquareMeters(id1,id2, force){
	if(!force){
		setTimeout(function(){zConvertSliderToSquareMeters(id1,id2, true);},1);
		return;
	}
	var d0=document.getElementById("search_sqfoot_low_zvalue");
	if(d0===null) return;
	var d1=document.getElementById("zInputSliderBottomBox_"+d0.value);
	var f1=document.getElementById(id1);
	var f2=document.getElementById(id2);
	var sm1="";
	var sm2="";
	if(f1.value !== ""){
		var f1_2=parseInt(f1.value);
		if(!isNaN(f1_2)){
			sm1=Math.round(f1_2/10.7639);
		}
	}
	if(f2.value !== ""){
		var f2_2=parseInt(f2.value);
		if(!isNaN(f2_2)){
			sm2=Math.round(f2_2/10.7639);
		}
	}
	d1.innerHTML='<div style="width:50%; float:left; text-align:left;">'+sm1+'m&#178;</div><div style="width:50%; float:left; text-align:right;">'+sm2+'m&#178;</div>';
	d1.style.display="block";
}

function zInactiveCheckLoginStatus(f){
	if(zGetCookie("Z_USER_ID")==="" || zGetCookie("Z_USER_ID")==='""'){
		var found=false;
		if(f.type==="select" || f.type==="select-multiple"){
			var d1=document.getElementById("search_liststatus");
			for(var i=0;i<d1.options.length;i++){
				if(d1.options[i].value==="1"){
					d1.options[i].selected=true;
				}else{
					if(d1.options[i].selected){
						found=true;
						d1.options[i].selected=false;
					}
				}
			}
		}else if(f.type === "checkbox"){
			for(var i=1;i<30;i++){
				var d1=document.getElementById("search_liststatus_name"+i);
				if(d1){
					if(d1.value==="1"){
						d1.checked=true;
					}else{
						if(d1.checked){
							found=true;
							d1.checked=false;
						}
					}
				}else{
					break;
				}
			}
		}
		if(found){
			zShowModalStandard('/z/user/preference/register?modalpopforced=1&custommarketingmessage='+escape('Due to MLS Association Rules, you must register a free account to view inactive or sold listing data.  Use the form below to sign-up and view this data.')+'&reloadOnNewAccount=1', 640, 630);
				//alert('Only active listings can be displayed until you register a free account.');
		}
	}
}


function getMLSTemplate(obj,row){
	var arrR=new Array();
	arrR.push('<table><tr><td valign="top" wid'+'th="110" style="font-size:10px; font-style:italic;"><div class="listing-l-img"><a href="#URL#"><img src="#PHOTO1#" alt="#TITLE#" style="max-width:100%;" class="listing-d-im'+'g"></a></div>ID##MLS_ID#-#LISTING_ID#</td><td valign="top"><h2><a href="#URL#" style="text-decoration:none; ">#TITLE#</a></h2><span>#DESCRIPTION#</span><span class="listing-l-l'+'inks" style="padding-bottom:0px; "><a href="#URL#" class="zcontent-readmore-link">Read More</a><a href="/z/listing/inquiry/index?acti'+'on=form&mls_id=#MLS_ID#&listing_id=#LISTING_ID#" rel="nofollow">Send An Inquiry</a><a href="/z/listing/sl/index?save'+'Act=check&mls_id=#MLS_ID#&listing_id=#LISTING_ID#" rel="nofollow">Save Listing</a>');
	if(obj["VIRTUAL_TOUR"][row] !== ""){
		arrR.push('<a href="#VIRTUAL_TOUR#" target="_blank" rel="nofollow">View Virtual Tour</a>');
	}
	arrR.push('</span></td></tr><tr><td colspan="2" style="border-bottom:1px solid #999999;">&nbsp;</td></table><br />');
	return arrR.join("");
}


var zMLSMessageBgColor="0x990000";
var zMLSMessageTextColor="0xFFFFFF";
var zMLSMessageOutputId=0;
function zMLSShowFlashMessage(){
	var a=zGetElementsByClassName("zFlashDiagonalStatusMessage");
	for(var i=0;i<a.length;i++){
		var message=a[i].innerHTML;
		zMLSMessageOutputId++;
		message=zStringReplaceAll(message,"\r","");
		if(message!=="" && message.indexOf("<object ") === -1){
			//a[i].innerHTML=('<img src="/z/a/images/s.gif" width="100%" height="100%">');
		//}else{
			a[i].innerHTML=('<object zswf="off" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=8,0,0,0" width="221" height="161" id="zMLSMessage'+zMLSMessageOutputId+'"><param name="allowScriptAccess" value="sameDomain" /><param name="allowFullScreen" value="false" /><param name="movie" value="/z/a/listing/images/message.swf?messageText='+escape(message)+'&bgColor='+zMLSMessageBgColor+'&textColor='+zMLSMessageTextColor+'" /><param name="quality" value="high" /><param name="scale" value="noscale" /><param name="wmode" value="transparent" /><param name="salign" value="TL" /><param name="bgcolor" value="#ffffff" />	<embed src="/z/a/listing/images/message.swf?messageText='+escape(message)+'&bgColor='+zMLSMessageBgColor+'&textColor='+zMLSMessageTextColor+'" quality="high" scale="noscale" wmode="transparent" bgcolor="#ffffff" width="221" height="161" name="zMLSMessage'+zMLSMessageOutputId+'" style="pointer-events:none;" salign="TL" allowScriptAccess="sameDomain" allowFullScreen="false" type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" /></object>');	
		}
		a[i].style.display="block";
	}
}
zArrLoadFunctions.push({functionName:zMLSShowFlashMessage});



function zModalSaveSearch(searchId){
	var modalContent1='<iframe src="/z/listing/property/save-search/index?searchId='+searchId+'" width="100%" height="95%"  style="margin:0px;overflow:auto; border:none;" seamless="seamless"></iframe>';
	zShowModal(modalContent1,{'width':520,'height':410});
}
/*
function zToggleSortFormBox(){
	var d1=document.getElementById("search_remarks");
	var d2=document.getElementById("search_remarks_negative");
	var d3=document.getElementById("zSortFormBox");
	var d5=document.getElementById("zSortFormBox2");
	var d4=document.getElementById("search_sort");
	if(d1.value !="" || d2.value !== ""){
		d3.style.display="none";
		d4.selectedIndex=0;
		d5.style.display="block";
	}else{
		d3.style.display="block";
		d5.style.display="none";
	}
}
*/

function zShowInquiryPop(){
	var modalContent1='<iframe src="/z/listing/inquiry-pop/index" width="100%" height="95%" style="margin:0px;overflow:auto; border:none;" seamless="seamless"></iframe>';
	zShowModal(modalContent1,{'width':520,'height':438});
}





/*
function zListingDisplayHelpBox(){
	document.write('<a href="javascript:zToggleDisplay(\'zListingHelpDiv\');">Need help using search?</a><br />'+
	'<div id="zListingHelpDiv" style="display:none; border:1px solid #990000; padding:10px; padding-top:0px;">'+
	'<p style="font-size:14px; font-weight:bold;">Search Directions:</p>'+
	'<p>Click on one of the search options on the sidebar and use the text fields, sliders and check boxes to enter your search data.  After you are done, click "Show Results" and the results will load on the right. </p>'+
	'<p><strong>City Search:</strong> Start typing a city into the box and our system will automatically show you a list of matching cities.  Select each city you wish to include in the search by using the arrow keys up and down.  Press the enter key or left click with your mouse to confirm the selection.  To remove a city, click the "X" button to the left of the city name. Only cities matching the ones in our system may be selected.</p>'+
	'<p>After typing an entry, click "Update Results" to update your search. </p>'+
	'<p>You can select or type as many options as you want.</p>'+
	'<p>Your search will automatically show the # of matching listings as you update each search field.</p>'+
	'<p>After searching, only the available options will appear.  To reveal more options again, try unselecting or extending the range for your next search.</p>'+
	'</div>');
}*/

function zDisplayConversionCode(){

	var tempObj={};
	tempObj.method="post";
	tempObj.url='/z/misc/system/getConversionCode'; 
	tempObj.cache=false;
	tempObj.callback=function(r){
		$("body").append('<div>'+r+'</div>');
	};
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);
}

function ajaxSubmitListingInquiryCallback(r){
	var obj=eval('('+r+')'); 
	if(obj.success){
		$(".listingInquiryErrorDiv").hide();
		$(".listingInquirySuccessDiv").html(obj.message).fadeIn('fast');
		zJumpToId("listingInquirySuccessDiv");

		zTrackPageview('/z/misc/thank-you/index');
		zDisplayConversionCode();
	}else{
		$(".listingInquirySuccessDiv").hide();
		$(".listingInquiryErrorDiv").html(obj.errorMessage).fadeIn('fast');
		zJumpToId("listingInquiryErrorDiv");
	}
}
function zSubmitListingInquiry(){ 
	var postObj=zGetFormDataByFormId("listingInquiryForm");
	var tempObj={};
	tempObj.method="post";
	tempObj.url='/z/listing/inquiry/send';
	tempObj.postObj=postObj;
	tempObj.cache=false;
	tempObj.callback=ajaxSubmitListingInquiryCallback;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);

	return false;
}