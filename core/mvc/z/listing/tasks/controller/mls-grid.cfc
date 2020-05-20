<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.base">
<cfoutput>
<!--- 
// requires curl for the metadata.xml download to work due to needing to uncompress the gzip response
// this command must go in custom-secure-scripts/mls-grid-download.php and added to production cronjob like this:
15 1 * * * /usr/bin/php /var/jetendo-server/custom-secure-scripts/mls-grid-download.php >/dev/null 2>&1

// wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '29-%'; 
		
The MLS Grid uses the field MlgCanView as our deletion flag. Listings marked with MlgCanView=false are listings that no longer qualify for inclusion in the IDX feed and are marked for deletion. The participating MLS do include listings with a Closed StandardStatus. Depending on the governing rules of the MLS they may continue to include 3+ years worth of listings with a StandardStatus of Closed. Listings that are marked for deletion will carry the MlgCanView=false flag for 7 days and are then removed completely from the feed.
 
Prepping for Web API Data Import
	standardname?

	canopy specific fields are prefixed with CAR_, MFR_
b. Native MLS fields will have an MLS Local Fields prefix. (A list of MLS local fields prefix is available: docs.mlsgrid.com/#local-fields-prefix)

$top=5000
$skip=1
$count=true

StandardStatus = ?
Resource = Property, Media, Member, etc


# download everything
http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/index?incremental=0 

# download only the newest data:
http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/index

debug 1 feed, 1 record:
http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/index?debug=1

http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/viewMetadata

http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/displayFields

has enums with individual plain text name and id value pairs - do i need them?
 --->
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	this.mls_id=32; 
	this.mls_provider="mlsgridcanopy";
	request.zos["listing"]=application.zcore.listingStruct;

	// get all the active record ids from database into a lookup table so we can mark for deletion faster
	db.sql="select listing_track_id, listing_id from #db.table("listing_track", request.zos.zcoreDatasource)# 
	WHERE listing_id like #db.param('#this.mls_id#-%')# and 
	listing_track_deleted=#db.param(0)# ";
	qTrack=db.execute("qTrack");
	variables.listingLookup={};
	loop query="qTrack"{
		variables.listingLookup[qTrack.listing_id]=qTrack.listing_track_id;
	} 
	variables.fieldNameLookup=getFieldNames();


	variables.excludeStruct={
		"BuyerAgentAOR":true,
		"BuyerAgentKey":true,
		"BuyerAgentMlsId":true,
		"BuyerOfficeKey":true,
		"BuyerOfficeMlsId":true,
		"CAR_BuyerAgentSaleYN":true,
		"CAR_CCRSubjectTo":true,
		"CAR_Documents":true,
		"CAR_DOMToClose":true,
		"CAR_OwnerAgentYN":true,
		"CoListAgentAOR":true,
		"CoListAgentFullName":true,
		"CoListAgentKey":true,
		"CoListAgentMlsId":true,
		"CoListOfficeKey":true,
		"CoListOfficeMlsId":true,
		"CoListOfficeName":true,
		"Latitude":true,
		"Longitude":true,
		"InternetAddressDisplayYN":true,
		"InternetAutomatedValuationDisplayYN":true,
		"InternetConsumerCommentYN":true,
		"InternetEntireListingDisplayYN":true,
		"ListAgentAOR":true,
		"ListAgentDirectPhone":true,
		"ListAgentFullName":true,
		"ListAgentKey":true,
		"ListAgentMlsId":true,
		"ListingAgreement":true,
		"ListingContractDate":true,
		"ListingId":true,
		"ListingKey":true,
		"ListingTerms":true,
		"ListOfficeKey":true,
		"ListOfficeMlsId":true,
		"ListOfficeName":true,
		"ListOfficePhone":true,
		"MlgCanView":true,
		"ModificationTimestamp":true,
		"OriginatingSystemModificationTimestamp":true,
		"OriginatingSystemName":true,
		"PendingTimestamp":true,
		"PhotosChangeTimestamp":true,
		"ShowingContactPhone":true,
		"SyndicationRemarks":true,
	};

	// data is too big, can't just download the active listings
	variables.arrResource=[
		"PropertyResi",
		"PropertyRlse",
		"PropertyRinc",
		"PropertyLand",
		"PropertyFarm",
		"PropertyMobi", // not used on canopyMLS
		"PropertyComs",
		"PropertyComl",
		"PropertyBuso", // not used on canopyMLS
		// "Member", // don't need it
		// "Office", // don't need it
		"Media"
	];


	// metaDataPath="/var/jetendo-server/jetendo/share/mls-data/32/metadata.xml";
	// a=application.zcore.functions.zReadFile(metaDataPath);
	// variables.metaData=xmlparse(a);
	</cfscript>
</cffunction>

<!--- <cffunction name="viewMetadata" localmode="modern" access="remote" roles="administrator"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	init();
	writedump(variables.metaData);
	abort;
	</cfscript>
</cffunction> --->

<cffunction name="displayFields" localmode="modern" access="remote" roles="administrator"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	index();
	</cfscript>
</cffunction>


<cffunction name="cancel" localmode="modern" access="remote" roles="administrator"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	application.cancelMLSGridImport=true;
	sleep(7000);
	structdelete(application, "cancelMLSGridImport");
	structdelete(application, "mlsGridImportRunning");
	structdelete(application, "mlsGridDownloadRunning");
	structdelete(application, "currentMLSGridStatus");
	structdelete(application, "mlsgridCronRunning");
	echo("The import was cancelled.");
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	</cfscript>
	<h1>MLS Grid Import</h1>
	<h2>Current Status: #application.zcore.functions.zso(application, "currentMLSGridStatus")#</h2>

	
	<h2><a href="/z/listing/tasks/mls-grid/download" target="_blank">Incremental Download</a> <cfif structkeyexists(application, "mlsGridDownloadRunning")>(Running)</cfif></h2>
	<h2>Download: <a href="/z/listing/tasks/mls-grid/download?incremental=0" target="_blank">Everything</a> | <a href="/z/listing/tasks/mls-grid/download?incremental=0&skipListing=1" target="_blank">Media</a> | <a href="/z/listing/tasks/mls-grid/download?incremental=0&skipMedia=1" target="_blank">Listings</a><cfif structkeyexists(application, "mlsGridDownloadRunning")>(Running)</cfif></h2>
	<h2><a href="/z/listing/tasks/mls-grid/process" target="_blank">Process Media + Listings</a> | <a href="/z/listing/tasks/mls-grid/process?skipMedia=1" target="_blank">Process Listings</a> <cfif structkeyexists(application, "mlsGridImportRunning")>(Running)</cfif></h2>
	<h2><a href="/z/listing/tasks/mls-grid/cron" target="_blank">Cron</a></h2>
	<p>Cron is designed to process one file at a time.  It should be scheduled to run once a minute.  If you add ?force=1 to the url, it will allow it to run again in the case of an error, but it will also be able to run again after 5 minutes too.</p>
	<h2><a href="/z/listing/tasks/mls-grid/cancel" target="_blank">Cancel</a></h2>
</cffunction>

<cffunction name="download" localmode="modern" access="remote"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	// echo("incomplete - disabled for now");abort;
	setting requesttimeout="100000"; 
	if(structkeyexists(application, "mlsGridDownloadRunning")){
		echo("The download is already running, you must cancel it or wait.");
		abort;
	}
	request.ignoreSlowScript=true;
	application.mlsGridDownloadRunning=true;
	resourceIndex=0; // leave as 0 when not debugging
	form.incremental=application.zcore.functions.zso(form, "incremental", true, 1);
	form.debug=application.zcore.functions.zso(form, "debug", true, 0);

 	top=1000; // 5000 is max records?
 	skip=0;
 	count=false; // don't need count since the next link can pull everything
 	lastUpdateDate=createdatetime(2020, 2, 14,0,0,0); // first time, pull very old data createdate(2010,1,1);
 	if(form.incremental EQ 1){
		dateContents=application.zcore.functions.zReadFile(request.zos.globals.privateHomeDir&"mlsgrid/lastUpdateDate");
		if(dateContents NEQ false){
			arrDate=listToArray(dateContents, "/");
			if(arrayLen(arrDate) EQ 6){
				lastUpdateDate=createDateTime(arrDate[1], arrDate[2], arrDate[3], arrDate[4], arrDate[5], arrDate[6]);
			}
		}
	}
 	if(form.debug EQ 1){
 		top=1;
 		skip=0;
 		count=true;
 		resourceIndex=1;
 	}

 	if(form.method EQ "displayFields"){
	 	displayFields=true;
		top=1;
		skip=0;
		count=false;
	}else{
		displayFields=false;
	}

	insertCount=0;
	updateCount=0;
	deleteCount=0;
	skipCount=0;
	downloadCount=0;
	init(); 

	application.zcore.functions.zCreateDirectory(request.zos.globals.privateHomeDir&"mlsgrid/");

 	for(n=1;n<=arrayLen(variables.arrResource);n++){
 		if(resourceIndex EQ 0){
			resource=variables.arrResource[n];
		}else if(resourceIndex NEQ n){
			continue; // skip to the correct resourceIndex when debugging
		}else{
			resource=variables.arrResource[resourceIndex];
		}
		// note filter operators have to be lower case.
		if(form.incremental EQ 1){
 			filter=urlencodedformat("ModificationTimestamp gt #dateformat(lastUpdateDate, "yyyy-mm-dd")#T#timeformat(lastUpdateDate, "HH:mm:ss")#.00Z");
 		}else if(resource EQ "Media"){
 			if(structkeyexists(form, "skipMedia")){
 				continue;
 			}
 			// media can't filter active listings
 			top=5000;
 			lastUpdateDate="2010-01-01"; // force very old date
 			filter="MlgCanView eq true"; // no other filter can reduce the media data
 		}else{ 
 			if(structkeyexists(form, "skipListing")){
 				continue;
 			}
 			lastUpdateDate="2010-01-01"; // force very old date
 			filter=urlencodedformat("ModificationTimestamp gt #dateformat(lastUpdateDate, "yyyy-mm-dd")#T#timeformat(lastUpdateDate, "HH:mm:ss")#Z and StandardStatus eq Odata.Models.StandardStatus'Active' and MlgCanView eq true");
 		}
	 	nextLink="https://api.mlsgrid.com/#resource#?$filter=#filter#&$top=#top#&$skip=#skip#&$count=#count#";

	 	fileNumber=1;
	 	while(true){
	 		if(structkeyexists(application, "cancelMLSGridImport")){
	 			echo("Import cancelled after downloading #downloadCount# files");
	 			abort;
	 		}
		 	js=downloadData(nextLink); 
		 	application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"mlsgrid/"&lcase(resource)&"-"&createuuid()&".txt", serializeJson(js));
			nextLink=replace(application.zcore.functions.zso(js, "@odata.nextLink"), "'", "%27", "all");
			fileNumber++;
			downloadCount++;
			if(nextLink EQ ""){
				break;
			}
		}
		//break; // for debugging just one.
	} 
	if(form.incremental EQ 1){
		application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"mlsgrid/lastUpdateDate", dateformat(dateadd("h", 4, now()), "yyyy/m/d")&timeformat(dateadd("h", 4, now()), "/HH/mm/ss"));
	}
	structdelete(application, "currentMLSGridStatus");
 	echo("Downloaded #downloadCount# files");
	structdelete(application, "mlsGridDownloadRunning");

	</cfscript>
