
var zHumanMovement=false;

if (typeof window.console === "undefined") { 
    window.console = {
        log: function(obj){ }
    };  
}

function maintenanceModeDisableForms(){
	$(".zHideMaintenanceMode").hide();
	$(".table-searchresults").hide();
	$("form").each(function(){
		if($("input", this).length<=2){
			$(this).after("Temporarily unavailable").remove();
		}else{
			$(this).after('<span style="font-size:140%;">Sorry, this form is temporarily disabled. Please contact us via phone or email and we\'d be happy to assist you.</span>').remove();
		}

	});
}

zArrDeferredFunctions.push(function(){
	if(typeof zMaintenanceMode!="undefined" && zMaintenanceMode){
		maintenanceModeDisableForms();
		setTimeout(function(){
			maintenanceModeDisableForms();
		}, 1000);
	}

	$(".zGetWeather").each(function(){
		var $self=$(this);
		var showHTML=$(this).attr("data-show-html");
		if(showHTML=="1"){
			showHTML=true;
		}else{
			showHTML=false;
		}
		var ts={
			id:"zGetWeather",
			method:"post",
			postObj:{
				zip:$(this).attr("data-zip"),
				currentOnly:$(this).attr("data-currentonly"),
				overrideStyles:$(this).attr("data-override-styles"),
				forecastLink:$(this).attr("data-forecast-link")
			},
			url:"/z/misc/weather/index",
			callback:function(r){
				var r=JSON.parse(r);
				if(r.success){ 
					if(showHTML){
						$self.html(r.html);
					}else{
						$self.html(r.data.temperature+"&deg;");
					}
				}else{ 
					$self.html("");
				}
			},
			cache:false
		};  
		zAjax(ts); 
	});
});


if (typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function () {
    return this.replace(/^\s+|\s+$/g, '');
  }
}

function zKeyExists(obj, key){
	return (key in obj);
}
function zGetURLParameter(sParam){
	var sPageURL = window.location.search.substring(1);
	var sURLVariables = sPageURL.split('&');
	for (var i = 0; i < sURLVariables.length; i++){
		var sParameterName = sURLVariables[i].split('=');
		if (sParameterName[0] == sParam){
			return sParameterName[1];
		}
	}
	return "";
}

