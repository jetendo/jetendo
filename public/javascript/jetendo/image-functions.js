
var zLoadAndCropImagesIndex=0;
var zArrSlideshowIds=[];
var zArrGalleryViewSlideshowTemplate=[];
var zGalleryReloadTimeoutId=0; 
(function($, window, document, undefined){
	"use strict";

	function zLoadAndCropImages(){
		var debug=false;
		var e=zGetElementsByClassName("zLoadAndCropImage");
		var time=new Date().getTime();
		for(var i=0;i<e.length;i++){
			if(e[i].getAttribute("data-imageloaded")==="1"){
				c=$("canvas", e[i]);
				c[0].style.maxWidth="99%";
				continue;
			}
			e[i].setAttribute("data-imageloaded", "1");
			var url=e[i].getAttribute("data-imageurl");
			var style=e[i].getAttribute("data-imagestyle");
			var width=parseInt(e[i].getAttribute("data-imagewidth"));
			var height=parseInt(e[i].getAttribute("data-imageheight"));
			var crop=false;
			if(e[i].getAttribute("data-imagecrop")==="1"){
				crop=true;
			}
			if(typeof e[i].style.maxWidth !== "undefined" && e[i].style.maxWidth !== ""){
				var tempWidth=parseInt(e[i].style.maxWidth);
				if(tempWidth<width){
					width=tempWidth;
					height=width;
				}
			}
			zLoadAndCropImage(e[i], url, debug, width, height, crop, style);
		}
	}
	function zLoadAndCropImagesDefer(){
		setTimeout(zLoadAndCropImages, 1);
		setTimeout(zLoadAndCropImages, 3000);
	}

	zArrLoadFunctions.push({functionName:zLoadAndCropImagesDefer});
	function zLoadAndCropImage(obj, imageURL, debug, width, height, crop, style){ 
		// TODO: someday figure out how to make crop always work, for now, i gave up.
		// if((zMSIEBrowser!==-1 && zMSIEVersion<=9) || window.location.href.indexOf("disableCanvasCrop=") != -1){
			if(height===10000){
				obj.innerHTML='<img src="'+imageURL+'" alt="Image" style="max-width:100%;" />';
			}else{
				obj.innerHTML='<img src="'+imageURL+'" alt="Image" width="'+width+'" style="max-width:100%;" />';
			}

			//return;	
		// }
		//debug=true;
		/*
		var p=window.location.href.indexOf("/", 8);
		var currentHostName="a";
		if(p != -1){
			currentHostName=window.location.href.substr(0, p);
		}
		p=imageURL.indexOf("/", 8);
		var imageHostName="b";
		if(imageHostName != -1){
			imageHostName=imageURL.substr(0, p);
		}
		var proxyPath="/zimageproxy/";
		if(imageURL.substr(0,4) == 'http' && currentHostName != imageHostName && imageURL.substr(0, proxyPath.length) != proxyPath){
			// use proxy when it is a remote domain to avoid crossdomain security error
			imageURL="/zimageproxy/"+imageURL.replace("http://", "").replace("https://", "");
		}
		if(debug) console.log('Loading: '+imageURL);
		var canvas = document.createElement('canvas');
		zLoadAndCropImagesIndex++;
		canvas.id="zCropImageID"+zLoadAndCropImagesIndex+"_canvas";
		canvas.width=width;
		canvas.height=height;
		canvas.style.cssText=style;

		var tempWidth=width;
		var tempHeight=height;
		var context = canvas.getContext('2d');
		var imageObj = new Image();
		imageObj.startTime=new Date().getTime();
		imageObj.onerror=function(){
			if(debug) console.log('image load fail: '+this.src);
			this.src='/z/a/listing/images/image-not-available.gif';	
		};
		imageObj.onload = function() {
			var end = new Date().getTime();
			var time2 = end - this.startTime;
			//if(debug) 
			if(debug) console.log(imageObj.src+": "+(time2/1000)+" seconds to load image");
			var time=new Date().getTime();

			if(this.width <= 10 || this.width >= 10000 || this.height <= 10 || this.height >= 10000){
				if(debug) console.log(imageObj.src+": Failed to draw canvas because the image width x height was too large: "+this.width+"x"+this.height);
				return;
			}
			if(this.src.indexOf('/z/a/listing/images/image-not-available.gif') !== -1){
				canvas.width=this.width;
				canvas.height=this.height;
				context.drawImage(this, 0,0);//Math.floor((width-this.width)/2), Math.floor((height-this.height)/2));
				//context.drawImage(this, Math.floor((width-this.width)/2), Math.floor((height-this.height)/2));
				obj.appendChild(canvas);
				return;
			}
			if(debug) console.log(imageObj.src+": image loaded");
			var start=new Date();
			if(this.width > 25 && this.height > 25){
				canvas.width=this.width;
				canvas.height=this.height;
			}
			context.drawImage(this, 0, 0);
			var imageData=context.getImageData(0,0, this.width, this.height);
			var end = new Date().getTime();
			var time2 = end - time;
			//if(debug) 
			if(debug) console.log(imageObj.src+": "+(time2/1000)+" seconds to getimagedata");
			var time=new Date().getTime();
			var xCheck=Math.round(this.width/5);
			var yCheck=Math.round(this.height/5);
			var xmiddle=Math.round(this.width/2);
			var ymiddle=Math.round(this.height/2);
			var xcrop=0;
			var xcrop2=0;
			var ycrop=0;
			var newy=0;
			var newx=0;
			var ycrop2=0;
			if(debug) console.log(imageObj.src+": "+"top side");
			for (var y=0;y<this.height;y++){
				var p=(xmiddle*4)+(y*4*this.width);
				var rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				var curX=Math.max(1, xmiddle-xCheck);
				p=(curX*4)+(y*4*this.width);
				var rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				curX=Math.min(this.width, xmiddle+xCheck);
				p=(curX*4)+(y*4*this.width);
				var rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
				if((rgb1+rgb2+rgb3)/3 < 16400000){
					ycrop=y+6;
					newy=y;
					for(y=Math.max(0,y-9);y<=newy;y++){
						var p=(xmiddle*4)+(y*4*this.width);
						rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
						if(debug) console.log(imageObj.src+": "+y+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
						if(rgb1<16400000){
							if(debug) console.log(imageObj.src+": "+"final y:"+y);
							ycrop=y+6;
							break;
						}
					}
					break;
				}
			}
			if(debug) console.log(imageObj.src+": "+"bottom side");
			for (var y=0;y<this.height;y++){
				var curY=((this.height-1)*4*this.width)-(y*4*this.width);
				var p=(xmiddle*4)+(curY);
				rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				var curX=Math.max(1, xmiddle-xCheck);
				p=(curX*4)+(curY);
				rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				curX=Math.min(this.width, xmiddle+xCheck);
				p=(curX*4)+(curY);
				rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
				if((rgb1+rgb2+rgb3)/3 < 16400000){
					ycrop2=y+6;
					newy=y;
					for(y=Math.max(0,y-9);y<=newy;y++){
						var p=(xmiddle*4)+(y*4*this.width);
						rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
						if(debug) console.log(imageObj.src+": "+y+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
						if(rgb1<16400000){
							if(debug) console.log(imageObj.src+": "+"final y:"+y);
							ycrop2=y+6;
							break;
						}
					}
					break;
				}
			}
			
			
			if(debug) console.log(imageObj.src+": "+"left side");
			for (var x=0;x<this.width;x++){
				var p=(x*4)+(ymiddle*4*this.width);
				rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				var curY=Math.max(1, ymiddle-yCheck);
				p=(x*4)+(curY*4*this.width);
				rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				curY=Math.min(this.height, ymiddle+yCheck);
				p=(x*4)+(curY*4*this.width);
				rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				//if(debug) console.log("finding y: "+rgb1+" | "+rgb2+" | "+rgb3);
				if((rgb1+rgb2+rgb3)/3 < 16400000){
					xcrop=x+6;
					newx=x; 
					for(x=Math.max(0,x-9);x<=newx;x++){
						var p=(x*4)+(ymiddle*4*this.width);
						rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
						if(debug) console.log(imageObj.src+": "+x+" | refining x: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
						if(rgb1<16400000){
							if(debug) console.log(imageObj.src+": "+"final x:"+x);
							xcrop=x+6;
							break;
						}
					}
					break;
				}
			}
			if(debug) console.log(imageObj.src+": "+"right side");
			for (var x=0;x<this.width;x++){
				//var curX=((this.width-1)*4)-(ymiddle*4*this.width);
				var curX2=(((this.width-1)-x)*4);
				var curX=(((this.width-1)-x)*4)+(ymiddle*4*this.width);
				var p=(x*4)+(curX);
				rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				var curY=Math.max(1, ymiddle-yCheck);
				p=(curX2)+(curY*4*this.width);
				rgb2=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				curY=Math.min(this.height, ymiddle+yCheck);
				p=(curX2)+(curY*4*this.width);
				rgb3=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
				//if(debug) console.log("finding x: "+rgb1+" | "+rgb2+" | "+rgb3+" | x:"+curX+" x:"+(this.width-x)+" y:"+curY);
				if((rgb1+rgb2+rgb3)/3 < 16400000){
					xcrop2=x+6;
					newx=x;
					for(x=Math.max(0,x-9);x<=newx;x++){
						var p=(xmiddle*4)+(curY);
						rgb1=imageData.data[p]*imageData.data[p+1]*imageData.data[p+2];
						if(debug) console.log(imageObj.src+": "+x+" | refining y: "+rgb1+" | red: "+imageData.data[p]+" | green: "+imageData.data[p+1]+" | blue: "+imageData.data[p+2]);
						if(rgb1<16400000){
							if(debug) console.log(imageObj.src+": "+"final x:"+x);
							xcrop2=x+6;
							break;
						}
					}
					break;
				}
			}
			if(debug) console.log(imageObj.src+": "+"left:"+xcrop+" | top:"+ycrop+" | right:"+xcrop2+" | bottom:"+ycrop2);
			
			var originalWidth=this.width;
			var originalHeight=this.height;
			if(debug) console.log(imageObj.src+": "+"original size:"+this.width+"x"+this.height);
			var newWidth=this.width-(xcrop+xcrop2);
			var newHeight=this.height-(ycrop+ycrop2);
			if(newHeight < 10 || newWidth < 10){
				// prevent mistakes
				if(Math.abs(xcrop-xcrop2) > 50){
					xcrop=Math.min(xcrop, xcrop2);
				}else{
					xcrop=Math.max(xcrop, xcrop2);
				}
				if(Math.abs(ycrop-ycrop2) > 50){
					ycrop=Math.min(ycrop, ycrop2);
				}else{
					ycrop=Math.max(ycrop, ycrop2);
				}
				newWidth=(originalWidth-(xcrop*2));
				newHeight=(originalHeight-(ycrop*2));
				if(newHeight < 10 || newWidth < 10){
					// image can't be cropped correctly, show entire image
					newWidth=originalWidth;
					newHeight=originalHeight;
				}
				crop=false;
			}
			if(newWidth < this.width/2 || newHeight < this.height/2){
				// preventing incorrect cropping of images that are mostly white, by restoring them to display as full size
				newWidth=this.width;
				newHeight=this.height;
			}
			if(debug) console.log(imageObj.src+": "+"size without whitespace:"+newWidth+"x"+newHeight);
			
			var x2crop=0;
			var x2crop2=0;
			var y2crop=0;
			var y2crop2=0;
			if(width === 10000 && height === 10000){
				nw=newWidth;
				nh=newHeight;
				if(debug) console.log(imageObj.src+": type 1| nw:"+nw+" nh:"+nh);
				width=newWidth;
				height=newHeight;
			}else{
				if(crop){
					// resize and crop
					var ratio=width/newWidth;
					var nw=width;
					var nh=(newHeight*ratio);
					if(nh < height){
						ratio=height/newHeight;
						nw=(newWidth*ratio);
						nh=height;
					}
					if(nw>width){
						x2crop=((nw-width)/2);
						x2crop2=((nw-width)/2);
					}
					if(nh>height){
						y2crop=((nh-height)/2);
						y2crop2=((nh-height)/2);
						
					}
					xcrop+=(x2crop/2)/ratio;
					ycrop+=(y2crop/2)/ratio;
					if(debug) console.log(imageObj.src+": type 2| nw:"+nw+" nh:"+nh);
					if(debug) console.log(imageObj.src+": "+"crop | left:"+x2crop+" | top:"+y2crop+" | right:"+x2crop2+" | bottom:"+y2crop2);
				}else{
					// resize preserving scale	
					var ratio=width/newWidth;
					var nw=width;
					var nh=Math.ceil(newHeight*ratio);
					if(nh > height){
						ratio=height/newHeight;
						nw=Math.ceil(newWidth*ratio);
						nh=height;
						if(debug) console.log(imageObj.src+": type 3| nw:"+nw+" nh:"+nh);
					}else{
						if(debug) console.log(imageObj.src+": type 4| nw:"+nw+" nh:"+nh);
					}
				}
			}
			
			if(this.width<nw){
				if(debug) console.log(imageObj.src+": "+"width exceeded original");
				ratio=this.width/nw;
				width=this.width;
				nw=this.width;
				nh=this.height;//ratio*this.height;
				height=nh;
				xcrop=0;
				ycrop=0;
				x2crop=0;
				y2crop=0;
			}
			if(this.height<nh){
				if(debug) console.log(imageObj.src+": "+"height exceeded original");
				ratio=this.height/nh;
				height=this.height;
				nh=this.height;
				nw=this.width;//ratio*this.width;
				xcrop=0;
				ycrop=0;
				x2crop=0;
				y2crop=0;
			} 
			if(debug) console.log(imageObj.src+": "+"final size:"+nw+"x"+nh);
			if(debug) console.log(imageObj.src+": "+"sizes:"+width+"x"+height+":"+this.width+"x"+this.height);
			
			var end = new Date().getTime();
			var time2 = end - time;
			//if(debug) 
			if(debug) console.log(imageObj.src+": "+(time2/1000)+" seconds to detect crop");
			var time=new Date().getTime();
			
			// x2crop -15
			if(debug) console.log(imageObj.src+": "+Math.ceil(xcrop)+" | "+Math.ceil(ycrop)+" | "+Math.floor(newWidth-(x2crop))+" | "+Math.floor(newHeight-(y2crop))+" | "+-Math.ceil(x2crop/2)+" | "+-Math.ceil(y2crop/2)+" | "+Math.ceil(nw)+" | "+Math.ceil(nh));
			if(tempWidth <= 10 || tempWidth >= 1000 || tempHeight <= 10 || tempHeight >= 1000){
				if(debug) console.log(imageObj.src+": "+"Failed to draw canvas because width x height must be >= 10x10 and <= 1000: "+tempWidth+"x"+tempHeight);
				canvas.width=tempWidth;
				canvas.height=tempHeight;
				return;
			}



			if(tempWidth > 25 && tempHeight > 25){
				canvas.width=tempWidth;
				canvas.height=tempHeight;
			}
			obj.appendChild(canvas);
			if(debug) console.log("canvas.width: "+canvas.width+" height:"+canvas.height);
			if(canvas.height < 50){
				if(window.location.href.indexOf('windermerehomes') != -1){
					if(typeof window.canvasdebug1=="undefined"){
						alert("too small:"+canvas.width+":"+canvas.height);
						window.canvasdebug1=true;
					}
				}

			}

			if(debug) console.log(imageObj.src+": newWidth:"+newWidth+" newHeight:"+newHeight+" canvas.height:"+canvas.height+" nh:"+Math.ceil(nh)+" y2crop:"+Math.ceil(y2crop));
			context.drawImage(imageObj, Math.ceil(xcrop), Math.ceil(ycrop), Math.floor(newWidth-(xcrop*2)), Math.floor(newHeight-(ycrop*2)),-Math.ceil(x2crop/2), -Math.ceil(y2crop/2), Math.ceil(nw), Math.ceil(nh));
			var end = new Date().getTime();
			var time = end - start;
			//if(debug) 
			if(debug) console.log(imageObj.src+": "+(time/1000)+" seconds to crop image");
		};
		imageObj.src = imageURL;
		*/
	}

	function zImageLazyLoadUpdate(currSlideElement, nextSlideElement, options, forwardFlag){
		var d='zUniqueSlideshowLargeId';
		var id=parseInt(nextSlideElement.parentNode.id.substr(d.length, nextSlideElement.parentNode.id.length-d.length));
		var i=zGetSlideShowId(id);
		if(zArrSlideshowIds[i].moveSliderId !== false){
			if(zArrSlideshowIds[i].ignoreNextRotate===false && zArrSlideshowIds[i].rotateIndex % zArrSlideshowIds[i].movedTileCount === 0){
				zArrSlideshowIds[i].ignoreNextRotate=true;
				$('.zlistingslidernext'+zArrSlideshowIds[i].id).trigger("click");
				if(zArrSlideshowIds[i].rotateGroupIndex+1===3){
					zArrSlideshowIds[i].rotateGroupIndex=0;
				}else{
					zArrSlideshowIds[i].rotateGroupIndex++;
				}
			}
			zArrSlideshowIds[i].ignoreNextRotate=false;
			if(zArrSlideshowIds[i].rotateIndex+1===zArrSlideshowIds[i].movedTileCount*3){
				zArrSlideshowIds[i].rotateIndex=0;
			}else{
				zArrSlideshowIds[i].rotateIndex++;
			}
		}
		var d1=document.getElementById(nextSlideElement.id+"_img");
		var d2=document.getElementById(currSlideElement.id+"_img");
		if(d1 && d1.src !== nextSlideElement.title){
			d1.src=nextSlideElement.title;
		}
		if(d2 && d2.src !== nextSlideElement.title){
			d2.src=currSlideElement.title;
		}
	}
	function zLoadHomeSlides(id){
		var c=0;
		for(var i=0;i<zArrSlideshowIds.length;i++){
			if(zArrSlideshowIds[i].id === id){
				zArrSlideshowIds[i].rotateIndex=0;
				zArrSlideshowIds[i].rotateGroupIndex=0;
				zArrSlideshowIds[i].ignoreNextRotate=true;
				c=zArrSlideshowIds[i];	
				break;
			}
		}
		zSlideshowSetupSliderButtons(c);
		if(c.layout===2 || c.layout === 0){
			$('#zUniqueSlideshowLargeId'+c.id).cycle({
				before: zImageLazyLoadUpdate,
				fx: 'fade',
				startingSlide: 0,
				timeout: c.slideDelay
			});
		}
		if(c.layout === 1 || c.layout === 0){
			var d=c.slideDelay;
			var e1="slide";
			if(c.slideDirection==='y'){
				e1='verticalslide';//'fade';
			}
			if(c.layout===0){
				d=false;
				
			}
			// thumbnails	
			$('#zUniqueSlideshowId'+c.id).slides({
				newClassNames:true,
				newId: c.id,
				play: d,
				pause: d,
				effect:e1,
				next: 'zlistingslidernext'+c.id,
				prev: 'zlistingsliderprev'+c.id,
				hoverPause: false
			});
		}
		zLoadAndCropImages();
	}
	function zGetSlideShowId(id){
		for(var i=0;i<zArrSlideshowIds.length;i++){
			if(zArrSlideshowIds[i].id === id){
				return i;
			}
		}
		return false;
	}

	function zUpdateListingSlides(id, theLink){
		var c=0;
		for(var i=0;i<zArrSlideshowIds.length;i++){
			if(zArrSlideshowIds[i].id === id){
				c=zArrSlideshowIds[i];	
				break;
			}
		}
		$.ajax({
			url: theLink,
			context: document.body,
			success: function(data){
				if(zArrSlideshowIds[i].layout === 0){
					// need to load both html and init both here
					var a1=data.split("~~~");
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).html(a1[0]);
					var a2='';
					if(zArrSlideshowIds[i].slideDirection==='x'){
						a2+='<div id="zslideshowhomeslidenav'+zArrSlideshowIds[i].id+'">'+document.getElementById('zslideshowhomeslidenav'+zArrSlideshowIds[i].id).innerHTML+'<\/div>';
					}
					a2+='<div class="zslideshow'+zArrSlideshowIds[i].id+'-38-2">		<a href="#" class="zlistingsliderprev'+zArrSlideshowIds[i].id+'"><span class="zlistingsliderprevimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><div id="zslideshowslides'+zArrSlideshowIds[i].id+'"><div id="zlistingcontainer'+zArrSlideshowIds[i].id+'" class="zslideshowslides_container'+zArrSlideshowIds[i].id+'"><div class="zslideshowslide'+zArrSlideshowIds[i].id+'">'+a1[1]+'<\/div><\/div><\/div>		<a href="#" class="zlistingslidernext'+zArrSlideshowIds[i].id+'"><span class="zlistingslidernextimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><\/div>';
					$('#zUniqueSlideshowId'+zArrSlideshowIds[i].id).html(a2);
				}else if(c.layout === 2){
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).html(data);
				}else{
					$('#zUniqueSlideshowId'+zArrSlideshowIds[i].id).html('<div id="zslideshowhomeslidenav'+zArrSlideshowIds[i].id+'">'+document.getElementById('zslideshowhomeslidenav'+zArrSlideshowIds[i].id).innerHTML+'<\/div><div class="zslideshow'+zArrSlideshowIds[i].id+'-38-2">		<a href="#" class="zlistingsliderprev'+zArrSlideshowIds[i].id+'"><span class="zlistingsliderprevimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><div id="zslideshowslides'+zArrSlideshowIds[i].id+'"><div id="zlistingcontainer'+zArrSlideshowIds[i].id+'" class="zslideshowslides_container'+zArrSlideshowIds[i].id+'"><div class="zslideshowslide'+zArrSlideshowIds[i].id+'">'+data+'<\/div><\/div><\/div>		<a href="#" class="zlistingslidernext'+zArrSlideshowIds[i].id+'"><span class="zlistingslidernextimg'+zArrSlideshowIds[i].id+'">&nbsp;<\/span><\/a><\/div>');
				}
				if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
					$('a').attr('target', '_parent');
				}
				zLoadHomeSlides(id);
			}
		});
	}
	function zSlideshowSetupSliderButtons(c){
			$('.zlistingsliderprev'+c.id).bind('click',function(){
				var d='zlistingsliderprev';
				var id=parseInt(this.className.substr(d.length, this.className.length-d.length));
				var i=zGetSlideShowId(id);
				if(zArrSlideshowIds[i].rotateGroupIndex===0){
					zArrSlideshowIds[i].rotateGroupIndex=2;
				}else{
					zArrSlideshowIds[i].rotateGroupIndex--;
				}
				if(zArrSlideshowIds[i].layout === 0 && zArrSlideshowIds[i].rotateIndex !== zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount){
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle('destroy');
					zArrSlideshowIds[i].rotateIndex=zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount;
					zArrSlideshowIds[i].ignoreNextRotate=true;
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle({
						before: zImageLazyLoadUpdate,
						fx: 'fade',
						startingSlide: zArrSlideshowIds[i].rotateIndex,
						timeout: zArrSlideshowIds[i].slideDelay
					});
				}
			});
			$('.zlistingslidernext'+c.id).bind('click',function(){
				var d='zlistingslidernext';
				var id=parseInt(this.className.substr(d.length, this.className.length-d.length));
				var i=zGetSlideShowId(id);
				if(zArrSlideshowIds[i].ignoreNextRotate){
					return;
				}
				if(zArrSlideshowIds[i].rotateGroupIndex===2){
					zArrSlideshowIds[i].rotateGroupIndex=0;
				}else{
					zArrSlideshowIds[i].rotateGroupIndex++;
				}
				if(zArrSlideshowIds[i].layout === 0 && zArrSlideshowIds[i].rotateIndex !== zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount){
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle('destroy');
					zArrSlideshowIds[i].rotateIndex=zArrSlideshowIds[i].rotateGroupIndex * zArrSlideshowIds[i].movedTileCount;
					zArrSlideshowIds[i].ignoreNextRotate=true;
					$('#zUniqueSlideshowLargeId'+zArrSlideshowIds[i].id).cycle({
						before: zImageLazyLoadUpdate,
						fx: 'fade',
						startingSlide: zArrSlideshowIds[i].rotateIndex,
						timeout: zArrSlideshowIds[i].slideDelay
					});
				}
			});
	}

	function zSlideshowInit(){  
		for(var i=0;i<zArrSlideshowIds.length;i++){
			$('.zslideshowslides_container'+zArrSlideshowIds[i].id).css("display","block");
			var c=zArrSlideshowIds[i];
			zSlideshowSetupSliderButtons(c);
			//c.slideDelay=1000;
			//zArrSlideshowIds[i].slideDelay=1000;
			zArrSlideshowIds[i].ignoreNextRotate=true;
			if(c.layout === 0){
				zArrSlideshowIds[i].moveSliderId='#zUniqueSlideshowId'+c.id;
			}else{
				zArrSlideshowIds[i].moveSliderId=false;
			}
				//	zArrSlideshowIds[i].slideDelay=2000;
					//c.slideDelay=2000;
			if(c.layout===2){
				var slideCount=zGetChildElementCount('zUniqueSlideshowLargeId'+c.id);
				if(slideCount===0){
					document.getElementById("zUniqueSlideshowContainerId"+c.id).style.display="none";
				}else if(slideCount===1){
					var d0=document.getElementById("zUniqueSlideshowLargeId"+c.id);
					var d_0=0;
					if(d0.childNodes[0].nodeName==="#text"){
						d_0=1;
					}
					var d1=document.getElementById(d0.childNodes[d_0].id+"_img");
					if(d1 && d1.src !== d0.childNodes[d_0].title){
						d1.src=d0.childNodes[d_0].title;
					}	
				}
			}
			if(c.layout===2 || c.layout === 0){
				if(c.slideDelay === 0){
					c.slideDelay=4000;
					zArrSlideshowIds[i].slideDelay=4000;
				}
				// console.log('iasadas here');
				// return;
				

				$('#zUniqueSlideshowLargeId'+c.id).cycle({
					before: zImageLazyLoadUpdate,
					fx: 'fade',
					timeout:c.slideDelay,
					slides:'> a',
					speed:300
				});

			}
			if(c.layout === 1 || c.layout===0){
				var d=c.slideDelay;
				var e1="slide";
				if(c.slideDirection==='y'){
					e1='verticalslide';//'fade';
				}
				if(c.layout===0){
					d=false;//c.slideDelay*zGetChildElementCount('zUniqueSlideshowLargeId'+c.id);
					
				}
				// thumbnails	
				$('#zUniqueSlideshowId'+c.id).slides({
					newClassNames:true,
					newId: c.id,
					play: d,
					pause: d,
					effect:e1,
					next: 'zlistingslidernext'+c.id,
					prev: 'zlistingsliderprev'+c.id,
					hoverPause: false
				});
			}
				if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
					$('a', document.body).attr('target', '_parent');
				}
		}
	}
	zArrDeferredFunctions.push(function(){
		zSlideshowInit();
	});
	function zSlideshowClickLink(u){
		if(window.location.href.indexOf('/z/misc/slideshow/embed') !== -1){
			top.location.href=u;
		}else{
			window.location.href=u;
		}
			
	}

	function loadDetailGallery(){
		var c="zGalleryViewSlideshow";
		var a=zGetElementsByClassName(c);
		for(var i=0;i<a.length;i++){
			if($("li", a[i]).length){
				$("#"+a[i].id)[0].parentNode.setAttribute("data-galleryview-id", a[i].id);
				var d2=document.getElementById(a[i].id+"_data").value;
				var myObj=eval("("+d2+")");
				zArrGalleryViewSlideshowTemplate[a[i].id]={
					html:$("#"+a[i].id).prop('outerHTML'),
					originalWidth:myObj.panel_width,
					originalThumbWidth:myObj.frame_width
				};
			}
		}
		//reloadDetailGallery();
		/*
		for(var i=0;i<a.length;i++){
			$(a[i]).show().galleryView(myObj);
		}*/
	}
	function reloadDetailGalleryTimeout(){
		clearTimeout(zGalleryReloadTimeoutId);
		zGalleryReloadTimeoutId=setTimeout(reloadDetailGallery, 200);
	}
	function reloadDetailGallery(){
		var c="zGalleryViewSlideshowContainer";
		var a2=zGetElementsByClassName(c);
		for(var i=0;i<a2.length;i++){
			var id=a2[i].getAttribute("data-galleryview-id");
			if(typeof zArrGalleryViewSlideshowTemplate[id] != "undefined"){
				var b=zArrGalleryViewSlideshowTemplate[id];
				a2[i].innerHTML=b.html;
				var d2=document.getElementById(id+"_data").value;
				var myObj=eval("("+d2+")");
				var windowWidth=$(window).width()*.9;
				var parentWidth=$(a2[i]).parent().width();
				if(!isNaN(parentWidth) && parentWidth != 0 && parentWidth<windowWidth){
					var width=Math.min(parentWidth, b.originalWidth);
				}else{
					var width=Math.min(windowWidth, b.originalWidth);
				}
				var thumbWidth=Math.min(Math.abs(windowWidth/4), b.originalThumbWidth);
				var ratio=width/myObj.panel_width;
				var thumbRatio=thumbWidth/myObj.frame_width;
				myObj.panel_width=width;
				myObj.panel_height=Math.abs(myObj.panel_height*ratio);
				myObj.frame_width=thumbWidth;
				myObj.frame_height=Math.abs(myObj.frame_height*thumbRatio); 
				$("#"+id).show().galleryView(myObj);
			}
		}
	}
	zArrLoadFunctions.push({functionName:loadDetailGallery});
	//zArrLoadFunctions.push({functionName:reloadDetailGalleryTimeout});
	zArrResizeFunctions.push({functionName:reloadDetailGalleryTimeout});

	window.zLoadAndCropImages=zLoadAndCropImages;
	window.zLoadAndCropImagesDefer=zLoadAndCropImagesDefer;
	window.zLoadAndCropImage=zLoadAndCropImage;
	window.zImageLazyLoadUpdate=zImageLazyLoadUpdate;
	window.zLoadHomeSlides=zLoadHomeSlides;
	window.zGetSlideShowId=zGetSlideShowId;
	window.zUpdateListingSlides=zUpdateListingSlides;
	window.zSlideshowSetupSliderButtons=zSlideshowSetupSliderButtons;
	window.zSlideshowInit=zSlideshowInit;
	window.zSlideshowClickLink=zSlideshowClickLink;
	window.loadDetailGallery=loadDetailGallery;
	window.reloadDetailGalleryTimeout=reloadDetailGalleryTimeout;
	window.reloadDetailGallery=reloadDetailGallery;
})(jQuery, window, document, "undefined"); 