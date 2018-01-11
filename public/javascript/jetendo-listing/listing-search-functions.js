var zlsSearchCriteriaMap={
search_bathrooms_low:"a",
search_bathrooms_high:"b",
search_bedrooms_low:"c",
search_bedrooms_high:"d",
search_city_id:"e",
search_exact_match:"f",
search_map_coordinates_list:"g",
search_listing_type_id:"h",
search_listing_sub_type_id:"i",
search_condoname:"j",  
search_address:"k",  
search_zip:"l",  
search_rate_low:"m",  
search_rate_high:"n",  
search_sqfoot_high:"o",
search_result_limit:"p",
search_agent_always:"q",
search_sort_agent_first:"r",
search_office_always:"s",
search_sort_office_first:"t",
search_sqfoot_low:"u",
search_year_built_low:"v",
search_year_built_high:"w",
search_county:"x",
search_frontage:"y",
search_view:"z",
search_remarks:"aa",
search_style:"bb",
search_mls_number_list:"cc",
search_sort:"dd",
search_listdate:"ee",
search_near_address:"ff",
search_near_coordinates:"ff1",
search_near_radius:"gg",
//search_sortppsqft:"",
//search_new_first:"",
search_remarks_negative:"hh",
//search_mls_number_list:"ii",
search_acreage_low:"jj",
search_acreage_high:"kk",
search_status:"ll",
search_surrounding_cities:'mm',
search_within_map:"nn",
search_with_photos:"oo",  
search_with_pool:"pp",   
search_agent_only:"qq",
search_office_only:"rr",
search_agent:"ss",
search_office:"tt",
search_subdivision:"uu",
search_result_layout:"vv",
//search_result_limit:"ww",
search_group_by:"xx",
search_region:"yy",
search_parking:"zz",
search_condition:"a1",
search_tenure:"b1",
search_liststatus:"c1"
};

var zSearchFormTimeoutId=0;
var zSearchFormCountTimeoutId=0;
var zSearchFormFloaterAbsoluteFix=false;
var zSearchFormFloaterDisplayed=false;


function zInputPutIntoForm(linkSelected, valueSelected, formName, valueId, enableOnEnter){
	var arrP=linkSelected.split(", ");
	var arrCity=new Array();
	for(i=0;i<arrP.length;i++){
		if(i+1!==arrP.length){
			arrCity.push(arrP[i]);
		}
	}
	//alert(valueId+":"+formName+":"+linkSelected+":"+valueSelected+":"+document.getElementById(formName));
	var v1=document.getElementById(valueId);
	document.getElementById(formName).value = linkSelected;
	v1.value=valueSelected;
	//alert(document.getElementById(formName).id+":"+v1.id+":"+valueSelected);
	
	if(enableOnEnter){
		//zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);document.getElementById('#arguments.ss.name#_zmanual').value='';
		zFormOnEnter(null,document.getElementById(formName),document.getElementById(formName));
	}
	return;
	/*v1.value="";
	document.getElementById(formName).value ="";
	selIndex=0;
	zCurrentCityLookupLabel='';*/
}
function zInputLinkBuildBox(obj, obj2,arrResults){
	selIndex=0;
	//alert(obj.name);
	var arrP=zFindPosition(obj);
	var b=document.getElementById("zTOB");
	b.style.position="absolute";
	b.style.left=(arrP[0]-zPositionObjSubtractPos[0])+"px";
	b.style.top=(arrP[1]+arrP[3]-zPositionObjSubtractPos[1])+"px";
	
	formName = obj2.id;
	var v="";
	var doc = document.getElementById("zTOB");
	doc.style.height=(60+(Math.min(10,arrResults.length)*23))+"px";
	class1='class="zTOB-selected" ';
	arrNewLink=[];
	v=v+'<div class="top">Click a city below or use the keyboard up and down arrow keys and press enter to select the city.</div>';
	for (j=0; j < arrResults.length; j++){
		var arrJ=arrResults[j].split("\t");
	v=v+'<a id="lid'+j+'" '+class1+' href="##" onclick="zInputPutIntoForm(\''+arrJ[0]+'\',\''+arrJ[1]+'\',\''+obj.id+'\', \''+formName+'\',true); zInputHideDiv(\''+formName+'\'); return false;" >'+arrJ[0]+'</a>';
		class1='class="zTOB-link" ';	
		arrNewLink.push(j);
	}
	document.getElementById("zTOB").style.display="block";
	document.getElementById("zTOB").innerHTML=v;
	document.getElementById("zTOB").scrollTop="0px";
}


function zMlsCheckCityLookup(e, obj, obj2, type){
var keynum;
	if(e===null) return;
	if(window.event){
	keynum = e.keyCode;
	}else{
	keynum = e.which;	
	}
	if(obj.value.length > 2){
		if(keynum !==13 && keynum !==40 && keynum!==38){
		zMlsCallCityLookup(obj,obj2,type);
		}	
	}else{
		zInputHideDiv();
	}
}

