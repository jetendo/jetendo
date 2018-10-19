<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="getDefaultBreakpointConfig" localmode="modern" access="public">
	<cfscript>
	ts={
		headingScale:1.5,
		textScale:1.5,
		indentScale:1,
		columnPaddingTopPercent:1,
		columnPaddingSidePercent:1,
		columnPaddingBottomPercent:1,
		boxPaddingTopPercent:1,
		boxPaddingSidePercent:1,
		boxPaddingBottomPercent:1,
		boxMarginTopPercent:1,
		boxMarginSidePercent:1,
		boxMarginBottomPercent:1,
		columnGapSidePercent:2,
		columnGapBottomPercent:2,
		minimumPadding:10,
		headingMinimumFontSize:12,
		textMinimumFontSize:12,
		headingLineHeightScale:1,
		textLineHeightScale:1
	}
	return ts;
	</cfscript>
</cffunction>
<cffunction name="getBreakpointConfig" localmode="modern" access="public">
	<cfscript>
	defaultBreakPoint=getDefaultBreakpointConfig();
	breakStruct={
		arrBreak=["Default","1800","1550","1362","992","767","479"],
		data:{
			"Default":{
				headingScale:1,
				textScale:1,
				minimumPadding:15,
				textMinimumFontSize:14,
				headingMinimumFontSize:14,
				indentScale:1.2,
				columnPaddingTopPercent:1,
				columnPaddingSidePercent:1,
				columnPaddingBottomPercent:1,
			}, 
			"1800":{
				indentScale:1,
			},
			"1550":{
				indentScale:1,
			}, 
			"1362":{
				indentScale:1,
			},
			"992":{
				headingScale:0.9,
				indentScale:1,
				textMinimumFontSize:16,
				headingMinimumFontSize:16,
				columnGapSidePercent:7,
				columnGapBottomPercent:4,
				columnPaddingTopPercent:2,
				columnPaddingSidePercent:2,
				columnPaddingBottomPercent:2
			},
			"767":{
				headingScale:0.8,
				indentScale:1, 
				columnGapSidePercent:10,
				columnGapBottomPercent:6,
				columnPaddingTopPercent:3,
				columnPaddingSidePercent:3,
				columnPaddingBottomPercent:3,
			},
			"479":{
				headingScale:0.7,
				indentScale:1,
				textMinimumFontSize:16,
				headingMinimumFontSize:16,
				columnGapSidePercent:15,
				columnGapBottomPercent:10,
				columnPaddingTopPercent:4,
				columnPaddingSidePercent:4,
				columnPaddingBottomPercent:4,
			}
		},
		minimum_column_width:200,
		css:{}
	}
	lastBreak={};
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		structappend(lastBreak, breakStruct.data[breakpoint], true);
		structappend(breakStruct.data[breakpoint], lastBreak, false);
		structappend(breakStruct.data[breakpoint], defaultBreakPoint, false);
		breakStruct.css[breakpoint]=[];
	}
	return breakStruct;
	</cfscript>
</cffunction>
 
