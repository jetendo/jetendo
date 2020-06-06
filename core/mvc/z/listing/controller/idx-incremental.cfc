<cfcomponent>
<cfoutput>
<cfscript>
this.nowDate=request.zos.mysqlnow;
this.dataStruct=structnew();
this.optionstruct=structnew();
this.optionstruct.limitTestServer=true;
this.inited=false;
</cfscript>

<!--- /z/listing/idx-incremental/index?mls_id=".$mls_id."&filename=".$filename --->
<cffunction name="index" localmode="modern" access="remote" returntype="any"> 
	<cfscript> 
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	form.mls_id=application.zcore.functions.zso(form, "mls_id", true);
	form.filename=application.zcore.functions.zso(form, "filename");
	if(form.filename EQ "" or form.filename CONTAINS ".." or form.filename CONTAINS "/" or form.filename CONTAINS "\"){
		application.zcore.functions.z404("Invalid filename: #form.filename#");
	}
	setting requesttimeout="150000";
	request.ignoreslowscript=true;
  
	application.zcore.listingCom.makeListingImportDataReady();
  
	try{
		r=init();
		if(r EQ false){
			process();
		}
	}catch(Any e){
		structdelete(application.zcore, 'mlsImportIsRunning');
		rethrow;	
	}
	structdelete(application.zcore, 'mlsImportIsRunning');
	abort;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="public" returntype="any">
    <cfscript>
	var db=request.zos.queryObject;
	this.inited=true;
	application.zcore.listingCom=application.zcore.listingStruct.configCom;
	
	// process the mls provider that is the most out of date first
	db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls 
	WHERE mls_status=#db.param('1')# and 
	mls_id=#db.param(form.mls_id)# and 
	mls_com like #db.param('rets%')# and 
	mls_deleted = #db.param(0)#
	ORDER BY mls_update_date ASC ";
	qMLS=db.execute("qMLS", "", 10000, "query", false);  
	this.optionstruct.filePath=false;
  
	for(row in qMLS){
		this.optionstruct.mls_id=row.mls_id;
		this.optionstruct.delimiter=row.mls_delimiter;
		this.optionstruct.csvquote=row.mls_csvquote;
		this.optionstruct.first_line_columns=row.mls_first_line_columns;
		this.optionstruct.charset=row.mls_file_charset;
		this.optionstruct.row=row;
		this.optionstruct.mlsProviderCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.mls-provider.#row.mls_com#");
		this.optionstruct.mlsproviderCom.setMLS(this.optionstruct.mls_id);
		this.optionstruct.filePath=request.zos.sharedPath&"mls-data/"&row.mls_id&"/"&form.filename;
		this.optionstruct.skipBytes=0;
	}
	if(this.optionstruct.filePath EQ false or not fileexists(this.optionStruct.filePath)){
		application.zcore.functions.z404('Invalid filename: '&form.filename);
	} 
	
	request.zos.listing=application.zcore.listingStruct;
	if(this.optionstruct.first_line_columns EQ 1){
		f=fileopen(this.optionstruct.filePath,"read", this.optionstruct.charset);
		if(fileIsEOF(f)){
			fclose(f);
			application.zcore.functions.zDeleteFile(this.optionstruct.filePath);
			abort;
		}
		try{
			firstline=lcase(filereadline(f));
		}catch(Any excpt){
			fileclose(f);
			savecontent variable="out"{
				writedump(excpt);
			}
			throw(out&"<br>firstline=lcase(filereadline(f)); failed | #this.optionstruct.filepath#.");
		}
		fileclose(f); 
		arrColumns=listtoarray(replace(firstline," ","","ALL"), this.optionstruct.delimiter, true);
		this.optionstruct.mlsproviderCom.setColumns(arrColumns);
		this.optionstruct.arrColumns=arrColumns; 
	}else if(structkeyexists(this.optionstruct,"arrColumns")){
		this.optionstruct.mlsProviderCom.setColumns(this.optionstruct.arrColumns); 
	} 
 
	this.optionstruct.mlsproviderCom.initImport("property", application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct);
	if(not structkeyexists(this.optionstruct,"arrColumns") and structkeyexists(application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct,"arrColumns")){
		this.optionstruct.arrColumns=request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.arrColumns;
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="process" localmode="modern" access="public" returntype="any"> 
    <cfscript> 
	var db=request.zos.queryObject;  
	try{ 
		if(this.optionstruct.delimiter EQ ""){
			throw("The delimiter for mls_id, "&this.optionstruct.mls_id&", can't be an empty string.");	
		}
		request.zos.idxFileHandle=fileOpen(this.optionstruct.filePath, 'read', this.optionStruct.charset);
		  
		if(fileIsEOF(request.zos.idxFileHandle)){
			fileComplete=true;
		}else{
			// variables.csvParser=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.csvParser");
			// variables.csvParser.pathToOstermillerCSVParserJar=application.zcore.cfmlwebinfpath&"lib/ostermillerutils.jar";
			// variables.csvParser.enableJava=request.zos.isJavaEnabled;
			// variables.csvParser.arrColumn=this.optionstruct.arrColumns;
			// variables.csvParser.separator=this.optionStruct.delimiter;
			// variables.csvParser.textQualifier=this.optionstruct.csvquote;
			// variables.csvParser.init();
			if(this.optionstruct.first_line_columns EQ 1){
				line2=fileReadLine(request.zos.idxFileHandle); // ignore columns since they were already read
			}else{
				line2="ignore";	
			}
			fileComplete=false; 
			if(fileIsEOF(request.zos.idxFileHandle)){
				fileComplete=true;
			}  
		}
		if(not fileComplete){
			startTime=gettickcount('nano'); 
			// application.zcore.idxImportStatus="Bytes read: "&this.optionStruct.skipBytes&" of "&this.optionstruct.filepath; 
			if(fileIsEOF(request.zos.idxFileHandle)){
				fileComplete=true; 
				break;	
			}
			while(true){
				line=fileReadLine(request.zos.idxFileHandle);
				// this.optionstruct.skipBytes+=len(line)+1;
				if(trim(line) EQ ""){
					continue;
				}
				// line=variables.csvParser.parseLineIntoArray(line);  
				// request.curline=line;

				// gets the listing_id and hash for row - might not be needed 
				// r1=this.addRow(line); 

				// gets the listing_track and sets whether record is new or update
				// this.checkDuplicates(); 

				// imports the one record.
				arrLine=listToArray(line, chr(9), true);
				this.import(arrLine);
				if(fileIsEOF(request.zos.idxFileHandle)){
					fileComplete=true;
					break;
				}  
			}
		}
		fileClose(request.zos.idxFileHandle); 
		writeoutput('File import, '&this.optionstruct.filepath&',  is complete<br />');
		application.zcore.functions.zDeleteFile(this.optionstruct.filepath);	
		if(fileexists(this.optionstruct.filepath)){
			throw('File: #this.optionstruct.filepath# exists after processing completed successfully.');
		}
	}catch(Any e){
		if(structkeyexists(request.zos, 'fileHandle')){
			fileClose(request.zos.idxFileHandle);
		}
		rethrow;
	}
	db.sql="UPDATE #db.table("mls", request.zos.zcoreDatasource)# mls 
	SET 
	mls_error_sent=#db.param('0')#, 
	mls_updated_datetime=#db.param(request.zos.mysqlnow)#, 
	mls_update_date = #db.param(request.zos.mysqlnow)# 
	where mls_id = #db.param(this.optionstruct.mls_id)# and 
	mls_deleted=#db.param(0)#";
	db.execute("q");

	// it works, so disabling this for now:
	// emailStruct={};
	// emailStruct.subject='Completed Incremental RETS Update';
	// emailStruct.html='<!DOCTYPE html><html><head></head><body><h2>Completed Incremental RETS Update</h2>
	// <p>File: #this.optionstruct.filepath#</p>
	// </body></html>';
	// emailStruct.to=request.zos.developerEmailTo;
	// emailStruct.from=request.zos.developerEmailFrom;
	// rCom=application.zcore.email.send(emailStruct);
	
	</cfscript>
</cffunction>

    
<cffunction name="import" localmode="modern" access="public" returntype="any">
	<cfargument name="arrData" type="array" required="yes">
	<cfscript>
	arrData=arguments.arrData;
	var db=request.zos.queryObject;
	nowDate1=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"); 

	listing_id=this.optionstruct.mls_id&'-'&arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset];
 
	arrayClear(request.zos.arrQueryLog);
	startTime=gettickcount('nano');

	// check if listing exists
	db.sql="select *
	from #db.table("listing_track", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("listing", request.zos.zcoreDatasource)# ON 
	listing.listing_id = listing_track.listing_id and 
	listing_deleted=#db.param(0)#  
	where listing_track.listing_id = #db.param(listing_id)# and 
	listing_track_deleted = #db.param(0)#";
	qTrack=db.execute("qTrack", "", 10000, "query", false);  

	dataStruct={
		arrData:arrData,
		listing_id:listing_id,
		listing_mls_id:form.mls_id
	};
	newHash=hash(arraytolist(arrData, chr(10)));
	if(qTrack.recordcount EQ 0){
		// doesn't exist.
		dataStruct.hasListing=false;
		dataStruct.update=false;
		dataStruct.new=true;
	}else if(qTrack.listing_deleted EQ ""){
		// listing missing
		dataStruct.hasListing=false;
		dataStruct.update=false;
		dataStruct.new=false;
		dataStruct.listing_track_id=qTrack.listing_track_id;
	}else{
		dataStruct.hasListing=true;
		dataStruct.update=false;
		dataStruct.new=false;
		dataStruct.listing_track_id=qTrack.listing_track_id;
		if(qTrack.listing_track_hash NEQ newHash){
			dataStruct.update=true;
		}
		// if(qTrack.listing_track_external_timestamp NEQ dataStruct.arrData[externalTimestampIndex]){
		// 	dataStruct.update=true;
		// }
	}
	if(dataStruct.haslisting and dataStruct.update EQ false){
		db.sql="update #db.table("listing_track", request.zos.zcoreDatasource)#  
		set listing_track_processed_datetime = #db.param(nowDate1)#, 
		listing_track_updated_datetime=#db.param(request.zos.mysqlnow)#,   
		listing_track_inactive=#db.param(0)# 
		WHERE listing_id = #db.param(listing_id)# and 
		listing_track_deleted = #db.param(0)#";
		db.execute("q"); 	 
	}else{
		if(dataStruct.new){
			dataStruct.listing_track_datetime=this.nowDate;
		}else{
			dataStruct.listing_track_datetime=qTrack.listing_track_datetime;
		}
		dataStruct.listing_track_updated_datetime=this.nowDate;
		rs2=this.optionstruct.mlsProviderCom.parseRawData(dataStruct);
		rs=rs2.listingData;
		// if(dataStruct.new){
		// 	if(structkeyexists(dataStruct, 'listing_track_price') EQ false){
		// 		dataStruct.listing_track_price=this.optionstruct.mlsProviderCom.price;
		// 	}
		// 	if(structkeyexists(dataStruct, 'listing_track_price_change') EQ false){
		// 		dataStruct.listing_track_price_change=this.optionstruct.mlsProviderCom.price;
		// 	}
		// }else{
		// 	if(structkeyexists(dataStruct, 'listing_track_price_change') EQ false){
		// 		dataStruct.listing_track_price_change=this.optionstruct.mlsProviderCom.price;
		// 	}
		// } 
		if(dataStruct.new){
			rs.listing_track_id="null";
			rs.listing_id=listing_id;
			// rs.listing_track_price=dataStruct.listing_track_price;
			// rs.listing_track_price_change=dataStruct.listing_track_price_change;
			rs.listing_track_hash=newHash;
			rs.listing_track_deleted="0";
			rs.listing_track_inactive='0';
			rs.listing_track_datetime=dataStruct.listing_track_datetime;
			rs.listing_track_updated_datetime=dataStruct.listing_track_updated_datetime;
			rs.listing_track_processed_datetime=nowDate1;
		}else{
			rs.listing_track_id=dataStruct.listing_track_id;
			rs.listing_id=listing_id;
			// if(dataStruct.listing_track_price GT 1000 and this.optionstruct.mlsProviderCom.price LT 200){
			// 	rs.listing_track_price=dataStruct.listing_track_price;
			// 	rs.listing_track_price_change=dataStruct.listing_track_price_change;
			// }else{
			// 	rs.listing_track_price=dataStruct.listing_track_price;
			// 	rs.listing_track_price_change=this.optionstruct.mlsProviderCom.price;
			// }
			rs.listing_track_hash=newHash;
			rs.listing_track_deleted="0";
			rs.listing_track_inactive='0';
			rs.listing_track_datetime=dataStruct.listing_track_datetime;
			rs.listing_track_updated_datetime=dataStruct.listing_track_updated_datetime;
			rs.listing_track_processed_datetime=nowDate1;
		}
		rs.mls_id=this.optionStruct.mls_id; 
		ts2={
			debug:true,
			datasource:request.zos.zcoreDatasource,
			table:"listing",
			struct:rs
		};
		ts2.struct.listing_deleted='0';
		ts3={
			debug:true,
			datasource:request.zos.zcoreDatasource,
			table:"listing_data",
			struct:rs
		};
		js={};
		for(i2 in rs2.columnIndex){
			js[i2]=rs2.arrData[rs2.columnIndex[i2]];
		}
		ts3.struct.listing_data_json=serializeJson(js);
		ts3.struct.listing_data_deleted='0';
		ts4={
			debug:true,
			datasource:request.zos.zcoreDatasource,
			table:"listing_track",
			struct:rs
		};
		ts4.struct.listing_track_deleted='0'; 

		transaction action="begin"{
			try{ 

				if(dataStruct.new){ 
					application.zcore.functions.zInsert(ts4); 
				}else{
					ts4.forceWhereFields="listing_id,listing_track_deleted";
					application.zcore.functions.zUpdate(ts4); 
				}

				if(dataStruct.hasListing){
					ts2.forceWhereFields="listing_id,listing_deleted";
					application.zcore.functions.zUpdate(ts2); 

					ts3.forceWhereFields="listing_id,listing_data_deleted";
					application.zcore.functions.zUpdate(ts3);   
				}else{
					application.zcore.functions.zInsert(ts2); 

					application.zcore.functions.zInsert(ts3);  
				}
				transaction action="commit"; 

			}catch(Any e){
				transaction action="rollback";
				rethrow;
			}
		}
	}
	return true;
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>