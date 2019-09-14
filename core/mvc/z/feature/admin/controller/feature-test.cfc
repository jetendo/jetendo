<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setId=1;
	groupId=1;
	db=request.zos.queryObject;
	db.sql="select * from #db.table("untest", "jetendofeature")#";
	qT=db.execute("qT");
	for(row in qT){
		id=row.untest_uuid;
		echo(id&" | "&"<br>");
	}
	abort;
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.debugCacheRebuild();
	homePage=application.zcore.featureCom.getSchemaSetById("coolFeature", ["Code123"], setId);
	writedump(homePage);
	abort;

	arrFeature=application.zcore.featureCom.getFeatureSchemaArray("coolFeature", "Feature");
	writedump(arrFeature);

	s=application.zcore.featureCom.getSchemaById(groupId);
	writedump(s);
	s=application.zcore.featureCom.getSchemaNameById(groupId);
	writedump(s);
	s=application.zcore.featureCom.getSchemaNameArrayById(groupId);
	writedump(s);

	s=application.zcore.featureCom.getFieldFieldById(fieldId);
	writedump(s);
	
	s=application.zcore.featureCom.getFieldFieldNameById(fieldId);
	writedump(s);
	
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>