<cffunction name="saveLayoutInstanceSettings" localmode="modern" access="remote" roles="member">
	<cfscript>

	form.layout_setting_instance_id=application.zcore.functions.zso(form, 'layout_setting_instance_id', true, 0);
	form.layout_setting_instance_name=application.zcore.functions.zso(form, 'layout_setting_instance_name');


	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_setting_instance", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_setting_instance_id=#db.param(form.layout_setting_instance_id)# and 
	layout_setting_instance_deleted =#db.param(0)#";
	qData=db.execute("qData");
	breakStruct=getBreakpointConfig();

	breakStructNew={
		arrBreak:[],
		data:{},
		css:{},
		minimum_column_width:application.zcore.functions.zso(form, 'minimum_column_width', true, 150)

	}; 
	breakStruct.minimum_column_width=breakStructNew.minimum_column_width;
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
		}
		if(structkeyexists(form, 'setToDefault')){
			dataStruct["enabled"]=1;
		}else{
			dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
		}
		if(dataStruct["enabled"] EQ 1){
			arrayAppend(breakstructNew.arrBreak, breakStruct.arrBreak[i]);
			breakStructNew.data[breakpoint]=breakStruct.data[breakpoint];
			breakStructNew.css[breakpoint]=breakStruct.css[breakpoint];
		}
	} 
	ts={
		table:"layout_setting_instance",
		datasource:request.zos.zcoreDatasource,
		struct:{
			layout_setting_instance_json_data:serializeJson(breakStruct),
			layout_setting_instance_updated_datetime:request.zos.mysqlnow,
			layout_setting_instance_deleted:0,
			layout_setting_instance_name:form.layout_setting_instance_name
		}
	};
	if(qData.recordcount EQ 0){
		form.layout_setting_instance_id=application.zcore.functions.zInsert(ts);
		if(form.layout_setting_instance_id EQ false){
			echo('<h2>Validation Error: The Instance Name must be unique per site.</h2>
			<p>Please go back and try a different instance name.</p>');
			return;
		}
	}else{
		ts.struct.layout_setting_instance_id=qData.layout_setting_instance_id; 
		if(application.zcore.functions.zUpdate(ts) EQ false){
			echo('<h2>Failed to save settings.</h2>
			<p>Please go back and try again.</p>');
			return;
		}
	}
	breakStructNew.layout_setting_instance_id=form.layout_setting_instance_id;
	generateGlobalBreakpointCSS(breakStructNew);

	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/layout-global/instanceList?zsid=#request.zsid#");
	</cfscript>
</cffunction>  

<cffunction name="saveLayoutSettings" localmode="modern" access="remote" roles="member">
	<cfscript> 
	if(form.method NEQ "autoPublish"){
		application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)#";
	qGlobal=db.execute("qGlobal");
	breakStruct=getBreakpointConfig();

	breakStructNew={
		arrBreak:[],
		data:{},
		css:{},
		minimum_column_width:application.zcore.functions.zso(form, 'minimum_column_width', true, 150)
	}; 
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
		}
		if(structkeyexists(form, 'setToDefault') and breakpoint NEQ 1800 and breakpoint NEQ 1550){
			dataStruct["enabled"]=1;
		}else{
			dataStruct["enabled"]=application.zcore.functions.zso(form, "enabled_"&breakpoint, true, 0); 
		}
		if(dataStruct["enabled"] EQ 1){
			arrayAppend(breakstructNew.arrBreak, breakStruct.arrBreak[i]);
			breakStructNew.data[breakpoint]=breakStruct.data[breakpoint];
			breakStructNew.css[breakpoint]=breakStruct.css[breakpoint];
		}
	} 
	breakStruct.minimum_column_width=breakStructNew.minimum_column_width;
	ts={
		table:"layout_global",
		datasource:request.zos.zcoreDatasource,
		struct:{
			layout_global_json_data:serializeJson(breakStruct),
			layout_global_updated_datetime:request.zos.mysqlnow,
			layout_global_deleted:0
		}
	};
	if(qGlobal.recordcount EQ 0){
		form.layout_global_id=application.zcore.functions.zInsert(ts);
		if(form.layout_global_id EQ false){
			if(form.method EQ "autoPublish"){
				return false;
			}else{
				application.zcore.status.setStatus(request.zsid, "Failed to save settings");
				application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
			}
		}
	}else{
		ts.struct.layout_global_id=qGlobal.layout_global_id; 
		if(application.zcore.functions.zUpdate(ts) EQ false){
			if(form.method EQ "autoPublish"){
				return false;
			}else{
				application.zcore.status.setStatus(request.zsid, "Failed to save settings");
				application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
			}
		}
	}
	breakStructNew.layout_setting_instance_id=0;
	generateGlobalBreakpointCSS(breakStructNew);

	if(form.method EQ "autoPublish"){
		return true;
	}else{
		application.zcore.status.setStatus(request.zsid, "Saved");
		application.zcore.functions.zRedirect("/z/admin/layout-global/index?zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>


<cffunction name="updateGlobalBreakpointCSS" localmode="modern" access="public">
	<cfscript>
	// TODO not complete
	db=request.zos.queryObject;
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)#";
	qGlobal=db.execute("qGlobal");
	breakStruct=getBreakpointConfig();
	if(qGlobal.recordcount){
		breakStructNew=deserializeJson(qGlobal.layout_global_json_data);
		form.minimum_column_width=application.zcore.functions.zso(breakStructNew, 'minimum_column_width', true, 150);
		for(i=1;i<=arraylen(breakStructNew.arrBreak);i++){
			breakpoint=breakStructNew.arrBreak[i]; 
			dataStruct=breakStructNew.data[breakpoint];
			for(n in dataStruct){
				id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
				form[id]=dataStruct[n];
			}
		} 
	}else{
		form.setToDefault=1;
		breakStructNew={};

	}

	defaultBreakStructNew={
		arrBreak:[],
		data:{},
		css:{},
		minimum_column_width:application.zcore.functions.zso(form, 'minimum_column_width', true, 150)
	}; 

	structappend(breakStructNew, defaultBreakStructNew, false);
	for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
		breakpoint=breakStruct.arrBreak[i]; 
		dataStruct=breakStruct.data[breakpoint];
		for(n in dataStruct){
			id=application.zcore.functions.zescape(n, "_")&"_"&breakpoint;
			if(structkeyexists(form, id)){
				dataStruct[n]=form[id];
			}
		}
		if(structkeyexists(form, 'setToDefault') and breakpoint NEQ 1800 and breakpoint NEQ 1550){ 
			arrayAppend(breakstructNew.arrBreak, breakStruct.arrBreak[i]);
			breakStructNew.data[breakpoint]=breakStruct.data[breakpoint];
			breakStructNew.css[breakpoint]=breakStruct.css[breakpoint];
		}
	}   
	// TODO: publish all instance layouts too
	breakStructNew.layout_setting_instance_id=0;
	generateGlobalBreakpointCSS(breakStructNew);
	</cfscript>
</cffunction>

