
function zlsEnableImageEnlarger(){
	var a=zGetElementsByClassName("zlsListingImage");	
	for(var i=0;i<a.length;i++){
		var id=a[i].id.substr(0,a[i].id.length-4);
		var d=document.getElementById(id+"_mlstempimagepaths");
		if(d !== null){
			zIArrMLink[id]="";
			zIArrM[id]=d.value.split("@");
			zIArrM2[id]=[];
			zIArrM3[id]=false;
			zImageMouseMove(id, false, true);
		}
	}
}
zArrLoadFunctions.push({functionName:zlsEnableImageEnlarger});


 var zIArrMLink=new Array();
var zIArrM=new Array();
var zIArrM2=new Array();
var zIArrM3=new Array();
  var zIArrMST=new Array();
  var zIArrOriginal=new Array();
function zImageMouseReset(id,mev){
	var d2=document.getElementById(id);
	if(d2===null) return;
	var dpos=zGetAbsPosition(d2);
	var dimg=document.getElementById(id+"_img");
	if(!dimg) return;
	if(
		(zMousePosition.x > dpos.x)                &&
		(zMousePosition.x < (dpos.x + dpos.width))  &&
		(zMousePosition.y > dpos.y)                &&
		(zMousePosition.y < (dpos.y + dpos.height))){
		return;
	}
	if(typeof zIImageClickLoad!=="undefined" && zIImageClickLoad){
		var b1=document.getElementById('zlistingnextimagebutton');
		var b2=document.getElementById('zlistingprevimagebutton');
		b1.style.display="none";
		b2.style.display="none";	
		return;
	}
	zIArrMST[id]=false;
	zIArrM5[id]=-1;
	zIArrM2[id]=new Array(); 
	dimg.style.display="block";
	zImageForceCloseEnlarger();
	if(typeof zIArrOriginal[id] !== "undefined"){
		document.getElementById('zListingImageEnlargeImageParent').innerHTML='<img id="zListingImageEnlargeImage" alt="Image" src="'+zIArrOriginal[id]+'" onerror="zImageOnError(this);" />';
	}
}
function zImageOnError(o){
	o.onmousemove=null;
	o.onmouseout=null;
	o.src='/z/a/listing/images/image-not-available.gif';
}
var zIArrMOffset=new Array();
  var zIArrMSize=new Array();
  var zIArrM5=new Array();
  var zIImageMaxWidth=540;
  var zIImageMaxHeight=420;
  var zICurrentImageIndex=0;
  var zICurrentImageXYPos=[0,0];
  //var zIImageClickLoad=false;
  var zILastLoaded="";