</cffunction>

<cffunction name="buildListingIdLookup" localmode="modern" access="remote"> 
	<cfscript>
	setting requesttimeout="10000";
	request.listingIdLookup={};

	qFiles=application.zcore.functions.zReadDirectory(request.zos.globals.privateHomeDir&"mlsgrid/");

	listingCount=0;
	oldestListingDate=now();
	// process all the media files first so we can add the image urls to the listing_data record
	loop query="qFiles"{
		if(qFiles.name CONTAINS "##"){
			continue;
		}
		arrName=listToArray(qFiles.name, "-");
		if(arrayLen(arrName) LT 2){
			continue;
		}
		resource=arrName[1]; 
		if(resource EQ "exclude" or resource EQ "media" or resource EQ "member" or resource EQ "office" or resource EQ "agent"){
			// skip media files
			continue;
		}
 		path=request.zos.globals.privateHomeDir&"mlsgrid/"&qFiles.name;
 		contents=application.zcore.functions.zReadFile(path); 
 		if(contents EQ false){
 			continue; // file missing, ignore it and do the next file
 		}
 		js=deserializeJSON(contents);
		// writedump(resource);
		// writedump(js);			 abort;
		for(i=1;i<=arraylen(js.value);i++){
			application.currentMLSGridStatus="BuildListingIdLookup Listing Row ###i# of #path#";
	 		if(structkeyexists(application, "cancelMLSGridImport")){
	 			echo("Import cancelled");
	 			abort;
	 		}
			// if(i EQ 3){
			// 	break; // only do 2 while debugging.
			// }
			ds=js.value[i];
			tempDate=dateformat(ds["ModificationTimestamp"], "yyyymmdd");
			if(tempDate LTE dateformat(oldestListingDate, "yyyymmdd")){
				oldestListingDate=ds["ModificationTimestamp"];
			} 

			if(ds["MlgCanView"] EQ "true"){
				listingCount++;
				request.listingIdLookup[ds["ListingID"]]=true;
			}
		}
	}

	application.zcore.functions.zWriteFile(request.zos.globals.privateHomeDir&"mlsgrid/exclude-listingIdLookup.txt", serializeJson(request.listingIdLookup));

	//writedump(request.listingIdLookup);
	structdelete(application, "currentMLSGridStatus");
	echo("Building listing id lookup for #listingCount# visible listings. Oldest modification date: #dateformat(oldestListingDate, "yyyy-mm-dd")#");
	abort;
	</cfscript>
</cffunction>

<cffunction name="getMediaByListingId" localmode="modern" access="public"> 
	<cfargument name="listing_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrPhoto=[];
	// return arrPhoto; // ignore photos for now
	db.sql="select * from #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
	WHERE
	listing_id=#db.param(arguments.listing_id)#  and 
	mlsgrid_media_deleted=#db.param(0)# 
	ORDER BY mlsgrid_media_order ASC";
	qMedia=db.execute("qMedia", "", 10000, "query", false);
	if(qMedia.recordcount EQ 0){
		// download images for 1 listing to fix the missing data once
		skip=0;
		count=false;
		top=5000;
		// note filter operators have to be lower case.
		filter=urlencodedformat("MlgCanView eq true and ResourceRecordID eq '#listgetat(arguments.listing_id, 2, "-")#'");
		nextLink="https://api.mlsgrid.com/Media?$filter=#filter#&$top=#top#&$skip=#skip#&$count=#count#";
		js=downloadData(nextLink);   

		for(i=1;i<=arraylen(js.value);i++){
			application.currentMLSGridStatus="Process Media Row ###i# for listing_id: #arguments.listing_id#";
	 		if(structkeyexists(application, "cancelMLSGridImport")){
	 			echo("Import cancelled");
	 			abort;
	 		}
			ds=js.value[i];
			if(ds["MlgCanView"] EQ "false"){
				db.sql="update #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
				set 
				mlsgrid_media_url=#db.param("")# 
				WHERE mls_id=#db.param(this.mls_id)# and 
				mlsgrid_media_key=#db.param("#ds["MediaKey"]#")# and 
				mlsgrid_media_deleted=#db.param(0)# ";
				db.execute("qUpdate");
			}else{
				ns=processMedia(ds);
				db.sql="select mlsgrid_media_id from #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
				WHERE mls_id=#db.param(this.mls_id)# and 
				mlsgrid_media_key=#db.param("#ns["MediaKey"]#")# and 
				mlsgrid_media_deleted=#db.param(0)# ";
				qMedia=db.execute("qMedia");

				// arrayAppend(arrPhoto, ns["MediaURL"]);
				if(qMedia.recordcount NEQ 0){
					db.sql="update #db.table("mlsgrid_media", request.zos.zcoreDatasource)#  SET
					mlsgrid_media_url=#db.param(ns["MediaURL"])#, 
					mlsgrid_media_downloaded=#db.param(1)#,
					listing_id=#db.param("#this.mls_id#-#ns["ResourceRecordID"]#")#,
					mlsgrid_media_order=#db.param(ns["Order"])#, 
					mlsgrid_media_updated_datetime=#db.param(request.zos.mysqlnow)# 
					WHERE mls_id=#db.param(this.mls_id)# and 
					mlsgrid_media_key=#db.param("#ns["MediaKey"]#")# and 
					mlsgrid_media_deleted=#db.param(0)# ";
					db.execute("qUpdate");
				}else{
					db.sql="INSERT INTO #db.table("mlsgrid_media", request.zos.zcoreDatasource)#  SET 
					mlsgrid_media_key=#db.param("#ns["MediaKey"]#")#,
					mlsgrid_media_downloaded=#db.param(1)#,
					listing_id=#db.param("#this.mls_id#-#ns["ResourceRecordID"]#")#,
					mlsgrid_media_url=#db.param(ns["MediaURL"])#, 
					mlsgrid_media_order=#db.param(ns["Order"])#, 
					mlsgrid_media_updated_datetime=#db.param(request.zos.mysqlnow)#,
					mls_id=#db.param(this.mls_id)#,
					mlsgrid_media_deleted=#db.param(0)# ";
					db.execute("qInsert");
				}
			}
		}
		db.sql="select * from #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
		WHERE
		listing_id=#db.param(arguments.listing_id)#  and 
		mlsgrid_media_deleted=#db.param(0)# 
		ORDER BY mlsgrid_media_order ASC";
		qMedia=db.execute("qMedia", "", 10000, "query", false);
	}
	for(row in qMedia){
		if(row.mlsgrid_media_url NEQ ""){
			// if(row.mlsgrid_media_url CONTAINS "/zimageproxy/"){
			// 	link=row.mlsgrid_media_url;
			// }else{
			// 	link="/zimageproxy/"&replace(replace(row.mlsgrid_media_url,"http://",""),"https://","");
			// }
			// arrayAppend(arrPhoto,  link);
			arrayAppend(arrPhoto, row.mlsgrid_media_url);
		}
	}
	return arrPhoto;
	</cfscript>
</cffunction>

<cffunction name="cron" localmode="modern" access="remote"> 
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	setting requesttimeout="100000";
	request.ignoreSlowScript=true;


	if(structkeyexists(application, "mlsgridCronRunning") and not structkeyexists(form, "force")){
		previousDate=dateformat(application.mlsgridCronRunning, "yyyymmdd")&timeformat(application.mlsgridCronRunning, "HHmmss");
		currentDate=dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss");
		if(currentDate-previousDate <= 500){
			echo("Cron is already running.  You must wait 5 minutes before running this again if there was an error, or add ?force=1 to the url.");
			abort;
		}
	}

	application.mlsgridCronRunning=request.zos.now;

	if(not request.zos.isTestServer){ 
		// the first run would always be 20 minutes after the server starts
		if(not structkeyexists(application, "mlsGridLastCronDownload")){
			application.mlsGridLastCronDownload=dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss");
		}
		currentTime=dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss");
		if(currentTime-application.mlsGridLastCronDownload GTE 1200 or structkeyexists(form, "forceDownload")){
			// download every 20 minutes
			application.mlsGridLastCronDownload=currentTime;
			form.incremental=1;
			download();
		}
	}
	qFiles=application.zcore.functions.zReadDirectory(request.zos.globals.privateHomeDir&"mlsgrid/");
	if(qFiles.recordcount EQ 0){
		structdelete(application, "mlsgridCronRunning");
		break; // import complete
	}
	currentRow=1; 
	loop query="qFiles"{ 
		if(qFiles.name CONTAINS "##"){
			continue;
		}
		try{
			process(qFiles.name);
		}catch(Any e){
			structdelete(application, "mlsGridImportRunning");
			structdelete(application, "currentMLSGridStatus");
			structdelete(application, "mlsgridCronRunning");
			rethrow;
		} 
		structdelete(application, "mlsGridImportRunning"); 
		if(currentRow EQ 5){
			break;
		}
		currentRow++;
	}
 
	structdelete(application, "mlsGridImportRunning");
	structdelete(application, "currentMLSGridStatus");
	structdelete(application, "mlsgridCronRunning");
	echo("Import complete");
	abort;
	</cfscript>