<cffunction name="generateGlobalBreakpointCSS" localmode="modern" access="public">
	<cfargument name="breakpointConfig" type="struct" required="yes">
	<cfscript> 
	breakStruct=arguments.breakpointConfig;
	startFontSize=12; 
	uniqueStruct={};

	frameworkEnabled=false;
	if(structkeyexists(request.zos.globals, 'enableCSSFramework') and request.zos.globals.enableCSSFramework EQ 1){
		frameworkEnabled=true;
	} 

	for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
		breakpoint=breakStruct.arrBreak[n]; 
		dataStruct=breakStruct.data[breakpoint];
		//uniqueStruct={};
		arrCSS=breakStruct.css[breakpoint];
		tempScaleText=max(round(16*dataStruct.textScale), dataStruct.textMinimumFontSize); 

		if(frameworkEnabled){
			if(breakpoint EQ "default"){
				arrayAppend(arrCSS, 'body{ margin:0px; line-height:1.5;  }'&chr(10)&
				'form{ margin:0px; padding:0px;}'&chr(10)&
				'img{border-style:none;}'&chr(10)&
				'*, img{ -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box; }'&chr(10)&
				'header, nav, section, aside, article, footer, .z-section, .z-row{ width:100%; float:left; min-height:1px; }'&chr(10));
			}

			v='body { line-height:#numberformat(dataStruct.textLineHeightScale*1.5, '_._')#; } ';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			v='p{margin:0px; padding:0px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleText*0.45))#px;}';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			v='ul,ol,blockquote{ margin:0px; padding:0px; padding-left:#numberformat(dataStruct.indentScale*4, '_.___')#%; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleText*0.45))#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			v='h1,h2,h3,h4,h5,h6{ line-height:#numberformat(dataStruct.headingLineHeightScale*1.5, '_._')#; margin:0px; padding:0px; }';
			//v='.z-container h1,.z-container h2,.z-container h3,.z-container h4,.z-container h5,.z-container h6{ line-height:#numberformat(dataStruct.headingLineHeightScale*1.5, '_._')#; margin:0px; padding:0px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
		}else{
			if(breakpoint EQ "default"){
				arrayAppend(arrCSS, 'section, z-container, header, section *, z-container *, header *{ line-height:1.5; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box; }'&chr(10));
			}
		}
		if(breakpoint EQ "992"){
			// margin / padding / text / heading over classes for mobile


			v='textarea, select, button, input{font-size:#max(16,tempScaleText)#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.5, '_._')#; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			v='.z-container textarea, .z-container select, .z-container button, .z-container input{ font-size:#max(16,tempScaleText)#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.5, '_._')#; }';
		}else{
			v='.z-container textarea, .z-container select, .z-container button, .z-container input{ font-size:#tempScaleText#px; line-height:#numberformat(dataStruct.headingLineHeightScale*1.5, '_._')#; }';
		}
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		v='.z-center-children > div, .z-center-children > a{text-align:left;vertical-align:top; font-size:#max(dataStruct.textMinimumFontSize, round(16*dataStruct.textScale))#px;}';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		}
		v='.z-center-children > div, .z-center-children > a{ font-size:#max(dataStruct.textMinimumFontSize, round(dataStruct.textScale*16))#px; }';
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		if(n EQ arrayLen(breakStruct.arrBreak)){
	 		v='.z-column, .z-1of1{ float:left; min-height:1px; width:#numberformat(100-dataStruct.columnGapSidePercent, '_.___')#%; margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }';
		}else{
	 		v='.z-column, .z-1of1{ float:left; min-height:1px; width:#numberformat(100-dataStruct.columnGapSidePercent, '_.___')#%; margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%; padding-left:#dataStruct.boxPaddingSidePercent#%; padding-right:#dataStruct.boxPaddingSidePercent#%; padding-top:#dataStruct.boxPaddingTopPercent#%; padding-bottom:#dataStruct.boxPaddingBottomPercent#%; }';
	 	}
		if(not structkeyexists(uniqueStruct, v)){
			uniqueStruct[v]=true;
			arrayAppend(arrCSS, v);
		} 
		limit=2; 

		arrOffsetCSS=[];
		for(i2=2;i2<=16;i2++){
			if(limit GT 7 and limit NEQ 12 and limit NEQ 16){
				limit++;
				continue;
			}
			percent=100/limit;
			currentLimit=limit;
			currentIndex=i2;
			isSingleColumn=false;
			nextBreakpoint=breakpoint;
			if(n+1 <= arraylen(breakStruct.arrBreak)){
				nextBreakpoint=breakStruct.arrBreak[n+1];
			}
			if(breakpoint EQ "default"){
				columnWidth=1280*(percent/100);
			}else if(nextBreakpoint EQ "default"){
				columnWidth=1280*(percent/100);
			}else{
				columnWidth=min(1280, nextBreakpoint)*(percent/100);
			}
			disableFirstLast=false; 
			// if the columns will be less then the minimum column width, force them all to 100% at this breakpoint
			if(n==arrayLen(breakStruct.arrBreak)){
				isSingleColumn=true;
				disableFirstLast=true;
			}else if(breakpoint <= 992 and columnWidth < breakStruct.minimum_column_width){
				// find the previous columnWidth that allows more then one column (if any)  
				for(i3=i2;i3>=2;i3--){
					tempPercent=100/i3;
					disableFirstLast=true;
					if(breakpoint EQ "default"){
						columnWidth=980*(tempPercent/100);
					}else{
						columnWidth=min(980, nextBreakpoint)*(tempPercent/100);
					}
					if(columnWidth >= breakStruct.minimum_column_width){
						break;
					}
				} 
				if(columnWidth < breakStruct.minimum_column_width){
					isSingleColumn=true;
					disableFirstLast=true;
				}else{ 
					percent=tempPercent;
					currentLimit=i3;
					currentIndex=i3;
				}  
			} 
			for(n2=1;n2<=limit;n2++){
				width=percent*n2; 


				// need to calculate the total margin based on number of columns.  i.e. 3 column with 3% column gap is (3-1)*3
				if(breakpoint > 992){
					columnCount=round(100/percent);
					columnCount=n2;
					margin=dataStruct.columnGapSidePercent/2;  
					marginTemp=dataStruct.columnGapSidePercent;
					/*if(n2==currentLimit){
						margin=0;  
						marginTemp=dataStruct.columnGapSidePercent;   
					}*/
					width-=dataStruct.columnGapSidePercent;
					maxWidth=100;  
				}else if(breakpoint EQ 992){ 
					if(percent <= 33.34){
						percent=33.33;
						columnCount=1;
						isSingleColumn=true;
					}else if(percent > 66.67){
						percent=100;
						columnCount=3;
						isSingleColumn=false;
					}else{
						percent=50;//66.66;
						columnCount=2;
						isSingleColumn=false;
					}
					disableFirstLast=true;
					width=n2*percent;
					margin=dataStruct.columnGapSidePercent/2; 
					totalMargin=dataStruct.columnGapSidePercent*columnCount;
					maxWidth=100-totalMargin;
					percentMargin=(percent/100)*totalMargin;
					width-=percentMargin; 
					width=min(maxWidth, int(width*100)/100);  
				}else{
					if(percent <= 50){
						percent=50;
						columnCount=1;
					}else{
						percent=100;
						columnCount=2;
					}
					disableFirstLast=true;
					width=n2*percent;
					margin=dataStruct.columnGapSidePercent/2; 
					totalMargin=dataStruct.columnGapSidePercent*columnCount;
					maxWidth=100-totalMargin;
					percentMargin=(percent/100)*totalMargin;
					width-=percentMargin; 
					width=min(maxWidth, int(width*100)/100);  
				}  
				padding=' padding-left:#dataStruct.columnPaddingSidePercent#%; padding-right:#dataStruct.columnPaddingSidePercent#%; padding-top:#dataStruct.columnPaddingTopPercent#%; padding-bottom:#dataStruct.columnPaddingBottomPercent#%;';

				v='.z-#n2#of#limit#{ float:left; margin-left:#numberformat(margin, '_.___')#%; margin-right:#numberformat(margin, '_.___')#%; #padding# margin-bottom:#numberformat(dataStruct.columnGapBottomPercent, '_.___')#%;}';

				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}  
				if(isSingleColumn){
					v='.z-#n2#of#limit#{ min-height:1px; max-width:100%; width:#numberformat(100-dataStruct.columnGapSidePercent, '_.___')#%; margin-left:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%;  margin-right:#numberformat(dataStruct.columnGapSidePercent/2, '_.___')#%; display:block; }';
					//v='.z-#n2#of#limit#{ min-height:1px; max-width:100%; width:100%; margin-left:0px; margin-right:0px; display:block; }';
					if(not structkeyexists(uniqueStruct, v)){
						uniqueStruct[v]=true;
						arrayAppend(arrCSS, v);
					}   
				}else{    
					if(breakpoint LTE 992){
						v=".z-#n2#of#limit#{ min-width:#breakStruct.minimum_column_width#px; max-width:#maxWidth#%; width:#numberformat(width, '_.___')#%; }";
					}else{
						v=".z-#n2#of#limit#{ max-width:#maxWidth#%; width:#numberformat(width, '_.___')#%; }";
					} 
					if(not structkeyexists(uniqueStruct, v)){
						uniqueStruct[v]=true;
						arrayAppend(arrCSS, v);
					}  
				}
				/*	if(n2 EQ 1 and limit EQ 2 ){
					writedump(v);
					writedump(percent);
					writedump(breakpoint);
					writedump(columnCount);
					writedump(columnWidth&" < "&breakStruct.minimum_column_width&" | "&n2&":"&limit);
					// abort;
					}*/
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}  
				// offset classes
				if(isSingleColumn){
					v='.z-offset-#n2#of#limit#{ margin-left:0px; }';
				}else{
					if(breakpoint > 992){ 
						v='.z-offset-#n2#of#limit#{ margin-left:#numberformat(margin+width, '_.___')#%; }';
					}else{
						v='.z-offset-#n2#of#limit#{ margin-left:#numberformat(margin, '_.___')#%; }';
					}
				}
				arrayAppend(arrOffsetCSS, v);
			} 
			limit++;
		}
		for(i=1;i<=arraylen(arrOffsetCSS);i++){
			arrayAppend(arrCSS, arrOffsetCSS[i]);
		}

		for(i=startFontSize;i<=70;i++){ 
			tempScaleHeading=max(round(i*dataStruct.headingScale), dataStruct.headingMinimumFontSize);
			tempScaleText=max(round(i*dataStruct.textScale), dataStruct.textMinimumFontSize); 
			if(n EQ 1){
				v='.z-fh-#i#{font-size:#i#px !important;  padding-bottom:#round(max(dataStruct.minimumPadding, i*0.45))#px !important;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
				v='.z-ft-#i#{font-size:#i#px !important; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}
			v='.z-h-#i#{font-size:#tempScaleHeading#px;  padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			}
			v='.z-t-#i#{font-size:#tempScaleText#px; }';
			if(not structkeyexists(uniqueStruct, v)){
				uniqueStruct[v]=true;
				arrayAppend(arrCSS, v);
			} 
			headingEnabled=0; 
			if(i EQ "36"){
				headingEnabled=1;
			}else if(i EQ "30"){
				headingEnabled=2;
			}else if(i EQ "24"){
				headingEnabled=3;
			}else if(i EQ "18"){
				headingEnabled=4;
			}else if(i EQ "14"){
				headingEnabled=5;
			}

			if(frameworkEnabled and headingEnabled NEQ 0){
				v='h#headingEnabled#{font-size:#tempScaleHeading#px; padding-bottom:#round(max(dataStruct.minimumPadding, tempScaleHeading*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
			} 
			if(breakpoint EQ "1362"){
				v='.zmd-h-#i#{font-size:#i#px;  padding-bottom:#round(max(dataStruct.minimumPadding, i*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
				v='.zmd-t-#i#{font-size:#i#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}else if(breakpoint EQ "992"){
				v='.zsm-h-#i#{font-size:#i#px;  padding-bottom:#round(max(dataStruct.minimumPadding, i*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
				v='.zsm-t-#i#{font-size:#i#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}else if(breakpoint EQ "479"){
				v='.zxs-h-#i#{font-size:#i#px;  padding-bottom:#round(max(dataStruct.minimumPadding, i*0.45))#px;}';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				}
				v='.zxs-t-#i#{font-size:#i#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS, v);
				} 
			}
		}
	}   
	savecontent variable="out"{
		for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
			breakpoint=breakStruct.arrBreak[i];  
			if(breakpoint NEQ 'Default'){
				echo('@media screen and (max-width: #breakpoint#px) {'&chr(10)); 
				echo(arrayToList(breakStruct.css[breakpoint], chr(10))&chr(10)); 
				echo('}'&chr(10));
			}else{
				echo(arrayToList(breakStruct.css[breakpoint], chr(10))&chr(10)); 
			}
		}  
		// arrCSS2=[];
		// for(g=0;g<=15;g++){
		// 	c=g*10; 
			// v='.z-fp-#c#{ padding-left:#c#px; padding-right:#c#px; padding-top:#c#px; padding-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v); 
			// } 
			// v='.z-fpt-#c#{ padding-top:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fpr-#c#{ padding-right:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fpb-#c#{ padding-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fpl-#c#{ padding-left:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fpv-#c#{ padding-top:#c#px; padding-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fph-#c#{ padding-left:#c#px; padding-right:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fm-#c#{ margin-left:#c#px; margin-right:#c#px; margin-top:#c#px; margin-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmt-#c#{ margin-top:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmr-#c#{ margin-right:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmb-#c#{ margin-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fml-#c#{ margin-left:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmv-#c#{ margin-top:#c#px; margin-bottom:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmh-#c#{ margin-left:#c#px; margin-right:#c#px; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmv-#c#-auto{ margin-top:#c#px; margin-bottom:#c#px; margin-left:auto; margin-right:auto; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
			// v='.z-fmh-#c#-auto{ margin-left:#c#px; margin-right:#c#px; margin-top:auto; margin-bottom:auto; }';
			// if(not structkeyexists(uniqueStruct, v)){
			// 	uniqueStruct[v]=true;
			// 	arrayAppend(arrCSS2, v);
			// } 
		// }
		// echo(arrayToList(arrCSS2, chr(10))&chr(10));
		uniqueStruct={};
		for(i=1;i<=arraylen(breakStruct.arrBreak);i++){
			breakpoint=breakStruct.arrBreak[i];   
			dataStruct=breakStruct.data[breakpoint];
			multiplier=0;
			arrCSS2=[];
		 	for(g=0;g<=15;g++){
		 		if(g EQ 1){
		 			multiplier=0.8;
		 		}
		 		multiplier=g*10;
		 		pt=dataStruct.boxPaddingTopPercent*multiplier;
		 		pb=dataStruct.boxPaddingBottomPercent*multiplier;
		 		ph=dataStruct.boxPaddingSidePercent*multiplier;
		 		mt=dataStruct.boxMarginTopPercent*multiplier;
		 		mb=dataStruct.boxMarginBottomPercent*multiplier;
		 		mh=dataStruct.boxMarginSidePercent*multiplier;
		 		v='.z-p-#g*10#{ padding-left:#ph#px; padding-right:#ph#px; padding-top:#pt#px; padding-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v); 
				} 
				v='.z-pt-#g*10#{ padding-top:#pt#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pr-#g*10#{ padding-right:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pb-#g*10#{ padding-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pl-#g*10#{ padding-left:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-pv-#g*10#{ padding-top:#pt#px; padding-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-ph-#g*10#{ padding-left:#ph#px; padding-right:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-m-#g*10#{ margin-left:#ph#px; margin-right:#ph#px; margin-top:#pt#px; margin-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mt-#g*10#{ margin-top:#pt#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mr-#g*10#{ margin-right:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mb-#g*10#{ margin-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-ml-#g*10#{ margin-left:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mv-#g*10#{ margin-top:#pt#px; margin-bottom:#pb#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mh-#g*10#{ margin-left:#ph#px; margin-right:#ph#px; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mv-#g*10#-auto{ margin-top:#pt#px; margin-bottom:#pb#px; margin-left:auto; margin-right:auto; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				v='.z-mh-#g*10#-auto{ margin-left:#ph#px; margin-right:#ph#px; margin-top:auto; margin-bottom:auto; }';
				if(not structkeyexists(uniqueStruct, v)){
					uniqueStruct[v]=true;
					arrayAppend(arrCSS2, v);
				} 
				multiplier+=0.8; 
			}
			if(breakpoint NEQ 'Default'){
				echo('@media screen and (max-width: #breakpoint#px) {'&chr(10)); 
				echo(arrayToList(arrCSS2, chr(10))&chr(10)); 
				echo('}'&chr(10));
			}else{
				echo(arrayToList(arrCSS2, chr(10))&chr(10)); 
			}
		}  
		echo('.z-width-fill, .z-fill-width{display:table-cell; direction:ltr; width:10000px; float:none;}');
	}
	if(breakStruct.layout_setting_instance_id NEQ 0){
		application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/layout-setting-instance-#breakStruct.layout_setting_instance_id#.css", out);
	}else{
		application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"zupload/layout-global.css", out);
	} 
	</cfscript>

