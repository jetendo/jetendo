<cffunction name="OnRequestEnd" localmode="modern" access="public" returntype="void" output="true" hint="Fires after the page processing is complete."><cfscript>  
	var db=request.zos.queryObject; 
	request.zos.requestLogEntry('Application.cfc onRequestEnd begin');
	if(not structkeyexists(form, request.zos.urlRoutingParameter)){
		return; 
	}
	if(not structkeyexists(application.sitestruct, request.zos.globals.id)){
		echo("Site cache missing | <a href=""/?zreset=site"">Reset</a>");abort;
	}
	savecontent variable="output"{
		writeoutput(request.zos.onRequestStartOutput&request.zos.onRequestOutput);
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'onSiteRequestEndEnabled') and application.sitestruct[request.zos.globals.id].onSiteRequestEndEnabled){
			application.sitestruct[request.zos.globals.id].zcorecustomfunctions.onSiteRequestEnd(variables);
		}
		if(structkeyexists(application.zcore,'template') EQ false){
			return;
		}
		// if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){ 
		// 	application.zcore.skin.includeCSS("/zcache/_z.system.mincat.css");
		// 	application.zcore.skin.includeJS("/zcache/_z.system.mincat.js"); 
		// }else if(request.zos.globals.enableJqueryUI EQ 1){
		// 	// application.zcore.functions.zrequirejquery();
		// 	application.zcore.functions.zrequirejqueryui();
		// }
		if(structkeyexists(request,'zPublishHelpOnRequestEnd')){
			application.zcore.functions.zPublishHelp();
		}
		writeoutput(application.zcore.app.onRequestEnd());
	}
	application.zcore.template.setTag("content", output); 
	if(structkeyexists(request.zos, 'zFormCurrentName') and structkeyexists(request.zos,'scriptAborted') EQ false and structkeyexists(request.zos,'zDisableEndFormCheckRule') EQ false and request.zos.zFormCurrentName NEQ ""){
		application.zcore.template.fail("You forgot to close the application.zcore.functions.zForm() with a call to application.zcore.functions.zEndForm().");
	} 
	if(structkeyexists(form, 'zajaxdownloadcontent')){
		request.zos.endtime=gettickcount('nano');
		c=application.zcore.template.getFinalTagContent("content");
		c=application.zcore.template.getTagContent("meta")&c;
		c1=false;
		if(request.cgi_script_name EQ "/index.cfm"){// or request.cgi_script_name EQ "/index.cfc"){
			c1=true;
		}
		if(structkeyexists(form,'x_ajax_id')){
			application.zcore.functions.zHeader("x_ajax_id", form.x_ajax_id);//zAjaxPageTransition
		}
		finalString='{content:"'&jsstringformat(c)&'", title:"'&jsstringformat(application.zcore.template.getTagContent("title"))&'", pagetitle:"'&jsstringformat(application.zcore.template.getFinalTagContent("pagetitle"))&'", pagenav:"'&jsstringformat(application.zcore.template.getFinalTagContent("pagenav"))&'", forceReload:'&c1&' }';
		//application.zcore.cache.setTemplateContent(finalString);
	}else{
		// if(structkeyexists(request.zos, 'enableContentTransitionStruct')){
		// 	application.zcore.functions.zProcessContentTransition(request.zos.enableContentTransitionStruct);
		// }
		// check if script turned off template system
		if(((structkeyexists(request.zos,'scriptAborted') EQ false and request.zos.routingIsCFC) or request.zos.onrequestcompleted) and (not structkeyexists(request,'znotemplate') or request.znotemplate EQ false)){
			// store reference to variables scope for use with debugger.
			Request.zOS.debugging.variablesBackup = variables;
			// load templates, parse the tags, sets tag config, replaces tags with content and outputs final page
			finalString=application.zcore.template.build();
		}else{
			finalString=output;
			request.zos.endtime=gettickcount('nano');
		}
	}
	savecontent variable="output2"{
		// not in use yet.
		// application.zcore.functions.zProcessQueryQueueThreaded(); // i should probably put this at the beginning of onRequestEnd and prevent templates from doing an asynchronous query to hide the overhead of of the <cfthread> call.
		application.zcore.tracking.endRequest();
		request.zos.requestLogEntry('Application.cfc onRequestEnd end');
		application.zcore.functions.zEndOfRunningScript();  
		
		if((request.zos.isdeveloper or request.zos.istestserver) and structkeyexists(request.zos, 'debugbarOutput')){
			if(structkeyexists(request.zsession, 'modes') and structkeyexists(request.zsession.modes, 'time') and request.zos.debugbarStruct.returnString NEQ ""){ 
				echo(replace(request.zos.debugbarStruct.returnString, '##zdebuggerTimeOutput##', '<br />Page generated in '&((gettickcount('nano')-Request.zOS.startTime)/1000000000)&' seconds.',"one"));
				echo(request.zos.debugbarStruct.returnString2&request.zos.debugbarOutput);
			}
		}
		//echo(application.zcore.template.getEndBodyHTML());
	}
	finalString=application.zcore.template.addEndBodyHTML(finalString, output2);
	
	if(not structkeyexists(application.sitestruct[request.zos.globals.id], 'versionDate')){
		application.sitestruct[request.zos.globals.id].versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
	}
	// if(not structkeyexists(request.zos, 'inMemberArea') or not request.zos.inMemberArea){
	// 	finalString=replace(replace(replace(replace(replace(replace(finalString, 'src="/', 'src="/z~~~v/', "all"), 'src="/z~~~v//', 'src="//', "all"), 'src="/z~~~v/zv', 'src="/zv', "all"), 'src="/z~~~v/http:', 'src="http:', 'all'), 'src="/z~~~v/https:', 'src="https:', 'all'), 'src="/z~~~v/', 'src="/zv#application.sitestruct[request.zos.globals.id].versionDate#/', "all");
	// 	finalString=replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(finalString, "url(/", "url(/z~~~v/", "all"), "url('/", "url('/z~~~v/", "all"), 'url("/', 'url("/z~~~v/', "all"), 'url(/z~~~v/http:', 'url(/http:', 'all'), 'url(/z~~~v/https:', 'url(/https:', 'all'), 'url("/z~~~v/http:', 'url("/http:', 'all'), 'url("/z~~~v/https:', 'url("/https:', 'all'), 'url(''/z~~~v/http:', 'url(''/http:', 'all'), 'url(''/z~~~v/https:', 'url(''/https:', 'all'), "/z~~~v/", "/zv#application.sitestruct[request.zos.globals.id].versionDate#/", "all");
	// }

	writeoutput(trim(finalString));
	/*if(len(finalString) EQ 0 or (isDefined('request.zos.whiteSpaceEnabled') and request.zos.whiteSpaceEnabled)){
		writeoutput(trim(finalString));
	}else{
		//writeoutput(finalString.replaceAll("[\r\t ]+", " "));
		//writeoutput(finalString.replaceAll("\n(\s+)", chr(10)));
		writeoutput(trim(rereplace(finalString, "\n(\s+)",chr(10),"all")));
		//writeOutput(trim(rereplace(rereplace(finalString, "[\r\t ]+"," ","all"), "\n(\s+)",chr(10),"all")));
		//writeoutput(trim(replace(replace(replace(replace(finalString, chr(13),'','all'), chr(9),' ', 'all'),'  ', ' ', 'all'), '  ', ' ', 'all')));
		//writeoutput(trim(finalString));
		//writeOutput(trim(rereplace(finalString, "\n\s+",chr(10),"all")));
	}*/
	application.zcore.session.put(request.zsession);
	application.zcore.functions.zThrowIfImplicitVariableAccessDetected();
</cfscript></cffunction>