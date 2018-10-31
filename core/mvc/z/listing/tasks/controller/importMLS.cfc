<cfcomponent>
<cfoutput>
<cffunction name="checkImportTimer" localmode="modern" access="remote">
	<cfscript>  
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	} 
	if(structkeyexists(application, 'idxImportTimerStruct')){
		echo('<h2>Import MLS Timer (total time for each sub-task)</h2>');
		for(i in application.idxImportTimerStruct){
			if(structkeyexists(form, 'resetTimes')){
				application.idxImportTimerStruct[i]=0;	
			}
			c=application.idxImportTimerStruct[i];
			echo('<p>'&(c/1000000000)&' seconds for #i#</p>');
		}
	}else{
		echo("<p>Import hasn't run yet.</p>");
	}

	echo('<p><a href="/z/listing/tasks/importMLS/checkImportTimer?resetTimes=1">Reset times to zero</a></p>');
	abort;
	</cfscript>
</cffunction>
	

<cffunction name="index" localmode="modern" access="remote" returntype="any"> 
	<cfscript>
	var myloops=0;
	var idxCom=0;
	var r=0;
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	setting requesttimeout="15000";
	request.ignoreslowscript=true;
	myloops=46;
 
	if(structkeyexists(application.zcore, 'mlsImportIsRunning')){
		if(not structkeyexists(form, 'zforce')){
			if(datediff("n", application.zcore.mlsImportIsRunning, now()) GT 5){
				structdelete(application.zcore, 'mlsImportIsRunning');
			}else{
				application.zcore.functions.z404('importMLS is already running | <a href="/z/listing/tasks/importMLS/index?zforce=1">Force execution</a>');
				abort;
			}
		}
	}
	request.totalRunTime=gettickcount();
	application.zcore.listingCom.makeListingImportDataReady();
 
	application.zcore.mlsImportIsRunning=now();
	try{
		while(myloops GT 0){
			myloops--;
			idxCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.idx");
			r=idxCom.init();
			if(r EQ false){
				idxCom.process();
				writeoutput('<br /><br />');
			}else{
				break;
			}
			if(gettickcount()-request.totalRunTime GT 170000){
				echo('Aborted due to nearing time limit');
				structdelete(application.zcore, 'mlsImportIsRunning');
				abort;
			}
		}
	}catch(Any e){
		structdelete(application.zcore, 'mlsImportIsRunning');
		rethrow;	
	}
	structdelete(application.zcore, 'mlsImportIsRunning');
	abort;
	</cfscript>
</cffunction>

<cffunction name="abortImport" localmode="modern" access="remote" returntype="any">
	<cfscript>
	
	application.zcore.abortIdxImport=true;
	application.zcore.status.setStatus(request.zsid, "Import cancelled.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>