</cffunction>
 
<cffunction name="instanceList" localmode="modern" access="remote" roles="member">
	<cfscript>
	sectionCom=createobject("component", "zcorerootmapping.mvc.z.section.admin.controller.section-admin");
	sectionCom.nav();
	db=request.zos.queryObject;
	application.zcore.functions.zStatusHandler(request.zsid);
	db.sql="select * from #db.table("layout_setting_instance", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and  
	layout_setting_instance_deleted =#db.param(0)# ";
	qList=db.execute("qList");
	echo('<h2>Manage Layout Settings Instances</h2>');
	echo('<p><a href="/z/admin/layout-global/settingsInstance?layout_setting_instance_id=">Add Settings Instance</a></p>');

	if(qList.recordcount){
		echo('<table class="table-list">
			<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Admin</th>
		</tr>');
		for(row in qList){
			echo('<tr>');
			echo('
				<td>#row.layout_setting_instance_id#</td>
				<td>#row.layout_setting_instance_name#</td>
				<td><a href="/z/admin/layout-global/settingsInstance?layout_setting_instance_id=#row.layout_setting_instance_id#">View/Edit</a> | 
				<a href="##" onclick="if(window.confirm(''Are you sure you want to delete this settings instance?'')){ window.location.href=''/z/admin/layout-global/deleteInstance?layout_setting_instance_id=#row.layout_setting_instance_id#''; } ">Delete</a>
				</td>');
			echo('</tr>');
		}
		echo('</table>');
	}
	</cfscript>
</cffunction>


<cffunction name="deleteInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;
	form.layout_setting_instance_id=application.zcore.functions.zso(form, 'layout_setting_instance_id');
	breakStruct={}; 

	application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&"zupload/layout-setting-instance-#form.layout_setting_instance_id#.css");

	breakStruct=getBreakpointConfig();
	defaultBreakstruct=duplicate(breakStruct);
	db.sql="delete from #db.table("layout_setting_instance", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_setting_instance_id=#db.param(form.layout_setting_instance_id)# and 
	layout_setting_instance_deleted =#db.param(0)# ";
	db.execute("qDelete");

	application.zcore.status.setStatus(request.zsid, "Instance deleted");
	application.zcore.functions.zRedirect("/z/admin/layout-global/instanceList?zsid=#request.zsid#");
	</cfscript>
</cffunction>


<cffunction name="settingsInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	sectionCom=createobject("component", "zcorerootmapping.mvc.z.section.admin.controller.section-admin");
	sectionCom.nav();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;
	form.layout_setting_instance_id=application.zcore.functions.zso(form, 'layout_setting_instance_id');
	form.layout_setting_instance_name=application.zcore.functions.zso(form, 'layout_setting_instance_name');
	breakStruct={}; 

	breakStruct=getBreakpointConfig();
	defaultBreakstruct=duplicate(breakStruct);
	db.sql="select * from #db.table("layout_setting_instance", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_setting_instance_id=#db.param(form.layout_setting_instance_id)# and 
	layout_setting_instance_deleted =#db.param(0)# ";
	qData=db.execute("qData");
	if(qData.recordcount NEQ 0){
		oldBreakStruct=deserializeJson(qData.layout_setting_instance_json_data);
		for(i in oldBreakStruct.data){
			if(structkeyexists(breakStruct.data, i)){
				structappend(breakStruct.data[i], oldBreakStruct.data[i], true);
			}
		}
		breakStruct.layout_setting_instance_name=qData.layout_setting_instance_name;
		form.layout_setting_instance_name=qData.layout_setting_instance_name;
		breakStruct.minimum_column_width=application.zcore.functions.zso(oldBreakStruct, 'minimum_column_width', true, 150);
	}else{
		breakStruct.layout_setting_instance_name="";
		breakStruct.minimum_column_width=150;
	}
	echo('<h2 class="z-fh-30">Instance Layout Settings</h2>');

	displaySettingsForm(defaultBreakstruct, breakStruct);
	</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	sectionCom=createobject("component", "zcorerootmapping.mvc.z.section.admin.controller.section-admin");
	sectionCom.nav();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	echo('<div style="width:100%; float:left; padding-left:5px; padding-right:5px;">');
	application.zcore.functions.zStatusHandler(request.zsid);
	db=request.zos.queryObject;

	breakStruct={}; 

	breakStruct=getBreakpointConfig();
	defaultBreakStruct=duplicate(breakStruct);
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)# ";
	qGlobal=db.execute("qGlobal");
	if(qGlobal.recordcount NEQ 0){
		oldBreakStruct=deserializeJson(qGlobal.layout_global_json_data);
		for(i in oldBreakStruct.data){
			if(structkeyexists(breakStruct.data, i)){
				structappend(breakStruct.data[i], oldBreakStruct.data[i], true);
			}
		}
		breakStruct.minimum_column_width=application.zcore.functions.zso(oldBreakStruct, 'minimum_column_width', true, 150);
	}
	echo('<p><a href="/z/admin/layout-global/instanceList">Manage Settings Instances</a></p>');

	echo('<h2 class="z-fh-30">Global Layout Settings</h2>');
	echo('<p>You must include the following stylesheet in your template to make use of this feature: /zupload/layout-global.css</p>');
	echo('<p>Values with a <span class="settingChanged" style="padding:5px;">pink background</span> don''t match the default value.  You can hover your mouse over that field to see a tooltip that has the default value listed.</p>');
	echo('</div>');
	displaySettingsForm(defaultBreakStruct, breakStruct);
	</cfscript>
