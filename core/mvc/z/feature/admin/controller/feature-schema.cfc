<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var theTitle=0;
	db=request.zos.queryObject;
	variables.allowGlobal=false; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	if(application.zcore.user.checkServerAccess()){
		variables.allowGlobal=true;
		variables.siteIdList="'0','"&request.zos.globals.id&"'";
	} 
	if(structkeyexists(form, 'returnURL')){
		request.zsession["feature_schema_return"&application.zcore.functions.zso(form, 'feature_schema_id')]=application.zcore.functions.zso(form, 'returnURL');
	}
	
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		application.zcore.functions.z301Redirect('/member/');
	}

	db.sql="select * from #db.table("feature", request.zos.zcoreDatasource)# feature_schema 
	where feature_id=#db.param(form.feature_id)# and 
	feature_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")#";
	request.qFeature=db.execute("qFeature", "", 10000, "query", false);
	if(request.qFeature.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid feature id", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}

	echo('<p><a href="/z/feature/admin/feature-manage/index">Features</a> / ');
	if(form.method EQ "index"){
		echo(request.qFeature.feature_display_name);
	}else{
		echo('<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">#request.qFeature.feature_display_name#</a>');
	}
	echo(' /</p>');
	theTitle="Manage Feature Schemas";
	application.zcore.template.setTag("title",theTitle); 
	echo('<h2>Feature Schemas</h2>');
	
	this.displayFeatureAdminNav();
	</cfscript>
</cffunction>


<cffunction name="displayFeatureAdminNav" access="public" localmode="modern">
	<cfscript> 
	</cfscript>
	<div class="z-float z-mb-10">
		DevTools:
		<cfif application.zcore.user.checkServerAccess()>
			<a href="/z/feature/admin/features/searchReindex">Search Reindex</a> | 
		</cfif>
		<!--- <a href="/z/feature/admin/feature-sync/index">Sync</a> |  --->
		<cfif structkeyexists(form, "feature_id")>
			<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">Schemas</a>
			 | <a href="/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Add Schema</a>
		</cfif>
	</div>
</cffunction> 

<cffunction name="generateSchemaCode" access="public" localmode="modern">
	<cfargument name="feature_id" type="numeric" required="yes"> 
	<cfargument name="groupId" type="numeric" required="yes"> 
	<cfargument name="parentIndex" type="numeric" required="yes"> 
	<cfargument name="parentSchemaId" type="numeric" required="yes"> 
	<cfargument name="sharedStruct" type="struct" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfargument name="disableLoop" type="boolean" required="yes"> 
	<cfargument name="debugMode" type="boolean" required="yes"> 
	<cfargument name="disableDebugOutput" type="boolean" required="yes">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	ss=arguments.sharedStruct;
	if(not structkeyexists(ss, 'curIndex')){
		ss.curIndex=arguments.parentIndex;
	}else{
		ss.curIndex++;
	}
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData;
	indent="";
	for(i=1;i LTE arguments.depth;i++){
		indent&=chr(9);
	}
	feature_variable_name=application.zcore.featureCom.getFeatureNameById(arguments.feature_id);


	for(i in fsd.featureSchemaLookup){
		groupStruct=fsd.featureSchemaLookup[i];
		groupName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(groupStruct.feature_schema_variable_name), " ", "", "all"), "");
		if(isNumeric(left(groupName, 1))){
			groupName="Schema"&groupName;
		}
		groupNameInstance=lcase(left(groupName, 1))&removeChars(groupName,1,1);
		if(arguments.groupID NEQ 0 and arguments.groupID NEQ groupStruct.feature_schema_id){
			continue;
		}
		if(arguments.parentSchemaID NEQ groupStruct.feature_schema_parent_id){ 	
			continue;
		}
		//echo(chr(10)&indent&"<h2>Schema: "&groupStruct.feature_schema_display_name&'</h2>'&chr(10));
		echo(indent&'<cfscript>#chr(10)#');
		if(not arguments.disableLoop and not arguments.debugMode){
			if(not arguments.disableDebugOutput){
				echo(indent&'// comment out when debugging#chr(10)#');
			}
			if(groupStruct.feature_schema_parent_id NEQ 0){
				parentSchemaStruct=fsd.featureSchemaLookup[groupStruct.feature_schema_parent_id];
				parentSchemaName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(parentSchemaStruct.feature_schema_variable_name), " ", "", "all"), "");
				if(isNumeric(left(parentSchemaName, 1))){
					parentSchemaName="Schema"&parentSchemaName;
				}
				parentSchemaNameInstance=lcase(left(parentSchemaName, 1))&removeChars(parentSchemaName,1,1);
				echo(indent&'arr#groupName#=application.zcore.featureCom.getFeatureSchemaArray("#feature_variable_name#", "#groupStruct.feature_schema_variable_name#", 0, request.zos.globals.id, #parentSchemaNameInstance#);'&chr(10));
			}else{
				echo(indent&'arr#groupName#=application.zcore.featureCom.getFeatureSchemaArray("#feature_variable_name#", "#groupStruct.feature_schema_variable_name#");'&chr(10));
			} 
		}
		if(not arguments.disableDebugOutput and structkeyexists(fsd.featureSchemaFieldLookup, groupStruct.feature_schema_id)){
			jsonStruct={};
			for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
				typeStruct=fsd.fieldLookup[n];

				typeCFC=application.zcore.featureCom.getTypeCFC(typeStruct.feature_field_type_id);
				debugValue=typeCFC.getDebugValue(typeStruct);
				jsonStruct[typeStruct.feature_field_variable_name]=debugValue; 
			} 
			if(groupStruct.feature_schema_enable_unique_url EQ 1){
				jsonStruct.__url='##';
			}
			if(groupStruct.feature_schema_enable_approval EQ 1){
				jsonStruct.__approved=1;
			}
			if(groupStruct.feature_schema_enable_image_library EQ 1){
				jsonStruct.__image_library_id=0;
			}
			if(arguments.disableLoop){
				j=replace(serializeJson(jsonStruct), '##', '####', 'all');
			}else{
				j=replace(serializeJson([jsonStruct]), '##', '####', 'all');
			}
			j=replace(replace(replace(j, '{', '{'&chr(10)&indent&chr(9)), '}', chr(10)&indent&'}'), '","', '",#chr(10)&indent&chr(9)#"', 'all');
			if(arguments.disableLoop){
				if(arguments.debugMode){
					echo(indent&chr(9)&'#chr(10)&indent##groupNameInstance#='&j&';'&chr(10));
				}else{
					echo(indent&chr(9)&'#chr(10)&indent#/* #groupNameInstance#='&j&'; */'&chr(10));
				}
			}else if(arguments.debugMode){
				echo(indent&chr(9)&'arr#groupName#='&j&';'&chr(10));
			}else{
				echo(indent&'// uncomment to debug group without live data#chr(10)&indent#/* arr#groupName#='&j&'; */'&chr(10));
			}
		}
		echo(indent&'</cfscript>#chr(10)#');
		if(not arguments.disableLoop){
			echo(indent&'<cfloop from="1" to="##arrayLen(arr#groupName#)##" index="i#ss.curIndex#">#chr(10)&indent&chr(9)#<cfscript>#groupNameInstance#=arr#groupName#[i#ss.curIndex#];</cfscript>#chr(10)#');
		}
		if(structkeyexists(fsd.featureSchemaFieldLookup, groupStruct.feature_schema_id)){
			c=fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id];
			fieldStruct={};
			for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
				typeStruct=fsd.fieldLookup[n];
				f=indent&chr(9)&'###groupNameInstance#["'&replace(replace(typeStruct.feature_field_variable_name, "##", "####", "all"), '"', '""', 'all')&'"]##'&chr(10);

				ts={
					html: f,
					sort: typeStruct.feature_field_sort
				};
				fieldStruct[n]=ts;
			}
			arrKey=structsort(fieldStruct, "numeric", "asc", "sort");
			for(n2=1;n2<=arraylen(arrKey);n2++){
				n=arrKey[n2];
				echo(fieldStruct[n].html);
			}
			if(groupStruct.feature_schema_enable_unique_url EQ 1){
				echo(indent&chr(9)&'<a href="###groupNameInstance#.__url##">View</a>'&chr(10));
			}
			if(groupStruct.feature_schema_enable_approval EQ 1){
				echo(indent&chr(9)&'<cfif #groupNameInstance#.__approved>Approved<cfelse>Not Approved</cfif>'&chr(10));
			}
			if(groupStruct.feature_schema_enable_image_library EQ 1){
				echo(indent&chr(9)&'<cfscript>'&chr(10));
				echo(indent&chr(9)&'if(structkeyexists(#groupNameInstance#, ''__image_library_id'')){'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts={};'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.output=false;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.size="640x400";'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.layoutType="";'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'ts.image_library_id=#groupNameInstance#.__image_library_id;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.forceSize=true;'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'ts.crop=0;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.offset=0;'&chr(10));
				echo(indent&chr(9)&chr(9)&'ts.limit=0; // zero will return all images'&chr(10)); 
				echo(indent&chr(9)&chr(9)&'var arrImage=request.zos.imageLibraryCom.displayImages(ts);'&chr(10));
				echo(indent&chr(9)&'}else{'&chr(10));
				echo(indent&chr(9)&chr(9)&'arrImage=[];'&chr(10));
				echo(indent&chr(9)&'}'&chr(10));
				echo(indent&chr(9)&'for(i=1;i LTE arrayLen(arrImage);i++){'&chr(10));
				echo(indent&chr(9)&chr(9)&'echo(''<img src="##arrImage[i].link##" alt="##htmleditformat(arrImage[i].caption)##" />'');'&chr(10));
				echo(indent&chr(9)&'}'&chr(10));
				echo(indent&chr(9)&'</cfscript>'&chr(10));
			}
			savecontent variable="childOutput"{
				generateSchemaCode(arguments.feature_id, 0, ss.curIndex, groupStruct.feature_schema_id, arguments.sharedStruct, arguments.depth+2, false, arguments.debugMode, arguments.disableDebugOutput);
			}
			childOutput=trim(childOutput);
			if(len(childOutput)){
				echo(chr(9)&chr(9)&childOutput&chr(10));
			}
		}
		if(not arguments.disableLoop){
			echo(indent&'</cfloop>'&chr(10));
		}
		ss.curIndex++;
	}
	</cfscript>
</cffunction>


