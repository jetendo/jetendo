// the other dimensions should be options


(function($, window, document, undefined){
	"use strict";
	function zThreePanelSlider(options){
		var self=this;

		var animating=false; 
		var currentSlideIndex=0;
		var direction=0;
		var d={
			slides:$(options.selector+" .threePanelSlider > div"),
			container:$(options.selector),
			arrPanelOrder:["threePanelSlide1", "threePanelSlide2", "threePanelSlide3", "threePanelSlide4", "threePanelSlide5"]
		};
		var slideNameOffset=0;
		var sliderInterval=false;
		var pager=false;
		var firstLoad=true;		
		var previousButton=false;
		var nextButton=false;

		d.slideCount=d.slides.length;
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

			d.container.on( 'mousedown', function( event ) {
				event.preventDefault(); 
				var mousePos = zDrag_mouseCoords(event.originalEvent); 
				this.lastMousePositionY=mousePos.y; 
				this.lastMousePositionX=mousePos.x; 
				//theImageRotator.cancelAutoRotate();  
				return false;
			} );
			d.container.on( 'mousemove', function( event ) { 
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
			d.container.on( 'mouseup mouseout', function( event ) {
				event.preventDefault();
				delete this.lastMousePositionX;
				return false;
			} ); 

			d.container.on( 'touchstart', function( event ) {  
				this.lastTouchPosition=event.originalEvent;  
			} );
			d.container.on( 'touchmove', function( event ) {
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
			d.container.on( 'touchend', function( event ) { 
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
			$(options.selector+" ."+d.arrPanelOrder[2]).addClass("active");
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
			d.container.append( '<div class="slider-previous-button">' + options.previousButton + '</div><div class="slider-next-button">' + options.nextButton + '</div>' );

			previousButton = $( '.slider-previous-button', d.container );
			nextButton     = $( '.slider-next-button', d.container ); 

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
			d.container.append( '<div class="slider-pager ' + options.pagerStyle + '"></div>' );

			pager = $( '.slider-pager', d.container );

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
			d.slideWidth=$(options.selector+" .threePanelSlide > div").width();
			d.containerWidth=d.container.width();
			//console.log(d);
			var maxHeight=0;
			$(options.selector+" .threePanelSlide").each(function(){
				maxHeight=Math.max(maxHeight, zGetAbsPosition(this).height);
			});
			//console.log("maxHeight:"+maxHeight);
			$(options.selector+" .threePanelSlider").height(maxHeight);


			if(!firstLoad && options.nextPrevious && options.nextPreviousCenterClass != ""){ 
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
					//console.log('branch1 currentSlideIndex:'+currentSlideIndex+' | offset:'+offset);
					return options.arrSlide.length-1;
				}else{
					//console.log('branch2 currentSlideIndex:'+currentSlideIndex+' | offset:'+offset);
					return remainder;
				}
			}else if(slideIndex < 0){ 
				var remainder=options.arrSlide.length-Math.abs(slideIndex);
				if(remainder < 0){
					//console.log('branch3 currentSlideIndex:'+currentSlideIndex+' | offset:'+offset);
					return options.arrSlide.length-1;
				}else{
					//console.log('branch4 currentSlideIndex:'+currentSlideIndex+' | offset:'+offset);
					return remainder;
				}
			}else{
				//console.log('branch5 currentSlideIndex:'+currentSlideIndex+' | offset:'+offset);
				return slideIndex;
			}
		}
		function reloadSlides(animate, direction){ 
			var slideIndex=currentSlideIndex;
			var arrHTML=[];
			var arrPanelOrderNew=[];
			slideNameOffset++;
			for(var i=0;i<5;i++){
				var loadSlideIndex=getSlideIndex(slideIndex, i-2); 
				//console.log("reloadSlides loadSlideIndex: "+loadSlideIndex+":"+typeof slideIndex);
				var slide=options.arrSlide[loadSlideIndex];
				arrHTML.push('<div class="threePanelSlide threePanelSlide'+slideNameOffset+' threePanelSlide'+slideNameOffset+"_"+(i+1)+' ');
				if(i == 2){
					arrHTML.push(' active');
				}
				arrHTML.push('" style="position:absolute; z-index:'+(slideNameOffset+1)+'; left:13%;">'+slide.html+'</div>');
				arrPanelOrderNew.push("threePanelSlide"+slideNameOffset+"_"+(i+1));
			}
			$(options.selector+" .threePanelSlider").append(arrHTML.join(""));
			var loadCount=0;
			var totalImages=$('.threePanelSlide'+slideNameOffset+" img").length;
			$('.threePanelSlide'+slideNameOffset+" img").load(function(e){ 
				loadCount++;
				if(loadCount==totalImages){
					$(options.selector).show();
					if(firstLoad){
						firstLoadInit();
					}
					resizeSlider();
				} 
			}); 
			
			var firstPercent=-116.66; 
			for(var i=0;i<=arrPanelOrderNew.length-1;i++){
				var m=arrPanelOrderNew[i];
				var left=firstPercent+((i)*66.66);  
				if(animate){  
					$(options.selector+" ."+m).css({ 
						"left":(Math.round((left+(3*66.66*direction))*100)/100)+"%"
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
			d.arrPanelOrder=arrPanelOrderNew;

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
			if(animating){
				if(arrAnimateQueue[arrAnimateQueue.length-1] != slideIndex){
					arrAnimateQueue.push(slideIndex);
				}
			}else{
				var offset=slideIndex-currentSlideIndex;
				console.log('queue:'+slideIndex+":"+currentSlideIndex);
				self.animateToSlide(getSlideIndex(currentSlideIndex, offset), offset);
			}
		}
		function executeAnimationQueue(){ 
			if(arrAnimateQueue.length){
				var slideIndex=arrAnimateQueue.shift();
				var offset=slideIndex-currentSlideIndex; 
				self.animateToSlide(getSlideIndex(currentSlideIndex, offset), offset);
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
				var firstPanel=d.arrPanelOrder[0];
				var lastPanel=d.arrPanelOrder.pop();
				d.arrPanelOrder.unshift(lastPanel);
				$("."+lastPanel).insertBefore("."+firstPanel); 
	 
				//console.log(d.arrPanelOrder);
	 
				// get the photo index to load
				var loadSlideIndex=getSlideIndex(slideIndex, -2);
 
				//console.log("previous:"+loadSlideIndex);
				var slide=options.arrSlide[loadSlideIndex];
				$(options.selector+" ."+lastPanel).html(slide.html);
				//console.log('loadSlideIndex:'+loadSlideIndex);
	 
				var firstPercent=-116.66;
				for(var i=0;i<d.arrPanelOrder.length;i++){
					var left=firstPercent+((i)*66.66);  
					$(options.selector+" ."+d.arrPanelOrder[i]).css({
						"left":(Math.round((left-66.66)*100)/100)+"%"
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
				var loadSlideIndex=getSlideIndex(slideIndex, 2);

				//console.log("next:"+loadSlideIndex);
				// change panel order
				var lastPanel=d.arrPanelOrder[4];
				var firstPanel=d.arrPanelOrder.shift();
				d.arrPanelOrder.push(firstPanel);

				// get the photo index to load
				var loadSlideIndex=getSlideIndex(slideIndex, 2);

				var slide=options.arrSlide[loadSlideIndex];
				// TODO: create img element here and animate onload instead
				$(options.selector+" ."+firstPanel).html(slide.html);

				firstPercent=-116.66;
				for(var i=0;i<d.arrPanelOrder.length;i++){
					var left=firstPercent+((i)*66.66);  
					$(options.selector+" ."+d.arrPanelOrder[i]).css({
						"left":(Math.round((left+66.66)*100)/100)+"%"
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
				firstPercent=-116.66;
				if(offset>0){
					var direction=1;
				}else{
					var direction=-1;
				}
				for(var i=0;i<=d.arrPanelOrder.length-1;i++){
					var left=firstPercent+((i)*66.66);  
					$(options.selector+" ."+d.arrPanelOrder[i]).css({
						//"left":(Math.round((left+66.66)*100)/100)+"%"
					}).animate({
						"left": (left-(66.66*3*direction))+"%"
					}, 'slow','easeInExpo', function(){ 
						animating=false;
						$(this).remove();
					});
				} 
				//return;
				// probably need to set currentSlideIndex sooner?
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