var zArrCityLookup=[];
var arrNewLink=[];
var zCurrentCityLookupLabel="";
function zMlsCallCityLookup(obj,obj2,type){	
	var strValue="";
	arrNewLink=[];
	var suggCount=0;
	strValue=obj.value;
	strValue = zFixText(strValue);	
	if(strValue.length >= 3){
		var arrNew=[];
		var arrNew2=[];
		arrNewLink=[];
		var firstIndex=-1;
		var resetSelect=false;
		var m=zGetCityLookupObj();
		var d1=strValue.substr(0,1);
		var d2=strValue.substr(1,1);
		var d3=strValue.substr(2,1);
		var m2=false;
		try{
			var m2=eval("(m."+d1+"."+d2+"."+d3+")");
		}catch(e){
			zInputHideDiv();
			return;	
		}
		if(m2===null || m2===false){
			zInputHideDiv();
			return;	
		}
		zArrCityLookup=m2;
			zInputLinkBuildBox(obj, obj2,m2); 
			aN=[];
			var fb=null;
			var fbi=-1;
			var fixB=false;
			var foundB=false;
			zCurrentCityLookupLabel="";
			for(var i=0;i<m2.length;i++){
				var cb=document.getElementById('lid'+i);
				if(cb.innerHTML.substr(0, strValue.length).toLowerCase() !== strValue || strValue.length>cb.innerHTML.length){
					if(fb===null){
						fb=cb;
						fbi=i;
					}
					cb.style.display="none";
					if(cb.className==="zTOB-selected"){
						fixB=true;
						cb.className="box-link";
					}
				}else if(cb.className==="zTOB-selected"){
					var arrJ=m2[i].split("\t");
					obj2.value=arrJ[1];
					zCurrentCityLookupLabel=arrJ[0];
					foundB=true;
				}
			}
			if(fixB && fb!==null){
				fb.className="zTOB-selected";
				selIndex=fbi;
			}
			if(!foundB && m2.length>0){
				var cb=document.getElementById('lid0');
				cb.className="zTOB-selected";
				selIndex=0;
				
				
			}
		var ajaxArrCleanResults=zFormatTheArray(m2);	
		
		for(i=0;i<ajaxArrCleanResults.length;i++){
			var aib=document.getElementById("lid"+i);
			if(ajaxArrCleanResults[i].substr(0, strValue.length) === strValue){
				arrNew.push(m2[i]);
				arrNew2.push(i);
				if(aib!==null){
					arrNewLink.push(i);
					if(aib.className==="zTOB-selected"){
						selIndex=arrNewLink.length-1;
					}
					aib.style.display="block";
					if(firstIndex===-1){
						firstIndex=arrNewLink.length-1;
					}
				}
			}else{
				if(aib!==null){
					if(aib.className==="zTOB-selected"){
						resetSelect=true;
						aib.className="box-link";
					}
					aib.style.display="none";
				}
			}
		}
		if(resetSelect && firstIndex!==-1){
			selIndex=arrNew2[0];
			document.getElementById("lid"+arrNewLink[firstIndex]).className="zTOB-selected";
		}
		if(arrNew.length > 0){
			if(arrNewLink.length === 0){
				zInputLinkBuildBox(obj,obj2, arrNew);
			}else if(document.getElementById("zTOB").style.display==="none"){
				document.getElementById("zTOB").style.display="block";
				for(i=0;i<arrNewLink.length;i++){
					if(i===0){
						selIndex=arrNewLink[i];
						document.getElementById("lid"+arrNewLink[i]).className="zTOB-selected";
					}else{
						document.getElementById("lid"+arrNewLink[i]).className="box-link";
					}
				}
			}
		}else{
			zInputHideDiv();
		}
	}	
} 

