<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var theTitle=0;
	variables.allowGlobal=false; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	if(application.zcore.user.checkServerAccess()){
		variables.allowGlobal=true;
		variables.siteIdList="'0','"&request.zos.globals.id&"'";
	} 
	if(structkeyexists(form, 'returnURL')){
		request.zsession["site_option_group_return"&application.zcore.functions.zso(form, 'site_option_group_id')]=application.zcore.functions.zso(form, 'returnURL');
	}
	
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		application.zcore.functions.z301Redirect('/member/');
	}
	theTitle="Manage Site Option Groups";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	
	this.displayoptionAdminNav();
	</cfscript>
</cffunction>


<cffunction name="displayoptionAdminNav" access="public" localmode="modern">
	<cfscript>
	
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id',false,0);
	if(form.site_option_app_id NEQ 0){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	}
	</cfscript>
	<div class="z-float z-mb-10">
		DevTools:
		<cfif application.zcore.user.checkServerAccess()>
			<a href="/z/admin/site-options/searchReindex">Search Reindex</a> | 
		</cfif>
		<a href="/z/admin/sync/index">Sync</a> | 
		<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#">Options</a> | 
		<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Groups</a> | 
		Add: <a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Option</a> | 
		<a href="/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Group</a>
	</div>
</cffunction>
<!--- 
<cffunction name="generateDebugGroupCode" access="public" localmode="modern">
	<cfargument name="groupId" type="numeric" required="yes"> 
	<cfargument name="parentIndex" type="numeric" required="yes"> 
	<cfargument name="parentGroupId" type="numeric" required="yes"> 
	<cfargument name="sharedStruct" type="struct" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	ss=arguments.sharedStruct;
	if(not structkeyexists(ss, 'curIndex')){
		ss.curIndex=arguments.parentIndex;
	}else{
		ss.curIndex++;
	}
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	indent="";
	for(i=1;i LTE arguments.depth;i++){
		indent&=chr(9);
	}

	for(i in t9.optionGroupLookup){
		groupStruct=t9.optionGroupLookup[i];
		if(arguments.groupID NEQ 0 and arguments.groupID NEQ groupStruct.site_option_group_id){
			continue;
		}
		if(arguments.parentGroupID NEQ groupStruct.site_option_group_parent_id){ 	
			continue;
		}  
		if(structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
			c=t9.optionGroupFieldLookup[groupStruct.site_option_group_id]; 
			jsonStruct={};
			for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
				optionStruct=t9.optionLookup[n];

				typeCFC=application.zcore.siteOptionCom.getTypeCFC(optionStruct.site_option_type_id);
				debugValue=typeCFC.getDebugValue(optionStruct);
				jsonStruct[optionStruct.site_option_name]=debugValue; 
			} 
			if(groupStruct.site_option_group_enable_unique_url EQ 1){
				jsonStruct.__url='##';
			}
			if(groupStruct.site_option_group_enable_approval EQ 1){
				jsonStruct.__approved=1;
			}
			if(groupStruct.site_option_group_enable_image_library EQ 1){
				jsonStruct.__image_library_id=0;
			}
			echo('<cfscript>arr#ss.curIndex#='&replace(serializeJson(jsonStruct), '##', '####', 'all')&';</cfscript>'&chr(10));
			/*echo(indent&'<cfloop from="1" to="##arrayLen(arr#ss.curIndex#)##" index="i#ss.curIndex#">#chr(10)&indent&chr(9)#<cfscript>curStruct#ss.curIndex#=arr#ss.curIndex#[i#ss.curIndex#];</cfscript>#chr(10)#');
			savecontent variable="childOutput"{
				generateDebugGroupCode(0, ss.curIndex, groupStruct.site_option_group_id, arguments.sharedStruct, arguments.depth+2);
			}
			childOutput=trim(childOutput);
			if(len(childOutput)){
				echo(chr(10)&indent&chr(9)&chr(9)&childOutput&chr(10));
			}
			echo(indent&'</cfloop><hr />'&chr(10));*/
		}
		ss.curIndex++;
	}
	</cfscript>
</cffunction> --->

