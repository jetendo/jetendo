<cfcomponent implements="zcorerootmapping.interface.widget" extends="zcorerootmapping.com.widget.baseWidget"> 
<cfoutput>  
<!--- 
cfcomponent must be defined like this for every widget:
<cfcomponent implements="zcorerootmapping.interface.widget" extends="zcorerootmapping.com.widget.baseWidget"> 

direct widget preview URL: 
/z/widget/widget-example/index

Be sure to implement ALL functions of the widget before moving your code to production.  If you have no custom variables / no upgrade scripts, that's fine, but be sure to have the same data structure and return statements.

Try to organize all of the static resources for a widget in a single directory tree.  For example: /z/widget/widget-example/ in the core project or /widget/widget-dev/example/ on a site.
  --->

<cffunction name="getHTML" localmode="modern" access="public" output="no"> 
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	df=arguments.ds.fields;
	/*
	This function is called during the rendering of a single instance of a widget.

	You may want to dump the arguments scope to see what is sent to this function. 
	writedump(arguments);

	Avoid the use of the id attribute in your widget html. 

	Your HTML will be automatically wrapped by the system in a container div which will have the ID that is contained in "arguments.dataFields.widgetContainer"

		Example:
		<div id="widgetInstance0" class="zWidgetContainer"> 
			YOUR CODE
		</div>
	
	If is ok to use logic / loops / and other advanced CFML to generate your HTML.
	*/
	</cfscript>
	<cfsavecontent variable="out">
		<div class="test-example-1">
			<div class="test-example-2">
				<div class="test-example-3">#df.Heading#</div>
				<div class="test-example-4">
					#df["Body Text"]#
				</div>
			</div>
			<div class="test-example-5">
				<cfif df["Image"] NEQ ""> 
					<img class="test-example-6" src="#df["Image"]#" alt="Broker">
				</cfif>
			</div>
		</div>
	</cfsavecontent>
	<cfscript>
	// It is not acceptable for widgets to output code directly.  They must return all output a single string.
	return out;
	</cfscript>
</cffunction>
	
<cffunction name="getJS" localmode="modern" access="public" output="no">  
	<cfargument name="widgetContainer" type="string" required="yes">
	<cfscript>
	/*
	This function is called during the rendering of a single instance of a widget.
	JavaScript is output at the very bottom of the page with all the other scripts.   Your code should always rely on async/deferrered execution as much as possible.

	Wherever you need to use $(document).ready(function(){}); or window.onload, be sure to use zArrDeferredFunctions.push(function(){}); instead.

	There are also other functions for events built-in to Jetendo CMS which should always be used instead of jquery or window objects for new custom code, including:
		zArrLoadFunctions.push({functionName:myLoadFunction});
		zArrResizeFunctions.push({functionName:myResizeFunction});
		zArrScrollFunctions.push({functionName:myScrollFunction});

	If you need to load external javascript, be sure to use application.zcore.skin.includeJS("/widget-path/your.js"); instead of <script src="/widget-path/your.js"></script>

	Make sure to return the inner contents of <script></script> only.  Your code will be combined and optimized and it can't contain the <script> tag since it will be in an external js file later.
	*/
	</cfscript>
	<script>
	<cfsavecontent variable="out">
	zArrDeferredFunctions.push(function(){
		var e="testWidgetJS - #arguments.widgetContainer#";
		console.log(e);
	});
	</cfsavecontent>
	</script>
	<cfscript>
	return out;
	</cfscript>
</cffunction>
	
<cffunction name="getCSS" localmode="modern" access="public" output="no"> 
	<cfargument name="layoutFields" type="struct" required="yes">
	<cfscript>
	cs=arguments.layoutFields;
	c=cs.widgetContainer;
	/*
	The CSS for widgets is compiled and cached once per widget instance.   This means you must define all the CSS without having access to the user data.  You must think of your returned CSS string as a static stylesheet that will the same for all users.

	This function is only for defining styles that need dynamic math adjustments or other dynamic changes based on the layout configuration variables.

	You should define any static CSS that doesn't need any per widget instance processing in external css files and define all the stylesheets this widget needs in the arrStylesheet array in the getConfig function instead of putting that code here.

	*/
	csd=cs["default"];
 	fs=csd["Font Scale"];
	</cfscript> 
