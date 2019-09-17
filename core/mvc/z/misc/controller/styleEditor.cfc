<cfcomponent> 
<cfoutput>
<!--- 
// TODO: make sure disabling breakpoints works.

// TODO: important note for future - already implemented below:
// The only way to support multiple stylesheets is if we merge each breakpoint so that all of the rules in each breakpoint are output before the next breakpoint for all stylesheets.

// TODO: I should probably allow the user to get to the correct styleEditor data from front of site editing somehow

You can debug the styleEditor more quickly with this URL:
/z/misc/styleEditor/modalStyleEditor?field=styleset&debug=1
 --->
<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	</cfscript>
	<h2>Testing styleset editor</h2>
	<cfscript>
	ts={
		name:"styleset",
		selector:".section1",
		editFonts:true,
		editSizes:true,
		editSpaces:true,
		editColors:true,
		editBreakpoints:true,
		externalStylesheet:false
	};
	// application.zcore.functions.
	echo(zStylesetEditor(ts));  
	</cfscript>
</cffunction>


<cffunction name="splitFontStyles" localmode="modern" access="public">
	<cfargument name="style" type="string" required="yes">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	arrF=listToArray(arguments.style, ";");
	for(font in arrF){
		f=trim(font);
		if(f NEQ ""){
			arrPart=listToArray(f, ":");
			if(arrayLen(arrPart) EQ 2){
				arrPart[1]=trim(arrPart[1]);
				arrPart[2]=trim(replace(arrPart[2], " !important", ""));
				if(arrPart[1] EQ "font-family" or arrPart[1] EQ "font-weight" or arrPart[1] EQ "font-style"){
					if(arrPart[1] NEQ "" and arrPart[2] NEQ ""){
						arguments.struct[arrPart[1]]=arrPart[2]&" !important;";
					}
				}
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getTRBLCSS" localmode="modern" access="public">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="style" type="string" required="yes">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	arrF=listToArray(arguments.style, ",", true);
	if(arrayLen(arrF) EQ 4){
		if(arrF[1] NEQ ""){
			if(isNumeric(arrF[1])){
				arrF[1]&="px";
			}
			arguments.struct[arguments.type&"-top"]=arrF[1]&";";
		}
		if(arrF[2] NEQ ""){
			if(isNumeric(arrF[2])){
				arrF[2]&="px";
			}
			arguments.struct[arguments.type&"-right"]=arrF[2]&";";
		}
		if(arrF[3] NEQ ""){
			if(isNumeric(arrF[3])){
				arrF[3]&="px";
			}
			arguments.struct[arguments.type&"-bottom"]=arrF[3]&";";
		}
		if(arrF[4] NEQ ""){
			if(isNumeric(arrF[4])){
				arrF[4]&="px";
			}
			arguments.struct[arguments.type&"-left"]=arrF[4]&";";
		}
	}
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	variables.breakpoints=["Default", "1362", "992", "767", "479"];
	variables.themePrefix="jdt-";
	</cfscript>
</cffunction>

<cffunction name="getStylesheetData" localmode="modern" access="public">
	<cfargument name="options" type="struct" required="yes">
	<cfargument name="baseConfig" type="struct" required="yes">
	<cfargument name="config" type="struct" required="yes">
	<cfargument name="selector" type="string" required="yes">
	<cfscript>
	selector=arguments.selector;
	options=arguments.options;
	baseConfig=arguments.baseConfig;
	if(selector EQ ""){
		selector="body ";
	}
	ms={};
	b=variables.breakpoints;
	if(!options.breakpoints){
		b=["Default"];
	}
	for(n in b){
		ms[n]=[];
	}
	debug=false;
	if(form.method EQ "debugStylesheet"){
		debug=true;
	}
	c=duplicate(arguments.config);
	structdelete(c, 'css');
	// remove fields that match baseConfig
	if(structkeyexists(c, "fonts")){
		for(field in c.fonts){
			if(structkeyexists(baseConfig, "fonts") and structkeyexists(baseConfig.fonts, field) and baseConfig.fonts[field] EQ c.fonts[field]){
				structdelete(c.fonts, field);
			}
		} 
		for(i in c){
			if(i EQ "fonts"){
				continue;
			}
			if(not structkeyexists(baseConfig, i)){
				continue;
			}
			for(var field in c[i]){
				if(not structkeyexists(baseConfig[i], field)){
					continue;
				}
				for(n in b){ 
					if(structkeyexists(baseConfig[i][field], n) and structkeyexists(c[i][field], n) and baseConfig[i][field][n] EQ c[i][field][n]){
						structdelete(c[i][field], n);
					} 
				} 
				if(structcount(c[i][field]) EQ 0){
					structdelete(c[i], field);
				}
			}
		} 
	}
	// remove empty values
	for(i in c){
		fields=c[i];
		if(i EQ "fonts"){
			for(field in fields){
				if(debug){
					fields[field]="font-family:testFont;";
				}
				if(fields[field] EQ ""){
					structdelete(fields, field);
				}
			}
		}else{
			for(field in fields){ 
				for(n in b){
					if(debug){
						fields[field][n]="test";
					}
					if(structkeyexists(fields[field], n) and fields[field][n] EQ ""){
						structdelete(fields[field], n);
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
 
	for(n in b){
		ts={};
		if(structkeyexists(c.spaces.padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.padding[n], ts);
		}
		if(structkeyexists(c.spaces.margin?:{}, n)){
			getTRBLCSS("margin", c.spaces.margin[n], ts);
		}
		if(structkeyexists(c.sizes.text_size?:{}, n)){
			ts["font-size"]=c.sizes.text_size[n]&"px;";
		}
		if(structkeyexists(c.sizes.text_line_height?:{}, n)){
			ts["line-height"]=c.sizes.text_line_height[n]&";";
		}
		if(structkeyexists(c.colors.container_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.container_background_color[n]&";";
		}
		if(structkeyexists(c.colors.text_color?:{}, n)){
			ts["color"]="##"&c.colors.text_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector, css:ts});
		}
		ts={};
		if(structkeyexists(c.spaces.text_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.text_padding[n], ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&"p", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.spaces.list_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.list_padding[n], ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&"ul, "&selector&"ol", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.spaces.heading_1_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.heading_1_padding[n], ts);
		}
		if(structkeyexists(c.sizes.heading_1_size?:{}, n)){
			ts["font-size"]=c.sizes.heading_1_size[n]&"px;";
		}
		if(structkeyexists(c.sizes.heading_1_line_height?:{}, n)){
			ts["line-height"]=c.sizes.heading_1_line_height[n]&";";
		}
		if(structkeyexists(c.colors.heading_1_color?:{}, n)){
			ts["color"]="##"&c.colors.heading_1_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(n EQ "Default" and structkeyexists(c.fonts, 'heading_1_font')){ 
			splitFontStyles(c.fonts.heading_1_font, ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&"h1, "&selector&"h1 a:link, "&selector&"h1 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.spaces.heading_2_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.heading_2_padding[n], ts);
		}
		if(structkeyexists(c.sizes.heading_2_size?:{}, n)){
			ts["font-size"]=c.sizes.heading_2_size[n]&"px;";
		}
		if(structkeyexists(c.sizes.heading_2_line_height?:{}, n)){
			ts["line-height"]=c.sizes.heading_2_line_height[n]&";";
		}
		if(structkeyexists(c.colors.heading_2_color?:{}, n)){
			ts["color"]="##"&c.colors.heading_2_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(n EQ "Default" and structkeyexists(c.fonts, 'heading_2_font')){ 
			splitFontStyles(c.fonts.heading_2_font, ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&" h2, "&selector&" h2 a:link, "&selector&" h2 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.spaces.heading_3_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.heading_3_padding[n], ts);
		}
		if(structkeyexists(c.sizes.heading_3_size?:{}, n)){
			ts["font-size"]=c.sizes.heading_3_size[n]&"px;";
		}
		if(structkeyexists(c.sizes.heading_3_line_height?:{}, n)){
			ts["line-height"]=c.sizes.heading_3_line_height[n]&";";
		}
		if(structkeyexists(c.colors.heading_3_color?:{}, n)){
			ts["color"]="##"&c.colors.heading_3_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(n EQ "Default" and structkeyexists(c.fonts, 'heading_3_font')){ 
			splitFontStyles(c.fonts.heading_3_font, ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&" h3, "&selector&" h3 a:link, "&selector&" h3 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.background_color[n]&";";
		} 
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&" .z-container > *", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.link_color?:{}, n)){
			ts["color"]="##"&c.colors.link_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&" a:link, "&selector&" a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.link_hover_color?:{}, n)){
			ts["color"]="##"&c.colors.link_hover_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&" a:hover", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.spaces.button_padding?:{}, n)){
			getTRBLCSS("padding", c.spaces.button_padding[n], ts);
		}
		if(structkeyexists(c.sizes.button_text_size?:{}, n)){
			ts["font-size"]=c.sizes.button_text_size[n]&"px;";
		}
		if(structkeyexists(c.sizes.button_line_height?:{}, n)){
			ts["line-height"]=c.sizes.button_line_height[n]&";";
		}
		if(structkeyexists(c.colors.button_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.button_background_color[n]&";";
		}
		if(structkeyexists(c.colors.button_color?:{}, n)){
			ts["color"]="##"&c.colors.button_color[n]&";";
		}
		if(n EQ "Default" and structkeyexists(c.fonts, 'button_font')){
			splitFontStyles(c.fonts.button_font, ts);
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".z-button, "&selector&".z-button:link, "&selector&".z-button:visited", css:ts}); 
		} 
		ts={};
		if(structkeyexists(c.colors.button_hover_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.button_hover_background_color[n]&";";
		}
		if(structkeyexists(c.colors.button_hover_color?:{}, n)){
			ts["color"]="##"&c.colors.button_hover_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".z-button:hover", css:ts}); 
		} 
		ts={};
		if(structkeyexists(c.colors.accent_button_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.accent_button_background_color[n]&";";
		}
		if(structkeyexists(c.colors.accent_button_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_button_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent .z-button, "&selector&".#variables.themePrefix#accent .z-button:link, "&selector&".#variables.themePrefix#accent .z-button:visited, .#variables.themePrefix#accent.z-button, "&selector&".#variables.themePrefix#accent.z-button:link, "&selector&".#variables.themePrefix#accent.z-button:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_container_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.accent_container_background_color[n]&";";
		}
		if(structkeyexists(c.colors.accent_text_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_text_color[n]&";";
		} 
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.accent_background_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent .z-container > *", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_link_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_link_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&"a.#variables.themePrefix#accent, "&selector&"a.#variables.themePrefix#accent:link, "&selector&"a.#variables.themePrefix#accent:visited, "&selector&".#variables.themePrefix#accent a:link, "&selector&".#variables.themePrefix#accent a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_heading_1_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_heading_1_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent h1, "&selector&".#variables.themePrefix#accent h1 a:link, "&selector&".#variables.themePrefix#accent h1 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_heading_2_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_heading_2_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent h2, "&selector&".#variables.themePrefix#accent h2 a:link, "&selector&".#variables.themePrefix#accent h2 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_heading_3_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_heading_3_color[n]&";";
			ts["text-decoration"]="none;";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent h3, "&selector&".#variables.themePrefix#accent h3 a:link, "&selector&".#variables.themePrefix#accent h3 a:visited", css:ts}); 
		}
		ts={};
		if(structkeyexists(c.colors.accent_link_hover_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_link_hover_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&"a.#variables.themePrefix#accent:hover, "&selector&".#variables.themePrefix#accent a:hover", css:ts}); 
		} 
		ts={};
		if(structkeyexists(c.colors.accent_button_hover_background_color?:{}, n)){
			ts["background-color"]="##"&c.colors.accent_button_hover_background_color[n]&";";
		}
		if(structkeyexists(c.colors.accent_button_hover_color?:{}, n)){
			ts["color"]="##"&c.colors.accent_button_hover_color[n]&";";
		}
		if(structcount(ts)){
			arrayAppend(ms[n], {selector:selector&".#variables.themePrefix#accent .z-button:hover, .#variables.themePrefix#accent.z-button:hover", css:ts}); 
		} 
	}
	if(structkeyexists(c.fonts, 'text_font')){
		ts={};
		splitFontStyles(c.fonts.text_font?:{}, ts);
		arrayAppend(ms["Default"], {selector:selector&", "&selector&" a:link, "&selector&" a:visited", css:ts}); 
	} 
	return ms;
	</cfscript>
</cffunction>

<!--- 
<cffunction name="deleteDefaultConfig" localmode="modern" access="public">
	<cfargument name="config" type="struct" required="yes">
	<cfargument name="defaultConfig" type="struct" required="yes">
	<cfscript>
	config=arguments.config;
	defaultConfig=arguments.defaultConfig;
	for(field in config.fonts){
		if(defaultConfig.fonts[field] EQ config.fonts[field]){
			structdelete(config.fonts, field);
		}
	} 
	for(key in config){
		if(key EQ "fonts"){
			continue;
		}
		for(field in config[key]){
			for(bp in variables.breakpoints){ 
				if(defaultConfig[key][field][bp] EQ config[key][field][bp]){
					structdelete(config[key][field], bp);
				} 
			}
			if(structcount(config[key][field]) EQ 0){
				structdelete(config[key], field);
			}
		}
	} 
	</cfscript>
</cffunction> --->

<cffunction name="mergeConfig" localmode="modern" access="public">
	<cfargument name="defaultConfig" type="struct" required="yes">
	<cfargument name="arrConfig" type="array" required="yes">
	<cfscript>
	defaultConfig=arguments.defaultConfig;
	arrConfig=arguments.arrConfig;
	/*for(i=1;i<=arraylen(arrConfig);i++){
		deleteDefaultConfig(arrConfig[i], defaultConfig);
	}*/
	baseConfig=duplicate(arrConfig[1]); 
	for(i=2;i<=arraylen(arrConfig);i++){
		config=arrConfig[i];
		// copy everything into baseConfig
		if(structkeyexists(config, 'fonts')){
			if(not structkeyexists(baseConfig, "fonts")){
				baseConfig.fonts={};
			}
			for(field in config.fonts){
				if(defaultConfig.fonts[field] NEQ config.fonts[field]){
					baseConfig.fonts[field]=config.fonts[field];
				}
			}
		}
		for(key in config){
			if(key EQ "fonts"){
				continue;
			}
			if(not structkeyexists(baseConfig, key)){
				baseConfig[key]={};
			}
			for(field in config[key]){
				if(not structkeyexists(baseConfig[key], field)){
					baseConfig[key][field]={};
				}
				for(bp in config[key][field]){
					if(defaultConfig[key][field][bp] NEQ config[key][field][bp]){
						baseConfig[key][field][bp]=config[key][field][bp];
					}
				}
			}
		}
	}
	for(field in baseConfig.fonts){
		if(defaultConfig.fonts[field] EQ baseConfig.fonts[field]){
			structdelete(baseConfig.fonts, field);
		}
	} 
	for(key in config){
		if(key EQ "fonts"){
			continue;
		}
		for(field in baseConfig[key]){
			for(bp in variables.breakpoints){ 
				if(structkeyexists(baseConfig[key][field], bp) and defaultConfig[key][field][bp] EQ baseConfig[key][field][bp]){
					structdelete(baseConfig[key][field], bp);
				} 
			}
			if(structcount(baseConfig[key][field]) EQ 0){
				structdelete(baseConfig[key], field);
			}
		}
	}
	return baseConfig;
	</cfscript>
</cffunction>


<cffunction name="getStylesheet" localmode="modern" access="public">
	<cfargument name="cssData" type="struct" required="yes">
	<cfscript>
	ms=arguments.cssData;

	css={};
	for(b in variables.breakpoints){
		tab="";
		if(not structkeyexists(ms, b)){
			continue;
		}
		if(arraylen(ms[b])){
			arrTemp=[];
			if(b NEQ "Default"){
				//arrayAppend(arrTemp, '@media (max-width:#b#px){'&chr(10));
				tab=chr(9);
			}
			for(ds in ms[b]){
				arrayAppend(arrTemp, tab&ds.selector&"{"&chr(10));
				for(key in ds.css){
					value=ds.css[key];
					arrayAppend(arrTemp, tab&chr(9)&key&":"&value&chr(10));
				}
				arrayAppend(arrTemp, tab&"}"&chr(10));
			}
			if(b NEQ "Default"){
				//arrayAppend(arrCSS, '} /* media-end #b# */'&chr(10));
			}
			css[b]=arrayToList(arrTemp, chr(10));
		}
	}
	return css;
	</cfscript>
</cffunction>

<cffunction name="debugStylesheet" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init(); 
	config=getDefaultConfig();
	selector=".section1 ";
	options={
		"sizes":1,
		"fonts":1,
		"spaces":1,
		"colors":1,
		"breakpoints":1
	};
	ms=getStylesheetData(options, {}, config, selector);
	writedump(ms);
	css=getStylesheet(ms); 
	writedump(css);
	//echo('<pre>'&css&'</pre>'); 
	abort;
	</cfscript>
</cffunction>

<cffunction name="customDebugStylesheet" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init(); 
	config=getDefaultConfig();
	selector=".section1 ";
	config.spaces.text_padding.Default="15,5,10,2";
	config.spaces.text_padding.Default="15,,,";
	options={
		"sizes":1,
		"fonts":1,
		"spaces":1,
		"colors":1,
		"breakpoints":1
	};
	ms=getStylesheetData(options, {}, config, selector);
	writedump(ms);
	css=getStylesheet(ms); 
	writedump(css);
	//echo('<pre>'&css&'</pre>'); 
	abort;
	</cfscript>
</cffunction>
 
<!--- <cffunction name="getMergedStylesheet" localmode="modern" access="public">
	<cfargument name="selector" type="string" required="yes">
	<cfargument name="arrConfig" type="array" required="yes">
	<cfscript>
	init();

	defaultConfig=getDefaultConfig();
	
	//writedump(arguments);abort;
	mergedConfig=mergeConfig(defaultConfig, arguments.arrConfig); 

	ms=getStylesheetData(mergedConfig, arguments.selector);

	return getStylesheet(ms);
	</cfscript>
</cffunction> --->

<cffunction name="getDefaultConfig" localmode="modern" access="public">
	<cfscript>
	ts={
		colors:{
			accent_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_button_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_button_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_button_hover_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_button_hover_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_container_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_link_hover_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_link_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_text_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_heading_1_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_heading_2_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			accent_heading_3_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_hover_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_hover_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			container_background_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			link_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			link_hover_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_1_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_2_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_3_color:{"479": "", "767": "", "992": "", "1362": "", "Default": ""}
		},
		fonts:{
			heading_1_font:"",
			heading_2_font:"",
			heading_3_font:"",
			text_font:"",
			button_font:""
		},
		spaces:{
			button_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_1_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_2_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_3_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			margin:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			list_padding:{"479": "", "767": "", "992": "", "1362": "", "Default": ""}
		},
		sizes:{
			button_text_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			button_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_1_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_2_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_3_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_1_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_2_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			heading_3_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_line_height:{"479": "", "767": "", "992": "", "1362": "", "Default": ""},
			text_size:{"479": "", "767": "", "992": "", "1362": "", "Default": ""}
		}
	}
	return ts;
	</cfscript>
</cffunction>
<!--- 
ts={
	name:"styleset",
	selector:"body", // CSS selector to prefix to all generated styles.
	editFonts:true,
	editSizes:true,
	editSpaces:true,
	editColors:true,
	editBreakpoints:true,
	externalStylesheet:false
};
echo(application.zcore.functions.zStylesetEditor(ts));  
 --->
<cffunction name="zStylesetEditor" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(not structkeyexists(ss, 'value')){
		ss.value=application.zcore.functions.zso(form, ss.name);
	}
	ts={
		selector:"body",
		editFonts:true,
		editSizes:true,
		editSpaces:true,
		editColors:true,
		editBreakpoints:true,
		externalStylesheet:false
	}
	structappend(ss, ts, false);
	ss.selector=trim(ss.selector)&" ";
	if(ss.editFonts){
		ss.editFonts=1;
	}else{
		ss.editFonts=0;
	}
	if(ss.editSizes){
		ss.editSizes=1;
	}else{
		ss.editSizes=0;
	}
	if(ss.editSpaces){
		ss.editSpaces=1;
	}else{
		ss.editSpaces=0;
	}
	if(ss.editColors){
		ss.editColors=1;
	}else{
		ss.editColors=0;
	}
	if(ss.editBreakpoints){
		ss.editBreakpoints=1;
	}else{
		ss.editBreakpoints=0;
	}
	if(ss.externalStylesheet){
		ss.externalStylesheet=1;
	}else{
		ss.externalStylesheet=0;
	}
	defaultConfig=getDefaultConfig();
	baseConfig=duplicate(defaultConfig);
	baseConfig.colors.text_color.Default="336699";
	baseConfig.colors.text_color.1362="993366";
	baseConfig.spaces.text_padding.Default=",10,0,";
	baseConfig.spaces.text_padding.1362="5,10,15,20";

	json=deserializeJson(ss.value);
	if(not isStruct(json)){
		json={};
	}
	json.spaces.text_padding.Default="10,15,,";
	json.spaces.list_padding.Default=",,20,";
	ss.value=serializeJson(json);
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */ 
	if(typeof zStylestyleDefaultConfig == "undefined"){
		var zStylestyleDefaultConfig={};
	} 
	zStylestyleDefaultConfig["#ss.name#"]=#serializeJson(defaultConfig)#;

	if(typeof zStylestyleBaseConfig == "undefined"){
		var zStylestyleBaseConfig={};
	} 
	zStylestyleBaseConfig["#ss.name#"]=#serializeJson(baseConfig)#;
	zArrDeferredFunctions.push(function(){
		$(".zStyleSetEditorButton").on("click", function(e){
			e.preventDefault();

			var field=$(this).attr("data-style-editor-field"); 
			zShowModalStandard('/z/misc/styleEditor/modalStyleEditor?field='+encodeURIComponent(field), 4000,4000, 10);
		});
	});
	/* ]]> */
	</script>
	<cfsavecontent variable="output"> 
		<h3><input type="hidden" name="#ss.name#" id="#ss.name#" value="#htmleditformat(ss.value)#"
			data-style-editor-selector="#ss.selector#" 
			data-style-editor-fonts="#ss.editFonts#" 
			data-style-editor-sizes="#ss.editSizes#" 
			data-style-editor-spaces="#ss.editSpaces#" 
			data-style-editor-colors="#ss.editColors#"
			data-style-editor-breakpoints="#ss.editBreakpoints#"
			data-style-editor-external-stylesheet="#ss.externalStylesheet#"
		 />
		 <a href="##" data-style-editor-field="#ss.name#" class="zStyleSetEditorButton z-manager-search-button">Open Style Editor</a></h3> 
		 <script type="text/javascript">
		 zArrDeferredFunctions.push(function(){
		 	$(".zStyleSetEditorButton").trigger("click");
		 });
		</script>

	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
	
</cffunction>


<cffunction name="modalStyleEditor" localmode="modern" access="remote">
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/zStyleEditor.js");
	application.zcore.functions.zSetModalWindow(false);
	application.zcore.functions.zIncludeJsColor();
	form.debug=application.zcore.functions.zso(form, 'debug', true, 0);
	form.field=application.zcore.functions.zso(form, 'field');
   
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	application.zcore.functions.zRequireJquery();
	if(form.debug EQ 1){
		defaultConfig=getDefaultConfig();
		debugConfig=duplicate(defaultConfig);
		debugConfig.sizes.text_size.Default="20";
		debugConfig.sizes.text_padding.1362="1px,5px,10px,15px";
		debugConfig.colors.text_color["Default"]="336699";
		debugConfig.fonts.text_font="font-weight:normal;";
	}
	</cfscript>
	<cfsavecontent variable="scriptOutput">   
	<cfif form.debug EQ 1>
		<input type="hidden" name="#form.field#" id="#form.field#" value="#htmleditformat(serializeJson(debugConfig))#"
			data-style-editor-selector=".section1 " 
			data-style-editor-fonts="1" 
			data-style-editor-sizes="1" 
			data-style-editor-colors="1"
			data-style-editor-spaces="1" 
			data-style-editor-breakpoints="1"
			data-style-editor-external-stylesheet="0"
		 />
	</cfif>
	<script type="text/javascript">
	/* <![CDATA[ */
	zArrDeferredFunctions.push(function(){ 
		<cfif form.debug EQ 1>
		if(typeof window.parent.zStylestyleDefaultConfig == "undefined"){
			window.parent.zStylestyleDefaultConfig={};
		} 
		window.parent.zStylestyleDefaultConfig["#form.field#"]=#serializeJson(defaultConfig)#;
		if(typeof window.parent.zStylestyleBaseConfig == "undefined"){
			window.parent.zStylestyleBaseConfig={};
		} 
		window.parent.zStylestyleBaseConfig["#form.field#"]=#serializeJson(defaultConfig)#;
		</cfif>
		var field=window.parent.document.getElementById("#form.field#");
		if(field.value != ""){
			config=JSON.parse(field.value);
		}else{
			config='';
		}
		var options={
			formId:"styleEditorForm",
			container:".styleEditorContainer",
			field:"#jsstringformat(form.field)#",
			baseConfig:window.parent.zStylestyleBaseConfig["#form.field#"],
			defaultConfig:window.parent.zStylestyleDefaultConfig["#form.field#"],
			config:config,
			selector:field.getAttribute("data-style-editor-selector"),
			fonts:parseInt(field.getAttribute("data-style-editor-fonts")),
			sizes:parseInt(field.getAttribute("data-style-editor-sizes")),
			spaces:parseInt(field.getAttribute("data-style-editor-spaces")),
			colors:parseInt(field.getAttribute("data-style-editor-colors")),
			breakpoints:parseInt(field.getAttribute("data-style-editor-breakpoints")),
			externalStylesheet:parseInt(field.getAttribute("data-style-editor-external-stylesheet"))
	 	};
	 	var myEditor=new zStyleEditor(options);

	 	$(".copyCSSLink").on("click", function(e){
	 		e.preventDefault();

			$("##stylePreviewTextArea").show();
			$("##stylePreviewTextArea").select();
			try {
				var backupButtonText=this.innerHTML;
				var successful = document.execCommand('copy');
				$("##stylePreviewTextArea").hide();
				var msg = successful ? 'successful' : 'unsuccessful';
				this.innerHTML="<strong>Copied</strong>";
				var self=this;
				setTimeout(function(){
					self.innerHTML=backupButtonText;
				}, 2000);
			} catch (err) {
				alert('Copy to clipboard is disabled by your browser.');
			}
	 	});
	});
	/* ]]> */
	</script> 
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("scripts", local.scriptOutput); 
	</cfscript> 
	<style type="text/css">
	.zblanktemplatedivcontainer{padding:0px !important;}

	.interfaceContainer{display:none; cursor:pointer;  position:relative;  border-right:1px solid ##CCC;  width:701px; padding-left:5px; padding-right:10px; padding-bottom:5px; float:left; padding-top:30px;}
	/*.styleEditorContainer{ width:370px;}
	.styleEditorTableContainer{overflow-x:scroll; width:224px; overflow-y: visible; margin-left:140px;}
	.styleEditorContainer .table-list .styleEditorFixedColumn{
		position: absolute;
		width: 140px !important;
		left: 0; 
			padding:3px !important; padding-left:5px !important;
		background-color:##FFF !important; 
		top: auto; 
		border-top:1px solid ##CCC;
		border-bottom:none;
	}*/ 
	.styleEditorContainer .table-list .styleEditorFixedColumn{
		width: 145px !important;
		font-weight:normal;
	} 
	.styleEditorContainer .table-list td, .styleEditorContainer .table-list th{
		padding:3px !important;
		border-top:1px solid ##CCC;
		border-bottom:none;
	}
	.selectedBreakpointDiv{display:none; z-index:1000; background-color:##FFF; padding-left:5px; padding-top:5px; position:fixed; top:0px; left:0px; font-size:14px; }
	.stylePreviewHTML{}

	.previewContainer{ display:none; left: 0px; position: fixed; width:1380px;  padding-bottom:5px; float:left;z-index:1001; }
	.previewContainer .z-container{ max-width:90%;}
	.previewContainerFull{ left:0px !important; top:0px !important;  position:relative !important; width:100% !important;}

	.previewContainerFull .z-container{ max-width:initial !important;}
	.previewContainerFull .stylePreviewHTML{ width:100% !important;  border:none !important; padding-bottom:0px; margin-bottom:20px; position:relative; top:0px; transform:none;}
	.previewContainerFull .htmlPreviewHeading{ display:none;}
	.breakpointLink{display:inline-block; transition: all ease 0.2s; padding:3px; padding-left:8px; border-radius:5px;  padding-right:8px; background-color:##CCC !important; color:##000 !important; }
	.breakpointLink:hover{background-color:##FFF !important; color:##000 !important;}
	.breakpointSelected{ background-color:##369 !important; color:##FFF !important;  }
	</style>

	<div class="selectedBreakpointDiv z-pr-10 z-radius-5" style="">
		<div class=" z-float-left">
			<a href="##" onclick="document;" class="z-manager-search-button hideInterfaceLink">Hide Interface</a>  
		</div>
			<div class="htmlPreviewHeading z-float-left">
				<!--- <h2 style="font-size:21px; padding-bottom:0px; display:inline-block; color:##369; font-weight:normal;">HTML Preview</h2> &nbsp;  --->
				<span class=" stylePreviewScale"></span>
			</div>
	</div>
	<div class="z-float"> 
		<div class="interfaceContainer z-pt-20" style="">
			<div class="z-float">
				<h2 style="font-size:21px; padding-bottom:0px; display:inline-block; color:##369; font-weight:normal;">Style Editor</h2> &nbsp;&nbsp;
				<a href="##" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Close</a>
				<a href="##" onclick="document;" class="z-manager-search-button copyCSSLink">Copy CSS</a>
			</div>
			<div class="z-float">
				<cfif request.zos.isdeveloper>
				<input type="checkbox" name="serverRenderCheckbox" id="serverRenderCheckbox" class="serverRenderCheckbox" value="1"> <label for="serverRenderCheckbox" title="Enable this to debug server-side CSS generation bugs">Server Render</label><br>
				</cfif>
				<span>Pink border indicates a changed value. Press Esc in a field to revert the change to the inherited value.</span>
			</div>
			<form class="zFormCheckDirty" action="" name="styleEditorForm" id="styleEditorForm" method="get"> 
				<div class="styleEditorContainer"></div> 
			</form>
			
		</div> 
		<div class="previewContainer"  style="">

			<div class="stylePreviewHTML z-float-left" <!--- style="display:none;" --->>
				<div class="styleIframeContainer"></div>
				<cfsavecontent variable="iframeHTML">
					<link rel="stylesheet" type="text/css" href="/z/stylesheets/zOS.css" />
					<link rel="stylesheet" type="text/css" href="/z/stylesheets/css-framework.css" />
					<link rel="stylesheet" type="text/css" href="/zupload/layout-global.css" />
					<style type="text/css" id="stylePreviewStyle"></style>
					<div class="section1 z-float"> 
						<div class="z-float">
							<div class="z-container">
								<div class="z-column">
									<h1>Heading 1</h1>
									<p>Testing a paragraph that goes more then the length of one line. Testing a paragraph that goes more then the length of one line. Testing a paragraph that goes more then the length of one line. </p>
									<h2>Heading 2 with <a href="##">link</a></h2>
									<p>Single Line<br>Break</p>
									<ul>
										<li>Bullet 1</li>
										<li>Bullet 2</li> 
									</ul>
									<h3>Heading 3</h3>
									<p><a href="##" class="z-button">Button</a></p>
								</div> 
							</div>
						</div>
						<div class="z-float jdt-accent">
							<div class="z-container">
								<div class="z-column">
									<h1>Accent <a href="##">Heading 1</a></h1>
									<p>This is an accent section.  <a href="##">Link Text</a></p>  
									<h2>Accent <a href="##">Heading 2</a></h2>
									<p><a href="##" class="z-button">Button</a></p>
									<h3>Accent <a href="##">Heading 3</a></h3>
								</div>
							</div>
						</div>
					</div> 
				</cfsavecontent>
			</div>
		</div> 
	</div>
	<div  style="width:100%; float:left;">
		<!--- <h2 style=" color:##369; font-weight:normal;">CSS Preview</h2> --->
		<div class="stylePreviewCSS"></div>
	</div>
	<script type="text/javascript">
	var iframeDocumentContents="#jsStringFormat(replace(replace(iframeHTML, chr(13), "", "all"), chr(10), " ", "all"))#";
	</script>
</cffunction>

<cffunction name="modalStylePreview" localmode="modern" access="remote">
	<cfscript>
	init();
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.template.setPlainTemplate(); 

	config=application.zcore.functions.zso(form, 'config');
	baseConfig=application.zcore.functions.zso(form, 'baseConfig');
	selector=".section1 ";
	config=deserializeJSON(config);
	if(not isStruct(config)){
		config={};
	}
	baseConfig=deserializeJSON(baseConfig);
	if(not isStruct(baseConfig)){
		baseConfig={};
	}



	//defaultConfig=getDefaultConfig();
	

	options={
		"sizes":application.zcore.functions.zso(form, 'sizes', true, 1),
		"fonts":application.zcore.functions.zso(form, 'fonts', true, 1),
		"spaces":application.zcore.functions.zso(form, 'spaces', true, 1),
		"colors":application.zcore.functions.zso(form, 'colors', true, 1),
		"breakpoints":application.zcore.functions.zso(form, 'breakpoints', true, 1)
	};

	baseSD=getStylesheetData(options, {}, baseConfig, selector);
	baseCSS=getStylesheet(baseSD);

	sd=getStylesheetData(options, baseConfig, config, selector);
	css=getStylesheet(sd);

	//baseCSS=getPreviewStylesheet({}, baseConfig, selector);
	//css=getPreviewStylesheet(baseConfig, config, selector);
	rs={success:true, css:css, baseCSS:baseCSS}; 
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>