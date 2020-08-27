<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="60";
	application.zcore.session.deleteOld();
	//application.zcore.session.testSession();abort;

	/*
	startTime=gettickcount();
	for(i=1;i LTE 70;i++){
		//application.zcore.session.pullNewer();
		if(gettickcount()-startTime GT 57000){
			break;
		}
		sleep(3);
	}*/
	echo('Done');abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>