function zImageMouseMove(id,mev,forceResize){

	zLoadImageEnlargerDiv();

	var d=document.getElementById(id);
	if(d===null) return;
	var dpos=zGetAbsPosition(d);
	
	var dimg=document.getElementById(id+"_img");
	if(dimg === null) return;
	var imageURL=dimg.getAttribute("data-imageurl");
	var b='/z/a/listing/images/image-not-available.gif';
	if(typeof dimg.src !== "undefined"){
		imageURL=dimg.src;
		if(dimg.src.substr(dimg.src.length-b.length, b.length) === b){
			return false;
		}
	}else if(imageURL !== ""){
		if(imageURL.indexOf(b) !== -1){
			return false;
		}
	}
	if(zILastLoaded === id){
		return;	
	}
	zIArrOriginal[id]=imageURL;
	if(typeof zIImageClickLoad !== "undefined" && zIImageClickLoad && typeof mev !== "boolean"){
		zILastLoaded=id;
		// show the prev/next buttons
		var b1=document.getElementById('zlistingnextimagebutton');
		var b2=document.getElementById('zlistingprevimagebutton');
		if(b1 !== null){
			if(zIArrM[id].length<=1){
				b1.style.display="none";
				b2.style.display="none";	
			}else{
				b1.style.display="block";
				b2.style.display="block";
				b1.style.paddingBottom=(dpos.height-19-45)+"px";
				b2.style.paddingBottom=(dpos.height-19)+"px";
			}
			if(zICurrentImageXYPos[0] === dpos.x && zICurrentImageXYPos[1] === dpos.y){
				return;
			}
			if(typeof zIArrMOffset[id] === "undefined"){
				zIArrMOffset[id]=0;
			}
			var b1pos=zGetAbsPosition(b1);
			zICurrentImageIndex=0;
			zICurrentImageXYPos[0]=dpos.x;
			zICurrentImageXYPos[1]=dpos.y;
			b1.ondblclick=function(){zClearSelection(); return false;};
			b2.ondblclick=function(){zClearSelection(); return false;};
			b1.onselectstart=function(){ zClearSelection(); return false;};
			b2.onselectstart=function(){ zClearSelection(); return false;};
			b2.style.top=((dpos.y)+10)+"px";//-dpos.height
			b2.style.left=dpos.x+"px";
			b1.style.top=((dpos.y)+10)+"px";//-dpos.height
			b1.style.left=((dpos.x+dpos.width)-b1pos.width)+"px";
			//b1.style.paddingTop=(dpos.height-b1pos.height)+"px";
			//b2.style.paddingTop=(dpos.height-b1pos.height)+"px";
			b1.curId=id;
			b1.curImageDiv=dimg;
			b2.curId=id;
			b2.curImageDiv=dimg;
			b1.unselectable=true;
			b2.unselectable=true;
			b1.onclick=function(){
				// next image
				//alert('next');
				var c=zIArrM[this.curId].length;
				var c2=zIArrMOffset[this.curId];
				c2++;
				if(c2 >=c){
					c2=0;	
				}
				this.curImageDiv.src=zIArrM[this.curId][c2];
				zIArrMOffset[this.curId]=c2;
				return false;
			};
			b2.onclick=function(){
				// prev image
				//alert('prev');	
				var c=zIArrM[this.curId].length;
				var c2=zIArrMOffset[this.curId];
				c2--;
				if(c2 <0){
					c2=c-1;	
				}
				this.curImageDiv.src=zIArrM[this.curId][c2];
				zIArrMOffset[this.curId]=c2;

				return false;
			};
		}
		dimg.onload=function(){
			var v1=zGetAbsPosition(this.parentNode); 
			if(v1.width === 0){
				var v1=zGetAbsPosition(this.parentNode.parentNode); 
			}
			//alert(this.parentNode.parentNode+":"+this.parentNode.parentNode.id+":"+v1.width+":"+this.width+":"+v1.height+":"+this.height);
			this.style.marginLeft=Math.max(0,Math.floor((v1.width-this.width)/2))+"px";
			//this.style.paddingRight=Math.max(0,Math.floor((v1.width-nw)/2))+"px";
			this.style.marginTop=Math.max(0,Math.floor((v1.height-this.height)/2))+"px";
			//this.style.paddingBottom=Math.max(0,Math.floor((v1.height-nh)/2))+"px";
		};
		return;	
	}
	if(forceResize!==true){
	  var offsetX =mev.clientX-dpos.x;
	  p=(offsetX/dpos.width);
	}else{
		p=0;	
	}
	if(typeof zIArrM === "undefined" || zIArrM === null || typeof zIArrM[id] === "undefined" || zIArrM[id] === null){
	  return;  
	}
	o=Math.min(Math.max(0,Math.floor(zIArrM[id].length*p)),zIArrM[id].length-1);
	if(zIArrM5[id]===o || zIArrM[id].length===0){
		if(typeof mev !== "boolean"){ 
			zImageShowEnlarger(id,dimg,dpos,zIArrM[id][o]);
		}
		return;
	}
  zIArrM5[id]=o;
  var lbl=zIArrM[id][o];
  if(zIArrM[id].length!==0 && o<zIArrM[id].length){
	  if(zIArrM3[id]===false){
		  for(var n=0;n<zIArrM[id].length;n++){
			  if(typeof mev !== "boolean" || n===0){
				zIArrMSize[zIArrM[id][n]]=[0,0];//nm.width,nm.height];
			  }
		  }
	  }
	if(zIArrM2[id][o]!==1){
		dimg.o222=dimg;
		dimg.o333=id;
		dimg.onload=function(){
			return;
		};
	}else{
		dimg.onload=null;
	}
		dimg.style.display="block";
	if(zIArrM[id][o] !== imageURL){
		if(typeof mev !== "boolean"){ 
			zImageShowEnlarger(id,dimg,dpos,zIArrM[id][o]);
		}
	}
  }
}
function zImageForceCloseEnlarger(){
	zLoadImageEnlargerDiv();
	var d99=document.getElementById('zListingImageEnlargeDiv');
	if(d99 !== null){
		d99.style.display="none";
	}
}


var zImageEnlargerLoaded=false;
function zLoadImageEnlargerDiv(){
	if(zImageEnlargerLoaded){
		return;
	}
	zImageEnlargerLoaded=true;

	$(document.body).append('<div id="zListingImageEnlargeDiv" style="position:absolute; cursor:pointer;pointer-events:none; display:none; left:0px; top:0px; width:540px;background-color:#FFF; max-width:100%; z-index:1002;  color:##999;  padding-top:0px; font-size:10px; line-height:11px; text-align:center;"><div style="width:98%; float:left;clear:both;background-color:#FFF;padding:1%;">ROLL YOUR MOUSE LEFT AND RIGHT TO VIEW ALL PHOTOS. <strong>CLICK TO READ MORE.</strong></div><br style="clear:both;" /><div id="zListingImageEnlargeImageParent" style="width:100%;text-align:center;float:left;"><img src="/z/a/images/s.gif" id="zListingImageEnlargeImage" style="max-width:100%;max-height:100%;display:inline-block;" alt="Enlarged Image" /></div></div>');
}