function zHtmlEditFormat(s, preserveCR) {
    preserveCR = preserveCR ? '&#13;' : '\n';
    return ('' + s) /* Forces the conversion to string. */
        .replace(/&/g, '&amp;') /* This MUST be the 1st replacement. */
        .replace(/'/g, '&apos;') /* The 4 other predefined entities, required. */
        .replace(/"/g, '&quot;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;') 
        .replace(/\r\n/g, preserveCR) /* Must be before the next replacement. */
        .replace(/[\r\n]/g, preserveCR);
        ;
}

var zDisableSearchFilter=0;

 
 zArrDeferredFunctions.unshift(function(){
	 // gist Source: https://gist.github.com/brucekirkpatrick/7026682
	(function($){

		$.unserialize = function(serializedString){
			var str = decodeURI(serializedString); 
			var pairs = str.split('&');
			var obj = {}, p, idx;
			for (var i=0, n=pairs.length; i < n; i++) {
				p = pairs[i].split('=');
				idx = p[0]; 
				if (typeof obj[idx] === 'undefined') {
					obj[idx] = decodeURIComponent(p[1]);
				}else{
					if (typeof obj[idx] === "string") {
						obj[idx]=[obj[idx]];
					}
					obj[idx].push(decodeURIComponent(p[1]));
				}
			}
			return obj;
		};
		
	})($);
});

var zPageHelpId='';
function zGetHelpForThisPage(obj){
	obj.id="getHelpForThisPageLinkId";
	if(zPageHelpId==''){
		alert("No help resources exist for this page yet.\n\nFeel free to browse the documentation or contact the web developer for further assistance.");
		return false;
	}
	obj.href=zPageHelpId;
	return true;
}


function zUpgradeBrowserMessage(){
	if(zMSIEBrowser!==-1 && zMSIEVersion<=7){
		$(".adminBrowserCompatibilityWarning").show();
	}
}
zArrLoadFunctions.push({functionName:zUpgradeBrowserMessage});



function zGetChildElementCount(id){
	var c=0;
	for(var i=0;i<document.getElementById(id).childNodes.length;i++){
		if(document.getElementById(id).childNodes[i].nodeName !== "#text"){
			c++;
		}
	}
	return c;
}

var zPopUnderURL="";
var zPopUnderFeatures="";
var zPopUnderLoaded=false;
function zLoadPopUnder(u, winfeatures){
	zPopUnderURL=u;
	zPopUnderFeatures=winfeatures;
	if (zPopUnderLoaded === false && zGetCookie('zpopunder')===''){
		zPopUnderLoaded=true;
		document.body.onclick = function(){
			zSetCookie({key:"zpopunder",value:"yes",futureSeconds:3600 * 12,enableSubdomains:false}); 
			win2=window.open(zPopUnderURL,"zpopunderwindow",zPopUnderFeatures);
			win2.blur();
			window.focus();	
		};
	} 
}
function zURLEscape(str){
	var s=encodeURIComponent(str.toString().trim());
	
	var g=new RegExp('/+/', 'g');
	s=s.replace(g,"+");
	g=new RegExp('/@/', 'g');
	s=s.replace(g,"@");
	g=new RegExp('///', 'g');
	s=s.replace(g,"/");
	g=new RegExp('/*/', 'g');
	s=s.replace(g,"*");
	return(s);
}
function zLoadVideoJSID(id, autoplay){
	VideoJS.setup(id);
	if(autoplay){
		document.getElementById(id).player.play();
	}
}
function walkTheDOM (node, func) {
	func(node);
	node = node.firstChild;
	while (node) {
		walkTheDOM(node, func);
		node = node.nextSibling;
	}
}
function zGetElementsByClassName(className) {
	if(typeof document.getElementsByClassName !== "undefined"){
		return document.getElementsByClassName(className);
	}else{
		var results = [];
		walkTheDOM(document.body, function (node) {
			var a, c = node.className, i;
			if (c) {
				a = c.split(' ');
				for (i=0; i<a.length; i++) {
					if (a[i] === className) {
						results.push(node);
						break;
					}
				}
			}
		});
		return results;
	}
}
function zToggleDisplay(id){
	var d=document.getElementById(id);
	if(d.style.display==="none"){
		d.style.display="block";
	}else{
		d.style.display="none";
	}
}

var zArrBlink=new Array();
function zBlinkId(aname, blink_speed){
var dflash=document.getElementById(aname);
 if(typeof zArrBlink[aname] === "undefined"){
	zArrBlink[aname]=0; 
 }
 if(zArrBlink[aname]%2===0){
 dflash.style.visibility="visible";
 }else{
 dflash.style.visibility="hidden";
 }
 if(zArrBlink[aname]<1){
	zArrBlink[aname]=1;
 }else{
	zArrBlink[aname]=0;
 }
 setTimeout("zBlinkId('"+aname+"',"+blink_speed+")",blink_speed);
}




var zIgnoreClickBackup=false;
function zRenable(){
	if(zIgnoreClickBackup){
		zIgnoreClickBackup=false;
	}else{
		zInputHideDiv();
	}
	return true;
}
if(typeof document.onclick === "function"){
	var zDocumentClickBackup=document.onclick;
}else{
	var zDocumentClickBackup=function(){};
}
$(document).bind("click", function(ev){
	zDocumentClickBackup(ev);
	zRenable(ev);
});


function zFixText(myString){
	myString = zMakeEnglish(myString);	
	myString = zIsAlphabet(myString);
	myString = myString.toLowerCase();
	return myString;
}


function zFormatTheArray(myArray){
	var useThisArray = [];
	for(i=0;i < myArray.length; i++){
	useThisArray[i] = zFixText(myArray[i]);
	}
	
return useThisArray;	
}



	

function zIsAlphabet(elem){
	var alphaExp = /^[a-zA-Z0-9 ]+$/;
	if(elem.match(alphaExp)){
		return elem;
	}else{
		return elem;
	}
}


var daysToOffset=0;

function zMakeEnglish(elem){
	var elem1 = elem;
	var alphaExp = /^[a-zA-Z ]+$/;
	if(elem.match(alphaExp)){
		return elem;
	}else{
		var englishList = "A,A,A,A,A,A,AE,C,E,E,E,E,I,I,I,I,ETH,N,O,O,O,O,O,O,U,U,U,U,Y,THORN,s,a,a,a,a,a,a,ae,c,e,e,e,e,i,i,i,i,eth,n,o,o,o,o,o,o,u,u,u,u,y,thorn,y,OE,oe,S,s,Y,f";		 
		var foreignList="�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�";		
		var arrEnglish = englishList.split( "," );
		var arrForeign = foreignList.split( "," );
		for(e = 0; e < elem.length; e ++){
			for(f=0; f < arrForeign.length; f++){				
				if (elem1.charAt(e) === arrForeign[f]){
					myChar = elem1.charAt(e);
					if (!(myChar.match(alphaExp))){
						pattern = new RegExp(arrForeign[f]);
						elem1 = elem1.replace(pattern, arrEnglish[f]);
					}
				}
			}
		}
		return elem1;
	}
}

function zStringReplaceAll(str, strTarget, strSubString){
	return str.replace( new RegExp(strTarget,"g"), strSubString ); 
}






function zLoadFile(filename, filetype){
	if (filetype==="js"){
		var fileref=document.createElement('script');
		fileref.setAttribute("type","text/javascript");
		fileref.setAttribute("src", filename);
	}else if (filetype==="css"){
		var fileref=document.createElement("link");
		fileref.setAttribute("rel", "stylesheet");
		fileref.setAttribute("type", "text/css");
		fileref.setAttribute("href", filename);
	}
	if (typeof fileref!=="undefined"){
		document.getElementsByTagName("head")[0].appendChild(fileref);
	}
}
function zSet9(id){
	var d1=document.getElementById(id);
	d1.value="9989";
	zHumanMovement=true;
}
if(typeof String.prototype.trim === "undefined"){
	String.prototype.trim=function(){return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');};
}


var zMSIEVersion=-1;
var zMSIEBrowser=window.navigator.userAgent.indexOf("MSIE");
if(zMSIEBrowser !== -1){
	zMSIEVersion= (window.navigator.userAgent.substring (zMSIEBrowser+5, window.navigator.userAgent.indexOf (".", zMSIEBrowser )));
}
function zo(variable){
	var a=document.getElementById(variable);
	if(a !== null){
		return a;
	}else if(typeof(window[variable]) === "undefined"){
		return false;	
	}else{
		return eval(variable);	
	}
}
function zso(obj, varName, isNumber, defaultValue){
	if(typeof isNumber==="undefined") isNumber=false;
	if(typeof defaultValue==="undefined") defaultValue=false;
	var tempVar = "";
	if(isNumber){
		if(zKeyExists(obj, varName)){
			tempVar = obj[varName];
			if(!isNaN(tempVar)){
				return tempVar;
			}else{
				if(defaultValue !== ""){
					return defaultValue;
				}else{
					return 0;
				}
			}
		}else{
			if(defaultValue !== ""){
				return defaultValue;
			}else{
				return 0;
			}
		}
	}else{
		if(zKeyExists(obj, varName)){
			return obj[varName];
		}else{
			return defaultValue;
		}
	}
}


function forceCustomFontDesignModeOn(id){
	doc=tinyMCE.get(id).getDoc();
	doc.designMode="on";
	$("span", doc).each(function(){
		if(this.innerHTML==="BESbswy"){
			$(this).remove();
		}
	});
}


function forceCustomFontLoading(editor){
	doc=editor.getDoc();
	if(navigator.userAgent.indexOf("MSIE ") === -1){
		doc.designMode="off";
	} 
	if(typeof zFontsComURL !== "undefined" && zFontsComURL !== ""){
		if(zFontsComURL.substr(zFontsComURL.length-4) === ".js"){
			head = doc.getElementsByTagName('head')[0];
			script = doc.createElement('script');
			script.src = zFontsComURL;
			script.type = 'text/javascript';
			head.appendChild(script);
		}else{
			head = doc.getElementsByTagName('head')[0];
			script = doc.createElement('link');
			script.href = zFontsComURL;
			script.rel = 'stylesheet';
			script.type = 'text/css';
			head.appendChild(script);
		}
	}
	if(typeof zTypeKitURL !== "undefined" && zTypeKitURL !== ""){
		head = doc.getElementsByTagName('head')[0];
		script = doc.createElement('script');
		script.src = zTypeKitURL;
		script.type = 'text/javascript';
		head.appendChild(script);
		script = doc.createElement('script');
		script.type = 'text/javascript';
		script.src='/z/javascript/zTypeKitOnLoad.js';
		head.appendChild(script);
	}
	if(navigator.userAgent.indexOf("MSIE ") === -1 && document.getElementById(editor.editorId)){
		setTimeout('forceCustomFontDesignModeOn("'+editor.editorId+'");',2000);
	}
}
function zGetCurrentRootRelativeURL(theURL){
	var a=theURL.split("/");
	var a2="";
	for(var i=3;i<a.length;i++){
		a2+="/"+a[i];
	}
	a2=(a2).split("#");
	return a2[0];
} 
function zIsTestServer(){
	if(typeof zThisIsTestServer !== "undefined" && zThisIsTestServer){
		return true;
	}else{
		return false;
	}
}
function zIsDeveloper(){
	if(typeof zThisIsDeveloper !== "undefined" && zThisIsDeveloper){
		return true;
	}else{
		return false;
	}
}



var zAddThisLoaded=false;
function zLoadAddThisJsDeferred(){
	setTimeout(zLoadAddThisJs, 300);
}
function zLoadAddThisJs(){
	//if(zIsTestServer()) return;
	var a1=[];
	var found=false;
	for(var i=1;i<=5;i++){
		d1=document.getElementById("zaddthisbox"+i);
		if(d1==null || typeof d1 == "undefined" || d1.style.display == 'none'){
			continue;
		} 
		if(d1){
			found=true;
			d1.innerHTML='<div style="float:left; padding-right:5px; padding-bottom:5px;"><a href="https://www.facebook.com/sharer/sharer.php?u='+escape(window.location.href)+'" target="_blank" title="Share on Facebook"><img src="/z/images/blog/facebook-share.png" width="54" height="20" alt="Share on Facebook" style="vertical-align:top;" /></a></div><div style="float:left; padding-right:5px; padding-bottom:5px;"><a href="http://www.linkedin.com/shareArticle?mini=true&amp;url='+escape(window.location.href)+'"><img src="/z/images/blog/linkedin-share.png" width="58" height="20" alt="Share on LinkedIn" style="vertical-align:top;" /></a></div><div style="float:left; padding-right:5px;padding-bottom:5px;"><a class="twitter-share-button" href="https://twitter.com/share?text='+escape(document.title)+'&url='+escape(window.location.href)+'"><img src="/z/images/blog/tweet.png" width="60" height="20" alt="Share on Twitter" style="vertical-align:top;" /></a></div><div style="float:left; padding-right:5px; padding-bottom:5px;"><iframe title="Facebook Like" style="overflow: hidden; border: 0px none; width: 90px; height: 32px; " src="//www.facebook.com/plugins/like.php?href='+escape(window.location.href)+'&amp;layout=button_count&amp;show_faces=false&amp;width=90&amp;action=like&amp;font=arial&amp;layout=button_count"></iframe></div>';

			d1.id="zaddthisbox"+i+"_loaded";
			a1.push(d1);
		}
	}
}
zArrLoadFunctions.push({functionName:zLoadAddThisJsDeferred});
 
function zeeo(m,n,o,w,l,r,h,b,v,z,z2){
	var k='ai',g='lto',f='m',e=':';
	var cr3="";
	if(z){return o+n+w+m;}else{ if(l){var cr3=('<a href="'+f+k+g+e+o+n+w+m+'">');
	if(b+h+v+r!==''){cr3+=(b+h+v+r);}else{cr3+=(o+n+w+m);} cr3+=('<\/a>');
	}else{
		cr3+=(o+n+w+m);}var d=document.getElementById('zencodeemailspan'+z2); 
		if(d){d.innerHTML=cr3;}
	}
}


	


function zSetEmailBody(c,t) {
	var ifrm = document.getElementById('zEmailBody'+c);
    var d=(ifrm.contentWindow) ? ifrm.contentWindow : (ifrm.contentDocument.document) ? ifrm.contentDocument.document : ifrm.contentDocument;
    d.document.open();
    d.document.write(t);
    d.document.close();
}

function zSetEmailBodyHeight(c){
    var ifrm = document.getElementById('zEmailBody'+c);
    var el=ifrm;
    ifrm.style.display="block";
    // this code is required to force the browser to set the correct heights after display:block is set
	var d=false;
    while (el.parentNode!==null){el=el.parentNode;d=el.scrollTop;d=el.offsetHeight;d=el.clientHeight;}
	d=false;
    if(ifrm.contentWindow){
        ifrm.style.height=((ifrm.contentWindow.document.body.scrollHeight+1))+'px';
    }else if(ifrm.contentDocument.document){
        ifrm.style.height=(ifrm.contentDocument.document.body.scrollHeight+1)+'px';
    }else{
        ifrm.style.height=(ifrm.contentDocument.body.scrollHeight+1)+'px';
    }
} 
 
function zCheckIfPageAlreadyLoadedOnce(){
	var once=document.getElementById('zPageLoadedOnceTracker');
	// if field was empty, the page was already loaded once and should be reloaded
	if(once.value.length ===""){
		var curURL=window.location.href;
		window.location.href=curURL;
	}
	once.value='';
}

function formatPhoneNumberForURI(p){
	p=p.replace(/[^0-9]/g, "");
	return p;
}
 
zArrDeferredFunctions.push(function(){
	if(zIsTouchscreen()){
		$(document).on('touchstart', ".zPhoneLink", function() {
		    this.documentClick = true;
		});
		$(document).on('touchmove', ".zPhoneLink", function() {
		    this.documentClick = false;
		});
		$(document).on('click touchend', ".zPhoneLink", function(e) {
			e.preventDefault();
		    if (e.type == "click") this.documentClick = true;
		    if (typeof this.documentClick != "undefined" && this.documentClick){
				var p=formatPhoneNumberForURI(this.innerText);
				if(p != ""){ 
					window.location.href="tel:"+p;
				}
		    }
		});  
	}
});



function zConvertToMilitaryTime( ampm, hours, minutes, leadingZero ) {
	var militaryHours;
	ampm=ampm.toLowerCase();
	hours=parseInt(hours);
	minutes=parseInt(minutes);
	if( ampm == "pm" || ampm == "p.m." ) {
		if(hours!=12){
			hours+=12;
		}
	}
	if(minutes < 10){
		if(leadingZero){
			return "0"+parseInt(hours+"0"+minutes);
		}else{
			return parseInt(hours+"0"+minutes);
		}
	}else{
		if(leadingZero){
			return "0"+hours + minutes;
		}else{
			return hours + minutes;
		}
	}
}

function gotoReimport(){
	var d2=document.getElementById('mls_id1');
	var d1=d2.options[d2.selectedIndex].value;
	if(d1 !== ''){
		window.open('/z/listing/idx/reimport?mls_id='+d1);
		return false;
	}
}
function gotoFieldNotOutput(){
	var d2=document.getElementById('mls_provider1');
	var d1=d2.options[d2.selectedIndex].value;
	if(d1 !== ''){
		window.open('/z/listing/admin/listing-misc/index?mlsName='+d1);
		return false;
	}
}
function gotoSite(id){
	if(id !== ''){
		window.location.href='/z/server-manager/admin/robots/edit?sid='+escape(id);
	}
}

function setHidden(obj, row){
	me = eval("document.myForm.log_resolver"+row);
	if(obj.checked){
		me.disabled = false;
	}else{
		me.disabled = true;
	}
}
var zIntervalIdForCFCExplorer=0;
function resize_iframe()
{
	clearInterval(zIntervalIdForCFCExplorer);
	var height=window.innerWidth;//Firefox
	if (document.body.clientHeight)
	{
		height=document.body.clientHeight;//IE
	}
	//resize the iframe according to the size of the
	//window (all these should be on the same line)
	if (document.getElementById("comframe")) {
		if (height > 0 && document.getElementById("comframe").offsetTop) {
			var newh = parseInt(height - document.getElementById("comframe").offsetTop - (15));
			if (newh > 0) {
				document.getElementById("comframe").style.height = newh + "px";
			}
		}
	}
} 

   


function zURLAppend(theLink, appendString){
	if(theLink.indexOf("?") !== -1){
		return theLink+"&"+appendString;
	}else{
		return theLink+"?"+appendString;
	}
}

function rentalForceReserve(obj){
	if(obj.value === "0" && obj.checked){
		var d=document.getElementById("rental_config_reserve_online_name2");
		d.checked=true;
	}
}
function rentalForceCalendar(obj){
	if(obj.value === "1" && obj.checked){
		var d=document.getElementById("rental_config_availability_calendar_name1");
		d.checked=true;
	}
}

var zArrURLParam=[];
function zParseURLParam() {
    var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

    zArrURLParam = {};
    while (true){
		match = search.exec(query);
		if(match){
			zArrURLParam[decode(match[1])] = decode(match[2]);
		}else{
			break;
		}
	}
}
zArrDeferredFunctions.push(function(){
	$(window).bind("popstate", zParseURLParam);
	zParseURLParam();
});



function zFormatDollar(num) {
	var p = num.toFixed(2).split(".");
	return ["$", p[0].split("").reverse().reduce(function(acc, num, i) {
		return num + (i && !(i % 3) ? "," : "") + acc;
	}, "."), p[1]].join("");
}
function zGetPMIRate(loanYears, loanToValue){
	if(loanToValue<0.8){
		return 100;	
	}
	if(loanYears===30){
		if(loanToValue>0.8 && loanToValue<=0.85){
			return 0.32;
		}else if(loanToValue>0.85 && loanToValue<=0.90){
			return 0.52;
		}else if(loanToValue>0.90 && loanToValue<=0.95){
			return 0.78;
		}else if(loanToValue>0.95 && loanToValue<=0.97){
			return 0.90;
		}else{
			return 0;
		}
	}else{
		if(loanToValue>0.8 && loanToValue<=0.85){
			return 0.19;
		}else if(loanToValue>0.85 && loanToValue<=0.90){
			return 0.23;
		}else if(loanToValue>0.90 && loanToValue<=0.95){
			return 0.26;
		}else if(loanToValue>0.95 && loanToValue<=0.97){
			return 0.79;
		}else{
			return 0;	
		}
	}
}
function zCalculateMonthlyPayment(){
	var homeprice=parseFloat(document.getElementById("homeprice").value);
	var percentdown=parseFloat(document.getElementById("percentdown").value);
	var loantype=document.getElementById("loantype");
	var loantypevalue=parseFloat(loantype.options[loantype.selectedIndex].value);	
	var currentrate=parseFloat(document.getElementById("currentrate").value);	
	var homeinsurance=parseFloat(document.getElementById("homeinsurance").value);	
	var hometax=parseFloat(document.getElementById("hometax").value);	
	var homehoa=parseFloat(document.getElementById("homehoa").value);	
	//var homepmi=document.getElementById("homepmi");
	var armEnabled=false;
	if(loantypevalue === 30.5){
		armEnabled=true;	
		loantypevalue=30;
	}
	
	var monthlyInsurance=homeinsurance/12;
	var monthlyTax=hometax/12;
	var results=document.getElementById("zMortgagePaymentResults");	
	arrT=[];
	var totalPayments=(loantypevalue*12); 
	var originalLoanBalance=homeprice-(homeprice*(percentdown/100)); 
	
	var monthlyInterestRate=(currentrate/100)/12;
	var payment = (monthlyInterestRate * originalLoanBalance*Math.pow(1 + monthlyInterestRate,totalPayments)) / (Math.pow(1 + monthlyInterestRate, totalPayments)-1);
	var interest=originalLoanBalance*monthlyInterestRate;
	var interestFormatted=zFormatDollar(Math.round(interest*100)/100);
	var principalFormatted=zFormatDollar(Math.round((payment-interest)*100)/100);
	
	var principalAndInterestFormatted=zFormatDollar(Math.round(payment*100)/100);
	
	var monthlyHoa=homehoa/12;
	var monthlyHoaFormatted=zFormatDollar(Math.round(monthlyHoa*100)/100);
	var monthlyInsuranceFormatted=zFormatDollar(Math.round(monthlyInsurance*100)/100);
	var monthlyTaxFormatted=zFormatDollar(Math.round(monthlyTax*100)/100);
	var loanToValue=originalLoanBalance/homeprice;
	var monthlyPMI=0;
	if(loanToValue>0.8){
		var pmiRate=zGetPMIRate(loantypevalue, loanToValue);
		if(pmiRate===0){
			alert("Loan to value must be 97% or less");	
			results.value="";
			return;
		}else if(pmiRate===100){
			monthlyPMI=0;
			var monthlyPMIFormatted="$0.00";
		}else{
			monthlyPMI=(originalLoanBalance*(pmiRate/100))/12;
			var monthlyPMIFormatted=zFormatDollar(Math.round(monthlyPMI*100)/100);
		}					
	}
	var paymentFormatted=zFormatDollar(Math.round((monthlyHoa+monthlyPMI+monthlyInsurance+monthlyTax+payment)*100)/100);
	arrHTML=['<span class="zMorgagePaymentTextTotal">'+paymentFormatted+"/month</span> (Principal+Interest+Tax+Insurance+PMI)<hr />"+principalAndInterestFormatted+" principal & interest<br />"+monthlyInsuranceFormatted+" Insurance<br />"+monthlyTaxFormatted+" Taxes<br />"+monthlyHoaFormatted+" HOA dues<br />"];
	if(loanToValue>0.8){
		arrHTML.push(monthlyPMIFormatted+" PMI");
	}
	results.innerHTML=arrHTML.join("");
}
