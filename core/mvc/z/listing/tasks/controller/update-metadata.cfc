<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	var i=0;
	var qD=0;
	var path=0;
	// this script may crash server due to running out of memory is the xml is too big.  Increase java server xmx to prevent this.
	application.zcore.functions.checkIfCronJobAllowed();
	if(request.zos.isDeveloper){
		form.forceMetaDataRebuild=true;  
	}
	setting requesttimeout="6000";
	//arrProgress=[];
	for(i in application.zcore.listingStruct.mlsStruct){ 
		object=application.zcore.functions.zcreateobject("component",application.zcore.listingStruct.mlsStruct[i].mlsComPath);
		object.mls_id=i; 
		//arrayappend(arrProgress, i&" started");
		//application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"metadatatemp.txt", arraytolist(arrProgress, chr(10)));
		if(request.zos.isServer or request.zos.isDeveloper){
			path="#request.zos.sharedPath#mls-data/#i#/";
			directory directory="#path#" filter="metadata*.xml" name="qD" sort="dateLastModified DESC";
			if(qD.recordcount NEQ 0){ 
				contents=application.zcore.functions.zreadfile(path&"/"&qD.name);
				application.zcore.listingStruct.mlsStruct[i].sharedStruct.metadataDateLastModified=qD.dateLastModified[1];	
			}
		}
		object.init(application.zcore.listingStruct.mlsStruct[i].sharedStruct); 
		object.makeListingImportDataReady();
	}
	//application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"metadatatemp.txt", arraytolist(arrProgress, chr(10)));
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
</cfcomponent>