function zImageShowEnlarger(id,dimg,dpos,src){
	var d=document.getElementById(id);
	if(d===null) return;
	zSetScrollPosition();
	//if(typeof zIArrMDead[id] === "undefined"){
		var ws=getWindowSize();
		zLoadImageEnlargerDiv();
		var d99=document.getElementById('zListingImageEnlargeDiv');
		if(d99 !== null){
			if(d99.style.display==="none" || zCurEnlargeImageId !== id){
				zCurEnlargeImageId=id; 
				// detect which side of listing image has more room
				
				var newLeft=0;
				var newTop=0;
				if(dpos.x + (dpos.width/2) > ws.width / 2 || ws.width < 580 ){
					// left bigger
					
					newLeft=Math.max(20, dpos.x-580); 
				}else{
					newLeft=Math.min(dpos.x+dpos.width+20, (ws.width-580)-zPositionObjSubtractPos[0]);
				}
				if(dpos.y + (dpos.height/2) > ws.height / 2 || ws.height < 470){
					// top bigger
					newTop=Math.max(dpos.y-470,zScrollPosition.top+20); 
				}else{
					newTop=Math.min(dpos.y+dpos.height+20, zScrollPosition.top+(ws.height-470));
				}
				
				d99.style.left=newLeft+"px"; 
				d99.style.top=newTop+"px"; 
			}
			d92=document.getElementById('zListingImageEnlargeImage'); 
			/*d92.onload=function(){
				
				var d99=document.getElementById('zListingImageEnlargeDiv'); 
				if(typeof zIArrMSize[this.src] === "undefined"){
					return;
				} 
				zIArrMSize[this.src]=[this.width,this.height];
				if(zIArrMSize[this.src][0]<=zIImageMaxWidth && zIArrMSize[this.src][1]<=zIImageMaxHeight-20){
					if(zIArrMSize[this.src][0] !== 0){
						this.width=zIArrMSize[this.src][0];
						this.height=zIArrMSize[this.src][1];
					}
				}else{
					if(zIArrMSize[this.src][0]>zIImageMaxWidth){
						var r1=zIImageMaxWidth/zIArrMSize[this.src][0];
						var nw=zIImageMaxWidth;
						var nh=r1*zIArrMSize[this.src][1]; 
					}else{
						var nw=0;
						var nh=zIImageMaxHeight; // force the height calculation below.
					}
					if(nh>zIImageMaxHeight-20){
						var r1=(zIImageMaxHeight-20)/zIArrMSize[this.src][1];
						var nw=Math.round(r1*zIArrMSize[this.src][0]);
						var nh=zIImageMaxHeight-20;
					} 
					if(nw===0){
						if(zIImageMaxWidth !== 0){
							this.width=zIImageMaxWidth;
							this.height=zIImageMaxHeight-20;
						}
					}else{
						if(Math.floor(nw) !== 0){
							this.width=Math.floor(nw);
							this.height=Math.floor(nh);
						}
					}
				} 
				this.style.cssFloat="left";
				this.style.marginLeft=Math.max(0,Math.floor((zIImageMaxWidth-this.width)/2))+"px";
				this.style.marginTop=Math.max(0,Math.floor((zIImageMaxHeight-this.height)/2))+"px"; 
			}; */
			if(d92.src === '/z/a/images/s.gif' || d92.src !== src){ 
				d99.style.display="block";
				document.getElementById('zListingImageEnlargeImageParent').innerHTML='<img id="zListingImageEnlargeImage" alt="Image" src="'+src+'" style="display:inline-block; max-width:100%;max-height:100%;" onerror="zImageOnError(this);" />'; 
			}else{
				d99.style.display="block";
			}
		}
	//}
}

function zImageMouseLoadDelayed(id){
	var d=document.getElementById(id);	
	d.onload();
}
function zImageStoreLoaded(obj,id){
	obj.style.display="block";
	for(i=0;i<zIArrM[id].length;i++){
		if(zIArrM[id][i] === obj.src){
			zIArrM2[id][i]=1;
			return;
		}
	}
}
if(arrM===null){
	var arrM=[];
	var arrM2=[];
	var arrM3=[];
}

function zlsFixImageHeight(obj, width, height){
	if(typeof obj.naturalHeight !== "undefined" && obj.naturalHeight !== 0){
		if(obj.naturalHeight > height){
			obj.style.width="auto";
			obj.style.height=height+"px";
		}else if(obj.naturalHeight < height && obj.naturalHeight < width){
			obj.style.width=obj.naturalWidth+"px";
			obj.style.height=obj.naturalHeight+"px";
		}
	}else{
		var pos=zGetAbsPosition(obj);
		if(pos.height > height){
			obj.style.width="auto";
			obj.style.height=height+"px";
		}
	}
}

