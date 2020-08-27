<cfcomponent>
<cfoutput>  
<cffunction name="updateDistanceCache" localmode="modern" access="remote" returntype="any">
<cfsetting requesttimeout="5000">
	<cfscript>
	
	cc=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
	cc.updateDistanceCache();
	writeoutput('City Distance table updated');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<!--- 
call for just one mls_id:
/z/listing/tasks/listingLookupBuilder/index?mls_id=28
or all of them without mls_id
/z/listing/tasks/listingLookupBuilder/index
 --->
<cffunction name="index" localmode="modern" access="remote" returntype="any"> 
	<cfscript>
	var db=request.zos.queryObject;
	var arrError=arraynew(1);
	var skipStruct=structnew();
	var arrMLS=[];
	var cityCreated=false;
	var arrSql=arraynew(1);
	var mlsCount=2;
	var listing_lookup_datetime=request.zos.mysqlnow;
	var todayDateTime=dateformat(now(),"yyyy-mm-dd")&" 00:00:00"; 
	var rs=0;
	var r1=0;
	var i=0;
	
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="5000";
	application.zcore.listingCom.makeListingImportDataReady();
	//request.zos.listing=structnew();
	//request.zos.listing.mlsStruct=structnew();

	form.mls_id=application.zcore.functions.zso(form, 'mls_id');
	if(form.mls_id NEQ "" or (request.zos.istestserver EQ false and application.zcore.functions.zso(form,'zforcelisting') NEQ 1)){
		db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# 
		WHERE ";
		if(form.mls_id EQ ""){
			db.sql&=" mls_update_date< #db.param(todayDateTime)# and  ";
		}
		db.sql&=" mls_deleted = #db.param(0)# and 
		mls_status=#db.param('1')#";
		qMC=db.execute("qMC");
		loop query="qMC"{
			if(form.mls_id NEQ ""){
				if(qMC.mls_id NEQ form.mls_id){
					skipStruct[qMC.mls_id]=true;
					writeoutput('Skipping mls_id = '&qMC.mls_id&'<br />');
				}
			}else{
				skipStruct[qMC.mls_id]=true;
				writeoutput('Skipping mls_id = '&qMC.mls_id&'<br />');
			}
		}
	} 
	for(i in application.zcore.listingStruct.mlsComObjects){
		if(structkeyexists(skipStruct, i) EQ false){
			arrayappend(arrMLS,application.zcore.listingStruct.mlsComObjects[i].mls_provider);
			if(request.zos.isTestServer){
				local.tempCom=createobject("component",application.zcore.listingStruct.mlsStruct[i].mlsComPath);
				local.tempCom.setMLS(i);
				rs=local.tempCom.getLookupTables();
			}else{
				rs=application.zcore.listingStruct.mlsComObjects[i].getLookupTables();
			}
			if(arraylen(rs.arrError) NEQ 0){
				mail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="listing lookup builder errors" type="html"{
					writeoutput('#application.zcore.functions.zHTMLDoctype()#
					<head>
					<meta charset="utf-8" />
					<title>errors</title>
					</head>
					
					<body>
					<h1>The following errors occurred in the scheduled task</h1>
					<p>'&request.zos.globals.serverdomain&'/z/listing/tasks/listingLookupBuilder/index</p>
					<p>'&arraytolist(arrError,"<br />")&'</p>
					</body>
					</html>');
				}
			}
			if(arraylen(rs.arrSQL) NEQ 0){
				db.sql="INSERT INTO #db.table("listing_lookup", request.zos.zcoreDatasource)#  
				(listing_lookup_mls_provider, listing_lookup_type, listing_lookup_value, listing_lookup_oldid, 
					listing_lookup_datetime, listing_lookup_oldid_unchanged, listing_lookup_updated_datetime, listing_lookup_deleted) 
				VALUES"&db.trustedSQL(arraytolist(rs.arrSQL))&" 
				ON DUPLICATE KEY UPDATE 
				listing_lookup_mls_provider=VALUES(listing_lookup_mls_provider), 
				listing_lookup_type=VALUES(listing_lookup_type), 
				listing_lookup_value=VALUES(listing_lookup_value), 
				listing_lookup_oldid=VALUES(listing_lookup_oldid), 
				listing_lookup_datetime=#db.trustedSQL("'"&listing_lookup_datetime&"'")#, 
				listing_lookup_oldid_unchanged=VALUES(listing_lookup_oldid_unchanged),
				listing_lookup_updated_datetime=VALUES(listing_lookup_updated_datetime),
				listing_lookup_deleted=VALUES(listing_lookup_deleted)";
				if(request.zos.isdeveloper and application.zcore.functions.zso(form,'zdebug') NEQ ""){
					writeoutput("<h2>sql for mls_id: "&i&"</h2>");
					writeoutput(db.sql&"<br /><hr /><br />");
				}
				if(db.execute("qInsert") EQ false){
					application.zcore.template.fail("Failed to insert/update listing_lookup table");	
				}
			}
			if(rs.cityCreated){
				cityCreated=true;
			}
		}
	}
	if(cityCreated){
		cc=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
		cc.updateDistanceCache();
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
	</cfscript>


</cffunction>
</cfoutput>
</cfcomponent>