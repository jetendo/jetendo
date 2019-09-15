<cfcomponent>
<cfoutput>
<!--- /z/feature/admin/feature-test/index --->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setId=1;
	schemaId=1;
	fieldId=2;
	writedump(application.zcore.featureData);abort;
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	ts={};
	featureCacheCom.rebuildFeaturesCache(ts, true);
	structappend(application.zcore.featureData, ts, true); 
	echo('cool');
	abort;

	application.zcore.featureCom.onSiteStart(application.siteStruct[request.zos.globals.id]);

	writedump(application.siteStruct[request.zos.globals.id].featureStruct.featureIdList);
	// application.siteStruct[arguments.key].globals["featureData"]={};

	echo("application.zcore.featureData");
	//writedump(application.zcore.featureData);abort;

	db=request.zos.queryObject;
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	ts={};
	featureCacheCom.rebuildFeaturesCache(ts, true);
	structappend(application.zcore, ts, true); 

	featureCacheCom.updateSchemaCache(ts);
	//writedump(ts);

	// for debugging new caching
	featureCacheCom.updateSchemaSetIdCache(23, 1); 

	homePage=application.zcore.featureCom.getSchemaSetById("coolFeature", ["Code123"], setId);
	writedump(homePage); 

	arrFeature=application.zcore.featureCom.getFeatureSchemaArray("coolFeature", "Feature");
	writedump(arrFeature);

	feature_id=application.zcore.featureCom.getFeatureIDByName("coolFeature");

	s=application.zcore.featureCom.getSchemaById(feature_id, schemaId);
	writedump(s);
	s=application.zcore.featureCom.getSchemaNameById(feature_id, schemaId);
	writedump(s);
	s=application.zcore.featureCom.getSchemaNameArrayById(feature_id, schemaId);
	writedump(s);


	s=application.zcore.featureCom.getFieldFieldById(feature_id, fieldId);
	writedump(s);
	
	s=application.zcore.featureCom.getFieldFieldNameById(feature_id, fieldId);
	writedump(s);
	
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>