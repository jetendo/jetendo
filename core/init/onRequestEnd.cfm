<cffunction name="OnRequestEnd" localmode="modern" access="public" returntype="void" output="true" hint="Fires after the page processing is complete."><cfscript>
	var local=structnew();
	var template=0;
	var db=request.zos.queryObject;
	local.notemplate=false; 
	request.zos.requestLogEntry('Application.cfc onRequestEnd begin');
	if(not structkeyexists(form, request.zos.urlRoutingParameter)){
		return; 
	}
	if(not structkeyexists(application.sitestruct, request.zos.globals.id)){
		echo("Site cache missing | <a href=""/?zreset=site"">Reset</a>");abort;
	}
	savecontent variable="local.output"{
		writeoutput(request.zos.onRequestStartOutput&request.zos.onRequestOutput);
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'onSiteRequestEndEnabled') and application.sitestruct[request.zos.globals.id].onSiteRequestEndEnabled){
			application.sitestruct[request.zos.globals.id].zcorecustomfunctions.onSiteRequestEnd(variables);
		}
		if(structkeyexists(application.zcore,'template') EQ false){
			return;
		}
		if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){ 
			application.zcore.skin.includeCSS("/zcache/_z.system.mincat.css");
			application.zcore.skin.includeJS("/zcache/_z.system.mincat.js"); 
		}else if(request.zos.globals.enableJqueryUI EQ 1){
			application.zcore.functions.zrequirejquery();
			application.zcore.functions.zrequirejqueryui();
		}
		if(structkeyexists(request,'zPublishHelpOnRequestEnd')){
			application.zcore.functions.zPublishHelp();
		}
		writeoutput(application.zcore.app.onRequestEnd());
	}
	application.zcore.template.setTag("content", local.output); 
	if(structkeyexists(request.zos, 'zFormCurrentName') and structkeyexists(request.zos,'scriptAborted') EQ false and structkeyexists(request.zos,'zDisableEndFormCheckRule') EQ false and request.zos.zFormCurrentName NEQ ""){
		application.zcore.template.fail("You forgot to close the application.zcore.functions.zForm() with a call to application.zcore.functions.zEndForm().");
	}
	if((structkeyexists(request,'znotemplate') and request.znotemplate EQ true) or request.zos.templateData.notemplate EQ true){
		local.notemplate=true;
	}
	if(structkeyexists(form, 'zajaxdownloadcontent')){
		request.zos.endtime=gettickcount('nano');
		local.c=application.zcore.template.getFinalTagContent("content");
		local.c=application.zcore.template.getTagContent("meta")&local.c;
		local.c1=false;
		if(request.cgi_script_name EQ "/index.cfm"){// or request.cgi_script_name EQ "/index.cfc"){
			local.c1=true;
		}
		if(structkeyexists(form,'x_ajax_id')){
			application.zcore.functions.zHeader("x_ajax_id", form.x_ajax_id);//zAjaxPageTransition
		}
		local.finalString='{content:"'&jsstringformat(local.c)&'", title:"'&jsstringformat(application.zcore.template.getTagContent("title"))&'", pagetitle:"'&jsstringformat(application.zcore.template.getFinalTagContent("pagetitle"))&'", pagenav:"'&jsstringformat(application.zcore.template.getFinalTagContent("pagenav"))&'", forceReload:'&local.c1&' }';
		application.zcore.cache.setTemplateContent(local.finalString);
	}else{
		if(structkeyexists(request.zos, 'enableContentTransitionStruct')){
			application.zcore.functions.zProcessContentTransition(request.zos.enableContentTransitionStruct);
		}
		// check if script turned off template system
		if(((structkeyexists(request.zos,'scriptAborted') EQ false and request.zos.routingIsCFC) or request.zos.onrequestcompleted) and local.notemplate EQ false){
			// store reference to variables scope for use with debugger.
			Request.zOS.debugging.variablesBackup = variables;
			// load templates, parse the tags, sets tag config, replaces tags with content and outputs final page
			local.finalString=application.zcore.template.build();
		}else{
			local.finalString=local.output;
			request.zos.endtime=gettickcount('nano');
		}
	}
	savecontent variable="local.output2"{
		application.zcore.functions.zProcessQueryQueueThreaded(); // i should probably put this at the beginning of onRequestEnd and prevent templates from doing an asynchronous query to hide the overhead of of the <cfthread> call.
		application.zcore.tracking.endRequest();
		request.zos.requestLogEntry('Application.cfc onRequestEnd end');
		application.zcore.functions.zEndOfRunningScript();  
		
		if((request.zos.isdeveloper or request.zos.istestserver) and structkeyexists(request.zos, 'debugbarOutput')){
			if(isDefined('request.zsession.modes.time') and request.zos.debugbarStruct.returnString NEQ ""){ 
				echo(replace(request.zos.debugbarStruct.returnString, '##zdebuggerTimeOutput##', '<br />Page generated in '&((gettickcount('nano')-Request.zOS.startTime)/1000000000)&' seconds.',"one"));
				echo(request.zos.debugbarStruct.returnString2&request.zos.debugbarOutput);
			}
		}
		//echo(application.zcore.template.getEndBodyHTML());
	}
	local.finalString=application.zcore.template.addEndBodyHTML(local.finalString, local.output2);
	
	if(not structkeyexists(application.sitestruct[request.zos.globals.id], 'versionDate')){
		application.sitestruct[request.zos.globals.id].versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
	}
	if(not structkeyexists(request.zos, 'inMemberArea') or not request.zos.inMemberArea){
		local.finalString=replace(replace(replace(replace(replace(replace(local.finalString, 'src="/', 'src="/z~~~v/', "all"), 'src="/z~~~v//', 'src="//', "all"), 'src="/z~~~v/zv', 'src="/zv', "all"), 'src="/z~~~v/http:', 'src="http:', 'all'), 'src="/z~~~v/https:', 'src="https:', 'all'), 'src="/z~~~v/', 'src="/zv#application.sitestruct[request.zos.globals.id].versionDate#/', "all");
		local.finalString=replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(local.finalString, "url(/", "url(/z~~~v/", "all"), "url('/", "url('/z~~~v/", "all"), 'url("/', 'url("/z~~~v/', "all"), 'url(/z~~~v/http:', 'url(/http:', 'all'), 'url(/z~~~v/https:', 'url(/https:', 'all'), 'url("/z~~~v/http:', 'url("/http:', 'all'), 'url("/z~~~v/https:', 'url("/https:', 'all'), 'url(''/z~~~v/http:', 'url(''/http:', 'all'), 'url(''/z~~~v/https:', 'url(''/https:', 'all'), "/z~~~v/", "/zv#application.sitestruct[request.zos.globals.id].versionDate#/", "all");
	}

	writeoutput(trim(local.finalString));
	/*if(len(local.finalString) EQ 0 or (isDefined('request.zos.whiteSpaceEnabled') and request.zos.whiteSpaceEnabled)){
		writeoutput(trim(local.finalString));
	}else{
		//writeoutput(local.finalString.replaceAll("[\r\t ]+", " "));
		//writeoutput(local.finalString.replaceAll("\n(\s+)", chr(10)));
		writeoutput(trim(rereplace(local.finalString, "\n(\s+)",chr(10),"all")));
		//writeOutput(trim(rereplace(rereplace(finalString, "[\r\t ]+"," ","all"), "\n(\s+)",chr(10),"all")));
		//writeoutput(trim(replace(replace(replace(replace(local.finalString, chr(13),'','all'), chr(9),' ', 'all'),'  ', ' ', 'all'), '  ', ' ', 'all')));
		//writeoutput(trim(local.finalString));
		//writeOutput(trim(rereplace(local.finalString, "\n\s+",chr(10),"all")));
	}*/
	application.zcore.session.put(request.zsession);
	application.zcore.functions.zThrowIfImplicitVariableAccessDetected();
</cfscript></cffunction>