
var zScrollApp=new Object();
zScrollApp.forceSmallHeight=50000;
zScrollApp.newCount=0;
zScrollApp.maxItems=1000;
zScrollApp.firstNewBox=0;
zScrollApp.boxCount2=0;
zScrollApp.colCount=-1;
	//var rowHeight=100;
zScrollApp.itemMarginRight=30;
zScrollApp.itemMarginBottom=30;
zScrollApp.itemWidth=160;
zScrollApp.itemHeight=170;
zScrollApp.arrVisibleBoxes=new Array();
zScrollApp.bottomRowLoaded=0;
zScrollApp.scrollAreaDiv=false;
zScrollApp.scrollAreaPos=false;
zScrollApp.scrollAreaMapDiv=false;
zScrollApp.appDisabled=false;

zScrollApp.bottomRowLoadedBackup=0;
zScrollApp.resizeTimeoutId=false;
zScrollApp.scrollTimeoutId=false;

zScrollApp.lastScrollPosition=-1;
zScrollApp.totalListingCount=0;
zScrollApp.googleMapClass=false;
zScrollApp.loadedMapMarkers=new Array();
zScrollApp.scrollAreaWidth=0;
zScrollApp.veryFirstSearchLoad=true;
zScrollApp.curListingCount=0;
zScrollApp.curListingLoadedCount=0;
zScrollApp.bottomRowLimit=5;
zScrollApp.arrListingId=new Array();
zScrollApp.templateCache={};
zScrollApp.offset=0;
zScrollApp.firstAjaxRequest=true;
zScrollApp.disableNextScrollEvent=false;
zScrollApp.lastScreenWidth=0;

zScrollApp.drawVisibleRows=function(startRow, endRow){
	var arrH=new Array();
	var firstNew=true;
	var boxOffset=startRow*zScrollApp.colCount;
	tempEndRow=Math.min(zScrollApp.bottomRowLimit, endRow);
	for(var row=startRow;row<tempEndRow;row++){
		var tempItemMarginRight=zScrollApp.itemMarginRight;
		var itemTop=((row*zScrollApp.itemHeight)+(row*zScrollApp.itemMarginBottom))+50;
		for(var col=0;col<zScrollApp.colCount;col++){
			var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight))+10;
				tempCSS="";
				zScrollApp.boxCount2++;
				var d9=document.getElementById('row'+boxOffset);
				if(d9!==null){
					
				}else{
					if(firstNew){
						firstNew=false;
						zScrollApp.firstNewBox=boxOffset;
					}
					zScrollApp.arrVisibleBoxes["row"+boxOffset]=new Object();
					zScrollApp.arrVisibleBoxes["row"+boxOffset].offset=boxOffset;
					zScrollApp.arrVisibleBoxes["row"+boxOffset].visible=true;
					zScrollApp.newCount++;
					var tempTop=itemTop;
					var tempLeft=itemLeft;
					arrH.push('<div id="row'+boxOffset+'" style="position:absolute; background-color:#FFF; left:'+tempLeft+'px; top:'+tempTop+'px; width:'+zScrollApp.itemWidth+'px; height:'+zScrollApp.itemHeight+'px;  '+tempCSS+' "><\/div>');// margin-bottom:'+zScrollApp.itemMarginBottom+'px; margin-right:'+tempItemMarginRight+'px;
				}
				boxOffset++;
		}
		zScrollApp.bottomRowLoaded=row;
	}
	zScrollApp.scrollAreaDiv.append(arrH.join(""));
};
zScrollApp.hideRows=function(lessThen, greaterThen){
	var activated=0;
	var boxOffset=0;
	for(var i10 in zScrollApp.arrVisibleBoxes){
		var i=zScrollApp.arrVisibleBoxes[i10].offset;
		var i2=Math.floor(i/zScrollApp.colCount);
		var i22=i;
		var i3=zScrollApp.arrVisibleBoxes[i10].visible;
		if(i2 < lessThen || i2 >= greaterThen){
			if(i3){
				// hide it
				zScrollApp.arrVisibleBoxes[i10].visible=false;
				var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
				for(var col=0;col<zScrollApp.colCount;col++){
					var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight));
					$('#row'+(i22)).html("");
				}
			}
		}else{
			if(!i3){
				zScrollApp.arrVisibleBoxes[i10].visible=true;
				activated++;
				var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
				for(var col=0;col<zScrollApp.colCount;col++){
					var itemLeft=((col*zScrollApp.itemWidth)+(col*zScrollApp.itemMarginRight));
					if('row'+(i22) in zScrollApp.templateCache){
						$('#row'+(i22)).html(zScrollApp.templateCache['row'+(i22)]);
					}
				}
			}
		}
	}
};


