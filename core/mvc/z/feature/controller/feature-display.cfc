<cfcomponent>
<cffunction name="insert" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.features");
	featureCom.publicInsertSchema();
	</cfscript>
</cffunction>

<cffunction name="insertAndReturn" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.features");
	rs=featureCom.publicAjaxInsertSchema();
	return rs;
	</cfscript>
</cffunction>


<cffunction name="ajaxInsert" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.features");
	rs=featureCom.publicAjaxInsertSchema();
    if(not rs.success){
    	arrError=application.zcore.status.getErrors(rs.zsid);
    	rs.errorMessage=arrayToList(arrError, chr(10));
    	rs.arrErrorField=application.zcore.status.getErrorFields(rs.zsid);
    }
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote">
	<cfscript>
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true);
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.features");
	featureCom.publicAddSchema();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');

	sog=application.siteStruct[request.zos.globals.id].globals.soSchemaData;
	setStruct={}; 
	if(structkeyexists(sog, 'optionSchemaSetQueryCache') and structkeyexists(sog.optionSchemaSetQueryCache, form.site_x_option_group_set_id)){
		setStruct=duplicate(sog.optionSchemaSetQueryCache[form.site_x_option_group_set_id]); 
	}else{
		db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# site_x_option_group_set,
		#db.table("feature_schema", "jetendofeature")# 
		WHERE site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
		feature_schema_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		feature_schema_enable_unique_url=#db.param(1)# and 
		feature_schema.feature_schema_id = site_x_option_group_set.feature_schema_id and 
		site_x_option_group_set.site_id = feature_schema.site_id and 
		site_x_option_group_set.feature_id=#db.param(form.feature_id)# ";
		if(not structkeyexists(form, 'zpreview')){
			db.sql&=" and site_x_option_group_set.site_x_option_group_set_approved=#db.param(1)#";
		}
		qSet=db.execute("qSet");
		for(row in qSet){
			setStruct=row;
			if(not structkeyexists(form, 'zpreview')){
				if(request.zos.enableSiteSchemaCache and setStruct.feature_schema_enable_cache EQ 1){
					sog.optionSchemaSetQueryCache[form.site_x_option_group_set_id]=setStruct;
				}
			}
		}
	} 

	if(not structcount(setStruct)){
		application.zcore.functions.z404("form.site_x_option_group_set_id, #form.site_x_option_group_set_id#, doesn't exist.");
	} 
	echo('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/feature/admin/features/editSchema?feature_id=#setStruct.feature_id#&feature_schema_id=#setStruct.feature_schema_id#&site_x_option_group_set_id=#setStruct.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#setStruct.site_x_option_group_set_parent_id#&returnURL=#urlencodedformat(request.zos.originalURL)#">');
	if(setStruct.feature_schema_enable_meta EQ "1"){
		if(setStruct.site_x_option_group_set_metatitle EQ ""){
			application.zcore.template.setTag("title", setStruct.site_x_option_group_set_title);
		}else{
			application.zcore.template.setTag("title", setStruct.site_x_option_group_set_metatitle);
		}
		application.zcore.template.prependTag('meta', '<meta name="keywords" content="#htmleditformat(setStruct.site_x_option_group_set_metakey)#" /><meta name="description" content="#htmleditformat(setStruct.site_x_option_group_set_metadesc)#" />');
	}else{
		application.zcore.template.setTag("title", setStruct.site_x_option_group_set_title);
	}
	if(structkeyexists(form, 'zURLName')){
		encodedTitle=application.zcore.functions.zURLEncode(setStruct.site_x_option_group_set_title, '-');
		if(setStruct.site_x_option_group_set_override_url NEQ ""){
			if(compare(setStruct.site_x_option_group_set_override_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(setStruct.site_x_option_group_set_override_url);
			}
		}else{
			if(compare(form.zURLName, encodedTitle) NEQ 0){
				application.zcore.functions.z301Redirect("/#encodedTitle#-#request.zos.globals.optionSchemaURLID#-#setStruct.site_x_option_group_set_id#.html");
			}
		}
	}
	if(setStruct.feature_schema_view_cfc_path NEQ ""){
		if(left(setStruct.feature_schema_view_cfc_path, 5) EQ "root."){
			cfcpath=replace(setStruct.feature_schema_view_cfc_path, 'root.',  request.zRootCfcPath);
		}else{
			cfcpath=setStruct.feature_schema_view_cfc_path;
		}
		if(request.zos.zreset EQ "site" or not request.zos.enableSiteTemplateCache){
			forceNew=true;
		}else{
			forceNew=false;
		}
		groupCom=application.zcore.functions.zcreateobject("component", cfcpath, forceNew); 
		// faster
		qSet=QueryNew(  "site_x_option_group_set_id" , "numeric" , { site_x_option_group_set_id: [setStruct.site_x_option_group_set_id] } );
		// old method sent too much
		// QueryAddColumn(qSet, "site_x_option_group_set_id", "VARCHAR", [setStruct.site_x_option_group_set_id]);
		//  qSet = QueryNew("");
		// for(i in setStruct){ 
		// 	if(isnull(setStruct[i])){
		//     	QueryAddColumn(qSet, i, "VARCHAR", [""]); 
		// 	}else{
		//     	QueryAddColumn(qSet, i, "VARCHAR", [setStruct[i]]); 
		//     }
		// }
		// if(not structkeyexists(setStruct, 'recordcount')){
		// 	QueryAddColumn(qSet, "recordcount", "VARCHAR", [1]);
		// }
		groupCom[setStruct.feature_schema_view_cfc_method](qSet);
	}else{
		application.zcore.functions.z404("feature_schema_view_cfc_path and feature_schema_view_cfc_method must be set when editing the site option group to allow rendering of the group.");
	}
	echo('</div>');
	
	</cfscript>
</cffunction>
</cfcomponent>