var zExpArrMenuBox=new Array();
var zExpMenuBoxChecked=new Array();
var zExpMenuBoxData=new Array();
function zExpMenuToggleCheckBox(k,n,r,m,v){
	var o=document.getElementById("zExpMenuOption"+k+"_"+n);
	var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+n);
	var i=0;
	var checkBoolean=true;
	if(m===1){
		checkBoolean=false;
	}
	n2=zExpArrMenuBox[zExpMenuLastIgnoreClick];
	for(var i=0;i<zExpArrMenuBox.length;i++){
		f=zExpArrMenuBox[i];
		if(f !== n2){
			var g1=document.getElementById(f+"_expmenu1");
			var g2=document.getElementById(f+"_expmenu2");
			var g4=document.getElementById(f+"_expmenu4");
			if(g4!==null){
				g2.style.display="none";
				g4.innerHTML="More Options &gt;&gt;";
				g4.className="zExpMenuOption";
			}
		}
	}
	if(r==='radio'){
		for(var i=0;i<zExpMenuBoxChecked[k].length;i++){
			var o=document.getElementById("zExpMenuOption"+k+"_"+zExpMenuBoxChecked[k][i]);
			var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+zExpMenuBoxChecked[k][i]);
			o.checked=false;
			o2.className="zExpMenuOption";
		}
		var o=document.getElementById("zExpMenuOption"+k+"_"+n);
		var o2=document.getElementById("zExpMenuOptionLink"+k+"_"+n);
		var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
		var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
		o.checked=true;
		o2.className="zExpMenuOptionOver";
		zExpMenuBoxChecked[k]=new Array();
		zExpMenuBoxChecked[k][0]=n;
		if(o_2 !== null){
			o_2.checked=true;
			o2_2.className="zExpMenuOptionOver";
			zExpMenuBoxChecked[k][1]=n+"_2";
		}
	}else{
		var checkedNow=false;
		if(v===1){
			var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
			var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
			if(o_2.checked === checkBoolean){
				o.checked=false;
				o2.className="zExpMenuOption";
				o_2.checked=false;
				o2_2.className="zExpMenuOption";
			}else{
				checkedNow=true;
				o.checked=true;
				o2.className="zExpMenuOptionOver";
				o_2.checked=true;
				o2_2.className="zExpMenuOptionOver";
			}
		}else{
			var o_2=document.getElementById("zExpMenuOption"+k+"_"+n+"_2");
			var o2_2=document.getElementById("zExpMenuOptionLink"+k+"_"+n+"_2");
			if(o.checked === checkBoolean){
				o.checked=false;
				o2.className="zExpMenuOption";
				if(o_2 !== null){
					o_2.checked=false;
					o2_2.className="zExpMenuOption";
				}
			}else{
				checkedNow=true;
				o.checked=true;
				o2.className="zExpMenuOptionOver";
				if(o_2 !== null){
					o_2.checked=true;
					o2_2.className="zExpMenuOptionOver";
				}
			}
		}
		var arrC=new Array();
		for(var i=0;i<zExpMenuBoxChecked[k].length;i++){
			if(checkedNow || (!checkedNow && i!==n)){
				arrC.push(zExpMenuBoxChecked[k][i]);
			}
		}
		zExpMenuBoxChecked[k]=arrC;
	}
	if(o.onchange!==null){
		o.onchange();
	}
}
function zExpMenuSetPos(obj,left,top){
	obj.style.left=left+"px";
	obj.style.top=top+"px";
}
function zExpMenuToggleMenu(n){
	if(n!==null){
		var m1=document.getElementById(n+"_expmenu1");
		var m2=document.getElementById(n+"_expmenu2");
		var m4=document.getElementById(n+"_expmenu4");
		if(m1===null) return;
		if(m2.style.display==="block"){
			m2.style.display="none";
			m4.innerHTML="More Options &gt;&gt;";
			m4.className="zExpMenuOption";
		}else{
			m4.innerHTML="&lt;&lt; Hide Options";
			m4.className="zExpMenuOptionOver";
			m2.style.display="block";
			var arrPos=zFindPosition(m1);
			zExpMenuSetPos(m2,(arrPos[0]+arrPos[2]),arrPos[1]);
		}
	}
	for(var i=0;i<zExpArrMenuBox.length;i++){
		f=zExpArrMenuBox[i];
		if(f !== n){
			var g1=document.getElementById(f+"_expmenu1");
			var g2=document.getElementById(f+"_expmenu2");
			var g4=document.getElementById(f+"_expmenu4");
			if(g4===null) return;
			g2.style.display="none";
			g4.innerHTML="More Options &gt;&gt;";
			g4.className="zExpMenuOption";
		}
	}
}
var zExpMenuIgnoreClick=-1;
var zExpMenuLastIgnoreClick=-1;
function zExpMenuOnClick(){
	if(zExpMenuIgnoreClick!==-1){
		zExpMenuLastIgnoreClick=zExpMenuIgnoreClick;
		zExpMenuIgnoreClick=-1;
	}else{
		zExpMenuToggleMenu();
	}
	return true;
}
if(typeof document.onclick ==="function"){
	var zExpMenuOnClickBackup=document.onclick;
}else{
	var zExpMenuOnClickBackup=function(){};
}
$(document).bind("click", function(){
	zExpMenuOnClickBackup();
	zExpMenuOnClick();
});

function zExpShowUpdateBar(v, s){
	var d1=document.getElementById("zExpUpdateBar"+v);
	if(d1){
		d1.style.display=s;
	}
}