</cffunction>


<cffunction name="autoPublish" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	db=request.zos.queryObject;

	breakStruct={}; 

	breakStruct=getBreakpointConfig();
	defaultBreakStruct=duplicate(breakStruct);
	db.sql="select * from #db.table("layout_global", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_global_deleted =#db.param(0)# ";
	qGlobal=db.execute("qGlobal");
	if(qGlobal.recordcount NEQ 0){
		oldBreakStruct=deserializeJson(qGlobal.layout_global_json_data);
		for(i in oldBreakStruct.data){
			if(structkeyexists(breakStruct.data, i)){
				structappend(breakStruct.data[i], oldBreakStruct.data[i], true);
			}
		}
		breakStruct.minimum_column_width=application.zcore.functions.zso(oldBreakStruct, 'minimum_column_width', true, 150);
	} 
	defaultBreakPoint=getDefaultBreakpointConfig(); 
 
  
	for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
		breakpoint=breakStruct.arrBreak[n]; 
		id="enabled_"&breakpoint;
		dataStruct=breakStruct.data[breakpoint]; 

		if(application.zcore.functions.zso(dataStruct, 'enabled', true, 1) EQ 1){
			form[id]="1";
		} 
	} 
	arrKey=structkeyarray(defaultBreakPoint);
	arraySort(arrKey, "text", "asc");
	for(i in arrKey){  
		for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
			breakpoint=breakStruct.arrBreak[n]; 
			dataStruct=breakStruct.data[breakpoint]; 
			id=application.zcore.functions.zescape(i, "_")&"_"&breakpoint; 
			defaultValue=defaultBreakStruct.data[breakpoint][i]; 
			form[id]=dataStruct[i];
		}
	}

	form.minimum_column_width=application.zcore.functions.zso(breakStruct, 'minimum_column_width');

	result=saveLayoutSettings();
	echo('#request.zos.globals.domain# | global layout css publish status: #result#');
	abort;
	</cfscript>
