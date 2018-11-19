<cfcomponent>
    <cffunction name="index" localmode="modern" access="remote" output="yes" returntype="any">
        <cfoutput><cfscript>
        application.zcore.functions.zNoCache();
        request.znotemplate=1;
        local.jsonText="";
        form.debug=application.zcore.functions.zso(form, 'debug',false,false);
        if(form.debug){
            form.x_ajax_id=1;
            form.latitude="29.2753658556";
            form.longitude="-81.1391101437";
        }
        if(structkeyexists(form, 'latitude') EQ false or structkeyexists(form, 'longitude') EQ false){
            application.zcore.functions.z301redirect('/');	
        }
        if(structkeyexists(application.zcore, 'walkscoreRequest') EQ false){
            application.zcore.walkscoreRequest=structnew();
            application.zcore.walkscoreRequest.count=0;
            application.zcore.walkscoreRequest.Day=dateformat(now(),"yyyy-mm-dd");
            application.zcore.walkscoreRequest.CountExceeded=0;
        }
        if(application.zcore.walkscoreRequest.Day NEQ dateformat(now(),"yyyy-mm-dd")){
            application.zcore.walkscoreRequest.Count=0;
            application.zcore.walkscoreRequest.Day=dateformat(now(),"yyyy-mm-dd");
            application.zcore.walkscoreRequest.CountExceeded=0;
        }
        local.emailAndStop=false;
        application.zcore.walkscoreRequest.Count++;
        if(application.zcore.walkscoreRequest.Count GT 3800){
            local.jsonText=('{"success":0,"errorMessage":"Walkscore API exceeded request limit of 4800 per day."}');
            if(application.zcore.walkscoreRequest.CountExceeded NEQ 1){
                application.zcore.walkscoreRequest.CountExceeded=1;
                local.emailAndStop=true;
            }
        }
        </cfscript><cfif local.emailAndStop><cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Walkscore API exceeded request limit of 3800 per day.">Walkscore API exceeded request limit of 3800 per day.  Consider using separate API keys or caching.</cfmail></cfif><cfscript>
        if(application.zcore.walkscoreRequest.CountExceeded EQ 0){
            local.link="http://api.walkscore.com/score?format=json&lat=#form.latitude#&lon=#form.longitude#&wsapikey=417c9d7a92089201537653e435820089";
            local.r1=application.zcore.functions.zDownloadLink(local.link,5);
            if(local.r1.success EQ false or form.debug){
                local.jsonText=('{"success":0,"errorMessage":"API could not be accessed, status code: #local.r1.cfhttp.statuscode# for URL: #local.link# | request count: #application.zcore.walkscoreRequest.Count#"}');	
            }else{
                local.jsonText=(local.r1.cfhttp.FileContent);
            }
        }
        </cfscript><cfheader name="x_ajax_id" value="#form.x_ajax_id#">#local.jsonText#<cfscript>application.zcore.tracking.backOneHit();application.zcore.functions.zabort();</cfscript></cfoutput>
    </cffunction>
</cfcomponent>