var zSearchFormObj=new Object();
zSearchFormObj.colCount=-1;
zSearchFormObj.delayedResizeFunction2=function(){
	var d1=document.getElementById('formDiv99');
	var nh=$(window).height();
	var nw=Math.min(965,$(window).width())-5;
	//d1.style.height=nh+"px";
	//d1.style.width=nw+"px";
	if(typeof zSearchFormObj.colmain1 === "undefined" || zSearchFormObj.colmain1===null) return;
	if(nw>800){
		zSearchFormObj.colmain1.style.width=Math.floor((nw/2)-55)+"px";//"48%";
		zSearchFormObj.colmain2.style.width=Math.floor((nw/2)-60)+"px";//"48%";
		if(zSearchFormObj.colCount === 4) return;
		zSearchFormObj.colCount=4;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="45%";
		zSearchFormObj.col4.style.width="45%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="5%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="0%";
		
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain2);
	}else if(nw<=800 && nw >= 660){
		zSearchFormObj.colmain1.style.width=(Math.floor((nw/3)*2)-50)+"px";//"63%";
		zSearchFormObj.colmain2.style.width=Math.floor((nw/3)-50)+"px";//"30%";
		if(zSearchFormObj.colCount === 3) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain2);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=3;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="95%";
		zSearchFormObj.col4.style.width="95%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col3.style.paddingRight="0%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="5%";
		
	}else if(nw<=659 && nw >= 410){
		if(zSearchFormObj.colCount === 2) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=2;
		zSearchFormObj.col1.style.width="45%";
		zSearchFormObj.col2.style.width="45%";
		zSearchFormObj.col3.style.width="45%";
		zSearchFormObj.col4.style.width="45%";
		zSearchFormObj.colr1.style.width="45%";
		zSearchFormObj.colr2.style.width="45%";
		zSearchFormObj.colr3.style.width="45%";
		zSearchFormObj.colr4.style.width="45%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="5%";
		zSearchFormObj.colr3.style.paddingRight="5%";
		zSearchFormObj.col4.style.paddingRight="5%";
		zSearchFormObj.colr4.style.paddingRight="5%";
		
		zSearchFormObj.colmain1.style.width="100%";
		zSearchFormObj.colmain2.style.width="100%";
	}else if(nw<=409){
		if(zSearchFormObj.colCount === 1) return;
		$(zSearchFormObj.col5).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col4).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col6).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr1).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr2).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.col7).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr3).appendTo(zSearchFormObj.colmain1);
		$(zSearchFormObj.colr4).appendTo(zSearchFormObj.colmain1);
		zSearchFormObj.colCount=1;
		zSearchFormObj.col1.style.width="95%";
		zSearchFormObj.col2.style.width="95%";
		zSearchFormObj.col3.style.width="100%";
		zSearchFormObj.col4.style.width="100%";
		zSearchFormObj.colr1.style.width="95%";
		zSearchFormObj.colr2.style.width="95%";
		zSearchFormObj.colr3.style.width="100%";
		zSearchFormObj.colr4.style.width="100%";
		zSearchFormObj.col1.style.paddingRight="5%";
		zSearchFormObj.colr1.style.paddingRight="5%";
		zSearchFormObj.col2.style.paddingRight="5%";
		zSearchFormObj.colr2.style.paddingRight="5%";
		zSearchFormObj.col3.style.paddingRight="0%";
		zSearchFormObj.colr3.style.paddingRight="0%";
		zSearchFormObj.col4.style.paddingRight="0%";
		zSearchFormObj.colr4.style.paddingRight="0%";
		
		zSearchFormObj.colmain1.style.width="100%";
		zSearchFormObj.colmain2.style.width="100%";
		
	}
	
	if ($.browser.msie  && parseInt($.browser.version, 10) === 7) {
		if(zSearchFormObj.col1.style.paddingRight!=="0%") zSearchFormObj.col1.style.paddingRight="1%";
		if(zSearchFormObj.colr1.style.paddingRight!=="0%") zSearchFormObj.colr1.style.paddingRight="1%";
		if(zSearchFormObj.col2.style.paddingRight!=="0%") zSearchFormObj.col2.style.paddingRight="1%";
		if(zSearchFormObj.colr2.style.paddingRight!=="0%") zSearchFormObj.colr2.style.paddingRight="1%";
		if(zSearchFormObj.col3.style.paddingRight!=="0%") zSearchFormObj.col3.style.paddingRight="1%";
		if(zSearchFormObj.colr3.style.paddingRight!=="0%") zSearchFormObj.colr3.style.paddingRight="1%";
		if(zSearchFormObj.col4.style.paddingRight!=="0%") zSearchFormObj.col4.style.paddingRight="1%";
		if(zSearchFormObj.colr4.style.paddingRight!=="0%") zSearchFormObj.colr4.style.paddingRight="1%";
	}
};
zSearchFormObj.loadForm=function(){
	if(document.getElementById('zMLSSearchFormLayout3') === null){
		return;
	}
	zSetFullScreenMobileApp();
	$('script').remove();
	zSearchFormObj.col1=document.getElementById('zMLSSearchFormLayout3');
	zSearchFormObj.col2=document.getElementById('zMLSSearchFormLayout9');
	zSearchFormObj.col3=document.getElementById('zMLSSearchFormLayout8');
	zSearchFormObj.col4=document.getElementById('zMLSSearchFormLayout10');	
	
	zSearchFormObj.colr1=document.getElementById('zMLSSearchFormLayout15');
	zSearchFormObj.colr2=document.getElementById('zMLSSearchFormLayout4');
	zSearchFormObj.colr3=document.getElementById('zMLSSearchFormLayout12');
	zSearchFormObj.colr4=document.getElementById('zMLSSearchFormLayout13');	
	zSearchFormObj.colmain1=document.getElementById('zMLSSearchFormLayout2');	
	zSearchFormObj.colmain2=document.getElementById('zMLSSearchFormLayout5');	
	zSearchFormObj.col5=document.getElementById('zMLSSearchFormLayout6');	
	//zSearchFormObj.col8=document.getElementById('zMLSSearchFormLayout7');	
	zSearchFormObj.col6=document.getElementById('zMLSSearchFormLayout16');	
	zSearchFormObj.col7=document.getElementById('zMLSSearchFormLayout17');	
	//$(window).bind('scroll', scrollFunction);
	zSearchFormObj.delayedResizeFunction2();
	$(window).bind('resize', zSearchFormObj.delayedResizeFunction2);
	
};

