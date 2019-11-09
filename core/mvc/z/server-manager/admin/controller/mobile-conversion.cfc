<cfcomponent output="no">
<cfoutput>
<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<h2>Mobile Conversion</h2>
		<p><a href="/z/server-manager/admin/mobile-conversion/inline-class">Inline Style to Class Conversion</a></p>
		<p><a href="/z/server-manager/admin/mobile-conversion/responsive">Mobile/Responsive Conversion</a></p>
</cffunction>

<cffunction name="inline-class" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	i1=0;
	application.zcore.template.setPlainTemplate();
	</cfscript> 
 <style>
textarea{font-size:14px; line-height:16px;}
 </style>
	<div id="parentContainer1" style="display:none;">
</div>
<h2>Input CFML+JS+CSS+HTML that has inline styles</h2>
<p><a href="/z/server-manager/admin/mobile-conversion/inline-class">Go to responsive conversion</a></p>
 <textarea cols="100" rows="10" style="height:150px !important;" id="htmlContents"></textarea><br />

	<input type="text" name="classPrefix" id="classPrefix" value="sh-" />
<a href="##" onclick="doTransform();return false;" style="font-size:18px; border-radius:5px; background-color:##000; color:##FFF; margin-top:10px;display:inline-block;padding:10px;">Submit</a><br />

<h2>Output HTML - inline styles removed from html elements only using DOM.  The surrounding CFML, CSS and JS are not modified.</h2>
 <textarea cols="100" rows="20" id="htmlOutput" style="height:150px !important;"></textarea>


<h2>Output CSS - generated unique class names</h2>
 <textarea cols="100" rows="20" id="cssOutput" style="height:150px !important;"></textarea>

 
<cfscript>
application.zcore.skin.includeJS("/z/javascript/zTransformHTML.js");
</cfscript>

<script>
function doTransform(){
	var obj={
		container:document.getElementById("parentContainer1")
	};
	obj.classPrefix=$("##classPrefix").val();
	var zth=new zTransformHTML(obj);
}
zArrDeferredFunctions.push(function(){

});
</script>

</cffunction>
	

<cffunction name="responsive" access="remote" localmode="modern" returntype="any" roles="serveradministrator">
	<cfscript>
	i1=0;
	application.zcore.template.setPlainTemplate();
	form.link=application.zcore.functions.zso(form, 'link');
	form.resizeBoxes=1;
	form.resizeFonts=1;
	form.originalwidth=1200;
	form.newwidth=960;
	</cfscript> 
 <style>
.convertButton:link, .convertButton:visited{font-size:18px; border-radius:5px; background-color:##000; color:##FFF !important; margin-top:10px;display:inline-block;padding:10px;}
*{
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing:border-box;
}
.sh-table111{width:500px;}
.sh-table111 ##link{ width:100%;}
textarea{font-size:14px; line-height:16px;}
 </style>
	<cfsavecontent variable="out">
</cfsavecontent>
<h2>Input CFML+JS+CSS+HTML that has inline styles</h2>
<p><a href="/z/server-manager/admin/mobile-conversion/inline-class">Go to inline to class conversion</a></p>
 <div class="sh-table111">
Convert Type: <input type="radio" name="mobiletype" id="mobiletype1" value="1" checked="checked" /> Responsive
 <input type="radio" name="mobiletype" id="mobiletype2" value="1" /> Mobile Phone (single column percent based)<br />
 Resize Fonts: #application.zcore.functions.zInput_Boolean("resizefonts")#<br />
 Resize Boxes: #application.zcore.functions.zInput_Boolean("resizeboxes")#<br />
 Resize Padding: #application.zcore.functions.zInput_Boolean("resizepadding")#<br />
 Resize Margin: #application.zcore.functions.zInput_Boolean("resizemargin")#<br />
 Link on this domain: #application.zcore.functions.zInput_Text({name:"link"})#<br />
Original Width: #application.zcore.functions.zInput_Text({name:"originalwidth"})#<br />
New Width: #application.zcore.functions.zInput_Text({name:"newwidth"})#<br />
Primary Stylesheet URL: #application.zcore.functions.zInput_Text({name:"primaryStylesheet"})#<br />

 </div>
<h2><a href="##" onclick="loadLink(); return false;" class="convertButton">Reload and Convert</a> <a href="##" onclick="doTransform(); return false;" style="display:none;" id="convertButton1" class="convertButton">Convert</a></h2>
<div id="pleaseWait1">Please wait for content to load.</div>
 <textarea cols="100" rows="5" style="height:150px !important;" id="htmlContents">#htmleditformat(out)#</textarea><br />
<!--- 
<h2>Output HTML - inline styles removed from html elements only using DOM.  The surrounding CFML, CSS and JS are not modified.</h2>
 <textarea cols="100" rows="20" id="htmlOutput"></textarea> --->


<h2>Output CSS - generated unique class names</h2>
 <textarea cols="100" rows="20" style="height:150px !important;" id="cssOutput"></textarea>

	<div id="parentContainer1" style="width:992px;display:none;">
</div>
 
<style id="newStyle1"></style>
<cfscript>
application.zcore.skin.includeJS("/z/javascript/zResponsiveHTML.js");
</cfscript>


<script>
function loadLink(){
	var link=$("##link").val();
	if(link.length==0 || link.indexOf("http:") != -1 || link.indexOf("https:") != -1){
		alert("Link must be a root relative URL");
		return;
	}
	$("##pleaseWait1").show();
	$.ajax(link, { 
		success: function(data){
			$("##htmlContents").text(data);
			doTransform();
			$("##convertButton1").show();
			$("##pleaseWait1").hide();
		}
	});
}
function doTransform(){

	var obj={
		container:document.getElementById("parentContainer1"),
		originalWidth:parseInt($("##originalwidth").val()),
		newWidth:parseInt($("##newwidth").val()),
		resizeFonts:false,
		resizeBoxes:false,
		resizeMargin:false,
		resizePadding:false,
		link:$("##link").val(),
		primaryStylesheet:$("##primaryStylesheet").val()
	};
	var c=2;
	$("##parentContainer1").css("width", obj.newWidth+"px");
	if($("##mobiletype1:checked").val()){
		c=1;
	}
	if($("##resizeboxes1:checked").val()){ 
		obj.resizeBoxes=true;
	}
	if($("##resizefonts1:checked").val()){ 
		obj.resizeFonts=true;
	}
	if($("##resizepadding1:checked").val()){ 
		obj.resizePadding=true;
	}
	if($("##resizemargin1:checked").val()){ 
		obj.resizeMargin=true;
	}
	obj.boxObj={
		maxVerticalPadding:25,
		maxHorizontalPadding:10,
		maxVerticalMargin:20,
		maxHorizontalMargin:0
	};
	if(c == 2){
		obj.type="mobile";
		obj.fontObj={
			maxFontSize:25,
			minFontSize:13,
			headingFontSizeThreshold:20,
			headingRatio:0.7, // percent amount to reduce heading font
			bodyRatio:0.9 // percent amount to reduce body text font
		};
	}else{
		obj.type="tablet";
		obj.fontObj={
			maxFontSize:40,
			minFontSize:13,
			headingFontSizeThreshold:20,
			headingRatio:0.7, // percent amount to reduce heading font
			bodyRatio:0.9 // percent amount to reduce body text font
		};
	}
	var zth=new zResponsiveHTML(obj);
}
zArrDeferredFunctions.push(function(){
	//doTransform();
});
</script>

</cffunction>
</cfoutput>
</cfcomponent>