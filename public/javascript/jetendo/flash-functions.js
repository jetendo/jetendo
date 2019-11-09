
(function($, window, document, undefined){
	"use strict";
	/*Author: Karina Steffens, www.neo-archaic.net*/
	function zswfr(s,s1,s2){
		var t1pos=s.indexOf(s1);
		if(t1pos !== -1){
			var t1s=s.substr(0,t1pos);
			var t1e=s.substr(t1pos+s1.length,s.length-(t1pos+s1.length));
			return t1s+s2+t1e;
		}else{
			return s;
		}
	}
	function zswf(v){
		v=zswfr(v,'zswf="off"','zswf="off" style="display:block;"');
		document.write(v);
	};
	function zswf2(){
		var is_webkit = navigator.userAgent.toLowerCase().indexOf('webkit') > -1;
		var ie=(document.defaultCharset&&document.getElementById&&!window.home);
		if(ie && !is_webkit){
			$("body").append('<style id="hideObject">object{display:none;}</style>');
		}
		if(!document.getElementsByTagName){
			return;
		}
		var x=[];
		var s=document.getElementsByTagName('object');
		for(var i=0;i<s.length;i++){
			var o=s[i];var h=o.outerHTML;
			if(h && h.indexOf('zswf="off"')!==-1){
				continue;
			}
			var params="";
			var q=true;
			for (var j=0;j<o.childNodes.length;j++){
				var p=o.childNodes[j];
				if(p.tagName==="PARAM"){
					if(p.name==="flashVersion"){
						q=zswfd(p.value);
						if(!q){
							o.id=(o.id==="")?("stripFlash"+i):o.id;x.push(o.id);break;
						}
					}
					params+=p.outerHTML;
				}
			}
			if(!q)continue;
			if(!ie)continue;
			if(o.className.toLowerCase().indexOf("noswap")!==-1)continue;
			var t=h.split(">")[0]+">";
			var j=t+params+o.innerHTML+"</OBJECT>";
			o.outerHTML=j;
		}
		if(x.length)stripFlash(x);
		if(ie && !is_webkit)var x2=document.getElementById("hideObject"); if(x2){ x2.disabled=true;}
	}
	function zswfd(v){
		if(navigator.plugins&&navigator.plugins.length){
			var plugin=navigator.plugins["Shockwave Flash"];
			if(plugin==="undefined")return false;
			var ver=navigator.plugins["Shockwave Flash"].description.split(" ")[2];
			return (Number(ver)>=Number(v));
		}else if(ie&&typeof(ActiveXObject)==="function"){
			try{
				var flash=new ActiveXObject("ShockwaveFlash.ShockwaveFlash."+v);
				return true;
			}catch(e){
				return false;
			}
		}
		return true;
	}
	function zswfs(x){
		if(!document.createElement)return;
		for(var i=0;i<x.length;i++){
			var o=document.getElementById(x[i]);
			var n=o.innerHTML;n=n.replace(/<!--\s/g,"");
			n=n.replace(/\s-->/g,"");
			n=n.replace(/<embed/gi,"<span");
			var d=document.createElement("div");
			d.innerHTML=n;
			d.className=o.className;
			d.id=o.id;
			o.parentNode.replaceChild(d,o);
		}
	}

	zArrDeferredFunctions.push(function(){
		zswf2();
	});
	window.zswf=zswf;
})(jQuery, window, document, "undefined"); 