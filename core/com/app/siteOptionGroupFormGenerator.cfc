<cfcomponent>
<cfoutput>  
<!--- 
consider implementing the getListValue for this.

consider having parent_id indentation or click to view children (and carry through id everywhere)

add options for: 
	uniqueURLField:"page_unique_url",
	metaFields:{
		title:"page_metatitle",
		keywords:"page_metakey",
		description:"page_metadesc",
	},
 --->

<!--- /z/_com/app/siteOptionGroupFormGenerator?method=index --->
<cffunction name="init" localmode="modern" access="public">
	<cfscript>  
	db=request.zos.queryObject;
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true);
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)#
	WHERE site_id= #db.param(request.zos.globals.id)# and  
	site_option_group_id = #db.param(form.site_option_group_id)# and  
	site_option_group_deleted = #db.param(0)#  ";
	request.qGroup=db.execute("qGroup");
	if(request.qGroup.recordcount EQ 0){
		application.zcore.functions.z404('Invalid group id');
		abort;
	}
	</cfscript>
</cffunction>

<cffunction name="displayForm" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init(); 
	ts={
		site_option_group_id:form.site_option_group_id,
		tableName:form.tableName,
		nameField:form.nameField,
		// make sure the uploadPath is unique to avoid conflicts with other applications
		uploadPath:"##request.zos.globals.privateHomeDir##"&removechars(form.uploadDisplayPath, 1, 1), // this absolute path directory will be created if it didn't exist yet
		uploadDisplayPath:form.uploadDisplayPath, 
		datasource:form.datasource,
		friendlyName:form.friendlyName,
		adminURL:form.adminURL,
		enableSearch:form.enableSearch,
		enableSiteId:form.enableSiteId,
		enableSorting:form.enableSorting,
		enableMeta:form.enableMeta,
		
		// parentId and foreignParentId not implemented yet - these will be for making forms/tables that have relationships to other forms/tables
		// together
		enableParentId:form.enableParentId,
		parentIdField:form.parentIdField,
		// together
		enableForeignKey:form.enableForeignKey,
		foreignRequired:form.foreignRequired,
		foreignPrimaryKeyField:form.foreignPrimaryKeyField,
		foreignNameField:form.foreignNameField,
		foreignTableName:form.foreignTableName,
		foreignFriendlyName:form.foreignFriendlyName,
		foreignAdminURL:form.foreignAdminURL,
		foreignEnableSiteId:form.foreignEnableSiteId,
		// together
		enableChildAdmin:form.enableChildAdmin,
		childAdminURL:form.childAdminURL,
		childFriendlyName:form.childFriendlyName,
		childCFCPath:form.childCFCPath,
		childTableName:form.childTableName,
		childCFCDeleteMethod:form.childCFCDeleteMethod,
		childEnableSiteId:form.childEnableSiteId,
		childPrimaryKeyId:form.childPrimaryKeyId
	}; 
 
	fieldData=getFieldData(ts);
	echo('<h2>Custom Database-driven Form Code For Site Option Group: #request.qGroup.site_option_group_display_name#</h2>
	<h3>Database Creation SQL</h3>');
	echo('<textarea name="n2" cols="150" rows="10" style="width:100%;">#htmleditformat(trim(fieldData.createTable))#</textarea>');

	template=getFormTemplate(ts, fieldData);
	echo('<h3>Place this code in #left(form.adminURL, len(form.adminURL)-1)#.cfc according to Jetendo MVC conventions.</h3>
	<textarea name="n1" cols="150" style="width:100%;" rows="10">#htmleditformat(template)#</textarea>');
	
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>  
	db=request.zos.queryObject;
	init();
	groupName=replace(application.zcore.functions.zURLEncode(lcase(request.qGroup.site_option_group_display_name), "_"), "__", "_", "all");
	</cfscript>
	<h2>Generate Custom Database-driven Form Code From Site Option Group</h2>
	<h3>Selected Group: #request.qGroup.site_option_group_display_name#</h3>
 
	<p>* Denotes required field.</p>
	<form action="/z/_com/app/siteOptionGroupFormGenerator?method=displayForm&amp;site_option_group_id=#form.site_option_group_id#" method="post">
		<table class="table-list">
			<tr>
				<th>Table Name *</th>
				<td><input type="text" name="tableName" value="#htmleditformat(form.tableName?:groupName)#"></td>
			</tr>
			<tr>
				<th>Friendly Name *</th>
				<td><input type="text" name="friendlyName" value="#htmleditformat(form.friendlyName?:request.qGroup.site_option_group_display_name)#"></td>
			</tr>
			<tr>
				<th>Name Field *</th>
				<td><input type="text" name="nameField" value="#htmleditformat(form.nameField?:"#groupName#_name")#"><br>
				This field will be shown in select boxes (like Parent) as the title of the record.
				</td>
			</tr> 
			<tr>
				<th>Enable Parent ID?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableParentId")#</td>
			</tr>
			<tr>
				<th>Upload Path</th>
				<td><input type="text" name="uploadDisplayPath" value="#htmleditformat(form.uploadDisplayPath?:'/zupload/#groupName#/')#"></td>
			</tr>
			<tr>
				<th>Datasource *</th>
				<td><input type="text" name="datasource" value="#htmleditformat(form.datasource?:'request.zos.globals.datasource')#"></td>
			</tr>
			<tr>
				<th>Admin URL Prefix *</th>
				<td><input type="text" name="adminURL" value="#htmleditformat(form.datasource?:'/admin/#groupName#/')#"></td>
			</tr>
			<tr>
				<th>Enable Search?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableSearch")#</td>
			</tr>
			<tr>
				<th>Enable Site ID?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableSiteId")#</td>
			</tr>
			<tr>
				<th>Enable Sorting?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableSorting")#</td>
			</tr>
			<tr>
				<th>Enable Meta (Custom Fields)?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableMeta")#</td>
			</tr>
			<tr>
				<th>Parent ID Field</th>
				<td><input type="text" name="parentIdField" value="#htmleditformat(form.parentIdField?:'#groupName#_parent_id')#"></td>
			</tr>
			<tr>
				<th>Enable Foreign Key?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableForeignKey")#</td>
			</tr>
			<tr>
				<th>Enable Foreign Field Required?</th>
				<td>#application.zcore.functions.zInput_Boolean("foreignRequired")#</td>
			</tr>
			
			<tr>
				<th>Foreign Key Primary ID Field</th>
				<td><input type="text" name="foreignPrimaryKeyField" value="#htmleditformat(form.foreignPrimaryKeyField?:'other_table_id')#"></td>
			</tr> 
			<tr>
				<th>Foreign Key Name Field</th>
				<td><input type="text" name="foreignNameField" value="#htmleditformat(form.foreignNameField?:'other_table_name')#"></td>
			</tr> 
			<tr>
				<th>Foreign Key Enable Site ID?</th>
				<td>#application.zcore.functions.zInput_Boolean("foreignEnableSiteId")#</td>
			</tr> 
			<tr>
				<th>Foreign Key Table Name</th>
				<td><input type="text" name="foreignTableName" value="#htmleditformat(form.foreignTableName?:'other_table')#"></td>
			</tr> 
			<tr>
				<th>Foreign Key Friendly Name</th>
				<td><input type="text" name="foreignFriendlyName" value="#htmleditformat(form.foreignFriendlyName?:'Other Table')#"></td>
			</tr> 
			<tr>
				<th>Foreign Key Admin URL</th>
				<td><input type="text" name="foreignAdminURL" value="#htmleditformat(form.foreignAdminURL?:'/admin/other_table/')#"></td>
			</tr>  
			<tr>
				<th>Enable Child Admin?</th>
				<td>#application.zcore.functions.zInput_Boolean("enableChildAdmin")#</td>
			</tr>
			<tr>
				<th>Child Key Primary ID Field</th>
				<td><input type="text" name="childPrimaryKeyId" value="#htmleditformat(form.childPrimaryKeyId?:'child_id')#"></td>
			</tr> 
			<tr>
				<th>Child Admin URL</th>
				<td><input type="text" name="childAdminURL" value="#htmleditformat(form.childAdminURL?:'/admin/child_table/')#"></td>
			</tr> 
			<tr>
				<th>Child Table Name</th>
				<td><input type="text" name="childTableName" value="#htmleditformat(form.childTableName?:'child')#"></td>
			</tr>
			<tr>
				<th>Child Friendly Name</th>
				<td><input type="text" name="childFriendlyName" value="#htmleditformat(form.childFriendlyName?:'Child Table')#"></td>
			</tr> 
			<tr>
				<th>Child Enable Site ID?</th>
				<td>#application.zcore.functions.zInput_Boolean("childEnableSiteId")#</td>
			</tr> 
			<tr>
				<th>Child CFC Path</th>
				<td><input type="text" name="childCFCPath" value="#htmleditformat(form.childCFCPath?:'##request.zRootCFCPath##mvc.controller.child')#"></td>
			</tr> 
			<tr>
				<th>Child CFC Delete Method</th>
				<td><input type="text" name="childCFCDeleteMethod" value="#htmleditformat(form.childCFCDeleteMethod?:'deleteRow')#"></td>
			</tr> 
			<!--- <tr>
				<th>&nbsp;</th>
				<td>The fields below are not implemented yet</td>
			</tr> --->
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submit1" value="Submit"></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="getFieldData" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;  
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)#
	WHERE site_id= #db.param(request.zos.globals.id)# and  
	site_option_group_id <> #db.param(0)# and  
	site_option_group_id = #db.param(ss.site_option_group_id)# and  
	site_option_deleted = #db.param(0)#  
	ORDER BY site_option_group_id ASC, site_option_sort ASC";
	qOption=db.execute("qOption");

	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)#
	WHERE site_id= #db.param(request.zos.globals.id)# and  
	site_option_group_id = #db.param(ss.site_option_group_id)# and  
	site_option_group_deleted = #db.param(0)#  ";
	qGroup=db.execute("qGroup");
	ds={};
	ds.groupStruct={}; 
	for(row in qGroup){
		ds.groupStruct[row.site_option_group_id]={
			data:row, 
			arrOptionOrder:[], 
			options:{}, 
			hasFileFields:false,
			arrParent:[]
		};
	}
	/*for(i in ds.groupStruct){
		group=ds.groupStruct[i];
		currentGroup=group;
		n=0;
		while(true){
			if(currentGroup.data.site_option_group_parent_id EQ 0){
				break;
			}
			arrayPrepend(ds.groupStruct[i].arrParent, currentGroup.data.site_option_group_parent_id);
			currentGroup=ds.groupStruct[currentGroup.data.site_option_group_parent_id];
			n++;
			if(n GT 25){
				throw("Detected infinite loop in #group.site_option_group_name# parent ids");
			}
		}
	}*/
	var optionBase=createobject("component", "zcorerootmapping.com.app.option-base");
	typeCFCStruct=optionBase.getOptionTypeCFCs();
	for(i in typeCFCStruct){
		typeCFCStruct[i].init("site", "site");
	}  
	for(row in qOption){
		if(not structkeyexists(ds.groupStruct, row.site_option_group_id)){
			continue;
		}
		typeCFC=typeCFCStruct[row.site_option_type_id];
		json=deserializeJson(row.site_option_type_json);

		group=ds.groupStruct[row.site_option_group_id];
		fieldName=ss.tableName&"_"&replace(application.zcore.functions.zURLEncode(lcase(row.site_option_display_name), "_"), "__", "_", "all");
		dataStruct={
			'uniqueFieldName#row.site_option_id#': '',
			'uniqueFieldName': ''
		} 
		value=typeCFC.getFormFieldCode(row, json, fieldName);
		value=replace(value, '{tableName}', ss.tableName, 'all');

		if(row.site_option_type_id EQ 9 or row.site_option_type_id EQ 3){
			value=replace(value, '{uploadDisplayPath}', ss.uploadDisplayPath, 'all');
		}  
 		if(application.zcore.functions.zso(json, 'checkbox_labels') NEQ ""){
 			request.forceTextCheckbox=true;
 		}
		ts={
			label:replace(htmleditformat(replace(row.site_option_display_name, "##", "####", "all")), '"', "", "all"),
			columnSQL:typeCFC.getCreateTableColumnSQL(fieldName),
			fieldName:fieldName,
			json:json,
			data:row,
			formField:value,
			beforeInsert:'',
			beforeUpdate:'',
			afterUpdate:'',
			visible:true,
			required:row.site_option_required
		};
		structdelete(request, 'forceTextCheckbox');
		if(row.site_option_type_id EQ 3){
			ts.columnSQL&=", `#ts.fieldName#_original` varchar(255) NOT NULL ";
		}
		if(row.site_option_type_id EQ 12){
			ts.visible=false;
		}
		if(row.site_option_type_id EQ 9 or row.site_option_type_id EQ 3){
			ds.groupStruct[row.site_option_group_id].hasFileFields=true;
		} 

		ds.groupStruct[row.site_option_group_id].options[row.site_option_id]=ts;
		arrayAppend(ds.groupStruct[row.site_option_group_id].arrOptionOrder, row.site_option_id); 
	}
	request.hasImageLibraryId=false;
	for(groupId in ds.groupStruct){
		group=ds.groupStruct[groupId];
		// if site_id enabled, add it

		if(ss.enableSiteId){
			ts={
				label:"Site ID",
				columnSQL:"`site_id` int(11) unsigned NOT NULL",
				fieldName:"site_id",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayPrepend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}
		if(ss.enableParentId){
			ts={
				label:ss.parentIdField,
				columnSQL:"`#ss.parentIdField#` int(11) unsigned NOT NULL",
				fieldName:"#ss.parentIdField#",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayPrepend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}
		if(ss.enableForeignKey){
			ts={
				label:ss.foreignFriendlyName,
				columnSQL:"`#ss.foreignPrimaryKeyField#` int(11) unsigned NOT NULL",
				fieldName:"#ss.foreignPrimaryKeyField#",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayPrepend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}

		// add primary key
		ts={
			label:"ID",
			columnSQL:"`#ss.tableName#_id` int(11) unsigned NOT NULL",
			fieldName:ss.tableName&"_id",
			json:{},
			data:{},
			formField:'',
			beforeUpdate:'',
			afterUpdate:'',
			visible:false,
			required:false
		};
		if(not ss.enableSiteId){
			ts.columnSQL&=" AUTO_INCREMENT";
		}
		ds.groupStruct[groupId].options[ts.fieldName]=ts;
		arrayPrepend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
 

		// if sorting enabled add field
		if(ss.enableSorting EQ 1){
			ts={
				label:"Sort",
				columnSQL:"`#ss.tableName#_sort` int(11) unsigned NOT NULL",
				fieldName:ss.tableName&"_sort",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}
		if(ss.enableMeta EQ 1){
			ts={
				label:"Meta",
				columnSQL:"`#ss.tableName#_meta_json` int(11) unsigned NOT NULL",
				fieldName:ss.tableName&"_meta_json",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}

		// if image library enabled, add field
		if(group.data.site_option_group_enable_image_library EQ 1){
			request.hasImageLibraryId=true;
			ts={
				label:"Photos",
				columnSQL:"`#ss.tableName#_image_library_id` int(11) unsigned NOT NULL",
				fieldName:ss.tableName&"_image_library_id",
				json:{},
				data:{},
				formField:' 
				<cfscript>
				form["#ss.tableName#_image_library_id"]=application.zcore.functions.zso(form, "#ss.tableName#_image_library_id"); 
				ts=structnew();
				ts.name="#ss.tableName#_image_library_id";
				ts.value=form["#ss.tableName#_image_library_id"];
				application.zcore.imageLibraryCom.getLibraryForm(ts); 
				</cfscript>
				',
				beforeUpdate:'',
				afterUpdate:'', // activate image library
				visible:true,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
 
		}
		if(ss.enableSearch){
			ts={
				label:"Search",
				columnSQL:"`#ss.tableName#_search` LONGTEXT NOT NULL",
				fieldName:ss.tableName&"_search",
				json:{},
				data:{},
				formField:'',
				beforeUpdate:'',
				afterUpdate:'',
				visible:false,
				required:false
			};
			ds.groupStruct[groupId].options[ts.fieldName]=ts;
			arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
		}

		// add created, updated and deleted fields
		ts={
			label:"Date Created",
			columnSQL:"`#ss.tableName#_created_datetime` datetime NOT NULL",
			fieldName:ss.tableName&"_created_datetime",
			json:{},
			data:{},
			formField:'',
			beforeUpdate:'',
			afterUpdate:'',
			visible:false,
			required:false
		};
		ds.groupStruct[groupId].options[ts.fieldName]=ts;
		arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);

		ts={
			label:"Last Updated",
			columnSQL:"`#ss.tableName#_updated_datetime` datetime NOT NULL",
			fieldName:ss.tableName&"_updated_datetime",
			json:{},
			data:{},
			formField:'',
			beforeUpdate:'#ss.tableName#_updated_datetime=request.zos.mysqlnow;',
			afterUpdate:'',
			visible:false,
			required:false
		};
		ds.groupStruct[groupId].options[ts.fieldName]=ts;
		arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);

		ts={
			label:"Deleted",
			columnSQL:"`#ss.tableName#_deleted` int(11) unsigned NOT NULL DEFAULT '0'",
			fieldName:ss.tableName&"_deleted",
			json:{},
			data:{},
			formField:'',
			beforeUpdate:'#ss.tableName#_deleted=0;',
			afterUpdate:'',
			visible:false,
			required:false
		};
		ds.groupStruct[groupId].options[ts.fieldName]=ts;
		arrayAppend(ds.groupStruct[groupId].arrOptionOrder, ts.fieldName);
	} 
	for(groupId in ds.groupStruct){
		group=ds.groupStruct[groupId];
		ds.groupStruct[groupId].createTable=getCreateTable(ss, group); 
	}
	if(ss.enableSiteId){
		ds.groupStruct[groupId].createTable&=chr(10)&chr(10)&'// you must also create the trigger for this table in the database upgrade script using the following code:'&chr(10)&' application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(#ss.datasource#, "#ss.tableName#", "#ss.tableName#_id"); ';
	}
	return ds.groupStruct[ss.site_option_group_id];
	</cfscript> 
</cffunction>
 
<cffunction name="getCreateTable" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	ds=arguments.ds;
	a=["CREATE TABLE #ss.tableName# ("];

	hasSiteId=false;
	for(i=1;i<=arraylen(ds.arrOptionOrder);i++){
		option=ds.options[ds.arrOptionOrder[i]];
		if(option.fieldName EQ "site_id"){
			hasSiteId=true;
		}
		if(structcount(option.data) NEQ 0 and option.data.site_option_type_id EQ 11){
			continue;
		}
		arrayAppend(a, option.columnSQL&", "); 
	}
	indexCount=1;
	if(hasSiteId){ 
		arrayAppend(a, " PRIMARY KEY (`site_id`,`#ss.tableName#_id`),
		KEY `NewIndex#indexCount#` (`site_id`) ");
		indexCount++;
	}else{
		arrayAppend(a, " PRIMARY KEY (`#ss.tableName#_id`) ");
	}
	if(ss.enableParentId){
		arrayAppend(a, ",
		KEY `newIndex#indexCount#` (`#ss.parentIdField#`) ");
		indexCount++;
	}
	if(ss.enableForeignKey){
		if(hasSiteId){ 
			arrayAppend(a, ",
			KEY `newIndex#indexCount#` (`site_id`, `#ss.foreignPrimaryKeyField#`) ");
			indexCount++;
		}else{
			arrayAppend(a, ",
			KEY `newIndex#indexCount#` (`#ss.foreignPrimaryKeyField#`) ");
			indexCount++;
		}
	}
	if(ss.enableSearch){
		arrayAppend(a, ", 
		FULLTEXT INDEX `NewIndex#indexCount#` (`#ss.tableName#_search`) ");
		indexCount++;
	}

	arrayAppend(a, ") ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;");

	return arrayToList(a, chr(10));
	</cfscript> 
</cffunction>


<cffunction name="getFormTemplate" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="fieldData" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss; 
	fd=arguments.fieldData;
	request.appendAdminURL="";
	if(ss.enableForeignKey){
		request.appendAdminURL="&#ss.foreignPrimaryKeyField#=##form.#ss.foreignPrimaryKeyField###&#ss.parentIdField#=##form.#ss.parentIdField###";
	}
	</cfscript>  
<cfsavecontent variable="templateCode">
<cfscript>  
echo('<cfcomponent extends="zcorerootmapping.com.app.manager-base"> 	 
<cfoutput>  
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[];
	/*
	// This is an example of making quick links.  Change #ss.friendlyName# to the right feature
	variables.hasAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("#ss.friendlyName#");
	if(variables.hasAccess){
		arrayAppend(links, { link:"#ss.adminURL#index?zManagerAddOnLoad=1", label:"Add #ss.friendlyName#" }); 
	}
	*/
	return links;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.template.setTag("title", "Manager | #ss.friendlyName#");

	');
	if(ss.enableParentId){
		echo('
	form.#ss.parentIdField#=application.zcore.functions.zso(form, "#ss.parentIdField#", true);
	');
	} 
	if(ss.enableForeignKey){
		echo('
	form.#ss.foreignPrimaryKeyField#=application.zcore.functions.zso(form, "#ss.foreignPrimaryKeyField#", true);
	db.sql="SELECT * 
	 from ##db.table("#ss.foreignTableName#", #ss.datasource#)##  
	WHERE  
	#ss.foreignTableName#_deleted = ##db.param(0)## and 
	#ss.foreignPrimaryKeyField# = ##db.param(form.#ss.foreignPrimaryKeyField#)## ');
	if(ss.foreignEnableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('"; 
	request.q#ss.foreignTableName#=db.execute("q#ss.foreignTableName#"); 
	');
	if(ss.foreignRequired){
		echo('
	if(request.q#ss.foreignTableName#.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid #ss.foreignFriendlyName#", form, true);
		echo("invalid #ss.foreignFriendlyName#");
		abort;
		//application.zcore.functions.zRedirect("#ss.foreignAdminURL#index?zsid=##request.zsid##");
	}
			');
		}
	}
	echo('
	variables.uploadPath=request.zos.globals.privateHomeDir&"#removeChars(ss.uploadDisplayPath, 1, 1)#";
	variables.displayPath="#ss.uploadDisplayPath#";
	ts={
		// required 
		label:"#ss.friendlyName#",
		pluralLabel:"#ss.friendlyName#",
		tableName:"#ss.tableName#",
		datasource:{datasource},
		deletedField:"#ss.tableName#_deleted",
		primaryKeyField:"#ss.tableName#_id",
		methods:{ // callback functions to customize the manager data and layout
			getListData:"getListData", 
			getListReturnData:"getListReturnData",
			getListRow:"getListRow", // function receives struct named row 
			getEditData:"getEditData",
			getEditForm:"getEditForm",
			beforeUpdate:"beforeUpdate",
			afterUpdate:"afterUpdate",
			beforeInsert:"beforeInsert",
			afterInsert:"afterInsert",
			getDeleteData:"getDeleteData",
			executeDelete:"executeDelete"
		},

		//optional
		requiredParams:[');
		hasRequired=false;
		if(ss.enableForeignKey){
			if(hasRequired){
				echo(', ');
			}
			hasRequired=true;
			echo('"#ss.foreignPrimaryKeyField#" ');
		}
		if(ss.enableParentId){
			if(hasRequired){
				echo(', ');
			}
			hasRequired=true;
			echo('"#ss.parentIdField#" ');
		}
		echo('],
		requiredEditParams:[],

		customInsertUpdate:false,
		');
		if(ss.enableSiteId){
			echo('hasSiteId:true,
			');
		}else{
			echo('hasSiteId:false,
			');
		}
		if(ss.enableSorting){
			echo('sortField:"#ss.tableName#_sort",
			rowSortingEnabled:true,
			');
		}
		if(ss.enableMeta){
			echo('metaField:"#ss.tableName#_meta_json",
			');
		}
		echo('quickLinks:getQuickLinks(),
		');
		echo('imageLibraryFields:[');
		
		fieldAdded=false;
		if(request.hasImageLibraryId){
			echo('"#ss.tableName#_image_library_id",
			');
			fieldAdded=true;
		}
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId]; 
			if(structcount(option.data) NEQ 0 and option.data.site_option_type_id EQ 23){
				if(hasImageLibrary){
					echo(', ');
				}
				fieldAdded=true;
				echo('"#option.fieldName#"
				');
			}
		}
		echo('],
		validateFields:{
			');
			count=0;
			for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
				optionId=fd.arrOptionOrder[i];
				option=fd.options[optionId];
				if(!option.required){
					continue;
				}
				count++;
				if(count NEQ 1){
					echo(', ');
				}
				echo('"#option.fieldName#":{ required:true } ');
			}
			echo('
		},
		imageFields:[],
		fileFields:[],
		// optional
		requireFeatureAccess:"",
		pagination:true,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:10,
		title:"#ss.friendlyName#",
		prefixURL:"#ss.adminURL#",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:true,
		columns:[{
			label:"ID",
			field:"#ss.tableName#_id"
		}');
		if(request.hasImageLibraryId){
			echo(',
			{
				label:"Photo",
				field:"#ss.tableName#_image_library_id"
			}
			');
		}
		if(ss.enableParentId){
			echo(',
			{
				label:"Parent",
				field:"#ss.parentIdField#"
			}
			');
		}
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId]; 
			if(structcount(option.data) EQ 0 or option.data.site_option_primary_field EQ 0){
				continue;
			}
			echo(',{
				label:"#option.label#",
				field:"#option.fieldName#"
			}');
		}
		echo(',
			{
				label:"Updated",
				field:"#ss.tableName#_updated_datetime"
			},
			{
				label:"Admin",
				field:""
			}
		]
	};
	');

	if(ss.enableForeignKey EQ 1){
		echo('
		// these are the foreign table breadcrumbs
		if(request.q#ss.foreignTableName#.recordcount NEQ 0){
			arrayAppend(ts.navLinks, {
				label:"##request.q#ss.foreignTableName#.#ss.foreignNameField###",
				link:"#ss.foreignAdminURL#index"
			});
			arrayAppend(ts.navLinks, {
				label:"#ss.foreignFriendlyName#"
			});
		}
		');
	}
	if(ss.enableParentId){
		echo(' 
		// these are the parent id (same table) breadcrumbs
		db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
		WHERE  
		{tableName}_deleted = ##db.param(0)## ');
		if(ss.enableSiteId){
			echo(' and 
			site_id=##db.param(request.zos.globals.id)## ')
		}
		echo('";
		qAll=db.execute("qAll");
		lookupStruct={};
		for(row in qAll){
			lookupStruct[row.#ss.tableName#_id]={
				parentId:row.#ss.parentIdField#,
				name:"##replace(replace(row.#ss.nameField#, ''"'', ''""'', "all"), "####", "########", "all")##"
			};
		}
		// get parent records in a loop
		i=1;
		arrParent=[];
		currentParent=form.#ss.parentIdField#;
		while(true){
			i++;
			if(currentParent EQ 0){
				break;
			}
			if(structkeyexists(lookupStruct, currentParent)){ 
				arrayprepend(arrParent, {
					link:"{adminURL}index?{tableName}_id=##row.{tableName}_id##&#ss.parentIdField#=##lookupStruct[currentParent].parentId##&#replace(request.appendAdminURL, "#ss.parentIdField#=", "ztv1=", "all")#",
					label:lookupStruct[currentParent].name
				}); 
				currentParent=lookupStruct[currentParent].parentId;
			}else{
				break;
			}
			if(i GT 25){
				throw("Possible infinite loop detected in #ss.parentIdField#");
			}
		}
		if(arrayLen(arrParent) NEQ 0){ 
			for(link in arrParent){
				arrayAppend(ts.navLinks, link);
			}
		}
		');
	}  
	echo('
	super.init(ts); 
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.delete();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	'); 
	if(ss.enableParentId){
		echo('// TODO: need to get parent field to passthrough: #ss.parentIdField#');
	}
	echo('
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
 	init();
	super.index();
	</cfscript>
</cffunction> 

<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
	WHERE {tableName}_id= ##db.param(application.zcore.functions.zso(form,"{tableName}_id"))## and  
	{tableName}_deleted = ##db.param(0)##  ');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('";
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject;  
	for(row in ss.qData){
		');
	if(ss.enableChildAdmin and ss.childCFCPath NEQ "" and ss.childCFCDeleteMethod NEQ ""){
		echo('
		childCom=createobject("component", "#ss.childCFCPath#");

		// select all children
		db.sql="select * from ##db.table("#ss.childTableName#", #ss.datasource#)## 
		WHERE 
		#ss.tableName#_id = ##db.param(row.#ss.childPrimaryKeyId#)## ";
		');
		if(ss.childEnableSiteId){
			echo('
		db.sql&=" and site_id = ##db.param(request.zos.globals.id)## ";
		');
		}
		echo('
		qChildren=db.execute("qChildren");
		for(childRow in qChildren){
			childCom.#ss.childCFCDeleteMethod#(childRow);
		}

		');
	}
	echo('
		deleteRow(row);
	}
	return {success:true};
	</cfscript>
</cffunction>
 

<cffunction name="deleteRow" localmode="modern" access="remote" roles="administrator">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	row=arguments.row;

	/*
	// this code is here if you need to handle files in a custom way.  by default, the manager API will automatically handle deleting these files, unless you remove the field names from the init config.
	');
	if(fd.hasFileFields){
		// process file uploads...
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId];
			if(structcount(option.data) EQ 0){
				continue;
			}
			if(option.data.site_option_type_id EQ 3){
				// image
				echo(' 
	application.zcore.functions.zDeleteFile("#ss.uploadPath#"&row.#option.fieldName#_original);
	application.zcore.functions.zDeleteFile("#ss.uploadPath#"&row.#option.fieldName#);
				');
			}else if(option.data.site_option_type_id EQ 9){
				// file
				echo('
	application.zcore.functions.zDeleteFile("#ss.uploadPath#"&row.#option.fieldName#);
				');

			}else if(option.data.site_option_type_id EQ 23){
				// image library
				echo('
	application.zcore.imageLibraryCom.deleteImageLibraryId(row.#option.fieldName#);
				');
			}else if(option.fieldName EQ ss.tableName&"_image_library_id"){
				// image library
				echo('
	application.zcore.imageLibraryCom.deleteImageLibraryId(row.#ss.tableName#_image_library_id);
				');
			}
		}
	} 

	echo('
	*/
	db.sql="DELETE FROM ##db.table("{tableName}", {datasource})## WHERE 
	{tableName}_id= ##db.param(application.zcore.functions.zso(form, "{tableName}_id"))## and  
	{tableName}_deleted = ##db.param(0)##   ');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('";
	db.execute("qDelete");

	return true; 
	</cfscript> 
</cffunction>


<cffunction name="beforeUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	rs={success:true};

	// handle custom validation here

	');
	if(ss.enableForeignKey){
		echo(' 
	form.#ss.foreignPrimaryKeyField#=application.zcore.functions.zso(form, "#ss.foreignPrimaryKeyField#", true);
	if(form.#ss.foreignPrimaryKeyField# NEQ 0){ 
		if(request.q#ss.foreignTableName#.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid #ss.foreignFriendlyName# selection.", form, true);
			error=true;
		}
	}
		');
	}
	/*

	for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
		optionId=fd.arrOptionOrder[i];
		option=fd.options[optionId];
		if(structcount(option.data) EQ 0){
			continue;
		}
		if(option.data.site_option_type_id EQ 15){
			echo('
	if(form.#option.fieldName# NEQ "" and not application.zcore.functions.zValidateURL(form.#option.fieldName#, false, false)){
		application.zcore.status.setStatus(request.zsid, "#option.data.site_option_display_name# must be a valid URL beginning with / or ##.", form, true);
		error=true;
	}
			');
		}else if(option.data.site_option_type_id EQ 10){
			echo('
	if(form.#option.fieldName# NEQ "" and not application.zcore.functions.zEmailValidate(form.#option.fieldName#)){
		application.zcore.status.setStatus(request.zsid, "#option.data.site_option_display_name# must be a valid email address.", form, true);
		error=true;
	}
			');
		}else if(option.data.site_option_type_id EQ 4){
			echo('
	form.#option.fieldName#=application.zcore.functions.zGetDateTimeSelect("#option.fieldName#", "yyyy-mm-dd", "HH:mm:ss");
			');
		}else if(option.data.site_option_type_id EQ 5){
			echo('
	if(form.#option.fieldName# NEQ ""){
		if(isdate(form.#option.fieldName#)){
			form.#option.fieldName#=dateformat(form.#option.fieldName#, "yyyy-mm-dd");
		}else{
			application.zcore.status.setStatus(request.zsid, "#option.data.site_option_display_name# must be a valid date.", form, true);
			error=true;
		}
	}else{
		form.#option.fieldName#="";
	}
			');
		}else if(option.data.site_option_type_id EQ 6){
			echo('
	if(form.#option.fieldName# NEQ ""){ 
		form.#option.fieldName#=dateformat(form.#option.fieldName#, "HH:mm:ss"); 
	}else{
		form.#option.fieldName#="";
	}
			');
		}
	}
	*/
	if(ss.enableSearch){
		echo('arrSearch=[];
		');
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId];
			if(!option.visible){
				continue;
			}
			echo('arrayAppend(arrSearch, form["'&option.fieldName&'"]);
			');
		}
		echo(' 
		form.{tableName}_search = arrayToList(arrSearch, " ");
		form.{tableName}_search=application.zcore.functions.zCleanSearchText(form.{tableName}_search, true);
			');

	}
	/*

	if(fd.hasFileFields and ss.uploadPath NEQ ""){
		echo('
	fail=false;
	application.zcore.functions.zCreateDirectory("#ss.uploadPath#");
		');
	}
	if(fd.hasFileFields){
		// process file uploads...
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId];
			if(structcount(option.data) EQ 0){
				continue;
			}
			if(option.data.site_option_type_id EQ 3){
				// image 
				photoresize=application.zcore.functions.zso(option.json, 'imagewidth',false,'1000')&"x"&application.zcore.functions.zso(option.json, 'imageHeight',false,'1000');
				if(application.zcore.functions.zso(option.json, 'imagecrop', true, 0) EQ '1'){
					crop="1";
				}else{
					crop="0";
				}
				echo('
	deleting=false;
	if(application.zcore.functions.zso(form, "#option.fieldName#_delete") NEQ ""){
		application.zcore.functions.zDeleteFile("#ss.uploadPath#"&qCheck.#option.fieldName#_original);
		application.zcore.functions.zDeleteFile("#ss.uploadPath#"&qCheck.#option.fieldName#);
		form.#option.fieldName#_original="";
		form.#option.fieldName#="";
		deleting=true;
	}
	if(application.zcore.functions.zso(form, "#option.fieldName#") NEQ ""){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("#option.fieldName#", "#ss.uploadPath#", "#photoresize#","","","",{datasource}, #crop#, request.zos.globals.id, false);
		if(isarray(arrList) EQ false){
			fail=true;
			application.zcore.status.setStatus(request.zsid, "<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a jpeg, png or gif file.<br />"&request.zImageErrorCause, form, true);
		}else if(ArrayLen(arrList) NEQ 0){
			form.#option.fieldName#_original=request.zos.lastUploadFileName; 
			form.#option.fieldName#=arrList[1];
		}
	}else if(form.method EQ "update" and not deleting){
		form.#option.fieldName#_original=qCheck.#option.fieldName#_original;
		form.#option.fieldName#=qCheck.#option.fieldName#;
	}

				');
			}else if(option.data.site_option_type_id EQ 9){
				// file
				
				echo(' 
	deleting=false;
	if(application.zcore.functions.zso(form, "#option.fieldName#_delete") NEQ ""){
		application.zcore.functions.zDeleteFile("#ss.uploadPath#"&qCheck.#option.fieldName#); 
		form.#option.fieldName#="";
		deleting=true;
	}
	if(application.zcore.functions.zso(form, "#option.fieldName#") NEQ ""){
		form.#option.fieldName#=application.zcore.functions.zUploadFileToDb("#option.fieldName#", "#ss.uploadPath#", "#ss.tableName#", "#ss.tableName#_id", application.zcore.functions.zso(form, "#option.fieldName#_delete", true, 0), {datasource}); 
	}else if(form.method EQ "update" and not deleting){ 
		form.#option.fieldName#=qCheck.#option.fieldName#;
	}
				');

			}
		} 
		echo(' 
	if(fail){	
		if(form.method EQ "insert"){
			application.zcore.functions.zRedirect("{adminURL}add?zsid=##request.zsid###request.appendAdminURL#");
		}else{
			application.zcore.functions.zRedirect("{adminURL}edit?{tableName}_id=##form.{tableName}_id##&zsid=##request.zsid###request.appendAdminURL#");
		}
	}  
		');
	}
	*/
	echo('
	db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
	WHERE  
	{tableName}_deleted = ##db.param(0)## and  
	{tableName}_id=##db.param(form.{tableName}_id)##');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('";
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	// you can optional make insert have custom validation

	rs=beforeUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.{tableName}_id=application.zcore.functions.zso(form, "{tableName}_id", true, 0);
	db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
	WHERE  
	{tableName}_deleted = ##db.param(0)## and  
	{tableName}_id=##db.param(form.{tableName}_id)##');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('"; 
	rs={}; 
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;
	form.{tableName}_id=application.zcore.functions.zso(form, "{tableName}_id", true, 0);
	');
	if(request.hasImageLibraryId){
		echo('
		ts=structnew();
		ts.image_library_id_field="{tableName}.{tableName}_image_library_id";
		ts.count = 1; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="SELECT * ##db.trustedsql(rs.select)## 
		FROM ##db.table("{tableName}", {datasource})##
		##db.trustedsql(rs.leftJoin)## 
		WHERE  
		{tableName}_deleted = ##db.param(0)## and  
		{tableName}_id=##db.param(form.{tableName}_id)##');
		if(ss.enableSiteId){
			echo(' and 
			site_id=##db.param(request.zos.globals.id)## ');
		}
		echo(' GROUP BY {tableName}.{tableName}_id "; ');
	}else{
		echo('
		db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
		WHERE  
		{tableName}_deleted = ##db.param(0)## and  
		{tableName}_id=##db.param(form.{tableName}_id)##');
		if(ss.enableSiteId){
			echo(' and 
			site_id=##db.param(request.zos.globals.id)## ')
		}
		echo('";
		');
	}
	echo('
	rs={};
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>


<cffunction name="getEditForm" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 

	rs={
		javascriptChangeCallback:"",
		javascriptLoadCallback:"",
		tabs:{
			"Basic":{
				fields:[]
			},
			"Advanced":{
				fields:[]
			}
		}
	};
	// basic fields
	fs=[];
	');
	if(ss.enableForeignKey){
		echo(' 
		savecontent variable="field"{
			db.sql="select * from ##db.table("#ss.foreignTableName#", #ss.datasource#)## ";
			q#ss.foreignTableName#=db.execute("q#ss.foreignTableName#"); 
			ts = StructNew();
			ts.name = "#ss.foreignPrimaryKeyField#"; 
			ts.size = 1; // more for multiple select 
			ts.query = q#ss.foreignTableName#;
			');
			if(ss.foreignRequired){
				echo('
			ts.hideSelect=true;
			');
			}
			echo('
			ts.queryLabelField = "#ss.foreignNameField#";
			ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
			ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
			ts.queryValueField = "#ss.foreignPrimaryKeyField#"; 
			application.zcore.functions.zInputSelectBox(ts);
		}
		arrayAppend(fs, {label:"#ss.foreignFriendlyName#", required:true, field:field});
		');
	}
	if(ss.enableParentId){
		echo('  
		savecontent variable="field"{
			db.sql="select * from ##db.table("#ss.tableName#", #ss.datasource#)## 
			ORDER BY #ss.nameField# asc";
			qParent=db.execute("qParent"); 
			ts = StructNew();
			ts.name = "#ss.parentIdField#"; 
			ts.size = 1; // more for multiple select 
			ts.query = qParent; 
			ts.onchange="for(var i in this.options){ if(this.options[i].selected && this.options[i].value != '''' && this.options[i].value==''##application.zcore.functions.zso(form, "#ss.tableName#_id")##''){alert(''You can\''t select the same item you are editing.'');this.selectedIndex=0;}; }";
			ts.queryLabelField = "#ss.nameField#";
			ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
			ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
			ts.queryValueField = "#ss.tableName#_id"; 
			application.zcore.functions.zInputSelectBox(ts);
		}
		arrayAppend(fs, {label:"Parent", required:true, field:field});
		');
	}
	for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
		optionId=fd.arrOptionOrder[i];
		option=fd.options[optionId]; 
		if(!option.visible){
			continue;
		}
		echo('  
		</cfscript>
		<cfsavecontent variable="field">
		');
			if(structcount(option.data) NEQ 0 and option.data.site_option_default_value NEQ ""){
				echo('
				<cfscript>
				if(application.zcore.functions.zso(form, "#option.fieldName#") EQ ""){
					form["#option.fieldName#"]=replace(replace("#option.data.site_option_default_value#", "####", "########", "all"), ''"'', "''", "all");
				}
				</cfscript>
				');
			}
			echo('#trim(option.formField)#');
		echo(' 
		</cfsavecontent>
		<cfscript>
		arrayAppend(fs, {label:"#option.label#", ');
		if(option.required){
			echo('required: true, ');
		}
		echo(' field:field});
		');
	}
	echo('
	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo(''<input type="text" name="{tableName}_advanced" value="##htmleditformat(form.{tableName}_advanced)##" />'');
	}
	arrayAppend(fs, {label:"Advanced Field", field:field});

	rs.tabs.advanced.fields=fs; 
	*/

	return rs;
	</cfscript> 
</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.{tableName}_id=application.zcore.functions.zso(form, "{tableName}_id", true, 0);
	');
	if(ss.enableSearch){
		echo('	form.{tableName}_search=application.zcore.functions.zso(form, "{tableName}_search"); 
		searchOn=false; 
		cleanSearch=application.zcore.functions.zCleanSearchText(form.{tableName}_search);
		');
	}


	if(request.hasImageLibraryId){
		echo('
		ts=structnew();
		ts.image_library_id_field="{tableName}.{tableName}_image_library_id";
		ts.count = 1; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts); 
		');
	}
	echo('
	db.sql="SELECT * ";
	');

	if(ss.enableSearch){
		echo('
		if(form.{tableName}_search NEQ ""){

			db.sql &= ", IF ( concat(`{tableName}`.{tableName}_id, ##db.param(" ")##, `{tableName}`.{tableName}_search) LIKE ##db.param("%"& application.zcore.functions.zURLEncode( form.{tableName}_search, "%")&"%")##, ##db.param("1")##, ##db.param("0")## ) exactMatch,
				MATCH( `{tableName}`.{tableName}_search) AGAINST(##db.param(cleanSearch)##) relevance ";
		}
		');
	} 
	if(request.hasImageLibraryId){
		echo('
		db.sql&=" 
		#db.trustedsql(rs.select)#  ');
	}
	echo('
	db.sql&=" FROM ##db.table("{tableName}", {datasource})## ');

	if(request.hasImageLibraryId){
		echo(' 
		##db.trustedsql(rs.leftJoin)## ');
	}
	echo(' 
	WHERE  
	{tableName}_deleted = ##db.param(0)## and   
	#ss.parentIdField# = ##db.param(form.#ss.parentIdField#)## ');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ');
	}
	echo(' "; 
	');
	if(ss.enableSearch){ 
		echo('
	if(form.{tableName}_search NEQ ""){
		searchOn=true;
		db.sql&=" and (
			MATCH({tableName}_search) AGAINST (##db.param(cleanSearch)##) or 
			{tableName}_search like ##db.param("%##application.zcore.functions.zURLEncode(form.{tableName}_search, "%")##%")## or {tableName}.{tableName}_id =##db.param(form.{tableName}_search)##) ";
	}  '); 
	}
	if(request.hasImageLibraryId){
		echo(' 
		db.sql&=" GROUP BY {tableName}.{tableName}_id "; 
		');
	}
	arrOrder=[];
	if(ss.enableSorting){
		arrayAppend(arrOrder, ss.tableName&"."&ss.tableName&"_sort ASC");
	}else{
		for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
			optionId=fd.arrOptionOrder[i];
			option=fd.options[optionId]; 
			if(structcount(option.data) EQ 0 or option.data.site_option_admin_sort_field EQ 0){
				continue;
			}
			arrayAppend(arrOrder, ss.tableName&"."&option.fieldName&" ASC");
		}
		if(arraylen(arrOrder) EQ 0){
			arrayAppend(arrOrder, ss.tableName&"."&ss.tableName&"_id ASC");
		}
	}
	echo('
	sortColumnSQL=getSortColumnSQL();
	if(sortColumnSQL NEQ ""){
		db.sql&=" ORDER BY ##sortColumnSQL## #arrayToList(arrOrder, ', ')# ";
	}else{
		db.sql&=" ORDER BY #arrayToList(arrOrder, ', ')# ";
	}
	db.sql&=" LIMIT ##db.param((form.zIndex-1)*variables.perpage)##, ##db.param(variables.perpage)## ";
	rs={};
	rs.qData=db.execute("qData");  

	rs.searchFields=[ ');

	if(ss.enableSearch){
		echo('{
			fields:[{
				formField:''<input type="text" name="{tableName}_search" style="min-width:200px;width:200px;" value="##htmleditformat(form.{tableName}_search)##"> '',
				field:"{tableName}_search"
			}]
		}');
	}
	echo('];
 
	db.sql="SELECT count(*) count FROM ##db.table("{tableName}", {datasource})##
	WHERE  
	{tableName}_deleted = ##db.param(0)## and  
	#ss.parentIdField# = ##db.param(form.#ss.parentIdField#)## ');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('"; ');
	if(ss.enableSearch){

		echo('
	if(form.{tableName}_search NEQ ""){
		searchOn=true;
		db.sql&=" and (
			MATCH({tableName}_search) AGAINST (##db.param(cleanSearch)##) or 
			{tableName}_search like ##db.param("%##application.zcore.functions.zURLEncode(form.{tableName}_search, "%")##%")## or {tableName}.{tableName}_id =##db.param(form.{tableName}_search)##) ";
	}  ');

	}
	echo('
	rs.qCount=db.execute("qCount");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListRow" localmode="modern" access="private">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="columns" type="array" required="yes">
	<cfscript>
	row=arguments.row;
	columns=arguments.columns; 
	arrayAppend(columns, {field: row.{tableName}_id});');
	if(request.hasImageLibraryId){
		echo('
		savecontent variable="field"{
			ts=structnew();
			ts.image_library_id=row.{tableName}_image_library_id;
			ts.output=false;
			ts.struct=row;
			ts.size="100x70";
			ts.crop=0;
			ts.count = 1; // how many images to get
			//zdump(ts);
			arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts); 
			for(i=1;i LTE arraylen(arrImages);i++){
				writeoutput(''<img src="'&arrImages[i].link&'">'');
			} 
		}
		arrayAppend(columns, {field: field, style:"width:100px; vertical-align:top; " });
		');
	} 
	if(ss.enableParentId){
		echo(' 
		arrayAppend(columns, {field: row.#ss.parentIdField# });');
	}
	for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
		optionId=fd.arrOptionOrder[i];
		option=fd.options[optionId]; 
		if(structcount(option.data) EQ 0 or option.data.site_option_primary_field EQ 0){
			continue;
		}
		if(option.data.site_option_type_id EQ 3){
			// image
			echo(' 
			if(row.#option.fieldName# EQ ""){ 
				arrayAppend(columns, {field: "" }); 
			}else{
				arrayAppend(columns, {field: ''<img src="##variables.displayPath&row.#option.fieldName###" alt="" width="100">'' });
			}
			');
		}else if(option.data.site_option_type_id EQ 9){
			// file  
			echo(' if(row.#option.fieldName# EQ ""){ 
				field="&nbsp;";
			}else{
			');
			if(application.zcore.functions.zso(option.json, 'file_securepath', false, "No") EQ 'Yes'){ 
				field='
				<a href="##request.zos.globals.domain##/z/misc/download/index?fp=##urlencodedformat(variables.displayPath&row.#option.fieldName#)##" target="_blank">Download File</a>';
			}else{
				field='
				<a href="##request.zos.globals.domain&variables.displayPath&row.#option.fieldName###" target="_blank">Download File</a>';
			}
			echo(' 
			}
			arrayAppend(columns, {field: field });');

		}else if(option.data.site_option_type_id EQ 10){
			echo(' 
			if(row.#option.fieldName# EQ ""){ 
				arrayAppend(columns, {field: "" }); 
			}else{
				arrayAppend(columns, {field: ''<a href="mailto:##row.#option.fieldName###">##row.#option.fieldName###</a>'' });
			}
			');
		}else if(option.data.site_option_type_id EQ 18){
			echo('
			field=''<div style="width:25px; height:25px; background-color:####''&row.#option.fieldName#&''; " title="##''&row.#option.fieldName#&''"></div> '';
			arrayAppend(columns, {field: field });
			');
		}else if(option.data.site_option_type_id EQ 15){
			echo('
			if(row.#option.fieldName# EQ ""){ 
				field="&nbsp;";
			}else{
				field=''<a href="##row.#option.fieldName###" target="_blank">''&application.zcore.functions.zLimitStringLength(row.#option.fieldName#, 50)&''</a>'';
			}
			arrayAppend(columns, {field: field });
			');

		}else{
			echo(' 
			arrayAppend(columns, {field: row.#option.fieldName# });');
		}
	}
	echo('

	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.{tableName}_updated_datetime)}); '); 
	echo(' 
	savecontent variable="field"{ 
	');

	if(ss.enableSorting){
		echo(' displayRowSortButton(row.{tableName}_id);
		');
	}
	echo('
		editLinks=[{
			label:"Edit",
			link:variables.prefixURL&"edit?{tableName}_id=##row.{tableName}_id##&modalpopforced=1&#request.appendAdminURL#",
			enableEditAjax:true // only possible for the link that replaces the current row
		}');
	if(ss.enableChildAdmin){
		echo(',{
			label:"Manage #ss.childFriendlyName#",
			link:"{adminURL}index?{tableName}_id=##row.{tableName}_id##&#ss.parentIdField#=##row.#ss.primaryKeyField###&#replace(request.appendAdminURL, "#ss.parentIdField#=", "ztv1=", "all")#",
		}
		');
	}
	echo('];
		ts={
			buttons:[{
				title:"View",
				icon:"eye",
				link:"{adminURL}view?{tableName}_id=##row.{tableName}_id###request.appendAdminURL#",
				label:"",
				target:"_blank"
			},{
				title:"Edit",
				icon:"cog",
				links:editLinks,
				label:""
			},{
				title:"Delete",
				icon:"trash",
				link:"{adminURL}delete?{tableName}_id=##row.{tableName}_id##&amp;returnJson=1&amp;confirm=1#request.appendAdminURL#",
				label:"",
				enableDeleteAjax:true
			}]
		}; 
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:200px; max-width:100%;"});
	</cfscript> 
</cffunction>	

<cffunction name="view" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	form.{tableName}_id=application.zcore.functions.zso(form, "{tableName}_id", true, 0);
	db.sql="SELECT * FROM ##db.table("{tableName}", {datasource})##
	WHERE  
	{tableName}_deleted = ##db.param(0)## and  
	{tableName}_id=##db.param(form.{tableName}_id)##');
	if(ss.enableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('";
	q{tableName}=db.execute("q{tableName}");
	if(q{tableName}.recordcount EQ 0){
		application.zcore.functions.z404("Invalid {tableName}_id: ##form.{tableName}_id##");
	}
	');
	if(ss.enableForeignKey){
		echo(' 
	db.sql="SELECT * 
	 from ##db.table("#ss.foreignTableName#", #ss.datasource#)##  
	WHERE  
	#ss.foreignTableName#_deleted = ##db.param(0)## and 
	#ss.foreignPrimaryKeyField# = ##db.param(q{tableName}.#ss.foreignPrimaryKeyField#)## ');
	if(ss.foreignEnableSiteId){
		echo(' and 
		site_id=##db.param(request.zos.globals.id)## ')
	}
	echo('"; 
	q#ss.foreignTableName#=db.execute("q#ss.foreignTableName#"); 
	');
	if(ss.foreignRequired){
		echo('
	if(q#ss.foreignTableName#.recordcount NEQ 0){
		echo(''<p><a href="#ss.foreignAdminURL#view?#ss.foreignPrimaryKeyField#=##q#ss.foreignTableName#.#ss.foreignPrimaryKeyField###">##q#ss.foreignTableName#.#ss.foreignNameField###</a> /</p>'');
	}
			');
		}
	}
	echo('
	echo(''
	<style type="text/css">
	.view-row{width:100%; float:left; margin-bottom:5px; padding:5px; border-bottom:1px solid ####CCC; }
	.view-label{ width:100%; float:left; width:30%; min-width:150px; max-width:250px; }
	.view-value{ width:100%; float:left; width:70%; min-width:250px; max-width:100%; }
	</style>
	<h1>#ss.friendlyName#</h1>
	'');
	for(row in q{tableName}){ 
	');
	for(i=1;i<=arraylen(fd.arrOptionOrder);i++){
		optionId=fd.arrOptionOrder[i];
		option=fd.options[optionId];  
		if(structcount(option.data) EQ 0 or option.data.site_option_type_id EQ 11){
			continue;
		}
		echo('
		echo(''<div class="view-row">
			<div class="view-label">#replace(option.data.site_option_display_name, "##", "####", "all")#</div>
			<div class="view-value">##row.#option.fieldName###</div>
		</div>''&chr(10));');
	}
	echo('
	}
	');

	if(ss.enableChildAdmin){
		echo(' 
	try{
		// select all children
		db.sql="select * from ##db.table("#ss.childTableName#", #ss.datasource#)## 
		WHERE  
		{tableName}_deleted=##db.param(0)## and 
		{tableName}_id = ##db.param(form.{tableName}_id)## ";
		');
		if(ss.childEnableSiteId){
			echo('
		db.sql&=" and site_id = ##db.param(request.zos.globals.id)## ";
		');
		}
		echo('
		echo(''<h2>#ss.childFriendlyName#</h2>'');
		qChildren=db.execute("qChildren");
		for(childRow in qChildren){
			echo(''<div class="view-row">'');
			writedump(childRow);
			echo(''</div>'');
			break;

		} 
	}catch(Any e){
		echo("Failed to get children.");
		writedump(e);
		abort;
	}
	');
	}
	echo('
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>');
</cfscript>
</cfsavecontent>
	<cfscript>
	templateCode=replace(templateCode, '{tableName}', ss.tableName, "all");
	templateCode=replace(templateCode, '{datasource}', ss.datasource, "all");
	templateCode=replace(templateCode, '{friendlyName}', ss.friendlyName, "all");
	templateCode=replace(templateCode, '{adminURL}', ss.adminURL, "all");

	return templateCode;
	</cfscript>

</cffunction>
</cfoutput>
</cfcomponent>