zArrLoadFunctions.push({functionName:zSearchFormObj.loadForm});

function updateCountPosition(e,r2){ 
	zScrollPosition.left = (document.all ? document.scrollLeft : window.pageXOffset);
	zScrollPosition.top = (document.all ? document.scrollTop : window.pageYOffset);
	
	r111=zModalLockPosition(e);
	if(1===0 && typeof r2 === "undefined"){ 
		clearTimeout(zSearchFormTimeoutId);
		zSearchFormTimeoutId=setTimeout("updateCountPosition(null,true);",300);	
		return;
	} 
	var r9=document.getElementById("resultCountAbsolute");
	var r95=document.getElementById("searchFormTopDiv"); 
	if(r95===null || r9 === null){
		return; 
	}
	if(r9.innerHTML == ""){
		return;
	}
	var p2=zFindPosition(r95); 
	if(p2[0]==0 && p2[0]==0){
		r9.style.display="none";
	}else{
		r9.style.display="block";
	}
	var scrollP=$(window).scrollTop();
	scrollP=Math.max(scrollP,p2[1]);
	zSearchFormFloaterDisplayed=true;
		r9.style.top=(scrollP-zPositionObjSubtractPos[1])+"px";
		var r10=getWindowSize();
		r9.style.left=(p2[0]-zPositionObjSubtractPos[0])+'px';
	clearTimeout(zSearchFormTimeoutId);
	
	zSearchFormChanged=false;
	clearTimeout(zSearchFormCountTimeoutId);
	zSearchFormCountTimeoutId=setTimeout(updateCountPosition, 300);
	if(r111===false){
		return false;
	}else{
		return true;
	}
}
var GMap=false;
if(typeof zMLSSearchFormName==="undefined"){
	zMLSSearchFormName="zMLSSearchForm";
}
function zMLSUpdateResultLimit(n){
	var d=document.getElementById('search_result_limit');
	if(n === 2){
		var d2=[9,15,21,27,33,39,45,54];
	}else{
		var d2=[10,15,20,25,30,35,40,50];
	}
	for(var i=0;i<d.options.length;i++){
		d.options[i].value=d2[i];
		d.options[i].text=d2[i];
	}
}
var zDebugMLSAjax=false;
function loadMLSResults(r){
	if(zDebugMLSAjax){
		document.write(r);
		return;
	}
	var myObj=eval('('+r+')');
	var m=myObj;
	arrD=new Array();
	setMLSCount(m.COUNT);
	//alert(m.SS[0].LABEL[0]);
  //          for(var g=0;g<zExpArrMenuBox.length;g++){
//            	if(zExpArrMenuBox[g]==f.id){
	// NOW I KNOW WHAT THIS WAS FOR! redraw from ajax results
					//zExpMenuRedraw(0,m.SS[0].LABEL,m.SS[0].VALUE);
	// loop listings
	//m.DATA["URL"]=new Array();
	m.DATA["TITLE"]=new Array();
	for(i=0;i<m.COUNT;i++){
		m.DATA["TITLE"][i]="Test title";
		var t=getMLSTemplate(m.DATA,i);
		for(g in m.DATA){
			t=zStringReplaceAll(t,"#"+g+"#",m.DATA[g][i]);
		}
		arrD.push(t);
	}
	var r2=document.getElementById("mlsResults");
	r2.innerHTML="";
	r2.innerHTML+=arrD.join('<hr />');
}
function displayMLSCount2(r,skipParse){
	displayMLSCount(r,skipParse,true);
}
function displayMLSCount(r,skipParse,newForm){
	// throws an error when debugging is enabled.
	if(zDebugMLSAjax){
		document.write(r);	
		return;
	}
	var myObj=eval('('+r+')');
	if(myObj.success){
		if(typeof myObj.disableSetCount === "undefined"){
			if(typeof newForm !=="undefined" && newForm){
				setMLSCount2(myObj.COUNT);
			}else{
				setMLSCount(myObj.COUNT);
			}
		}
		if(zUpdateMapMarkersV3!==null){
			zUpdateMapMarkersV3(myObj);	
		}
	}else{
		alert(myObj.errorMessage);
	}
	
}
var zSearchFormChanged=false;
//var zDisableSearchFormSubmit=false;
var firstSetMLSCount=true;
var zDisableSearchCountBox=false;
function setMLSCount2(c){ 
	if(zDisableSearchCountBox) return;
	var r92=document.getElementById("resultCountAbsolute");
	var r93=document.getElementById("searchFormTopDiv");
	if(typeof r93==="undefined" || r93===null || r92===null) return;
	//r93.style.height="110px";
	r92.style.display="block";
	var theHTML=c+' Listings';
	if(r92!==null){
		r92.innerHTML=theHTML;
	}
	if(firstSetMLSCount){
		firstSetMLSCount=false;
		//updateCountPosition();
	}
	updateCountPosition();
}
function setMLSCount(c){
	if(zDisableSearchCountBox) return;
	var theHTML='<span style="font-size:21px;line-height:26px;">'+c+'</span><br /><span style="font-size:12px;">listings match your <br />search criteria<br />&nbsp;</span></span>';
	var r92=document.getElementById("resultCountAbsolute");
	var r93=document.getElementById("searchFormTopDiv");
	if(typeof r93==="undefined" || r93===null) return;
	r93.style.height="110px";
	r92.style.display="block";
	var theHTML='<span style="font-size:21px;line-height:26px;">'+c+'</span><br /><span style="font-size:12px;">matching listings';
	//if(zSearchFormChanged && (typeof zDisableSearchFormSubmit === "undefined" || zDisableSearchFormSubmit === false)){
		theHTML+='<br /><button onclick="document.zMLSSearchForm.submit();" class="zls-showResultsButton" style="font-size:13px; font-weight:normal; background-image:url(/z/a/listing/images/mlsbg1.jpg); background-repeat:repeat-x; background-color:none; border:1px solid #999; margin-top:7px; box-sizing:border-box; width:100%; padding:3px; text-decoration:none; cursor:pointer;" name="sfbut1">Show Results</button>';
	//}

	
	theHTML+='</span></span>';
	if(r92!==null){
		r92.innerHTML=theHTML;
	}
	if(firstSetMLSCount){
		
		firstSetMLSCount=false;
		//updateCountPosition();
	}
	updateCountPosition();
}