</cffunction>
	
<cffunction name="displaySettingsForm" localmode="modern" access="public">
	<cfargument name="defaultBreakStruct" type="struct" required="yes">
	<cfargument name="breakStruct" type="struct" required="yes">
	<cfscript>
	breakStruct=arguments.breakStruct;
	defaultBreakStruct=arguments.defaultBreakStruct;
defaultBreakPoint=getDefaultBreakpointConfig();
// uncomment to more easily debug css generation
//generateGlobalBreakpointCSS(breakStruct);

labelStruct={
	headingScale:"Heading Scale",
	textScale:"Text Scale",
	indentScale:"Indent Scale",
	boxPaddingTopPercent:"Padding Class Top %",
	boxPaddingSidePercent:"Padding Class Side %",
	boxPaddingBottomPercent:"Padding Class Bottom %",
	boxMarginTopPercent:"Margin Class Top %",
	boxMarginSidePercent:"Margin Class Side %",
	boxMarginBottomPercent:"Margin Class Bottom %",
	columnGapSidePercent:"Column Gap Side %",
	columnGapBottomPercent:"Column Gap Bottom %",
	minimumPadding:"Minimum Padding",
	headingMinimumFontSize:"Heading Minimum Font Size",
	textMinimumFontSize:"Text Minimum Font Size",
	headingLineHeightScale:"Heading Line Height Scale",
	textLineHeightScale:"Text Line Height Scale",
	columnPaddingTopPercent:"Column Padding Top %",
	columnPaddingSidePercent:"Column Padding Side %",
	columnPaddingBottomPercent:"Column Padding Bottom %",
};

