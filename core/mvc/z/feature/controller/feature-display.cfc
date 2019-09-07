<cfcomponent>
<cffunction name="insert" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
	featureCom.publicInsertSchema();
	</cfscript>
</cffunction>

<cffunction name="insertAndReturn" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
	rs=featureCom.publicAjaxInsertSchema();
	return rs;
	</cfscript>
</cffunction>


<cffunction name="ajaxInsert" localmode="modern" access="remote">
	<cfscript>
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
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
	featureCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
	featureCom.publicAddSchema();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');

	sog=application.siteStruct[request.zos.globals.id].globals.featureSchemaData;
	setStruct={}; 
	if(structkeyexists(sog, 'featureSchemaSetQueryCache') and structkeyexists(sog.featureSchemaSetQueryCache, form.feature_data_id)){
		setStruct=duplicate(sog.featureSchemaSetQueryCache[form.feature_data_id]); 
	}else{
		db.sql="select * from #db.table("feature_data", "jetendofeature")# feature_data,
		#db.table("feature_schema", "jetendofeature")# 
		WHERE feature_data_id = #db.param(form.feature_data_id)# and 
		feature_schema_deleted = #db.param(0)# and 
		feature_data_master_set_id = #db.param(0)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_schema_enable_unique_url=#db.param(1)# and 
		feature_schema.feature_schema_id = feature_data.feature_schema_id and 
		feature_data.site_id = feature_schema.site_id and 
		feature_data.feature_id=#db.param(form.feature_id)# ";
		if(not structkeyexists(form, 'zpreview')){
			db.sql&=" and feature_data.feature_data_approved=#db.param(1)#";
		}
		qSet=db.execute("qSet");
		for(row in qSet){
			setStruct=row;
			if(not structkeyexists(form, 'zpreview')){
				if(request.zos.enableSiteOptionGroupCache and setStruct.feature_schema_enable_cache EQ 1){
					sog.featureSchemaSetQueryCache[form.feature_data_id]=setStruct;
				}
			}
		}
	} 

	if(not structcount(setStruct)){
		application.zcore.functions.z404("form.feature_data_id, #form.feature_data_id#, doesn't exist.");
	} 
	echo('<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/feature/admin/features/editSchema?feature_id=#setStruct.feature_id#&feature_schema_id=#setStruct.feature_schema_id#&feature_data_id=#setStruct.feature_data_id#&feature_data_parent_id=#setStruct.feature_data_parent_id#&returnURL=#urlencodedformat(request.zos.originalURL)#">');
	if(setStruct.feature_schema_enable_meta EQ "1"){
		if(setStruct.feature_data_metatitle EQ ""){
			application.zcore.template.setTag("title", setStruct.feature_data_title);
		}else{
			application.zcore.template.setTag("title", setStruct.feature_data_metatitle);
		}
		application.zcore.template.prependTag('meta', '<meta name="keywords" content="#htmleditformat(setStruct.feature_data_metakey)#" /><meta name="description" content="#htmleditformat(setStruct.feature_data_metadesc)#" />');
	}else{
		application.zcore.template.setTag("title", setStruct.feature_data_title);
	}
	if(structkeyexists(form, 'zURLName')){
		encodedTitle=application.zcore.functions.zURLEncode(setStruct.feature_data_title, '-');
		if(setStruct.feature_data_override_url NEQ ""){
			if(compare(setStruct.feature_data_override_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(setStruct.feature_data_override_url);
			}
		}else{
			if(compare(form.zURLName, encodedTitle) NEQ 0){
				application.zcore.functions.z301Redirect("/#encodedTitle#-50-#setStruct.feature_data_id#.html");
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
		qSet=QueryNew(  "feature_data_id" , "numeric" , { feature_data_id: [setStruct.feature_data_id] } );
		// old method sent too much
		// QueryAddColumn(qSet, "feature_data_id", "VARCHAR", [setStruct.feature_data_id]);
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
		application.zcore.functions.z404("feature_schema_view_cfc_path and feature_schema_view_cfc_method must be set when editing the Feature Schema to allow rendering of the group.");
	}
	echo('</div>');
	
	</cfscript>
</cffunction>
</cfcomponent>