</cffunction>

<cffunction name="process" localmode="modern" access="remote"> 
	<cfscript>
	try{
		runProcess("");
	}catch(Any e){
		structdelete(application, "mlsGridImportRunning");
		structdelete(application, "currentMLSGridStatus"); 
		structdelete(application, "mlsgridCronRunning");
		rethrow;
	}

	structdelete(application, "mlsGridImportRunning");
	structdelete(application, "currentMLSGridStatus");
	structdelete(application, "mlsgridCronRunning");
	</cfscript>
</cffunction>


<cffunction name="runProcess" localmode="modern" access="public"> 
	<cfargument name="fileName" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	request.ignoreSlowScript=true;

	fileName=arguments.fileName;
	if(fileName CONTAINS "/" or fileName CONTAINS "\"){
		application.zcore.functions.z404("Insecure fileName: #fileName#");
	}
		// echo("incomplete - disabled for now");abort;
	if(structkeyexists(form, "force")){
		structdelete(application, "mlsGridImportRunning");
	}
	if(structkeyexists(application, "mlsGridImportRunning")){
		echo("The import is already running, you must cancel it or wait.");
		abort;
	}
	setting requesttimeout="100000";  

	application.mlsGridImportRunning=true;

	// don't need this for now, it gets all the active listing_id in a file
	// contents=application.zcore.functions.zReadFile(request.zos.globals.privateHomeDir&"mlsgrid/exclude-listingIdLookup.txt");
	// request.listingIdLookup=deserializeJson(contents);

	resourceIndex=0; // leave as 0 when not debugging
	// property, but only residential??
	form.debug=application.zcore.functions.zso(form, "debug", true, 0);
 	top=1000; // 5000 is max records?
 	skip=0;
 	count=false; // don't need count since the next link can pull everything
 	lastUpdateDate=createdatetime(2020, 1, 20, 0,0,0); // first time, pull very old data createdate(2010,1,1);
 	if(form.debug EQ 1){
 		top=1;
 		skip=0;
 		count=true;
 		resourceIndex=1;
 	}

 	if(form.method EQ "displayFields"){
	 	displayFields=true;
		top=1;
		skip=0;
		count=false;
	}else{
		displayFields=false;
	}

	insertCount=0;
	updateCount=0;
	deleteCount=0;
	skipCount=0; 
	init(); 

	mediaCount=0;
	mediaFileCount=0;

	qFiles=application.zcore.functions.zReadDirectory(request.zos.globals.privateHomeDir&"mlsgrid/");

	// process all the media files first so we can add the image urls to the listing_data record
	loop query="qFiles"{
		if(qFiles.name CONTAINS "##"){
			continue;
		}
		if(structkeyexists(form, "skipMedia")){
			break;
		}
		if(fileName NEQ ""){
			if(fileName NEQ qFiles.name){
				continue;
			}
		} 
		// echo("media process skipped<br>");
		// break; // skip media import until it is done downloading
		arrName=listToArray(qFiles.name, "-");
		if(arrayLen(arrName) LT 2){
			continue;
		}
		resource=arrName[1];
		if(resource NEQ "media"){
			continue;
		} 
 		path=request.zos.globals.privateHomeDir&"mlsgrid/"&qFiles.name;
 		contents=application.zcore.functions.zReadFile(path); 
 		if(contents EQ false){
 			continue; // file missing, ignore it and do the next file
 		}
 		js=deserializeJSON(contents); 
		for(i=1;i<=arraylen(js.value);i++){
			application.currentMLSGridStatus="Process Media Row ###i# of #path#";
	 		if(structkeyexists(application, "cancelMLSGridImport")){
	 			echo("Import cancelled");
	 			abort;
	 		}
			ds=js.value[i];
			if(displayFields){
				for(k in ds){
					echo('ts["#k#"]=application.zcore.functions.zso(ds, "#k#");<br>');
				}
				break;
			}
			mediaCount++;

			if(ds["MlgCanView"] EQ "false"){
				db.sql="update #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
				set 
				mlsgrid_media_url=#db.param("")# 
				WHERE mls_id=#db.param(this.mls_id)# and 
				mlsgrid_media_key=#db.param("#ds["MediaKey"]#")# and 
				mlsgrid_media_deleted=#db.param(0)# ";
				db.execute("qUpdate");
			}else{
				ns=processMedia(ds);
				db.sql="select mlsgrid_media_id from #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
				WHERE mls_id=#db.param(this.mls_id)# and 
				mlsgrid_media_key=#db.param("#ns["MediaKey"]#")# and 
				mlsgrid_media_deleted=#db.param(0)# ";
				qMedia=db.execute("qMedia");

				if(qMedia.recordcount NEQ 0){
					db.sql="update #db.table("mlsgrid_media", request.zos.zcoreDatasource)#  SET
					mlsgrid_media_url=#db.param(ns["MediaURL"])#, 
					mlsgrid_media_downloaded=#db.param(1)#,
					listing_id=#db.param("#this.mls_id#-#ns["ResourceRecordID"]#")#,
					mlsgrid_media_order=#db.param(ns["Order"])#, 
					mlsgrid_media_updated_datetime=#db.param(request.zos.mysqlnow)# 
					WHERE mls_id=#db.param(this.mls_id)# and 
					mlsgrid_media_key=#db.param("#ns["MediaKey"]#")# and 
					mlsgrid_media_deleted=#db.param(0)# ";
					db.execute("qUpdate");
				}else{
					db.sql="INSERT INTO #db.table("mlsgrid_media", request.zos.zcoreDatasource)#  SET 
					mlsgrid_media_key=#db.param("#ns["MediaKey"]#")#,
					mlsgrid_media_downloaded=#db.param(1)#,
					listing_id=#db.param("#this.mls_id#-#ns["ResourceRecordID"]#")#,
					mlsgrid_media_url=#db.param(ns["MediaURL"])#, 
					mlsgrid_media_order=#db.param(ns["Order"])#, 
					mlsgrid_media_updated_datetime=#db.param(request.zos.mysqlnow)#,
					mls_id=#db.param(this.mls_id)#,
					mlsgrid_media_deleted=#db.param(0)# ";
					db.execute("qInsert");
				}
			}  
		}
		mediaFileCount++;
		application.zcore.functions.zDeleteFile(path);
 	} 

	if(not structkeyexists(form, "skipMedia") and mediaFileCount NEQ 0){
	 	echo("Processed #mediaCount# media records in #mediaFileCount# files<br>");
	 	return;
	}
 	// process all the listing files after media files
	loop query="qFiles"{
		if(qFiles.name CONTAINS "##"){
			continue;
		}
		if(fileName NEQ ""){
			if(fileName NEQ qFiles.name){
				continue;
			}
		}
		arrName=listToArray(qFiles.name, "-");
		if(arrayLen(arrName) LT 2){
			continue;
		}
		resource=arrName[1];
		if(resource EQ "exclude" or resource EQ "media"){
			continue;
		}
	 	// MlgCanView 
 		path=request.zos.globals.privateHomeDir&"mlsgrid/"&qFiles.name;
 		contents=application.zcore.functions.zReadFile(path);
 		if(contents EQ false){
 			continue; // file missing, ignore it and do the next file
 		}
 		js=deserializeJSON(contents);
		// writedump(resource);
		// writedump(js);			 abort;
		for(i=1;i<=arraylen(js.value);i++){
			application.currentMLSGridStatus="Process Listing Row ###i# of #path#";
	 		if(structkeyexists(application, "cancelMLSGridImport")){
	 			echo("Import cancelled");
	 			return;
	 		} 
			ds=js.value[i];

			if(displayFields){
				for(k in ds){
					echo('ts["#k#"]=application.zcore.functions.zso(ds, "#k#");<br>');
				}
				break;
			}
			listing_id=this.mls_id&"-"&ds.listingId;
			if(form.debug EQ 0 and (ds["MlgCanView"] EQ "false" or ds["StandardStatus"] NEQ "active")){
				// delete this record somehow
				if(structkeyexists(variables.listingLookup, listing_id)){ 
					db.sql="DELETE FROM #db.table("listing", request.zos.zcoreDatasource)#  
					WHERE listing_id =#db.param(listing_id)# and listing_deleted = #db.param(0)# ";
					db.execute("qDelete");
					db.sql="DELETE FROM #db.table("listing_data", request.zos.zcoreDatasource)#  
					WHERE listing_id =#db.param(listing_id)# and listing_data_deleted = #db.param(0)# ";
					db.execute("qDelete");
					db.sql="DELETE FROM #db.table("listing_memory", request.zos.zcoreDatasource)# WHERE listing_id=#db.param(listing_id)# and listing_deleted = #db.param(0)# ";
					db.execute("qDelete");
					db.sql="DELETE FROM #db.table("listing_track", request.zos.zcoreDatasource)# 
					WHERE listing_id=#db.param(listing_id)# and 
					listing_track_deleted = #db.param(0)#";
					db.execute("qDelete"); 
					// db.sql="UPDATE #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
					// SET listing_track_hash=#db.param('')#, 
					// listing_track_inactive=#db.param(1)#, 
					// listing_track_updated_datetime=#db.param(request.zos.mysqlnow)#  
					// WHERE listing_id=#db.param(listing_id)# and 
					// listing_track_deleted = #db.param(0)#";
					// db.execute("qDelete"); 
					deleteCount++;

				}else{
					skipCount++;
				}
				continue;
			}
			excludeDS=duplicate(ds);
			excludeListingFields(excludeDS);

			rs=processListing(ds, excludeDS);
			// writedump(rs);abort;

			// insert to the 4 tables
			dataChanged=true;
			if(not structkeyexists(variables.listingLookup, listing_id)){ 
				// new record - might want to keep the previous values someday
				rs.listing_track_id="null";
				rs.listing_id=listing_id;
				rs.listing_track_price=ds.ListPrice;
				rs.listing_track_price_change=ds.ListPrice;
				rs.listing_track_hash="";
				rs.listing_track_deleted="0";
				rs.listing_track_inactive='0';
				rs.listing_track_datetime=request.zos.mysqlnow;
				rs.listing_track_updated_datetime=request.zos.mysqlnow;
				rs.listing_track_processed_datetime=request.zos.mysqlnow;
				insertCount++;
			}else{
				rs.listing_track_id=variables.listingLookup[listing_id];
				rs.listing_id=listing_id;
				rs.listing_track_price=ds.ListPrice;
				rs.listing_track_change_price=ds.ListPrice;
				rs.listing_track_hash="";
				rs.listing_track_deleted="0";
				rs.listing_track_inactive='0';
				rs.listing_track_datetime=request.zos.mysqlnow;
				rs.listing_track_updated_datetime=request.zos.mysqlnow;
				rs.listing_track_processed_datetime=request.zos.mysqlnow;
				updateCount++;
			} 
			ts2={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing",
				struct:rs
			};
			ts2.struct.listing_deleted='0';
			ts5={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing_memory",
				struct:rs
			};
			ts5.struct.listing_deleted='0';
			ts3={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing_data",
				struct:rs
			};
			jsData={}; 
			for(i2 in rs){
				if(i2 DOES NOT CONTAIN "listing_" and not structkeyexists(variables.excludeStruct, i2)){
					jsData[i2]=rs[i2];
				}
			}
			ts3.struct.listing_data_json=serializeJson(jsData);
			ts3.struct.listing_data_deleted='0';
			ts4={
				debug:true,
				datasource:request.zos.zcoreDatasource,
				table:"listing_track",
				struct:rs
			};
			ts4.struct.listing_track_deleted='0'; 
			// writedump(ts3);abort;
			transaction action="begin"{
				try{ 
					if(not structkeyexists(variables.listingLookup, listing_id)){ 
						listing_track_id=application.zcore.functions.zInsert(ts4);
						application.zcore.functions.zInsert(ts5);
						application.zcore.functions.zInsert(ts2); 
						application.zcore.functions.zInsert(ts3); 
						variables.listingLookup[listing_id]=listing_track_id;
					}else{
						// listing_track
						ts4.forceWhereFields="listing_id,listing_track_deleted";
						application.zcore.functions.zUpdate(ts4);
						
						// listing_memory
						ts5.forceWhereFields="listing_id,listing_deleted";
						application.zcore.functions.zUpdate(ts5); 

						// listing
						ts2.forceWhereFields="listing_id,listing_deleted";
						application.zcore.functions.zUpdate(ts2);

						// listing_data
						ts3.forceWhereFields="listing_id,listing_data_deleted";
						application.zcore.functions.zUpdate(ts3);  
					}
					transaction action="commit"; 
				}catch(Any e){
					transaction action="rollback";
					rethrow;
				}
			} 
		 // 	echo("Inserted #insertCount#, Updated #updateCount#, Deleted #deleteCount#, Skipped #skipCount#");
			// structdelete(application, "mlsGridImportRunning");
			// structdelete(application, "currentMLSGridStatus");
			// structdelete(application, "mlsgridCronRunning");
			// echo('stopped');return;
		}
		// application.zcore.functions.zRenameFile(path, request.zos.globals.privateHomeDir&"mlsgrid-listing-backup/"&qFiles.name);
		application.zcore.functions.zDeleteFile(path);
 		if(resourceIndex NEQ 0){
 			break;
 		} 
	}
 	echo("Inserted #insertCount#, Updated #updateCount#, Deleted #deleteCount#, Skipped #skipCount#<br>");
	structdelete(application, "mlsGridImportRunning");
	structdelete(application, "currentMLSGridStatus");
	structdelete(application, "mlsgridCronRunning");
	return; 
	</cfscript>
