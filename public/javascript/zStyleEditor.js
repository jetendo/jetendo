
(function($, window, document, undefined){
	"use strict";
	
var zStyleEditor=function(options){
	var self=this;

	var config=options.config;
	if(config == ""){
		config={
			fonts:{},
			sizes:{},
			spaces:{},
			colors:{}
		};
	}
	if(typeof config.css != "undefined"){
		delete config.css;
	}
	if(typeof options.selector == "undefined"){
		options.selector="body ";
	}
	if(typeof config.fonts == "undefined"){
		config.fonts={};
	}
	if(typeof config.sizes == "undefined"){
		config.sizes={};
	}
	if(typeof config.spaces == "undefined"){
		config.spaces={};
	}
	if(typeof config.colors == "undefined"){
		config.colors={};
	}
	if(typeof options === undefined){
		options={};
	} 
 	var configReduced=config;

	function executeParentCallback(){ 
		var f=window.parent.document.getElementById(options.field);
		if(typeof f != "undefined" && f){
			f.value=JSON.stringify(configReduced);
		}
	}     
	var interfaceHidden=false;

	var currentMousePosition={x:0, y:0};
	var currentScrollPosition={left:0, top:0};
	var dragging=false;
	function bindEvents(){ 
		$(".hideInterfaceLink").on("click", function(e){
			e.preventDefault();
			var self=this;
			$(".previewContainer").hide().toggleClass('previewContainerFull');
			if(interfaceHidden){
				interfaceHidden=false;
			}else{
				interfaceHidden=true;
			} 

			$(".zblanktemplatedivcontainer").css("transition", "padding ease 0.3s");
			$(".selectedBreakpointDiv").hide();
			$(".interfaceContainer").fadeToggle('fast', 'swing', function(){
				if(!interfaceHidden){
					$(".zblanktemplatedivcontainer").css("padding", "10px");
					$(self).html("Hide Interface");
					$(".selectedBreakpointDiv").css("position", "fixed").show();;
				}else{
					$(self).html("Show Interface");
					$(".zblanktemplatedivcontainer").css("padding", "0px");
					$(".selectedBreakpointDiv").css("position", "relative").show();;
				}
				$(".previewContainer").fadeIn('fast');
				editorChanged();
			});
		});
		$(window).on("mouseleave", function(e){
			dragging=false;
		});
		$(".interfaceContainer").on("selectstart", function(e){
			e.preventDefault();
		});
		$(".interfaceContainer").on("mousedown", function(e){
			currentMousePosition={x:zMousePosition.x, y:zMousePosition.y};
			currentScrollPosition={left:$(this).scrollLeft(), top:$(this).scrollTop()};
			dragging=true;
		});
		$(".interfaceContainer").on("mousemove", function(e){
			if(dragging){
				var m=zMousePosition;
				var xMove=(m.x-currentMousePosition.x)*2;
				var yMove=(m.y-currentMousePosition.y)*2;
				//console.log(xScroll+":"+yScroll);
				var width=$(this).width();
				var tableWidth=$(".styleEditorTable").width();
				var xMaxScroll=tableWidth-width;
				var height=$(this).height();
				var tableHeight=$(".styleEditorTable").height();
				var yMaxScroll=tableHeight-height;

				var xScroll=Math.max(Math.min(xMaxScroll, currentScrollPosition.left-xMove), 0);
				var yScroll=Math.max(Math.min(yMaxScroll, currentScrollPosition.top-yMove), 0);
				console.log("scroll to "+xScroll+", "+yScroll);
				this.scrollTo(xScroll, yScroll);
			}
		});
		$(".interfaceContainer").on("mouseup", function(e){
			if(dragging){
			}
			dragging=false;
		});

		$(".serverRenderCheckbox").on("change", function(e){
			e.preventDefault();
			if(this.checked){
				serverRender=true; 
			}else{ 
				serverRender=false;
			}
			editorChanged();
		});

		$("#"+options.formId+" .zColorEditLink").on("click", function(e){
			e.preventDefault();
			var field=$(this).attr("data-field");
			$("#"+options.formId+" ."+field+"_color").show();
			$("#"+options.formId+" ."+field+"_color_box").hide();
			$(this).hide();
			$("#"+options.formId+" ."+field+"_color_reset").show();
			$("#"+options.formId+" ."+field+"_color").trigger("focus");
			$("#"+options.formId+" ."+field+"_color").trigger("blur");
			setTimeout(function(){
				// forces color picker to reset the position
				$("#"+options.formId+" ."+field+"_color").trigger("focus");
			}, 1);
			if($("#"+options.formId+" ."+field).val() == ""){
				$("#"+options.formId+" ."+field).val("FFFFFF");
			}
			var baseValue=$("#"+field).attr("data-base-value");
			setColorBorder(field, $("#"+options.formId+" ."+field).val(), baseValue);
			editorChanged();
		});
		$("#"+options.formId+" .zColorResetLink").on("click", function(e){
			e.preventDefault();
			var field=$(this).attr("data-field");
			var originalValue=$("#"+options.formId+" ."+field).attr("data-original-value");
			var empty=false;
			$("#"+options.formId+" ."+field).val(originalValue);
			if(originalValue == ""){
				empty=true;
				originalValue="FFFFFF";
			}
			$("#"+options.formId+" ."+field+"_color_box").css("background-color", "#"+originalValue);
			$("#"+options.formId+" ."+field+"_color").css("background-color", "#"+originalValue).val(originalValue);
			$("#"+options.formId+" ."+field+"_color").hide();
			if(!empty){
				$("#"+options.formId+" ."+field+"_color_box").show();
			}
			$(this).hide();
			$("#"+options.formId+" ."+field+"_color_edit").show();
			var baseValue=$("#"+field).attr("data-base-value");
			setColorBorder(field, $("#"+options.formId+" ."+field).val(), baseValue);
			editorChanged();
		});
		$("#"+options.formId+" .zColorInput").on("keyup", function(e){
			if(e.which==27){
				// escape pressed.
				var field=$(this).attr("data-field");
				var baseValue=$("#"+options.formId+" ."+field).attr("data-base-value");
				$("#"+options.formId+" ."+field).attr("data-original-value", baseValue);
				$("#"+options.formId+" ."+field).val(baseValue);
				$("#"+options.formId+" ."+field+"_color_reset").trigger("click");
				setColorBorder(field, $("#"+options.formId+" ."+field).val(), baseValue);
			}else{
				var field=$(this).attr("data-field");
				var baseValue=$("#"+field).attr("data-base-value");
				$("#"+options.formId+" ."+field).val(this.value);
				setColorBorder(field, $("#"+options.formId+" ."+field).val(), baseValue);
				editorChanged();
			}
		});
		$("#"+options.formId+" .zColorInput").on("change", function(e){
			var field=$(this).attr("data-field");
			var baseValue=$("#"+field).attr("data-base-value");
			$("#"+options.formId+" ."+field).val(this.value);
			setColorBorder(field, $("#"+options.formId+" ."+field).val(), baseValue);
			editorChanged();
		});
		$("#"+options.formId+" .undoOnEscapeInput").on("mouseout mouseleave", function(e){
			// this fixes mousewheel not firing the last event.
			if($(this).is(":focus")){
				$(this).trigger("change");
				editorChanged();
			}
		});
		$("#"+options.formId+" .undoOnEscapeInput").on("mousewheel keyup paste", function(e){
			var field=this.id;
			var baseValue=$(this).attr("data-base-value");
			setColorBorder(field, this.value, baseValue);
			editorChanged();
			return true;
		});
		$("#"+options.formId+" .undoOnEscapeInput").on("keyup", function(e){
			if(e.which==27){
				// escape pressed.
				var field=this.id;
				var baseValue=$(this).attr("data-base-value");
				this.value=baseValue;
				setColorBorder(field, this.value, baseValue);
				editorChanged();
			}
		});
	}
	function setColorBorder(field, value, baseValue){
		if(value != baseValue){
			// change border
			$("#"+options.formId+" ."+field).css("border", "2px solid #eb85ee");
			$("#"+options.formId+" ."+field+"_color").css("border", "2px solid #eb85ee");
			$("#"+options.formId+" ."+field+"_color_box").css("border", "2px solid #eb85ee");
		}else{
			$("#"+options.formId+" ."+field).css("border", "2px solid #AAA");
			$("#"+options.formId+" ."+field+"_color").css("border", "2px solid #AAA");
			$("#"+options.formId+" ."+field+"_color_box").css("border", "2px solid #AAA");
		}

	}
	function splitFontStyles(style, struct){
		var arrF=style.split(";");
		for(var f1 in arrF){
			var f=arrF[f1].trim();
			if(f != ""){
				var arrPart=f.split(":");
				if(arrPart.length == 2){
					arrPart[0]=arrPart[0].trim();
					arrPart[1]=arrPart[1].replace(" !important", "").trim();
					if(arrPart[0] == "font-family" || arrPart[0] == "font-weight" || arrPart[0] == "font-style"){
						if(arrPart[0] != "" && arrPart[1] != ""){
							struct[arrPart[0]]=arrPart[1]+" !important;";
						}
					}
				}
			}
		}
	}

	function getTRBLCSS(type, style, struct){
		var arrF=style.split(",");
		if(arrF.length == 4){
			if(arrF[0] != ""){
				arrF[0]=parseInt(arrF[0]);
				if(!isNaN(arrF[0])){
					arrF[0]+="px";
				}
				struct[type+"-top"]=arrF[0]+";";
			}
			if(arrF[1] != ""){
				arrF[1]=parseInt(arrF[1]);
				if(!isNaN(arrF[1])){
					arrF[1]+="px";
				}
				struct[type+"-right"]=arrF[1]+";";
			}
			if(arrF[2] != ""){
				arrF[2]=parseInt(arrF[2]);
				if(!isNaN(arrF[2])){
					arrF[2]+="px";
				}
				struct[type+"-bottom"]=arrF[2]+";";
			}
			if(arrF[3] != ""){
				arrF[3]=parseInt(arrF[3]);
				if(!isNaN(arrF[3])){
					arrF[3]+="px";
				}
				struct[type+"-left"]=arrF[3]+";";
			}
		}
	}

	function getStylesheetData(baseConfig, config, selector, debug){
		if(selector == ""){
			selector="body ";
		}
		var sd={};
		var b=breakpointFields;
		for(var n in b){
			sd[b[n]]=[];
			if(!options.breakpoints){
				break;
			}
		} 
		var c = $.extend(true, {}, config);
		// remove fields that match baseConfig
		if(typeof c.fonts != "undefined"){
			for(var field in c.fonts){
				if(typeof baseConfig.fonts != "undefined" && typeof baseConfig.fonts[field] != "undefined" && baseConfig.fonts[field] == c.fonts[field]){
					delete c.fonts[field];
				}
			} 
			for(var key in c){
				if(key == "fonts"){
					continue;
				}
				if(typeof baseConfig[key] == "undefined"){
					continue;
				}
				for(var field in c[key]){
					if(typeof baseConfig[key][field] == "undefined"){
						continue;
					}
					for(var b1 in breakpointFields){ 
						var bp=breakpointFields[b1];
						if(typeof baseConfig[key][field][bp] != "undefined" && typeof c[key][field][bp] != "undefined" && baseConfig[key][field][bp] == c[key][field][bp]){
							delete c[key][field][bp];
						} 
					} 
					if(Object.keys(c[key][field]).length == 0){
						delete c[key][field];
					}
				}
			} 
		}
		// remove empty values
		for(var i in c){
			if(i == "fonts"){
				for(var field in c[i]){
					if(debug){
						c[i][field]="font-family:testFont;";
					}
					if(c[i][field] == ""){
						delete c[i][field];
					}
				}
			}else{
				for(var field in c[i]){
					for(var b1 in b){
						var n=b[b1];
						if(debug){
							c[i][field][n]="test";
						}
						if(typeof c[i][field][n] != "undefined" && c[i][field][n] == ""){
							delete c[i][field][n];
						}
					} 
				}
			}
		}  
		if(!options.fonts){
			c.fonts={};
		}  
		if(!options.sizes){
			c.sizes={};
		}  
		if(!options.spaces){
			c.spaces={};
		}  
		if(!options.colors){
			c.colors={};
		}
		configReduced=c;
	 	var ts={};
		for(var b1 in b){
			var n=b[b1];
			ts={}; 
			if(typeof zso(c.spaces, "padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.padding[n], ts);
			}
			if(typeof zso(c.spaces, "margin", false, {})[n] != "undefined"){
				getTRBLCSS("margin", c.spaces.margin[n], ts);
			}
			if(typeof zso(c.sizes, "text_size", false, {})[n] != "undefined"){
				ts["font-size"]=c.sizes.text_size[n]+"px;";
			}
			if(typeof zso(c.sizes, "text_line_height", false, {})[n] != "undefined"){
				ts["line-height"]=c.sizes.text_line_height[n]+";";
			}
			if(typeof zso(c.colors, "container_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.container_background_color[n]+";";
			}
			if(typeof zso(c.colors, "text_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.text_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector, css:ts});
			}
			ts={};
			if(typeof zso(c.spaces, "text_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.text_padding[n], ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+"p", css:ts}); 
			}
			ts={};
			if(typeof zso(c.spaces, "list_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.list_padding[n], ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+"ul, "+selector+"ol", css:ts}); 
			}
			ts={};
			if(typeof zso(c.spaces, "heading_1_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.heading_1_padding[n], ts);
			}
			if(typeof zso(c.sizes, "heading_1_size", false, {})[n] != "undefined"){
				ts["font-size"]=c.sizes.heading_1_size[n]+"px;";
			}
			if(typeof zso(c.sizes, "heading_1_line_height", false, {})[n] != "undefined"){
				ts["line-height"]=c.sizes.heading_1_line_height[n]+";";
			}
			if(typeof zso(c.colors, "heading_1_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.heading_1_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(n == "Default" && typeof c.fonts.heading_1_font != "undefined"){ 
				splitFontStyles(c.fonts.heading_1_font, ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+"h1, "+selector+"h1 a:link, "+selector+"h1 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.spaces, "heading_2_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.heading_2_padding[n], ts);
			}
			if(typeof zso(c.sizes, "heading_2_size", false, {})[n] != "undefined"){
				ts["font-size"]=c.sizes.heading_2_size[n]+"px;";
			}
			if(typeof zso(c.sizes, "heading_2_line_height", false, {})[n] != "undefined"){
				ts["line-height"]=c.sizes.heading_2_line_height[n]+";";
			}
			if(typeof zso(c.colors, "heading_2_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.heading_2_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(n == "Default" && typeof c.fonts.heading_2_font != "undefined"){ 
				splitFontStyles(c.fonts.heading_2_font, ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+" h2, "+selector+" h2 a:link, "+selector+" h2 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.spaces, "heading_3_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.heading_3_padding[n], ts);
			}
			if(typeof zso(c.sizes, "heading_3_size", false, {})[n] != "undefined"){
				ts["font-size"]=c.sizes.heading_3_size[n]+"px;";
			}
			if(typeof zso(c.sizes, "heading_3_line_height", false, {})[n] != "undefined"){
				ts["line-height"]=c.sizes.heading_3_line_height[n]+";";
			}
			if(typeof zso(c.colors, "heading_3_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.heading_3_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(n == "Default" && typeof c.fonts.heading_3_font != "undefined"){ 
				splitFontStyles(c.fonts.heading_3_font, ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+" h3, "+selector+" h3 a:link, "+selector+" h3 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.background_color[n]+";";
			} 
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+" .z-container > *", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "link_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.link_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+" a:link, "+selector+" a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "link_hover_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.link_hover_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+" a:hover", css:ts}); 
			}
			ts={};
			if(typeof zso(c.spaces, "button_padding", false, {})[n] != "undefined"){
				getTRBLCSS("padding", c.spaces.button_padding[n], ts);
			}
			if(typeof zso(c.sizes, "button_text_size", false, {})[n] != "undefined"){
				ts["font-size"]=c.sizes.button_text_size[n]+"px;";
			}
			if(typeof zso(c.sizes, "button_line_height", false, {})[n] != "undefined"){
				ts["line-height"]=c.sizes.button_line_height[n]+";";
			}
			if(typeof zso(c.colors, "button_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.button_background_color[n]+";";
			}
			if(typeof zso(c.colors, "button_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.button_color[n]+";";
			}
			if(n == "Default" && typeof c.fonts.button_font != "undefined"){
				splitFontStyles(c.fonts.button_font, ts);
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".z-button, "+selector+".z-button:link, "+selector+".z-button:visited", css:ts}); 
			} 
			ts={};
			if(typeof zso(c.colors, "button_hover_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.button_hover_background_color[n]+";";
			}
			if(typeof zso(c.colors, "button_hover_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.button_hover_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".z-button:hover", css:ts}); 
			} 
			ts={};
			if(typeof zso(c.colors, "accent_button_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.accent_button_background_color[n]+";";
			}
			if(typeof zso(c.colors, "accent_button_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_button_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent .z-button, "+selector+".jdt-accent .z-button:link, "+selector+".jdt-accent .z-button:visited, .jdt-accent.z-button, "+selector+".jdt-accent.z-button:link, "+selector+".jdt-accent.z-button:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_container_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.accent_container_background_color[n]+";";
			}
			if(typeof zso(c.colors, "accent_text_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_text_color[n]+";";
			} 
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.accent_background_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent .z-container > *", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_link_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_link_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+"a.jdt-accent, "+selector+"a.jdt-accent:link, "+selector+"a.jdt-accent:visited, "+selector+".jdt-accent a:link, "+selector+".jdt-accent a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_heading_1_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_heading_1_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent h1, "+selector+".jdt-accent h1 a:link, "+selector+".jdt-accent h1 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_heading_2_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_heading_2_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent h2, "+selector+".jdt-accent h2 a:link, "+selector+".jdt-accent h2 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_heading_3_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_heading_3_color[n]+";";
				ts["text-decoration"]="none;";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent h3, "+selector+".jdt-accent h3 a:link, "+selector+".jdt-accent h3 a:visited", css:ts}); 
			}
			ts={};
			if(typeof zso(c.colors, "accent_link_hover_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_link_hover_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+"a.jdt-accent:hover, "+selector+".jdt-accent a:hover", css:ts}); 
			} 
			ts={};
			if(typeof zso(c.colors, "accent_button_hover_background_color", false, {})[n] != "undefined"){
				ts["background-color"]="#"+c.colors.accent_button_hover_background_color[n]+";";
			}
			if(typeof zso(c.colors, "accent_button_hover_color", false, {})[n] != "undefined"){
				ts["color"]="#"+c.colors.accent_button_hover_color[n]+";";
			}
			if(Object.keys(ts).length){
				sd[n].push({selector:selector+".jdt-accent .z-button:hover, .jdt-accent.z-button:hover", css:ts}); 
			} 
			if(!options.breakpoints){
				break;
			}
		}
		if(typeof c.fonts.text_font != "undefined"){
			ts={}; 
			splitFontStyles(c.fonts.text_font, ts);
			sd["Default"].push({selector:selector+", "+selector+" a:link, "+selector+" a:visited", css:ts}); 
		} 
		return sd;
	}
	function getStylesheet(sd){ 
		var css={}; 
		for(var i in breakpointFields){
			var b=breakpointFields[i];
			var tab="";
			if(typeof sd[b] == "undefined"){
				continue;
			}
			if(sd[b].length){
				var arrTemp=[];
				var t={};
				if(b != "Default"){
					//arrCSS.push('@media (max-width:'+b+'px){'+"\n");
					tab="\t";
				}
				for(var index in sd[b]){
					var ds=sd[b][index];
					arrTemp.push(tab+ds.selector+"{"+"\n");
					for(var key in ds.css){
						var value=ds.css[key];
						arrTemp.push(tab+"\t"+key+":"+value+"\n");
					}
					arrTemp.push(tab+"}"+"\n");
				}
				if(b != "Default"){
					//arrCSS.push('} /* media-end '+b+' */'+"\n");
				}
				css[b]=arrTemp.join("");
			}
			if(!options.breakpoints){
				break;
			}
		}
		return css;
	} 
	var serverRender=false;

	var loadPreviewTimeoutId=false;
	function loadPreview(){ 
		var baseSD=getStylesheetData({}, options.baseConfig, options.selector, false);
		var baseCSS=getStylesheet(baseSD);
		//console.log('baseCSS');
		//console.log(baseCSS);

		var sd=getStylesheetData(options.baseConfig, config, options.selector, false);
		//console.log(sd);
		var css=getStylesheet(sd);
		//console.log('css');
		//console.log(css); 


		var r={success:true, baseCSS:baseCSS, css:css};
		if(serverRender){
			clearTimeout(loadPreviewTimeoutId);
			loadPreviewTimeoutId=setTimeout(function(){
				var tempObj={};
				tempObj.id="zLoadPreview";
				tempObj.url="/z/misc/styleEditor/modalStylePreview";
				tempObj.postObj={
					sizes:options.sizes,
					fonts:options.fonts,
					colors:options.colors,
					spaces:options.spaces,
					breakpoints:options.breakpoints,
					selector:options.selector,
					baseConfig:JSON.stringify(options.baseConfig),
					config:JSON.stringify(configReduced)
				};
				tempObj.method="post";
				tempObj.callback=loadPreviewCallback;
				tempObj.cache=false;
				zAjax(tempObj);
			}, 500);
		}else{
			renderPreviewPanel(r);
		}
	}
	var selectedBreakpoint="";
	function loadPreviewCallback(r){
		var r=JSON.parse(r);
		if(r.success){ 
			renderPreviewPanel(r);
		}else{
			alert(r.errorMessage);
		}
	}
	var iframeLoaded=false;
	function renderPreviewPanel(r){

		var arrMergeCSS=[];
		var arrBaseCSS=[];
		var arrCSS=[];
		for(var i in breakpointFields){
			var bp=breakpointFields[i];
			if(bp != "Default"){
				arrMergeCSS.push('@media (max-width:'+bp+'px){'+"\n");
			} 
			if(typeof r.baseCSS[bp] != "undefined"){
				arrMergeCSS.push(r.baseCSS[bp]);
			}
			if(typeof r.css[bp] != "undefined"){
				arrMergeCSS.push(r.css[bp]);
			}
			if(typeof r.baseCSS[bp] != "undefined"){
				arrBaseCSS.push(r.baseCSS[bp]);
			}
			if(typeof r.css[bp] != "undefined"){
				arrCSS.push(r.css[bp]);
			}
			if(bp != "Default"){
				arrMergeCSS.push('} /* media-end '+bp+' */'+"\n");
			}
		}
		var stringMergedCSS=arrMergeCSS.join("\n");
		var stringBaseCSS=arrBaseCSS.join("\n");
		var stringCSS=arrCSS.join("\n");

		var cssCopy=stringMergedCSS;
		config.css=stringCSS;
		executeParentCallback();

// TODO: i could replace max-width with an impossibly high value to force those breakpoints to not show
// TODO: i could remove the extra media queries
// TODO: i could force the iframe to be minimum of 1400 when Default is selected
		var minWidth="1363";
		if(!interfaceHidden && selectedBreakpoint != ""){
			var arrDelete=[];
			if(selectedBreakpoint == "1362"){
				arrDelete=["1362"];
				minWidth="1050";
			}else if(selectedBreakpoint == "992"){
				arrDelete=["1362","992"];
				minWidth="810";
			}else if(selectedBreakpoint == "767"){
				arrDelete=["1362","992","767"];
				minWidth="530";
			}else if(selectedBreakpoint == "479"){
				arrDelete=["1362","992","767","479"];
				minWidth="400";
			}
			for(var i in arrDelete){
				stringMergedCSS=stringMergedCSS.replace('@media (max-width:'+arrDelete[i]+'px){', '');
				stringMergedCSS=stringMergedCSS.replace('} /* media-end '+arrDelete[i]+' */', ''); 
				stringBaseCSS=stringBaseCSS.replace('@media (max-width:'+arrDelete[i]+'px){', '');
				stringBaseCSS=stringBaseCSS.replace('} /* media-end '+arrDelete[i]+' */', ''); 
				stringCSS=stringCSS.replace('@media (max-width:'+arrDelete[i]+'px){', '');
				stringCSS=stringCSS.replace('} /* media-end '+arrDelete[i]+' */', ''); 
			}
		} 
		if(!iframeLoaded){
			$(".styleIframeContainer").html('<iframe id="stylePreviewIframe" width="100%" height="200" scrolling="no" frameborder="0" ></iframe>');
		}
		var stylePreviewIframe = document.getElementById( 'stylePreviewIframe' );
		var iframeDocument = stylePreviewIframe.contentWindow || ( stylePreviewIframe.contentDocument.document || stylePreviewIframe.contentDocument );
		if(!iframeLoaded){
			iframeLoaded=true; 
			iframeDocument.document.open();
			iframeDocument.document.write(iframeDocumentContents);
			iframeDocument.document.close(); 
		}
		iframeDocument.document.getElementById("stylePreviewStyle").innerHTML=stringMergedCSS;
		var iframeDocumentHeight=$(iframeDocument).height();
		
		if(interfaceHidden){
			$("#stylePreviewIframe").css({
				"height":iframeDocumentHeight+"px",
				"width":"100%"
			});
			$(".stylePreviewHTML").css("width","100%");
		}else{ 
			$("#stylePreviewIframe").css({
				"height":iframeDocumentHeight+"px",
				"width":minWidth+"px"
			});
			$(".stylePreviewHTML").css("width",minWidth+"px");
		}
		if(interfaceHidden){
			var panelHeight=$(window).height()-2;
			var panelWidth=Math.round($(window).width());
			$(".stylePreviewHTML").show();//.css("width", "100%");

		}else{
			var interfaceWidth=$(".interfaceContainer").width();
			console.log(interfaceWidth);
			var panelHeight=$(window).height()-2;
			var panelWidth=Math.round($(window).width()-interfaceWidth)-20;
			$(".stylePreviewHTML").show();//.css("width", panelWidth+"px"); 
			$(".previewContainer").css("left", (interfaceWidth+20)+"px");
		} 
		//$(".interfaceContainer").css("height", panelHeight+"px");
		var previewHeight=$(".stylePreviewHTML").height();
		var previewWidth=$(".stylePreviewHTML").width();
		if(previewHeight > panelHeight){
			var scale=panelHeight/previewHeight;
			var newWidth=scale*previewWidth;
			var newHeight=panelHeight;
			if(newWidth > panelWidth){
				scale=(panelWidth)/previewWidth;
				var newHeight=scale*previewHeight;
				var newWidth=panelWidth;
			}
		}else{
			var scale=panelWidth/previewWidth;
			var newHeight=scale*previewHeight;
			var newWidth=panelWidth;

		}
		scale=Math.min(1, Math.round(scale*100)/100);
		var top=0;
		var right=-Math.round(newWidth/scale/2);
		if(interfaceHidden){
			$(".stylePreviewHTML").css({
				"-webkit-transform" : "none",
				"-moz-transform"    : "none",
				"-ms-transform"     : "none",
				"-o-transform"      : "none",
				"transform":"none",
			    "-ms-transform-origin": "0% 0%",
			    "-webkit-transform-origin": "0% 0%",
			    "transform-origin": "0% 0%",
				"top":"0px", 
				"position":"relative"
			}); 
			$(".stylePreviewScale").hide(); 
		}else{
			if(scale == 1){
				$(".stylePreviewScale").hide(); 
			}else{
				$(".stylePreviewScale").show().html("Scaled to fit: "+Math.round(scale*100)+"%"); 
			}
			$(".stylePreviewHTML").css({
				"-webkit-transform" : "scale("+scale+")",
				"-moz-transform"    : "scale("+scale+")",
				"-ms-transform"     : "scale("+scale+")",
				"-o-transform"      : "scale("+scale+")",
				"transform":"scale("+scale+")",
			    "-ms-transform-origin": "0% 0%",
			    "-webkit-transform-origin": "0% 0%",
			    "transform-origin": "0% 0%",
				"top":top+"px", 
				"position":"fixed"
			}); 
		}
		$(".stylePreviewCSS").html('<textarea id="stylePreviewTextArea" cols="20" rows="5" style="height:'+panelHeight+'px; display:none; font-family:monospace; width:100%; font-size:9px;">'+htmlEntities.encode(cssCopy)+' </textarea>'); 
	}
	function editorChanged(){
		// read form state and store changes in config
		var obj=zGetFormDataByFormId(options.formId);
		for(var i in fontFields){
			var field=fontFields[i];
			var defaultValue=options.defaultConfig.fonts[field.field];
			var newValue=obj[field.field]; 
			if(newValue == "font-family:; font-weight:; font-style:;"){
				newValue=defaultValue;
			}
			if(defaultValue != newValue){
				config.fonts[field.field]=newValue;
			}else{
				config.fonts[field.field]="";
			}
		}
		if(options.sizes){
			for(var i in sizeFields){
				var field=sizeFields[i];
				for(var b in breakpointFields){
					var bp=breakpointFields[b];
					if(field.type == "marginPaddingBorder"){
						var defaultValue=options.defaultConfig.sizes[field.field][bp];
						var newValue=obj[field.field+"_"+bp+"_top"]+","+obj[field.field+"_"+bp+"_right"]+","+obj[field.field+"_"+bp+"_bottom"]+","+obj[field.field+"_"+bp+"_left"];
						if(newValue == ",,,"){
							newValue="";
						}
					}else{
						var defaultValue=options.defaultConfig.sizes[field.field][bp];
						var newValue=obj[field.field+"_"+bp];
					}
					if(defaultValue != newValue){
						config.sizes[field.field][bp]=newValue;
					}else{
						config.sizes[field.field][bp]="";
					}
				}
			}
		}

		if(options.spaces){
			for(var i in spaceFields){
				var field=spaceFields[i];
				for(var b in breakpointFields){
					var bp=breakpointFields[b];
					if(field.type == "marginPaddingBorder"){
						var defaultValue=options.defaultConfig.spaces[field.field][bp];
						var newValue=obj[field.field+"_"+bp+"_top"]+","+obj[field.field+"_"+bp+"_right"]+","+obj[field.field+"_"+bp+"_bottom"]+","+obj[field.field+"_"+bp+"_left"];
						if(newValue == ",,,"){
							newValue="";
						}
					}else{
						var defaultValue=options.defaultConfig.spaces[field.field][bp];
						var newValue=obj[field.field+"_"+bp];
					}
					if(defaultValue != newValue){
						config.spaces[field.field][bp]=newValue;
					}else{
						config.spaces[field.field][bp]="";
					}
				}
			}
		}

		if(options.colors){
			for(var i in colorFields){
				var field=colorFields[i];
				for(var b in breakpointFields){
					var bp=breakpointFields[b];
					var defaultValue=options.defaultConfig.colors[field.field][bp];
					var newValue=obj[field.field+"_"+bp];
					if(defaultValue != newValue){
						config.colors[field.field][bp]=newValue;
					}else{
						config.colors[field.field][bp]="";
					}
				}
			}
		}
		loadPreview(); 
	} 
	function getInputElement(fc, suffix){
		var arrHTML=[];  
		var currentValue=fc.value;
		var bgStyle=' border:2px solid #AAA;';
		if(fc.value != "" && fc.value != fc.baseValue){
			bgStyle=' border:2px solid #eb85ee;';
		}
		if(currentValue != ""){
			hasValue=true;
		}else if(fc.baseValue != ""){
			hasValue=true;
			currentValue=fc.baseValue;
		}
		if(fc.type == "lineHeight"){ 
			var style='width:'+fc.width+'; min-width:'+fc.width+'; ';
			arrHTML.push('<input type="number" step="0.1" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" class="'+fc.name+suffix+' undoOnEscapeInput" data-base-value="'+fc.baseValue+'" style="'+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'">');
		}else if(fc.type == "font"){ 
			var style='width:'+fc.width+'; min-width:'+fc.width+'; ';
			if(fc.value == ""){
				fc.value="font-family:; font-weight:; font-style:;";
			}
			arrHTML.push('<input type="text" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" class="'+fc.name+suffix+' undoOnEscapeInput" data-base-value="'+fc.baseValue+'" style="'+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'">');
		}else if(fc.type == "pixelNumber"){ 
			width="50px";
			var style='width:'+width+'; min-width:'+width+'; ';
			arrHTML.push('<input type="number" step="1" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" class="'+fc.name+suffix+' undoOnEscapeInput" data-base-value="'+fc.baseValue+'" style="'+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'"> px');
		}else if(fc.type == "color"){
			var style='width:50px; min-width:50px; ';

			arrHTML.push('<a href="#" class="zColorEditLink '+fc.name+suffix+'_color_edit" style="display:block; float:left; padding:3px; padding-left:7px; padding-right:7px; text-decoration:none; background-color:#369; border-radius:5px; color:#FFF; " data-field="'+fc.name+suffix+'">Edit</a>');
			arrHTML.push('<span class="'+fc.name+suffix+'_color_box" style=" margin-left:3px; border-radius:5px; border:1px solid #999; float:left; width:35px; height:23px; '+bgStyle);
			if(hasValue && currentValue !=""){
				arrHTML.push('background-color:#'+currentValue+';');
			}else{
				arrHTML.push('display:none;');
			}
			arrHTML.push('"></span>');
			arrHTML.push('<input type="hidden" class="'+fc.name+suffix+'" name="'+fc.name+suffix+'" id="'+fc.name+suffix+'" data-base-value="'+fc.baseValue+'" data-original-value="'+htmlEntities.encode(currentValue)+'" value="'+htmlEntities.encode(currentValue)+'">');
			arrHTML.push('<input type="text" class="zColorInput {required:false} '+fc.name+suffix+'_color" onkeyup="this.value.replace(\'#\', \'\');" data-field="'+fc.name+suffix+'" name="'+fc.name+suffix+'_color" id="'+fc.name+suffix+'_color" style="display:none; float:left; '+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'">'); 
			arrHTML.push('<a href="#" class="zColorResetLink '+fc.name+suffix+'_color_reset" title="Click to reset value to default" data-field="'+fc.name+suffix+'" style="display:none; padding:3px; padding-left:7px; padding-right:7px;margin-left:3px; border-radius:5px; text-decoration:none; background-color:#369; color:#FFF; float:left;">X</a>');
		}else if(fc.type == "marginPaddingBorder"){
			var arrValue=fc.value.split(",");
			if(arrValue.length != 4){
				arrValue=["", "", "", ""];
			}
			var arrBaseValue=fc.baseValue.split(",");
			if(arrBaseValue.length != 4){
				arrBaseValue=["", "", "", ""];
			}
			var width="45px";
			var margin="5px";
			var style='margin-right:'+margin+'; margin-bottom:'+margin+'; width:'+width+'; min-width:'+width+'; ';
			//var styleBottom='margin-right:'+margin+'; margin-bottom:'+margin+'; width:62px; min-width:62px;"; ';
			var styleBottom='margin-right:'+margin+'; margin-bottom:'+margin+'; width:'+width+'; min-width:'+width+'; ';
			var currentValue=arrValue[0];
			var hasValue=false;
			var tempValue=arrValue[0];
			var tempBaseValue=arrBaseValue[0];
			var bgStyle=' border:2px solid #AAA;';
			if(tempValue != "" && tempValue != tempBaseValue){
				bgStyle=' border:2px solid #eb85ee;';
			}
			if(currentValue != ""){
				hasValue=true;
			}else if(arrBaseValue[0] != ""){
				hasValue=true;
				currentValue=arrBaseValue[0];
			}
			arrHTML.push('<div style="width:100%; float:left; text-align:center;"><input type="number" step="1" placeholder="T" name="'+fc.name+suffix+'_top" id="'+fc.name+suffix+'_top" class="'+fc.name+suffix+'_top undoOnEscapeInput" data-base-value="'+tempBaseValue+'" style="'+styleBottom+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'"></div>');
			currentValue=arrValue[3];
			hasValue=false;
			var tempValue=arrValue[3];
			var tempBaseValue=arrBaseValue[3];
			var bgStyle=' border:2px solid #AAA;';
			if(tempValue != "" && tempValue != tempBaseValue){
				bgStyle=' border:2px solid #eb85ee;';
			}
			if(currentValue != ""){
				hasValue=true;
			}else if(arrBaseValue[3] != ""){
				hasValue=true;
				currentValue=arrBaseValue[3];
			}
			arrHTML.push('<div style="width:100%; float:left;"><div style="width:50%; text-align:left; float:left;"><input type="number" step="1" placeholder="L" name="'+fc.name+suffix+'_left" id="'+fc.name+suffix+'_left" class="'+fc.name+suffix+'_left undoOnEscapeInput" data-base-value="'+tempBaseValue+'" style="'+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'"></div>');
			currentValue=arrValue[1];
			hasValue=false;
			var tempValue=arrValue[1];
			var tempBaseValue=arrBaseValue[1];
			var bgStyle=' border:2px solid #AAA;';
			if(tempValue != "" && tempValue != tempBaseValue){
				bgStyle=' border:2px solid #eb85ee;';
			}
			if(currentValue != ""){
				hasValue=true;
			}else if(arrBaseValue[1] != ""){
				hasValue=true;
				currentValue=arrBaseValue[1];
			}
			arrHTML.push('<div style="width:50%; text-align:right; float:right;"><input type="number" step="1" placeholder="R" name="'+fc.name+suffix+'_right" id="'+fc.name+suffix+'_right" class="'+fc.name+suffix+'_right undoOnEscapeInput" data-base-value="'+tempBaseValue+'" style="'+style+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'"></div></div>');
			currentValue=arrValue[2];
			hasValue=false;
			var tempValue=arrValue[2];
			var tempBaseValue=arrBaseValue[2];
			var bgStyle=' border:2px solid #AAA;';
			if(tempValue != "" && tempValue != tempBaseValue){
				bgStyle=' border:2px solid #eb85ee;';
			}
			if(currentValue != ""){
				hasValue=true;
			}else if(arrBaseValue[2] != ""){
				hasValue=true;
				currentValue=arrBaseValue[2];
			}
			arrHTML.push('<div style="width:100%; float:left;text-align:center;"><input type="number" step="1" placeholder="B" name="'+fc.name+suffix+'_bottom" id="'+fc.name+suffix+'_bottom" class="'+fc.name+suffix+'_bottom undoOnEscapeInput" data-base-value="'+tempBaseValue+'" style="'+styleBottom+bgStyle+'" value="'+htmlEntities.encode(currentValue)+'"></div>');
		}
		return arrHTML.join('');
	}
	function scrollStyleEditor(){
		if($(window).scrollTop() > 55){
			$(".zStyleEditorFixed").show();
		}else{
			$(".zStyleEditorFixed").hide();
		}
	}
	function init(){
		buildStyleEditor();

		$(".breakpointLink").on("click", function(e){
			e.preventDefault();
			$(".breakpointLink").removeClass("breakpointSelected");
			selectedBreakpoint=$(this).attr("data-breakpoint");
			$(".breakpoint_"+selectedBreakpoint).addClass("breakpointSelected");
			//$(".selectedBreakpointDiv").html("Selected Breakpoint: "+selectedBreakpoint);
			if(selectedBreakpoint == "Default"){
				selectedBreakpoint="";
			}
			loadPreview();
			loadPreview();
		});

		zArrScrollFunctions.push({functionName:scrollStyleEditor});
		scrollStyleEditor();
		loadPreview();
		zArrResizeFunctions.push({functionName:loadPreview});
	}
	function buildStyleEditor(){
		var arrHTML=[];
		var labelWidth="145px";
		var breakWidth="110px";
		arrHTML.push('<div class="zStyleEditorFixed" style=" font-weight:bold; float:left; display:none; position:fixed; background-color:#FFF; color:#000;"><div style="float:left; padding: 3px; padding-left: 3px;  width:'+labelWidth+';"><a href="#" onclick="window.parent.zCloseModal(); return false;" class="z-manager-search-button">Close</a></div>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var tableWidth=145+(breakpointFields.length*110);
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<div style="float:left; width:'+breakWidth+';  padding: 3px; padding-top:8px; padding-right:0px; padding-left: 3px;  "><a href="#" title="Click to select this breakpoint." class="breakpointLink breakpoint_'+breakpointFields[i]+' ');
			if(breakpointFields[i] == "Default"){
				arrHTML.push('breakpointSelected');
			}
			arrHTML.push('" style="text-decoration:none;" data-breakpoint="'+breakpointFields[i]+'">'+breakpointFields[i]+'</a></div>');
		}
		arrHTML.push('</div>');
		arrHTML.push('<div class="styleEditorTableContainer"><table class="styleEditorTable table-list" style="width:'+tableWidth+'px;">');
		arrHTML.push('<tr style=" background-color:#FFF; color:#000;"><th class="styleEditorFixedColumn" style="width:'+labelWidth+';">&nbsp;</th>');
		if(!options.breakpoints){
			breakpointFields=["Default"];
		}
		var fullColspan=(breakpointFields.length+1);
		for(var i in breakpointFields){
			arrHTML.push('<th style="width:'+breakWidth+';"><a href="#" title="Click to select this breakpoint." class="breakpointLink breakpoint_'+breakpointFields[i]+' ');
			if(breakpointFields[i] == "Default"){
				arrHTML.push('breakpointSelected');
			}
			arrHTML.push('" data-breakpoint="'+breakpointFields[i]+'">'+breakpointFields[i]+'</a></th>');
		}
		arrHTML.push('</tr>');
		if(options.sizes){
			arrHTML.push('<tr><th class="styleEditorFixedColumn"  title="Click to toggle display of these fields" onclick="$(\'.sizeRow\').fadeToggle(\'fast\');" style="cursor:pointer; font-size:16px;">Adjust sizes</th><td colspan="'+(fullColspan-1)+'">&nbsp;</td></tr><tbody class="sizeRow" style="display:none;">');
			for(var field in sizeFields){
				var fd=sizeFields[field];
				if(typeof config.sizes[fd.field] == "undefined"){
					config.sizes[fd.field]={};
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th class="styleEditorFixedColumn" style="font-size:12px; font-weight:normal; white-space:nowrap;">'+fd.label+'</th>');
				for(var i in breakpointFields){ 
					if(typeof config.sizes[fd.field][breakpointFields[i]] == "undefined"){
						config.sizes[fd.field][breakpointFields[i]]="";
					}
					var value=config.sizes[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.sizes[fd.field] != "undefined" && typeof options.baseConfig.sizes[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.sizes[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px; ">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.spaces){
			arrHTML.push('<tr><th title="Click to toggle display of these fields" onclick="$(\'.spaceRow\').fadeToggle(\'fast\');" class="styleEditorFixedColumn" style="cursor:pointer; font-size:16px;width:'+labelWidth+';">Adjust spaces</th><td colspan="'+(fullColspan-1)+'">&nbsp;</td></tr><tbody class="spaceRow" style="display:none;">');
			for(var field in spaceFields){
				var fd=spaceFields[field];
				if(typeof config.spaces[fd.field] == "undefined"){
					config.spaces[fd.field]={};
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th class="styleEditorFixedColumn" style="font-size:12px; font-weight:normal; white-space:nowrap;">'+fd.label+'</th>');
				for(var i in breakpointFields){
					if(typeof config.spaces[fd.field][breakpointFields[i]] == "undefined"){
						config.spaces[fd.field][breakpointFields[i]]="";
					}
					var value=config.spaces[fd.field][breakpointFields[i]];
					if(!value){
						value=",,,";
					}
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.spaces[fd.field] != "undefined" && typeof options.baseConfig.spaces[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.spaces[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px;">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.colors){
			arrHTML.push('<tr><th class="styleEditorFixedColumn"  title="Click to toggle display of these fields" onclick="$(\'.colorRow\').fadeToggle(\'fast\');" style="cursor:pointer; font-size:16px;">Adjust colors</th><td colspan="'+(fullColspan-1)+'">&nbsp;</td></tr><tbody class="colorRow" style="display:none;">');
			for(var field in colorFields){
				var fd=colorFields[field];
				if(typeof config.colors[fd.field] == "undefined"){
					config.colors[fd.field]={};
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th class="styleEditorFixedColumn" style="font-size:12px; font-weight:normal; white-space:nowrap;">'+fd.label+'</th>');
				for(var i in breakpointFields){
					if(typeof config.colors[fd.field][breakpointFields[i]] == "undefined"){
						config.colors[fd.field][breakpointFields[i]]="";
					}
					var value=config.colors[fd.field][breakpointFields[i]];
					var fc={
						name:fd.field,
						type:fd.type,
						value:value,
						baseValue:"",
						width:"50px"
					};
					if(typeof options.baseConfig.colors[fd.field] != "undefined" && typeof options.baseConfig.colors[fd.field][breakpointFields[i]] != "undefined"){
						fc.baseValue=options.baseConfig.colors[fd.field][breakpointFields[i]];
					}
					var suffix="_"+breakpointFields[i];
					arrHTML.push('<td style=" padding-right:3px;">'+getInputElement(fc, suffix)+'</td>'); 
				}
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		if(options.fonts){
			arrHTML.push('<tr><th class="styleEditorFixedColumn"  title="Click to toggle display of these fields" onclick="$(\'.fontRow\').fadeToggle(\'fast\');" style="cursor:pointer; font-size:16px;">Adjust fonts</th><td colspan="'+(fullColspan-1)+'">&nbsp;</td></tr><tbody class="fontRow" style="display:none;"><tr><td colspan="'+fullColspan+'"><p>Please type in the font-family, font-weight, font-style CSS combination that will trigger the font to be applied.</p><p>It is recommended to exclude font-weight and font-style for "Text Font" so that regular, italic, bold, and bold italic in the same family will function correctly.</p><p>Examples:</p><p><code>font-family:\'Open Sans\'; font-weight:normal; font-style:normal;</code><br>or<br><code>font-family:\'Open Sans\';</code></p></td></tr>');
			for(var index in fontFields){
				var fd=fontFields[index]; 
				if(typeof config.fonts[fd.field] == "undefined"){
					config.fonts[fd.field]="";
				}
				arrHTML.push('<tr>');
				arrHTML.push('<th class="styleEditorFixedColumn" style="font-size:12px; font-weight:normal; white-space:nowrap;">'+fd.label+'</th>');
				var value=config.fonts[fd.field];
				var fc={
					name:fd.field,
					type:fd.type,
					value:value,
					baseValue:"",
					width:"100%"
				};
				if(typeof options.baseConfig.fonts[fd.field] != "undefined"){
					fc.baseValue=options.baseConfig.fonts[fd.field];
				}
				var suffix="";
				arrHTML.push('<td style=" padding-left:3px;" colspan="'+fullColspan+'">'+getInputElement(fc, suffix)+'</td>');
				arrHTML.push('</tr>');
			}
			arrHTML.push('</tbody>');
		}
		
		arrHTML.push('</table></div>');
		//arrHTML.push('<div class="z-float z-p-10"><a href="#" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Close</a></div>'); 
		var c=$(options.container);
		c.html(arrHTML.join(""));
		jscolor.bind();
		bindEvents();
		$(".interfaceContainer").show();
		$(".previewContainer").show();
		$(".selectedBreakpointDiv").show();
	} 

	var fontFields=[
		{
			field:"text_font",
			label:"Text Font",
			type:"font"
		},
		{
			field:"heading_1_font",
			label:"Heading 1 Font",
			type:"font"
		},
		{
			field:"heading_2_font",
			label:"Heading 2 Font",
			type:"font"
		},
		{
			field:"heading_3_font",
			label:"Heading 3 Font",
			type:"font"
		}
	];
	var spaceFields=[
		{
			field:"text_padding",
			label:"Text Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"list_padding",
			label:"List Padding (UL/OL)",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_1_padding",
			label:"Heading 1 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_2_padding",
			label:"Heading 2 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"heading_3_padding",
			label:"Heading 3 Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"button_padding",
			label:"Button Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"padding",
			label:"Padding",
			type:"marginPaddingBorder"
		},
		{
			field:"margin",
			label:"Margin",
			type:"marginPaddingBorder"
		}
	];
 
	var sizeFields=[
		{
			field:"text_size",
			label:"Text Size",
			type:"pixelNumber"
		},
		{
			field:"text_line_height",
			label:"Text Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_1_size",
			label:"Heading 1 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_1_line_height",
			label:"Heading 1 Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_2_size",
			label:"Heading 2 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_2_line_height",
			label:"Heading 2 Line Height",
			type:"lineHeight"
		},
		{
			field:"heading_3_size",
			label:"Heading 3 Size",
			type:"pixelNumber"
		},
		{
			field:"heading_3_line_height",
			label:"Heading 3 Line Height",
			type:"lineHeight"
		},
		{
			field:"button_text_size",
			label:"Button Text Size",
			type:"pixelNumber"
		},
		{
			field:"button_line_height",
			label:"Button Line Height",
			type:"lineHeight"
		}
	];
 
	var colorFields=[
		{
			field:"container_background_color",
			label:"Container BG",
			type:"color"
		},
		{
			field:"background_color",
			label:"BG",
			type:"color"
		},
		{
			field:"text_color",
			label:"Text",
			type:"color"
		},
		{
			field:"heading_1_color",
			label:"Heading 1",
			type:"color"
		},
		{
			field:"heading_2_color",
			label:"Heading 2",
			type:"color"
		},
		{
			field:"heading_3_color",
			label:"Heading 3",
			type:"color"
		},
		{
			field:"link_color",
			label:"Link",
			type:"color"
		},
		{
			field:"link_hover_color",
			label:"Link Hover",
			type:"color"
		},
		{
			field:"button_background_color",
			label:"Button BG",
			type:"color"
		},
		{
			field:"button_color",
			label:"Button",
			type:"color"
		},
		{
			field:"button_hover_background_color",
			label:"Button Hover BG",
			type:"color"
		},
		{
			field:"button_hover_color",
			label:"Button Hover",
			type:"color"
		},
		{
			field:"accent_container_background_color",
			label:"Accent Container BG",
			type:"color"
		},
		{
			field:"accent_background_color",
			label:"Accent BG",
			type:"color"
		},
		{
			field:"accent_text_color",
			label:"Accent Text",
			type:"color"
		},
		{
			field:"accent_heading_1_color",
			label:"Accent Heading 1",
			type:"color"
		},
		{
			field:"accent_heading_2_color",
			label:"Accent Heading 2",
			type:"color"
		},
		{
			field:"accent_heading_3_color",
			label:"Accent Heading 3",
			type:"color"
		},
		{
			field:"accent_link_color",
			label:"Accent Link",
			type:"color"
		},
		{
			field:"accent_link_hover_color",
			label:"Accent Link Hover",
			type:"color"
		},
		{
			field:"accent_button_background_color",
			label:"Accent Button BG",
			type:"color"
		},
		{
			field:"accent_button_color",
			label:"Accent Button",
			type:"color"
		},
		{
			field:"accent_button_hover_background_color",
			label:"Accent Button Hover BG",
			type:"color"
		},
		{
			field:"accent_button_hover_color",
			label:"Accent Button Hover",
			type:"color"
		}
	];
	var breakpointFields=[
		"Default", "1362", "992", "767", "479"
	];
	init();

	return this;
};
window.zStyleEditor=zStyleEditor;


})(jQuery, window, document, "undefined"); 