function zSetJsNewDivHeight(){
	var h=zWindowSize.height - 0;
	var d=document.getElementById("zSearchJsNewDiv");
	if(d!==null){
		zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
		if(zListingInfiniteScrollDiv){
			var p=zGetAbsPosition(zListingInfiniteScrollDiv);
			var oldHeight=parseInt(zListingInfiniteScrollDiv.style.height);
			zListingInfiniteScrollDiv.style.height=h+"px";
		}else{
			var p=zGetAbsPosition(zListingSearchJSDivPHLoaded);
			var oldHeight=parseInt(zListingSearchJSDivPHLoaded.style.height);
			zListingSearchJSDivPHLoaded.style.height=h+"px";
		}
		d.style.left=p.x+"px";
		d.style.top=p.y+"px";
		d.style.width=p.width+"px";//"100%";
		d.style.height=h+"px";
		d=document.getElementById("zSearchJsNewDivIframe");
		d.style.height=h+"px";
	
	/*
		if(h > oldHeight){
			// load more listings!
			var b=zScrollApp.disableNextScrollEvent;
			zScrollApp.disableNextScrollEvent=false;
			zScrollApp.scrollFunction();
			zScrollApp.disableNextScrollEvent=b;
		}*/
	}
	
}
function zForceSearchJsScrollTop(){
	var d=document.getElementById("zSearchJsNewDiv");
	if(d !== null){
		var p=zGetAbsPosition(d);
		if (zIsTouchscreen()) {
			//$(parent).scrollTop(p.y);
			zScrollTop(false, p.y);
		}else{
			zScrollTop(false, p.y);
		}
	}
	if(!d){
		d=parent.document.getElementById("zSearchJsNewDiv");
		if(d !== null){
			var p=parent.zGetAbsPosition(d);
			if (zIsTouchscreen()) {
				//$(parent).scrollTop(p.y);
				parent.zScrollTop(false, p.y);
			}else{
				parent.zScrollTop(false, p.y);
			}
		}
	}
}
var zListingSearchJSDivFirstTime=true;
var zListingSearchJSDivLoaded=null;
var zListingSearchJSToolDivLoaded=null;
var zListingSearchJSActivated=false;
var zListingSearchJSToolDivDisabled=false;
var zlsInstantPlaceholderDiv=false;
var zListingSearchJSDivPHLoaded=null;
function zListingSearchJsToolHide(){
	zListingSearchJSToolDivDisabled=true;
	if(zListingSearchJSToolDivLoaded){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholder.style.display="none";
	}
}
function zListingSearchJsToolPos(){
	if(typeof zlsInstantPlaceholder ==='boolean' || zListingSearchJSToolDivDisabled || !zListingSearchJSToolDivLoaded) return;
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	if(u.indexOf("/z/listing/search-form/index") !== -1 || u.indexOf("/z/listing/instant-search/index") !== -1){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholder.style.display="none";
	}else{
		zListingSearchJSToolDivLoaded.style.display="block";
		zlsInstantPlaceholder.style.display="block";
		var w=$("#zContentTransitionContentDiv").width();
		var p=$("#zContentTransitionContentDiv").position();
		var p2=$(zlsInstantPlaceholder).position();
		zListingSearchJSToolDivLoaded.style.top=Math.max(p2.top,$(window).scrollTop())+"px";
		zListingSearchJSToolDivLoaded.style.left=p.left+"px";
		zListingSearchJSToolDivLoaded.style.width=w+"px";
	}
}
function zListingShowSearchJsToolDiv(){
	var d22=document.getElementById('zListingSearchBarEnabledDiv');
	//console.log("tried:"+d22+":"+zListingSearchJSToolDivDisabled);
	if(!zListingSearchJSActivated && (!d22 ||  zListingSearchJSToolDivDisabled || (window.parent.location.href !== window.location.href && typeof window.parent !== "undefined" && typeof window.parent.zCloseModal !== "undefined"))){ return;}
	//console.log("got in");
	if(zListingSearchJSToolDivLoaded){
		if(zListingSearchJSActivated){
			zlsInstantPlaceholderDiv.style.display="block";
		}
		zListingSearchJSToolDivLoaded.style.display="block";
	}else{
		var w=$("#zContentTransitionContentDiv").width();
		var p=$("#zContentTransitionContentDiv").position();
		var c="window.location.href='/z/listing/search-form/index?showLastSearch=1'; return false;";
		if(zListingSearchJSActivated){
			c="zListingHideSearchJsToolDiv(); zContentTransition.gotoURL('/z/listing/instant-search/index'); return false;";
		}
		$("#zContentTransitionContentDiv").before('<div id="zlsInstantPlaceholder"></div><div id="zSearchJsToolNewDiv" class="zls-instantsearchtoolbar" style=" width:'+w+'px;z-index:1000; "><a href="/z/listing/instant-search/index" onclick="'+c+'" class="zNoContentTransition">&laquo; Back To Search Results</a></div>');
		zListingSearchJSToolDivLoaded=document.getElementById("zSearchJsToolNewDiv");
		zlsInstantPlaceholderDiv=document.getElementById("zlsInstantPlaceholder");
		zListingSearchJsToolPos();
		zArrResizeFunctions.push({functionName:zListingSearchJsToolPos});
		zArrScrollFunctions.push({functionName:zListingSearchJsToolPos});
		zArrLoadFunctions.push({functionName:zListingSearchJsToolPos});
	}
}