</cffunction>


<cffunction name="excludeListingFields" localmode="modern" access="public">
	<cfargument name="ts" type="struct" required="yes">
	<cfscript>
	ts=arguments.ts;
	for(i in variables.excludeStruct){
		structdelete(ts,i);
	}

	</cfscript>
</cffunction>


<cffunction name="downloadData" localmode="modern" access="public">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	link=arguments.link;
 
	http url="#link#" timeout="10000"{
		httpparam type="header" name="Authorization" value="Bearer #request.zos.mlsGridToken#";
	}
	sleep(2000);
	//writedump(cfhttp);abort;
	if(cfhttp.status_code NEQ "200"){
		savecontent variable="out"{
			echo("MLSGrid download failed: #link#");
			writedump(cfhttp);
		}
		throw(out);
	}
	js=deserializeJson(cfhttp.filecontent);
	return js;
	</cfscript>
</cffunction>

<cffunction name="processMedia" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Media
	ts={};
	// ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["MediaKey"]=application.zcore.functions.zso(ds, "MediaKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["Order"]=application.zcore.functions.zso(ds, "Order");
	ts["ImageWidth"]=application.zcore.functions.zso(ds, "ImageWidth");
	ts["ImageHeight"]=application.zcore.functions.zso(ds, "ImageHeight");
	ts["ImageSizeDescription"]=application.zcore.functions.zso(ds, "ImageSizeDescription");
	ts["MediaURL"]=application.zcore.functions.zso(ds, "MediaURL");
	ts["MediaModificationTimestamp"]=application.zcore.functions.zso(ds, "MediaModificationTimestamp");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	ts["ResourceRecordKey"]=application.zcore.functions.zso(ds, "ResourceRecordKey");
	ts["ResourceRecordID"]=application.zcore.functions.zso(ds, "ResourceRecordID");
	ts["ResourceName"]=application.zcore.functions.zso(ds, "ResourceName");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");

	if(ts["MediaURL"] NEQ ""){
		fNameTemp1=this.mls_id&"-"&ts["ResourceRecordID"]&"-"&(ts["Order"]+1)&".jpeg";
		fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
		destinationFile=request.zos.sharedPath&"mls-images/"&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
		path=request.zos.sharedPath&"mls-images/"&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/";
		application.zcore.functions.zCreateDirectory(path);

		link=replace(ts["MediaURL"], "/zimageproxy/", "https://");
		HTTP METHOD="GET" URL="#link#" path="#path#" file="#fNameTemp1#" result="cfhttpresult" redirect="yes" timeout="30" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{
		}
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="downloadAllMedia" localmode="modern" access="remote"> 
	<cfscript>	
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	init();
	setting requesttimeout="100000";
	db=request.zos.noVerifyQueryObject;
	offset=0;
	while(true){
		db.sql="select * from 
		#db.table("listing", request.zos.zcoreDatasource)#, 
		#db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
		WHERE listing.listing_id like #db.param("#this.mls_id#-%")# and 
		listing.listing_id = mlsgrid_media.listing_id and 
		listing_deleted=#db.param(0)# and 
		mlsgrid_media_deleted=#db.param(0)# and 
		mlsgrid_media_downloaded=#db.param(0)# 
		ORDER BY mlsgrid_media_order
		LIMIT #db.param(offset)#, #db.param(100)# ";
		qMedia=db.execute("qMedia");
		if(qMedia.recordcount EQ 0){
			break;
		}
		for(row in qMedia){
			if(row.mlsgrid_media_url EQ ""){
				continue;
			}
			fNameTemp1=row.listing_id&"-"&(row.mlsgrid_media_order+1)&".jpeg";
			fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
			displayFile='/zretsphotos/'&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
			destinationFile=request.zos.sharedPath&"mls-images/"&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
			path=request.zos.sharedPath&"mls-images/"&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/";
			// application.zcore.functions.zCreateDirectory(path);

			row.mlsgrid_media_url=replace(row.mlsgrid_media_url, "/zimageproxy/", "https://");
			if(not fileexists(destinationFile)){
				HTTP METHOD="GET" URL="#row.mlsgrid_media_url#" path="#path#" file="#fNameTemp1#" result="cfhttpresult" redirect="yes" timeout="30" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{
				}
			}
			db.sql="UPDATE #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
			SET
			mlsgrid_media_downloaded=#db.param(1)# 
			WHERE listing_id = #db.param(row.listing_id)# and 
			mlsgrid_media_deleted=#db.param(0)#";
			qMedia=db.execute("qMedia");
			// echo('<img src="#displayFile#">');
			// abort;
		}
		offset+=100;
	}
	return ts;
	</cfscript>
</cffunction>
<!--- 
<cffunction name="processOffice" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Office
	ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["OfficeBranchType"]=application.zcore.functions.zso(ds, "OfficeBranchType");
	ts["OfficeEmail"]=application.zcore.functions.zso(ds, "OfficeEmail");
	ts["OfficeFax"]=application.zcore.functions.zso(ds, "OfficeFax");
	ts["MainOfficeKeyNumeric"]=application.zcore.functions.zso(ds, "MainOfficeKeyNumeric");
	ts["MainOfficeMlsId"]=application.zcore.functions.zso(ds, "MainOfficeMlsId");
	ts["OriginatingSystemOfficeKey"]=application.zcore.functions.zso(ds, "OriginatingSystemOfficeKey");
	ts["OfficeKey"]=application.zcore.functions.zso(ds, "OfficeKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["OfficeMlsId"]=application.zcore.functions.zso(ds, "OfficeMlsId");
	ts["OfficeBrokerKeyNumeric"]=application.zcore.functions.zso(ds, "OfficeBrokerKeyNumeric");
	ts["OfficeBrokerMlsId"]=application.zcore.functions.zso(ds, "OfficeBrokerMlsId");
	ts["CAR_OfficeLongName"]=application.zcore.functions.zso(ds, "CAR_OfficeLongName");
	ts["OfficeName"]=application.zcore.functions.zso(ds, "OfficeName");
	ts["OfficeStatus"]=application.zcore.functions.zso(ds, "OfficeStatus");
	ts["OfficePhone"]=application.zcore.functions.zso(ds, "OfficePhone");
	ts["CAR_PhotoCount"]=application.zcore.functions.zso(ds, "CAR_PhotoCount");
	ts["OfficeAOR"]=application.zcore.functions.zso(ds, "OfficeAOR");
	ts["CAR_StreetAddress"]=application.zcore.functions.zso(ds, "CAR_StreetAddress");
	ts["CAR_StreetCity"]=application.zcore.functions.zso(ds, "CAR_StreetCity");
	ts["CAR_StreetPostalCode"]=application.zcore.functions.zso(ds, "CAR_StreetPostalCode");
	ts["CAR_StreetStateOrProvince"]=application.zcore.functions.zso(ds, "CAR_StreetStateOrProvince");
	ts["CAR_WebPageAddress"]=application.zcore.functions.zso(ds, "CAR_WebPageAddress");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	</cfscript>
</cffunction> --->
<!--- 
<cffunction name="processMember" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Member
	ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["MemberStatus"]=application.zcore.functions.zso(ds, "MemberStatus");
	ts["MemberType"]=application.zcore.functions.zso(ds, "MemberType");
	ts["MemberAOR"]=application.zcore.functions.zso(ds, "MemberAOR");
	ts["CAR_BranchType"]=application.zcore.functions.zso(ds, "CAR_BranchType");
	ts["MemberMobilePhone"]=application.zcore.functions.zso(ds, "MemberMobilePhone");
	ts["MemberDirectPhone"]=application.zcore.functions.zso(ds, "MemberDirectPhone");
	ts["MemberPreferredPhone"]=application.zcore.functions.zso(ds, "MemberPreferredPhone");
	ts["MemberFax"]=application.zcore.functions.zso(ds, "MemberFax");
	ts["MemberFirstName"]=application.zcore.functions.zso(ds, "MemberFirstName");
	ts["MemberFullName"]=application.zcore.functions.zso(ds, "MemberFullName");
	ts["MemberLastName"]=application.zcore.functions.zso(ds, "MemberLastName");
	ts["MemberKeyNumeric"]=application.zcore.functions.zso(ds, "MemberKeyNumeric");
	ts["MemberKey"]=application.zcore.functions.zso(ds, "MemberKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["OriginalEntryTimestamp"]=application.zcore.functions.zso(ds, "OriginalEntryTimestamp");
	ts["MemberMiddleName"]=application.zcore.functions.zso(ds, "MemberMiddleName");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["MemberMlsId"]=application.zcore.functions.zso(ds, "MemberMlsId");
	ts["MemberNationalAssociationId"]=application.zcore.functions.zso(ds, "MemberNationalAssociationId");
	ts["OfficeKey"]=application.zcore.functions.zso(ds, "OfficeKey");
	ts["OfficeKeyNumeric"]=application.zcore.functions.zso(ds, "OfficeKeyNumeric");
	ts["OfficeMlsId"]=application.zcore.functions.zso(ds, "OfficeMlsId");
	ts["CAR_PhotoCount"]=application.zcore.functions.zso(ds, "CAR_PhotoCount");
	ts["MemberAddress1"]=application.zcore.functions.zso(ds, "MemberAddress1");
	ts["MemberCity"]=application.zcore.functions.zso(ds, "MemberCity");
	ts["MemberPostalCode"]=application.zcore.functions.zso(ds, "MemberPostalCode");
	ts["MemberStateOrProvince"]=application.zcore.functions.zso(ds, "MemberStateOrProvince");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	</cfscript>
</cffunction>
 --->

<cffunction name="listingLookupNewId" localmode="modern" output="no" returntype="any">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="oldid" type="string" required="yes">
	<cfargument name="defaultValue" type="string" required="no" default="">
	<cfscript>
	arguments.oldid=replace(arguments.oldid,'"','','all');
	if(arguments.oldid EQ ""){
		return arguments.defaultValue;
	} 
	if(structkeyexists(request.zos.listing.listingLookupStruct,arguments.type) and structkeyexists(request.zos.listing.listingLookupStruct[arguments.type].id,arguments.oldid)){
		return request.zos.listing.listingLookupStruct[arguments.type].id[arguments.oldid];
	}else{
		db=request.zos.queryObject;

		ts={
			table:"listing_lookup",
			datasource:request.zos.zcoreDatasource,
			struct:{
				listing_lookup_type:arguments.type,
				listing_lookup_value:arguments.oldid,
				listing_lookup_oldid:arguments.oldid,
				listing_lookup_datetime:request.zos.mysqlnow,
				listing_lookup_mls_provider:this.mls_provider,
				listing_lookup_oldid_unchanged:arguments.oldid,
				listing_lookup_updated_datetime:request.zos.mysqlnow,
				listing_lookup_deleted:0
			}
		}
		listing_lookup_id=application.zcore.functions.zInsert(ts);
		if(listing_lookup_id NEQ false){
			request.zos.listing.listingLookupStruct[arguments.type].id[arguments.oldId]=listing_lookup_id;
			return listing_lookup_id;
		}else{
			return arguments.defaultValue;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="processListing" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfargument name="excludeDs" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds; 
	startTime=gettickcount('nano');


	for(i in ds){
		if((right(i, 4) EQ "date" or i CONTAINS "timestamp") and isdate(ds[i])){
			d=parsedatetime(ds[i]);
			ds[i]=dateformat(d, "m/d/yyyy")&" "&timeformat(d, "h:mm tt");
		}else if(ds[i] EQ 0 or ds[i] EQ 1){

		}else if(len(ds[i]) lt 14 and isnumeric(ds[i]) and right(ds[i], 3) EQ ".00"){
			ds[i]=numberformat(ds[i]);
		}else{
			ds[i]=replace(ds[i], ",", ", ", "all");
		}
	}
	//writedump(ts); 		abort; 
	
	ds["ListPrice"]=replace(ds["ListPrice"],",","","ALL");
	
	local.listing_subdivision="";
	if(structkeyexists(ds, "SubdivisionName")){
		if(findnocase(","&ds["SubdivisionName"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			ds["SubdivisionName"]="";
		}else if(ds["SubdivisionName"] NEQ ""){
			ds["SubdivisionName"]=application.zcore.functions.zFirstLetterCaps(ds["SubdivisionName"]);
		}
		if(ds["SubdivisionName"] NEQ ""){
			local.listing_subdivision=ds["SubdivisionName"];
		}
	} 
	this.price=ds["ListPrice"];
	local.listing_price=ds["ListPrice"];
	cityName=ds["city"];
	// get the actual city name: 
	cid=getNewCityId(ds["city"], cityName, ds["StateOrProvince"]);
	 

	arrS=listtoarray(application.zcore.functions.zso(ds, 'SpecialListingConditions'),","); 
	local.listing_county="";
	if(local.listing_county EQ ""){
		local.listing_county=this.listingLookupNewId("county",ds['CountyOrParish']);
	}
	//writedump(listing_county); 		abort; 
	local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type", application.zcore.functions.zso(ds, 'PropertySubType'));


	local.listing_type_id=this.listingLookupNewId("listing_type",ds['PropertyType']);

	

	// rs=getListingTypeWithCode(ds["PropertyType"]);
	
	if(application.zcore.functions.zso(ds, "InternetAddressDisplayYN", false, "Y") EQ "N"){
		ds["StreetNumber"]="";
		ds["StreetName"]="";
		ds["StreetType"]="";
		ds["UnitNumber"]="";
	}

	// ds["PropertyType"]=rs.id;
	ad=ds['StreetNumber'];
	if(ad NEQ 0){
		address=trim(application.zcore.functions.zso(ds, "StreetDirPrefix")&" #ad# ");
	}else{
		address="";	
	}
	address&=" "&trim(ds['StreetName']&" "&ds['StreetSuffix']&" "&application.zcore.functions.zso(ds, "StreetDirSuffix"));
	curLat=ds.latitude;
	curLong=ds.longitude;
	// if(trim(address) NEQ ""){ 
	// 	rs5=this.baseGetLatLong(address,ds['StateOrProvince'],ds['PostalCode'], this.mls_id&"-"&ds.listingId);
	// 	if(rs5.success){
	// 		curLat=rs5.latitude;
	// 		curLong=rs5.longitude;
	// 	}
	// }
	address=application.zcore.functions.zfirstlettercaps(address);
	
	if(application.zcore.functions.zso(ds, 'UnitNumber') NEQ ''){
		address&=" Unit: "&ds["UnitNumber"];	
	} 
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=application.zcore.functions.zso(ds, 'YearBuilt');
	ts2.foreclosureField="";
	
	s={};//this.processRawStatus(ts2);
	arrS=listtoarray(application.zcore.functions.zso(ds, 'SpecialListingConditions'),",");
	for(i=1;i LTE arraylen(arrS);i++){
		c=trim(arrS[i]);
		if(c EQ "Short Sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
			break;
		} 
		if(c EQ "In Foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(c EQ "Real Estate Owned"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
	}
	if(application.zcore.functions.zso(ds, 'NewConstructionYN') EQ "Y"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["New Construction"]]=true;
	}
	if(ds["PropertyType"] EQ "Residential Lease" or ds["PropertyType"] EQ "Commercial Lease"){
		structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else{
		structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	}
	arrT3=[];
	local.listing_status=structkeylist(s,",");

	uns=structnew();
	tmp=application.zcore.functions.zso(ds, 'ArchitecturalStyle');
	//writedump(tmp);
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){ 
			tmp=this.listingLookupNewId("style",arrT[i]); 
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	local.listing_style=arraytolist(arrT3);
	//writedump(listing_style); 	abort;


	arrT2=[]; 
	tmp=application.zcore.functions.zso(ds, 'ParkingFeatures');
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("parking",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT2,tmp);
			}
		}
	}
	local.listing_parking=arraytolist(arrT2, ",");
	
	if(structkeyexists(ds,'ListingContractDate')){
		arguments.ss.listing_track_datetime=dateformat(ds["ListingContractDate"],"yyyy-mm-dd")&" "&timeformat(ds["ListingContractDate"], "HH:mm:ss");
	}
	arguments.ss.listing_track_updated_datetime=dateformat(ds["ModificationTimestamp"],"yyyy-mm-dd")&" "&timeformat(ds["ModificationTimestamp"], "HH:mm:ss"); 
	arguments.ss.listing_track_price=ds["ListPrice"];
	arguments.ss.listing_track_price_change=ds["ListPrice"];
	liststatus=ds["StandardStatus"];
	s2=structnew();
	/*
	Active (StandardStatus)
	Active Under Contract (StandardStatus)
	Canceled (StandardStatus)
	Closed (StandardStatus)
	Coming Soon
	Delete
	Expired (StandardStatus)
	Hold (StandardStatus)
	Incomplete
	Pending (StandardStatus)
	Withdrawn (StandardStatus)
	*/ 
	if(liststatus EQ "Active"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Active"]]=true;
	}
	if(liststatus EQ "Withdrawn"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Withdrawn"]]=true;
	}  
	if(liststatus EQ "Expired"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Expired"]]=true;
	}
	if(liststatus EQ "Closed"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Closed"]]=true;
	} 
	local.listing_liststatus=structkeylist(s2,",");
	if(local.listing_liststatus EQ ""){
		local.listing_liststatus=1;
	}
	
	// view & frontage
	arrT3=[];
	
	uns=structnew();
	tmp=application.zcore.functions.zso(ds, 'LotFeatures');		
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("frontage",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	} 
	local.listing_frontage=arraytolist(arrT3);
	
	local.listing_view=""; 

	local.listing_pool=0; 
	extFeatures={
		"INPOOL":true,
		"AGPOOL":true
	}; 
	tmp=application.zcore.functions.zso(ds, 'ExteriorFeatures'); 
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			if(structkeyexists(extFeatures, arrT[i])){
				local.listing_pool=1;	
				break;
			} 
		}
	}  
	
	
	rs=structnew();
	rs.mls_id=this.mls_id;
	rs.listing_id=this.mls_id&"-"&ds.listingId;
	rs.listing_acreage=application.zcore.functions.zso(ds, "LotSizeArea");
	rs.listing_baths=application.zcore.functions.zso(ds, "BathroomsFull");
	rs.listing_halfbaths=application.zcore.functions.zso(ds, "BathroomsHalf");
	rs.listing_beds=application.zcore.functions.zso(ds, "BedroomsTotal");
	rs.listing_city=cid;
	rs.listing_county=local.listing_county;
	rs.listing_frontage=","&local.listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=application.zcore.functions.zso(ds, "listprice");
	rs.listing_status=","&local.listing_status&",";
	rs.listing_state=application.zcore.functions.zso(ds, "StateOrProvince");
	rs.listing_type_id=local.listing_type_id;
	rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
	rs.listing_style=","&local.listing_style&",";
	rs.listing_view=","&local.listing_view&",";
	rs.listing_lot_square_feet=""; 
	rs.listing_square_feet=application.zcore.functions.zso(ds, "CAR_SqFtMain");
	rs.listing_subdivision=local.listing_subdivision;
	rs.listing_year_built=application.zcore.functions.zso(ds, "yearbuilt");
	rs.listing_office=application.zcore.functions.zso(ds, "ListOfficeMLSID");
	rs.listing_office_name=application.zcore.functions.zso(ds, "ListOfficeName");
	rs.listing_agent=application.zcore.functions.zso(ds, "ListAgentMlsId");
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=local.listing_pool;
	rs.listing_photocount=application.zcore.functions.zso(ds, "PhotosCount");
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=this.mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=application.zcore.functions.zso(ds, "PostalCode");
	rs.listing_condition="";
	rs.listing_parking=local.listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=local.listing_liststatus;
	rs.listing_data_remarks=application.zcore.functions.zso(ds, "PublicRemarks");
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(application.zcore.functions.zso(ds, "PostalCode"));
	rs.listing_data_detailcache1=getDetailCache1(arguments.excludeDS);
	rs.listing_data_detailcache2=getDetailCache2(arguments.excludeDS);
	rs.listing_data_detailcache3=getDetailCache3(arguments.excludeDS);

	rs.listing_track_sysid=ds["ListingKey"];

	rs.VirtualTourURLUnbranded=application.zcore.functions.zso(ds, "VirtualTourURLUnbranded");

	// make sure we have all the images before importing the listing.
	rs.arrPhoto=getMediaByListingId(this.mls_id&"-"&ds["ListingID"]);
	// for(i=1;i<=arrayLen(arrPhoto);i++){
	// 	rs["photo#i#"]=arrPhoto[i];
	// } 
	// writedump(rs);abort;

	return rs;
	</cfscript>
</cffunction>

   

<cffunction name="getListingDetailRowOutput" localmode="modern" output="no" returntype="string">
	<cfargument name="label" type="string" required="yes">
	<cfargument name="idx" type="struct" required="yes">
	<cfargument name="idxExclude" type="struct" required="yes">
	<cfargument name="idxMap" type="struct" required="yes">
	<cfargument name="allFields" type="struct" required="yes">
	<cfscript>
	// variables.fieldNameLookup
	idxTemp3=structnew();
	idxTemp32=structnew();
	n1=1;
	for(i in arguments.idxMap){
		idxTemp32[arguments.idxMap[i]&"-"&n1]=i;
		idxTemp3[i]=arguments.idxMap[i];
		n1++;
	}
	arrR2=[];
	arrK=structkeyarray(idxTemp32);
	arraysort(arrK, "text", "asc");
	for(i99=1;i99 LTE arraylen(arrK);i99++){
		if(not structkeyexists(variables.fieldNameLookup, i)){ 
			continue;
		}
		i=idxTemp32[arrK[i99]]; 
		for(i9 in arguments.allFields){
			if(arguments.allFields[i9].field EQ i){
				structdelete(arguments.allFields, i9);
				break;
			}
		}
		if(structkeyexists(arguments.idxExclude, i) EQ false){
			if(structkeyexists(arguments.idx, i) and structkeyexists(arguments.idx, i) and arguments.idx[i] NEQ "" and arguments.idx[i] NEQ "0"){
				arrayappend(arrR2, '<tr><th>'&application.zcore.functions.zfirstlettercaps(variables.fieldNameLookup[i])&'</th><td>'&htmleditformat(arguments.idx[i])&'</td></tr>'&chr(10));
			}
		}
	} 
	if(arraylen(arrR2) NEQ 0){
		return '<tr><td colspan="2"><h3>'&arguments.label&'</h3></td></tr>'&arraytolist(arrR2,"");
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
  <cfargument name="idx" type="struct" required="yes">
  <cfscript>
	var arrR=arraynew(1);
	var ts=structnew(); 
	variables.allFields={};


	ts["RoomBathroom1Level"]=true;
	ts["RoomBathroom2Level"]=true;
	ts["RoomBreakfastRoomLevel"]=true;
	ts["RoomDiningRoomLevel"]=true;
	ts["RoomFamilyRoomLevel"]=true;
	ts["RoomKitchenLevel"]=true;
	ts["RoomLivingRoomLevel"]=true;
	ts["RoomMasterBedroomLevel"]=true;
	ts["CAR_room1_RoomType"]=true;
	ts["CAR_room2_BathsFull"]=true;
	ts["CAR_room2_BathsHalf"]=true;
	ts["CAR_room2_BedsTotal"]=true;
	ts["RoomBathroom3Level"]=true;
	ts["RoomBathroom4Level"]=true;
	ts["RoomBathroom5Level"]=true;
	ts["RoomLaundryLevel"]=true;
	ts["RoomLoftLevel"]=true;
	ts["RoomMasterBedroom2Level"]=true;
	ts["RoomBedroom1Level"]=true;
	ts["RoomBedroom2Level"]=true;
	ts["CAR_room2_RoomType"]=true;
	ts["CAR_room3_BathsFull"]=true;
	ts["CAR_room3_BathsHalf"]=true;
	ts["CAR_room3_BedsTotal"]=true;
	ts["RoomBathroom6Level"]=true;
	ts["RoomLoft2Level"]=true;
	ts["RoomPlayRoomLevel"]=true;
	ts["RoomBedroom3Level"]=true;
	ts["CAR_room3_RoomType"]=true;
	ts["CAR_room4_BathsFull"]=true;
	ts["CAR_room4_BathsHalf"]=true;
	ts["CAR_room4_BedsTotal"]=true;
	ts["RoomNoneLevel"]=true;
	ts["CAR_room4_RoomType"]=true;
	ts["Flooring"]=true;
	ts["Furnished"]=true;
	ts["InteriorFeatures"]=true;
	ts["RoomPantryLevel"]=true;
	ts["AccessibilityFeatures"]=true;
	ts["NumberOfUnitsTotal"]=true;
	ts["CAR_SqFtGarage"]=true;
	ts["CAR_unit1_BathsFull"]=true;
	ts["CAR_unit1_BathsHalf"]=true;
	ts["UnitType1BedsTotal"]=true;
	ts["CAR_unit1_SqFtTotal"]=true;
	ts["CAR_unit1_UnitRooms"]=true;
	ts["CAR_unit2_BathsFull"]=true;
	ts["CAR_unit2_BathsHalf"]=true;
	ts["UnitType2BedsTotal"]=true;
	ts["CAR_unit2_SqFtTotal"]=true;
	ts["CAR_unit2_UnitRooms"]=true;
	ts["Cooling"]=true;
	ts["BathroomsFull"]=true;
	ts["BathroomsHalf"]=true;
	ts["BathroomsTotalInteger"]=true;
	ts["BedroomsTotal"]=true;
	ts["Appliances"]=true;
	ts["ConstructionMaterials"]=true;
	ts["FireplaceFeatures"]=true;
	ts["FireplaceYN"]=true;
	ts["FoundationDetails"]=true;
	ts["Heating"]=true;
	ts["LaundryFeatures"]=true;
	ts["CAR_SqFtAdditional"]=true;
	ts["BelowGradeFinishedArea"]=true;
	ts["CAR_SqFtLower"]=true;
	ts["CAR_SqFtMain"]=true;
	ts["CAR_SqFtThird"]=true;
	ts["LivingArea"]=true;
	ts["BuildingAreaTotal"]=true;
	ts["CAR_SqFtUnheatedBasement"]=true;
	ts["CAR_SqFtUnheatedLower"]=true;
	ts["CAR_SqFtUnheatedMain"]=true;
	ts["CAR_SqFtUnheatedThird"]=true;
	ts["CAR_SqFtUnheatedTotal"]=true;
	ts["CAR_SqFtUnheatedUpper"]=true;
	ts["RoomType"]=true;
	ts["CAR_room1_BathsFull"]=true;
	ts["CAR_room1_BathsHalf"]=true;
	ts["CAR_room1_BedsTotal"]=true;

	arrayappend(arrR, getListingDetailRowOutput("Interior Information", arguments.idx, variables.excludeStruct, ts, variables.allFields));
	    
	return arraytolist(arrR,'');
	
	</cfscript>
</cffunction>


<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
    <cfargument name="idx" type="struct" required="yes">
    <cfscript>
	var arrR=arraynew(1);
	var ts=structnew();  
	variables.allFields={};
 

ts["LotSizeArea"]=true;
ts["ParkingFeatures"]=true;

ts["Sewer"]=true;
ts["ArchitecturalStyle"]=true;
ts["CAR_Porch"]=true;
ts["EntryLevel"]=true;
ts["ExteriorFeatures"]=true;
ts["Elevation"]=true;
ts["Roof"]=true;
ts["StoriesTotal"]=true;
	arrayappend(arrR, getListingDetailRowOutput("Exterior Information", arguments.idx, variables.excludeStruct, ts, variables.allFields));
	    
	return arraytolist(arrR,'');
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
    <cfargument name="idx" type="struct" required="yes">
    <cfscript>
	var arrR=arraynew(1);
	var ts=structnew();   
	variables.allFields={};

ts["PetsAllowed"]=true;
ts["BuilderName"]=true;
// ts["CAR_BuyerAgentSaleYN"]=true;
ts["CumulativeDaysOnMarket"]=true;
// ts["City"]=true;
ts["CAR_ConstructionType"]=true;
// ts["CountyOrParish"]=true;
ts["CAR_DeedReference"]=true;
ts["DaysOnMarket"]=true;
ts["RoadSurfaceType"]=true;
ts["ElementarySchool"]=true;
// ts["CAR_GeocodeSource"]=true;
ts["HighSchool"]=true;
ts["AssociationName"]=true;
ts["AssociationPhone"]=true;
ts["CAR_HOASubjectTo"]=true;
ts["CAR_HOASubjectToDues"]=true;
// ts["Latitude"]=true;
// ts["ListAgentKey"]=true;
// ts["ListAgentDirectPhone"]=true;
// ts["ListAgentFullName"]=true;
// ts["ListAgentMlsId"]=true;
// ts["ListAgentAOR"]=true;
// ts["ListingContractDate"]=true;
// ts["ListingAgreement"]=true;
// ts["ListOfficeKey"]=true;
// ts["ListOfficeMlsId"]=true;
// ts["ListOfficeName"]=true;
// ts["ListOfficePhone"]=true;
// ts["ListPrice"]=true;
// ts["Longitude"]=true;
// ts["ListingKey"]=true;
// ts["OriginatingSystemModificationTimestamp"]=true;
ts["MiddleOrJuniorSchool"]=true;
// ts["OriginatingSystemName"]=true;
// ts["ListingId"]=true;
ts["Model"]=true;
ts["NewConstructionYN"]=true;
// ts["CAR_OwnerAgentYN"]=true;
ts["ParcelNumber"]=true;
// ts["PendingTimestamp"]=true;
// ts["InternetAddressDisplayYN"]=true;
// ts["InternetEntireListingDisplayYN"]=true;
// ts["CAR_PermitSyndicationYN"]=true;
// ts["PhotosCount"]=true;
// ts["PhotosChangeTimestamp"]=true;
ts["PostalCode"]=true;
ts["PostalCodePlus4"]=true;
ts["StructureType"]=true;
ts["PropertySubType"]=true;
ts["PropertyType"]=true;
ts["CAR_ProposedSpecialAssessmentYN"]=true;
// ts["PublicRemarks"]=true;
ts["CAR_RATIO_CurrentPrice_By_Acre"]=true;
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=true;
ts["RoadResponsibility"]=true;
// ts["BuyerAgentKey"]=true;
// ts["BuyerAgentAOR"]=true;
// ts["BuyerAgentMlsId"]=true;
// ts["BuyerOfficeKey"]=true;
// ts["BuyerOfficeMlsId"]=true;
// ts["ShowingContactPhone"]=true;
ts["SpecialListingConditions"]=true;
ts["CAR_SqFtUpper"]=true;
ts["StateOrProvince"]=true;
// ts["StandardStatus"]=true;
// ts["CAR_StatusContractualSearchDate"]=true;
// ts["StreetName"]=true;
// ts["StreetNumber"]=true;
// ts["StreetNumberNumeric"]=true;
// ts["StreetSuffix"]=true;
// ts["CAR_StreetViewParam"]=true;
ts["SubdivisionName"]=true;
ts["CAR_Table"]=true;
ts["TaxAnnualAmount"]=true;
ts["CAR_UnitCount"]=true;
// ts["UnitNumber"]=true;
// ts["InternetAutomatedValuationDisplayYN"]=true;
// ts["InternetConsumerCommentYN"]=true;
ts["WaterSource"]=true;
ts["CAR_WaterHeater"]=true;
ts["YearBuilt"]=true;
ts["ZoningDescription"]=true;
ts["CAR_MainLevelGarageYN"]=true;
ts["OccupantType"]=true;
// ts["CAR_ProjectedClosingDate"]=true;
ts["CAR_CCRSubjectTo"]=true;
// ts["MlgCanView"]=true;
// ts["ModificationTimestamp"]=true;
// ts["@odata.id"]=true;
ts["AboveGradeFinishedArea"]=true;
ts["AvailabilityDate"]=true;
ts["CloseDate"]=true;
ts["ClosePrice"]=true;
ts["CAR_DOMToClose"]=true;
ts["CAR_PropertySubTypeSecondary"]=true;
ts["TenantPays"]=true;
ts["CommunityFeatures"]=true;
ts["CAR_ConstructionStatus"]=true;
ts["Directions"]=true;
// ts["ListingTerms"]=true;
ts["SyndicationRemarks"]=true;
ts["WaterfrontFeatures"]=true;
ts["CAR_ZoningNCM"]=true;
ts["AssociationFee"]=true;
ts["AssociationFeeFrequency"]=true;
ts["CAR_CanSubdivideYN"]=true;
// ts["CoListAgentKey"]=true;
// ts["CoListAgentFullName"]=true;
// ts["CoListAgentAOR"]=true;
// ts["CoListAgentMlsId"]=true;
// ts["CoListOfficeKey"]=true;
// ts["CoListOfficeMlsId"]=true;
// ts["CoListOfficeName"]=true;
ts["HabitableResidenceYN"]=true;
ts["LotSizeDimensions"]=true;
ts["CAR_OutBuildingsYN"]=true;
ts["CAR_PlatBookSlide"]=true;
ts["CAR_PlatReferenceSectionPages"]=true;
ts["CAR_Restrictions"]=true;
ts["CAR_SqFtBuildingMinimum"]=true;
ts["CAR_SuitableUse"]=true;
ts["CAR_CorrectionCount"]=true;
ts["LotFeatures"]=true;
// ts["StreetDirSuffix"]=true;
// ts["VirtualTourURLUnbranded"]=true;
ts["WaterBodyName"]=true;
ts["Inclusions"]=true;
ts["CAR_InsideCityYN"]=true;
ts["NumberOfBuildings"]=true;
ts["CAR_RestrictionsDescription"]=true;
ts["CAR_SqFtAvailableMaximum"]=true;
ts["CAR_SqFtAvailableMinimum"]=true;
ts["CAR_SqFtMaximumLease"]=true;
ts["CAR_SqFtMinimumLease"]=true;
ts["CAR_TransactionType"]=true;
// ts["AccessCode"]=true;
ts["CAR_CommercialLocationDescription"]=true;
ts["CAR_ComplexName"]=true;
ts["CrossStreet"]=true;
ts["CAR_Documents"]=true;
ts["CAR_FloodPlain"]=true;
ts["CAR_RailService"]=true;
// ts["StreetDirPrefix"]=true;
ts["Utilities"]=true;

	arrayappend(arrR, getListingDetailRowOutput("Additional Information", arguments.idx, variables.excludeStruct, ts, variables.allFields));
	     

	return arraytolist(arrR,'');
	</cfscript>
</cffunction>
 

<cffunction name="getFieldNames" localmode="modern" access="public">
	<cfscript>
		ts={};
		ts["AboveGradeFinishedArea"]="Above Grade Finished Area";
	ts["AccessCode"]="Access Code";
	ts["AccessibilityFeatures"]="Accessibility Features";
	ts["Appliances"]="Appliances";
	ts["ArchitecturalStyle"]="Architectural Style";
	ts["AssociationFee"]="Association Fee";
	ts["AssociationFeeFrequency"]="Association Fee Frequency";
	ts["AssociationName"]="Association Name";
	ts["AssociationPhone"]="Association Phone";
	ts["AvailabilityDate"]="Availability Date";
	ts["BathroomsFull"]="Bathrooms Full";
	ts["BathroomsHalf"]="Bathrooms Half";
	ts["BathroomsTotalInteger"]="Bathrooms Total Integer";
	ts["BedroomsTotal"]="Bedrooms Total";
	ts["BelowGradeFinishedArea"]="Below Grade Finished Area";
	ts["BuilderName"]="Builder Name";
	ts["BuildingAreaTotal"]="Building Area Total";
	ts["CAR_CanSubdivideYN"]="Can Subdivide YN";
	ts["CAR_CommercialLocationDescription"]="Commercial Location Description";
	ts["CAR_ComplexName"]="Complex Name";
	ts["CAR_ConstructionStatus"]="Construction Status";
	ts["CAR_ConstructionType"]="Construction Type";
	ts["CAR_CorrectionCount"]="Correction Count";
	ts["CAR_DeedReference"]="Deed Reference";
	ts["CAR_FloodPlain"]="Flood Plain";
	ts["CAR_GeocodeSource"]="Geocode Source";
	ts["CAR_HOASubjectTo"]="HOA Subject To";
	ts["CAR_HOASubjectToDues"]="HOA Subject To Dues";
	ts["CAR_InsideCityYN"]="Inside City YN";
	ts["CAR_MainLevelGarageYN"]="Main Level Garage YN";
	ts["CAR_OutBuildingsYN"]="Out Buildings YN";
	ts["CAR_PermitSyndicationYN"]="Permit Syndication YN";
	ts["CAR_PlatBookSlide"]="Plat Book Slide";
	ts["CAR_PlatReferenceSectionPages"]="Plat Reference Section Pages";
	ts["CAR_Porch"]="Porch";
	ts["CAR_ProjectedClosingDate"]="Projected Closing Date";
	ts["CAR_PropertySubTypeSecondary"]="Property Sub Type Secondary";
	ts["CAR_ProposedSpecialAssessmentYN"]="Proposed Special Assessment YN";
	ts["CAR_RailService"]="Rail Service";
	ts["CAR_RATIO_CurrentPrice_By_Acre"]="RATIO Current Price By Acre";
	ts["CAR_RATIO_ListPrice_By_TaxAmount"]="RATIO ListPrice By TaxAmount";
	ts["CAR_Restrictions"]="Restrictions";
	ts["CAR_RestrictionsDescription"]="Restrictions Description";
	ts["CAR_room1_BathsFull"]="Room 1 Baths Full";
	ts["CAR_room1_BathsHalf"]="Room 1 Baths Half";
	ts["CAR_room1_BedsTotal"]="Room 1 Beds Total";
	ts["CAR_room1_RoomType"]="Room 1 Room Type";
	ts["CAR_room2_BathsFull"]="Room 2 Baths Full";
	ts["CAR_room2_BathsHalf"]="Room 2 Baths Half";
	ts["CAR_room2_BedsTotal"]="Room 2 Beds Total";
	ts["CAR_room2_RoomType"]="Room 2 Room Type";
	ts["CAR_room3_BathsFull"]="Room 3 Baths Full";
	ts["CAR_room3_BathsHalf"]="Room 3 Baths Half";
	ts["CAR_room3_BedsTotal"]="Room 3 Beds Total";
	ts["CAR_room3_RoomType"]="Room 3 Room Type";
	ts["CAR_room4_BathsFull"]="Room 4 Baths Full";
	ts["CAR_room4_BathsHalf"]="Room 4 Baths Half";
	ts["CAR_room4_BedsTotal"]="Room 4 Beds Total";
	ts["CAR_room4_RoomType"]="Room 4 Room Type";
	ts["CAR_SqFtAdditional"]="SqFt Additional";
	ts["CAR_SqFtAvailableMaximum"]="SqFt Available Maximum";
	ts["CAR_SqFtAvailableMinimum"]="SqFt Available Minimum";
	ts["CAR_SqFtBuildingMinimum"]="SqFt Building Minimum";
	ts["CAR_SqFtGarage"]="SqFt Garage";
	ts["CAR_SqFtLower"]="SqFt Lower";
	ts["CAR_SqFtMain"]="SqFt Main";
	ts["CAR_SqFtMaximumLease"]="SqFt Maximum Lease";
	ts["CAR_SqFtMinimumLease"]="SqFt Minimum Lease";
	ts["CAR_SqFtThird"]="SqFt Third";
	ts["CAR_SqFtUnheatedBasement"]="SqFt Unheated Basement";
	ts["CAR_SqFtUnheatedLower"]="SqFt Unheated Lower";
	ts["CAR_SqFtUnheatedMain"]="SqFt Unheated Main";
	ts["CAR_SqFtUnheatedThird"]="SqFt Unheated Third";
	ts["CAR_SqFtUnheatedTotal"]="SqFt Unheated Total";
	ts["CAR_SqFtUnheatedUpper"]="SqFt Unheated Upper";
	ts["CAR_SqFtUpper"]="SqFt Upper";
	ts["CAR_StatusContractualSearchDate"]="Status Contractual Search Date";
	ts["CAR_StreetViewParam"]="Street View Param";
	ts["CAR_SuitableUse"]="Suitable Use";
	ts["CAR_Table"]="Table";
	ts["CAR_TransactionType"]="Transaction Type";
	ts["CAR_unit1_BathsFull"]="Unit 1 Baths Full";
	ts["CAR_unit1_BathsHalf"]="Unit 1 Baths Half";
	ts["CAR_unit1_SqFtTotal"]="Unit 1 SqFt Total";
	ts["CAR_unit1_UnitRooms"]="Unit 1 Unit Rooms";
	ts["CAR_unit2_BathsFull"]="Unit 2 Baths Full";
	ts["CAR_unit2_BathsHalf"]="Unit 2 Baths Half";
	ts["CAR_unit2_SqFtTotal"]="Unit 2 SqFt Total";
	ts["CAR_unit2_UnitRooms"]="Unit 2 Unit Rooms";
	ts["CAR_UnitCount"]="Unit Count";
	ts["CAR_WaterHeater"]="Water Heater";
	ts["CAR_ZoningNCM"]="Zoning NCM";
	ts["City"]="City";
	ts["CloseDate"]="Close Date";
	ts["ClosePrice"]="Close Price";
	ts["CommunityFeatures"]="Community Features";
	ts["ConstructionMaterials"]="Construction Materials";
	ts["Cooling"]="Cooling";
	ts["CountyOrParish"]="County Or Parish";
	ts["CrossStreet"]="Cross Street";
	ts["CumulativeDaysOnMarket"]="Cumulative Days On Market";
	ts["DaysOnMarket"]="Days On Market";
	ts["Directions"]="Directions";
	ts["ElementarySchool"]="Elementary School";
	ts["Elevation"]="Elevation";
	ts["EntryLevel"]="EntryLevel";
	ts["ExteriorFeatures"]="Exterior Features";
	ts["FireplaceFeatures"]="Fireplace Features";
	ts["FireplaceYN"]="Fireplace YN";
	ts["Flooring"]="Flooring";
	ts["FoundationDetails"]="Foundation Details";
	ts["Furnished"]="Furnished";
	ts["HabitableResidenceYN"]="Habitable Residence YN";
	ts["Heating"]="Heating";
	ts["HighSchool"]="High School";
	ts["Inclusions"]="Inclusions";
	ts["InteriorFeatures"]="Interior Features";
	ts["LaundryFeatures"]="Laundry Features";
	ts["ListPrice"]="List Price";
	ts["LivingArea"]="Living Area";
	ts["LotFeatures"]="Lot Features";
	ts["LotSizeArea"]="Lot Size Area";
	ts["LotSizeDimensions"]="Lot Size Dimensions";
	ts["MiddleOrJuniorSchool"]="Middle Or Junior School";
	ts["Model"]="Model";
	ts["NewConstructionYN"]="New Construction YN";
	ts["NumberOfBuildings"]="Number Of Buildings";
	ts["NumberOfUnitsTotal"]="Number Of Units Total";
	ts["OccupantType"]="Occupant Type";
	ts["ParcelNumber"]="Parcel Number";
	ts["ParkingFeatures"]="Parking Features";
	ts["PetsAllowed"]="Pets Allowed";
	ts["PhotosCount"]="Photos Count";
	ts["PostalCode"]="Postal Code";
	ts["PostalCodePlus4"]="Postal Code Plus 4";
	ts["PropertySubType"]="Property Sub Type";
	ts["PropertyType"]="Property Type";
	ts["PublicRemarks"]="Public Remarks";
	ts["RoadResponsibility"]="Road Responsibility";
	ts["RoadSurfaceType"]="Road SurfaceType";
	ts["Roof"]="Roof";
	ts["RoomBathroom1Level"]="Room Bathroom 1 Level";
	ts["RoomBathroom2Level"]="Room Bathroom 2 Level";
	ts["RoomBathroom3Level"]="Room Bathroom 3 Level";
	ts["RoomBathroom4Level"]="Room Bathroom 4 Level";
	ts["RoomBathroom5Level"]="Room Bathroom 5 Level";
	ts["RoomBathroom6Level"]="Room Bathroom 6 Level";
	ts["RoomBedroom1Level"]="Room Bedroom 1 Level";
	ts["RoomBedroom2Level"]="Room Bedroom 2 Level";
	ts["RoomBedroom3Level"]="Room Bedroom 3 Level";
	ts["RoomBreakfastRoomLevel"]="Room Breakfast Room Level";
	ts["RoomDiningRoomLevel"]="Room Dining Room Level";
	ts["RoomFamilyRoomLevel"]="Room Family Room Level";
	ts["RoomKitchenLevel"]="Room Kitchen Level";
	ts["RoomLaundryLevel"]="Room Laundry Level";
	ts["RoomLivingRoomLevel"]="Room Living Room Level";
	ts["RoomLoft2Level"]="Room Loft 2 Level";
	ts["RoomLoftLevel"]="Room Loft Level";
	ts["RoomMasterBedroom2Level"]="Room Master Bedroom 2 Level";
	ts["RoomMasterBedroomLevel"]="Room Master Bedroom Level";
	ts["RoomNoneLevel"]="Room None Level";
	ts["RoomPantryLevel"]="Room Pantry Level";
	ts["RoomPlayRoomLevel"]="Room Play Room Level";
	ts["RoomType"]="Room Type";
	ts["Sewer"]="Sewer";
	ts["SpecialListingConditions"]="Special Listing Conditions";
	ts["StandardStatus"]="Standard Status";
	ts["StateOrProvince"]="State Or Province";
	ts["StoriesTotal"]="Stories Total";
	ts["StreetDirPrefix"]="Street Dir Prefix";
	ts["StreetDirSuffix"]="Street Dir Suffix";
	ts["StreetName"]="Street Name";
	ts["StreetNumber"]="Street Number";
	ts["StreetNumberNumeric"]="Street Number Numeric";
	ts["StreetSuffix"]="Street Suffix";
	ts["StructureType"]="Structure Type";
	ts["SubdivisionName"]="Subdivision Name";
	ts["TaxAnnualAmount"]="TaxAnnual Amount";
	ts["TenantPays"]="Tenant Pays";
	ts["UnitNumber"]="Unit Number";
	ts["UnitType1BedsTotal"]="Unit Type 1 Beds Total";
	ts["UnitType2BedsTotal"]="Unit Type 2 Beds Total";
	ts["Utilities"]="Utilities";
	ts["VirtualTourURLUnbranded"]="Virtual Tour URL Unbranded";
	ts["WaterBodyName"]="Water Body Name";
	ts["WaterfrontFeatures"]="Waterfront Features";
	ts["WaterSource"]="Water Source";
	ts["YearBuilt"]="Year Built";
	ts["ZoningDescription"]="Zoning Description";


	return ts;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>