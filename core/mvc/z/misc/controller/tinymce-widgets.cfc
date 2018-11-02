<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	application.zcore.template.setPlainTemplate();

	</cfscript>
	<style>
		.bdr {border: 1px solid ##eee;}
		.br1 {border-right:1px solid ##eee;}
/*
column-count:
@med
on 767, switch to column-count:1 
*/
	</style>
	<form id="get-data-form" method="post">
		<!--- <textarea class="tinymce" id="texteditor"></textarea> --->
		<div class="z-container" style="margin-bottom:80px;">	
			
			<h1>2 Column Text Layout</h1>
			<div class="2colText" onclick="insertLayout('2colText')">
				<div class="widgetContainer">
					<section class="widgetSection bdr">
						<div class="z-container">
							<div class="colCount2" style="-webkit-column-count: 2; -moz-column-count: 2; column-count: 2;">
								<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vehicula urna eu purus faucibus, eu dapibus est dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem. Vestibulum quis velit ligula. Quisque congue ipsum sed urna vehicula, id fermentum massa vulputate. Curabitur sit amet dolor vestibulum, tempus sem eu, rhoncus risus. Praesent nulla ipsum, sollicitudin ut iaculis quis, ultrices id quam. Ut tempus condimentum justo, sed dapibus massa volutpat bibendum. Vivamus faucibus orci auctor nibh tincidunt sodales. Donec in imperdiet lectus, a lobortis ex. Phasellus eu augue pellentesque, tincidunt tellus nec, vulputate orci. Mauris non ipsum ante. Integer tempor lorem rutrum ipsum sodales, eu dictum neque mattis. Aenean lacinia, dolor sit amet bibendum consectetur, justo odio consequat diam, eget varius nisi lacus sit amet orci.

								Sed ac ex tincidunt elit posuere fringilla non iaculis turpis. Sed ullamcorper sodales tellus id eleifend. Etiam dolor magna, vulputate nec magna non, fermentum tincidunt massa. Mauris malesuada pellentesque felis, eget aliquet nibh faucibus ac. Ut elementum suscipit tempus. Donec nunc tortor, egestas sed faucibus nec, laoreet at libero. Etiam dui odio, sodales vitae nulla a, eleifend rhoncus elit. Mauris consequat augue vel luctus vulputate. Fusce pharetra blandit enim, id bibendum diam aliquet vitae. Integer vel tincidunt erat, in pulvinar erat. Maecenas nibh nulla, hendrerit non auctor ac, imperdiet at nisi.</p>
							</div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>

			<h1>3 Column Text Layout</h1>
			<div class="3colText" onclick="insertLayout('3colText')">
				<div class="widgetContainer">
					<section class="widgetSection bdr">
						<div class="z-container">
							<div class="colCount3" style="-webkit-column-count: 3; -moz-column-count: 3; column-count: 3;">
								<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vehicula urna eu purus faucibus, eu dapibus est dignissim. Aliquam facilisis, tortor at efficitur rutrum, dui dolor porttitor libero, quis laoreet augue enim vel ipsum. Sed sit amet odio malesuada nisi molestie posuere sit amet at sem. Vestibulum quis velit ligula. Quisque congue ipsum sed urna vehicula, id fermentum massa vulputate. Curabitur sit amet dolor vestibulum, tempus sem eu, rhoncus risus. Praesent nulla ipsum, sollicitudin ut iaculis quis, ultrices id quam. Ut tempus condimentum justo, sed dapibus massa volutpat bibendum. Vivamus faucibus orci auctor nibh tincidunt sodales. Donec in imperdiet lectus, a lobortis ex. Phasellus eu augue pellentesque, tincidunt tellus nec, vulputate orci. Mauris non ipsum ante. Integer tempor lorem rutrum ipsum sodales, eu dictum neque mattis. Aenean lacinia, dolor sit amet bibendum consectetur, justo odio consequat diam, eget varius nisi lacus sit amet orci.

								Sed ac ex tincidunt elit posuere fringilla non iaculis turpis. Sed ullamcorper sodales tellus id eleifend. Etiam dolor magna, vulputate nec magna non, fermentum tincidunt massa. Mauris malesuada pellentesque felis, eget aliquet nibh faucibus ac. Ut elementum suscipit tempus. Donec nunc tortor, egestas sed faucibus nec, laoreet at libero. Etiam dui odio, sodales vitae nulla a, eleifend rhoncus elit. Mauris consequat augue vel luctus vulputate. Fusce pharetra blandit enim, id bibendum diam aliquet vitae. Integer vel tincidunt erat, in pulvinar erat. Maecenas nibh nulla, hendrerit non auctor ac, imperdiet at nisi.</p>
							</div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>


			<h1>2 Column Layout</h1>
			<div class="2col" onclick="insertLayout('2col')">
				<div class="widgetContainer">
					<section class="widgetSection bdr">
						<div class="z-container">
							<div class="z-1of2 zb-1of2 br1 z-mv-0"><p>.z-1of2</p></div>
							<div class="z-1of2 zb-1of2 z-mv-0"><p>.z-1of2</p></div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>

			<h1>3 Column Layout</h1>
			<div class="3col" onclick="insertLayout('3col')">
				<div class="widgetContainer">
					<section class="widgetSection bdr">
						<div class="z-container">
							<div class="z-1of3 zb-1of2 br1 z-mv-0"><p>.z-1of3</p></div>
							<div class="z-1of3 zb-1of2 br1 z-mv-0"><p>.z-1of3</p></div>
							<div class="z-1of3 zb-1of2 z-mv-0"><p>.z-1of3</p></div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>
			<h1>1 Third / 2 Thirds Column Layout</h1>
			<div class="1third2third" onclick="insertLayout('1third2third')">
				<div class="widgetContainer">
					<section class="widgetSection bdr" >
						<div class="z-container">
							<div class="z-1of3 br1 z-mv-0"><p>.z-1of3</p></div>
							<div class="z-2of3 br1 z-mv-0"><p>.z-2of3</p></div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>

			<h1>4 Column Layout</h1>
			<div class="4col" onclick="insertLayout('4col')">
				<div class="widgetContainer">
					<section class="widgetSection bdr">
						<div class="z-container">
							<div class="z-1of4 zb-1of2 zm-1of2 br1 z-mv-0"><p>.z-1of4</p></div>
							<div class="z-1of4 zb-1of2 zm-1of2 br1 z-mv-0"><p>.z-1of4</p></div>
							<div class="z-1of4 zb-1of2 zm-1of2 br1 z-mv-0"><p>.z-1of4</p></div>
							<div class="z-1of4 zb-1of2 zm-1of2 z-mv-0"><p>.z-1of4</p></div>
						</div>
					</section>
				</div>
				<p>&nbsp;</p>
			</div>

			<!--- <h1>12 Column Layout</h1>
			<div class="12col">
				<div class="widgetContainer">
					<section class="widgetSection bdr" onclick="insertLayout(12)">
						<div class="z-container">
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 br1 z-mv-0"><p>.z-1of12</p></div>
							<div class="z-1of12 z-mv-0"><p>.z-1of12</p></div>
							<div style="clear:both;"></div>
						</div>
					</section>
				</div>
			</div> --->
		</div>
	</form>
	<script type="text/javascript">
		if(!window.parent.zInsertGalleryFile){
	    	alert('HTML Editor is missing');
		}
 
		function insertLayout(layout){
			// Get HTML to insert (from doc above)
			var theHTML = document.getElementsByClassName(layout)[0].innerHTML;

			// Insert HTML into parent
			console.log(window.parent.document);
			window.parent.zInsertGalleryFile(theHTML);
		}
	</script>
</cffunction> 

<cffunction name="debug" localmode="modern" access="remote" output="yes">
	<style>
		.mce-i-fa {
    		display: inline-block;
    		font: normal normal normal 14px/1 FontAwesome;
    		font-size: inherit;
    		text-rendering: auto;
    		-webkit-font-smoothing: antialiased;
    		-moz-osx-font-smoothing: grayscale;
		}
	</style>
	<cfscript>
	application.zcore.template.setPlainTemplate();

	</cfscript>
	<cfscript> 
	htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor"); 
	htmlEditor.instanceName     = "office_description"; 
	htmlEditor.value               = ""; 
	htmlEditor.basePath          = '/'; 
	htmlEditor.width               = "100%"; 
	htmlEditor.height          = 300; 
	htmlEditor.config.EditorAreaCSS="/z/stylesheets/editor.css"; 
	htmlEditor.create(); 
	</cfscript>


	<script type="text/javascript"> 
		function moveCaret(win, charCount) {
		    var sel, range;
		    if (win.getSelection) {
		        sel = win.getSelection();
		        if (sel.rangeCount > 0) {
		            var textNode = sel.focusNode;
		            var newOffset = sel.focusOffset + charCount;
		            sel.collapse(textNode, Math.min(textNode.length, newOffset));
		        }
		    } else if ( (sel = win.document.selection) ) {
		        if (sel.type != "Control") {
		            range = sel.createRange();
		            range.move("character", charCount);
		            range.select();
		        }
		    }
		}
		function executeInsertContent(position, content){
			setTimeout(function(){ 
				var editor=window.tinymce.activeEditor;
				moveCaret(document.getElementById("office_description_ifr").contentWindow, position);
				editor.insertContent(content);
			}, 200); 
	}
		zArrDeferredFunctions.push(function(){

		// 	setTimeout(function(){
		// 	var f=$("office_description", document.getElementById("office_description_ifr").contentWindow);
		// 	console.log(f);
		//  moveCaret(document.getElementById("office_description_ifr").contentWindow, 5);
		// }, 3000);
		});
		</script>
</cffunction> 
</cfoutput>
</cfcomponent>