<cffunction name="generateGroupCode" access="public" localmode="modern">
	<cfargument name="groupId" type="numeric" required="yes"> 
	<cfargument name="parentIndex" type="numeric" required="yes"> 
	<cfargument name="parentGroupId" type="numeric" required="yes"> 
	<cfargument name="sharedStruct" type="struct" required="yes"> 
	<cfargument name="depth" type="numeric" required="yes"> 
	<cfargument name="disableLoop" type="boolean" required="yes"> 
	<cfargument name="debugMode" type="boolean" required="yes"> 
	<cfargument name="disableDebugOutput" type="boolean" required="yes">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	ss=arguments.sharedStruct;
	if(not structkeyexists(ss, 'curIndex')){
		ss.curIndex=arguments.parentIndex;
	}else{
		ss.curIndex++;
	}
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	indent="";
	for(i=1;i LTE arguments.depth;i++){
		indent&=chr(9);
	}


	for(i in t9.optionGroupLookup){
		groupStruct=t9.optionGroupLookup[i];
		groupName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(groupStruct.site_option_group_name), " ", "", "all"), "");
		if(isNumeric(left(groupName, 1))){
			groupName="Group"&groupName;
		}
		groupNameInstance=lcase(left(groupName, 1))&removeChars(groupName,1,1);
		if(arguments.groupID NEQ 0 and arguments.groupID NEQ groupStruct.site_option_group_id){
			continue;
		}
		if(arguments.parentGroupID NEQ groupStruct.site_option_group_parent_id){ 	
			continue;
		}
		//echo(chr(10)&indent&"<h2>Group: "&groupStruct.site_option_group_display_name&'</h2>'&chr(10));
		echo(indent&'<cfscript>#chr(10)#');
		if(not arguments.disableLoop and not arguments.debugMode){
			if(not arguments.disableDebugOutput){
				echo(indent&'// comment out when debugging#chr(10)#');
			}
			if(groupStruct.site_option_group_parent_id NEQ 0){
				parentGroupStruct=t9.optionGroupLookup[groupStruct.site_option_group_parent_id];
				parentGroupName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(parentGroupStruct.site_option_group_name), " ", "", "all"), "");
				if(isNumeric(left(parentGroupName, 1))){
					parentGroupName="Group"&parentGroupName;
				}
				parentGroupNameInstance=lcase(left(parentGroupName, 1))&removeChars(parentGroupName,1,1);
				echo(indent&'arr#groupName#=application.zcore.siteOptionCom.optionGroupStruct("#groupStruct.site_option_group_name#", 0, request.zos.globals.id, #parentGroupNameInstance#);'&chr(10));
			}else{
				echo(indent&'arr#groupName#=application.zcore.siteOptionCom.optionGroupStruct("#groupStruct.site_option_group_name#");'&chr(10));
			} 
		}
		if(not arguments.disableDebugOutput and structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
			jsonStruct={};
			for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
				optionStruct=t9.optionLookup[n];

				typeCFC=application.zcore.siteOptionCom.getTypeCFC(optionStruct.site_option_type_id);
				debugValue=typeCFC.getDebugValue(optionStruct);
				jsonStruct[optionStruct.site_option_name]=debugValue; 
			} 
			if(groupStruct.site_option_group_enable_unique_url EQ 1){
				jsonStruct.__url='##';
			}
			if(groupStruct.site_option_group_enable_approval EQ 1){
				jsonStruct.__approved=1;
			}
			if(groupStruct.site_option_group_enable_image_library EQ 1){
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
		if(structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
			c=t9.optionGroupFieldLookup[groupStruct.site_option_group_id];
			fieldStruct={};
			for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
				optionStruct=t9.optionLookup[n];
				f=indent&chr(9)&'###groupNameInstance#["'&replace(replace(optionStruct.site_option_name, "##", "####", "all"), '"', '""', 'all')&'"]##'&chr(10);

				ts={
					html: f,
					sort: optionStruct.site_option_sort
				};
				fieldStruct[n]=ts;
			}
			arrKey=structsort(fieldStruct, "numeric", "asc", "sort");
			for(n2=1;n2<=arraylen(arrKey);n2++){
				n=arrKey[n2];
				echo(fieldStruct[n].html);
			}
			if(groupStruct.site_option_group_enable_unique_url EQ 1){
				echo(indent&chr(9)&'<a href="###groupNameInstance#.__url##">View</a>'&chr(10));
			}
			if(groupStruct.site_option_group_enable_approval EQ 1){
				echo(indent&chr(9)&'<cfif #groupNameInstance#.__approved>Approved<cfelse>Not Approved</cfif>'&chr(10));
			}
			if(groupStruct.site_option_group_enable_image_library EQ 1){
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
				generateGroupCode(0, ss.curIndex, groupStruct.site_option_group_id, arguments.sharedStruct, arguments.depth+2, false, arguments.debugMode, arguments.disableDebugOutput);
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
	<cfargument name="groupId" type="numeric" required="yes">  
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	 
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData; 


	groupStruct=t9.optionGroupLookup[arguments.groupId];
 
	tableName=lcase(application.zcore.functions.zURLEncode(groupStruct.site_option_group_name, "_"));
 
	echo("CREATE TABLE `#tableName#` (
`#tableName#_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
`site_x_option_group_set_id` int(11) unsigned NOT NULL DEFAULT '0',
`site_option_group_id` int(11) unsigned NOT NULL DEFAULT '0',
`site_x_option_group_set_sort` int(11) unsigned NOT NULL DEFAULT '0',
`site_x_option_group_set_active` char(1) NOT NULL DEFAULT '0',
`site_x_option_group_set_parent_id` int(11) NOT NULL DEFAULT '0',
`site_x_option_group_set_image_library_id` int(11) NOT NULL DEFAULT '0',
`site_x_option_group_set_override_url` varchar(255) NOT NULL,
`site_x_option_group_set_approved` char(1) NOT NULL DEFAULT '0',
`#tableName#_updated_datetime` datetime NOT NULL,
`#tableName#_deleted` char(1) NOT NULL DEFAULT '0',"&chr(10));  
	if(structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
		for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
			optionStruct=t9.optionLookup[n];
			savecontent variable="out"{
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(optionStruct.type); 
				fieldName="#tableName#_"&lcase(application.zcore.functions.zURLEncode(optionStruct.site_option_name, "_"));
				v=currentCFC.getCreateTableColumnSQL(fieldName);
			}
			echo(v&","&chr(10));
		} 
	}
	echo('PRIMARY KEY (`#tableName#_id`),
KEY `site_x_option_group_set_id` (`site_x_option_group_set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;');  
	</cfscript>
</cffunction>
 
<cffunction name="generateUpdateTable" access="public" localmode="modern">
	<cfargument name="groupId" type="numeric" required="yes">  
	<cfscript>
 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	 
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData; 


	groupStruct=t9.optionGroupLookup[arguments.groupId];
 
	tableName=lcase(application.zcore.functions.zURLEncode(groupStruct.site_option_group_name, "_"));
  
	if(structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
		for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
			optionStruct=t9.optionLookup[n];
			savecontent variable="out"{ 
				fieldName="#tableName#_"&lcase(application.zcore.functions.zURLEncode(optionStruct.site_option_name, "_"));
			}
			echo(fieldName&':ds["'&replace(optionStruct.site_option_name, "##", "####", "all")&'"],'&chr(10)); 
		} 
	}
	</cfscript>
</cffunction>

<cffunction name="displayGroupCode" access="remote" localmode="modern" roles="member"> 
	<cfscript>
	application.zcore.functions.zSetPageHelpId("2.7.1.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	request.zos.whiteSpaceEnabled=true;
	application.zcore.template.setPlainTemplate();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0);
	form.site_option_group_parent_id=application.zcore.functions.zso(form, 'site_option_group_parent_id', true, 0);
	
	echo('<div style="width:98% !important; float:left;margin:1%;">');
	echo('<h2>Source code generated below.</h2>
	<p>Note: searchOptionGroup() retrieves all the records.  If "Enable Memory Caching" is disabled for the group, it will perform a query to select all the data.  This can be very slow if you are working with hundreds or thousands of records and it may cause nested queries to run if the sub-groups also have "Enable Memory Caching" disabled.   Conversely, for small datasets, this feature is much faster then running a query.</p>
	<p>If you want to disable "Enable Memory Caching", we have a feature that allows returning only the columns you need, such as when making a search filter loop.</p>
	<p>Example: arr1=application.zcore.siteOptionCom.optionGroupStruct("Group Name", 0, request.zos.globals.id, {__groupId=0,__setId=0}, "Field Name,Field 2,etc");</p>
	<p>Then when you need the full records later in your code, you can grab them by id like this.</p>
	<p>fullStruct=application.zcore.siteOptionCom.getOptionGroupSetById(["Group Name"], dataStruct.__setId);</p>

	<p>Warning: The data returned from these function calls is the original copy.  Make sure not to modify the object or it will be modified for all requests until the database is read again.  Also make a new variable first or use the duplicate() function to make a copy.   If the datatype is not able to be converted to a string automatically, then it will always be accessed as a reference to the original instead of a copy.  i.e. struct/array/components are references.  String/boolean/number are copied when you set a variable.</p>
	');
	echo('
		<h2>Jetendo Array Output</h2>
		<textarea name="a222" cols="100" rows="10" style="width:70%;">');

	savecontent variable="cfcOutput"{
		generateGroupCode(form.site_option_group_id, 1, form.site_option_group_parent_id, {}, 0, true, false, true);
	}
	cfcOutput=trim(cfcOutput);

	request.zos.forceAbsoluteImagePlaceholderURL=true;
	savecontent variable="cfcDebugOutput"{
		generateGroupCode(form.site_option_group_id, 1, form.site_option_group_parent_id, {}, 0, true, true, false);
	}
	structdelete(request.zos, 'forceAbsoluteImagePlaceholderURL');
	cfcDebugOutput=trim(cfcDebugOutput);
	savecontent variable="output"{
		generateGroupCode(form.site_option_group_id, 1, form.site_option_group_parent_id, {}, 0, false, false, false);
		
		 
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	if(not structkeyexists(t9.optionGroupLookup, form.site_option_group_id)){
		application.zcore.functions.z404("#form.site_option_group_id# is not a valid site_option_group_id");
	}
		groupStruct=t9.optionGroupLookup[form.site_option_group_id];

		groupName=application.zcore.functions.zURLEncode(replace(application.zcore.functions.zFirstLetterCaps(groupStruct.site_option_group_name), " ", "", "all"), "");
		if(isNumeric(left(groupName, 1))){
			groupName="Group"&groupName;
		}
		groupNameInstance=lcase(left(groupName, 1))&removeChars(groupName,1,1);

		groupNameArray=arrayToList(application.zcore.siteOptionCom.getOptionGroupNameArrayById(groupStruct.site_option_group_id), '","');
		
	}
	echo(trim(output));
	echo('</textarea>');
	if(groupStruct.site_option_group_enable_unique_url EQ 1){
		savecontent variable="output"{
		echo('<!--- Below is an example of a CFC that is used for making a custom page, search result, and search index for a site_x_option_group_set record. --->
<cfcomponent>
<cfoutput>
<cffunction name="index" access="public" localmode="modern">
	<cfargument name="query" type="query" required="yes">
	<cfscript>
	#groupNameInstance#=application.zcore.siteOptionCom.getOptionGroupSetById(["#groupNameArray#"], arguments.query.site_x_option_group_set_id);  
	</cfscript> 
	#cfcOutput#
</cffunction>

<!-- To debug without live data, uncomment this index function and comment out the other index function: --->
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
	<li>Memory Cache Enabled: struct=application.zcore.siteOptionCom.getOptionGroupSetById(["#groupNameArray#"], site_x_option_group_set_id);</li>
	<li>Memory Cache Disabled: showUnapproved=false; struct=application.zcore.siteOptionCom.getOptionGroupSetByID(["#groupNameArray#"], site_x_option_group_set_id, request.zos.globals.id, showUnapproved); </li>
	</ul>');
	if(groupStruct.site_option_group_allow_public NEQ 0){
		if(groupStruct.site_option_group_public_form_url NEQ ""){
			link=groupStruct.site_option_group_public_form_url;
		}else{
			link='/z/misc/display-site-option-group/add?site_option_group_id=#groupStruct.site_option_group_id#';
		}
		link=application.zcore.functions.zURLAppend(link, 'modalpopforced=1');
		echo('<h2>Iframe Embed Code</h2><pre>'&htmlcodeformat('<iframe src="'&link&'" frameborder="0"  style=" margin:0px; border:none; overflow:auto;" seamless="seamless" width="100%" height="500" />')&'</pre>');
		echo('<h2>Modal Window</h2><pre>'&htmlcodeformat('<a href="##" onclick="zShowModalStandard(''#link#?zRefererURL=''+escape(window.location.href), 540, 400); return false;">Show Form</a>')&'</pre>');
		echo('<p>Note "zRefererURL" can be passed to the form, or defined in the script to force the referring page url to be stored. In cfml, you can use form.zReferer=request.zos.globals.domain&request.zos.originalURL;  In JavaScript, "?zRefererURL="+escape(window.location.href);</p>');

		echo('<h2>CFML Embed Form Code</h2><pre>'&htmlcodeformat('
application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id"));
// Note: if this group is a child group, you must update the array below to have the parent groups as well.
form.site_option_group_id=application.zcore.siteOptionCom.getOptionGroupIDWithNameArray(["#groupNameArray#"]);
displayGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
displayGroupCom.add();')&'</pre>');
	}
	echo('<h2>Alternative Group Search Method</h2>
	<p>application.zcore.siteOptionCom.searchOptionGroup(); can also be used to filter records with SQL-LIKE object input.</p>
	<p>By default, all records are looped & compared in memory with a single thread, so be aware that it may take a lot of CPU time with a larger database.</p>
	<p>When working with hundreds or thousands of records, you can achieve better performance & reduced memory usage with the database based search method that is built in to searchOptionGroup.  It translates the structured input array into an efficient SQL query that returns only the records you select.  To switch to using database queries for searchOptionGroup, you only need to disable "Enable Memory Caching" on the edit group form.  Keep in mind the sub-groups have their own "Enable Memory Caching" setting which you may want to enable or disable.</p>
	<p>Even when memory cache is disabled queries are only necessary to retrieve data value because the schema information is still cached in memory.</p>
	<p>Simple Example with fake group/field info:</p>
	<pre>
	
	groupName="#groupStruct.site_option_group_name#";
	// build search as an array of structs.  Supports nested sub-group search, AND/OR, logic grouping, many operators, and multiple values.  See the function definition of searchOptionGroup for more information.
	arrSearch=[{
		type="=",
		field: "Title",
		arrValue:["Title1"]	
	}
	];
	parentGroupId=0;
	showUnapproved=true;
	offset=0;
	limit=10;
	// perform search and return struct with array of structs and whether or not there are more records.
	rs=application.zcore.siteOptionCom.searchOptionGroup(groupName, arrSearch, parentGroupId, showUnapproved, offset, limit);
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


	if(groupStruct.site_option_group_allow_public NEQ 0){
		echo('<h2>Public Form Examples</h2>
		<h3>Embed Public Form in any page</h3>
		'&htmlcodeformat('<cfscript>
form.site_option_group_id=application.zcore.functions.zGetSiteOptionGroupIDWithNameArray(["#groupNameArray#"]);
displayGroupCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
displayGroupCom.add();
</cfscript>')&'

		<h3>Custom Version Of Form Field Layout With Custom Ajax Processing</h3>
		'&htmlcodeformat('
<cffunction name="customFormProcess" access="remote" localmode="modern">
	<cfscript>

	request.zos.disableSpamCheck=true;
    application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, "x_ajax_id")); 
    form.site_option_group_id=application.zcore.functions.zGetSiteOptionGroupIDWithNameArray(["#groupNameArray#"]);
	
    displayGroupCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
    displayGroupCom.ajaxInsert();

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
				window.location.href="#groupStruct.site_option_group_public_thankyou_url#";
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
form.site_option_group_id=application.zcore.functions.zGetSiteOptionGroupIDWithNameArray(["#groupNameArray#"]);

displayGroupCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.display-site-option-group");
displayGroupCom.ajaxInsert();
</cfscript>'));
	}
	// custom version - use moving to sunny as example...

	echo('</div></div>');
	

	echo('<h2>Create Custom Table</h2>
		<p>Using the "Change CFC Path" options, you can have a second table updated with the data, so you can create high performance queries against the data.</p>
		<p>Start with the example code below, and further customize it, add column indexes, and different table column names, etc to build your custom application.</p>');
	echo('<pre><blockquote>');
	savecontent variable="out"{
	generateCreateTable(form.site_option_group_id);
	}
	echo(trim(out));
	echo('</blockquote></pre>');
	echo('<h2>Example Functions For Updating the Custom Table</h2>'); 

	savecontent variable="out"{
		generateUpdateTable(form.site_option_group_id);
	}
	echo('<blockquote>'&htmlcodeformat(trim(out))&'</blockquote>');


	echo('<h2>Generate Widget Config Code</h2>
		<p>This code can be used by the widget system so you can build forms for new widgets visually, and then convert them to code for further editing.</p>');
	echo('<textarea name="widget_code" cols="100" rows="10" style="width:95%;">');
	echo('cs={};'&chr(10));
 	echo('cs.dataFields=[');
	count=0; 
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	if(structkeyexists(t9.optionGroupFieldLookup, groupStruct.site_option_group_id)){
		for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
			optionStruct=t9.optionLookup[n];
			count++;
			currentCFC=application.zcore.siteOptionCom.getTypeCFC(optionStruct.type);   
			typeName=currentCFC.getTypeName();
			options=currentCFC.getOptionFieldStruct();
			currentOptions=duplicate(optionStruct.optionStruct);
			structappend(currentOptions, options, false);
			tabs=chr(9);
			if(count NEQ 1){
				echo(',');
			}
			echo(chr(10)&'{'&chr(10));
			echo('#tabs#id:"#count#",'&chr(10));
			echo('#tabs#label:"#replace(replace(optionStruct.site_option_name, '##', '####', 'all'), '"', '""', "all")#",'&chr(10));
			echo('#tabs#type:"#typeName#",'&chr(10));
			echo('#tabs#required:#optionStruct.site_option_required#,'&chr(10));
			echo('#tabs#defaultValue:"#replace(replace(optionStruct.site_option_default_value, '##', '####', 'all'), '"', '""', "all")#",'&chr(10));
			echo('#tabs#options:{');
			first=true;
			for(g in currentOptions){
				if(not first){
					echo(','&chr(10));
				}else{
					echo(chr(10));
				}
				first=false;
				echo(chr(9)&chr(9)&'"#replace(replace(g, '##', '####', 'all'), '"', '""', "all")#":"#replace(replace(currentOptions[g], '##', '####', 'all'), '"', '""', "all")#"');
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
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0);
	
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData; 
	for(i in t9.optionGroupLookup){
		groupStruct=t9.optionGroupLookup[i];
		if(form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ groupStruct.site_option_group_id){
			continue;
		} 
		echo("<h2>"&groupStruct.site_option_group_display_name&'(s) Help Page</h2>'&chr(10));
		echo('<div style="width:100%; float:left; padding-bottom:10px;">'&groupStruct.site_option_group_help_description&'</div>');
		echo('<div style="width:100%; float:left; padding-bottom:10px;"><h2>Fields</h2>
		<table class="table-list">');
		ss={};
		for(n in t9.optionGroupFieldLookup[groupStruct.site_option_group_id]){
			ss[n]=t9.optionLookup[n];
		}
		arrKey=structsort(ss, "text", "asc", "site_option_name");
		for(n=1;n LTE arraylen(arrKey);n++){
			optionStruct=t9.optionLookup[arrKey[n]];
			echo('<tr>');
			echo('<th style="width:150px; ">#htmleditformat(optionStruct.site_option_name)#</th><td>');
			if(optionStruct.site_option_tooltip EQ ""){
				echo('No help available.');
			}else{
				echo(optionStruct.site_option_tooltip);
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	for(local.i=1;local.i LTE form.fieldcount;local.i++){
		form.site_option_id=application.zcore.functions.zso(form, 'option'&local.i);
		form.mapField=application.zcore.functions.zso(form, 'mapField'&local.i);
		if(form.mapField NEQ ""){
			db.sql="INSERT INTO #db.table("site_option_group_map", request.zos.zcoredatasource)# 
			SET site_option_group_map_updated_datetime = #db.param(request.zos.mysqlnow)#, 
			site_option_id=#db.param(form.site_option_id)#,
			site_option_group_map_fieldname=#db.param(form.mapField)#,
			site_option_group_id=#db.param(form.site_option_group_id)#, 
			site_id=#db.param(request.zos.globals.id)#, 
			site_option_group_map_deleted=#db.param(0)#
			";
			db.execute("qInsert");
		}
	}
	db.sql="delete from #db.table("site_option_group_map", request.zos.zcoredatasource)# 
	where site_option_group_id=#db.param(form.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	site_option_group_map_updated_datetime < #db.param(request.zos.mysqlnow)#";
	db.execute("qDelete");
	application.zcore.status.setStatus(request.zsid, "Map fields saved.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="export" localmode="modern" access="remote" roles="administrator">
	<cfscript>

	content type="text/plain";
	setting requesttimeout="10000";
	var db=request.zos.queryObject;
	currentGroupId=application.zcore.functions.zso(form, 'site_option_group_id'); 
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(currentGroupId)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	header name="Content-Disposition" value="attachment; filename=#dateformat(now(), "yyyy-mm-dd-")&qGroup.site_option_group_name#.csv";
	optionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	db.sql="SELECT * FROM  
	#db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option.site_option_group_id = #db.param(currentGroupId)# and  
	site_option_deleted = #db.param(0)# and 
	site_option.site_id = #db.param(request.zos.globals.id)#  
	ORDER BY site_option_sort ASC";
	qOption=db.execute("qOption");
	arrOption=[];
	arrRowDefault=[];
	optionStruct={};
	optionStructType={};
	first=true;

	hasUser=false;
	for(row in qOption){
		arrayAppend(arrRowDefault, "");
		arrayAppend(arrOption, row.site_option_name);
		v=replace(replace(replace(replace(replace(row.site_option_name, chr(10), ' ', 'all'), chr(13), '', 'all'), chr(9), ' ', 'all'), '\', '\\', 'all'), '"', '\"', "all");
		if(not first){
			echo(",");
		}
		if(row.site_option_type_id EQ 16){
			hasUser=true;
		}
		first=false;
		echo('"'&v&'"');
		optionStruct[row.site_option_id]=arraylen(arrOption);
		optionStructType[row.site_option_id]=row.site_option_type_id;
	}
	if(hasUser){
		userStruct={};
		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
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

		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(currentGroupId)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qGroups=db.execute("qGroups");
		if(qGroups.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qGroups){
			db.sql="SELECT * FROM 
			#db.table("site_x_option_group", request.zos.zcoreDatasource)# 
			WHERE  
			site_x_option_group.site_option_group_id = #db.param(currentGroupId)# and 
			site_x_option_group_set_id = #db.param(row.site_x_option_group_set_id)# and 
			site_x_option_group_deleted = #db.param(0)# and 
			site_x_option_group.site_id = #db.param(request.zos.globals.id)#  ";
			qValues=db.execute("qValues");
 

			arrRow=duplicate(arrRowDefault);
			userStructRow={};
			arrAddUser=[];
			for(value in qValues){
				if(structkeyexists(optionStruct, value.site_option_id)){
					offset=optionStruct[value.site_option_id]; 
					if(optionStructType[value.site_option_id] EQ 16){ 
						if(structkeyexists(userStruct, value.site_x_option_group_value)){
							arrayAppend(arrAddUser, userStruct[value.site_x_option_group_value]); 
						} 
					}
					arrRow[offset]=value.site_x_option_group_value;
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
	var qGroup=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qOption=0;
	setting requesttimeout="10000";
	currentGroupId=application.zcore.functions.zso(form, 'site_option_group_id'); 
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id');
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(currentGroupId)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	optionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	doffset=0;
	while(true){

		// process x groups at a time.
		xlimit=20;

		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(currentGroupId)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		LIMIT #db.param(doffset)#, #db.param(xlimit)#";
		qGroups=db.execute("qGroups");
		if(qGroups.recordcount EQ 0){
			break;
		}
		doffset+=xlimit;

		for(row in qGroups){
			db.sql="SELECT * FROM 
			#db.table("site_x_option_group", request.zos.zcoreDatasource)#,
			#db.table("site_option", request.zos.zcoreDatasource)# 
			WHERE 
			site_option.site_option_id = site_x_option_group.site_option_id and 
			site_option.site_id = site_x_option_group.site_id and 
			site_option_deleted = #db.param(0)# and 
			site_x_option_group.site_option_group_id = #db.param(currentGroupId)# and 
			site_x_option_group_set_id = #db.param(row.site_x_option_group_set_id)# and 
			site_x_option_group_deleted = #db.param(0)# and 
			site_x_option_group.site_id = #db.param(request.zos.globals.id)#  ";
			qValues=db.execute("qValues");

			structclear(form);


			ts={};
			for(value in qValues){
				ts[value.site_option_name]=value.site_x_option_group_value;
				//form['newvalue'&value.site_option_id]=form[value.site_x_option_group_value];
			}
			// get all site options with label and value for current row.

			//throw("warning: this will delete unique url and image gallery id - because internalGroupUpdate is broken.");

			arrGroupName =application.zcore.siteOptionCom.getOptionGroupNameArrayById(qGroup.site_option_group_id); 
			application.zcore.siteOptionCom.setOptionGroupImportStruct(arrGroupName, 0, 0, ts, form); 
			structappend(form, row, true);
			// writedump(form);abort;
 
			rs=optionCom.internalGroupUpdate(); 
			if(not rs.success){
				writedump(rs);
				writedump(ts);
				writedump(form);
				application.zcore.functions.zStatusHandler(rs.zsid);
				abort;
			} 
		}
	}
	application.zcore.status.setStatus(request.zsid, "Group, ""#qGroup.site_option_group_name#"", was reprocessed successfully.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="mapFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qGroup=0;
	var ts=0;
	var db=request.zos.queryObject;
	var row=0;
	var qOption=0;
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id'); 
	variables.init();
	// get group
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group no longer exists.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
	}
	echo("<h2>Map Fields For Site Option Group: #qGroup.site_option_group_display_name#</h2>");
	
	if(qGroup.site_option_group_map_group_id NEQ 0){
		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(qGroup.site_option_group_map_group_id)# and 
		site_option_group_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qMapGroup=db.execute("qMapGroup");
		if(qMapGroup.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "You must add an option to the group before you can use this feature.", form, true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid=#request.zsid#");
		}
		echo("<p>Mapping to Site Option Group: ""#qMapGroup.site_option_group_display_name#""</p>");
	}else{
		echo("<p>Mapping to Inquiries Table.</p>");
	}
	db.sql="SELECT * FROM #db.table("site_option_group_map", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qMap=db.execute("qMap");
	local.mapStruct={};
	for(row in local.qMap){
		local.mapStruct[row.site_option_id]=row.site_option_group_map_fieldname;
	}
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)#
	ORDER BY site_option_sort ASC";
	qOption=db.execute("qOption");
	
	mappingEnabled=true;
	if(qGroup.site_option_group_map_fields_type EQ "2"){ // group
		// get second group
		db.sql="SELECT site_option_display_name, site_option_id FROM #db.table("site_option", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id = #db.param(qGroup.site_option_group_map_group_id)# and 
		site_option_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# and
		site_option_allow_public = #db.param(1)#
		ORDER BY site_option_display_name";
		local.qOption2=db.execute("qOption2"); 
		if(local.qOption2.recordcount EQ 0){
			mappingEnabled=false;
			writeoutput('No site options in the mapped group, "#qMapGroup.site_option_group_display_name#",  are set to "allow public" = "yes".  Make at least 1 field public to allow this feature to be used.');
		}
		local.arrLabel=[];
		local.arrValue=[];
		for(row in local.qOption2){
			arrayAppend(local.arrLabel, row.site_option_display_name);
			arrayAppend(local.arrValue, row.site_option_id);
		}
		local.labels=arrayToList(local.arrLabel, chr(9));
		local.values=arrayToList(local.arrValue, chr(9));
	
	}else if(qGroup.site_option_group_map_fields_type EQ "1"){ // inquiries
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
		application.zcore.functions.z404("qGroup.site_option_group_map_fields_type: "&qGroup.site_option_group_map_fields_type&" is invalid");
	}

	local.index=1;
	if(mappingEnabled){
		writeoutput('<p>Map as many fields as you wish. You can map an option to the same field multiple times to automatically combine those values.</p>
			<p>To save time, try clicking <a href="##" class="zOptionGroupAutoMap">auto-map</a> first.</p>
		<form class="zFormCheckDirty" id="optionGroupMapForm" action="/z/admin/site-option-group/saveMapFields?site_option_group_id=#form.site_option_group_id#" method="post">
		<table class="table-list"><tr><th>Option Field</th><th>Map To Field</th></tr>');
		for(row in qOption){
			writeoutput('<tr><td><input type="hidden" name="option#local.index#" value="#row.site_option_id#" /><div id="fieldLabel#local.index#" class="fieldLabelDiv" data-id="#local.index#">'&htmleditformat(row.site_option_display_name)&'</div></td><td>');
			if(structkeyexists(local.mapStruct, row.site_option_id)){
				form["mapField"&local.index]=local.mapStruct[row.site_option_id];
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
		<input type="button" name="cancel1" value="Cancel" onclick="window.location.href=''/z/admin/site-option-group/index'';" />
		</form>');
	}
	</cfscript>
</cffunction>

<cffunction name="copyGroupForm" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;

	application.zcore.functions.zSetPageHelpId("2.7.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	if(local.qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site option group.", form, true);
		application.zcore.functions.zRedirect('/z/admin/site-option-group/index?zsid=#request.zsid#');	
	}
	</cfscript>
	<h2>Copy Group: #local.qGroup.site_option_group_display_name#</h2>
	<p>Please note that the "select menu" type, and group / inquiries mapping data are not copied.  You will need to verify those are setup correctly after copying this site option group.</p>
	<form class="zFormCheckDirty" action="/z/admin/site-option-group/copyGroup" method="post">
		<input type="hidden" name="site_option_group_id" value="#form.site_option_group_id#" />
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
			<td>New Group Name</td>
			<td><cfscript>
				ts=StructNew();
				ts.name="newGroupName";
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
				<input type="button" name="cancel1" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/admin/site-option-group/index';" />
			</td></tr>
		</table>
	</form>
</cffunction>


<cffunction name="copyGroupRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="site_option_group_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	var row2=0;
	var ts=0;
	// 
	
	// TODO: we would need to guarantee inquiries_type_id is cloned first by checking for same new on the new site - then i could copy the map table too.  For now, it just removes these.
	row.inquiries_type_id=0;
	row.inquiries_type_id_siteIDType=0;
	row.site_option_group_map_group_id=0;
	row.site_id = arguments.site_id;
	ts=structnew();
	ts.struct=row;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="site_option_group";
	local.newoptionGroupId=application.zcore.functions.zInsert(ts);
	arguments.groupStruct[arguments.site_option_group_id]=local.newoptionGroupId;
	db.sql="select * from #db.table("site_option", request.zos.zcoredatasource)# 
	where site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)# and
	site_option_group_id = #db.param(arguments.site_option_group_id)# ";
	local.qOptions=db.execute("qOptions");
	for(row2 in local.qOptions){
		row2.site_id=arguments.site_id;
		row2.site_option_group_id=local.newoptionGroupId;
		// row2.site_option_appidlist     
		ts=structnew();
		ts.struct=row2;
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="site_option";
		local.newoptionId=application.zcore.functions.zInsert(ts);
		arguments.optionStruct[row2.site_option_id]=local.newoptionId;
	}
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_parent_id = #db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	for(row in local.qGroup){
		row.site_option_group_parent_id=local.newoptionGroupId;
		this.copyGroupRecursive(row.site_option_group_id, arguments.site_id, row, arguments.groupStruct, arguments.optionStruct);
	}
	</cfscript>
</cffunction>

<cffunction name="copyGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var row2=0;
	var ts=0;
	var optionStruct={};
	var groupStruct={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	form.newGroupName=application.zcore.functions.zso(form, 'newGroupName');
	form.newSiteId=application.zcore.functions.zso(form, 'newSiteId', true, 0);
	if(form.newSiteId EQ 0){
		form.newSiteId=request.zos.globals.id;
	}
	form.copyData=application.zcore.functions.zso(form, 'copyData', true, 0);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0); 
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	where site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
	if(local.qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site option group.", form, true);
		application.zcore.functions.zRedirect('/z/admin/site-option-group/index?zsid=#request.zsid#');	
	} 
	for(row in local.qGroup){
		if(form.newGroupName NEQ ""){
			row.site_option_group_name=form.newGroupName;
			row.site_option_group_display_name=form.newGroupName;
		}
		this.copyGroupRecursive(form.site_option_group_id, form.newSiteId, row, groupStruct, optionStruct);
	}
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.newSiteId);
		
	application.zcore.status.setStatus(request.zsid, "Site Option Group Copied.");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<!--- 
<cffunction name="generateTableFromGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var row2=0;
	var dbNoVerify=request.zos.noVerifyQueryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
	local.arrSQL=[];
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# WHERE 
	site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	local.qGroup=db.execute("qGroup");
		
	db.sql="select * from #db.table("site_option", request.zos.zcoredatasource)# WHERE 
	site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	site_option_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	local.qOption=db.execute("qOption");

	if(local.qGroup.recordcount EQ 0 or local.qOption.recordcount EQ 0){
		return;
	}
	
	local.optionLookup={};
	for(row in local.qOption){
		local.optionLookup[row.site_option_id]={
			type:row.site_option_type_id,
			name:row.site_option_name
		};
		if(row.site_option_type_id EQ 0){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 1){
			local.sqlType="text NOT NULL";
		}else if(row.site_option_type_id EQ 2){
			local.sqlType="longtext NOT NULL";
		}else if(row.site_option_type_id EQ 3){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 4){
			local.sqlType="datetime NOT NULL";
		}else if(row.site_option_type_id EQ 5){
			local.sqlType="date NOT NULL";
		}else if(row.site_option_type_id EQ 6){
			local.sqlType="time NOT NULL";
		}else if(row.site_option_type_id EQ 7){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 8){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 9){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 10){
			local.sqlType="varchar(255) NOT NULL";
		}else if(row.site_option_type_id EQ 11){
			continue;
		}
		arrayappend(local.arrSQL, "`"&row.site_option_name&"` #local.sqlType# ");
	}
	arrayappend(local.arrSQL, "
	`_title` varchar(255) NOT NULL,
	`_sort` int(11) unsigned NOT NULL DEFAULT '0',
	`_active` int(11) unsigned NOT NULL DEFAULT '0',
	`_parent_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_app_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_url` varchar(255) NOT NULL,
	`_image_library_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_set_id` int(11) unsigned NOT NULL DEFAULT '0',
	`_approved` char(1) NOT NULL DEFAULT '1'");
	arrayappend(local.arrSQL, "PRIMARY KEY (`_set_id`)");
  	// KEY `NewIndex1` (`site_id`),
	
	local.tableName="_#qGroup.site_option_group_name#_#qGroup.site_id#";
	dbNoVerify.sql="SHOW TABLES IN `#request.zos.zcoreTempDatasource#` LIKE '#local.tableName#_safe'";
	local.qCheck=dbNoVerify.execute("qCheck");
	if(local.qCheck.recordcount NEQ 0){
		dbNoVerify.sql=" DROP TABLE `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` ";
		dbNoVerify.execute("qDrop");
	}
	dbNoVerify.sql=" CREATE TABLE  `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` (
	"&arrayToList(local.arrSQL, ", "&chr(10))&") 
	ENGINE=InnoDB DEFAULT CHARSET=utf8";
	dbNoVerify.execute("qCreate");
	
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1,
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2
	WHERE 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and
	s1.site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	s1.site_id = #db.param(request.zos.globals.id)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id 
	ORDER BY s1.site_x_option_group_set_id asc ";
	local.qData=db.execute("qData");
	if(local.qData.recordcount){
		local.lastSetId=0;
		local.lastSetIdInserted=0;
		local.setStruct={};
		for(row2 in local.qData){
			if(local.lastSetId NEQ 0 and local.lastSetId NEQ row2.site_x_option_group_set_id){
				local.insertId=variables.insertRowInTempTable(local.tableName&"_safe", local.qGroup, local.setStruct, row2);
				if(local.insertId EQ false){
					
				}
				local.lastSetIdInserted=row2.site_x_option_group_set_id;
				local.setStruct={};
			}
			if(structkeyexists(local.optionLookup, row2.site_option_id)){
				local.tempOption=local.optionLookup[row2.site_option_id];
				if(local.tempOption.type EQ 4){
					local.setStruct[local.tempOption.name] = dateformat(row2.site_x_option_group_date_value, "yyyy-mm-dd")&' '& timeformat(row2.site_x_option_group_date_value, "HH:mm:ss");
				}else if(local.tempOption.type EQ 5){
					local.setStruct[local.tempOption.name] = dateformat(row2.site_x_option_group_date_value, "yyyy-mm-dd");
				}else if(local.tempOption.type EQ 6){
					local.setStruct[local.tempOption.name] = timeformat(row2.site_x_option_group_date_value, "HH:mm:ss");
				}else if(local.tempOption.type EQ 11){
					continue;
				}else{
					local.setStruct[local.tempOption.name] = '';
				}
			}
			local.lastSetId=row2.site_x_option_group_set_id;
		}
		if(structcount(local.setStruct) NEQ 0 and local.lastSetIdInserted NEQ row2.site_x_option_group_set_id){
			local.insertId=variables.insertRowInTempTable(local.tableName&"_safe", local.qGroup, local.setStruct, row2);
			if(local.insertId EQ false){
				
			}
			local.setStruct={};
		}
	}
	
	dbNoVerify.sql="SHOW TABLES IN `#request.zos.zcoreTempDatasource#` LIKE '#local.tableName#'";
	local.qCheck=dbNoVerify.execute("qCheck");
	if(local.qCheck.recordcount EQ 0){
		dbNoVerify.sql="RENAME TABLE 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#` ";
		dbNoVerify.execute("qRename");
	}else{
		dbNoVerify.sql="RENAME TABLE 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safetemp`, 
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe`,
		`#request.zos.zcoreTempDatasource#`.`#local.tableName#_safetemp` to `#request.zos.zcoreTempDatasource#`.`#local.tableName#`
		 ";
		dbNoVerify.execute("qRename");
		dbNoVerify.sql=" DROP TABLE `#request.zos.zcoreTempDatasource#`.`#local.tableName#_safe` ";
		dbNoVerify.execute("qDrop");
	}
	
	/*db.sql="select * from #db.table("#local.tableName#", request.zos.zcoreTempDatasource)# ";
	local.qData=db.execute("qData");
	writedump(local.qData);
	*/
	</cfscript>
</cffunction>

<cffunction name="insertRowInTempTable" localmode="modern" access="private">
	<cfargument name="tableName" type="string" required="yes">
	<cfargument name="qGroup" type="query" required="yes">
	<cfargument name="setStruct" type="struct" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	var ts=structnew();
	// add other data from set
	local.tempURL="";
	if(request.zos.globals.optionGroupURLID NEQ 0 and arguments.qGroup.site_option_group_enable_unique_url EQ 1){
		if(arguments.row.site_x_option_group_set_override_url NEQ ""){
			local.tempURL=arguments.row.site_x_option_group_set_override_url;
		}else{
			local.tempURL="/#application.zcore.functions.zURLEncode(arguments.row.site_x_option_group_set_title, '-')#-#request.zos.globals.optionGroupURLID#-#arguments.row.site_x_option_group_set_id#.html";
		}
	}
	arguments.setStruct._title = arguments.row.site_x_option_group_set_title;
	arguments.setStruct._sort = arguments.row.site_x_option_group_set_sort;
	arguments.setStruct._active = arguments.row.site_x_option_group_set_active;
	arguments.setStruct._parent_id = arguments.row.site_x_option_group_set_parent_id;
	arguments.setStruct._app_id = arguments.row.site_option_app_id;
	arguments.setStruct._url = local.tempURL;
	arguments.setStruct._image_library_id = arguments.row.site_x_option_group_set_image_library_id;
	arguments.setStruct._set_id = arguments.row.site_x_option_group_set_id;
	arguments.setStruct._approved = arguments.row.site_x_option_group_set_approved;
	ts.struct=arguments.setStruct;
	ts.table=arguments.tableName;
	ts.enableTableFieldCache=false;
	ts.forcePrimaryInsert={"_set_id": arguments.row.site_x_option_group_set_id}; 
	ts.debug=true;
	ts.datasource=request.zos.zcoreTempDatasource;
	return application.zcore.functions.zInsert(ts);
	</cfscript>
</cffunction> --->

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var qProp=0;
	var curParentId=0;
	var arrParent=0;
	var q1=0;
	var i=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7.1");
	application.zcore.functions.zstatushandler(request.zsid);
	form.site_option_group_parent_id=application.zcore.functions.zso(form, 'site_option_group_parent_id',true);
	if(form.site_option_group_parent_id NEQ 0){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		where site_option_group_id=#db.param(form.site_option_group_parent_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_option_group.site_id =#db.param(request.zos.globals.id)#";
		qGroup=db.execute("qGroup");
        if(qGroup.recordcount EQ 0){
            application.zcore.functions.z301redirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#");	
        }
	}
	db.sql="SELECT site_option_group.*, if(child1.site_option_group_id IS NULL, #db.param(0)#,#db.param(1)#) hasChildren 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group
	LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# child1 ON 
	site_option_group.site_option_group_id = child1.site_option_group_parent_id and 
	child1.site_id = site_option_group.site_id and 
	child1.site_option_group_deleted = #db.param(0)# 
	WHERE
	site_option_group.site_option_group_deleted = #db.param(0)# and 
	site_option_group.site_id =#db.param(request.zos.globals.id)# and 
	site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_parent_id)# 
	group by site_option_group.site_option_group_id 
	order by site_option_group.site_option_group_display_name ASC ";
	qProp=db.execute("qProp");
	if(form.site_option_group_parent_id NEQ 0){
		writeoutput('<p><a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Manage Groups</a> / ');
		curParentId=form.site_option_group_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * 
			from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
			where site_option_group_id = #db.param(curParentId)# and 
			site_option_group_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#";
			q1=db.execute("q1");
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#q1.site_option_group_id#">
				#application.zcore.functions.zFirstLetterCaps(q1.site_option_group_display_name)#</a> / ');
				curParentId=q1.site_option_group_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.site_option_group_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GT 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(form.site_option_group_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qGroup.site_option_group_display_name)&" /");
		}
		writeoutput('</p>');
	}
	</cfscript>
	<p><a href="/z/admin/site-option-group/add?site_option_group_parent_id=<cfif isquery(qgroup)>#qgroup.site_option_group_id#</cfif>">Add Group</a> 

	 | <a href="/z/admin/site-option-group-import/importGroup">Import Group</a> 
	 
	<cfif isquery(qgroup) and qgroup.site_option_group_id NEQ 0>
		| <a href="/z/admin/site-option-group/displayGroupCode?site_option_group_id=<cfif isquery(qgroup)>#qgroup.site_option_group_id#</cfif>" target="_blank">Display Group Code</a>
	</cfif>
	<cfif isquery(qgroup)> | <a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#qgroup.site_option_group_id#&site_option_group_parent_id=#qgroup.site_option_group_parent_id#">Manage Options</a></cfif></p>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>ID</th>
			<th>Group Name</th>
			<th>Disable Admin</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
		<tr <cfif qProp.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.site_option_group_id#</td>
			<td>#qProp.site_option_group_name#</td>
			<td><cfif qProp.site_option_group_disable_admin EQ 1>
					Yes
				<cfelse>
					No
				</cfif>
			</td>
			<td>
				<cfif qProp.site_option_group_admin_app_only EQ "0">
					<cfif qProp.site_option_group_parent_id EQ 0>
	
						<a href="/z/admin/site-options/manageGroup?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#">List/Edit</a> | 
						<a href="/z/admin/site-options/import?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#">Import</a> | 
						<a href="/z/admin/site-options/manageGroup?site_option_app_id=0&site_option_group_id=#qProp.site_option_group_id#&amp;zManagerAddOnLoad=1">Add</a> | 
					</cfif>
				</cfif>
			<cfif qProp.site_id NEQ 0 or variables.allowGlobal>
					<a href="/z/admin/site-option-group/add?site_option_group_parent_id=#qProp.site_option_group_id#">Add Sub-Group</a> | 
					<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#">Options</a> | 
					<cfif qProp.site_option_group_allow_public NEQ 0>
						<cfif qProp.site_option_group_public_form_url NEQ "">
							<a href="#htmleditformat(qProp.site_option_group_public_form_url)#" target="_blank">Public Form</a> | 
						<cfelse>
							<a href="/z/misc/display-site-option-group/add?site_option_group_id=#qProp.site_option_group_id#" target="_blank">Public Form</a> | 
						</cfif>
					</cfif>
					<cfif application.zcore.user.checkServerAccess()>
						<a href="/z/admin/site-option-group/export?site_option_group_id=#qProp.site_option_group_id#" target="_blank">Export CSV</a> | 
						<a href="/z/admin/site-option-group/reindex?site_option_group_id=#qProp.site_option_group_id#" title="Will update site option group table for all records.  Useful after a config change.">Reprocess</a> | 
						<a href="/z/_com/app/siteOptionGroupFormGenerator?method=index&amp;site_option_group_id=#qProp.site_option_group_id#" target="_blank">Generate Custom DB Form</a> | 
					</cfif>
	
					<cfif qProp.hasChildren EQ 1>
						<a href="/z/admin/site-option-group/index?site_option_group_parent_id=#qProp.site_option_group_id#">Sub-Groups</a> |
					</cfif>
					<a href="/z/admin/site-option-group/displayGroupCode?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#" target="_blank">Display Code</a> |
					
					<cfif qProp.site_option_group_map_fields_type NEQ 0>
						<a href="/z/admin/site-option-group/mapFields?site_option_group_id=#qProp.site_option_group_id#">Map Fields</a>
						<cfscript>
						db.sql="select count(site_option_group_map_id) count 
						from #db.table("site_option_group_map", request.zos.zcoreDatasource)# site_option_group_map WHERE 
						site_id = #db.param(qProp.site_id)# AND 
						site_option_group_map_deleted = #db.param(0)# and
						site_option_group_id = #db.param(qProp.site_option_group_id)# ";
						qMap=db.execute("qMap");
						if(qMap.recordcount EQ 0 or qMap.count EQ 0){
							echo('<strong>(Not Mapped Yet)</strong> ');
						}
						</cfscript> | 
					</cfif>
					<a href="/z/admin/site-option-group/edit?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Edit</a> | 
					<cfif qProp.site_option_group_parent_id EQ 0>
						<a href="/z/admin/site-option-group/copyGroupForm?site_option_group_id=#qProp.site_option_group_id#">Copy</a> | 
					</cfif>
					<a href="/z/admin/site-option-group/delete?site_option_group_id=#qProp.site_option_group_id#&amp;site_option_group_parent_id=#qProp.site_option_group_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Delete</a>
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	form.site_option_group_id=application.zcore.functions.zso(form,'site_option_group_id');
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "group is missing");
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&zsid="&request.zsid);
	}
	if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index");
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		// TODO: fix group delete that has no options - it leaves a remnant in memory that breaks the application
		application.zcore.siteOptionCom.deleteGroupRecursively(form.site_option_group_id, true);
		application.zcore.status.setStatus(request.zsid, "Group deleted successfully.");
		application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(qCheck.site_option_group_id);

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id); 
		if(structkeyexists(request.zsession, "site_option_group_return"&form.site_option_group_id) and request.zsession['site_option_group_return'&form.site_option_group_id] NEQ ""){
			tempLink=request.zsession["site_option_group_return"&form.site_option_group_id];
			structdelete(request.zsession,"site_option_group_return"&form.site_option_group_id);
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Group";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2> Are you sure you want to delete this Group?<br />
		<br />
		Group: #qcheck.site_option_group_display_name#<br />
		<br />
		<a href="/z/admin/site-option-group/delete?confirm=1&site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&zrand=#gettickcount()#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_parent_id=#form.site_option_group_parent_id#">No</a> </h2>
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	myForm.site_option_group_display_name.required=true;
	myForm.site_option_group_display_name.friendlyName="Display Name";
	myForm.site_option_group_name.required=true;
	myForm.site_option_group_name.friendlyName="Code Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm,request.zsid, true);
	
	form.site_option_group_allow_delete_usergrouplist=application.zcore.functions.zso(form, 'site_option_group_allow_delete_usergrouplist');
	form.site_option_group_user_group_id_list=application.zcore.functions.zso(form, 'site_option_group_user_group_id_list');
	form.site_option_group_change_email_usergrouplist=application.zcore.functions.zso(form, 'site_option_group_change_email_usergrouplist');

	if(form.method EQ "update"){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		where site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#");
		}
		// force code name to never change after initial creation
		//form.site_option_group_name=qCheck.site_option_group_name;
	}
	if(application.zcore.functions.zso(form, 'site_option_group_enable_unique_url', false, 0) EQ 1){
		if(form.site_option_group_view_cfc_path EQ "" or form.site_option_group_view_cfc_method EQ ""){
			application.zcore.status.setStatus(request.zsid, "View CFC Path and View CFC Method are required when ""Enable Unique Url"" is set to yes.", form, true);
			errors=true;
		}
	}
	if(form.site_option_group_parent_id NEQ "" and form.site_option_group_parent_id NEQ 0){
		form.site_option_group_enable_new_button=0;
	} 
	
	form.site_option_group_appidlist=","&application.zcore.functions.zso(form,'site_option_group_appidlist')&",";
	 if(application.zcore.functions.zso(form,'optionGroupglobal',false,0) EQ 1 and variables.allowGlobal){
		 form.site_id='0';
	 }else{
		 form.site_id=request.zos.globals.id;
	 }
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#");
		}
	} 
	
	if(form.inquiries_type_id NEQ ""){
		local.arrTemp=listToArray(form.inquiries_type_id, '|');
		form.inquiries_type_id=local.arrTemp[1];
		form.inquiries_type_id_siteIDType=application.zcore.functions.zGetSiteIdType(local.arrTemp[2]);
	}
	 
	ts=StructNew();
	ts.table="site_option_group";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.site_option_group_id = application.zcore.functions.zInsert(ts);
		if(form.site_option_group_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Group couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Group added successfully.");
			redirecturl=("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Group failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Group updated successfully.");
			redirecturl=("/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid="&request.zsid);
		}
	}
	
	
	application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(form.site_option_group_id);
	//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	
	if(form.method EQ "insert" and structkeyexists(request.zsession, "site_option_group_return") and request.zsession['site_option_group_return'] NEQ ""){
		tempLink=request.zsession["site_option_group_return"];
		structdelete(request.zsession,"site_option_group_return");
		application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
	}else if(structkeyexists(request.zsession, "site_option_group_return"&form.site_option_group_id)){
		tempLink=request.zsession["site_option_group_return"&form.site_option_group_id];
		structdelete(request.zsession,"site_option_group_return"&form.site_option_group_id);
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
	application.zcore.functions.zSetPageHelpId("2.7.2");
	
	var currentMethod=form.method;
	variables.init();
	form.site_option_group_id=application.zcore.functions.zso(form,'site_option_group_id',true);
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id =#db.param(request.zos.globals.id)# ";
	qRate=db.execute("qRate");
	if(structkeyexists(form, 'site_option_group_parent_id')){
		application.zcore.functions.zQueryToStruct(qRate,form,'site_option_group_id,site_option_group_parent_id'); 
	}else{
		application.zcore.functions.zQueryToStruct(qRate,form,'site_option_group_id'); 
	}
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Group";
	}else{
		theTitle="Add Group";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	</cfscript>
				<cfscript>
				if(form.site_id EQ 0){
					form.optionGroupglobal='1';
				}
				</cfscript> 
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/admin/site-option-group/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#" method="post">

		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Public Form", "Landing Page", "Email & Mapping"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-site-option-group-edit");
		cancelURL="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#"; 
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  style="border-spacing:0px;" class="table-list">
			<cfsavecontent variable="db.sql"> SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_option_group_deleted = #db.param(0)# 
			<!--- <cfif form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ "">
				and site_option_group_id <> #db.param(form.site_option_group_id)# and 
				site_option_group_parent_id <> #db.param(form.site_option_group_id)#
			</cfif> --->
			ORDER BY site_option_group_display_name </cfsavecontent>
			<cfscript>
			qG=db.execute("qG");
			</cfscript>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Group","member.site-option-group.edit site_option_group_parent_id")#</th>
				<td><cfscript>
				arrData=[];
				for(row in qG){
					arrayAppend(arrData, { 
						parent:row.site_option_group_parent_id, 
						label:row.site_option_group_display_name, 
						value:row.site_option_group_id
					});
				} 
				rs=application.zcore.functions.zGetRecursiveLabelValueForSelectBox(arrData);
				selectStruct=structnew();
				selectStruct.name="site_option_group_parent_id"; 
				selectStruct.onchange="doParentCheck();";
				if(form.site_option_group_id NEQ ""){
					selectStruct.onchange="if(this.options[this.selectedIndex].value=='#form.site_option_group_id#'){alert('You can\'t select the same group you are editing.');this.selectedIndex=0;}"&selectStruct.onchange;
				}
				selectStruct.listValuesDelimiter=chr(9);
				selectStruct.listLabelsDelimiter=chr(9);
				selectStruct.listLabels=arrayToList(rs.arrLabel, chr(9));
				selectStruct.listValues=arrayToList(rs.arrValue, chr(9)); 
				application.zcore.functions.zInputSelectBox(selectStruct);
				/*
				selectStruct=structnew();
				selectStruct.name="site_option_group_parent_id";
				selectStruct.query = qG;
				selectStruct.onchange="doParentCheck();";
				selectStruct.queryLabelField = "site_option_group_display_name";
				selectStruct.queryValueField = "site_option_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);*/
				</cfscript><br />
				<strong>Warning:</strong> If user data exists for this record, you should not change the Parent Group, because the user data's parent group field will not be automatically updated.  You'd have to update the database and cache manually if you want to do this anyway. 
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Code Name","member.site-option-group.edit site_option_group_name")#</th>
				<td>
					<input name="site_option_group_name" id="site_option_group_name" size="50" type="text" value="#htmleditformat(form.site_option_group_name)#"  onkeyup="var d1=document.getElementById('site_option_group_display_name');d1.value=this.value;" onblur="var d1=document.getElementById('site_option_group_display_name');d1.value=this.value;" maxlength="100" />
					<input type="hidden" name="site_option_group_type" value="1" />
				<cfif currentMethod NEQ "add">
					<br><br><strong>WARNING:</strong> You should not change the "Name" on a live site unless you are ready to deploy the corrections to the source code immediately.  Editing the "Name" will also prevent the Sync feature from working.  Make sure to communicate with the other developers if you change the "Name".  Any code that refers to this name will start throwing undefined errors immediately after changing this.
				</cfif></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Display Name","member.site-option-group.edit site_option_group_display_name")#</th>
				<td><input name="site_option_group_display_name" id="site_option_group_display_name" size="50" type="text" value="#htmleditformat(form.site_option_group_display_name)#" maxlength="100" />
				</td>
			</tr>
				
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Menu Name","member.site-option-group.edit site_option_group_menu_name")#</th>
					<td><div  id="groupMenuNameId">
							<input name="site_option_group_menu_name" id="site_option_group_menu_name" size="50" type="text" value="#htmleditformat(form.site_option_group_menu_name)#" maxlength="100" /><br />
							(Put this group in a different manager menu - default is Custom)</div>
						<div  id="groupMenuNameId2" style="display:none;">Disabled - Only allowed on the root groups.</div></td>
				</tr>
				<!---
				TODO:  optionGroupglobal is not fully implemented
				<cfif variables.allowGlobal>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Global","member.site-option-group.edit optionGroupglobal")#</th>
						<td>#application.zcore.functions.zInput_Boolean("optionGroupglobal")#</td>
					</tr>
				</cfif> --->
				<cfscript>
				if(form.site_option_group_admin_paging_limit EQ ""){
					form.site_option_group_admin_paging_limit=0;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Child Limit","member.site-option-group.edit site_option_group_limit")#</th>
					<td><input type="number" name="site_option_group_limit" id="site_option_group_limit" value="#htmleditformat(form.site_option_group_limit)#" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("User Child Limit","member.site-option-group.edit site_option_group_user_child_limit")#</th>
					<td><input type="number" name="site_option_group_user_child_limit" id="site_option_group_user_child_limit" value="#htmleditformat(form.site_option_group_user_child_limit)#" /></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Sorting","member.site-option-group.edit site_option_group_enable_sorting")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_sorting")#</td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Image Library?","member.site-option-group.edit site_option_group_enable_image_library")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_image_library")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Admin?","member.site-option-group.edit site_option_group_disable_admin")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_admin")#</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Archiving?","member.site-option-group.edit site_option_group_enable_archiving")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_archiving")#</td>
				</tr>
				<cfif form.site_option_group_parent_id EQ 0> 
					<tr>
						<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable New Button","member.site-option-group.edit site_option_group_enable_new_button")#</th>
						<td>
							#application.zcore.functions.zInput_Boolean("site_option_group_enable_new_button")# 
							(Places this group in the Create New button in manager header)
					</td>
					</tr>
				</cfif>

				
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Admin Paging Limit</th>
					<td><input name="site_option_group_admin_paging_limit" id="site_option_group_admin_paging_limit" type="number" value="#htmleditformat(form.site_option_group_admin_paging_limit)#"  /> (Number of records to display in admin until showing page navigation)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Form Description:","member.site-option-group.edit site_option_group_form_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_form_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_form_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Form Bottom Description:","member.site-option-group.edit site_option_group_bottom_form_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_bottom_form_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_bottom_form_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("List View Description:","member.site-option-group.edit site_option_group_list_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_list_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_list_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 250;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Field","member.site-option-group.edit site_option_group_parent_field")#</th>
					<td><input type="text" name="site_option_group_parent_field" id="site_option_group_parent_field" value="#htmleditformat(form.site_option_group_parent_field)#" /> (Optional, enables indented heirarchy on list view)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable List Recurse","member.site-option-group.edit site_option_group_enable_list_recurse")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_list_recurse")# (Displays this group's records on parent groups manager list view)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Export?","member.site-option-group.edit site_option_group_disable_export")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_export")#</td>
				</tr>

				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Versioning?","member.site-option-group.edit site_option_group_enable_versioning")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_versioning")# (This enables deep copy and changing between versions of a record. Changing versions doesn't support recursion.)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Max ## of Versions","member.site-option-group.edit site_option_group_version_limit")#</th>
					<td><input name="site_option_group_version_limit" id="site_option_group_version_limit" size="50" type="text" value="#htmleditformat(application.zcore.functions.zso(form, 'site_option_group_version_limit', true))#" maxlength="100" />
							</td></tr>

				
				<cfscript>
				if(form.site_option_group_enable_cache EQ ""){
					form.site_option_group_enable_cache=1;
				}
				</cfscript>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Memory Caching","member.site-option-group.edit site_option_group_enable_cache")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_cache")# (Warning: "Yes" will result in very slow manager performance if this group has many records.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable URL Caching","member.site-option-group.edit site_option_group_enable_partial_page_caching")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_partial_page_caching")# (Incomplete - will store rendered page in memory)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Help Description:","member.site-option-group.edit site_option_group_help_description")#</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "site_option_group_help_description";
						htmlEditor.value			= application.zcore.functions.zso(form, 'site_option_group_help_description');
						htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
						htmlEditor.height		= 350;
						htmlEditor.create();
						</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Change CFC Path","member.site-option-group.edit site_option_group_change_cfc_path")#</th>
					<td><input type="text" name="site_option_group_change_cfc_path" id="site_option_group_change_cfc_path" value="#htmleditformat(form.site_option_group_change_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)<br /><br />

					Update Method: <input type="text" name="site_option_group_change_cfc_update_method" id="site_option_group_change_cfc_update_method" value="#htmleditformat(form.site_option_group_change_cfc_update_method)#" /><br /><br />
					Delete Method: <input type="text" name="site_option_group_change_cfc_delete_method" id="site_option_group_change_cfc_delete_method" value="#htmleditformat(form.site_option_group_change_cfc_delete_method)#" /><br /><br />
					Sort Method: <input type="text" name="site_option_group_change_cfc_sort_method" id="site_option_group_change_cfc_sort_method" value="#htmleditformat(form.site_option_group_change_cfc_sort_method)#" /><br />
					 (Each function should exist in the CFC with access="public")
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Only Show App Admin?","member.site-option-group.edit site_option_group_admin_app_only")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_admin_app_only")# (Disables list/add links on developer's manage groups page)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Associate With Apps","member.site-option-group.edit site_option_group_appidlist")#</th>
					<td><cfscript>
					db.sql="select app.* from #db.table("app", request.zos.zcoreDatasource)# app, 
					#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
					WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	 				app.app_built_in=#db.param(0)# and 
					app_x_site.app_id = app.app_id and 
					app_x_site_deleted = #db.param(0)# and 
					app_deleted = #db.param(0)# 
					order by app_name ";
					qApp=db.execute("qApp");
					
					selectStruct=structnew();
					selectStruct.name="site_option_group_appidlist";
					selectStruct.query = qApp;
					selectStruct.onchange="";
					selectStruct.queryLabelField = "app_name";
					selectStruct.queryValueField = "app_id";
					application.zcore.functions.zInput_Checkbox(selectStruct);
					</cfscript> (Deprecated - DO NOT USE)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Section?","member.site-option-group.edit site_option_group_enable_section")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_section")# Deprecated DO NOT USE (Requires Enable Unique URL to be set to Yes)</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">
						#application.zcore.functions.zOutputHelpToolTip("Allow Locked Delete?","member.site-option-group.edit site_option_group_enable_locked_delete")#
					</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_locked_delete")# 
						(When a record is locked, setting this to yes will allow a non-developer to delete the record.)
					</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Public Form")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form Title","member.site-option-group.edit site_option_group_public_form_title")#</th>
					<td><input name="site_option_group_public_form_title" id="site_option_group_public_form_title" size="50" type="text" value="#htmleditformat(form.site_option_group_public_form_title)#" maxlength="100" />
							</td></tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Public Form?","member.site-option-group.edit site_option_group_allow_public")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_allow_public")#

					<script type="text/javascript">
					zArrDeferredFunctions.push(function(){
						$("##site_option_group_allow_public1").bind("click", function(){
							$("##site_option_group_enable_cache0")[0].checked=true;
						});
						$("##site_option_group_allow_public0").bind("click", function(){
							$("##site_option_group_enable_cache1")[0].checked=true;
						});
					});
					</script>
					</td>
				</tr>
				<tr>
					<th>Newsletter Auto Opt In?</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_newsletter_opt_in_form")#</td>
				</tr>
				<tr>
					<th>Require Captcha<br />For Public Data Entry:</th>
					<td>
					#application.zcore.functions.zInput_Boolean("site_option_group_enable_public_captcha")#
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Data Entry<br />For User Groups","member.site-option-group.edit site_option_group_user_group_id_list")#</th>
					<td>
					<cfscript>
					db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					user_group_deleted = #db.param(0)# 
					ORDER BY user_group_name asc"; 
					var qGroup2=db.execute("qGroup2"); 
					ts = StructNew();
					ts.name = "site_option_group_user_group_id_list";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qGroup2;
					ts.queryLabelField = "user_group_friendly_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'site_option_group_user_group_id_list'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Delete<br />For User Groups","member.site-option-group.edit site_option_group_allow_delete_usergrouplist")#</th>
					<td>
					<cfscript> 
					ts = StructNew();
					ts.name = "site_option_group_allow_delete_usergrouplist";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qGroup2;
					ts.queryLabelField = "user_group_friendly_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'site_option_group_allow_delete_usergrouplist'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> (Enabling delete, will force enable delete of all child groups too)</td>
				</tr>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Changes Email Alert<br />For User Groups","member.site-option-group.edit site_option_group_change_email_usergrouplist")#</th>
					<td>
					<cfscript> 
					ts = StructNew();
					ts.name = "site_option_group_change_email_usergrouplist";
					ts.friendlyName="";
					// options for query data
					ts.multiple=true;
					ts.query = qGroup2;
					ts.queryLabelField = "user_group_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'site_option_group_change_email_usergrouplist'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> (Email will be sent when custom record data is changed by these user groups)</td>
				</tr>
				<cfif application.zcore.functions.zso(form, 'site_option_group_parent_id', true) EQ 0>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable User Dashboard Admin","member.site-option-group.edit site_option_group_enable_user_dashboard_admin")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_user_dashboard_admin")# | If you select yes, you must specify the User Id Field below.</td>
				</tr>
	
					<tr>
						<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("User Id Field","member.site-option-group.edit site_option_group_user_id_field")#</th>
						<td>
							<input name="site_option_group_user_id_field" id="site_option_group_user_id_field" size="50" type="text" value="#htmleditformat(form.site_option_group_user_id_field)#" maxlength="50" />
						</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Enable Alternate Admin Layout","member.site-option-group.edit site_option_group_subgroup_alternate_admin")#</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_group_subgroup_alternate_admin")#</td>
					</tr>
				</cfif>

				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Require Approval#chr(10)#of Public Data?","member.site-option-group.edit site_option_group_enable_approval")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_approval")#</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Form URL","member.site-option-group.edit site_option_group_public_form_url")#</th>
					<td>
							<input name="site_option_group_public_form_url" id="site_option_group_public_form_url" size="50" type="text" value="#htmleditformat(form.site_option_group_public_form_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Thank You URL","member.site-option-group.edit site_option_group_public_thankyou_url")#</th>
					<td>
							<input name="site_option_group_public_thankyou_url" id="site_option_group_public_thankyou_url" size="50" type="text" value="#htmleditformat(form.site_option_group_public_thankyou_url)#" maxlength="100" />
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Session Form Token","member.site-option-group.edit site_option_group_public_thankyou_token")#</th>
					<td>
							<input name="site_option_group_public_thankyou_token" id="site_option_group_public_thankyou_token" size="50" type="text" value="#htmleditformat(form.site_option_group_public_thankyou_token)#" maxlength="100" /> <br />(The thank you url will have this token added to it with a unique value that will also be added to the user's session memory.  Comparing these 2 values on the server side will allow you to show content to only users that have submitted the form.  I.e. allow them to download a file, etc.)
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Ajax?","member.site-option-group.edit site_option_group_ajax_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_ajax_enabled")# <br />(Yes will make public form insertions use ajax instead, but not for updating existing records.)</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Landing Page")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Enable Unique URL</th>
					<td>
				<cfif request.zos.globals.optionGroupURLID NEQ 0>
					#application.zcore.functions.zInput_Boolean("site_option_group_enable_unique_url")#
				<cfelse>
					Option group URL ID must be set in server manager to use this feature.
				</cfif></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Home Page?</th>
					<td> 
					#application.zcore.functions.zInput_Boolean("site_option_group_is_home_page")# | Yes, will force the URL to be "/".   Note: you may have trouble getting this to work with root.index, you can move index.cfc to mvc/controller/index.cfc to fix the problem.  The routing system gives higher precedence to root.index, so you have to remove it.
					</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Meta Tags?","member.site-option-group.edit site_option_group_enable_meta")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_enable_meta")#</td>
				</tr>
				<!--- 
				This field doesn't do anything yet!
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Embedding?","member.site-option-group.edit site_option_group_embed")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_embed")#</td>
				</tr> --->
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Embed HTML Code:","member.site-option-group.edit site_option_group_code")#</th>
					<td><textarea name="site_option_group_code" id="site_option_group_code" cols="100" rows="10">#htmleditformat(form.site_option_group_code)#</textarea></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Path","member.site-option-group.edit site_option_group_view_cfc_path")#</th>
					<td><input type="text" name="site_option_group_view_cfc_path" id="site_option_group_view_cfc_path" value="#htmleditformat(form.site_option_group_view_cfc_path)#" /> <br />(Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("View CFC Method","member.site-option-group.edit site_option_group_view_cfc_method")#</th>
					<td><input type="text" name="site_option_group_view_cfc_method" id="site_option_group_view_cfc_method" value="#htmleditformat(form.site_option_group_view_cfc_method)#" /><br />(A function name in the CFC with access="remote")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Site Map?","member.site-option-group.edit site_option_group_disable_site_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_site_map")#</td>
				</tr>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="site_option_group_public_searchable" id="site_option_group_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_group_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="site_option_group_public_searchable" id="site_option_group_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_group_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Path","member.site-option-group.edit site_option_group_search_index_cfc_path")#</th>
					<td><input type="text" name="site_option_group_search_index_cfc_path" id="site_option_group_search_index_cfc_path" value="#htmleditformat(form.site_option_group_search_index_cfc_path)#" /><br />
					(Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Index CFC Method","member.site-option-group.edit site_option_group_search_index_cfc_method")#</th>
					<td><input type="text" name="site_option_group_search_index_cfc_method" id="site_option_group_search_index_cfc_method" value="#htmleditformat(form.site_option_group_search_index_cfc_method)#" /><br /> (A function name in the CFC with access="public")</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Path","member.site-option-group.edit site_option_group_search_result_cfc_path")#</th>
					<td><input type="text" name="site_option_group_search_result_cfc_path" id="site_option_group_search_result_cfc_path" value="#htmleditformat(form.site_option_group_search_result_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Search Result CFC Method","member.site-option-group.edit site_option_group_search_result_cfc_method")#</th>
					<td><input type="text" name="site_option_group_search_result_cfc_method" id="site_option_group_search_result_cfc_method" value="#htmleditformat(form.site_option_group_search_result_cfc_method)#" /> <br />(A function name in the CFC with access="public")</td>
				</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Email & Mapping")#
		<table  style="border-spacing:0px;" class="table-list">
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Fields Type","member.site-option-group.edit site_option_group_map_fields_type")#</th>
					<td><cfscript>
					form.site_option_group_map_fields_type=application.zcore.functions.zso(form, 'site_option_group_map_fields_type', true, 0);
					ts = StructNew();
					ts.name = "site_option_group_map_fields_type";
					ts.listLabels = "Disabled,Inquiries,Group";
					ts.listValues = "0,1,2";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map Group","member.site-option-group.edit site_option_group_map_group_id")#</th>
					<td><cfscript>
					selectStruct=structnew();
					selectStruct.name="site_option_group_map_group_id";
					selectStruct.query = qG;
					selectStruct.onchange="doParentCheck();";
					selectStruct.queryLabelField = "site_option_group_display_name";
					selectStruct.queryValueField = "site_option_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Map To Lead Type","member.site-option-group.edit inquiries_type_id")#</th>
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
					<th>#application.zcore.functions.zOutputHelpToolTip("Map Insert Type","member.site-option-group.edit site_option_group_map_insert_type")#</th>
					<td><cfscript>
					form.site_option_group_map_insert_type=application.zcore.functions.zso(form, 'site_option_group_map_insert_type', true, 0);
					ts = StructNew();
					ts.name = "site_option_group_map_insert_type";
					ts.listLabels = "Disabled,Immediately on Insert,After Manual Approval";
					ts.listValues = "0,1,2";
					ts.radio=true;
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					writeoutput(application.zcore.functions.zInput_Checkbox(ts));
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Delete On Map?","member.site-option-group.edit site_option_group_delete_on_map")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_delete_on_map")# (Set this to no when a file upload field is used on the form.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Enable Lead Routing?","member.site-option-group.edit site_option_group_lead_routing_enabled")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_lead_routing_enabled")# | If Yes, an email will be generated when a new record is inserted.</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Disable Detailed Lead Email?","member.site-option-group.edit site_option_group_disable_detailed_lead_email")#</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_group_disable_detailed_lead_email")# | If Yes, a simple lead email will be sent excluding any personal information from the contact.</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Path","member.site-option-group.edit site_option_group_email_cfc_path")#</th>
					<td><input type="text" name="site_option_group_email_cfc_path" id="site_option_group_email_cfc_path" value="#htmleditformat(form.site_option_group_email_cfc_path)#" /><br /> (Should begin with zcorerootmapping, root or another root relative path.)</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email CFC Method","member.site-option-group.edit site_option_group_email_cfc_method")#</th>
					<td><input type="text" name="site_option_group_email_cfc_method" id="site_option_group_email_cfc_method" value="#htmleditformat(form.site_option_group_email_cfc_method)#" /><br /> (A function name in the CFC with access="public")</td>
				</tr>
				<tr>
					<th>Custom Email<br />Options</th>
					<td>
						<p>If you need to have custom routing that can't be handled by the CMS, you should answer No and Yes below and define the Email CFC above.  The Email CFC must send the email itself.</p>
						<p>If the custom email cfc path/method feature is used, the regular lead email will be disabled.</p>
					<p>Do you want to force the regular email to be sent as well?</p>
					<p>#application.zcore.functions.zInput_Boolean("site_option_group_force_send_default_email")#</p>
					<p>Disable routing for the custom email? (You will need to call application.zcore.email.send yourself if you want to send an email)</p>
					<p>#application.zcore.functions.zInput_Boolean("site_option_group_disable_custom_routing")#</p></td>
				</tr>
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()#
				 
				
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="optionGroupglobal" value="0" />
		</cfif>
	</form>
	<script type="text/javascript">
		/* <![CDATA[ */
		var arrD=[];<cfloop query="qG">arrD.push("#qG.site_id#");</cfloop>
		var firstLoad11=true;
		function doParentCheck(){
			var d1=document.getElementById("optionGroupglobal1");
			var d0=document.getElementById("optionGroupglobal0");
			var groupMenuName=document.getElementById("groupMenuNameId");
			var groupMenuName2=document.getElementById("groupMenuNameId2");
			var groupMenuNameField=document.getElementById("site_option_group_menu_name");
			if(groupMenuNameField == null){
				return;
			}
			if(firstLoad11){
				firstLoad11=false;
				if(d1 != null){
					$(d1).bind("change",function(){ doParentCheck(); });
					$(d0).bind("change",function(){ doParentCheck(); });
				}
				
			}
			var a=document.getElementById("site_option_group_parent_id");
			if(a.selectedIndex != 0){
				groupMenuNameField.value='';
				groupMenuName.style.display="none";
				groupMenuName2.style.display="block";

				if(d1 != null){
					if(arrD[a.selectedIndex-1] == 0){
						d1.checked=true;
						d0.checked=false;	
					}else{
						d1.checked=false;
						d0.checked=true;	
					}
				}
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
