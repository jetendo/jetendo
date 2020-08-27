<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var s=0; 
	echo('disabled');abort;
	/*
	// the live server uses too much memory, and runs out of space if we enable memory-dump.
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="350";
	// lock all requests so that the object dumps are consistent
	lock type="exclusive" timeout="300" throwontimeout="no" name="#request.zos.installPath#-zDeployExclusiveLock"{
		application.zcore.functions.zCreateDirectory(request.zos.zcoreRootCachePath&"scripts/memory-dump/");
		coreDumpFile=request.zos.zcoreRootCachePath&"scripts/memory-dump/"&server[request.zos.cfmlServerKey].version&"-all.bin";
		tempCoreDumpFile=coreDumpFile&"."&gettickcount();
		objectsave(application.zcore, tempCoreDumpFile);
		application.zcore.functions.zdeletefile(coreDumpFile);
		application.zcore.functions.zRenameFile(tempCoreDumpFile, coreDumpFile);
	};
	writeoutput('dump complete');
	abort;
	*/
	</cfscript>
</cffunction>


<cffunction name="logRecentRequestsError" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	t9=duplicate(application.zcore.runningScriptStruct); 
	form.returnResults=application.zcore.functions.zso(form, 'returnResults', true, 0);
	if(form.returnResults EQ 1){
		arrOut=[];
		for(i in t9){ 
			seconds=datediff("s",t9[i].startTime, now()); 
			if(structkeyexists(form, 'clearOldRunning') and seconds GT 3600){
				structdelete(application.zcore.runningScriptStruct,i);	
			}else{
				if(t9[i].url DOES NOT CONTAIN "/z/server-manager/tasks/execute-http-queue/index" and t9[i].url DOES NOT CONTAIN "/z/server-manager/tasks/memory-dump/logRecentRequestsError"){
					arrayAppend(arrOut, seconds&' seconds for '&t9[i].url); 
				}
			} 
		}
		echo("Running Requests"&chr(10)&arrayToList(arrOut, chr(10)));
		abort;
	}
	savecontent variable="out"{
		writeoutput('<h2>High CPU Alert - Dumping log of Running CFML Requests Below</h2>
		<table style="border-spacing:0px; padding:5px;">
		<tr><td>Running Time (seconds)</td><td>URL</td></tr>');
		
		for(i in t9){ 
			seconds=datediff("s",t9[i].startTime, now()); 
			if(structkeyexists(form, 'clearOldRunning') and seconds GT 3600){
				structdelete(application.zcore.runningScriptStruct,i);	
			}else{
				if(t9[i].url DOES NOT CONTAIN "/z/server-manager/tasks/execute-http-queue/index" and t9[i].url DOES NOT CONTAIN "/z/server-manager/tasks/memory-dump/logRecentRequestsError"){
					writeoutput('<tr><td>'&seconds&'</td><td>'&t9[i].url&'</td></tr>'); 
				}
			} 
		}
		writeoutput('</table>');
	}

	ts={
		type:"Custom",
		errorHTML:out,
		scriptName:'/z/server-manager/admin/recent-requests/logRecentRequestsError',
		url:request.zos.originalURL,
		exceptionMessage:'High CPU Alert - Dumping log of Running CFML Requests Below',
		// optional
		lineNumber:'1'
	}
	application.zcore.functions.zLogError(ts);
	echo('Error logged');
	abort;
	</cfscript>	
</cffunction>
</cfoutput>
</cfcomponent>