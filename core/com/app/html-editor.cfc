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
		<style>
		##newvalue23_ifr{max-width:100% !important;}
		</style>');
	}
	</cfscript> 

	<cfsavecontent variable="theScript"><script>
	zArrDeferredFunctions.push(function(){

		tinymce.init({
			branding: false,
			selector : "tinyMceTextarea#request.zos.zTinyMceIndex#",
			menubar: false,
			//theme: 'modern',
			//autoresize_min_height: 100,
			<cfscript>
			// autoheight made it harder to use the toolbars
			if(this.height NEQ "" and this.height DOES NOT CONTAIN "%"){
			    echo(' height: #max(100, this.height)#, '&chr(10));
			}
			//autoresize
			</cfscript>
			plugins: [
			' advlist autolink lists link image charmap print preview anchor textcolor',
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
        <cfsavecontent variable="theMeta"><script src="/z/a/scripts/tiny_mce/tinymce.min.js"></script></cfsavecontent><cfscript>application.zcore.template.appendtag("meta",theMeta);</cfscript>
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
	<style>
	##newvalue23_ifr{max-width:100% !important;}
	</style>
</cfsavecontent>
	
	<cfsavecontent variable="theScript"><script>
zArrDeferredFunctions.push(function(){ 
	function removeClasses(e){ 
		for(var i=0;i<e.childNodes.length;i++){
			e.childNodes[i]=removeClasses(e.childNodes[i]);
		}
		$(e).removeAttr("id").removeAttr("class");
	}
	function replaceSelectedText(replacementHTML) {
	    var sel, range;
	    if (window.getSelection) {
	        sel = window.getSelection();
	        if (sel.rangeCount) {
	            range = sel.getRangeAt(0);
	            range.deleteContents();
	            range.insertNode(document.createDocumentFragment(replacementHTML));
	        }
	    } else if (document.selection && document.selection.createRange) {
	        range = document.selection.createRange();
	        range.pasteHTML(replacementHTML);
	    }
	}
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
		paste_preprocess: function(plugin, args) {
			// strip all the classes that start with ze- or z-
			var c=args.content;
			c=c.replace(/<(ADDRESS|ARTICLE|DETAILS|DIALOG|FIELDSET|FIGCAPTION|FIGURE|FOOTER|HEADER|MAIN|NAV|SECTION|DIV|SPAN|TABLE|TR|THEAD|TBODY|TD)/g, "<p");
			c=c.replace(/<\/(ADDRESS|ARTICLE|DETAILS|DIALOG|FIELDSET|FIGCAPTION|FIGURE|FOOTER|HEADER|MAIN|NAV|SECTION|DIV|SPAN|TABLE|TR|THEAD|TBODY|TD)/g, "<\/p");
			c=c.replace(/<(address|article|details|dialog|fieldset|figcaption|figure|footer|header|main|nav|section|div|span|table|tr|thead|tbody|td)/g, "<p");
			c=c.replace(/<\/(address|article|details|dialog|fieldset|figcaption|figure|footer|header|main|nav|section|div|span|table|tr|thead|tbody|td)/g, "<\/p"); 
			var d=document.createElement("div");
			d.innerHTML=c; 
			removeClasses(d);
			console.log(this);
			console.log(plugin);
			c=d.innerHTML.replace(/<p>\s*<\/p>/g, ""); 
			console.log(args);
			args.content=c;
		},
		paste_postprocess: function(plugin, args) {
	        console.log(args);
	        //args.node.setAttribute('id', '42');
	    },
		setup : function(ed) {
		// 	ed.on("paste", function(e) { 
		// 		var c="";
		// 		e.preventDefault();
		// 		e.stopPropagation(); 
		// 		if (window.clipboardData && window.clipboardData.getData) {
		// 			c=window.clipboardData.getData('Text'); 
		// 			c="<p>"+c.split("\r\n").join("</p><p>")+"</p>";
		// 			c=c.split("\n").join("<br>");
		// 		}else{
		// 			c=e.clipboardData.getData('text/html'); 
		// 			if(c.length == 0){
		// 				c=e.clipboardData.getData('Text'); 
		// 				c="<p>"+c.split("\r\n").join("</p><p>")+"</p>";
		// 				c=c.split("\n").join("<br>");
		// 			}
		// 			console.log("content before", c);

		// 			c=c.replace(/<(ADDRESS|ARTICLE|DETAILS|DIALOG|FIELDSET|FIGCAPTION|FIGURE|FOOTER|HEADER|MAIN|NAV|SECTION|DIV|SPAN|TABLE|TR|THEAD|TBODY|TD)/g, "<p");
		// 			c=c.replace(/<\/(ADDRESS|ARTICLE|DETAILS|DIALOG|FIELDSET|FIGCAPTION|FIGURE|FOOTER|HEADER|MAIN|NAV|SECTION|DIV|SPAN|TABLE|TR|THEAD|TBODY|TD)/g, "<p");
		// 			c=c.replace(/<(address|article|details|dialog|fieldset|figcaption|figure|footer|header|main|nav|section|div|span|table|tr|thead|tbody|td)/g, "<p");
		// 			c=c.replace(/<\/(address|article|details|dialog|fieldset|figcaption|figure|footer|header|main|nav|section|div|span|table|tr|thead|tbody|td)/g, "<p"); 
		// 			var d=document.createElement("div");
		// 			d.innerHTML=c;  
		// 			removeClasses(d);  
		// 			c=d.innerHTML.replace(/<p>\s*<\/p>/g, "").replace(/<(\w+)(.|[\r\n])*?>/g, '<$1>').replace(/<!--.*?-->/g, "");   
		// 		}
		// 		replaceSelectedText(c);
		// 		return;
		// 		var range=ed.selection.getRng();
		// 		if(range.startOffset-range.endOffset != 0){
		// 			// replace content instead of append
		// 			if (window.getSelection) {
		// 			    // not IE case
		// 			    var selObj = window.getSelection();
		// 			    var selRange = selObj.getRangeAt(0);
		// 			    selRange.insertNode(d);

		// 			    var newElement = document.createElement("b");
		// 			    var documentFragment = selRange.extractContents();
		// 			    newElement.appendChild(documentFragment);
		// 			    selRange.insertNode(newElement);

		// 			    selObj.removeAllRanges();
		// 			} else if (document.selection && document.selection.createRange && document.selection.type != "None") {
		// 			    // IE case
		// 			    var range = document.selection.createRange();
		// 			    var selectedText = range.htmlText;
		// 			    var newText = '<b>' + selectedText + '</b>';
		// 			    document.selection.createRange().pasteHTML(newText);
		// 			}
		// 		}else{

		// 			e.preventDefault();
		// 			e.stopPropagation(); 
		// 			console.log('why');

		// 			var currentElement=ed.selection.getNode();   
		// 			// get P tag 
		// 			currentElement=currentElement.parentNode;
		// 			$(currentElement).append(c); 
		// 		} 

		// 		return;
		// 		while(currentElement){
		// 			if(currentElement.nodeName == "P"){
		// 				$(currentElement).parentNode.append(c); 
		// 				return;
		// 			}else if(currentElement.nodeName == "DIV"){
		// 				$(currentElement).append(c); 
		// 				return;
		// 			}else if(currentElement.nodeName == "##document"){
		// 				$(currentElement.body).append(c);
		// 				return;
		// 			}else if(currentElement.nodeName == "HTML"){
		// 				$("BODY", currentElement).append(c);
		// 				return;
		// 			}
		// 			currentElement=currentElement.parentNode;
		// 		}
		// 	} );
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
		
	  // <cfif this.autoResize>
	  // 	'autoresize',
	  // 	</cfif>
		</cfscript>
		#arrayToList(arrExtraCode, " ")#
	  //selector: 'textarea',  
	  theme: 'modern',
	  plugins: [
	  	//'zsawidget',
	    ' advlist autolink lists link zsaimage zsafile charmap print preview hr anchor pagebreak',
	    'searchreplace wordcount visualblocks visualchars code fullscreen',
	    'insertdatetime media nonbreaking save directionality', // contextmenu table
	    'emoticons paste textcolor colorpicker textpattern' //imagetools
	  ], // template 
	  fontsize_formats: '8pt 10pt 12pt 14pt 16pt 18pt 21pt 24pt 30pt 36pt 48pt',
	  toolbar1: 'insertfile undo redo | fontselect fontsizeselect styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link zsaimage zsafile  	zsawidget fullscreen',
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
