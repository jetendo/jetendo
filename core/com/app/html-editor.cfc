<cfcomponent output="false">
<cfoutput>
<!--- 	
<cfscript>
htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
htmlEditor.instanceName	= "member_description";
htmlEditor.value			= form.member_description;
htmlEditor.width			= "100%";
htmlEditor.height		= 150;
htmlEditor.createSimple();
</cfscript> --->
<cffunction name="CreateSimple" localmode="modern"
	access="public"
	output="true"
	returntype="any"
	hint="Outputs the editor HTML in the place where the function is called"
> 
	<cfparam name="this.instanceName" type="string" />
	<cfparam name="this.width" type="string" default="100%" />
	<cfparam name="this.height" type="string" default="200" /> 
	<cfparam name="this.value" type="string" default="" />  

	<cfscript>
	if(right(this.width, 2) EQ "px"){
		this.width=left(this.width, len(this.width)-2);
	} 
	if(not structkeyexists(request.zos, 'zTinyMceIncluded')){
    	request.zos.zTinyMceIncluded=true;
    	request.zos.zTinyMceIndex=0;
    	application.zcore.skin.includeJS("/z/a/scripts/tiny_mce/tinymce.min.js");
	}
	request.zos.zTinyMceIndex++;  
	savecontent variable="theReturn"{
		echo('<textarea id="#this.instanceName#" name="#this.instanceName#" class="tinyMceTextarea#request.zos.zTinyMceIndex#" cols="10" rows="10" style="width:#this.width#');
		if(this.width DOES NOT CONTAIN "%" and this.width DOES NOT CONTAIN "px"){
			echo('px');
		}
		echo('; height:#this.height#');
		if(this.height DOES NOT CONTAIN "%" and this.height DOES NOT CONTAIN "px"){
			echo('px');
		}
		echo(';">#htmleditformat(this.value)#</textarea>
		<style type="text/css">
		##newvalue23_ifr{max-width:100% !important;}
		</style>');
	}
	</cfscript> 

	<cfsavecontent variable="theScript"><script type="text/javascript">
	zArrDeferredFunctions.push(function(){

		tinymce.init({
			branding: false,
			selector : "tinyMceTextarea#request.zos.zTinyMceIndex#",
			menubar: false,
			//theme: 'modern',
			autoresize_min_height: 100,
			plugins: [
			'autoresize advlist autolink lists link image charmap print preview anchor textcolor',
			'searchreplace visualblocks code fullscreen',
			'insertdatetime media table contextmenu paste code'
			],
			setup : function(ed) {
				ed.on('blur', function(e) {
					if(typeof tinyMCE != "undefined"){
						tinyMCE.triggerSave();
					} 
				});
			},
			toolbar: 'undo redo |  formatselect | bold italic | alignleft aligncenter alignright alignjustify | link bullist numlist outdent indent | removeformat',
			content_css: []
		});  
		tinymce.EditorManager.execCommand('mceAddEditor', true, "#this.instanceName#");
	});
	</script></cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("scripts",theScript);
	</cfscript>
	#theReturn#
</cffunction>

<!--- 
<cfscript>
htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
htmlEditor.instanceName= "content_summary";
htmlEditor.value= content_summary;
htmlEditor.basePath= '/';
htmlEditor.width= "100%";
htmlEditor.height= 250;
htmlEditor.create();
</cfscript>
 --->
<cffunction name="Create" localmode="modern"
	access="public"
	output="true"
	returntype="any"
	hint="Outputs the editor HTML in the place where the function is called"
>

	<cfparam name="this.instanceName" type="string" />
	<cfparam name="this.autoResize" type="boolean" default="#false#" />
	<cfparam name="this.width" type="string" default="100%" />
	<cfparam name="this.height" type="string" default="200" />
	<cfparam name="this.toolbarSet" type="string" default="Default" />
	<cfparam name="this.value" type="string" default="" /> 
	<cfparam name="this.config" type="struct" default="#structNew()#" />

	<cfscript>
	if(right(this.width, 2) EQ "px"){
		this.width=left(this.width, len(this.width)-2);
	}
	var theScript=0;
	var theMeta="";
	var theReturn="";
	this.config.fileImageGalleryScript='/z/admin/files/gallery';
	this.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
	arrExtraCode=[];
	if(application.zcore.functions.zso(request.zos.globals, 'typekitURL') NEQ "" or application.zcore.functions.zso(request.zos.globals, 'fontsComURL') NEQ ""){
		arrayAppend(arrExtraCode, ' init_instance_callback: "forceCustomFontLoading",');
	} 
	fonts=application.zcore.functions.zso(request.zos.globals, 'editorFonts');
	if(fonts NEQ ""){
		arrayAppend(arrExtraCode, ' font_formats : 
		#request.zos.globals.editorFonts#
		"Andale Mono=andale mono,times;"+ 
		"Arial=arial,helvetica,sans-serif;"+ 
		"Arial Black=arial black,avant garde;"+ 
		"Book Antiqua=book antiqua,palatino;"+ 
		"Comic Sans MS=comic sans ms,sans-serif;"+ 
		"Courier New=courier new,courier;"+ 
		"Georgia=georgia,palatino;"+ 
		"Helvetica=helvetica;"+ 
		"Impact=impact,chicago;"+ 
		"Symbol=symbol;"+ 
		"Tahoma=tahoma,arial,helvetica,sans-serif;"+ 
		"Terminal=terminal,monaco;"+ 
		"Times New Roman=times new roman,times;"+ 
		"Trebuchet MS=trebuchet ms,geneva;"+ 
		"Verdana=verdana,geneva;"+ 
		"Webdings=webdings;"+ 
		"Wingdings=wingdings,zapf dingbats", ');
	}
	</cfscript>
    <cfif isDefined('request.zos.zTinyMceIncluded') EQ false>
    	<cfset request.zos.zTinyMceIncluded=true>
    	<cfscript>
		request.zos.zTinyMceIndex=0;
		</cfscript>
        <cfsavecontent variable="theMeta"><script type="text/javascript" src="/z/a/scripts/tiny_mce/tinymce.min.js"></script></cfsavecontent><cfscript>application.zcore.template.appendtag("meta",theMeta);</cfscript>
		<cfsavecontent variable="theMeta">

<cfscript>
request.zos.zTinyMceIndex++;
application.zcore.functions.zRequireFontFaceUrls();
</cfscript> 
</cfsavecontent>
<cfscript>
application.zcore.template.prependTag("scripts",theMeta);
</cfscript>
</cfif>
	<cfsavecontent variable="theReturn"><textarea id="#this.instanceName#" name="#this.instanceName#" class="tinyMceTextarea#request.zos.zTinyMceIndex#" cols="10" rows="10" style="width:#this.width#<cfif this.width DOES NOT CONTAIN "%" and this.width DOES NOT CONTAIN "px">px</cfif>; height:#this.height#<cfif this.height DOES NOT CONTAIN "%" and this.height DOES NOT CONTAIN "px">px</cfif>;">#htmleditformat(this.value)#</textarea>
	<style type="text/css">
	##newvalue23_ifr{max-width:100% !important;}
	</style>
</cfsavecontent>
	
	<cfsavecontent variable="theScript"><script type="text/javascript">
zArrDeferredFunctions.push(function(){

	tinymce.init({ 
		branding: false,
		fix_table_elements: 0,  
        selector : "tinyMceTextarea#request.zos.zTinyMceIndex#",
		document_base_url:'/',
		convert_urls: 0,
		browser_spellcheck: true,
		gecko_spellcheck :true,
		paste_remove_spans: 1,
		remove_script_host : 0,
		relative_urls : 0,
		forced_root_block : 'p',
		setup : function(ed) {
			ed.on('blur', function(e) {
				if(typeof tinyMCE != "undefined"){
					tinyMCE.triggerSave();
				} 
			});
		},
		<cfscript>
		if(this.width NEQ "" and this.width DOES NOT CONTAIN "%"){
		    echo(' width: #max(200, this.width)#, '&chr(10));
		}
		if(this.height NEQ "" and this.height DOES NOT CONTAIN "%"){
		    echo(' height: #max(100, this.height)#, '&chr(10));
		}
		</cfscript>
		#arrayToList(arrExtraCode, " ")#
	  /*selector: 'textarea', 
	  height: 500,*/
	  theme: 'modern',
	  plugins: [
	  <cfif this.autoResize>
	  	'autoresize',
	  	</cfif>
	  	'zsawidget',
	    'advlist autolink lists link zsaimage zsafile charmap print preview hr anchor pagebreak',
	    'searchreplace wordcount visualblocks visualchars code fullscreen',
	    'insertdatetime media nonbreaking save table directionality', // contextmenu
	    'emoticons paste textcolor colorpicker textpattern' // imagetools
	  ], // template 
	  fontsize_formats: '12px 14px 18px 24px 36px 42px 48px',
	  toolbar1: 'insertfile undo redo | fontselect fontsizeselect styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link zsaimage zsafile  	zsawidget',
	  toolbar2: 'print preview media | forecolor backcolor emoticons',
	  image_advtab: true, 
	  content_css: [ 
	  	<cfif not structkeyexists(request, 'zDisableTinyMCEJetendoFrameworkCSS')>
	  	"/z/stylesheets/zOS.css?zversion="+Math.random(),
		"/zupload/layout-global.css?zversion="+Math.random(),
		"/z/stylesheets/css-framework.css?zversion="+Math.random(),
		</cfif>
	    "#this.config.EditorAreaCSS#?zversion="+Math.random()
	  ]
	  <cfif this.autoResize>
	  ,resize:false
	  ,init_instance_callback: function (inst) { inst.execCommand('mceAutoResize'); }
	  </cfif>
	 }); 
	tinymce.EditorManager.execCommand('mceAddEditor', true, "#this.instanceName#");
 
});
</script></cfsavecontent>
<cfscript>
application.zcore.template.appendTag("scripts",theScript);
</cfscript>
	#theReturn#
</cffunction>

</cfoutput>
</cfcomponent>
