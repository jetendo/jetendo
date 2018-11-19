<cfcomponent output="no">
	<cffunction name="new" localmode="modern" returntype="any" output="no">
    	<cfargument name="modelName" type="string" required="yes">
    	<cfargument name="mvcPath" type="string" required="no" default="#request.zos.zcorerootmapping#.mvc">
    	<cfscript>
		
		local.path=arguments.mvcPath&".model."&arguments.modelName;
		if(structkeyexists(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache, local.path)){
			local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
		}else{
			local.absPath=request.zos.globals.homedir&replace(arguments.mvcPath&".model."&arguments.modelName,".","/","all")&".cfc";
			if(fileexists(local.absPath)){
				// extended model
				application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component",arguments.mvcPath&".model."&arguments.modelName);
				local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
			}else{
				if(arguments.mvcPath EQ request.zos.zcorerootmapping&".mvc"){
					// generated model
					application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component","zcorecachemapping.model."&arguments.modelName);
					local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
				}else{
					// custom generated model
					application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]=createobject("component",request.zRootSecureCFCPath&"_cache.model."&arguments.modelName);
					local.rs=duplicate(application.sitestruct[request.zos.globals.id].modelDataCache.modelComponentCache[local.path]);
				}
			}
		}
		return local.rs;
		</cfscript>
    </cffunction>
    
</cfcomponent>