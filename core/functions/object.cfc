<cfcomponent extends="zcorerootmapping.functions.codeExport">
<cfoutput>

<cffunction name="zCreateObject" localmode="modern" output="no" returntype="any">
    <cfargument name="c" type="string" required="yes">
    <cfargument name="cpath" type="string" required="yes">
    <cfargument name="forceNew" type="boolean" required="no" default="#false#">
    <cfscript>   
    if(structkeyexists(application, 'codeDeployModeEnabled')){ 
        try{
            com=createobject("component",arguments.cpath);
        }catch(Any e){
            if(not request.zos.istestserver and not fileexists(expandpath(replace(arguments.cpath, ".","/","all")&".cfc"))){
                savecontent variable="local.e2"{
                    writedump(e);//, true, 'simple');   
                }
                application.zcore.functions.z404("zCreateObject() c:"&arguments.c&"<br />cpath:"&arguments.cpath&"<br />forceNew:"&arguments.forceNew&"<br />request.zos.cgi.SCRIPT_NAME:"&request.zos.cgi.SCRIPT_NAME&"<br />catch error:"&local.e2);
            }else{
                rethrow;
            }
        } 
    }else{
        if(structkeyexists(application.zcore,'allcomponentcache') EQ false){
            application.zcore.allcomponentcache=structnew();
        }
    	t7=application.zcore.allcomponentcache;
        if(structkeyexists(t7,arguments.cpath) EQ false or arguments.forceNew){
    		try{
    			com=createobject("component",arguments.cpath);
    		}catch(Any e){
    			if(not request.zos.istestserver and not fileexists(expandpath(replace(arguments.cpath, ".","/","all")&".cfc"))){
                    savecontent variable="local.e2"{
                        writedump(e);//, true, 'simple');   
                    }
    				application.zcore.functions.z404("zCreateObject() c:"&arguments.c&"<br />cpath:"&arguments.cpath&"<br />forceNew:"&arguments.forceNew&"<br />request.zos.cgi.SCRIPT_NAME:"&request.zos.cgi.SCRIPT_NAME&"<br />catch error:"&local.e2);
    			}else{
    				rethrow;
    			}
    		}
            t7[arguments.cpath]=com;
        }else{
            com=t7[arguments.cpath];
        }
    }
    c=duplicate(com, true); 
    return c;
    </cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
