<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	application.zcore.template.setPlainTemplate(); 
	request.zos.debuggerEnabled=false;
	</cfscript>
	<style>
	.ze-row > div{border: 1px solid ##eee;}
	.ze-row > div{border-right:1px solid ##eee;}

	.widget-container{background-color:rgba(0,0,0,.2) !important; padding-left:1%; padding-top:1%;}
	.widget-box{ width:32.333%; background-color:##FFF; min-width:280px; margin-right:1%; margin-bottom:1%; float:left; border:1px solid ##EEE; box-shadow:0px 0px 10px rgba(0,0,0,0.5); }
	.widget-box h3{ background-color:##CCC; display:block; padding:5px; font-weight:normal; font-size:16px; color:##666;}
	.widget-button{ display:none; float:right; padding:3px;  font-size:12px; margin-right:5px; cursor:pointer;}
	.widget-box:hover{ transition:all ease-in 0.1s; box-shadow:0px 5px 20px rgba(0,0,0,.5); margin-top:-2px; background-color:##EEE; border:1px solid rgba(0,0,0,.5);}
	.widget-box:hover .widget-button{display:block;} 
	.widget-template{padding:5px; background-color:##F2F2F2;}
	.widget-template .ze-row, .widget-template p{ background-color:##FFF;}
	.widget-template .ze-row > div, .widget-template p{ padding:5px;}
	</style>   
	<div class="widget-container z-center-children z-equal-heights z-float" data-column-count="3">

		<div class="widget-box">
			<h3>1 Column <div class="widget-button">Click to Insert</div></h3>
			<div class="a2col widget-template">
				<p>Column1</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>2 Columns <div class="widget-button">Click to Insert</div></h3>
			<div class="a2col widget-template">
				<section class="ze-row">
					<div class="ze-1of2"><p>Column1</p></div>
					<div class="ze-1of2"><p>Column2</p></div>
				</section>
				<p>&nbsp;</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>3 Columns <div class="widget-button">Click to Insert</div></h3>
			<div class="a3col widget-template">
				<section class="ze-row">
					<div class="ze-1of3"><p>Column1</p></div>
					<div class="ze-1of3"><p>Column2</p></div>
					<div class="ze-1of3"><p>Column3</p></div>
				</section>
				<p>&nbsp;</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>1/3 &amp; 2/3 Column <div class="widget-button">Click to Insert</div></h3>
			<div class="a1third2third widget-template">
				<section class="ze-row">
					<div class="ze-a1of3"><p>Column1</p></div>
					<div class="ze-a2of3"><p>Column2</p></div>
				</section>
				<p>&nbsp;</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>2/3 &amp; 1/3 Column <div class="widget-button">Click to Insert</div></h3>
			<div class="a1third2third widget-template">
				<section class="ze-row">
					<div class="ze-a2of3"><p>Column1</p></div>
					<div class="ze-a1of3"><p>Column2</p></div>
				</section>
				<p>&nbsp;</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>4 Columns <div class="widget-button">Click to Insert</div></h3>
			<div class="a4col widget-template">
				<section class="ze-row">
					<div class="ze-1of4"><p>Column1</p></div>
					<div class="ze-1of4"><p>Column2</p></div>
					<div class="ze-1of4"><p>Column3</p></div>
					<div class="ze-1of4"><p>Column4</p></div>
				</section>
				<p>&nbsp;</p>
			</div>
		</div>
		<div class="widget-box">
			<h3>Button <div class="widget-button">Click to Insert</div></h3>
			<div class="abutton widget-template" data-allow-inline="1">
				<p class="ze-row"><a href="##" class="z-button">Button</a></p> 
			</div>
		</div> 
			
		<div class="widget-box">
			<h3>2 Column Content Flow <div class="widget-button">Click to Insert</div></h3>
			<div class="a2colText widget-template">
				<section class="ze-row"> 
					<div class="ze-column-count2">
						<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vehicula urna eu purus faucibus, eu dapibus est dignissim. Aliquam facilisis.   </p>
					</div> 
				</section> 
				<p>&nbsp;</p>
			</div>
		</div>

		<div class="widget-box">
			<h3>3 Column Content Flow <div class="widget-button">Click to Insert</div></h3>
			<div class="a3colText widget-template">
				<section class="ze-row"> 
					<div class="ze-column-count3">
						<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vehicula urna eu purus faucibus, eu dapibus est dignissim. Aliquam facilisis.   </p>
					</div> 
				</section> 
				<p>&nbsp;</p>
			</div>
		</div>
	</div>
 
	<script type="text/javascript">
	if(!window.parent.zInsertTinymceWidget){
    	alert('HTML Editor is missing');
	}
	zArrDeferredFunctions.push(function(){
		$(".widget-box").on("click", function(e){
			e.preventDefault();
			var theHTML = $(".widget-template", this)[0].innerHTML;
			var allowInline=this.getAttribute("data-allow-inline");
			if(!allowInline || allowInline=="0"){
				allowInline=false;
			}else{
				allowInline=true;
			}

			// Insert HTML into parent
			console.log(window.parent.document);
			window.parent.zInsertTinymceWidget(theHTML, allowInline);
		});
	}); 
	</script>
</cffunction> 

<!--- 
/z/misc/tinymce-widgets/debug
 --->
<cffunction name="debug" access="remote" localmode="modern">
    <cfscript>
application.zcore.template.setPlainTemplate();
    </cfscript>
 
<cfsavecontent variable="content">
<p>Paragraph outside a grid element</p>
<section class="ze-row">
<div class="ze-1of4">
<p>Column1</p>
<div>
<p class="ze-row"><a class="z-button" href="##">Button</a></p>
</div>
</div>
<div class="ze-1of4">
<p>Column2</p>
<div>
<p class="ze-row"><a class="z-button" href="##">Button</a></p>
</div>
</div>
<div class="ze-1of4">
<p>Column3</p>
</div>
<div class="ze-1of4">
<p>Column4</p>
</div>
</section>
<section class="ze-row">
<div class="ze-1of3">
<p>Column1</p>
</div>
<div class="ze-1of3">
<p>Column2</p>
</div>
<div class="ze-1of3">
<p>Column3</p>
</div>
</section>
<section class="ze-row">
<div class="ze-a1of3">
<p>Column1</p>
</div>
<div class="ze-a2of3">
<p>Column2</p>
</div>
</section>
<section class="ze-row">
<div class="ze-a2of3">
<p>Column1</p>
</div>
<div class="ze-a1of3">
<p>Column2</p>
</div>
</section>
<p>Paragraph outside a grid element</p>
<section class="ze-row">
<div class="ze-1of2">
<p>Column1</p>
</div>
<div class="ze-1of2">
<p>Column2</p>
</div>
</section>
<section class="ze-row">
<div class="ze-column ze-column-count2">
<p>st dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem. st dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem.</p>
</div>
</section>
<section class="ze-row">
<div class="ze-column ze-column-count3">
<p>st dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem. st dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem.</p>
</div>
</section>
<p>&nbsp;</p>
</div>
</cfsavecontent>
<div class="resizeHTMLEditorDiv" style="width:100%; max-width:1200px; margin:0 auto; height:600px;">
<cfscript>
htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
htmlEditor.instanceName= "content_summary";
htmlEditor.value= content;
htmlEditor.basePath= '/';
htmlEditor.width= "100%";
htmlEditor.autoResize=true;
htmlEditor.height= 250;
htmlEditor.create();
</cfscript>
</div>
<script>
zArrDeferredFunctions.push(function(){
	// inst.execCommand('mceAutoResize');
});
</script>
</cffunction>
</cfoutput>
</cfcomponent>