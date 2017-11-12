
(function($, window, document, undefined){
	"use strict";
	var zModalObjectHidden=new Array();
	var zModalScrollPosition=new Array();
	var zArrModal=[];
	var zModalPosIntervalId=false;
	var zModalIndex=0;
	var zModalKeepOpen=false;
	var zModalSideReduce=30;

	function zModalLockPosition(e){
		var el = document.getElementById("zModalOverlayDiv"); 
		if(el && el.style.display==="block"){
			var yPos=$(window).scrollTop();
			el.style.top=yPos+"px";
			return false;
		}else{
			return true;
		}
	}

	var modalIndexId=1;
	function zShowModalStandard(url, maxWidth, maxHeight, disableClose, fullscreen, padding){
		var windowSize=zGetClientWindowSize();
		if(url.indexOf("?") === -1){
			url+="?";
		}else{
			url+="&";
		}
		if(typeof maxWidth === "undefined"){
			maxWidth=3000;	
		}
		if(typeof maxHeight === "undefined"){
			maxHeight=3000;	
		}
		if(typeof disableClose === "undefined"){
			disableClose=false;	
		}
		if(typeof fullscreen === "undefined"){
			fullscreen=false;	
		} 
		if(typeof padding === "undefined"){
			padding=20;	
		}
		zModalSideReduce=10;
		if(disableClose){
			zModalSideReduce=0;
			padding=0;
		}else if(zWindowSize.width < 550){
			zModalSideReduce=10;
			padding=10;
		}
		window.zCurrentModalIframeId="zModalIframe"+modalIndexId;


		modalIndexId++;
		var modalContent1='<iframe id="'+window.zCurrentModalIframeId+'" src="'+url+'ztv='+Math.random()+'" scrolling="yes" frameborder="0"  style=" margin:0px; border:none; overflow:auto; -webkit-overflow-scrolling: touch; position:relative; " seamless="seamless" width="100%" height="98%" />';		
		zShowModal(modalContent1,{
			'width':maxWidth, // windowSize.width-zModalSideReduce
			'height':maxHeight, // , windowSize.height
			"maxWidth":maxWidth, 
			"maxHeight":maxHeight, 
			"padding":padding,

			"disableClose":disableClose, 
			"fullscreen":fullscreen});

	}
	function zFixModalPos(){
		zScrollbarWidth=1;
		zGetClientWindowSize();
		var windowSize=zWindowSize;

		for(var i=1;i<=zModalIndex;i++){
			var el = document.getElementById("zModalOverlayDivContainer"+i);
			var el2 = document.getElementById("zModalOverlayDivInner"+i);
			zArrModal[i].scrollPosition=[
			self.pageXOffset ||
			document.documentElement.scrollLeft ||
			document.body.scrollLeft
			,
			self.pageYOffset ||
			document.documentElement.scrollTop ||
			document.body.scrollTop
			];
			if(isNaN(zArrModal[i].modalWidth)){
				zArrModal[i].modalWidth=10000;
			}
			if(isNaN(zArrModal[i].modalHeight)){
				zArrModal[i].modalHeight=10000;
			}

			el.style.top=zArrModal[i].scrollPosition[1]+"px";
			el.style.left=zArrModal[i].scrollPosition[0]+"px"; 
			if(zArrModal[i].fullscreen){
				var newWidth=windowSize.width-(zModalSideReduce*2);
				var newHeight=windowSize.height-(zModalSideReduce*2); 
			}else{
				var newWidth=Math.min(zArrModal[i].modalWidth, Math.min(windowSize.width-(zModalSideReduce*2),((zArrModal[i].modalMaxWidth))));
				var newHeight=Math.min(zArrModal[i].modalHeight, Math.min(windowSize.height-(zModalSideReduce*2),((zArrModal[i].modalMaxHeight)))); 
			}
			var finalWidth=newWidth;
			var finalHeight=newHeight;
			if(windowSize.width < 768 && zArrModal[i].modalMaxMobileWidth < 768){
				finalWidth=zArrModal[i].modalMaxMobileWidth;
				finalHeight=zArrModal[i].modalMaxMobileHeight; 
			} 
			var left=Math.round(Math.max(0, windowSize.width-finalWidth)/2);
			var top=Math.round(Math.max(0, windowSize.height-finalHeight)/2);
			el2.style.left=left+'px';
			if(zArrModal[i].disableClose){
				el2.style.top=(top)+'px';
			}else{
				el2.style.top=(top+25)+'px';
			} 
			if(zArrModal[i].forceSize){
				if(windowSize.width < 768 && zArrModal[i].modalMaxMobileWidth < 768){
					finalWidth=zArrModal[i].modalMaxMobileWidth;
					finalHeight=zArrModal[i].modalMaxMobileHeight; 
				}else{
					finalWidth=zArrModal[i].width;
					finalHeight=zArrModal[i].height; 
				} 
			}else if(!zArrModal[i].disableResize){
				if(windowSize.width < 768 && zArrModal[i].modalMaxMobileWidth < 768){

				}else{
					if(zArrModal[i].disableClose){
						finalWidth=finalWidth-(zArrModal[i].padding);
						finalHeight=finalHeight-(zArrModal[i].padding);
					}else{
						finalWidth=finalWidth-(zArrModal[i].padding)-5;
						finalHeight=finalHeight-(zArrModal[i].padding)-22;
					}
				} 
				el2.style.width=finalWidth+"px";
				el2.style.height=finalHeight+"px"; 
			}
			$(".zCloseModalButton"+i).css({
				"left":((left+finalWidth)-80)+"px",
				"top":(top)+"px"
			});
			
		}
	}
	function stopBodyScrolling (bool) {

	    if (bool === true) {
	        document.body.addEventListener("touchmove", freezeVp, false);
	    } else {
	        document.body.removeEventListener("touchmove", freezeVp, false);
	    }
	}
	function freezeVp(e) {
	    e.preventDefault();
	}
	function zShowModal(content, obj){
		var d=document.body || document.documentElement;
		zModalIndex++;
		zArrModal[zModalIndex]={
			"disableClose":false,
			"padding":20,
			"disableResize":false,
			"modalMaxWidth":10000,
			"modalMaxHeight":10000,
			"modalMaxMobileWidth":10000,
			"modalMaxMobileHeight":10000,
			"modalWidth":10000,
			"modalHeight":10000,
			"fullscreen":false,
			"forceSize":false
		};
		if(typeof obj.fullscreen !== "undefined" && obj.fullscreen){
			zArrModal[zModalIndex].fullscreen=obj.fullscreen;	
		}
		if(typeof obj.disableResize !== "undefined" && obj.disableResize){
			zArrModal[zModalIndex].disableResize=obj.disableResize;	
		}
		if(typeof obj.forceSize !== "undefined" && obj.forceSize){
			zArrModal[zModalIndex].forceSize=obj.forceSize;	
		}
		var disableClose=false;
		if(typeof obj.disableClose !== "undefined" && obj.disableClose){
			disableClose=obj.disableClose;	
			zArrModal[zModalIndex].disableClose=obj.disableClose;
		}
		if(typeof obj.padding !== "undefined"){
			zArrModal[zModalIndex].padding=obj.padding;	
		}
		var b='';
		if(!disableClose){
			b='<div class="zCloseModalButton'+zModalIndex+'" style="width:80px; text-align:right; left:0px; top:0px; position:relative; float:left;  font-weight:bold;"><a href="#" onclick="zCloseModal();return false;" style="color:#FFF !important;">X Close</a></div>';  
		}
		var h='<div id="zModalOverlayDivContainer'+zModalIndex+'" class="zModalOverlayDiv">'+b+'<div id="zModalOverlayDivInner'+zModalIndex+'" class="zModalOverlayDiv2" style=" -webkit-overflow-scrolling: touch !important; overflow:auto !important;"></div></div>'; 
  


  

		$(d).append(h);
		if(!zArrModal[zModalIndex].disableResize){
			var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
			if(iOS){
				d.style.overflow="hidden";
				//d.style.position="fixed";
				d.style.position="static";
			}else{
				d.style.overflow="hidden";
			}
		}

		zGetClientWindowSize();
		$(".zModalOverlayDiv2").css("padding", zArrModal[zModalIndex].padding+"px");
		var windowSize=zWindowSize;
		zArrModal[zModalIndex].modalWidth=obj.width;
		zArrModal[zModalIndex].modalHeight=obj.height;
		if(zArrModal[zModalIndex].fullscreen){
			obj.width=windowSize.width;
			obj.height=windowSize.height;
		}else{
			obj.width=Math.min(zArrModal[zModalIndex].modalMaxWidth, Math.min(obj.width, windowSize.width));
			obj.height=Math.min(zArrModal[zModalIndex].modalMaxHeight, Math.min(obj.height, windowSize.height));
		}
		if(typeof obj.maxWidth !== "undefined"){
			zArrModal[zModalIndex].modalMaxWidth=obj.maxWidth;
		}
		if(typeof obj.maxHeight !== "undefined"){
			zArrModal[zModalIndex].modalMaxHeight=obj.maxHeight;
		}
		if(typeof obj.maxMobileWidth !== "undefined"){
			zArrModal[zModalIndex].modalMaxMobileWidth=obj.maxMobileWidth;
		}
		if(typeof obj.maxMobileHeight !== "undefined"){
			zArrModal[zModalIndex].modalMaxMobileHeight=obj.maxMobileHeight;
		}
	    zArrModal[zModalIndex].scrollPosition = [
	        self.pageXOffset ||
	        document.documentElement.scrollLeft ||
	        document.body.scrollLeft
	        ,
	        self.pageYOffset ||
	        document.documentElement.scrollTop ||
	        document.body.scrollTop
	    ];
	    if(zModalIndex==1){

			var arr=document.getElementsByTagName("iframe");
			for(var i=0;i<arr.length;i++){
				if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
					arr[i].style.visibility="hidden";
					zModalObjectHidden.push(arr[i]);
				}
			}
			if(navigator.userAgent.indexOf("MSIE 6.0") !== -1){
				var arr=document.getElementsByTagName("select");
				for(var i=0;i<arr.length;i++){
					if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
						arr[i].style.visibility="hidden";
						zModalObjectHidden.push(arr[i]);
					}
				}
				arr=document.getElementsByTagName("object");
				for(var i=0;i<arr.length;i++){
					if(arr[i].style.visibility==="" || arr[i].style.visibility === "visible"){
						arr[i].style.visibility="hidden";
						zModalObjectHidden.push(arr[i]);
					}
				}
				// don't use the png here...
				var dover1=document.getElementById("zModalOverlayDiv");
				dover1.style.backgroundImage="url(/z/a/images/bg-checker.gif)";
			}
		} 
		stopBodyScrolling(true);
		var el = document.getElementById("zModalOverlayDivContainer"+zModalIndex);
		var el2 = document.getElementById("zModalOverlayDivInner"+zModalIndex);
		el.style.display = "block";
		el2.style.display = "block";
		el2.onclick=function(){
			zModalKeepOpen=true;
			setTimeout(function(){zModalKeepOpen=false;},100); 
			return false;
		};
		el2.innerHTML=content;  	
		if(disableClose){
			el.onclick=function(){};
		}else{
			el.onclick=function(){
				if(zModalKeepOpen) return;
				zCloseModal();
			};
			//right:20px; top:5px; position:fixed; 
			//el2.innerHTML='<div class="zCloseModalButton" style="width:80px; text-align:right; left:0px; top:0px; position:relative; float:left;  font-weight:bold;"><a href="#" onclick="zCloseModal();return false;" style="color:#CCC;">X Close</a></div>'+content;  
		}

 
		if($(".zModalOverlayDiv2 iframe").length){
			if(!zIsTouchscreen()){
				$(".zModalOverlayDiv2").css("overflow", "hidden");
			}
			$(".zModalOverlayDiv2 iframe").height("100%");
			$(".zModalOverlayDiv2 iframe").css("position", "relative");
		}else{
			if(!zIsTouchscreen()){
				$(".zModalOverlayDiv2").css("overflow", "auto");
			}
		}
		el.style.top=zArrModal[zModalIndex].scrollPosition[1]+"px";
		el.style.left=zArrModal[zModalIndex].scrollPosition[0]+"px";
		el.style.height="100%";
		el.style.width="100%";
		var left=Math.round(Math.max(0,((windowSize.width)-obj.width))/2);
		var top=Math.round(Math.max(0, (windowSize.height-obj.height))/2);
		el2.style.left=left+'px';
		el2.style.top=top+'px';
		if(zArrModal[zModalIndex].disableClose){
			el2.style.width=(obj.width-(zArrModal[zModalIndex].padding))+"px";
			el2.style.height=(obj.height-(zArrModal[zModalIndex].padding))+"px";
		}else{
			el2.style.width=(obj.width-(zArrModal[zModalIndex].padding)-5)+"px";
			el2.style.height=(obj.height-(zArrModal[zModalIndex].padding)-22)+"px";
		}
		$(".zCloseModalButton"+zModalIndex).css({
			"left":((left+obj.width)-80)+"px",
			"top":(top-25)+"px"
		});
		zModalPosIntervalId=setInterval(zFixModalPos,500);
		zCurrentHash="#zModal-"+new Date().getTime()+"-"+Math.random();
		window.location.href=zCurrentHash;  

	}
	function zSetModalSideReduce(r){
		zModalSideReduce=r;
	}
	function zCloseModal(){

		stopBodyScrolling(false);
		zModalSideReduce=30;
		var el = document.getElementById("zModalOverlayDivContainer"+zModalIndex);
		if(!el){
			return;
		}
		clearInterval(zModalPosIntervalId);
		for(var i=0;i <zArrModalCloseFunctions.length;i++){
			zArrModalCloseFunctions[i]();
		}
		zArrModalCloseFunctions=[];
		zModalPosIntervalId=false;
		var d=document.body || document.documentElement;

		var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
		if(iOS){
			d.style.overflow="auto";
			d.style.position="static";
		}else{
			d.style.overflow="auto";
			d.style.position="relative"; 
		}
		el.parentNode.removeChild(el);
	    if(zModalIndex==1){
			for(var i=0;i<zModalObjectHidden.length;i++){
				zModalObjectHidden[i].style.visibility="visible";
			}
		}
		zModalIndex--;
		if(zModalIndex<0){
			zModalIndex=0;
		}
	}

	function zShowGridEditorWindow(link){
		var windowSize=zGetClientWindowSize();
		var modalContent1='<iframe src="'+link+'"  style="margin:0px;border:none; overflow:auto;" seamless="seamless" width="100%" height="95%"><\/iframe>';		
		zShowModal(modalContent1,{'width':windowSize.width-100,'height':windowSize.height-100});
	}
	
	function zShowImageUploadWindow(imageLibraryId, imageLibraryFieldId, imageCountId){
		var windowSize=zGetClientWindowSize();

		window.zImageCountObj=document.getElementById(imageCountId);
		var modalContent1='<iframe src="/z/_com/app/image-library?method=imageform&image_library_id='+imageLibraryId+'&fieldId='+encodeURIComponent(imageLibraryFieldId)+'&ztv='+Math.random()+'"  style="margin:0px;border:none; overflow:auto;" seamless="seamless" width="100%" height="95%"><\/iframe>';		
		zSetModalSideReduce(0);
		zShowModal(modalContent1,{'padding':0, 'width':4000,'height':4000}); 
	}

	function zCloseThisWindow(reload){
		if(typeof reload === 'undefined'){
			reload=false;
		}
		if(window.parent.zCloseModal){
			if(reload){
				var curURL=window.parent.location.href;
				window.parent.location.href = curURL;
			}else{
				window.parent.zCloseModal();
			}
		}else{
			if(reload){
				var curURL=window.parent.location.href;
				window.parent.location.href = curURL;
			}else{
				window.close();
			}
		}
	}
	window.zArrModalCloseFunctions=[];
	if(typeof window.zModalCancelFirst == "undefined"){
		window.zModalCancelFirst=false;
	}
	window.zShowGridEditorWindow=zShowGridEditorWindow;
	window.zModalLockPosition=zModalLockPosition;
	window.zShowModalStandard=zShowModalStandard;
	window.zFixModalPos=zFixModalPos;
	window.zShowModal=zShowModal;
	window.zCloseModal=zCloseModal;
	window.zShowImageUploadWindow=zShowImageUploadWindow;
	window.zCloseThisWindow=zCloseThisWindow;
	window.zSetModalSideReduce=zSetModalSideReduce;
})(jQuery, window, document, "undefined"); 