zScrollApp.delayedResizeFunction=function(d){
	if(zlsHoverBox.panel && zlsHoverBox.panel.style.display==="block"){
		return;
	}
	if(zlsHoverBoxNew.panel && zlsHoverBoxNew.panel.style.display==="block"){
		return;
	}
	if(zScrollApp.resizeTimeoutId !==false){
		clearTimeout(zScrollApp.resizeTimeoutId);
	}
	zScrollApp.resizeTimeoutId=setTimeout('zScrollApp.resizeFunction();',50);
};
zScrollApp.resizeFunction=function(){
	var s=$(window).width();
	if(zScrollApp.lastScreenWidth !== s){
		zListingResetSearch();
	}
};
zScrollApp.lastScrollTop=0;

zScrollApp.delayedScrollFunction=function(){
	var docViewTop=$(window).scrollTop();
	zScrollApp.lastScrollTop=docViewTop;
	/*if(zIsTouchscreen()){
		if(zlsHoverBox.panel.style.display=="block"){
			zlsHoverBox.box.style.top="0px";	
		}else{
			if(zIsAppleIOS()){
				zlsHoverBox.box.style.top=docViewTop+"px";	
			}else{
				zlsHoverBox.box.style.top="0px";	
			}
		}
	}*/
	if(zlsHoverBox.panel && zlsHoverBox.panel.style.display==="block"){
		return;
	}
	if(zlsHoverBoxNew.panel && zlsHoverBoxNew.panel.style.display==="block"){
		return;
	}
	if(zScrollApp.scrollTimeoutId !==false){
		clearTimeout(zScrollApp.scrollTimeoutId);
	}
	zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
};
zScrollApp.scrollFunction=function(){
	if(zScrollApp.disableFirstAjaxLoad){ return;}
	if(zScrollApp.disableNextScrollEvent){
		zScrollApp.disableNextScrollEvent=false;
		return;
	}
	//console.log("storing:"+$(window.frames["zSearchJsNewDivIframe"]).scrollTop()+":"+$(window.parent.frames["zSearchJsNewDivIframe"]).scrollTop());
	//zSetCookie({key:"zls-lsos",value:$(window.parent.frames["zSearchJsNewDivIframe"]).scrollTop(),futureSeconds:3600,enableSubdomains:false}); 
	if(zScrollApp.appDisabled) return;
	//alert('scroll');
	var docViewTop=$(window).scrollTop();
	
	/*if(zIsTouchscreen()){
		if(zlsHoverBox.panel.style.display=="block"){
			zlsHoverBox.box.style.top="0px";	
		}else{
			if(zIsAppleIOS()){
				zlsHoverBox.box.style.top=docViewTop+"px";	
			}else{
				zlsHoverBox.box.style.top="0px";	
			}
		}
	}*/
	if(zScrollApp.lastScrollPosition-docViewTop > $(window).height()){
		if(window.stop !== "undefined"){
			 window.stop();
		}else if(document.execCommand !== "undefined"){
			 document.execCommand("Stop", false);
		}
	}
	if(zScrollApp.lastScrollPosition !== -1 && zScrollApp.lastScrollPosition >=5 && Math.abs(zScrollApp.lastScrollPosition-docViewTop) <= zScrollApp.itemHeight/2){
	//alert('wha:'+zScrollApp.lastScrollPosition+":"+zScrollApp.disableNextScrollEvent);
		//return;
	}
	//alert('scroll'+docViewTop);
	clearTimeout(zScrollApp.scrollTimeoutId);
	clearTimeout(zScrollApp.resizeTimeoutId);
	zScrollApp.scrollTimeoutId=false;
	zScrollApp.resizeTimeoutId=false;
	zScrollApp.setBoxSizes();
	backupColCount=zScrollApp.colCount;
	zScrollApp.colCount=Math.floor((zScrollApp.scrollAreaWidth)/(zScrollApp.itemWidth+zScrollApp.itemMarginRight));
	var oldTop=Math.floor(docViewTop / (zScrollApp.itemHeight+zScrollApp.itemMarginBottom));
	var newTop=Math.floor(((oldTop * backupColCount ) / zScrollApp.colCount) * (zScrollApp.itemHeight+zScrollApp.itemMarginBottom));
	if(backupColCount !== zScrollApp.colCount){
		zScrollApp.bottomRowLimit=Math.max(5,Math.round(zScrollApp.totalListingCount/zScrollApp.colCount));
		zScrollApp.scrollAreaDiv.css("width",zScrollApp.colCount*(zScrollApp.itemWidth+zScrollApp.itemMarginRight)+"px");
		zScrollApp.scrollAreaDiv.css("height",Math.round(zScrollApp.totalListingCount/zScrollApp.colCount)*(zScrollApp.itemHeight+zScrollApp.itemMarginBottom)+"px"); 
		if(docViewTop !== newTop){
			//alert("old:"+docViewTop+" new:"+newTop);
			window.scrollTo(0, newTop);
			zScrollApp.lastScrollPosition=-1;
			zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
			//return;
			//return;
			backupColCount=zScrollApp.colCount;
			return;
		}
	}
	if(zScrollApp.lastScrollPosition !== -1 && backupColCount !== -1 && backupColCount !== zScrollApp.colCount){
		// set the scrollTop based on the top row last displayed.
		if(zScrollApp.scrollTimeoutId !==false){
			clearTimeout(zScrollApp.scrollTimeoutId);
		}
		zScrollApp.scrollTimeoutId=setTimeout('zScrollApp.scrollFunction();',100);
	//alert('fail'+docViewTop);
		return;
	}else{
		tempForceRowRedraw=false;
	}
	zScrollApp.lastScrollPosition=docViewTop;
	var docViewBottom = docViewTop + ($(window).height()-40);
	var offset=100;
	docViewTop-=offset;
	docViewBottom+=offset;
	
	var topPos=docViewTop-zScrollApp.scrollAreaPos.top;
	zScrollApp.topRow=Math.floor((topPos+offset)/(zScrollApp.itemHeight+zScrollApp.itemMarginBottom))-1;
	var footerSize=0;
	zScrollApp.bottomRow=Math.floor(((docViewBottom+offset+footerSize)-zScrollApp.scrollAreaPos.top)/(zScrollApp.itemHeight+zScrollApp.itemMarginBottom))+1;
		
	zScrollApp.newCount=0;
	zScrollApp.bottomRowLoadedBackup=zScrollApp.bottomRowLoaded;
	/*var allLoaded=false;
	if((1+zScrollApp.bottomRowLoadedBackup)*zScrollApp.colCount >= zScrollApp.maxItems){
		allLoaded=true;
	}
	if(!allLoaded){*/
		var tempStartRow=Math.floor(Math.min(0,zScrollApp.boxCount2)/zScrollApp.colCount);
		zScrollApp.drawVisibleRows(Math.max(0,zScrollApp.topRow), Math.max(1,zScrollApp.bottomRow));
	//}
	//alert('beforedoajax'+zScrollApp.newCount);
	if(zScrollApp.newCount !== 0){
		zScrollApp.offset=zScrollApp.firstNewBox;
		zScrollApp.doAjax(zScrollApp.newCount);
	}
	zScrollApp.hideRows(zScrollApp.topRow, zScrollApp.bottomRow);
};
zScrollApp.disableFirstAjaxLoad=false;
zScrollApp.loadSearchMap=function() {
	return;
	/*
    var myLatlng = new google.maps.LatLng(25.363882,-91.044922);
    var myOptions = {
      zoom: 12,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    zScrollApp.googleMapClass = new google.maps.Map(document.getElementById("zMapCanvas2"), myOptions);
    myLatlng = new google.maps.LatLng(25.363882,-91.044922);
    myOptions = {
      zoom: 18,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.HYBRID
    }
    zScrollApp.googleMapClass2 = new google.maps.Map(document.getElementById("zMapCanvas4"), myOptions);
	*/
};
zScrollApp.addListingMarker=function(d,n){
	if(d.latitude[n] ==="0" || d.longitude[n] ==="0" || d.latitude[n] ==="" || d.longitude[n] ===""){
		return;	
	}
    var myLatlng = new google.maps.LatLng(d.latitude[n],d.longitude[n]);
    var marker = new google.maps.Marker({
        position: myLatlng, 
        map: zScrollApp.googleMapClass,
        title:d.listing_id[n]
    }); 
    var marker2 = new google.maps.Marker({
        position: myLatlng, 
        map: zScrollApp.googleMapClass2,
        title:d.listing_id[n]
    }); 
	zScrollApp.loadedMapMarkers[d.listing_id[n]]=[marker,marker2];
	zScrollApp.googleMapClass.setCenter(myLatlng);
	zScrollApp.googleMapClass2.setCenter(myLatlng);
		
};
zScrollApp.removeListingMarker=function(d){
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	if(typeof zScrollApp.loadedMapMarkers[d] !== "undefined"){
		zScrollApp.loadedMapMarkers[d][0].setMap(null);	
		zScrollApp.loadedMapMarkers[d][1].setMap(null);	
		delete zScrollApp.loadedMapMarkers[d];
	}
};
zScrollApp.setBoxSizes=function(){
	var d3=$(window).width();
	var mapWidth=Math.max(300,Math.round(d3*.25));
	var mapX=d3-mapWidth;
	var hideMap=false;
	if(mapX<200){
		mapX=d3;
		hideMap=true;	
		if(zScrollApp.scrollAreaMapDiv2 && zScrollApp.scrollAreaMapDiv2.style.display==="block"){
			zScrollApp.scrollAreaMapDiv2.style.display="none";
			zScrollApp.scrollAreaMapDiv4.style.display="none";
		}
	}else{
		if(zScrollApp.scrollAreaMapDiv2.style.display==="none"){
			zScrollApp.scrollAreaMapDiv2.style.display="block";
			zScrollApp.scrollAreaMapDiv4.style.display="block";
		}
	}
	if(zScrollApp.scrollAreaWidth===mapX) return;
	zScrollApp.scrollAreaWidth=mapX;
	if(zScrollApp.scrollAreaMapDiv2){
		zScrollApp.scrollAreaDiv2.style.width=mapX+"px";
		zScrollApp.scrollAreaMapDiv2.style.backgroundColor="#900";
		zScrollApp.scrollAreaMapDiv2.style.width=mapWidth+"px";
		zScrollApp.scrollAreaMapDiv2.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv2.style.left=mapX+"px";
		zScrollApp.scrollAreaMapDiv3.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv4.style.backgroundColor="#009";
		zScrollApp.scrollAreaMapDiv4.style.left=mapX+"px";
		zScrollApp.scrollAreaMapDiv4.style.width=mapWidth+"px";
		zScrollApp.scrollAreaMapDiv4.style.top=Math.round((($(window).height()-40)/2)+40)+"px";
		zScrollApp.scrollAreaMapDiv4.style.height=Math.round(($(window).height()-40)/2)+"px";
		zScrollApp.scrollAreaMapDiv5.style.height=Math.round(($(window).height()-40)/2)+"px";
	}
};

