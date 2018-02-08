
var zHelpTooltip=new Object();

(function($, window, document, undefined){
	"use strict";

	zHelpTooltip.arrTrack=[];
	zHelpTooltip.curId=false;
	zHelpTooltip.curTimeoutId=false;
	zHelpTooltip.helpDiv=false;
	zHelpTooltip.helpInnerDiv=false;
	zHelpTooltip.getParentScroll = function (ctrl) {
		if (ctrl == null) {
			return null;
		}
		if (ctrl.scrollHeight > ctrl.clientHeight) {
			return ctrl;
		} else {
			return zHelpTooltip.getParentScroll(ctrl.parentNode);
		}
	};
	zHelpTooltip.showTooltip=function(){
		clearTimeout(zHelpTooltip.curTimeoutId);
		zHelpTooltip.curTimeoutId=false;
		zHelpTooltip.arrTrack[this.id].hovering=false;
		var d=document.getElementById(this.id);
		var p=zGetAbsPosition(d);
		//alert(this.id+" tooltip "+p.x+":"+p.y+":"+p.width+":"+p.height);
		var ws=getWindowSize();	
		zHelpTooltip.helpDiv.style.display="inline-block";
		zHelpTooltip.helpInnerDiv.innerHTML=zHelpTooltip.arrTrack[this.id].title;
		var p2=zGetAbsPosition(zHelpTooltip.helpDiv);
		zHelpTooltip.helpDiv.style.left = Math.min(ws.width-p2.width-10, p.x+p.width+5)+"px";
		var dParent = zHelpTooltip.getParentScroll(d);
		var window_offset = (p.y) - ( p2.height + $(dParent).scrollTop());
		zHelpTooltip.helpDiv.style.top  = window_offset + "px";//Math.max(10,(p.y)-p2.height)+"px";
		//alert(Math.min(ws.width-p.width, p.x+p.width+5)+" | "+(p.y-p.height-5));
		return false;
	};
	zHelpTooltip.hoverOut=function(e){
		clearTimeout(zHelpTooltip.curTimeoutId);
		zHelpTooltip.curTimeoutId=false;
		zHelpTooltip.curId=false;
		zHelpTooltip.arrTrack[this.id].hovering=false;
		zHelpTooltip.helpDiv.style.display="none";
		// hideTooltip
	};
	zHelpTooltip.hover=function(e){
		clearTimeout(zHelpTooltip.curTimeoutId);
		zHelpTooltip.curTimeoutId=false;
		zHelpTooltip.curId=this.id;
		if(zHelpTooltip.arrTrack[this.id].hovering){
			zHelpTooltip.arrTrack[this.id].hovering=false;
			document.getElementById(zHelpTooltip.curId).onclick();
		}else{
			zHelpTooltip.arrTrack[this.id].hovering=true;
			zHelpTooltip.curTimeoutId=setTimeout(function(){ document.getElementById(zHelpTooltip.curId).onmouseover(); }, 1000);	
		}
	};
	
	zHelpTooltip.setupHelpTooltip=function(){
		zHelpTooltip.helpDiv=document.getElementById("zHelpToolTipDiv");
		zHelpTooltip.helpInnerDiv=document.getElementById("zHelpToolTipInnerDiv");
		var a=zGetElementsByClassName("zHelpToolTip");
		for(var i=0;i<a.length;i++){
			if(a[i].title == ""){
				continue;
			}
			a[i].style.display="inline-block"; 
			zHelpTooltip.arrTrack[a[i].id]={hovering:false,title:a[i].title};
			a[i].title="";
			a[i].onmouseover=zHelpTooltip.hover;
			a[i].onmouseout=zHelpTooltip.hoverOut;
			a[i].ondragout=zHelpTooltip.hoverOut;
			a[i].onclick=zHelpTooltip.showTooltip;
		}
	};
	zArrDeferredFunctions.push(function(){
		if($("#zHelpToolTipDiv").length==0){
			$(document.body).append('<div id="zHelpToolTipDiv"><div id="zHelpToolTipInnerDiv"></div></div>');
		}
		zHelpTooltip.setupHelpTooltip();
	});

})(jQuery, window, document, "undefined"); 

