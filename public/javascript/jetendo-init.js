
if(typeof Jetendo == "undefined"){
	var Jetendo={
		loadedFiles:{}
	}
}  
var zArrMapFunctions=new Array();
var zArrScrollFunctions=new Array();
var zImageOnError=function(){};
var zFunctionLoadStarted=false;
var zArrResizeFunctions=new Array();
var zJetendoLoadedRan=false;
var zArrDeferredFunctions=[];
var zArrLoadFunctions=[];
var zMSIEVersion=-1; 
var zMSIEBrowser=window.navigator.userAgent.indexOf("MSIE"); 
if(zMSIEBrowser != -1){	
	zMSIEVersion= (window.navigator.userAgent.substring (zMSIEBrowser+5, window.navigator.userAgent.indexOf (".", zMSIEBrowser ))); 
}  

var forcedUpgradeMessage=false; 
if(!forcedUpgradeMessage){
	if(zMSIEBrowser != -1 && zMSIEVersion <= 8){	
		forcedUpgradeMessage=true;
	}
	if(navigator.userAgent.toLowerCase().indexOf("android 2.") != -1){
		forcedUpgradeMessage=true;
	}
	if(typeof zDisableUpgradeMessage == "undefined" && forcedUpgradeMessage){
		var h=document.cookie.indexOf('hideBrowserUpgrade=');
		if(h==-1){
			zArrLoadFunctions.push(function(){
				if(typeof zDisableUpgradeMessage != "undefined"){
					return;
				}
				$('body').append('<div id="zBrowserUpgradeDiv" style="position:absolute; z-index:20000; background-color:#FFF !important; color:#000 !important; top:10px; right:10px; width:280px; padding:10px; font-size:18px; border:1px solid #999; line-height:24px; "><strong>This web site is not compatible with your browser.</strong> Please upgrade to access all features.<br /><a href="http://www.whatbrowser.org/" target="_blank">Learn More</a> | <a href="##" onclick="zHideBrowserUpgrade();">Hide Message</a></div>');
			});
		}
	}

} 
function zHideBrowserUpgrade(){
	document.getElementById("zBrowserUpgradeDiv").style.display='none';
	zSetCookie({key:"hideBrowserUpgrade",value:1,futureSeconds:60 * 60 * 24 * 7,enableSubdomains:false}); 

}
zJetendoLoaded=function(){}; 
function zOverEditDiv(){};
function zImageMouseMove(){};
function zImageMouseReset(){};
function onGMAPLoad(){};
zLoadMapID=false;
function zMapInit(){ 
	if(zJetendoLoadedRan){ 
		zLoadMapFunctions(); 
		onGMAPLoad(true); 
	}else{ 
		zArrDeferredFunctions.push(function(){ 
			zLoadMapFunctions(); 
			onGMAPLoad(true);  
		}); 
	} 
};
function zBindEvent(elem, evt, cb){
	if(elem.addEventListener){
		elem.addEventListener(evt,cb,false);
	}else if(elem.attachEvent){
		elem.attachEvent("on" + evt, function(){
			cb.call(event.srcElement,event);
		});
	}
}
var zStackTraceLoaded=false;
var zJavascriptErrorLogged=false;
function zLoadStackTrace(callback){
	if(zStackTraceLoaded){
		return;
	}
	zStackTraceLoaded=true;
	var a = document.createElement('script');  
	a.setAttribute("data-scriptLoaded","0");
	a.onreadystatechange=function(){
		if(this.readyState=="loaded" || this.readyState=="complete"){
			if (this.getAttribute("data-scriptLoaded")=="0"){
				this.setAttribute("data-scriptLoaded","1");
				callback();
			}
		}
	};
	a.onload=function(){
		if (this.getAttribute("data-scriptLoaded")=="0"){
			this.setAttribute("data-scriptLoaded","1"); 
			callback();
		}
	}; 
	a.src="/z/javascript/javascript-stacktrace/stacktrace.js"; 
	document.getElementsByTagName('head')[0].appendChild(a);
}
function zGetDomainFromURL(url){ 
    var domain;
    if (url.indexOf("://") > -1) {
        domain = url.split('/')[2];
    }
    else {
        domain = url.split('/')[0];
    }
    domain = domain.split(':')[0];
    return domain;
}
function zGlobalErrorHandler(message, url, lineNumber, columnOffset, errorObj) { 
	try{
		if(message.substr(0, 17) === "Unspecified error" || message.substr(0, 12) === "Script error" || message.substr(0, 12) === "Syntax error" || message.substr(0, 18) ===  "Not enough storage"){
			return false; // ignore origin errors
		}
		if(zJavascriptErrorLogged || (zThisIsDeveloper && window.location.href.indexOf("zdebug=") === -1)){
			return false;
		} 
		if(zGetDomainFromURL(window.location.href) != zGetDomainFromURL(url)){
			return false; // ignore external domains
		 }
		if(window.location.href.indexOf(zSiteDomain) === -1){
			console.log('zGlobalErrorHandler cancelled');
			return false;
		}
		zJavascriptErrorLogged=true; // only log 1 error per page view
		zLoadStackTrace(function(){ 
			arrStack=printStackTrace();  
			arrNewStack=[];
			if(typeof arrStack !== "undefined"){
				for(var i=0;i < arrStack.length;i++){
					// ignore internal calls
					if(arrStack[i].indexOf('printStackTrace') === -1){
						arrNewStack.push(arrStack[i]);
					}
					// ignore disqus, facebook, google, twitter, etc...
				}
			}
			postObj={};
			postObj.requestURL=window.location.href;
			postObj.errorStacktrace=arrNewStack.join("\n");
			postObj.errorMessage=message;
			postObj.errorUrl=url;
			if(typeof columnOffset !== "undefined"){
				postObj.errorColumnOffset=columnOffset;
			}
			postObj.errorLineNumber=lineNumber;
			if(typeof errorObj !== "undefined"){
				if(typeof JSON !== "undefined" && typeof JSON.stringify !== "undefined"){
					errorObj=JSON.stringify(errorObj, null, 4);
				}
				postObj.errorObj=errorObj;
			}
			if(window.XMLHttpRequest){ 
				var xhr = new XMLHttpRequest();  
			}else if (window.ActiveXObject){ 
				var xhr = new ActiveXObject('Microsoft.XMLHTTP');  
			} 
			xhr.open("POST", "/z/misc/system/logJavascriptError", true);
			xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
			var postData="";
			for(var i in postObj){
				postData+=i+"="+encodeURIComponent(postObj[i])+"&";
			}
			xhr.send(postData);
			// hide errors for real users
			if(typeof console != "undefined" && typeof console.log != "undefined"){
				console.log("A javascript error occured and the web developer was notified.");
			}
			return false; 
		});
	}catch(e){
		// ignore errors.
		//throw(e);
		console.log(e);
	}
} 
if(!forcedUpgradeMessage){
	window.onerror=zGlobalErrorHandler;
}
var zLoader=function(){
	this.loaded=0;
	this.scriptLoaded=function(){
		this.loaded++;
		if(this.count==this.loaded){
			if(this.completeCallback){
				this.completeCallback();
			}else if(typeof zJetendoLoaded != "undefined"){
				zJetendoLoaded();
			}
		}
	};
	this.loadScripts=function(arr, c) {
		this.count=arr.length;
		var h = document.getElementsByTagName("head")[0];
		var a=[];
		this.completeCallback=c;
		for(var i=0;i<arr.length;i++){
			var s = document.createElement("script");
			s.type = "text/javascript";
			s.zLoader=this;
			s.setAttribute("data-scriptLoaded","0");
			s.onreadystatechange=function(){
				if(this.readyState=="loaded" || this.readyState=="complete"){
					if (this.getAttribute("data-scriptLoaded")=="0"){
						this.setAttribute("data-scriptLoaded","1");
						this.zLoader.scriptLoaded();
					}
				}
			};
			s.onload=function(){
				if (this.getAttribute("data-scriptLoaded")=="0"){
					this.setAttribute("data-scriptLoaded","1");
					this.zLoader.scriptLoaded();
				}
			};
			
			s.onerror=function(){
				//alert("error loading script:"+this.src+":"+this.readyState);
			}; 
			s.src = arr[i];
			
			h.appendChild(s);
		}
	}
}