
(function($, window, document, undefined){
	"use strict";


	function zSetupClickTrackDisplay(){
		$(".zClickTrackDisplayValue").each(function(){
			if(this.getAttribute('data-zclickbindset')!=null){
				return;
			}
			$(this).attr('data-zclickbindset', '1');
			$(this).bind("click", zClickTrackDisplayValue); 
		});
		$(".zClickTrackDisplayURL").each(function(){
			if(this.getAttribute('data-zclickbindset')!=null){
				return;
			}
			$(this).attr('data-zclickbindset', '1');
			$(this).bind("click", zClickTrackDisplayURL);
		});
	}		
	function zClickTrackDisplayValue(){ 
		var postValue=this.getAttribute("data-zclickpostvalue");
		var eventCategory=this.getAttribute("data-zclickeventcategory");
		var eventLabel=this.getAttribute("data-zclickeventlabel");
		var eventAction=this.getAttribute("data-zclickeventaction");
		var eventValue=this.getAttribute("data-zclickeventvalue");
		var gtmEventValue=this.getAttribute("data-zclickgtmeventvalue");
		if(gtmEventValue != null && gtmEventValue != ""){
			window.dataLayer = window.dataLayer || [];
			window.dataLayer.push({
			'event' : gtmEventValue
			});
		}
		
		zTrackEvent(eventCategory, eventAction, eventLabel, eventValue, '', false);
		if(postValue != ""){
			this.parentNode.innerHTML=postValue;
		}
		return false;
	}
	function zClickTrackDisplayURL(){
		var postValue=this.getAttribute("data-zclickpostvalue");
		var eventCategory=this.getAttribute("data-zclickeventcategory");
		var eventLabel=this.getAttribute("data-zclickeventlabel");
		var eventAction=this.getAttribute("data-zclickeventaction");
		var eventValue=this.getAttribute("data-zclickeventvalue");
		var gtmEventValue=this.getAttribute("data-zclickgtmeventvalue");
		if(gtmEventValue != null && gtmEventValue != ""){
			window.dataLayer = window.dataLayer || [];
			window.dataLayer.push({
			'event' : gtmEventValue
			});
		}
		var newWindow=false;
		if(this.target == "_blank"){
			newWindow=true;
		}
		zTrackEvent(eventCategory, eventAction, eventLabel, eventValue, postValue, newWindow);
		if(this.target == "_blank"){
			return true;
		}else{
			return false;
		}
	}
	function zTrackPageView(link){
		if(typeof window['gtag'] != "undefined"){
			var b=window['gtag'];
			b('config', {'page_path': link}); 
		}else if(typeof window['GoogleAnalyticsObject'] != "undefined"){
			var b=window[window['GoogleAnalyticsObject']];
			b('send', {
				'hitType' : 'pageview',
				'page' : link // Virtual page (aka, does not actually exist) that you can now track in GA Goals as a destination page.
			}); 
		}else if(typeof pageTracker != "undefined" && typeof pageTracker._trackPageview != "undefined"){
			pageTracker._trackPageview(link);
		}else if(typeof _gaq != "undefined" && typeof _gaq.push != "undefined"){ 
			_gaq.push(['_trackPageview',link]); 
		}else{
			console.log('Google Analytics not detected when trying to store this pageview: '+link);
		}

	}

	



	function zTrackEvent(eventCategory,eventAction, eventLabel, eventValue, gotoToURLAfterEvent, newWindow){
		// detect when google analytics is disabled on purpose to avoid running this.
		var registerTimeout=0;
		if(gotoToURLAfterEvent != ""){
			registerTimeout=setTimeout(function(){ 
				if(!newWindow){ 
					console.log('event tracking failed - loading URL anyway: '+gotoToURLAfterEvent);
					window.location.href = gotoToURLAfterEvent;
				}
			}, 1000); 
		}
		if(typeof zVisitorTrackingDisabled != "undefined"){
			if(gotoToURLAfterEvent != ""){
				clearTimeout(registerTimeout);
				setTimeout(function(){
					if(!newWindow){
						window.location.href = gotoToURLAfterEvent;
					}
				}, 100);
			}
			return; 
		} 
		if(typeof window['gtag'] != "undefined"){
			var b=window['gtag'];
			if(gotoToURLAfterEvent != ""){
				if(eventLabel != ""){
					console.log('track event 1:'+eventValue);
					b('event', eventAction, {
					  'event_category': eventCategory,
					  'event_label': eventLabel,
					  value:eventValue,
					  'event_callback': function(){
							clearTimeout(registerTimeout);
							if(!newWindow && gotoToURLAfterEvent != ""){
								window.location.href = gotoToURLAfterEvent;
							}
					  }
					}); 
				}else{
					console.log('track event 2:'+eventAction);
					b('event', eventAction, {
					  'event_category': eventCategory, 
					  value:eventValue,
					  'event_callback': function(){
							clearTimeout(registerTimeout);
							if(!newWindow && gotoToURLAfterEvent != ""){
								window.location.href = gotoToURLAfterEvent;
							}
					  }
					});  
				}
			}else{
				if(eventLabel != ""){
					console.log('track event 3:'+eventValue);
					b('event', eventAction, {
					  'event_category': eventCategory,
					  'event_label': eventLabel,
					  value:eventValue
					}); 
				}else{
					console.log('track event 4:'+eventAction);
					b('event', eventAction, {
					  'event_category': eventCategory,
					  value:eventValue
					}); 
				}
			}
		}else if(typeof window['GoogleAnalyticsObject'] != "undefined"){
			var b=window[window['GoogleAnalyticsObject']];
			if(gotoToURLAfterEvent != ""){
				if(eventLabel != ""){
					console.log('track event 1:'+eventValue);
					b('send', 'event', eventCategory, eventAction, eventLabel, eventValue, {
						'hitCallback': function(){
							clearTimeout(registerTimeout);
							if(!newWindow && gotoToURLAfterEvent != ""){
								window.location.href = gotoToURLAfterEvent;
							}
						}
					});
				}else{
					console.log('track event 2:'+eventAction);
					b('send', 'event', eventCategory, eventAction, {
						'hitCallback': function(){ 
							clearTimeout(registerTimeout);
							if(!newWindow && gotoToURLAfterEvent != ""){
								window.location.href = gotoToURLAfterEvent;
							}
						}
					});
				}
			}else{
				if(eventLabel != ""){
					console.log('track event 3:'+eventValue);
					b('send', 'event', eventCategory, eventAction, eventLabel, eventValue);
				}else{
					console.log('track event 4:'+eventAction);
					b('send', 'event', eventCategory, eventAction);
				}
			}
		}else if(typeof pageTracker != "undefined" && typeof pageTracker._trackPageview != "undefined"){
			if(eventLabel != ""){
				pageTracker._trackEvent(eventCategory, eventAction, eventLabel, eventValue);
			}else{
				pageTracker._trackEvent(eventCategory, eventAction);
			} 
		}else if(typeof _gaq != "undefined" && typeof _gaq.push != "undefined"){
			if(gotoToURLAfterEvent != ""){
				_gaq.push(['_set','hitCallback',function(){
					clearTimeout(registerTimeout);
					if(!newWindow){
						window.location.href = gotoToURLAfterEvent;
					}
				}]);
			}
			if(eventLabel != ""){
				_gaq.push(['_trackEvent', eventCategory, eventAction, eventLabel, eventValue]);
			}else{
				_gaq.push(['_trackEvent', eventCategory, eventAction]);
			}
		}else{
			if(zIsLoggedIn()){
				if(!newWindow && gotoToURLAfterEvent != ""){
					window.location.href = gotoToURLAfterEvent;
				}
			}else{
				throw("Google analytics tracking code is not installed, or is using different syntax. Event tracking will not work until this is correct.");
			}
		}
	}

	// track all outbound links in google analytics events
	$(document).on('touchstart', "a", function() {
	    this.documentClick = true;
	});
	$(document).on('touchmove', "a", function() {
	    this.documentClick = false;
	});
	$(document).on('click touchend', "a", function(e) { 
	    if (e.type == "click") this.documentClick = true;
	    if (typeof this.documentClick == "undefined" || !this.documentClick){
	    	return true;
	    } 
	    if($(this).hasClass("zDisableTrackOutbound")){
	    	return true;
	    }
   		var d=window.location.href;
   		var slash=d.indexOf("/", 9); 
   		if(slash==-1){
   			return true;
   		}else{
	   		d=d.substr(0, slash);  
	   		var link="";
	   		if(typeof this.href != "undefined"){
	   			link=this.href;
	   		} 
	   		if(link == "" || link.substr(0,1) == "#"){
	   			return true;
	   		}
	   		var clickDomain=this.href.substr(0, d.length);
	   		if(clickDomain != d){  
	   			if(typeof this.target != "undefined" && this.target=="_blank"){
					zTrackEvent("outbound", link, "", "", link, true); 
	   				return true;
	   			}else{
					zTrackEvent("outbound", link, "", "", link, false); 
	   				return false;
	   			}
	   		}else{
		   		return true;
		   	}
	   	}
   	});  

	zArrLoadFunctions.push({functionName:zSetupClickTrackDisplay});
	window.zSetupClickTrackDisplay=zSetupClickTrackDisplay;
	window.zTrackPageView=zTrackPageView;
	window.zTrackPageview=zTrackPageView; // to help with typos
	window.zTrackEvent=zTrackEvent;
	window.zClickTrackDisplayURL=zClickTrackDisplayURL;
	window.zClickTrackDisplayValue=zClickTrackDisplayValue;
	window.zSetupClickTrackDisplay=zSetupClickTrackDisplay;
})(jQuery, window, document, "undefined"); 