zScrollApp.startYTouch = 0;
zScrollApp.startXTouch = 0;
zScrollApp.startTouchCount = 0;
zScrollApp.listingSearchLoad=function() {
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	if(u.indexOf("/z/listing/instant-search/index") !== -1){
		zForceSearchJsScrollTop();
	}
	zScrollApp.lastScreenWidth=$(window).width();
	zScrollApp.itemWidth=Math.round((zScrollApp.lastScreenWidth-110)/3);
	zScrollApp.itemNegativeHeight=90;
	zScrollApp.itemHeight=Math.round((zScrollApp.itemWidth*0.68)+zScrollApp.itemNegativeHeight);
				/*setTimeout(function(){
					var h3 = parent.document.getElementById("zSearchJsNewDivIframe");
					h3.contentWindow
					$(h3).scrollTop(200);
				},1000);*/
				//return;
	if(zIsTouchscreen()){
		//zForceSearchJsScrollTop();
		setTimeout(function () {
			var b = document.body;
			b.addEventListener('touchstart', function (event) {
				zScrollApp.startYTouch = event.targetTouches[0].pageY;
				zScrollApp.startXTouch = event.targetTouches[0].pageX;
				zScrollApp.startTouchCount=event.targetTouches.length;
			}, {
				passive:true 
			});
			b.addEventListener('touchmove', function (event) {
				if(zScrollApp.startTouchCount !== 1 || event.targetTouches.length !== 1){ return true;}
				event.preventDefault();
				
				var posy = event.targetTouches[0].pageY;
				var h = parent.document.getElementById("zSearchJsNewDiv");
				var h3 = parent.document.getElementById("zSearchJsNewDivIframe");
				var sty = $(h3).contents().scrollTop();
				$(h3).contents().scrollTop(sty-(posy - zScrollApp.startYTouch));
			}, {
				passive:true 
			});
		}, 500);
	}
	//window.scrollTo(0,1);
	setTimeout(function(){ 
		var s=$(window).scrollTop();
		if(s !== zScrollApp.lastScrollTop){
			zScrollApp.lastScrollTop=s;
			zScrollApp.delayedScrollFunction();
		}
	}, 100);
	
	
	
	$(window).bind('scroll', zScrollApp.delayedScrollFunction);
	$(window).bind('resize', zScrollApp.delayedResizeFunction);
	/*$(document.body).bind('touchmove', zScrollApp.delayedScrollFunction);
	$(document.body).bind('touchend', function(){zScrollApp.disableNextScrollEvent=false;zScrollApp.lastScrollPosition=1;zScrollApp.scrollFunction();});
	$(document.body).bind('touchstart', zScrollApp.delayedScrollFunction);
	$(window).bind('orientationchange', zScrollApp.delayedResizeFunction);*/
	zScrollApp.scrollAreaDiv=$("#zScrollArea");
	zScrollApp.scrollAreaMapDiv=$("#zMapCanvas");
	zScrollApp.scrollAreaMapDiv2=$("#zMapCanvas3");
	zScrollApp.scrollAreaDiv2=document.getElementById("zScrollArea");
	zScrollApp.scrollAreaMapDiv2=document.getElementById("zMapCanvas");
	zScrollApp.scrollAreaMapDiv3=document.getElementById("zMapCanvas2");
	zScrollApp.scrollAreaMapDiv4=document.getElementById("zMapCanvas3");
	zScrollApp.scrollAreaMapDiv5=document.getElementById("zMapCanvas4");
	zScrollApp.scrollAreaPos=zScrollApp.scrollAreaDiv.position();
	zScrollApp.loadSearchMap();
	
	
	
};
function zListingResetSearch(){
	var s=$(window).width();
	zScrollApp.lastScreenWidth=s;
	/*if($(window).scrollTop() > 5){
		//alert('scroll to 1');
		window.scrollTo(0,1);
		setTimeout("zListingResetSearch();",100);
		return;
	}*/
	var scrollFunctionBackup=zScrollApp.scrollFunction;
	var delayedResizeFunctionBackup=zScrollApp.delayedResizeFunction;
	zScrollApp.templateCache=[];
	zScrollApp.scrollFunction=function(){};
	zScrollApp.delayedResizeFunction=function(){};
	zScrollApp.scrollAreaDiv.html("");
	zScrollApp.forceSmallHeight=50000;
	zScrollApp.newCount=0;
	zScrollApp.maxItems=1000;
	zScrollApp.firstNewBox=0;
	zScrollApp.boxCount2=0;
	//zScrollApp.colCount=-1;
	zScrollApp.itemMarginRight=30;
	zScrollApp.itemMarginBottom=30;
	//zScrollApp.itemWidth=160;
	//zScrollApp.itemHeight=170;
	zScrollApp.itemWidth=Math.round((zScrollApp.lastScreenWidth-110)/3);
	zScrollApp.itemNegativeHeight=90;
	zScrollApp.itemHeight=Math.round((zScrollApp.itemWidth*0.68)+zScrollApp.itemNegativeHeight);
	//zScrollApp.lastScrollPosition=-1;
	zScrollApp.arrVisibleBoxes=new Array();
	zScrollApp.disableNextScrollEvent=false;
	zScrollApp.bottomRowLoaded=0;
	if(zScrollApp.firstAjaxRequest){
		window.scrollTo(0,1);
		zScrollApp.lastScrollPosition=-1;
		zScrollApp.colCount=-1;
	}
	/*
	zScrollApp.scrollAreaDiv=false;
	zScrollApp.scrollAreaPos=false;
	zScrollApp.scrollAreaMapDiv=false;
	*/
	zScrollApp.scrollFunction=scrollFunctionBackup;
	zScrollApp.delayedResizeFunction=delayedResizeFunctionBackup;
	zScrollApp.veryFirstSearchLoad=true;
	//zScrollApp.listingSearchLoad();
	zScrollApp.scrollFunction();
}
zScrollApp.ajaxProcessError=function(r){
	//alert("Failed to search listings. Please try again later.");
};
zScrollApp.showDebugger=function(m){
	document.getElementById("debugInfo").style.display="block";
	document.getElementById("debugInfoTextArea").value+=m;
	
};
zScrollApp.processAjax=function(r){
	//zScrollApp.showDebugger(r);
	var r=eval('(' + r + ')');
	var i2=0;
	if(r.offset>0){
		i2=(r.offset);
	}
	
	//document.getElementById("debugDivDiv").innerHTML="query:"+r.query+"\n\n";
	var itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
	if(zScrollApp.firstAjaxRequest){
		setMLSCount2(r.count);
		zScrollApp.totalListingCount=Math.min(zScrollApp.maxItems, r.count);
		zScrollApp.bottomRowLimit=(Math.round(zScrollApp.totalListingCount/zScrollApp.colCount));
		zScrollApp.scrollAreaDiv.css("width",zScrollApp.colCount*(zScrollApp.itemWidth+zScrollApp.itemMarginRight)+"px");
		zScrollApp.scrollAreaDiv.css("height",Math.round(zScrollApp.totalListingCount/zScrollApp.colCount)*(zScrollApp.itemHeight+zScrollApp.itemMarginBottom)+"px");
		zScrollApp.curListingCount=r.count;
		zScrollApp.firstAjaxRequest=false;
		for(var i=0;i<zScrollApp.boxCount2;i++){
			if(i<r.count){
				if(typeof zScrollApp.arrVisibleBoxes["row"+i] === "object"){
					zScrollApp.arrVisibleBoxes["row"+i].visible=true;
				}
				if(document.getElementById("row"+i)){
					document.getElementById("row"+i).style.display="block";
				}
			}else{
				if(typeof zScrollApp.arrVisibleBoxes["row"+i] === "object"){
					zScrollApp.arrVisibleBoxes["row"+i].visible=false;
				}
				if(document.getElementById("row"+i)){
					document.getElementById("row"+i).style.display="none";
				}
			}
		}
	}
	
	var g=document.getElementById('zlsGrid');
	var d="";
	var f=0;
	for(var i=0;i<r.url.length;i++){
		if(r.url[i] === ""){
			 continue;
		}
		if(f>=zScrollApp.colCount){
			f=0;	
			i2++;
			itemTop=((i2*zScrollApp.itemHeight)+(i2*zScrollApp.itemMarginBottom));
		}
		var itemLeft=((f*zScrollApp.itemWidth)+(f*zScrollApp.itemMarginRight));
		var cc=(r.offset)+i;
		if('row'+cc in zScrollApp.templateCache){
			d=zScrollApp.templateCache['row'+cc];	
		}else{
			d=zScrollApp.buildTemplate(r, i);	
			zScrollApp.templateCache['row'+cc]=d;
		}
		//zScrollApp.addListingMarker(r,i);
		zScrollApp.arrListingId[cc]=r.listing_id[i];
		$('#row'+cc).html(d);
		
		var cc1=document.getElementById("row"+cc);
		if(cc1){
			cc1.listing_id=r.listing_id[i];
			cc1.zlsData=r;
			cc1.zlsIndex=i;
			cc1.boxOffset=cc;
		}
		$('#row'+cc).bind('mouseover', function(obj){ 
			//this.style.backgroundColor="#EEE";
			//zScrollApp.scrollAreaMapDiv2.style.display="block";
			//zScrollApp.scrollAreaMapDiv4.style.display="block";
			//zScrollApp.setBoxSizes();
			
			// map temp removed
			//zScrollApp.addListingMarker(this.zlsData,this.zlsIndex);
		});
	
		$('#row'+cc).bind('mouseout', function(obj){ 
			//this.style.backgroundColor="#FFF";
			// map temp removed
			//zScrollApp.removeListingMarker(this.zlsData.listing_id[this.zlsIndex]);
			
			// not used
			//zScrollApp.scrollAreaMapDiv2.style.display="none";
			//zScrollApp.scrollAreaMapDiv4.style.display="none";
		});
		f++;
	}
	var u=window.parent.location.href;	var p=u.indexOf("#");	if(p !== -1){		u=u.substr(p+1);	}
	if(u.indexOf("/z/listing/instant-search/index") !== -1){
		if("/z/listing/search-js/index?"+r.qs === zGetCookie("zls-lsurl")){
			if(zScrollApp.veryFirstSearchLoad){
				var offset=zGetCookie("zls-lsos");
				if(offset !== ""){
					//console.log("trying to move to:"+offset);
					$(window).scrollTop(parseInt(offset));
				}
			}else{
				var offset=$(window).scrollTop();	
				//console.log("unable to move - already loaded:"+offset);
			}
			zSetCookie({key:"zls-lsos",value:offset,futureSeconds:3600,enableSubdomains:false}); 
		}else{
			zSetCookie({key:"zls-lsos",value:0,futureSeconds:3600,enableSubdomains:false}); 
		}
	}else{
		var offset=$(window).scrollTop();
		zSetCookie({key:"zls-lsos",value:offset,futureSeconds:3600,enableSubdomains:false}); 
	}
	zSetCookie({key:"zls-lsurl",value:"/z/listing/search-js/index?"+r.qs,futureSeconds:3600,enableSubdomains:false}); 
	if(zScrollApp.veryFirstSearchLoad){
		zScrollApp.veryFirstSearchLoad=false;
		/*if(zIsTouchscreen()){
			setTimeout(function(){
			window.scrollTo(0,1);
			},500);
			zScrollApp.disableNextScrollEvent=true;
		}*/
	}
};
zScrollApp.imageWidth=0;
zScrollApp.imageHeight=0;
zScrollApp.doAjax=function(perpage, customCallback){
	zSearchFormChanged=true;
	var formName="zMLSSearchForm"; 
	var v1=document.getElementById("search_map_lat_blocks");
	/*if(typeof zMapCoorUpdateV3 !== "undefined"){// && v1 && v1.value==""){ 
		 return "0";
	} */
	if(typeof zFormData[formName] === "undefined") return;
	zFormData[formName].ajax=true;
	zFormData[formName].ignoreOldRequests=false;
	if(typeof customCallback !== "undefined"){
		zFormData[formName].onLoadCallback=customCallback;
	}else{
		zFormData[formName].onLoadCallback=zScrollApp.processAjax;
	}
	zFormData[formName].onErrorCallback=zScrollApp.ajaxProcessError;
	zFormData[formName].successMessage=false;
	
	var v="/z/listing/search/g?of="+zScrollApp.offset+"&perpage="+(perpage)+"&debugSearchForm=1&pw="+zScrollApp.itemWidth+"&ph="+(zScrollApp.itemHeight-zScrollApp.itemNegativeHeight)+"&pa=1&x_ajax_id="+zScrollApp.offset+"_"+Math.random();
	var v2=v;
	if(zScrollApp.firstAjaxRequest){
		v+="&first=1";	
	}
	zFormData[formName].action=v;
	zScrollApp.offset+=perpage;
	zFormSubmit(formName,false,true);
	zFormData[formName].action=v2;
	return false;
};
zScrollApp.buildTemplate=function(d, n){
	var t=[];
	t.push('<div class="zls-grid-1" style="width:'+zScrollApp.itemWidth+'px; height:'+(zScrollApp.itemHeight)+'px;"><div class="zls-grid-2">');
	if(d.photo1[n] !== ''){
		t.push('<img src="'+d.photo1[n]+'" onerror="zImageOnError(this);" width="'+zScrollApp.itemWidth+'" height="'+(zScrollApp.itemHeight-zScrollApp.itemNegativeHeight)+'" alt="Image1" />');
	}else{
		t.push('&nbsp;');	
	}
	t.push('<\/div><div class="zls-grid-3">');
	t.push('<div class="zls-buttonlink" style="float:right; position:relative; margin-top:-38px;"><a href="#" onclick="parent.zContentTransition.gotoURL(\''+d.url[n]+'\');">View</a></div>');
	if(d.price[n] !== "0"){
		t.push('<strong>'+d.price[n]+'<\/strong><br />');
	}
	var bset=false;
	if(d.bedrooms[n] !== "0" && d.bedrooms[n] !== ""){
		bset=true;
		t.push(d.bedrooms[n]+" bed");
	}
	if(d.bedrooms[n] !== "0" && d.bedrooms[n] !== ""){
		if(bset){
			t.push(", ");	
		}
		bset=true;
		t.push(d.bathrooms[n]+" bath");
	}
	if(bset){
		t.push('<br />');
	}else if(d.square_footage[n] !== "" && d.square_footage[n] !== "0"){
		t.push(d.square_footage[n]+' sqft<br />');	
	}
	if(d.type[n] !== ""){
		t.push(d.type[n]+'<br />');	
	}
	if(d.city[n] !== ""){
		t.push(d.city[n]+'<br />');	
	}
	return t.join("");
};