var zListingLastSearchJsURL="/z/listing/search-js/index";
function zListingShowSearchJsDiv(){
	zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
	if(zListingInfiniteScrollDiv){
		var p=zGetAbsPosition(zListingInfiniteScrollDiv);
	}else{
		var p=zGetAbsPosition(document.getElementById("zContentTransitionContentDiv"));
	}
	var dut2=zGetCookie("zls-lsurl");
	var u=window.location.href;	var p=u.indexOf("#");	if(p !== -1){		u=u.substr(p+1);	}
	if(dut2 !== "" && u.indexOf("/z/listing/instant-search/index") !== -1){
		var du=dut2;
		
	}else{
		var d22=document.getElementById("zListingSearchJsURLHidden");
		if(d22){
			var du=d22.value;
			zListingLastSearchJsURL=d22.value;
			zSetCookie({key:"zls-lsurl",value:zListingLastSearchJsURL,futureSeconds:3600,enableSubdomains:false}); 
		}else{
			var du=zListingLastSearchJsURL;
		}
	}
	if(zListingSearchJSDivLoaded){
		var i=document.getElementById("zSearchJsNewDivIframe");
		if(i && i.src.substr(i.src.length-du.length) !== du){
			i.src=du;
		}
		//zListingSearchJSDivLoaded.style.display="block";
	}else{
		var h=$(window).height() - 0;
		$("#zContentTransitionContentDiv").before('<div id="zSearchJsNewDivPlaceholder" style="width:100%; float:left; height:'+Math.max(100,h)+'px;"></div><div id="zSearchJsNewDiv" style="overflow:auto;position:absolute; left:'+p.x+'px; top:'+p.y+'px; height:'+Math.max(100,h)+'px; width:'+p.width+'px;"><iframe id="zSearchJsNewDivIframe" frameborder="0" scrolling="auto" src="'+du+'" width="100%" height="'+h+'" /></div>');
		zListingSearchJSDivLoaded=document.getElementById("zSearchJsNewDiv");
		zListingSearchJSDivPHLoaded=document.getElementById("zSearchJsNewDivPlaceholder");
		zArrResizeFunctions.push({functionName:zSetJsNewDivHeight});
		zArrScrollFunctions.push({functionName:zSetJsNewDivHeight});
		zSetJsNewDivHeight();
	}
	$(zListingSearchJSDivLoaded).hide().fadeIn(200,function(){});
	if(zListingInfiniteScrollDiv){
		if(zListingSearchJSDivPHLoaded){
			zListingSearchJSDivPHLoaded.style.display="none";
		}
	}else{
		if(zListingSearchJSDivPHLoaded){
			zListingSearchJSDivPHLoaded.style.display="block";
		}
	}
}
function zListingHideSearchJsToolDiv(){
	if(zListingSearchJSToolDivLoaded){
		zListingSearchJSToolDivLoaded.style.display="none";
		zlsInstantPlaceholderDiv.style.display="none";
	}
}
function zListingHideSearchJsDiv(){
	if(zListingSearchJSDivPHLoaded){
		zListingSearchJSDivPHLoaded.style.display="none";	
	}
	if(zListingSearchJSDivLoaded){
		zListingSearchJSDivLoaded.style.display="none";
	}
}
var zListingInfiniteScrollDiv=false;
function zListingLoadSearchJsDiv(){
	var u=window.location.href;
	var p=u.indexOf("#");
	if(p !== -1){
		u=u.substr(p+1);
	}
	var c=u;
	zListingInfiniteScrollDiv=document.getElementById("zListingInfinitePlaceHolder");
	if(c.indexOf("/z/listing/search-js/index") !== -1) return;
	var d=document.getElementById("zListingEnableInstantSearch");
	if((d && d.value === "1") && (c.indexOf("/z/listing/instant-search/index") !== -1 || zListingInfiniteScrollDiv)){
		if(!zListingSearchJSDivFirstTime) return;
		zListingSearchJSDivFirstTime=false;
		zListingSearchJSActivated=true;
		zListingShowSearchJsDiv();
		zContentTransition.bind(function(newUrl){
			if(newUrl.indexOf("/z/listing/instant-search/index") !== -1){
				zContentTransition.disableNextAnimation=true;
				zListingShowSearchJsDiv();
				zListingHideSearchJsToolDiv();
				setTimeout(function(){zForceSearchJsScrollTop();
				if(window.parent.document.getElementById("zSearchJsNewDivPlaceholder")){
					window.parent.zScrollTop('html, body', $(window.parent.document.getElementById("zSearchJsNewDivPlaceholder")).position().top);
				}else if(document.getElementById("zSearchJsNewDivPlaceholder")){
					window.zScrollTop('html, body', $(document.getElementById("zSearchJsNewDivPlaceholder")).position().top);
				}
				},50);
			}else{
				zListingHideSearchJsDiv();
				zListingShowSearchJsToolDiv();
				setTimeout(zListingSearchJsToolPos,50);
			}
			zContentTransition.manuallyProcessTransition();
		});
	}else{
		zListingShowSearchJsToolDiv();
	}
}