if(form.method EQ "index"){
	action="/z/admin/layout-global/saveLayoutSettings";
}else{
	action="/z/admin/layout-global/saveLayoutInstanceSettings";
}
// display form
echo('

	<style type="text/css"> 
	.settingChanged{background-color:##FCC;}
	</style> 
	<div style="width:100%; overflow:auto; font-size:14px !important; float:left; padding-left:5px; padding-right:5px;">
	<form class="zFormCheckDirty" action="#action#" method="post">');
if(form.method EQ "settingsInstance"){
	echo('<p>Instance Name: <input type="text" name="layout_setting_instance_name" value="#htmleditformat(form.layout_setting_instance_name)#" /></p>');
	echo('<input type="hidden" name="layout_setting_instance_id" value="#form.layout_setting_instance_id#">');
}
	echo('<table class="table-list">
	<tr>
	<th>&nbsp;</th>');
for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
	breakpoint=breakStruct.arrBreak[n]; 
	dataStruct=breakStruct.data[breakpoint];
	echo('<th>#breakpoint#</th>');
}
echo('</tr>');
	echo('<tr>');
	echo('<th>Enabled?</th>');
for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
	breakpoint=breakStruct.arrBreak[n]; 
	id="enabled_"&breakpoint;
	dataStruct=breakStruct.data[breakpoint]; 

	echo('<td><input type="checkbox" name="#id#" value="1" ');
	if(application.zcore.functions.zso(dataStruct, 'enabled', true, 1) EQ 1){
		echo('checked="checked" ');
	}
	echo(' /></td>');
}
echo('</tr>');
arrKey=structkeyarray(defaultBreakPoint);
arraySort(arrKey, "text", "asc");
for(i in arrKey){
	//i=defaultBreakPoint[arrKey[i]];
	echo('<tr>');
	echo('<th>'&labelStruct[i]&'</th>');
	for(n=1;n<=arraylen(breakStruct.arrBreak);n++){
		breakpoint=breakStruct.arrBreak[n]; 
		dataStruct=breakStruct.data[breakpoint]; 
		id=application.zcore.functions.zescape(i, "_")&"_"&breakpoint;
		echo('<td ');
		defaultValue=defaultBreakStruct.data[breakpoint][i];
		if(defaultValue NEQ dataStruct[i]){
			echo(' class="settingChanged" title="Default at #breakpoint# is: #htmleditformat(defaultValue)#" ');
		}
		echo('><input type="text" name="#id#" value="'&dataStruct[i]&'" style="font-size:14px; width:70px;min-width:70px;" /></td>');
	}
	echo('</tr>');
}

minimum_column_width=application.zcore.functions.zso(breakStruct, 'minimum_column_width');
echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	Column width that triggers single column below 992: <input type="text" name="minimum_column_width" style="font-size:14px; max-width:100px; min-width:100px;" value="#htmleditformat(minimum_column_width)#"><br />
	Enable z-breakpoint: Checkbox
	</td>
	</tr>');

link='/z/admin/layout-global/saveLayoutSettings?setToDefault=1';
if(form.method EQ "settingsInstance"){
	link='/z/admin/layout-global/saveLayoutInstanceSettings?layout_setting_instance_name=#urlencodedformat(form.layout_setting_instance_name)#&layout_setting_instance_id=#form.layout_setting_instance_id#&setToDefault=1';
}

echo('<tr>
	<th>&nbsp;</th>
	<td colspan="#structcount(defaultBreakPoint)#">
	<input type="submit" name="save1" value="Save" class="z-manager-search-button"> 
	<input type="button" name="save2" value="Restore Defaults" class="z-manager-search-button" onclick="if(window.confirm(''Are you sure you want to restore defaults? You should make a backup of the current settings in case they are important.'')){ window.location.href=''#link#''; } "> ');

if(form.method EQ "settingsInstance"){
	echo('<input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/admin/layout-global/instanceList'';">'); 
}
	echo('</td>');
echo('</table>
	</form>
	</div>');   

	form.layout_setting_instance_id=application.zcore.functions.zso(form, 'layout_setting_instance_id', true, 0);
	if(form.layout_setting_instance_id NEQ 0){
		echo('<div style="width:100%; float:left; padding-top:20px;"><h2>Embed Instance Stylesheet</h2>');
		echo('<p>Use this stylesheet URL in your application to activate this instance on specific pages.</p>');
		echo('<textarea name="c1" cols="100" rows="2" style="width:95%;">#request.zos.globals.domain#/zupload/layout-setting-instance-#form.layout_setting_instance_id#.css</textarea></div>');
	}
	</cfscript> 
	<iframe id="cssExampleIframe" src="/z/misc/grid-example/index?layout_setting_instance_id=#form.layout_setting_instance_id#" width="100%" height="300"></iframe> 
	<script type="text/javascript">
	function resizeExampleIframe(){
		$("##cssExampleIframe").height(zWindowSize.height-30);
	}
	zArrDeferredFunctions.push(function(){
		zArrResizeFunctions.push({functionName:resizeExampleIframe});
	});
	</script>
</cffunction>
	
</cfoutput>
</cfcomponent>