<style>
<cfsavecontent variable="out">
#c# .test-example-1{ 
	padding:#round(csd["Container Padding"]*20)#px;
}
#c# .test-example-2{width:#round(csd["Left Column Width %"]*100)#%; padding-right:#csd["Column Gap"]#px;} 
#c# .test-example-5{width:#round((1-csd["Left Column Width %"])*100)#%;}
#c# .test-example-3{ font-size:#round(fs*36)#px; line-height:#round(fs*42)#px;}
#c# .test-example-4{ font-size:#round(fs*18)#px; line-height:#round(fs*24)#px;}
@media only screen and (max-width: 1362px) { 
#c# .test-example-3{ font-size:#round(fs*30)#px; line-height:#round(fs*36)#px; }
#c# .test-example-4{ font-size:#round(fs*16)#px; line-height:#round(fs*21)#px;}


}
@media only screen and (max-width: 992px) { 
#c# .test-example-4{ font-size:#round(fs*14)#px; line-height:#round(fs*18)#px;} 
#c# .test-example-3{ font-size:#round(fs*24)#px; line-height:#round(fs*30)#px;}
#c# .test-example-2{padding-bottom:#csd["Column Gap"]#px;}
#c# .test-example-5{width:100%;}
}
</cfsavecontent>
</style>
	<cfscript>
	return out;
	</cfscript>
</cffunction>


	
<cffunction name="getConfig" localmode="modern" access="public" output="no">
	<cfscript>
	// make sure to update all the string values to be unique and correct for this widget.

	cs={};
	// Change 2 to a unique number that is reserved for ONLY this widget across all Jetendo CMS sites.
	cs.id="1";
	// This should be a human readable name for this widget.  It is safe to change the name later.
	cs.name="Widget Example";
	// This should be a unique code name for the widget to avoid needing to use the widget id.  It should be unique across all widgets and match the component name for the widget.
	cs.codeName="widget-example";
	// Always start with 1 for the version and increment it only when you MUST define a custom upgrade process.   Don't change the version number on every minor change unless you absolutely must have the upgrade() function run to maintain backwards compatibility.
	cs.version=1;
	// Here you can define an array of all the external stylesheets used by this widget.  You can have 0 or more.
	cs.arrStylesheet=["/z/widget/widget-example/widget-example.css"];
 	// made there should be "previewValue" key below for dataFields

 	// TODO: need to support nested forms for recursive data
 	// more of the form field types supported by the visual form builder are also supported here.
 	// at the moment, I don't have documentation for all the ways you can define custom form fields.  We need to expand on the documentation here or online.

 	// dataFields is an array of all the data fields for this widget.  The end user will usually have access to edit these, so the form should be as user friendly as possible.
	cs.dataFields=[
		// Each structure in the array will become a separate form field.  They will appear in order.  Be sure to define at least, id, label, type, previewValue, and options.   Some fields support options and others don't have any.
		{
			id:"1",
			label:"Heading",
			type:"Text",
			required:true,
			defaultValue:"",
			previewValue:"Heading",
			options:{}
		},
		{
			id:"2",
			label:"Body Text",
			type:"HTML Editor",
			defaultValue:"",
			previewValue:"<p>Body Text</p>",
			options:{
				editorwidth:600,
				editorheight:300
			}
		},
		{
			id:"3",
			label:"Image",
			type:"Image",
			defaultValue:"",
			previewValue:application.zcore.functions.zGetImagePlaceholderURL(600, 600),
			options:{
				imagewidth:600,
				imageheight:600,
				imagecrop:0,
				imagemaskpath:""
			}
		}
	];
 	// layoutFields is an array of all the layout fields for this widget.  Usually only the developer will have access to edit these, so the form can contain technical terms or be more complex.
	cs.layoutFields=[
		{
			id:"1",
			label:"Font Scale", 
			type:'Slider',
			required:true,
			defaultValue:1,
			previewValue:1,
			options:{
				slider_from:0.5,
				slider_to:3,
				slider_step:0.1,
			}
		},
		{
			id:"2",
			label:"Container Padding", 
			type:'Slider',
			required:true,
			defaultValue:1,
			previewValue:1,
			options:{
				slider_from:0.5,
				slider_to:3,
				slider_step:0.1,
			}
		},
		{
			id:"3",
			label:"Left Column Width %", 
			type:'Slider',
			required:true,
			defaultValue:0.5,
			previewValue:0.5,
			options:{
				slider_from:0.1,
				slider_to:1,
				slider_step:0.05,
			}
		},
		{
			id:"4",
			label:"Column Gap", 
			type:'Number',
			required:true,
			defaultValue:10,
			previewValue:10,
			options:{
			}
		}
	];

	// you must return the above structure even if you don't have any form fields defined in either array.
	return cs;
	</cfscript>
</cffunction>


<cffunction name="upgrade" localmode="modern" access="public" output="no">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	// this function will be called once for each widget instance.  
	// dataStruct is all the fields in widget_instance for the single instance as a structure.
	// jsonStruct is the deserialized widget_instance_json_data data structure
	ds=arguments.dataStruct; 
	// add an if statement for each version of the widget.  Be sure to never delete the code for upgrading between older versions.
	if(ds.widget_version EQ 1){
		// upgrade to version 2

		// you may need to move files, change the names of fields, or migrate data from one place to another.   

		ds.widget_instance_version=2;
	}
	// after return the data, the json will be serialized again for you, and the widget_instance table will be updated, and any caches reset.
	return ds;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>