zArrLoadFunctions.push({functionName:zListingLoadSearchJsDiv});

//var zMapCoorUpdateV3=null;
function getMLSCount2(formName){
	getMLSCount(formName, true);
}
function getMLSCount(formName,newForm){
	zSearchFormChanged=true; 
	//clearInterval(zCoorUpdateIntervalIdV3);
	//zCoorUpdateIntervalIdV3=0;
	var v1=document.getElementById("search_map_lat_blocks");
	/*if(zIsTouchscreen() === false && typeof zMapCoorUpdateV3 !== "undefined" && v1 && v1.value==""){ 
		 return "0";
	} */
	var ab=zFormData[formName].action;
	var cb=zFormData[formName].onLoadCallback;
	var aj=zFormData[formName].ajax;
	zFormData[formName].ajax=true;
	zFormData[formName].ignoreOldRequests=true;
	if(typeof newForm !== "undefined" && newForm){
		zFormData[formName].onLoadCallback=displayMLSCount2;
	}else{
		zFormData[formName].onLoadCallback=displayMLSCount;
	}
	zFormData[formName].successMessage=false;
	
	zFormData[formName].action='/z/listing/search-form/ajaxCount';
	if(zDisableSearchFilter===1){
		zFormData[formName].action+="&zDisableSearchFilter=1";
	}
	zFormSubmit(formName,false,true);
	zFormData[formName].ajax=aj;
	zFormData[formName].action=ab;
	zFormData[formName].onLoadCallback=cb;
	return "1";
}
function zlsGotoMultiunitResults(coordinateList){
	var arrQ=[];
	var obj=zFormSubmit(zMLSSearchFormName, false, true,false, true);
	obj.search_map_coordinates_list=coordinateList;
	obj.search_within_map=1;
	for(var i in obj){
		if(typeof zlsSearchCriteriaMap[i] !== "undefined" && obj[i] !== ""){
			arrQ.push(zlsSearchCriteriaMap[i]+"="+obj[i]);
		}
	}
	var d1=arrQ.join("&");
	if(d1.length >= 1950){
		alert("You've selected too many criteria. Please reduce the number of selections for the most accurate search results.");
	}
	if(window.location.href.indexOf("superiorpropertieshawaii.com") !== -1){
		window.open('/search-compare.cfc?method=index&'+d1.substr(0,1950));
	}else{
		window.open('/z/listing/search-form/index?searchaction=search&'+d1.substr(0,1950));
	}
}