// test more than one on same page with different settings

// allow clicking on other slides to make them active
/*
// usage
*/

(function($, window, document, undefined){
	"use strict";
	var slideNameOffset=0;
	function zThreePanelSlider(options){
		var self=this; 
		options.arrSlide=zso(options, 'arrSlide', false, []);
		options.selector=zso(options, 'selector', false, ''); 
		options.pager=zso(options, 'pager', false, true);
		options.pagerStyle=zso(options, 'pagerStyle', false, 'circles'); // circles or squares
		options.auto=zso(options, 'auto', false, true);
		options.timeout=zso(options, 'timeout', true, 5000); // milliseconds
		options.touchSwipe=zso(options, 'touchSwipe', false, true);
		options.nextPrevious=zso(options, 'nextPrevious', false, true); // enable the next / previous buttons to be automatically placed
		options.nextButton=zso(options, 'nextButton', false, '&#10093;');
		options.previousButton=zso(options, 'previousButton', false, '&#10092;');
		options.nextPreviousCenterClass=zso(options, 'nextPreviousCenterClass', false, '');
		options.slideWidthPercent=zso(options, 'slideWidthPercent', true, 66.66);
		options.slideMinimumWidth=zso(options, 'slideWidthPercent', true, 200);
   
		var animating=false; 
		var currentSlideIndex=0;
		var direction=0;
		var slider=$(options.selector);
		var arrPanelOrder=[];
		var slideWidth=0;

		if(slider.length==0){
			console.log("zThreePanelSlider: options.selector not found: "+options.selector);
			return;
		}
		if(slider.length==0){
			console.log("zThreePanelSlider: options.arrSlide has no slides");
			return;
		}
		if(options.nextPreviousCenterClass==""){
			options.nextPreviousCenterClass=options.selector+" .threePanelSlide";
		}

		slider.append('<div class="threePanelSliderBackground"><div class="threePanelSlider"></div></div>'); 
		var sliderInterval=false;
		var pager=false;
		var firstLoad=true;		
		var previousButton=false;
		var nextButton=false;
		if(options.slideWidthPercent < 33.33){
		//	alert('options.slideWidthPercent must be at least 33.33.');
		}
		var panelCount=Math.round(100/options.slideWidthPercent)+2; 
		if(panelCount/2 == Math.floor(panelCount/2)){
			// force to odd number of panels
			panelCount++;
		}
		var middlePanelOffset=Math.floor(panelCount/2);
		//console.log("panelCount:"+panelCount+" middlePanelOffset:"+middlePanelOffset);

		var left=(100-options.slideWidthPercent)/2;
		var firstPercent=Math.round((left-(options.slideWidthPercent*middlePanelOffset))*100)/100;
 
		function init(){
			reloadSlides(false, 0); 
			zArrResizeFunctions.push({functionName:resizeSlider}); 
		}
		function firstLoadInit(){
			firstLoad=false;
			if(options.nextPrevious){
				attachNextPreviousButtons();
			}
			if(options.touchSwipe){
				attachTouchSwipe();
			}

			if(options.arrSlide.length > 1){
				if ( options.pager ) {
					attachPager();
					setActivePager();
				}
	  
				resetInterval( false );
			}
			setInterval(function(){
				executeAnimationQueue();
			}, 300);
		}

		function attachTouchSwipe(){

			slider.on( 'mousedown', function( event ) {
				event.preventDefault(); 
				var mousePos = zDrag_mouseCoords(event.originalEvent); 
				this.lastMousePositionY=mousePos.y; 
				this.lastMousePositionX=mousePos.x; 
				//theImageRotator.cancelAutoRotate();  
				return false;
			} );
			slider.on( 'mousemove', function( event ) { 
				var mousePos = zDrag_mouseCoords(event.originalEvent); 

				var differenceY=this.lastMousePositionY-mousePos.y;
				if(Math.abs(differenceY) < 30){
					event.preventDefault(); 
				}
				if(typeof this.lastMousePositionX != "undefined"){ 
					var differenceX=this.lastMousePositionX-mousePos.x;
					if(differenceX < 0){
						if(differenceX < -30){ 
							self.previous();
						}
					}else{
						if(differenceX > 30){ 
							self.next();
						}
					}
					if(Math.abs(differenceX) > 30){
						this.lastMousePositionX=mousePos.x;
					}
				}
				if(Math.abs(differenceY) < 30){
					return false;
				}else{
					return true;
				}
			} );
			slider.on( 'mouseup mouseout', function( event ) {
				event.preventDefault();
				delete this.lastMousePositionX;
				return false;
			} ); 

			slider.on( 'touchstart', function( event ) {  
				this.lastTouchPosition=event.originalEvent;  
			} );
			slider.on( 'touchmove', function( event ) {
				if(typeof this.lastTouchPosition =="undefined" || typeof this.lastTouchPosition.touches == "undefined"){
					return;
				}
				var differenceY=this.lastTouchPosition.touches[0].pageY-event.originalEvent.touches[0].pageY; 
				if(Math.abs(differenceY) < 30){
					event.preventDefault(); 
				} 
				if(typeof this.lastTouchPosition != "undefined"){ 
					var differenceX=this.lastTouchPosition.touches[0].pageX-event.originalEvent.touches[0].pageX; 
					if(differenceX < 0){
						if(differenceX < -30){ 
							self.previous();
						}
					}else{
						if(differenceX > 30){ 
							self.next();
						}
					}
					if(Math.abs(differenceX) > 30){
						this.lastTouchPosition=event.originalEvent;
					}
				}
				if(Math.abs(differenceY) < 30){
					return false; 
				} 
			} );
			slider.on( 'touchend', function( event ) { 
				delete this.lastTouchPosition;
				return false;
			} ); 
		}
		function setActivePager(){
			if ( options.pager ) {
				$( 'span', pager ).removeClass( 'active' );
				$( 'span[data-slide-index="' + currentSlideIndex + '"]', pager ).addClass( 'active' );
			}
			$(options.selector+" .threePanelSlide").removeClass("active");
			$(options.selector+" ."+arrPanelOrder[middlePanelOffset]).addClass("active");
		}

		function resetInterval( doAnimation ) {
			if ( options.auto ) {
				clearInterval( sliderInterval );

				sliderInterval = setInterval( function() {
					var doAnimation = typeof doAnimation !== 'undefined' ? doAnimation : true;

					self.animateToSlide(getSlideIndex(currentSlideIndex, 1), 1);
				}, options.timeout );
			}
		}
		function attachNextPreviousButtons() {
			slider.append( '<div class="slider-previous-button">' + options.previousButton + '</div><div class="slider-next-button">' + options.nextButton + '</div>' );

			previousButton = $( '.slider-previous-button', slider );
			nextButton     = $( '.slider-next-button', slider ); 

			previousButton.on( 'mousedown touchstart', function( event ) {
				if((event.type == "mousedown") && event.which!=1){
					return;
				}
				event.preventDefault();  
				this.clickTouchStart=true;
			} );
			previousButton.on( 'mouseup touchend', function( event ) {
				if(typeof this.clickTouchStart == "undefined" || !this.clickTouchStart){
					return;
				}
				if((event.type == "mouseup") && event.which!=1){
					return;
				}
				this.clickTouchStart=false;
				self.previous();
			});
			nextButton.on( 'mousedown touchstart', function( event ) {
				if((event.type == "mousedown") && event.which!=1){
					return;
				}
				event.preventDefault(); 
				this.clickTouchStart=true;
			} );
			nextButton.on( 'mouseup touchend', function( event ) {
				if(typeof this.clickTouchStart == "undefined" || !this.clickTouchStart){
					return;
				}
				this.clickTouchStart=false;
				self.next();
			});
		}
		function attachPager() {
			slider.append( '<div class="slider-pager ' + options.pagerStyle + '"></div>' );

			pager = $( '.slider-pager', slider );

			for(var i=0;i<options.arrSlide.length;i++){
				pager.append( '<span data-slide-index="' + i + '"></span>' );
			}

			pager.on( 'mousedown touchstart', 'span', function( event ) { 
				if((event.type == "mousedown") && event.which!=1){
					return;
				}
				this.clickTouchStart=true;
			});
			pager.on( 'mouseup touchend', 'span', function( event ) {
				event.preventDefault();
				if((event.type == "mouseup") && event.which!=1){
					return;
				}
				if(typeof this.clickTouchStart == "undefined" || !this.clickTouchStart){
					return;
				} 
				this.clickTouchStart=false;
				var pagerSlideIndex = parseInt($( this ).attr( 'data-slide-index' ));
 
				if ( pagerSlideIndex == currentSlideIndex ) {
					// Don't switch slides if we clicked on the active slide pager.
					return false;
				} 
				if ( options.auto ) {
					resetInterval(true);
				}  
				self.queueAnimateToSlide(pagerSlideIndex); 
				return false;
			} ); 
		}
		function resizeSlider(){
			//d.slideWidth=$(options.selector+" .threePanelSlide > div").width();
			var sliderWidth=slider.width();
			//console.log(d);
			var maxHeight=0;
			$(options.selector+" .threePanelSlide").each(function(){
				maxHeight=Math.max(maxHeight, zGetAbsPosition(this).height);
			});
			//console.log("maxHeight:"+maxHeight);
			$(options.selector+" .threePanelSlider").height(maxHeight);


			if(!firstLoad && options.nextPrevious){ 
				var centerClassHeight=0;
				$(options.nextPreviousCenterClass).each(function(){
					centerClassHeight=Math.max(centerClassHeight, zGetAbsPosition(this).height);
				});
				//console.log("centerClassHeight:"+centerClassHeight+" length:"+$(options.nextPreviousCenterClass).length);
				nextButton.css("top", Math.round((centerClassHeight/2))+"px");
				previousButton.css("top", Math.round((centerClassHeight/2))+"px");
			}
		}
		function getSlideIndex(currentSlideIndex, offset){
			var slideIndex=currentSlideIndex+offset;
			if(slideIndex >= options.arrSlide.length){
				var remainder=slideIndex-(options.arrSlide.length);
				if(remainder>=options.arrSlide.length){
					return options.arrSlide.length-1;
				}else{
					return remainder;
				}
			}else if(slideIndex < 0){ 
				var remainder=options.arrSlide.length-Math.abs(slideIndex);
				if(remainder < 0){
					return options.arrSlide.length-1;
				}else{
					return remainder;
				}
			}else{
				return slideIndex;
			}
		}
		function reloadSlides(animate, direction){ 
			var slideIndex=currentSlideIndex;
			var arrHTML=[];
			var arrPanelOrderNew=[];
			slideNameOffset++;
			console.log('reloadSlides: '+options.selector+' panelCount:'+panelCount);
			for(var i=0;i<panelCount;i++){
				var loadSlideIndex=getSlideIndex(slideIndex, i-middlePanelOffset ); 
				//console.log("reloadSlides loadSlideIndex: "+loadSlideIndex+":"+typeof slideIndex);
				var slide=options.arrSlide[loadSlideIndex];
				arrHTML.push('<div class="threePanelSlide threePanelSlide'+slideNameOffset+' threePanelSlide'+slideNameOffset+"_"+(i+1)+' ');
				if(i == middlePanelOffset){
					arrHTML.push(' active');
				}
				left=Math.round(((100-options.slideWidthPercent)/2)*100)/100;
				arrHTML.push('" style="position:absolute; z-index:'+(slideNameOffset+1)+'; width:'+options.slideWidthPercent+'%; left:'+left+'%;">'+slide.html+'</div>');
				arrPanelOrderNew.push("threePanelSlide"+slideNameOffset+"_"+(i+1));
			}
			//console.log(arrHTML);
			$(options.selector+" .threePanelSlider").append(arrHTML.join(""));
			var loadCount=0;
			var totalImages=$(options.selector+' .threePanelSlide'+slideNameOffset+" img").length;
			var $slideImages=$(options.selector+' .threePanelSlide'+slideNameOffset+" img");
			setInterval(function(){ 
				$slideImages.each(function(){
					if(this.complete && typeof this.slideImageLoaded == "undefined"){
						loadCount++;
						this.slideImageLoaded=true; 
						if(loadCount==totalImages){ 
							$(options.selector).show();
							if(firstLoad){
								firstLoadInit();
							}
							resizeSlider();
						}
					}
				});
			}, 100);
			$slideImages.load(function(e){ 
				loadCount++;
				if(loadCount==totalImages){
					//console.log(options.selector+' loadCount:'+loadCount+'== totalImages:'+totalImages);
					$(options.selector).show();
					if(firstLoad){
						firstLoadInit();
					}
					resizeSlider();
				} 
			}); 
			
			//var firstPercent=-116.66;  
			for(var i=0;i<=arrPanelOrderNew.length-1;i++){
				var m=arrPanelOrderNew[i];
				var left=firstPercent+((i)*options.slideWidthPercent);  
				if(animate){  
					$(options.selector+" ."+m).css({ 
						"left":(Math.round((left+(panelCount*options.slideWidthPercent*direction))*100)/100)+"%"
					}).animate({
						"left": (left)+"%"
					}, 'slow','easeInExpo', function(){
						animating=false; 
					}); 
				}else{
					$(options.selector+" ."+m).css({
						"left": (left)+"%"
					}); 
				}
			} 
			arrPanelOrder=arrPanelOrderNew;

			$(options.selector+" .threePanelSlide a").on("mousedown touchstart", function(e){
				if((event.type == "mousedown") && event.which!=1){
					return;
				}
				this.clickTouchStart=true; 
			});
			$(options.selector+" .threePanelSlide a").on("mouseup touchend", function(e){ 
				if((event.type == "mouseup") && event.which!=1){
					return;
				} 
				if(typeof this.clickTouchStart == "undefined" || !this.clickTouchStart){
					return;
				}
				this.clickTouchStart=false;
				window.location.href=this.href;
			});
		}

		self.next=function(){
			self.animateToSlide(getSlideIndex(currentSlideIndex, 1), 1);
			resetInterval(true);
		}
		self.previous=function(){
			self.animateToSlide(getSlideIndex(currentSlideIndex, -1), -1);
			resetInterval(true);
		}
		var arrAnimateQueue=[];
		self.queueAnimateToSlide=function(slideIndex){
			arrAnimateQueue.push(slideIndex);
			console.log(slideIndex);
		}
		function executeAnimationQueue(){ 
			if(!animating && arrAnimateQueue.length){
				var slideIndex=arrAnimateQueue.pop();
				var offset=slideIndex-currentSlideIndex; 
				self.animateToSlide(getSlideIndex(currentSlideIndex, offset), offset);
				arrAnimateQueue=[];
			}
		};
		self.animateToSlide=function(slideIndex, offset){
			if(animating){
				return;
			}
			//console.log("animateToSlide:  current:"+currentSlideIndex+" next:"+slideIndex); 
			animating=true;
			if(offset==0){
				// do nothing
				//console.log('doNothingToSlides');
				animating=false;
				return;
			}else if(offset==-1){
				if(direction==0){
					direction=-1;
				}
				// previous
				//console.log('previousSlide');

				// change panel order
				var firstPanel=arrPanelOrder[0];
				var lastPanel=arrPanelOrder.pop();
				arrPanelOrder.unshift(lastPanel);
				$("."+lastPanel).insertBefore("."+firstPanel); 
	 
				//console.log(arrPanelOrder);
	 
				// get the photo index to load
				var loadSlideIndex=getSlideIndex(slideIndex, -middlePanelOffset);
 
				//console.log("previous:"+loadSlideIndex);
				var slide=options.arrSlide[loadSlideIndex];
				$(options.selector+" ."+lastPanel).html(slide.html);
				//console.log('loadSlideIndex:'+loadSlideIndex);
	 
				//var firstPercent=-116.66;
				for(var i=0;i<arrPanelOrder.length;i++){
					var left=firstPercent+((i)*options.slideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).css({
						"left":(Math.round((left-options.slideWidthPercent)*100)/100)+"%"
					}).animate({
						"left": (left)+"%"
					}, 'slow','easeInExpo', function(){
						animating=false;
					});
				} 

			}else if(offset==1){ 
				// next
				//console.log('nextSlide');

				// get the photo index to load
				var loadSlideIndex=getSlideIndex(slideIndex, middlePanelOffset);

				//console.log("next:"+loadSlideIndex);
				// change panel order
				var lastPanel=arrPanelOrder[arrPanelOrder.length-1];
				var firstPanel=arrPanelOrder.shift();
				arrPanelOrder.push(firstPanel);

				// get the photo index to load
				var loadSlideIndex=getSlideIndex(slideIndex, middlePanelOffset);

				var slide=options.arrSlide[loadSlideIndex];
				// TODO: create img element here and animate onload instead
				$(options.selector+" ."+firstPanel).html(slide.html);

				//firstPercent=-116.66;
				for(var i=0;i<arrPanelOrder.length;i++){
					var left=firstPercent+((i)*options.slideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).css({
						"left":(Math.round((left+options.slideWidthPercent)*100)/100)+"%"
					}).animate({
						"left": (left)+"%"
					}, 'slow','easeInExpo', function(){
						animating=false;
					});
				} 
			}else{
				// reload all slides
				//console.log('reload all slides');  
				// animate all the existing slides offscreen
				//firstPercent=-116.66;
				if(offset>0){
					var direction=1;
				}else{
					var direction=-1;
				}
				for(var i=0;i<=arrPanelOrder.length-1;i++){
					var left=firstPercent+((i)*options.slideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).animate({
						"left": (left-(options.slideWidthPercent*panelCount*direction))+"%"
					}, 'slow','easeInExpo', function(){ 
						animating=false;
						$(this).remove();
					});
				}  
				currentSlideIndex=slideIndex;
				reloadSlides(true, direction); 
			}
			currentSlideIndex=slideIndex;
			setActivePager();
			resetInterval(true);
		}
		init();

	}
	window.zThreePanelSlider=zThreePanelSlider;
})(jQuery, window, document, "undefined"); 