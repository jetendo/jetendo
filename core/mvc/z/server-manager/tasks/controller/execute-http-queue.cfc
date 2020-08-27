<cfcomponent>
<cfoutput>
<cffunction name="viewErrors" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	application.zcore.functions.checkIfCronJobAllowed();
	queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
	queueHttpCom.displayHTTPQueueErrors(); 
	</cfscript>
</cffunction>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="6000";
	queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
 	
 	startTickCount=getTickCount();
 	if(structkeyexists(application, 'zExecuteHttpQueue')){
 		echo('zExecuteHttpQueue is already running.');
 		abort;
 	}
 	application.zExecuteHttpQueue=true;
	while(true){
		try{
			queueHttpCom.executeQueuedTasks();
		}catch(Any e){
			structdelete(application, 'zExecuteHttpQueue');
			rethrow;	
		}
		sleep(1000);
		if((getTickCount()-startTickCount)/1000 > 580){
			break;
		}
	}

	structdelete(application, 'zExecuteHttpQueue');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>