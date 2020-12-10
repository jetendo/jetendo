
(function($, window, document, undefined){
	"use strict";


function setupMobileHeader(){ 
	var win = $( window ); 
	var mobileHeader = $( '.z-mobile-header');  
	var mobileHeaderMobileMenu        = $( '.z-mobile-menu', mobileHeader );
	var mobileHeaderMobileMenuIcon    = $( '.z-mobile-menu-icon' );
	var mobileHeaderDesktopMenuIcon=$('.z-desktop-mobile-menu-icon');
	var mobileHeaderMobileMenuOverlay = $( '.z-mobile-header-overlay', mobileHeader );
	var mobileHeaderMobileMenuClosedLinks        = $( '.z-mobile-menu li.closed > a', mobileHeader );


	mobileHeaderMobileMenuClosedLinks.on("click",function(e){
		e.preventDefault();
		$(this).parent().toggleClass("closed");
	});
	
 
	if(mobileHeader.hasClass("z-mobile-allow-fixed")){
		win.on( 'scroll', function() {
			var scrollTop = ( window.pageYOffset !== undefined ) ? window.pageYOffset : ( document.documentElement || document.body.parentNode || document.body ).scrollTop;
			if ( scrollTop > 0 ) {
				mobileHeader.addClass( 'z-mobile-header-fixed' );
			} else {
				mobileHeader.removeClass( 'z-mobile-header-fixed' );
			}
		} );
	}
	win.scroll();  

	var scrollbarWidth=zGetScrollBarWidth();
	var hasScrollbar=false;

	function resizeMobileHeader(){
		var marginType="margin-right";
		var left=false;
		if($(".z-mobile-header").hasClass("z-mobile-header-left")){
			left=true;
		//	marginType="margin-left";
		}
 		var w=$(window).width();
 		var h=$(window).width();
 		var open=false;
		if(mobileHeaderMobileMenuIcon.hasClass( 'open' )){ 
			open=true; 
			mobileHeaderMobileMenuOverlay.css({
				"width":Math.round(w*2)+"px",
				"height":Math.round(h*2)+"px"
			}); 
		}
		var nw=$(window).width(); 
		// keep screen from shifting
 		if(hasScrollbar){ 
 			if(open){ 
				$("body").css(marginType, scrollbarWidth+"px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", (20+scrollbarWidth)+"px");
	 				if(left){
			 			$(".z-mobile-header").css("width", (w-scrollbarWidth)+"px");
	 				}else{
			 			$(".z-mobile-header").css("width", (w)+"px");
			 		}
	 			}else{
		 		}
 			}else{
	 			$(".z-mobile-header").css("width", "100%");
				$("body").css(marginType, "0px"); 
				if(mobileHeader.hasClass("z-mobile-allow-fixed") && zScrollPosition.top != 0){
	 				$(".z-mobile-menu-icon").css("right", "20px"); 
	 			}
	 		}
 		}else{ 
	 		$(".z-mobile-header").css("width", "100%");
			$("body").css(marginType, "0px"); 
	 		$(".z-mobile-menu-icon").css("right", "20px"); 
 		}
	}
 
 	function toggleMenu(){ 
 		var w=$(window).width();
 		var h=$(window).width();
 		var open=false;
		if(mobileHeaderMobileMenuIcon.hasClass( 'open' )){
			$("body").css("overflow", "auto");
			mobileHeaderMobileMenuOverlay.removeClass("open");
		}else{
			$("body").css("overflow", "hidden");
			open=true;
			mobileHeaderMobileMenuOverlay.addClass("open"); 
		}
		var nw=$(window).width();  
 		if(w!=nw){ 
 			hasScrollbar=true;
 		}else{ 
 			hasScrollbar=false;
 		} 
		mobileHeaderMobileMenuIcon.toggleClass( 'open' );
		mobileHeaderMobileMenu.toggleClass( 'open' );
		resizeMobileHeader();
 	}
 	zArrResizeFunctions.push({functionName:resizeMobileHeader});
 	resizeMobileHeader();

	mobileHeaderMobileMenuIcon.on( 'click', function() {
		toggleMenu();
	} );

	mobileHeaderMobileMenuOverlay.on( 'click', function() { 
		toggleMenu();
	} );
	mobileHeaderDesktopMenuIcon.on( 'click', function() {
		toggleMenu();
	} );
}
	
zArrDeferredFunctions.push(setupMobileHeader);

})(jQuery, window, document, "undefined"); 