<cffunction name="generateCreateTable" access="public" localmode="modern">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="groupId" type="numeric" required="yes">  
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	 
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id]; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData; 


	groupStruct=fsd.featureSchemaLookup[arguments.groupId];
 
	tableName=lcase(application.zcore.functions.zURLEncode(groupStruct.feature_schema_variable_name, "_"));
 
	echo("CREATE TABLE `#tableName#` (
`#tableName#_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
`feature_data_id` int(11) unsigned NOT NULL DEFAULT '0',
`feature_schema_id` int(11) unsigned NOT NULL DEFAULT '0',
`feature_data_sort` int(11) unsigned NOT NULL DEFAULT '0',
`feature_data_active` char(1) NOT NULL DEFAULT '0',
`feature_data_parent_id` int(11) NOT NULL DEFAULT '0',
`feature_data_image_library_id` int(11) NOT NULL DEFAULT '0',
`feature_data_override_url` varchar(255) NOT NULL,
`feature_data_approved` char(1) NOT NULL DEFAULT '0',
`#tableName#_updated_datetime` datetime NOT NULL,
`#tableName#_deleted` char(1) NOT NULL DEFAULT '0',"&chr(10));  
	if(structkeyexists(fsd.featureSchemaFieldLookup, groupStruct.feature_schema_id)){
		for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
			typeStruct=fsd.fieldLookup[n];
			savecontent variable="out"{
				var currentCFC=application.zcore.featureCom.getTypeCFC(typeStruct.type); 
				fieldName="#tableName#_"&lcase(application.zcore.functions.zURLEncode(typeStruct.feature_field_variable_name, "_"));
				v=currentCFC.getCreateTableColumnSQL(fieldName);
			}
			echo(v&","&chr(10));
		} 
	}
	echo('PRIMARY KEY (`#tableName#_id`),
KEY `feature_data_id` (`feature_data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;');  
	</cfscript>
</cffunction>
 
<cffunction name="generateUpdateTable" access="public" localmode="modern"> 
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="groupId" type="numeric" required="yes">  
	<cfscript>
 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	 
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id]; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData; 


	groupStruct=fsd.featureSchemaLookup[arguments.groupId];
 
	tableName=lcase(application.zcore.functions.zURLEncode(groupStruct.feature_schema_variable_name, "_"));
  
	if(structkeyexists(fsd.featureSchemaFieldLookup, groupStruct.feature_schema_id)){
		for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
			typeStruct=fsd.fieldLookup[n];
			savecontent variable="out"{ 
				fieldName="#tableName#_"&lcase(application.zcore.functions.zURLEncode(typeStruct.feature_field_variable_name, "_"));
			}
			echo(fieldName&':ds["'&replace(typeStruct.feature_field_variable_name, "##", "####", "all")&'"],'&chr(10)); 
		} 
	}
	</cfscript>
</cffunction>

<cffunction name="displaySchemaCode" access="remote" localmode="modern" roles="member"> 
	<cfscript>
	application.zcore.functions.zSetPageHelpId("2.11.1.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	request.zos.whiteSpaceEnabled=true;
	application.zcore.template.setPlainTemplate();
	form.feature_id=application.zcore.functions.zso(form, 'feature_id', true, 0);
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true, 0);
	form.feature_schema_parent_id=application.zcore.functions.zso(form, 'feature_schema_parent_id', true, 0);

	feature_variable_name=application.zcore.featureCom.getFeatureNameById(form.feature_id);
	
	echo('<div style="width:98% !important; float:left;margin:1%;">');
	echo('<h2>Source code generated below.</h2>
	<p>Note: searchSchema() retrieves all the records.  If "Enable Memory Caching" is disabled for the group, it will perform a query to select all the data.  This can be very slow if you are working with hundreds or thousands of records and it may cause nested queries to run if the sub-groups also have "Enable Memory Caching" disabled.   Conversely, for small datasets, this feature is much faster then running a query.</p>
	<p>If you want to disable "Enable Memory Caching", we have a feature that allows returning only the columns you need, such as when making a search filter loop.</p>
	<p>Example: arr1=application.zcore.featureCom.getFeatureSchemaArray("#feature_variable_name#", "Schema Name", 0, request.zos.globals.id, {__groupId=0,__setId=0}, "Field Name,Field 2,etc");</p>
	<p>Then when you need the full records later in your code, you can grab them by id like this.</p>
	<p>fullStruct=application.zcore.featureCom.getSchemaSetById("#feature_variable_name#", ["Schema Name"], dataStruct.__setId);</p>

	<p>Warning: The data returned from these function calls is the original copy.  Make sure not to modify the object or it will be modified for all requests until the database is read again.  Also make a new variable first or use the duplicate() function to make a copy.   If the datatype is not able to be converted to a string automatically, then it will always be accessed as a reference to the original instead of a copy.  i.e. struct/array/components are references.  String/boolean/number are copied when you set a variable.</p>
	');
	echo('
		<h2>Jetendo Array Output</h2>
		<textarea name="a222" cols="100" rows="10" style="width:70%;">');

	savecontent variable="cfcOutput"{
		generateSchemaCode(form.feature_id, form.feature_schema_id, 1, form.feature_schema_parent_id, {}, 0, true, false, true);
	}
	cfcOutput=trim(cfcOutput);

	request.zos.forceAbsoluteImagePlaceholderURL=true;
	savecontent variable="cfcDebugOutput"{
		generateSchemaCode(form.feature_id, form.feature_schema_id, 1, form.feature_schema_parent_id, {}, 0, true, true, false);
	}
	structdelete(request.zos, 'forceAbsoluteImagePlaceholderURL');
	cfcDebugOutput=trim(cfcDebugOutput);
	savecontent variable="output"{
		generateSchemaCode(form.feature_id, form.feature_schema_id, 1, form.feature_schema_parent_id, {}, 0, false, false, false);

		 
	fsd=application.zcore.featureData.featureSchemaData[form.feature_id]; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData;
	if(not structkeyexists(fsd.featureSchemaLookup, form.feature_schema_id)){
		application.zcore.functions.z404("#form.feature_schema_id# is not a valid feature_schema_id");
	}
		groupStruct=fsd.featureSchemaLookup[form.feature_schema_id];

		groupName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(groupStruct.feature_schema_variable_name), " ", "", "all"), "");
		if(isNumeric(left(groupName, 1))){
			groupName="Schema"&groupName;
		}
		groupNameInstance=lcase(left(groupName, 1))&removeChars(groupName,1,1);

		groupNameArray=arrayToList(application.zcore.featureCom.getSchemaNameArrayById(groupStruct.feature_id, groupStruct.feature_schema_id), '","');
		
	}
	echo(trim(output));
	echo('</textarea>');
	if(groupStruct.feature_schema_enable_unique_url EQ 1){
		savecontent variable="output"{
		echo('<!--- Below is an example of a CFC that is used for making a custom page, search result, and search index for a feature_data record. --->
<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	#groupNameInstance#=application.zcore.featureCom.getSchemaSetById("#feature_variable_name#", ["#groupNameArray#"], arguments.query.feature_data_id);  
	</cfscript> 
	#cfcOutput#
</cffunction>

<!--- To debug without live data, uncomment this index function and comment out the other index function: --->
<!---
<cffunction name="index" access="remote" localmode="modern">
	#cfcDebugOutput#
</cffunction>
---> 

<!--- Optional functions used to integrate with search site feature
<cffunction name="searchResult" access="public" roles="member" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	// output the search result html
	</cfscript>
</cffunction>

<cffunction name="searchReindex" access="public" roles="member" localmode="modern">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	// map dataStruct custom fields to the tableStruct search fields.
	</cfscript>
</cffunction> --->
</cfoutput>
</cfcomponent>');

		}
		echo('<h2>Jetendo Custom Landing Page CFC Code</h2>
		<textarea name="a2222" cols="100" rows="10" style="width:70%;">'&output&'</textarea>');
		savecontent variable="output"{
		echo('<!--- If you are using the standalone framework, you should use this CFC instead --->
<cfcomponent extends="layout">
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	request.title="#groupName#";
	arrayAppend(request.stylesheets, ''<link rel="stylesheet" href="##request.currentPath##/stylesheets/subpage.css" type="text/css" />'');
	// arrayAppend(request.scripts, ''<script type="text/javascript" src="##request.currentPath##/js/custom-example.js"></script>'');
	header();
	</cfscript>
	#cfcDebugOutput#

<section class="page-title">
	<div class="z-container z-center-children">
		<h1>Title</h1>
	</div>
</section>

<section class="z-pv-40">
	<div class="z-container"> 
		<div class="z-1of3">Column 1</div>
		<div class="z-1of3">Column 2</div>
		<div class="z-1of3">Column 3</div>
	</div>
</section>

<!-- add more sections -->

	<cfscript>
	footer();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>');
		}
	}

	echo('
		<h2>Standalone Framework Custom Landing Page CFC Code</h2>
		<textarea name="a2222" cols="100" rows="30" style="width:70%;">'&output&'</textarea>');
	echo('<div style="width:100%; float:left; padding-top:10px;">
	<h2>Miscellaneous Code</h2>
	<p>To select a single group set, use one of the following:</p>
	<ul>
	<li>Memory Cache Enabled: struct=application.zcore.featureCom.getSchemaSetById("#feature_variable_name#", ["#groupNameArray#"], feature_data_id);</li>
	<li>Memory Cache Disabled: showUnapproved=false; struct=application.zcore.featureCom.getSchemaSetByID("#feature_variable_name#", ["#groupNameArray#"], feature_data_id, request.zos.globals.id, showUnapproved); </li>
	</ul>');
	if(groupStruct.feature_schema_allow_public NEQ 0){
		if(groupStruct.feature_schema_public_form_url NEQ ""){
			link=groupStruct.feature_schema_public_form_url;
		}else{
			link='/z/feature/feature-display/add?feature_schema_id=#groupStruct.feature_schema_id#';
		}
		link=application.zcore.functions.zURLAppend(link, 'modalpopforced=1');
		echo('<h2>Iframe Embed Code</h2><pre>'&htmlcodeformat('<iframe src="'&link&'" frameborder="0"  style=" margin:0px; border:none; overflow:auto;" seamless="seamless" width="100%" height="500" />')&'</pre>');
		echo('<h2>Modal Window</h2><pre>'&htmlcodeformat('<a href="##" onclick="zShowModalStandard(''#link#?zRefererURL=''+escape(window.location.href), 540, 400); return false;">Show Form</a>')&'</pre>');
		echo('<p>Note "zRefererURL" can be passed to the form, or defined in the script to force the referring page url to be stored. In cfml, you can use form.zReferer=request.zos.globals.domain&request.zos.originalURL;  In JavaScript, "?zRefererURL="+escape(window.location.href);</p>');

		echo('<h2>CFML Embed Form Code</h2><pre>'&htmlcodeformat('
application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id"));
// Note: if this group is a child group, you must update the array below to have the parent groups as well.
form.feature_schema_id=application.zcore.featureCom.getSchemaIDWithNameArray(["#groupNameArray#"]);
displaySchemaCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.controller.feature-display");
displaySchemaCom.add();')&'</pre>');
	}
	echo('<h2>Alternative Schema Search Method</h2>
	<p>application.zcore.featureCom.searchSchema(); can also be used to filter records with SQL-LIKE object input.</p>
	<p>By default, all records are looped & compared in memory with a single thread, so be aware that it may take a lot of CPU time with a larger database.</p>
	<p>When working with hundreds or thousands of records, you can achieve better performance & reduced memory usage with the database based search method that is built in to searchSchema.  It translates the structured input array into an efficient SQL query that returns only the records you select.  To switch to using database queries for searchSchema, you only need to disable "Enable Memory Caching" on the edit group form.  Keep in mind the sub-groups have their own "Enable Memory Caching" setting which you may want to enable or disable.</p>
	<p>Even when memory cache is disabled queries are only necessary to retrieve data value because the schema information is still cached in memory.</p>
	<p>Simple Example with fake group/field info:</p>
	<pre>
	
	groupName="#groupStruct.feature_schema_variable_name#";
	// build search as an array of structs.  Supports nested sub-group search, AND/OR, logic grouping, many operators, and multiple values.  See the function definition of searchSchema for more information.
	arrSearch=[{
		type="=",
		field: "Title",
		arrValue:["Title1"]	
	}
	];
	parentSchemaId=0;
	showUnapproved=true;
	offset=0;
	limit=10;
	// perform search and return struct with array of structs and whether or not there are more records.
	rs=application.zcore.featureCom.searchSchema(groupName, arrSearch, parentSchemaId, showUnapproved, offset, limit);
	if(arraylen(rs.arrResult)){
		for(i=1;i LTE arraylen(rs.arrResult);i++){
			c=rs.arrResult[i];
			echo(c["Title"]&"&lt;br /&gt;");
		}
		if(rs.hasMoreRecords){
			// show next button
		}
	}
	</pre>'); 


	if(groupStruct.feature_schema_allow_public NEQ 0){
		echo('<h2>Public Form Examples</h2>
		<h3>Embed Public Form in any page</h3>
		'&htmlcodeformat('<cfscript>
form.feature_schema_id=application.zcore.functions.zGetSiteSchemaIDWithNameArray(["#groupNameArray#"]);
displaySchemaCom=createobject("component", "zcorerootmapping.mvc.z.feature.controller.feature-display");
displaySchemaCom.add();
</cfscript>')&'

		<h3>Custom Version Of Form Field Layout With Custom Ajax Processing</h3>
		'&htmlcodeformat('
<cffunction name="customFormProcess" access="remote" localmode="modern">
	<cfscript>

	request.zos.disableSpamCheck=true;
    application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id")); 
    form.feature_schema_id=application.zcore.functions.zGetSiteSchemaIDWithNameArray(["#groupNameArray#"]);
	
    displaySchemaCom=createobject("component", "zcorerootmapping.mvc.z.feature.controller.feature-display");
    displaySchemaCom.ajaxInsert();

	</cfscript>
</cffunction>
<cffunction name="customForm" access="remote" localmode="modern">
 	<form class="zFormCheckDirty" id="customForm1" action="" method="post">
		<div class="rowDiv1">
			<div class="labelDiv1">
				Field Name
			</div>
			<div class="fieldDiv1"> 
				<input type="text" name="Field Name" value="" />
			</div>
		</div>
		<input type="submit" name="submit1" value="Submit" />
	</form>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		$("##customForm1").bind("submit", function(){
			var postObj=zGetFormDataByFormId("customForm1"); 
			var tempObj={};
			tempObj.id="ajaxModalFormLoad";
			tempObj.cache=false;
			tempObj.method="post";
			tempObj.postObj=postObj;
			tempObj.callback=function(r){ 
				var r=JSON.parse(r);
				if(r.success){ 
					// success
				}else{
					alert(r.errorMessage);
					return;
				}
				window.location.href="#groupStruct.feature_schema_public_thankyou_url#";
			};
			tempObj.ignoreOldRequests=true;
			tempObj.url="/form/customFormProcess";
			zAjax(tempObj);
			return false;
		});
	});
	</script>
</cffunction>')&'
		
		<h3>Ajax Insert</h3>
		<p>Use this when the data needs to come from another form/request and you can''t display the form directly.</p>
		'&htmlcodeformat('<cfscript>
request.zos.disableSpamCheck=true;
application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id"));
form.feature_schema_id=application.zcore.functions.zGetSiteSchemaIDWithNameArray(["#groupNameArray#"]);

displaySchemaCom=createobject("component", "zcorerootmapping.mvc.z.feature.controller.feature-display");
displaySchemaCom.ajaxInsert();
</cfscript>'));
	}
	// custom version - use moving to sunny as example...

	echo('</div></div>');
	

	echo('<h2>Create Custom Table</h2>
		<p>Using the "Change CFC Path" options, you can have a second table updated with the data, so you can create high performance queries against the data.</p>
		<p>Start with the example code below, and further customize it, add column indexes, and different table column names, etc to build your custom application.</p>');
	echo('<pre><blockquote>');
	savecontent variable="out"{
	generateCreateTable(form.feature_id, form.feature_schema_id);
	}
	echo(trim(out));
	echo('</blockquote></pre>');
	echo('<h2>Example Functions For Updating the Custom Table</h2>'); 

	savecontent variable="out"{
		generateUpdateTable(form.feature_id, form.feature_schema_id);
	}
	echo('<blockquote>'&htmlcodeformat(trim(out))&'</blockquote>');


	echo('<h2>Generate Widget Config Code</h2>
		<p>This code can be used by the widget system so you can build forms for new widgets visually, and then convert them to code for further editing.</p>');
	echo('<textarea name="widget_code" cols="100" rows="10" style="width:95%;">');
	echo('cs={};'&chr(10));
 	echo('cs.dataFields=[');
	count=0; 
	fsd=application.zcore.featureData.featureSchemaData[form.feature_id]; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData;
	if(structkeyexists(fsd.featureSchemaFieldLookup, groupStruct.feature_schema_id)){
		for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
			typeStruct=fsd.fieldLookup[n];
			count++;
			currentCFC=application.zcore.featureCom.getTypeCFC(typeStruct.type);   
			typeName=currentCFC.getTypeName();
			options=currentCFC.getFieldStruct();
			currentFields=duplicate(typeStruct.typeStruct);
			structappend(currentFields, options, false);
			tabs=chr(9);
			if(count NEQ 1){
				echo(',');
			}
			echo(chr(10)&'{'&chr(10));
			echo('#tabs#id:"#count#",'&chr(10));
			echo('#tabs#label:"#replace(replace(typeStruct.feature_field_variable_name, '##', '####', 'all'), '"', '""', "all")#",'&chr(10));
			echo('#tabs#type:"#typeName#",'&chr(10));
			echo('#tabs#required:#typeStruct.feature_field_required#,'&chr(10));
			echo('#tabs#defaultValue:"#replace(replace(typeStruct.feature_field_default_value, '##', '####', 'all'), '"', '""', "all")#",'&chr(10));
			echo('#tabs#options:{');
			first=true;
			for(g in currentFields){
				if(not first){
					echo(','&chr(10));
				}else{
					echo(chr(10));
				}
				first=false;
				echo(chr(9)&chr(9)&'"#replace(replace(g, '##', '####', 'all'), '"', '""', "all")#":"#replace(replace(currentFields[g], '##', '####', 'all'), '"', '""', "all")#"');
			}
			echo(chr(10)&'#tabs#}'&chr(10)); 
			echo('}'); 
		}
	}
	echo(chr(10)&'];');
	echo('</textarea>');
	</cfscript>
</cffunction>

<cffunction name="help" access="remote" localmode="modern" roles="member"> 
	<cfscript>
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true, 0);
	
	fsd=application.zcore.featureData; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].featureSchemaData; 
	for(i in fsd.featureSchemaLookup){
		groupStruct=fsd.featureSchemaLookup[i];
		if(form.feature_schema_id NEQ 0 and form.feature_schema_id NEQ groupStruct.feature_schema_id){
			continue;
		} 
		echo("<h2>"&groupStruct.feature_schema_display_name&'(s) Help Page</h2>'&chr(10));
		echo('<div style="width:100%; float:left; padding-bottom:10px;">'&groupStruct.feature_schema_help_description&'</div>');
		echo('<div style="width:100%; float:left; padding-bottom:10px;"><h2>Fields</h2>
		<table class="table-list">');
		ss={};
		for(n in fsd.featureSchemaFieldLookup[groupStruct.feature_schema_id]){
			ss[n]=fsd.fieldLookup[n];
		}
		arrKey=structsort(ss, "text", "asc", "feature_field_variable_name");
		for(n=1;n LTE arraylen(arrKey);n++){
			typeStruct=fsd.fieldLookup[arrKey[n]];
			echo('<tr>');
			echo('<th style="width:150px; ">#htmleditformat(typeStruct.feature_field_variable_name)#</th><td>');
			if(typeStruct.feature_field_tooltip EQ ""){
				echo('No help available.');
			}else{
				echo(typeStruct.feature_field_tooltip);
			}
			echo('</td></tr>');
			
		}
		echo('</table></div>');
		
	}
	</cfscript>
</cffunction>


<cffunction name="saveMapFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	form.feature_id=application.zcore.featureCom.getFeatureIdForSchema(form.feature_schema_id);

	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	for(local.i=1;local.i LTE form.fieldcount;local.i++){
		form.feature_field_id=application.zcore.functions.zso(form, 'option'&local.i);
		form.mapField=application.zcore.functions.zso(form, 'mapField'&local.i);
		if(form.mapField NEQ ""){
			db.sql="INSERT INTO #db.table("feature_map", request.zos.zcoreDatasource)# 
			SET feature_map_updated_datetime = #db.param(request.zos.mysqlnow)#, 
			feature_field_id=#db.param(form.feature_field_id)#,
			feature_map_fieldname=#db.param(form.mapField)#,
			feature_schema_id=#db.param(form.feature_schema_id)#, 
			feature_id=#db.param(form.feature_id)#, 
			feature_map_deleted=#db.param(0)#
			";
			db.execute("qInsert");
		}
	}
	db.sql="delete from #db.table("feature_map", request.zos.zcoreDatasource)# 
	where feature_schema_id=#db.param(form.feature_schema_id)# and 
	feature_map_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_map_updated_datetime < #db.param(request.zos.mysqlnow)#";
	db.execute("qDelete");
	application.zcore.status.setStatus(request.zsid, "Map fields saved.");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="export" localmode="modern" access="remote" roles="administrator">
	<cfscript>

	// content type="text/plain";
	setting requesttimeout="10000";
	var db=request.zos.queryObject;
	currentSchemaId=application.zcore.functions.zso(form, 'feature_schema_id'); 
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(currentSchemaId)# and 
	feature_schema_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	qSchema=db.execute("qSchema");
	if(qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}
	header name="Content-Disposition" value="attachment; filename=#dateformat(now(), "yyyy-mm-dd-")&qSchema.feature_schema_variable_name#.csv";
	optionCom=createobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");

	db.sql="SELECT * FROM  
	#db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_field.feature_schema_id = #db.param(currentSchemaId)# and  
	feature_field_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_field")#
	ORDER BY feature_field_sort ASC";
	qField=db.execute("qField");
	arrField=[];
	arrRowDefault=[];
	typeStruct={};
	typeStructType={};
	first=true;

	hasUser=false;
	for(row in qField){
		arrayAppend(arrRowDefault, "");
		arrayAppend(arrField, row.feature_field_variable_name);
		v=replace(replace(replace(replace(replace(row.feature_field_variable_name, chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '\', '\\', 'all'), '"', '\"', "all");
		if(not first){
			echo(",");
		}
		if(row.feature_field_type_id EQ 16){
			hasUser=true;
		}
		first=false;
		echo('"'&v&'"');
		typeStruct[row.feature_field_id]=arraylen(arrField);
		typeStructType[row.feature_field_id]=row.feature_field_type_id;
	}
	if(hasUser){
		userStruct={};
		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
		site_id=#db.param(request.zos.globals.id)# and 
		user_deleted=#db.param(0)# and 
		user_active=#db.param(1)# ";
		qUser=db.execute("qUser");
		arrUser=listToArray(qUser.columnlist, ",");
		userFieldStruct={
			member_address:"Address",
			member_address2:"Address 2",
			member_city:"City",
			member_state:"State",
			member_zip:"Zip/Postal Code",
			member_country:"Country",
			member_phone:"Phone",
			member_company:"Company",
			member_fax:"Fax",
			user_pref_list:"Opt In",
			member_first_name:"First Name",
			member_last_name:"Last Name", 
			user_username:"Email"
		};
		arrEmptyUser=[];
		firstRow=true;
		for(row in qUser){
			arrOut=[];
			for(i=1;i<=arraylen(arrUser);i++){
				if(structkeyexists(userFieldStruct, arrUser[i])){
					v=row[arrUser[i]];
					if(arrUser[i] EQ "user_pref_list"){
						if(v EQ 1){
							v="Yes";
						}else{
							v="No";
						}
					}
					if(firstRow){ 
						arrayAppend(arrEmptyUser, '""');
						echo(',"'&userFieldStruct[arrUser[i]]&'"');
					}
					row[arrUser[i]]=rereplace(replace(replace(replace(replace(replace(v, chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '\', '\\', 'all'), '"', '\"', "all"), '<.*?>', '', 'all');
					arrayAppend(arrOut, ',"'&v&'"');
				}
			} 
			if(firstRow){
				firstRow=false;
			}
			userStruct[row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)]=arrayToList(arrOut, "");
		}
	} 
	echo(chr(13)&chr(10));
	/*
	writedump(userFieldStruct);
	writedump(userStruct);
	abort;
*/
	doffset=0;
	while(true){

		// process x groups at a time.
		xlimit=20;
		db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
		WHERE feature_schema_id = #db.param(currentSchemaId)# and  
		feature_field_deleted = #db.param(0)# 
		ORDER BY feature_field_sort ASC";
		qField=db.execute("qField", "", 10000, "query", false);

		db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE feature_schema_id = #db.param(currentSchemaId)# and 
		feature_data_master_set_id = #db.param(0)# and 
		feature_data_deleted = #db.param(0)# and 
		#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_data")# and 
		site_id = #db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qSchemas=db.execute("qSchemas");
		if(qSchemas.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qSchemas){

			arrRow=duplicate(arrRowDefault);
			userStructRow={};
			arrAddUser=[];

			fieldStruct={};
			if(row.feature_data_field_order NEQ ""){
				arrFieldOrder=listToArray(row.feature_data_field_order, chr(13), true);
				arrFieldData=listToArray(row.feature_data_data, chr(13), true);
				for(i=1;i<=arraylen(arrFieldOrder);i++){
					fieldStruct[arrFieldOrder[i]]=arrFieldData[i];
				}
			}
			loop query="qField"{
				value="";
				if(structkeyexists(fieldStruct, qField.feature_field_id)){
					value=fieldStruct[qField.feature_field_id];
				}
				if(structkeyexists(typeStruct, qField.feature_field_id)){
					offset=typeStruct[qField.feature_field_id]; 
					if(typeStructType[qField.feature_field_id] EQ 16){ 
						if(structkeyexists(userStruct, value)){
							arrayAppend(arrAddUser, userStruct[value]); 
						} 
					}
					arrRow[offset]=value;
				}
			}
			for(i2=1;i2 LTE arraylen(arrRow);i2++){
				if(i2 NEQ 1){
					echo(',');
				} 
				v=rereplace(replace(replace(replace(replace(arrRow[i2], chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '"', '""', "all"), '<.*?>', '', 'all');
				echo('"'&v&'"');  
			}
			echo(arrayToList(arrAddUser, ","));
			echo(chr(13)&chr(10));
		}
	}
	abort;
	</cfscript>
</cffunction>

<cffunction name="reindex" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var qSchema=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qField=0;
	setting requesttimeout="10000";
	currentSchemaId=application.zcore.functions.zso(form, 'feature_schema_id'); 
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(currentSchemaId)# and 
	feature_schema_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	qSchema=db.execute("qSchema");
	if(qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}
	optionCom=createobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");

	doffset=0;
	while(true){

		// process x groups at a time.
		xlimit=20;

		db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE feature_schema_id = #db.param(currentSchemaId)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_data_master_set_id = #db.param(0)# and 
		feature_id=#db.param(qSchema.feature_id)# and 
		site_id=#db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qSchemas=db.execute("qSchemas");
		if(qSchemas.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qSchemas){

			structclear(form);


			ts={}; 
			fieldStruct={};
			if(row.feature_data_field_order NEQ ""){
				arrFieldOrder=listToArray(row.feature_data_field_order, chr(13), true);
				arrFieldData=listToArray(row.feature_data_data, chr(13), true);
				for(i=1;i<=arraylen(arrFieldOrder);i++){
					form["newvalue"&arrFieldOrder[i]]=arrFieldData[i];
				}
			}
			// for(value in qValues){
			// 	ts[value.feature_field_variable_name]=value.feature_data_value;
			// 	//form['newvalue'&value.feature_field_id]=form[value.feature_data_value];
			// }
			// get all Feature Fields with label and value for current row.

			//throw("warning: this will delete unique url and image gallery id - because internalSchemaUpdate is broken.");

			arrSchemaName =application.zcore.featureCom.getSchemaNameArrayById(qSchema.feature_id, qSchema.feature_schema_id); 
			application.zcore.featureCom.setSchemaImportStruct(qSchema.feature_id, arrSchemaName, 0, ts, form); 
			structappend(form, row, true);
			// writedump(form);abort;
 
			rs=optionCom.internalSchemaUpdate(); 
			if(not rs.success){
				writedump(rs);
				writedump(ts);
				writedump(form);
				application.zcore.functions.zStatusHandler(rs.zsid);
				abort;
			} 
		}
	}
	application.zcore.status.setStatus(request.zsid, "Schema, ""#qSchema.feature_schema_variable_name#"", was reprocessed successfully.");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="mapFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qSchema=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qField=0;
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id'); 
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	qSchema=db.execute("qSchema");
	if(qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}
	echo("<h2>Map Fields For Feature Schema: #qSchema.feature_schema_display_name#</h2>");
	
	// if(qSchema.feature_map_group_id NEQ 0){
	// 	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	// 	WHERE feature_schema_id = #db.param(qSchema.feature_map_group_id)# and 
	// 	feature_schema_deleted = #db.param(0)# and 
	// 	feature_id=#db.param(qSchema.feature_id)# ";
	// 	qMapSchema=db.execute("qMapSchema");
	// 	if(qMapSchema.recordcount EQ 0){
	// 		application.zcore.status.setStatus(request.zsid, "You must add an option to the group before you can use this feature.", form, true);
	// 		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	// 	}
	// 	echo("<p>Mapping to Feature Schema: ""#qMapSchema.feature_schema_display_name#""</p>");
	// }else{
		echo("<p>Mapping to Inquiries Table.</p>");
	// }
	db.sql="SELECT * FROM #db.table("feature_map", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_map_deleted = #db.param(0)# and 
	feature_id=#db.param(qSchema.feature_id)# ";
	local.qMap=db.execute("qMap");
	local.mapStruct={};
	for(row in local.qMap){
		local.mapStruct[row.feature_field_id]=row.feature_map_fieldname;
	}
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_id=#db.param(qSchema.feature_id)# and 
	feature_field_deleted = #db.param(0)#
	ORDER BY feature_field_sort ASC";
	qField=db.execute("qField");
	
	mappingEnabled=true;
	if(qSchema.feature_schema_map_fields_type EQ "2"){ // group
		// get second group
		db.sql="SELECT feature_field_display_name, feature_field_id FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
		WHERE feature_schema_id = #db.param(qSchema.feature_map_group_id)# and 
		feature_field_deleted = #db.param(0)# and
		feature_id=#db.param(qSchema.feature_id)# and
		feature_field_allow_public = #db.param(1)#
		ORDER BY feature_field_display_name";
		local.qField2=db.execute("qField2"); 
		if(local.qField2.recordcount EQ 0){
			mappingEnabled=false;
			writeoutput('No Feature Fields in the mapped group, "#qMapSchema.feature_schema_display_name#",  are set to "allow public" = "yes".  Make at least 1 field public to allow this feature to be used.');
		}
		local.arrLabel=[];
		local.arrValue=[];
		for(row in local.qField2){
			arrayAppend(local.arrLabel, row.feature_field_display_name);
			arrayAppend(local.arrValue, row.feature_field_id);
		}
		local.labels=arrayToList(local.arrLabel, chr(9));
		local.values=arrayToList(local.arrValue, chr(9));
	
	}else if(qSchema.feature_schema_map_fields_type EQ "1"){ // inquiries
		// get fields in inquiries
		// manually remove sensitive ones
		// structdelete
		// force some default values for new table
		local.tempColumns=duplicate(application.zcore.tableColumns["#request.zos.zcoreDatasource#.inquiries"]);
		//writedump(local.tempColumns);
		arrTemp=structkeyarray(local.tempColumns);
		arraySort(arrTemp, "text", "asc");
		arrNew=[];
		ignoreStruct={
			inquiries_assign_name:true,
			inquiries_assign_email:true,
			content_id:true,
			inquiries_key:true,
			inquiries_parent_id:true,
			inquiries_referer:true,
			inquiries_referer2:true,
			inquiries_status_id:true,
			inquiries_type_id:true,
			inquiries_type_id_siteIDType:true,
			inquiries_type_other:true,
			inquiries_updated_datetime:true,
			ip_id:true,
			user_id:true,
			user_id_siteIdType:true,
			site_id:true
		}
		for(i=1;i<=arrayLen(arrTemp);i++){
			n=arrTemp[i];
			if(structkeyexists(ignoreStruct, n)){
				continue;
			}
			arrayAppend(arrNew, arrTemp[i]);
		}
		arrTemp=arrNew;
		local.labels="inquiries_custom_json"&chr(9)&arrayToList(arrTemp, chr(9));
		local.values=local.labels;
		
	}else{
		application.zcore.functions.z404("qSchema.feature_schema_map_fields_type: "&qSchema.feature_schema_map_fields_type&" is invalid");
	}

	local.index=1;
	if(mappingEnabled){
		writeoutput('<p>Map as many fields as you wish. You can map an option to the same field multiple times to automatically combine those values.</p>
			<p>To save time, try clicking <a href="##" class="zOptionGroupAutoMap">auto-map</a> first.</p>
		<form class="zFormCheckDirty" id="optionGroupMapForm" action="/z/feature/admin/feature-schema/saveMapFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#" method="post">
		<table class="table-list"><tr><th>Field Field</th><th>Map To Field</th></tr>');
		for(row in qField){
			writeoutput('<tr><td><input type="hidden" name="option#local.index#" value="#row.feature_field_id#" /><div id="fieldLabel#local.index#" class="fieldLabelDiv" data-id="#local.index#">'&htmleditformat(row.feature_field_display_name)&'</div></td><td>');
			if(structkeyexists(local.mapStruct, row.feature_field_id)){
				form["mapField"&local.index]=local.mapStruct[row.feature_field_id];
			}
			ts = StructNew();
			ts.name = "mapField"&local.index;
			// options for list data
			ts.listLabels =local.labels;
			ts.listValues = local.values;
			ts.listLabelsDelimiter = chr(9);
			ts.listValuesDelimiter = chr(9);
			
			application.zcore.functions.zInputSelectBox(ts);
			
			writeoutput('</td></tr>');
			local.index++;
		}
		writeoutput('</table><br /><br />
		<input type="hidden" name="fieldcount" value="#local.index-1#" />
		<input type="submit" name="submit1" value="Save" /> 
		<input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#'';" />
		</form>');
	}
	</cfscript>
</cffunction>

<cffunction name="copySchemaForm" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;

	application.zcore.functions.zSetPageHelpId("2.11.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	where feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	local.qSchema=db.execute("qSchema");
	if(local.qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid Feature Schema.", form, true);
		application.zcore.functions.zRedirect('/z/feature/admin/feature-schema/index?zsid=#request.zsid#');	
	}
	</cfscript>
	<h2>Copy Schema: #local.qSchema.feature_schema_display_name#</h2>
	<p>Please note that the "select menu" type, and group / inquiries mapping data are not copied.  You will need to verify those are setup correctly after copying this Feature Schema.</p>
	<form class="zFormCheckDirty" action="/z/feature/admin/feature-schema/copySchema" method="post">
		<input type="hidden" name="feature_id" value="#form.feature_id#" />
		<input type="hidden" name="feature_schema_id" value="#form.feature_schema_id#" />
		<table style="border-spacing:0px; padding:5px;">
			<tr>
			<td>New Site</td>
			<td><!--- get sites --->
				<cfscript>
				application.zcore.functions.zGetSiteSelect('newsiteid');
				</cfscript>
			</td>
			</tr>
			<tr>
			<td>New Schema Name</td>
			<td><cfscript>
				ts=StructNew();
				ts.name="newSchemaName";
				ts.size=50;
				application.zcore.functions.zInput_Text(ts);
				</cfscript> (Leave blank to keep it the same)
			</td>
			</tr>
			<!--- <tr>
			<td>Copy Data?</td>
			<td>#application.zcore.functions.zInput_Boolean("copyData")#
			</td>
			</tr> --->
			<tr><td>&nbsp;</td>
			<td>
				<input type="submit" name="submit1" value="Copy" class="z-manager-search-button" /> 
				<input type="button" name="cancel1" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#';" />
			</td></tr>
		</table>
	</form>
</cffunction>


<cffunction name="copySchemaRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="feature_schema_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	var row2=0;
	var ts=0;
	// 
	
	// TODO: we would need to guarantee inquiries_type_id is cloned first by checking for same new on the new site - then i could copy the map table too.  For now, it just removes these.
	row.inquiries_type_id=0;
	row.inquiries_type_id_siteIDType=0;
	row.feature_schema_map_group_id=0;
	row.site_id = arguments.site_id;
	ts=structnew();
	ts.struct=row;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="feature_schema";
	local.newfeatureSchemaId=application.zcore.functions.zInsert(ts);
	arguments.groupStruct[arguments.feature_schema_id]=local.newfeatureSchemaId;
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# 
	where #application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_field")# and 
	feature_field_deleted = #db.param(0)# and
	feature_schema_id = #db.param(arguments.feature_schema_id)# ";
	local.qFields=db.execute("qFields");
	for(row2 in local.qFields){
		row2.site_id=arguments.site_id;
		row2.feature_schema_id=local.newfeatureSchemaId;
		// row2.featureidlist     
		ts=structnew();
		ts.struct=row2;
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="feature_field";
		local.newoptionId=application.zcore.functions.zInsert(ts);
		arguments.typeStruct[row2.feature_field_id]=local.newoptionId;
	}
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	where feature_schema_parent_id = #db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	local.qSchema=db.execute("qSchema");
	for(row in local.qSchema){
		row.feature_schema_parent_id=local.newfeatureSchemaId;
		this.copySchemaRecursive(row.feature_schema_id, arguments.site_id, row, arguments.groupStruct, arguments.typeStruct);
	}
	</cfscript>
</cffunction>

<cffunction name="copySchema" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var row2=0;
	var ts=0;
	var typeStruct={};
	var groupStruct={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	form.feature_id=application.zcore.functions.zso(form, 'feature_id', true);
	form.newSchemaName=application.zcore.functions.zso(form, 'newSchemaName');
	form.newSiteId=application.zcore.functions.zso(form, 'newSiteId', true, 0);
	if(form.newSiteId EQ 0){
		form.newSiteId=request.zos.globals.id;
	}
	form.copyData=application.zcore.functions.zso(form, 'copyData', true, 0);
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true, 0); 
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	where feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	local.qSchema=db.execute("qSchema");
	if(local.qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid Feature Schema.", form, true);
		application.zcore.functions.zRedirect('/z/feature/admin/feature-schema/index?zsid=#request.zsid#');	
	} 
	for(row in local.qSchema){
		if(form.newSchemaName NEQ ""){
			row.feature_schema_variable_name=form.newSchemaName;
			row.feature_schema_display_name=form.newSchemaName;
		}
		this.copySchemaRecursive(form.feature_schema_id, form.newSiteId, row, groupStruct, typeStruct);
	}
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.rebuildFeatureStructCache(form.feature_id, application.zcore); 
	structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		
	application.zcore.status.setStatus(request.zsid, "Feature Schema Copied.");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>
 

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	qSchema=0;
	application.zcore.functions.zSetPageHelpId("2.11.1");
	application.zcore.functions.zstatushandler(request.zsid);
	form.feature_schema_parent_id=application.zcore.functions.zso(form, 'feature_schema_parent_id',true);
	if(form.feature_schema_parent_id NEQ 0){
		db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
		where feature_schema_id=#db.param(form.feature_schema_parent_id)# and 
		feature_schema_deleted = #db.param(0)# and
		#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")#";
		qSchema=db.execute("qSchema", "", 10000, "query", false);
        if(qSchema.recordcount EQ 0){
            application.zcore.functions.z301redirect("/z/feature/admin/feature-schema/index");	
        }
	}
	db.sql="SELECT feature_schema.*, feature.*, if(child1.feature_schema_id IS NULL, #db.param(0)#,#db.param(1)#) hasChildren 
	FROM 
	(#db.table("feature", request.zos.zcoreDatasource)#, 
	#db.table("feature_schema", request.zos.zcoreDatasource)#) 
	LEFT JOIN #db.table("feature_schema", request.zos.zcoreDatasource)# child1 ON 
	feature_schema.feature_schema_id = child1.feature_schema_parent_id and 
	child1.feature_id = feature_schema.feature_id and 
	child1.feature_schema_deleted = #db.param(0)# 
	WHERE 
	feature.feature_id=feature_schema.feature_id and 
	feature.feature_deleted=#db.param(0)# and
	feature_schema.feature_id = #db.param(form.feature_id)# and 
	feature_schema.feature_schema_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# and 
	feature_schema.feature_schema_parent_id = #db.param(form.feature_schema_parent_id)# 
	group by feature_schema.feature_schema_id 
	order by feature_schema.feature_schema_display_name ASC ";
	qProp=db.execute("qProp", "", 10000, "query", false); 
	if(form.feature_schema_parent_id NEQ 0){
		writeoutput('<p><a href="/z/feature/admin/feature-manage/index">Features</a> / <a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">#request.qFeature.feature_display_name#</a> / ');
		curParentId=form.feature_schema_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * 
			from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
			where feature_schema_id = #db.param(curParentId)# and 
			feature_schema_deleted = #db.param(0)# and
			#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")#";
			q1=db.execute("q1", "", 10000, "query", false);
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/feature/admin/feature-schema/index?feature_id=#q1.feature_id#&feature_schema_parent_id=#q1.feature_schema_id#">
				#application.zcore.functions.zFirstLetterCaps(q1.feature_schema_display_name)#</a> / ');
				curParentId=q1.feature_schema_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.feature_schema_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GT 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(form.feature_schema_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qSchema.feature_schema_display_name)&" /");
		}
		writeoutput('</p>');
	}
	</cfscript>
	<p><a href="/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&feature_schema_parent_id=<cfif isquery(qSchema)>#qSchema.feature_schema_id#</cfif>">Add Schema</a> 

	<!---  | <a href="/z/feature/admin/feature-import/importSchema?feature_id=#form.feature_id#">Import Schema</a> --->
	 
	<cfif isquery(qSchema) and qSchema.feature_schema_id NEQ 0>
		| <a href="/z/feature/admin/feature-schema/displaySchemaCode?feature_schema_id=<cfif isquery(qSchema)>#qSchema.feature_schema_id#</cfif>" target="_blank">Display Schema Code</a>
	</cfif>
	<cfif isquery(qSchema)> | <a href="/z/feature/admin/features/manageFields?feature_id=#qSchema.feature_id#&feature_schema_id=#qSchema.feature_schema_id#&feature_schema_parent_id=#qSchema.feature_schema_parent_id#">Manage Fields</a></cfif></p>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>ID</th>
			<th>Schema Name</th>
			<th>Disable Admin</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
		<tr <cfif qProp.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.feature_schema_id#</td>
			<td>#qProp.feature_schema_display_name#</td>
			<td><cfif qProp.feature_schema_disable_admin EQ 1>
					Yes
				<cfelse>
					No
				</cfif>
			</td>
			<td>
				<cfscript>
				isFeatureHost=true;
				if((request.zos.isTestServer and qProp.feature_test_domain NEQ request.zos.globals.domain) or (not request.zos.isTestServer and qProp.feature_live_domain NEQ request.zos.globals.domain)){
					isFeatureHost=false;
				}
				</cfscript>
				<cfif qProp.feature_schema_parent_id EQ 0>
					<a href="/z/feature/admin/features/manageSchema?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#">List/Edit</a>
					<cfif qProp.feature_schema_allow_public NEQ 0>
						|
						<cfif qProp.feature_schema_public_form_url NEQ "">
							<a href="#htmleditformat(qProp.feature_schema_public_form_url)#" target="_blank">Public Form</a> 
						<cfelse>
							 <a href="/z/feature/feature-display/add?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#" target="_blank">Public Form</a>
						</cfif>
					</cfif>
					<!--- |  <a href="/z/feature/admin/features/import?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#">Import</a> --->
				</cfif>
				<cfif variables.allowGlobal and isFeatureHost>
					 | <a href="/z/feature/admin/feature-schema/add?feature_id=#qProp.feature_id#&feature_schema_parent_id=#qProp.feature_schema_id#">Add Child Schema</a> | 
					<a href="/z/feature/admin/features/manageFields?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#&amp;feature_schema_parent_id=#qProp.feature_schema_parent_id#">Fields</a> | 
					<cfif application.zcore.user.checkServerAccess()>
						<a href="/z/feature/admin/feature-schema/export?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#" target="_blank">Export CSV</a> | 
						<a href="/z/feature/admin/feature-schema/reindex?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#" title="Will update Feature Schema table for all records.  Useful after a config change.">Reprocess</a> | 
					</cfif>
	
					<cfif qProp.hasChildren EQ 1>
						<a href="/z/feature/admin/feature-schema/index?feature_id=#qProp.feature_id#&feature_schema_parent_id=#qProp.feature_schema_id#">Child Schemas</a> |
					</cfif>
					<a href="/z/feature/admin/feature-schema/displaySchemaCode?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#&amp;feature_schema_parent_id=#qProp.feature_schema_parent_id#" target="_blank">Display Code</a> |
					
					<cfif qProp.feature_schema_map_fields_type NEQ 0>
						<a href="/z/feature/admin/feature-schema/mapFields?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#">Map Fields</a>
						<cfscript>
						db.sql="select count(feature_map_id) count 
						from #db.table("feature_map", request.zos.zcoreDatasource)# feature_map WHERE 
						feature_map_deleted = #db.param(0)# and
						feature_schema_id = #db.param(qProp.feature_schema_id)# ";
						qMap=db.execute("qMap");
						if(qMap.recordcount EQ 0 or qMap.count EQ 0){
							echo('<strong>(Not Mapped Yet)</strong> ');
						}
						</cfscript> | 
					</cfif>
					<a href="/z/feature/admin/feature-schema/edit?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#&amp;feature_schema_parent_id=#qProp.feature_schema_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Edit</a> | 
					<cfif qProp.feature_schema_parent_id EQ 0>
						<a href="/z/feature/admin/feature-schema/copySchemaForm?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#">Copy</a> | 
					</cfif>
					<a href="/z/feature/admin/feature-schema/delete?feature_id=#qProp.feature_id#&feature_schema_id=#qProp.feature_schema_id#&amp;feature_schema_parent_id=#qProp.feature_schema_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Delete</a>
				</cfif></td>
		</tr>
		</cfloop>
	</table>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var result=0;
	var qCheck=0;
	var theTitle=0;
	var tempLink=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	form.feature_schema_id=application.zcore.functions.zso(form,'feature_schema_id');
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema WHERE 
	feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "group is missing");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid="&request.zsid);
	}
	if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#");
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		// TODO: fix group delete that has no options - it leaves a remnant in memory that breaks the application
		application.zcore.featureCom.deleteSchemaRecursively(form.feature_schema_id, true);
		application.zcore.status.setStatus(request.zsid, "Schema deleted successfully.");
		featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
		featureCacheCom.rebuildFeatureStructCache(form.feature_id, application.zcore); 

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		if(structkeyexists(request.zsession, "feature_schema_return"&form.feature_schema_id) and request.zsession['feature_schema_return'&form.feature_schema_id] NEQ ""){
			tempLink=request.zsession["feature_schema_return"&form.feature_schema_id];
			structdelete(request.zsession,"feature_schema_return"&form.feature_schema_id);
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Schema";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2> Are you sure you want to delete this Schema?<br />
		<br />
		Schema: #qcheck.feature_schema_display_name#<br />
		<br />
		<a href="/z/feature/admin/feature-schema/delete?feature_id=#form.feature_id#&confirm=1&feature_schema_id=#form.feature_schema_id#&zrand=#gettickcount()#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">    
	<cfscript>
	var db=request.zos.queryObject;
	var errors=0;
	var tempLink=0;
	var qCheck=0;
	var ts=0;
	var redirecturl=0;
	var rCom=0;
	var myForm={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	myForm.feature_schema_display_name.required=true;
	myForm.feature_schema_display_name.friendlyName="Display Name";
	myForm.feature_schema_variable_name.required=true;
	myForm.feature_schema_variable_name.friendlyName="Code Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm,request.zsid, true);
	
	form.feature_schema_allow_delete_usergrouplist=application.zcore.functions.zso(form, 'feature_schema_allow_delete_usergrouplist');
	form.feature_schema_user_group_id_list=application.zcore.functions.zso(form, 'feature_schema_user_group_id_list');
	form.feature_schema_change_email_usergrouplist=application.zcore.functions.zso(form, 'feature_schema_change_email_usergrouplist');

	if(form.method EQ "update"){
		db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
		where feature_schema_id = #db.param(form.feature_schema_id)# and 
		feature_schema_deleted = #db.param(0)# and
		#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")#";
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index");
		}
		// force code name to never change after initial creation
		//form.feature_schema_variable_name=qCheck.feature_schema_variable_name;
	}
	if(application.zcore.functions.zso(form, 'feature_schema_enable_unique_url', false, 0) EQ 1){
		if(form.feature_schema_view_cfc_path EQ "" or form.feature_schema_view_cfc_method EQ ""){
			application.zcore.status.setStatus(request.zsid, "View CFC Path and View CFC Method are required when ""Enable Unique Url"" is set to yes.", form, true);
			errors=true;
		}
	}

	if(form.feature_schema_parent_id NEQ "" and form.feature_schema_parent_id NEQ 0){
		form.feature_schema_enable_new_button=0;
	}  
	form.site_id=request.zos.globals.id;
	if(form.feature_id EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature is required", form, true);
		errors=true;
	}
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/edit?feature_schema_id=#form.feature_schema_id#&feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid=#request.zsid#");
		}
	} 

	fileName=application.zcore.functions.zUploadFileToDb("feature_schema_preview_image", application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/', 
			'feature_schema', 'feature_schema_id', 'feature_schema_preview_image_delete', request.zos.zcoreDatasource, 'feature_schema_preview_image');	
	if(fileName NEQ ""){
		form.feature_schema_preview_image=fileName;
	}
	
	if(form.inquiries_type_id NEQ ""){
		local.arrTemp=listToArray(form.inquiries_type_id, '|');
		form.inquiries_type_id=local.arrTemp[1];
		form.inquiries_type_id_siteIDType=application.zcore.functions.zGetSiteIdType(local.arrTemp[2]);
	}
	 
	ts=StructNew();
	ts.table="feature_schema";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.feature_schema_id = application.zcore.functions.zInsert(ts);
		if(form.feature_schema_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Schema couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Schema added successfully.");
			redirecturl=("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Schema failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/edit?feature_schema_id=#form.feature_schema_id#&feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Schema updated successfully.");
			redirecturl=("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid="&request.zsid);
		}
	}
	
	
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.updateSchemaCacheBySchemaId(form.feature_id, form.feature_schema_id);
	structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	
	if(form.method EQ "insert" and structkeyexists(request.zsession, "feature_schema_return") and request.zsession['feature_schema_return'] NEQ ""){
		tempLink=request.zsession["feature_schema_return"];
		structdelete(request.zsession,"feature_schema_return");
		application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
	}else if(structkeyexists(request.zsession, "feature_schema_return"&form.feature_schema_id)){
		tempLink=request.zsession["feature_schema_return"&form.feature_schema_id];
		structdelete(request.zsession,"feature_schema_return"&form.feature_schema_id);
		if(tempLink NEQ ""){
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}
	}
	application.zcore.functions.zRedirect(redirecturl);
	</cfscript>
</cffunction>


<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>


<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qRate=0;
	var theTitle=0;
	var qApp=0;
	var qG=0;
	var htmlEditor=0;
	var selectStruct=0;
	var ts=0;
	application.zcore.functions.zSetPageHelpId("2.11.2");
	
	var currentMethod=form.method;
	variables.init();
	form.feature_schema_id=application.zcore.functions.zso(form,'feature_schema_id',true);
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# ";
	qRate=db.execute("qRate");
	if(structkeyexists(form, 'feature_schema_parent_id')){
		application.zcore.functions.zQueryToStruct(qRate,form,'feature_id,feature_schema_id,feature_schema_parent_id'); 
	}else{
		application.zcore.functions.zQueryToStruct(qRate,form,'feature_id,feature_schema_id'); 
	}
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Schema";
	}else{
		theTitle="Add Schema";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	</cfscript> 
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/feature/admin/feature-schema/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?feature_schema_id=#form.feature_schema_id#" method="post" enctype="multipart/form-data">

		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Public Form", "Landing Page", "Email & Mapping"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-feature-schema-edit");
		cancelURL="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#"; 
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  style="border-spacing:0px;" class="table-list">
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Feature *</th>
				<td><cfscript>
				db.sql="SELECT * 
				FROM #db.table("feature", request.zos.zcoreDatasource)# 
				WHERE
				feature.feature_deleted = #db.param(0)# and  
				#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature")#
				order by feature.feature_display_name ASC ";
				qFeature=db.execute("qFeature"); 
				selectStruct=structnew();
				selectStruct.name="feature_id"; 
				selectStruct.onchange="";
				selectStruct.hideSelect=true;
				selectStruct.query=qFeature;
 				selectStruct.queryLabelField = "feature_display_name";
 				selectStruct.queryValueField = "feature_id";
				application.zcore.functions.zInputSelectBox(selectStruct); 
				</cfscript> 
				</td>
			</tr>
			<cfscript>
				db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
			#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# and 
			feature_schema_deleted = #db.param(0)# ";
			if(form.feature_schema_id NEQ 0 and form.feature_schema_id NEQ ""){
				db.sql&=" and feature_schema_id <> #db.param(form.feature_schema_id)# and 
				feature_schema_parent_id <> #db.param(form.feature_schema_id)# ";
			}
			db.sql&=" ORDER BY feature_schema_display_name ";
			qG=db.execute("qG", "", 10000, "query", false); 
			</cfscript>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Schema","member.feature-schema.edit feature_schema_parent_id")#</th>
				<td><cfscript>
				arrData=[];
				for(row in qG){
					arrayAppend(arrData, { 
						parent:row.feature_schema_parent_id, 
						label:row.feature_schema_display_name, 
						value:row.feature_schema_id
					});
				} 
				rs=application.zcore.functions.zGetRecursiveLabelValueForSelectBox(arrData);
				selectStruct=structnew();
				selectStruct.name="feature_schema_parent_id"; 
				selectStruct.onchange="doParentCheck();";
				if(form.feature_schema_id NEQ ""){
					selectStruct.onchange="if(this.options[this.selectedIndex].value=='#form.feature_schema_id#'){alert('You can\'t select the same group you are editing.');this.selectedIndex=0;}"&selectStruct.onchange;
				}
				selectStruct.listValuesDelimiter=chr(9);
				selectStruct.listLabelsDelimiter=chr(9);
				selectStruct.listLabels=arrayToList(rs.arrLabel, chr(9));
				selectStruct.listValues=arrayToList(rs.arrValue, chr(9)); 
				application.zcore.functions.zInputSelectBox(selectStruct);
				/*
				selectStruct=structnew();
				selectStruct.name="feature_schema_parent_id";
				selectStruct.query = qG;
				selectStruct.onchange="doParentCheck();";
				selectStruct.queryLabelField = "feature_schema_display_name";
				selectStruct.queryValueField = "feature_schema_id";
				application.zcore.functions.zInputSelectBox(selectStruct);*/
				</cfscript><br />
				<strong>Warning:</strong> If user data exists for this record, you should not change the Parent Schema, because the user data's parent group field will not be automatically updated.  You'd have to update the database and cache manually if you want to do this anyway. 
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Variable Name","member.feature-schema.edit feature_schema_variable_name")#</th>
				<td>
					<input name="feature_schema_variable_name" id="feature_schema_variable_name" size="50" type="text" value="#htmleditformat(form.feature_schema_variable_name)#"  onkeyup="var d1=document.getElementById('feature_schema_display_name');d1.value=this.value;" onblur="var d1=document.getElementById('feature_schema_display_name');d1.value=this.value;" maxlength="100" />
					<input type="hidden" name="feature_schema_type" value="1" />
				<cfif currentMethod NEQ "add">
					<br><br><strong>WARNING:</strong> You should not change the "Variable Name" on a live site unless you are ready to deploy the corrections to the source code immediately.  Editing the "Name" will also prevent the Sync feature from working.  Make sure to communicate with the other developers if you change the "Variable Name".  Any code that refers to this name will start throwing undefined errors immediately after changing this.
				</cfif></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Display Name","member.feature-schema.edit feature_schema_display_name")#</th>
				<td><input name="feature_schema_display_name" id="feature_schema_display_name" size="50" type="text" value="#htmleditformat(form.feature_schema_display_name)#" maxlength="100" />
				</td>
			</tr>
				
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Menu Name","member.feature-schema.edit feature_schema_menu_name")#</th>
					<td><div  id="groupMenuNameId">
							<input name="feature_schema_menu_name" id="feature_schema_menu_name" size="50" type="text" value="#htmleditformat(form.feature_schema_menu_name)#" maxlength="100" /><br />
							(Put this group in a different manager menu - default is Custom)</div>
						<div  id="groupMenuNameId2" style="display:none;">Disabled - Only allowed on the root groups.</div></td>
				</tr> 
				<cfscript>
				if(form.feature_schema_admin_paging_limit EQ ""){
					form.feature_schema_admin_paging_limit=0;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Child Limit","member.feature-schema.edit feature_schema_limit")#</th>
					<td><input type="number" name="feature_schema_limit" id="feature_schema_limit" value="#htmleditformat(form.feature_schema_limit)#" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("User Child Limit","member.feature-schema.edit feature_schema_user_child_limit")#</th>
					<td><input type="number" name="feature_schema_user_child_limit" id="feature_schema_user_child_limit" value="#htmleditformat(form.feature_schema_user_child_limit)#" /></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Sorting","member.feature-schema.edit feature_schema_enable_sorting")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_sorting")#</td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Image Library?","member.feature-schema.edit feature_schema_enable_image_library")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_image_library")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Admin?","member.feature-schema.edit feature_schema_disable_admin")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_disable_admin")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Archiving?","member.feature-schema.edit feature_schema_enable_archiving")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_archiving")#</td>
				</tr>
				<cfif form.feature_schema_parent_id EQ 0> 
					<tr>
						<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable New Button","member.feature-schema.edit feature_schema_enable_new_button")#</th>
						<td>
							#application.zcore.functions.zInput_Boolean("feature_schema_enable_new_button")# 
							(Places this group in the Create New button in manager header)
					</td>
					</tr>
				</cfif>

				
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Admin Paging Limit</th>
					<td><input name="feature_schema_admin_paging_limit" id="feature_schema_admin_paging_limit" type="number" value="#htmleditformat(form.feature_schema_admin_paging_limit)#"  /> (Number of records to display in admin until showing page navigation)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Form Description:","member.feature-schema.edit feature_schema_form_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "feature_schema_form_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'feature_schema_form_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Form Bottom Description:","member.feature-schema.edit feature_schema_bottom_form_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "feature_schema_bottom_form_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'feature_schema_bottom_form_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("List View Description:","member.feature-schema.edit feature_schema_list_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "feature_schema_list_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'feature_schema_list_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Field","member.feature-schema.edit feature_schema_parent_field")#</th>
					<td><input type="text" name="feature_schema_parent_field" id="feature_schema_parent_field" value="#htmleditformat(form.feature_schema_parent_field)#" /> (Optional, enables indented heirarchy on list view)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable List Recurse","member.feature-schema.edit feature_schema_enable_list_recurse")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_list_recurse")# (Displays this group's records on parent groups manager list view)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Export?","member.feature-schema.edit feature_schema_disable_export")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_disable_export")#</td>
				</tr>

				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Versioning?","member.feature-schema.edit feature_schema_enable_versioning")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_versioning")# (This enables deep copy and changing between versions of a record. Changing versions doesn't support recursion.)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Max ## of Versions","member.feature-schema.edit feature_schema_version_limit")#</th>
					<td><input name="feature_schema_version_limit" id="feature_schema_version_limit" size="50" type="text" value="#htmleditformat(application.zcore.functions.zso(form, 'feature_schema_version_limit', true))#" maxlength="100" />
							</td></tr>

				
				<cfscript>
				if(form.feature_schema_enable_cache EQ ""){
					form.feature_schema_enable_cache=1;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Memory Caching","member.feature-schema.edit feature_schema_enable_cache")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_cache")# (Warning: "Yes" will result in very slow manager performance if this group has many records.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable URL Caching","member.feature-schema.edit feature_schema_enable_partial_page_caching")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_partial_page_caching")# (Incomplete - will store rendered page in memory)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Help Description:","member.feature-schema.edit feature_schema_help_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "feature_schema_help_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'feature_schema_help_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 350;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Change CFC Path","member.feature-schema.edit feature_schema_change_cfc_path")#</th>
					<td><input type="text" name="feature_schema_change_cfc_path" id="feature_schema_change_cfc_path" value="#htmleditformat(form.feature_schema_change_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)<br /><br />

					Update Method: <input type="text" name="feature_schema_change_cfc_update_method" id="feature_schema_change_cfc_update_method" value="#htmleditformat(form.feature_schema_change_cfc_update_method)#" /><br /><br />
					Delete Method: <input type="text" name="feature_schema_change_cfc_delete_method" id="feature_schema_change_cfc_delete_method" value="#htmleditformat(form.feature_schema_change_cfc_delete_method)#" /><br /><br />
					Sort Method: <input type="text" name="feature_schema_change_cfc_sort_method" id="feature_schema_change_cfc_sort_method" value="#htmleditformat(form.feature_schema_change_cfc_sort_method)#" /><br />
					 (Each function should exist in the CFC with access="public")<br><br>
					<cfscript>
					if(form.feature_schema_change_cfc_children EQ ""){
						form.feature_schema_change_cfc_children=0;
					}
					</cfscript>
					 Execute on child record changes? 
					 #application.zcore.functions.zInput_Boolean("feature_schema_change_cfc_children")#
					</td>
				</tr>  
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">
						#application.zcore.functions.zOutputHelpToolTip("Allow Locked Delete?","member.feature-schema.edit feature_schema_enable_locked_delete")#
					</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_locked_delete")# 
						(When a record is locked, setting this to yes will allow a non-developer to delete the record.)
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Merge Interface?","member.feature-schema.edit feature_schema_enable_merge_interface")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_merge_interface")#</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Merge Group","member.feature-schema.edit feature_schema_merge_group_id")#</th>
					<td><cfscript>

					selectStruct=structnew();
					selectStruct.name="feature_schema_merge_group_id"; 
					selectStruct.onchange="doParentCheck();";
					if(form.feature_schema_id NEQ ""){
						selectStruct.onchange="if(this.options[this.selectedIndex].value=='#form.feature_schema_id#'){alert('You can\'t select the same group you are editing.');this.selectedIndex=0;}"&selectStruct.onchange;
					}
					selectStruct.listValuesDelimiter=chr(9);
					selectStruct.listLabelsDelimiter=chr(9);
					selectStruct.listLabels=arrayToList(rs.arrLabel, chr(9));
					selectStruct.listValues=arrayToList(rs.arrValue, chr(9)); 
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript> (Will override the child groups to the selected group.  Leave blank to use current group)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Merge Child Title Field","member.feature-schema.edit feature_schema_merge_title_field")#</th>
					<td><input type="text" name="feature_schema_merge_title_field" id="feature_schema_parent_field" value="#htmleditformat(form.feature_schema_merge_title_field)#" /></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Merge Child Image Field","member.feature-schema.edit feature_schema_merge_image_field")#</th>
					<td><input type="text" name="feature_schema_merge_image_field" id="feature_schema_merge_image_field" value="#htmleditformat(form.feature_schema_merge_image_field)#" /></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Merge Category","member.feature-schema.edit feature_schema_category")#</th>
					<td><input type="text" name="feature_schema_category" id="feature_schema_category" value="#htmleditformat(form.feature_schema_category)#" /></td>
				</tr>

				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Merge Preview Image","member.feature-schema.edit feature_schema_preview_image")#</th>
					<td><cfscript>
						var ts3=StructNew();
						ts3.name="feature_schema_preview_image";
						ts3.allowDelete=true;
						if(form.feature_schema_preview_image NEQ ""){
							ts3.downloadPath="/zupload/feature-options/";
						}
						application.zcore.functions.zInput_file(ts3);
						</cfscript></td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Public Form")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form Title","member.feature-schema.edit feature_schema_public_form_title")#</th>
					<td><input name="feature_schema_public_form_title" id="feature_schema_public_form_title" size="50" type="text" value="#htmleditformat(form.feature_schema_public_form_title)#" maxlength="100" />
							</td></tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Public Form?","member.feature-schema.edit feature_schema_allow_public")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_allow_public")#

					<script type="text/javascript">
					zArrDeferredFunctions.push(function(){
						$("##feature_schema_allow_public1").bind("click", function(){
							$("##feature_schema_enable_cache0")[0].checked=true;
						});
						$("##feature_schema_allow_public0").bind("click", function(){
							$("##feature_schema_enable_cache1")[0].checked=true;
						});
					});
					</script>
					</td>
				</tr>
				<tr>
					<th>Newsletter Auto Opt In?</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_newsletter_opt_in_form")#</td>
				</tr>
				<tr>
					<th>Require Captcha<br />For Public Data Entry:</th>
					<td>
					#application.zcore.functions.zInput_Boolean("feature_schema_enable_public_captcha")#
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Data Entry<br />For User Schemas","member.feature-schema.edit feature_schema_user_group_id_list")#</th>
					<td>
					<cfscript>
					db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
					WHERE site_id=#db.param(request.zos.globals.id)# and 
					user_group_deleted = #db.param(0)# 
					ORDER BY user_group_name asc"; 
					var qSchema2=db.execute("qSchema2", "", 10000, "query", false); 
					ts = StructNew();
					ts.name = "feature_schema_user_group_id_list";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qSchema2;
					ts.queryLabelField = "user_group_friendly_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'feature_schema_user_group_id_list'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Delete<br />For User Schemas","member.feature-schema.edit feature_schema_allow_delete_usergrouplist")#</th>
					<td>
					<cfscript> 
					ts = StructNew();
					ts.name = "feature_schema_allow_delete_usergrouplist";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qSchema2;
					ts.queryLabelField = "user_group_friendly_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'feature_schema_allow_delete_usergrouplist'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> (Enabling delete, will force enable delete of all child groups too)</td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Changes Email Alert<br />For User Schemas","member.feature-schema.edit feature_schema_change_email_usergrouplist")#</th>
					<td>
					<cfscript> 
					ts = StructNew();
					ts.name = "feature_schema_change_email_usergrouplist";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qSchema2;
					ts.queryLabelField = "user_group_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'feature_schema_change_email_usergrouplist'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> (Email will be sent when custom record data is changed by these user groups)</td>
				</tr>
				<cfif application.zcore.functions.zso(form, 'feature_schema_parent_id', true) EQ 0>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable User Dashboard Admin","member.feature-schema.edit feature_schema_enable_user_dashboard_admin")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_user_dashboard_admin")# | If you select yes, you must specify the User Id Field below.</td>
				</tr>
	
					<tr>
						<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("User Id Field","member.feature-schema.edit feature_schema_user_id_field")#</th>
						<td>
							<input name="feature_schema_user_id_field" id="feature_schema_user_id_field" size="50" type="text" value="#htmleditformat(form.feature_schema_user_id_field)#" maxlength="50" />
						</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Enable Alternate Admin Layout","member.feature-schema.edit feature_schema_subgroup_alternate_admin")#</th>
						<td>#application.zcore.functions.zInput_Boolean("feature_schema_subgroup_alternate_admin")#</td>
					</tr>
				</cfif>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Require Approval#chr(10)#of Public Data?","member.feature-schema.edit feature_schema_enable_approval")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_approval")#</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form URL","member.feature-schema.edit feature_schema_public_form_url")#</th>
					<td>
							<input name="feature_schema_public_form_url" id="feature_schema_public_form_url" size="50" type="text" value="#htmleditformat(form.feature_schema_public_form_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Thank You URL","member.feature-schema.edit feature_schema_public_thankyou_url")#</th>
					<td>
							<input name="feature_schema_public_thankyou_url" id="feature_schema_public_thankyou_url" size="50" type="text" value="#htmleditformat(form.feature_schema_public_thankyou_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Session Form Token","member.feature-schema.edit feature_schema_public_thankyou_token")#</th>
					<td>
							<input name="feature_schema_public_thankyou_token" id="feature_schema_public_thankyou_token" size="50" type="text" value="#htmleditformat(form.feature_schema_public_thankyou_token)#" maxlength="100" /> <br />(The thank you url will have this token added to it with a unique value that will also be added to the user's session memory.  Comparing these 2 values on the server side will allow you to show content to only users that have submitted the form.  I.e. allow them to download a file, etc.)
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Ajax?","member.feature-schema.edit feature_schema_ajax_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_ajax_enabled")# <br />(Yes will make public form insertions use ajax instead, but not for updating existing records.)</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Landing Page")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Enable Unique URL</th>
					<td>
				<cfif 50 NEQ 0>
					#application.zcore.functions.zInput_Boolean("feature_schema_enable_unique_url")#
				<cfelse>
					Field group URL ID must be set in server manager to use this feature.
				</cfif></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Home Page?</th>
					<td> 
					#application.zcore.functions.zInput_Boolean("feature_schema_is_home_page")# | Yes, will force the URL to be "/".   Note: you may have trouble getting this to work with root.index, you can move index.cfc to mvc/controller/index.cfc to fix the problem.  The routing system gives higher precedence to root.index, so you have to remove it.
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Meta Tags?","member.feature-schema.edit feature_schema_enable_meta")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_enable_meta")#</td>
				</tr>
				<!--- 
				This field doesn't do anything yet!
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Embedding?","member.feature-schema.edit feature_schema_embed")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_embed")#</td>
				</tr> --->
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Embed HTML Code:","member.feature-schema.edit feature_schema_code")#</th>
					<td><textarea name="feature_schema_code" id="feature_schema_code" cols="100" rows="10">#htmleditformat(form.feature_schema_code)#</textarea></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Path","member.feature-schema.edit feature_schema_view_cfc_path")#</th>
					<td><input type="text" name="feature_schema_view_cfc_path" id="feature_schema_view_cfc_path" value="#htmleditformat(form.feature_schema_view_cfc_path)#" /> <br />(Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Method","member.feature-schema.edit feature_schema_view_cfc_method")#</th>
					<td><input type="text" name="feature_schema_view_cfc_method" id="feature_schema_view_cfc_method" value="#htmleditformat(form.feature_schema_view_cfc_method)#" /><br />(A function name in the CFC with access="remote")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Site Map?","member.feature-schema.edit feature_schema_disable_site_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_disable_site_map")#</td>
				</tr>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="feature_schema_public_searchable" id="feature_schema_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'feature_schema_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="feature_schema_public_searchable" id="feature_schema_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'feature_schema_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Path","member.feature-schema.edit feature_schema_search_index_cfc_path")#</th>
					<td><input type="text" name="feature_schema_search_index_cfc_path" id="feature_schema_search_index_cfc_path" value="#htmleditformat(form.feature_schema_search_index_cfc_path)#" /><br />
					(Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Method","member.feature-schema.edit feature_schema_search_index_cfc_method")#</th>
					<td><input type="text" name="feature_schema_search_index_cfc_method" id="feature_schema_search_index_cfc_method" value="#htmleditformat(form.feature_schema_search_index_cfc_method)#" /><br /> (A function name in the CFC with access="public")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Path","member.feature-schema.edit feature_schema_search_result_cfc_path")#</th>
					<td><input type="text" name="feature_schema_search_result_cfc_path" id="feature_schema_search_result_cfc_path" value="#htmleditformat(form.feature_schema_search_result_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Method","member.feature-schema.edit feature_schema_search_result_cfc_method")#</th>
					<td><input type="text" name="feature_schema_search_result_cfc_method" id="feature_schema_search_result_cfc_method" value="#htmleditformat(form.feature_schema_search_result_cfc_method)#" /> <br />(A function name in the CFC with access="public")</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Email & Mapping")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Fields Type","member.feature-schema.edit feature_schema_map_fields_type")#</th>
					<td><cfscript>
					form.feature_schema_map_fields_type=application.zcore.functions.zso(form, 'feature_schema_map_fields_type', true, 0);
					ts = StructNew();
					ts.name = "feature_schema_map_fields_type";
					ts.listLabels = "Disabled,Inquiries";
					ts.listValues = "0,1";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<!--- <tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map Schema","member.feature-schema.edit feature_map_group_id")#</th>
					<td><cfscript>
					selectStruct=structnew();
					selectStruct.name="feature_map_group_id";
					selectStruct.query = qG;
					selectStruct.onchange="doParentCheck();";
					selectStruct.queryLabelField = "feature_schema_display_name";
					selectStruct.queryValueField = "feature_schema_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr> --->
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map To Lead Type","member.feature-schema.edit inquiries_type_id")#</th>
					<td><cfscript>
					if(form.inquiries_type_id_siteIDType NEQ "" and form.inquiries_type_id_siteIDType NEQ 0){
						form.inquiries_type_id=form.inquiries_type_id&"|"&application.zcore.functions.zGetSiteIDFromSiteIdType(form.inquiries_type_id_siteIDType);
					}
					db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
					WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
					inquiries_type_deleted = #db.param(0)# ";
					if(not application.zcore.app.siteHasApp("listing")){
						db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
					}
					if(not application.zcore.app.siteHasApp("rental")){
						db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
					}
					db.sql&="ORDER BY inquiries_type_name ASC ";
					local.qType=db.execute("qType");
					selectStruct=structnew();
					selectStruct.name="inquiries_type_id";
					selectStruct.query = local.qType;
					selectStruct.queryLabelField = "inquiries_type_name";
					selectStruct.queryParseValueVars=true;
					selectStruct.queryValueField = "##inquiries_type_id##|##site_id##";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Insert Type","member.feature-schema.edit feature_schema_map_insert_type")#</th>
					<td><cfscript>
					form.feature_schema_map_insert_type=application.zcore.functions.zso(form, 'feature_schema_map_insert_type', true, 0);
					ts = StructNew();
					ts.name = "feature_schema_map_insert_type";
					ts.listLabels = "Disabled,Immediately on Insert,After Manual Approval";
					ts.listValues = "0,1,2";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Delete On Map?","member.feature-schema.edit feature_schema_delete_on_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_delete_on_map")# (Set this to no when a file upload field is used on the form.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Lead Routing?","member.feature-schema.edit feature_schema_lead_routing_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_lead_routing_enabled")# | If Yes, an email will be generated when a new record is inserted.</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Detailed Lead Email?","member.feature-schema.edit feature_schema_disable_detailed_lead_email")#</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_schema_disable_detailed_lead_email")# | If Yes, a simple lead email will be sent excluding any personal information from the contact.</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Path","member.feature-schema.edit feature_schema_email_cfc_path")#</th>
					<td><input type="text" name="feature_schema_email_cfc_path" id="feature_schema_email_cfc_path" value="#htmleditformat(form.feature_schema_email_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Method","member.feature-schema.edit feature_schema_email_cfc_method")#</th>
					<td><input type="text" name="feature_schema_email_cfc_method" id="feature_schema_email_cfc_method" value="#htmleditformat(form.feature_schema_email_cfc_method)#" /><br /> (A function name in the CFC with access="public")</td>
				</tr>
				<tr>
					<th>Custom Email<br />Fields</th>
					<td>
						<p>If you need to have custom routing that can't be handled by the CMS, you should answer No and Yes below and define the Email CFC above.  The Email CFC must send the email itself.</p>
						<p>If the custom email cfc path/method feature is used, the regular lead email will be disabled.</p>
					<p>Do you want to force the regular email to be sent as well?</p>
					<p>#application.zcore.functions.zInput_Boolean("feature_schema_force_send_default_email")#</p>
					<p>Disable routing for the custom email? (You will need to call application.zcore.email.send yourself if you want to send an email)</p>
					<p>#application.zcore.functions.zInput_Boolean("feature_schema_disable_custom_routing")#</p></td>
				</tr>
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()# 
	</form>
	<script type="text/javascript">
		/* <![CDATA[ */ 
		var firstLoad11=true;
		function doParentCheck(){ 
			var groupMenuName=document.getElementById("groupMenuNameId");
			var groupMenuName2=document.getElementById("groupMenuNameId2");
			var groupMenuNameField=document.getElementById("feature_schema_menu_name");
			if(groupMenuNameField == null){
				return;
			}
			if(firstLoad11){
				firstLoad11=false; 
			}
			var a=document.getElementById("feature_schema_parent_id");
			if(a.selectedIndex != 0){
				groupMenuNameField.value='';
				groupMenuName.style.display="none";
				groupMenuName2.style.display="block";
 
			}else{
				groupMenuName.style.display="block";
				groupMenuName2.style.display="none";
			}
		}
		zArrDeferredFunctions.push(function(){doParentCheck();});
		/* ]]> */
		</script>
</cffunction>
</cfoutput>
</cfcomponent>
