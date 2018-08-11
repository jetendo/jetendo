// rename to multiPanelSlider
// allow clicking on other slides to make them active
/*
// usage
*/

(function($, window, document, undefined){
	"use strict";
	var slideNameOffset=0;
	function zMultiPanelSlider(options){
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
		options.slideMinimumWidth=zso(options, 'slideMinimumWidth', true, 200);
		options.animationStyle=zso(options, 'animationStyle', false, "click");
		options.mouseMoveMinVelocity=zso(options, 'mouseMoveMinVelocity', true, 0); // should be 0 or higher
		options.mouseMoveMaxVelocity=zso(options, 'mouseMoveMaxVelocity', true, 5); // should be greater then 0
		options.mouseMoveVelocityChangeSpeed=zso(options, 'mouseMoveVelocityChangeSpeed', false, 0.4); // should be greater then 0
		options.mouseMoveDeadZone=zso(options, 'mouseMoveDeadZone', false, 0.25); // should be greater then zero and less then 0.5
		if(options.animationStyle=="mouseMove" && options.pager){
			throw('options.pager must be false when options.animationStyle=="mouseMove"');
		}
   
		var sliderInterval=false;
		var pager=false;
		var firstLoad=true;		
		var previousButton=false;
		var nextButton=false;
		var panelCount=1;
		var middlePanelOffset=0;
		var left=0;
		var firstPercent=0;
		var animating=false; 
		var currentSlideIndex=0;
		var direction=0;
		var slider=$(options.selector);
		var arrPanelOrder=[];
		var currentSlideWidthPercent=Math.round(options.slideWidthPercent*100)/100;
 		updateSlideWidth();

		if(slider.length==0){
			console.log("zMultiPanelSlider: options.selector not found: "+options.selector);
			return;
		}
		if(options.arrSlide.length==0){
			console.log("zMultiPanelSlider: options.arrSlide has no slides");
			return;
		}
		if(options.nextPreviousCenterClass==""){
			options.nextPreviousCenterClass=options.selector+" .multiPanelSlide";
		} 
		slider.append('<div class="multiPanelSliderBackground"><div class="multiPanelSlider"></div></div>');  

		function init(){
			reloadSlides(false, 0); 
			zArrResizeFunctions.push({functionName:resizeSlider}); 
		}

		var updateSlideWidthIntervalId=false;
		function updateSlideWidth(){ 
			var display=slider.css("display");
			if(display == "" || display == "none"){
				slider.show();
				var sliderPosition=zGetAbsPosition(slider[0]);
				slider.hide();
			}else{
				var sliderPosition=zGetAbsPosition(slider[0]);
			} 
			var slideWidth=Math.round(sliderPosition.width*(options.slideWidthPercent/100));
			//console.log("before currentSlideWidthPercent:"+currentSlideWidthPercent);
			if(slideWidth<options.slideMinimumWidth){
				currentSlideWidthPercent=Math.round((options.slideMinimumWidth/sliderPosition.width)*10000)/100;
			}
			var lastPanelCount=panelCount;
			panelCount=Math.round(100/currentSlideWidthPercent)+3; 
			//console.log("fix panelCount:"+panelCount+" : "+Math.floor(panelCount/2));
			if(panelCount % 2 == 0){
				// force to odd number of panels
				panelCount++;
			}
			middlePanelOffset=Math.floor(panelCount/2);
			//console.log("panelCount:"+panelCount+" middlePanelOffset:"+middlePanelOffset);

			left=Math.round(((100-currentSlideWidthPercent)/2)*100)/100;
			firstPercent=Math.round((left-(currentSlideWidthPercent*middlePanelOffset))*100)/100;
			//console.log("firstPercent:"+firstPercent);
			//console.log(sliderPosition);
			//console.log("sliderPosition.width: "+sliderPosition.width+" panelCount:"+panelCount+" slideWidth:"+slideWidth+" options.slideMinimumWidth:"+options.slideMinimumWidth+"  currentSlideWidthPercent:"+currentSlideWidthPercent+" firstPercent:"+firstPercent+" left:"+left);
			// reposition all the slides - reload if panel count should change

			clearInterval(updateSlideWidthIntervalId);
			updateSlideWidthIntervalId=false;
			updateSlideWidthIntervalId=setInterval(function(){
				// can't do this while animating is true
				if(animating){
					return; 
				}
				clearInterval(updateSlideWidthIntervalId);
				updateSlideWidthIntervalId=false; 
				if(panelCount != lastPanelCount){
					lastPanelCount=panelCount;
					$(options.selector+' .multiPanelSlide').remove();
					reloadSlides(false, 0); 
				}
			}, 100);
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
					self.setActivePager();
				}
	  
				resetInterval( false );
			}
			setInterval(function(){
				executeAnimationQueue();
			}, 300);
		}
 
		var mouseHasMoved=false;
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
				mouseHasMoved=true;
				var mousePos = zDrag_mouseCoords(event.originalEvent); 

				var differenceY=this.lastMousePositionY-mousePos.y;
				if(Math.abs(differenceY) < 50){
					event.preventDefault(); 
				}
				if(typeof this.lastMousePositionX != "undefined"){ 
					var differenceX=this.lastMousePositionX-mousePos.x;
					if(differenceX < 0){
						if(differenceX < -50){ 
							self.previous();
						}
					}else{
						if(differenceX > 50){ 
							self.next();
						}
					}
					if(Math.abs(differenceX) > 50){
						this.lastMousePositionX=mousePos.x;
					}
				}
				if(Math.abs(differenceY) < 50){
					return false;
				}else{
					return true;
				}
			} );
			slider.on( 'select', function(e){
				e.preventDefault();
			});
			slider.on( 'mouseup mouseout', function( event ) {
				//event.preventDefault();
				delete this.lastMousePositionY;
				delete this.lastMousePositionX;
				//return false;
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
				//return false;
			} ); 
		}
		self.setActivePager=function(){
			if ( options.pager ) {
				$( 'span', pager ).removeClass( 'active' );
				$( 'span[data-slide-index="' + currentSlideIndex + '"]', pager ).addClass( 'active' );
			}
			$(options.selector+" .multiPanelSlide").removeClass("active");
			$(options.selector+" ."+arrPanelOrder[middlePanelOffset]).addClass("active");
		}

		function resetInterval( doAnimation ) {
			clearInterval( sliderInterval );
			if ( options.auto ) {

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
			//d.slideWidth=$(options.selector+" .multiPanelSlide > div").width(); 
 			updateSlideWidth();
			var sliderWidth=slider.width();
			//console.log(d);
			var maxHeight=0;
			$(options.selector+" .multiPanelSlide").each(function(){
				maxHeight=Math.max(maxHeight, zGetAbsPosition(this).height);
			});
			//console.log("maxHeight:"+maxHeight);
			$(options.selector+" .multiPanelSlider").height(maxHeight);


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
			//console.log('reloadSlides: '+options.selector+' panelCount:'+panelCount);
			for(var i=0;i<panelCount;i++){
				var loadSlideIndex=getSlideIndex(slideIndex, i-middlePanelOffset ); 
				//console.log("reloadSlides loadSlideIndex: "+loadSlideIndex+":"+typeof slideIndex);
				var slide=options.arrSlide[loadSlideIndex];
				arrHTML.push('<div class="multiPanelSlide multiPanelSlide'+slideNameOffset+' multiPanelSlide'+slideNameOffset+"_"+(i+1)+' ');
				if(i == middlePanelOffset){
					arrHTML.push(' active');
				}
				left=Math.round(((100-currentSlideWidthPercent)/2)*100)/100;
				arrHTML.push('" style="position:absolute; z-index:'+(slideNameOffset+1)+'; width:'+currentSlideWidthPercent+'%; left:'+left+'%;">'+slide.html+'</div>');
				arrPanelOrderNew.push("multiPanelSlide"+slideNameOffset+"_"+(i+1));
			}
			//console.log(arrHTML);
			$(options.selector+" .multiPanelSlider").append(arrHTML.join(""));
			var loadCount=0;
			var totalImages=$(options.selector+' .multiPanelSlide'+slideNameOffset+" img").length;
			var $slideImages=$(options.selector+' .multiPanelSlide'+slideNameOffset+" img");
			setInterval(function(){ 
				$slideImages.each(function(){
					if(this.complete && typeof this.slideImageLoaded == "undefined"){
						loadCount++;
						this.slideImageLoaded=true; 
						if(loadCount==totalImages){ 
							$(options.selector).show();
							if(firstLoad){
								firstLoadInit();
								resizeSlider();
							}
							//resizeSlider();
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
						resizeSlider();
					}
					//resizeSlider();
				} 
			}); 
			
			//var firstPercent=-116.66;  
			for(var i=0;i<=arrPanelOrderNew.length-1;i++){
				var m=arrPanelOrderNew[i];
				var left=firstPercent+((i)*currentSlideWidthPercent);  
				if(animate){  
					$(options.selector+" ."+m).css({ 
						"left":(Math.round((left+(panelCount*currentSlideWidthPercent*direction))*100)/100)+"%"
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

			$(options.selector+" .multiPanelSlide a").on("mousedown touchstart", function(e){
				if((event.type == "mousedown") && event.which!=1){
					return;
				}
				this.clickTouchStart=true; 
			});
			$(options.selector+" .multiPanelSlide a").on("mouseup touchend", function(e){ 
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
			options.auto=false;
			resetInterval(true);
		}
		self.previous=function(){
			self.animateToSlide(getSlideIndex(currentSlideIndex, -1), -1);
			options.auto=false;
			resetInterval(true);
		}
		var arrAnimateQueue=[];
		self.queueAnimateToSlide=function(slideIndex){
			options.auto=false;
			arrAnimateQueue.push(slideIndex);
			//console.log(slideIndex);
		}
		function executeAnimationQueue(){ 
			if(!animating && arrAnimateQueue.length){
				var slideIndex=arrAnimateQueue.pop();
				var offset=slideIndex-currentSlideIndex; 
				self.animateToSlide(getSlideIndex(currentSlideIndex, offset), offset);
				arrAnimateQueue=[];
			}
		};
 
		var currentVelocity=0; 
		var panelLeftCache={}; 
		var panelTotalOffset=0;
		function runAnimation(){   
			if(options.animationStyle != "mouseMove"){ 
				return;
			}
			if(zWindowSize.width<=992){ 
				window.requestAnimationFrame(runAnimation);
				return;
			}
			animating=false;

			panelTotalOffset+=currentVelocity;
			if(Math.abs(panelTotalOffset) >= currentSlideWidthPercent){ 
				panelLeftCache=[];
				var slideIndex=currentSlideIndex; 
				if(panelTotalOffset>0){   
					var firstPanel=arrPanelOrder[0];
					var lastPanel=arrPanelOrder.pop();
					arrPanelOrder.unshift(lastPanel);  
					var loadSlideIndex=getSlideIndex(slideIndex, -middlePanelOffset-1); 
					var slide=options.arrSlide[loadSlideIndex]; 
					$(options.selector+" ."+lastPanel).html(slide.html); 
					currentSlideIndex=getSlideIndex(slideIndex, -1);
				}else if(panelTotalOffset<0){  
					var loadSlideIndex=getSlideIndex(slideIndex, middlePanelOffset+1);  
					var firstPanel=arrPanelOrder.shift();
					arrPanelOrder.push(firstPanel);   
					var slide=options.arrSlide[loadSlideIndex]; 
					$(options.selector+" ."+firstPanel).html(slide.html); 
					currentSlideIndex=getSlideIndex(slideIndex, 1);  
				} 
				panelTotalOffset=0;
			}
			for(var i=0;i<arrPanelOrder.length;i++){
				var panel=$(options.selector+" ."+arrPanelOrder[i])[0];
				if(typeof panelLeftCache[arrPanelOrder[i]]=="undefined"){
					var left=firstPercent+((i)*currentSlideWidthPercent);
					panelLeftCache[arrPanelOrder[i]]=left; 
				}
				panelLeftCache[arrPanelOrder[i]]+=currentVelocity;
				var newLeft=(Math.round(panelLeftCache[arrPanelOrder[i]]*100)/100)+"%"; 
				panel.style.left=newLeft;
			}  

			window.requestAnimationFrame(runAnimation);
		};  

		setInterval(function(){
			if(zWindowSize.width<=992){
				currentVelocity=0;
				return;
			}
			if(options.animationStyle != "mouseMove"){ 
				return;
			}
			if(!mouseHasMoved){
				return;
			}
			var pos=zGetAbsPosition(slider[0]); 

			var sliderWidth=pos.width;

			var percentMouseX=(zMousePosition.x-pos.x)/sliderWidth;
			var velocityRange=options.mouseMoveMaxVelocity-options.mouseMoveMinVelocity;
			var newVelocity=0;
			var reducedVelocityChange=0;
			// see if we're out of the dead zone
			var halfDeadZone=options.mouseMoveDeadZone/2;
			var liveZone=0.5-halfDeadZone;
			if(percentMouseX<liveZone){
				// left, negative
				newVelocity=((liveZone-percentMouseX)/liveZone)*velocityRange;
				//currentVelocity=((0.25-percentMouseX)/0.25)*velocityRange;
			}else if(percentMouseX>0.5+halfDeadZone){
				// right, positive
				newVelocity=-((percentMouseX-(0.5+halfDeadZone))/liveZone)*velocityRange;
				//currentVelocity=-((percentMouseX-0.75)/0.25)*velocityRange;  
			}
			var reducedVelocityChange=(newVelocity-currentVelocity)*options.mouseMoveVelocityChangeSpeed;
			if(Math.abs(reducedVelocityChange)<=0.01 && Math.abs(currentVelocity)<=0.01){
				// force it to stop when its too slow
				reducedVelocityChange=0;
				currentVelocity=0;
			}else{
				//console.log("currentVelocity:"+currentVelocity+" newVelocity:"+newVelocity+" | reducedVelocityChange:"+reducedVelocityChange);
			}
			currentVelocity=currentVelocity+reducedVelocityChange;
			if(currentVelocity<0){
				currentVelocity=Math.max(-options.mouseMoveMaxVelocity, currentVelocity);
			}else if(currentVelocity>0){
				currentVelocity=Math.min(options.mouseMoveMaxVelocity, currentVelocity);
			}  
		}, 100);
		runAnimation(); 
		self.animateToSlide=function(slideIndex, offset){
			if(options.animationStyle=="mouseMove"){
				if(zWindowSize.width>992){
					return;
				}
			}
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
					var left=firstPercent+((i)*currentSlideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).css({
						"left":(Math.round((left-currentSlideWidthPercent)*100)/100)+"%"
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
					var left=firstPercent+((i)*currentSlideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).css({
						"left":(Math.round((left+currentSlideWidthPercent)*100)/100)+"%"
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
					var left=firstPercent+((i)*currentSlideWidthPercent);  
					$(options.selector+" ."+arrPanelOrder[i]).animate({
						"left": (left-(currentSlideWidthPercent*panelCount*direction))+"%"
					}, 'slow','easeInExpo', function(){ 
						animating=false;
						$(this).remove();
					});
				}  
				currentSlideIndex=slideIndex;
				reloadSlides(true, direction); 
			}
			currentSlideIndex=slideIndex;
			self.setActivePager();
			resetInterval(true);
		} 
  
		init();

	}
	window.zMultiPanelSlider=zMultiPanelSlider;
})(jQuery, window, document, "undefined"); 