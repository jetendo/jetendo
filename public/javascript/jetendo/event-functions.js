
var zWindowSize=false;
var zWindowIsLoaded=false;
var zScrollPosition={left:0,top:0};
var zPositionObjSubtractId=false;
var zPositionObjSubtractPos=new Array(0,0);
var zJetendoLoadedRan=false;
var zHumanMovement=false;

(function($, window, document, undefined){
	"use strict";



	function zJetendoLoaded(){ 
		if(zJetendoLoadedRan) return;
		zJetendoLoadedRan=true;
		if(!zWindowIsLoaded){
			zWindowOnLoad();	
		}
		if(typeof zArrDeferredFunctions !== "undefined"){
			var zATemp=zArrDeferredFunctions;
			for(var i=0;i<zATemp.length;i++){
				zATemp[i]();
			}
		}
	}

	var zArrMapFunctionsLoaded=false;
	function zLoadMapFunctions(){
		if(zArrMapFunctionsLoaded) return;
		zArrMapFunctionsLoaded=true;
		if(typeof zArrMapFunctions !== "undefined"){
			for(var i=0;i<zArrMapFunctions.length;i++){
				zArrMapFunctions[i]();
			}
		}
	} 
	function zSetScrollPosition(){
		var ScrollTop = document.body.scrollTop;
		if (ScrollTop === 0){
			if (window.pageYOffset){
				ScrollTop = window.pageYOffset;
			}else{
				ScrollTop = (document.body.parentElement) ? document.body.parentElement.scrollTop : 0;
			}
		}
		zScrollPosition.top=ScrollTop;
		var ScrollLeft = document.body.scrollLeft;
		if (ScrollLeft === 0){
			if (window.pageXOffset){
				ScrollLeft = window.pageXOffset;
			}else{
				ScrollLeft = (document.body.parentElement) ? document.body.parentElement.scrollLeft : 0;
			}
		}
		zScrollPosition.left=ScrollLeft;
	}


	function getWindowSize() {
	  var myWidth = 0, myHeight = 0;
	  if( typeof( window.innerWidth ) === 'number' ) {
	    //Non-IE
	    myWidth = window.innerWidth;
	    myHeight = window.innerHeight;
	  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
	    //IE 6+ in 'standards compliant mode'
	    myWidth = document.documentElement.clientWidth;
	    myHeight = document.documentElement.clientHeight;
	  } else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
	    //IE 4 compatible
	    myWidth = document.body.clientWidth;
	    myHeight = document.body.clientHeight;
	  }
	  return {width:myWidth,height:myHeight};
	}
	function zWindowOnScroll(){
		zHumanMovement=true;
		var r111=true;
		zSetScrollPosition();
		if(typeof updateCountPosition !== "undefined"){
			r111=updateCountPosition();
		}
		for(var i=0;i<zArrScrollFunctions.length;i++){
			var f1=zArrScrollFunctions[i];
			if(typeof f1==="object"){
				if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
					f1.functionName();
				}else if(f1.arguments.length === 1){
					f1.functionName(f1.arguments[0]);
				}else if(f1.arguments.length === 2){
					f1.functionName(f1.arguments[0], f1.arguments[1]);
				}else if(f1.arguments.length === 3){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
				}else if(f1.arguments.length === 4){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
				}
			}else{
				f1();
			}
				
		}
		return r111;
	} 

	
	if(typeof window.onscroll === "function"){
		var zMLSonScrollBackup=window.onscroll;
	}else{
		var zMLSonScrollBackup=function(){};
	}
	$(window).on("scroll", function(ev){
		zMLSonScrollBackup(ev);
		return zWindowOnScroll(ev);

	});
	if(typeof window.onmousewheel === "function"){
		var zMLSonScrollBackup2=window.onmousewheel;
	}else{
		var zMLSonScrollBackup2=function(){};
	} 
	$(window).on("mousewheel", function(ev){
		zMLSonScrollBackup2(ev);
		return zWindowOnScroll(ev); 
	});

	function zWindowOnResize(){
		var windowSizeBackup=zWindowSize;

		zGetClientWindowSize();
		if(typeof windowSizeBackup === "function" && windowSizeBackup.width === zWindowSize.width && windowSizeBackup.height === zWindowSize.height){
			return;	
		}
		if(typeof updateCountPosition !== "undefined"){
			updateCountPosition();
		}
		for(var i=0;i<zArrResizeFunctions.length;i++){
			var f1=zArrResizeFunctions[i];
			if(typeof f1==="object"){
				if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
					f1.functionName();
				}else if(f1.arguments.length === 1){
					f1.functionName(f1.arguments[0]);
				}else if(f1.arguments.length === 2){
					f1.functionName(f1.arguments[0], f1.arguments[1]);
				}else if(f1.arguments.length === 3){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
				}else if(f1.arguments.length === 4){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
				}
			}else{
				f1();
			}
		}
	}

	if(typeof window.onresize === "function"){
		var zMLSonResizeBackup=window.onresize;
	}else{
		var zMLSonResizeBackup=function(){};
	}
	zArrDeferredFunctions.push(function(){
		$(window).bind("resize", function(ev){
			zMLSonResizeBackup(ev);
			return zWindowOnResize(ev);

		});
		$(window).bind("clientresize", function(ev){
			zMLSonResizeBackup(ev);
			return zWindowOnResize(ev);

		});
	});
	function zLoadAllLoadFunctions(){
		zFunctionLoadStarted=true;
		for(var i=0;i<zArrLoadFunctions.length;i++){
			var f1=zArrLoadFunctions[i];
			if(typeof f1==="object"){
				if(typeof f1.arguments === "undefined" || f1.arguments.length === 0){
					f1.functionName();
				}else if(f1.arguments.length === 1){
					f1.functionName(f1.arguments[0]);
				}else if(f1.arguments.length === 2){
					f1.functionName(f1.arguments[0], f1.arguments[1]);
				}else if(f1.arguments.length === 3){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2]);
				}else if(f1.arguments.length === 4){
					f1.functionName(f1.arguments[0], f1.arguments[1], f1.arguments[2], f1.arguments[3]);
				}
			}else{
				f1();
			}
		}
		zFunctionLoadStarted=false;
		
	}
	function zGetClientWindowSize() {
		var myWidth = 0, myHeight = 0;
		if( typeof( window.innerWidth ) === 'number' ) {
			//Non-IE
			myWidth = window.innerWidth;
			myHeight = window.innerHeight;
		} else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
			//IE 6+ in 'standards compliant mode'
			myWidth = document.documentElement.clientWidth;
			myHeight = document.documentElement.clientHeight;
		} else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
			//IE 4 compatible
			myWidth = document.body.clientWidth;
			myHeight = document.body.clientHeight;
		}
		if(zScrollbarWidth===0){
		zScrollbarWidth=zGetScrollBarWidth();	
		}
		zWindowSize={
			"width":myWidth-zScrollbarWidth,
					"height":myHeight
		};
		return zWindowSize;
	}

	function zWindowOnLoad(){
		if(zWindowIsLoaded) return;
		zWindowIsLoaded=true; 
		zSetScrollPosition();
		zGetClientWindowSize();
		if(typeof window.zCloseModal !== "undefined" || typeof window.parent.zCloseModal !== "undefined"){ 
			var d1=document.getElementById("js3811");
			if(d1){
				d1.value="j219";
			}	
		}
		
		zLoadAllLoadFunctions();
		if(zPositionObjSubtractId!==false){
			var d1=document.getElementById(zPositionObjSubtractId);
			zPositionObjSubtractPos=zFindPosition(d1);
		}
		zWindowIsLoaded=true; 
		if(typeof updateCountPosition !== "undefined"){
			updateCountPosition();
		}
	}
	if(typeof window.onload === "function"){
		var zMLSonloadBackup=window.onload;
	}else{
		var zMLSonloadBackup=function(){};
	}
	$(window).bind("onload", function(ev){
		zMLSonloadBackup(ev);
		zWindowOnLoad(ev);

	});
	zArrDeferredFunctions.push(function(){
		zWindowOnResize();
	});
	window.zJetendoLoaded=zJetendoLoaded;
	window.zLoadMapFunctions=zLoadMapFunctions;
	window.zSetScrollPosition=zSetScrollPosition;
	window.getWindowSize=getWindowSize;
	window.zLoadAllLoadFunctions=zLoadAllLoadFunctions;
	
})(jQuery, window, document, "undefined"); 