<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	application.zcore.template.setPlainTemplate();
	form.layout_setting_instance_id=application.zcore.functions.zso(form, 'layout_setting_instance_id', true, 0);
	if(form.layout_setting_instance_id NEQ 0){
		application.zcore.skin.includeCSS("/zupload/layout-setting-instance-#form.layout_setting_instance_id#.css");
	}
	echo('<h2 class="z-fh-30">Layout Example</h2>');
	</cfscript>  
	<style>
	.zapp-shell-container{padding-left:0px; padding-right:0px;}
	section:nth-child(even){ background-color:##555;}
	section:nth-child(odd){ background-color:##666;}
	section section{background:none !important;} 
	.z-fill-width, .z-container div, .z-column { background-color:##EEE !important;}
	.z-left-sidebar, .z-right-sidebar{ background-color:##ccc !important;} 
	</style> 
<div class="wrapper">
	<section>
		<div class="z-container"> 
			<div class="z-column">
				For visualizing space adjustments, background colors have been applied. Dark = section, light = z-column
			</div> 
		</div> 
	</section>
	<section>
		<div class="z-container z-pv-10">
			<div class="z-column " > 
				Each grid system can have columns that span 1 or more of the columns. Examples:
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
			<div class="z-1of4 " > 
				<div class="z-h-24">z-1of4</div>
				<div class="z-t-16">Text</div> 
			</div>
			<div class="z-2of4 " > 
				<div class="z-h-24">z-2of4</div>
				<div class="z-t-16">Text</div>
			</div> 
			<div class="z-1of4" > 
				<div class="z-h-24">z-1of4</div>
				<div class="z-t-16">Text</div>
			</div> 
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-1of3" > 
					<div class="z-h-24">z-1of3</div>
					<div class="z-t-16">Text</div>
				</div>
				<div class="z-2of3"> 
					<div class="z-h-24">z-2of3</div>
					<div class="z-t-16">Text</div> 
				</div> 
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-4of4" > 
					<div class="z-h-24">z-4of4</div>
					<div class="z-t-16">Text</div> 
				</div>
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-center-children"> 
				<div class="z-column" > 
					<h2>All Grid Systems</h2>
				</div>
			</div>
		</div>
	</section>
	<cfloop from="2" to="16" index="i">
		<cfscript>
		if(i gt 7 and i NEQ 12 and i NEQ 16){
			continue;
		}
		</cfscript>

		<section class="z-pv-10">
			<div class="z-container z-center-children"> 
				<div class="z-column z-h-18">#i# column grid system ( class="z-1of#i#" )</div> 
				<section class="z-center-children z-pv-10"> 
					<cfloop from="1" to="#i#" index="n">
						<div class="z-1of#i#" > 
							<div class="z-h-16">#n#</div>
						</div>
					</cfloop>
				</section>
			</div>
		</section>
	</cfloop> 

	<section class="z-pv-10">
		<div class="z-container">
			<div class="z-column z-h-18">Right sidebar with automatic fill width column</div> 
		</div>
		<div class="z-container z-mv-10"> 
			<div class="z-column z-p-0">
				<aside class="z-column z-fill-width">
					z-column and z-fill-width
				</aside>
				<section class="z-1of4 z-right-sidebar">
					z-1of4 and z-right-sidebar
				</section>
			</div> 
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container">
			<div class="z-column z-h-18">Left sidebar with automatic fill width column and reverse order html</div> 
		</div>
		<div class="z-container z-mv-10"> 
			<div class="z-column z-reverse-order z-p-0">
				<section class="z-column z-fill-width">
					z-column and z-fill-width
				</section>
				<aside class="z-1of4 z-left-sidebar">
					z-1of4 and z-left-sidebar
				</aside> 
			</div>
		</div>
	</section>

	<section class="z-pv-10">
		<div class="z-container z-mv-10">
			<div class="z-column z-h-18">Responsive Heading and Text Classes</div> 
		</div>
		<div class="z-container z-center-children z-equal-heights" data-column-count="3"> 
		 	<div class="z-1of3">
				<div class="z-h-36">
					z-h-36
				</div>  
				<div class="z-h-30">
					z-h-30
				</div>  
				<div class="z-h-24">
					z-h-24
				</div> 
				<div class="z-h-18">
					z-h-18
				</div>  
				<div class="z-h-14">
					z-h-14
				</div>  
			</div>
			<div class="z-1of3">
				<h1>Heading1</h1>
				<h2>Heading2</h2>
				<h3>Heading3</h3> 
				<h4>Heading4</h4>
				<h5>Heading5</h5>
			</div>
			<div class="z-1of3">
				<div class=" z-t-36">
				z-t-36
				</div> 
				<div class=" z-t-24">
				z-t-24
				</div> 
				<div class=" z-t-18">
				z-t-18
				</div>  
			</div>
		</div>
		<div class="z-container z-mv-10">
			<div class="z-column z-h-18">Fixed Size Heading and Text Classes</div> 
		</div>

		<div class="z-container z-center-children z-equal-heights" data-column-count="3"> 
		 	<div class="z-1of3">
				<div class="z-fh-36">
					z-fh-36
				</div>  
				<div class="z-fh-30">
					z-fh-30
				</div>  
				<div class="z-fh-24">
					z-fh-24
				</div> 
				<div class="z-fh-18">
					z-fh-18
				</div>  
				<div class="z-fh-14">
					z-fh-14
				</div>  
			</div>
			<div class="z-1of3">
				<h1 class="z-fh-36">Heading1</h1>
				<h2 class="z-fh-30">Heading2</h2>
				<h3 class="z-fh-24">Heading3</h3> 
				<h4 class="z-fh-18">Heading4</h4>
				<h5 class="z-fh-14">Heading5</h5>
			</div>
			<div class="z-1of3">
				<div class=" z-ft-36">
				z-ft-36
				</div> 
				<div class=" z-ft-24">
				z-ft-24
				</div> 
				<div class=" z-ft-18">
				z-ft-18
				</div>  
			</div>
		</div>
	</section>  
</div>
</cffunction>
	
</cfoutput>
</cfcomponent>