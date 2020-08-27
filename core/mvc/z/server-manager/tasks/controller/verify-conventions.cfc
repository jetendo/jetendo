<cfcomponent>
<cfoutput>
<cffunction name="verifyCFClocalmode" access="private" localmode="modern" hint="Jetendo Core should always use localmode=""modern"" except for Application.cfc's onRequest function.">
	<cfargument name="arrLog" type="array" required="yes">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="cfcMapping" type="string" required="yes">
	<cfscript>
	directory action="list" recurse="true" directory="#arguments.path#" name="qDir" filter="*.cfc";
	for(row in qDir){
		globalsBackup=request.zos.globals;
		absPath=row.directory&"/"&row.name;
		cfcPath=replace(replace(absPath, arguments.path, arguments.cfcMapping&"."), "/", ".", "all");
		cfcPath=left(cfcPath, len(cfcPath)-4);
		if(left(cfcPath, len("zcorerootmapping.mvc.z.test.")) EQ "zcorerootmapping.mvc.z.test."){
			// skip test files because mxunit isn't compatible with localmode yet.
			continue;
		}
		md=getcomponentmetadata(cfcPath);
		if(structkeyexists(md, 'functions')){
			for(i=1;i LTE arraylen(md.functions);i++){
				c=md.functions[i];
				if(not structkeyexists(c, 'localmode') or c.localmode NEQ "modern"){
					arrayAppend(arguments.arrLog, row.directory&"/"&row.name&" | localmode=""modern"" is missing for function: "&c.name);
				}
			}
		}
		request.zos.globals=globalsBackup;
	}
	</cfscript>
</cffunction>

<cffunction name="verifyApplicationDotCFClocalmode" access="private" localmode="modern" hint="Jetendo Core should always use localmode=""modern"" except for Application.cfc's onRequest function.">
	<cfargument name="arrLog" type="array" required="yes">
	<cfscript>
	md=getapplicationsettings();
	for(i in md){
		if(isCustomFunction(md[i])){
			c=getmetadata(md[i]);
			if(i NEQ "onRequest"){
				if(not structkeyexists(c, 'localmode') or c.localmode NEQ "modern"){
					arrayAppend(arguments.arrLog, "#request.zos.installPath#core/Application.cfc | localmode=""modern"" is missing for function: "&i);
				}
			}else{
				if(not structkeyexists(c, 'localmode') or c.localmode NEQ "classic"){
					arrayAppend(arguments.arrLog, "#request.zos.installPath#core/Application.cfc | localmode=""classic"" is missing for function: "&i);
				}
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="verifySiteConventions" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	arrLog=[];
	db=request.zos.queryObject;
	form.sid=application.zcore.functions.zso(form, 'sid');
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# site 
	where site_id = #db.param(form.sid)# and 
	site_deleted = #db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		echo("The site doesn't exist.");
	}
	echo('<h2>Verify Conventions For Site: <a href="#qSite.site_domain#" target="_blank">#qSite.site_domain#</a></h2>');
	// need a way of disabling sites that I don't want to verify, so this is not alerting excessively.
	homedir=application.zcore.functions.zvar("homedir", form.sid);
	privatehomedir=application.zcore.functions.zvar("privatehomedir", form.sid);

	mapping=replace(replace(replace(qSite.site_short_domain, "www.", ""), "."&request.zos.testDomain, ""), ".", "_", "all");


	verifyCFClocalmode(arrLog, homedir, mapping);
	//verifyCFClocalmode(arrLog, privatehomedir, mapping);

	outputLog(arrLog);
	abort;
	</cfscript>
</cffunction>

<cffunction name="outputLog" localmode="modern" access="private">
	<cfargument name="arrLog" type="array" required="yes">
	<cfscript>
	
	if(arraylen(arguments.arrLog)){
		echo("The following problems were detected:<br />");
		for(i=1;i LTE arraylen(arguments.arrLog);i++){
			echo(arguments.arrLog[i]&"<br>");
		} 
	}else{
		echo("No problems detected with following conventions.<br />");
	}
	echo("All CFCs are able to be compiled by the CFML Server.<br />");
	</cfscript>

</cffunction>
	
<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	arrLog=[];
	echo('<h2>Verify Conventions</h2>');
	
	verifyApplicationDotCFClocalmode(arrLog);
	application.zcore.functions.checkIfCronJobAllowed();
	
	verifyCFClocalmode(arrLog, request.zos.installPath&"core/", "zcorerootmapping");
	verifyCFClocalmode(arrLog, request.zos.installPath&"themes/", "jetendo-themes");

	outputLog(arrLog);
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>