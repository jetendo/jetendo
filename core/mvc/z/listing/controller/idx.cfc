<cfcomponent>
<cfoutput>
<cfscript>
this.nowDate=request.zos.mysqlnow;
this.dataStruct=structnew();
this.optionstruct=structnew();
this.optionstruct.limitTestServer=true;
this.inited=false;
</cfscript>
<cffunction name="reimport" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>

	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	var db=request.zos.queryObject;
	if(request.zos.istestserver){
		p="#request.zos.sharedPath#mls-data/";	
	}else{
		p="#request.zos.sharedPath#mls-data/";
	}
	form.mls_id=application.zcore.functions.zso(form, 'mls_id', false, 'all');
	if(form.mls_id EQ "all"){
		db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# where 
		mls_status = #db.param(1)# and 
		mls_deleted=#db.param(0)#";
		qMLS=db.execute("qMls");
		arrMLS=[];
		for(row in qMLS){
			arrayAppend(arrMLS, row.mls_id);
		}
	}else{
		arrMLS=[form.mls_id];
		if(application.zcore.functions.zso(form, 'mls_id',true) EQ 0){
			echo('form.mls_id must be a number');
			abort;
		}
	}
	for(i=1;i LTE arraylen(arrMLS);i++){
		a=arrMLS[i];
    	directory action="list" directory="#p&a#" name="qDir";
    	for(row in qDir){
        	if(row.name contains "-imported"){
            	file action="rename" source="#p&a#/#row.name#" destination="#p&a#/#replacenocase(row.name,'-imported','','all')#";
            }
			local.pos=findnocase("-corrupt", row.name);
			if(local.pos){
            	file action="rename" source="#p&a#/#row.name#" destination="#p&a#/#left(row.name,local.pos-1)#";
            }
        }
		echo(a&" files renamed<br />");
        if(not structkeyexists(form, 'disableHashClear')){
        	db.sql='UPDATE #db.table("listing_track", request.zos.zcoreDatasource)# 
			set listing_track_hash = #db.param('')#
			where listing_id like #db.param('#a#-%')# and 
			listing_track_deleted = #db.param(0)#';
			qT=db.execute("qT");
			echo(a&" hashes cleared<br />");
		}
	}
	echo('reimport task complete');
	abort;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="public" returntype="any">
    <cfscript>
	var qmls=0;
	var f=0;
	var nd222=0;
	var qp2=0;
	var firstline=0;
	var arrcolumns=0;
	var qp=0;
	var x=0;
	var db=request.zos.queryObject;
	var qu=0;
	var starttime=0;
	this.inited=true;
	application.zcore.listingCom=application.zcore.listingStruct.configCom;
	
	this.optionstruct.loopRowCount=40;
	if(request.zos.istestserver){
		this.optionstruct.delaybetweenloops=0;
	}else{
		this.optionstruct.delaybetweenloops=10; // 30
	}
	this.optionstruct.timeLimitInSeconds=55; // 75
	// process the mls provider that is the most out of date first
	db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls 
	WHERE mls_status=#db.param('1')# and 
	mls_deleted = #db.param(0)#
	ORDER BY mls_update_date ASC ";
	qMLS=db.execute("qMLS", "", 10000, "query", false);  
	this.optionstruct.filePath=false;

	arrSold=[false, true];
	hasBreaked=false;
	for(i=1;i LTE 2;i++){
		for(row in qMLS){
			this.optionstruct.mls_id=row.mls_id;
			this.optionstruct.delimiter=row.mls_delimiter;
			this.optionstruct.csvquote=row.mls_csvquote;
			this.optionstruct.first_line_columns=row.mls_first_line_columns;
			this.optionstruct.row=row;
			this.optionstruct.mlsProviderCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.mls-provider.#row.mls_com#");
			this.optionstruct.mlsproviderCom.setMLS(this.optionstruct.mls_id);
			if(row.mls_current_file_path NEQ "" and fileexists(request.zos.sharedPath&row.mls_current_file_path)){
				this.optionstruct.filePath=replace(trim(row.mls_current_file_path),"\","/","ALL");
				this.optionstruct.skipBytes=row.mls_skip_bytes;
				hasBreaked=true;
				break;
			}else{
				nextFile=replace(trim(this.optionstruct.mlsProviderCom.getImportFilePath(this.optionstruct, arrSold[i])),"\","/","ALL");
				if(nextFile EQ false){
					continue;
				}else{
					this.optionstruct.filePath=nextFile;
					this.optionstruct.skipBytes=0;
					hasBreaked=true;
					break;
				}
			}
		}
		if(hasBreaked){
			break;
		}
	}
	if(this.optionstruct.filePath EQ false){
		writeoutput('All files are complete.');
		this.cleanInactive(); 
		return true;
	}
	
	request.zos.listing=application.zcore.listingStruct;
	if(this.optionstruct.first_line_columns EQ 1){
		f=fileopen(request.zos.sharedPath&this.optionstruct.filePath,"read", "windows-1252");
		try{
			firstline=lcase(filereadline(f));
		}catch(Any excpt){
			fileclose(f);
			application.zcore.template.fail("firstline=lcase(filereadline(f)); failed | #request.zos.sharedPath&this.optionstruct.filepath#.");
		}
		fileclose(f); 
		arrColumns=listtoarray(replace(firstline," ","","ALL"), this.optionstruct.delimiter, true);
		this.optionstruct.mlsproviderCom.setColumns(arrColumns);
		this.optionstruct.arrColumns=arrColumns; 
		//writedump(arrColumns);
	}else if(structkeyexists(this.optionstruct,"arrColumns")){
		this.optionstruct.mlsProviderCom.setColumns(this.optionstruct.arrColumns); 
	}else{
	//	throw("failed to set columns for mls_id = #this.optionStruct.mls_id#");
	} 

	/*arrColumn2=[];
	for(i in this.optionstruct.arrColumns){
		arrayAppend(arrColumn2, replace(i, "rets#this.optionstruct.mls_id#_", ""));
	}
	writedump(application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idxColumns);
	writedump(this.optionstruct.arrColumns);
	abort;
	this.optionstruct.mlsproviderCom.setColumns(arrColumns);*/
	// seems like column need to be set like this:
	//application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idxColumns=arraytolist(arrColumn2, ",");
	this.optionstruct.mlsproviderCom.initImport("property", application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct);
	if(not structkeyexists(this.optionstruct,"arrColumns") and structkeyexists(application.zcore.listingStruct.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct,"arrColumns")){
		this.optionstruct.arrColumns=request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.arrColumns;
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="process" localmode="modern" access="public" returntype="any"> 
    	<cfscript>
	var r22=0;
	var jfis=0;
	var r1="";
	var db=request.zos.queryObject;
	var csvParser=0;
	var line2=0;
	var fieldComplete=0;
	var oldOffset=0;
	var currentOffset=0;
	var loopCount=0;
	var stillParsing=0;
	var addRowFailCount=0;
	var i2=0;
	var line=0;
	var fileComplete=0;
	var p=0;
	var startTimeTemp=gettickcount();
	var mlsUpdateDate=0;
	var r=0;
	try{
		if(not structkeyexists(request, 'totalRunTime')){
			request.totalRunTime=gettickcount();
		}
		if(this.optionstruct.delimiter EQ ""){
			application.zcore.template.fail("The delimiter for mls_id, "&this.optionstruct.mls_id&", can't be an empty string.");	
		}
		// idea for higher performance initial insert:
			// instead of reading the file from disk, import the csv into a temporary mysql table based on first row size
			// have to use first line for columns - some mls don't have that, they use the hardcoded column list in the mls-provider
			
			// once table exists, it will act as a queue.  the records will be removed as they are processed.
			// select * from recordcount
				// consider allowing threads= (CPU cores / 2)  to process these tables simultaneously
					// figure out how to do that.
		 
		request.zTempIDXFilePath=request.zos.sharedPath&this.optionstruct.filePath;
		
		request.zos.idxFileHandle=fileOpen("#request.zos.sharedPath&this.optionstruct.filePath#", 'read', "windows-1252");
		 

		if(this.optionstruct.skipBytes NEQ 0){
			fileSkipBytes(request.zos.idxFileHandle, this.optionStruct.skipBytes-10); 
		}
		writeoutput(request.zos.sharedPath&this.optionstruct.filePath&'<br />');
		
		
		if(fileIsEOF(request.zos.idxFileHandle)){
			fileComplete=true;
		}else{
			variables.csvParser=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.csvParser");
			variables.csvParser.pathToOstermillerCSVParserJar=application.zcore.cfmlwebinfpath&"lib/ostermillerutils.jar";
			variables.csvParser.enableJava=request.zos.isJavaEnabled;
			variables.csvParser.arrColumn=this.optionstruct.arrColumns;
			variables.csvParser.separator=this.optionStruct.delimiter;
			variables.csvParser.textQualifier=this.optionstruct.csvquote;
			variables.csvParser.init();
			if(this.optionstruct.skipBytes NEQ 0){
				// skip the partially read line
				line2=fileReadLine(request.zos.idxFileHandle);
			}else if(this.optionstruct.first_line_columns EQ 1){
				line2=fileReadLine(request.zos.idxFileHandle); // ignore columns since they were already read
			}else{
				line2="ignore";	
			}
			fileComplete=false; 
			if(fileIsEOF(request.zos.idxFileHandle)){
				fileComplete=true;
			}
			currentOffset=0;
			loopcount=0;
			stillParsing=true;
			addRowFailCount=0;

			application.idxImportTimerStruct={
				parseLine:0,
				addRow:0,
				checkDuplicates:0,
				parseRow1:0,
				loops:0,
				parseRow2:0, 
				"import-update-track-only":0,
				"import-listing":0,
				"import-listing_data":0,
				"import-listing_track":0,
				"import-listing_memory":0,
				"import-update-listing":0,
				"import-update-listing_data":0,
				"import-update-listing_track":0,
				"import-update-listing_memory":0
			};
			structdelete(application.zcore, 'abortIdxImport');
		}
		if(not fileComplete){
			while(gettickcount()-startTimeTemp LTE this.optionstruct.timeLimitInSeconds*1000){// and stillParsing){
				processedRow=false;
				stopProcessing=false;
				for(i2=1;i2 LTE this.optionstruct.loopRowCount;i2++){
					application.idxImportTimerStruct.loops++;
					startTime=gettickcount('nano');

					if(structkeyexists(application.zcore, 'abortIdxImport')){
						throw("Aborting IDX Import due to manual cancellation");
					}
					application.zcore.idxImportStatus="Bytes read: "&this.optionStruct.skipBytes&" of "&request.zos.sharedPath&this.optionstruct.filepath;
					loopcount++;
					if(fileIsEOF(request.zos.idxFileHandle) or (this.optionstruct.limitTestServer and request.zos.istestserver and loopcount GT 500)){
						fileComplete=true; 
						break;	
					}
					line=fileReadLine(request.zos.idxFileHandle);
					this.optionstruct.skipBytes+=len(line)+1;
					line=variables.csvParser.parseLineIntoArray(line);  

					processedRow=true;

					tempTime=gettickcount('nano');
					application.idxImportTimerStruct.parseLine+=(tempTime-startTime);
					startTime=tempTime;

					request.curline=line;
					r1=this.addRow(line);

					tempTime=gettickcount('nano');
					application.idxImportTimerStruct.addRow+=(tempTime-startTime);
					startTime=tempTime;
	 
					if(r1 EQ false){
						addRowFailCount++;
						if(addRowFailCount GTE 10){
							fileClose(request.zos.idxFileHandle);
							throw(request.addRowErrorMessage);
							abort;
							application.zcore.functions.zRenameFile(request.zos.sharedPath&this.optionstruct.filepath, request.zos.sharedPath&this.optionstruct.filepath&"-corrupt-"&dateformat(now(),'yyyy-mm-dd')&'-'&timeformat(now(),'HH-mm-ss'));	
							if(fileexists(request.zos.sharedPath&this.optionstruct.filepath&"-imported")){
								application.zcore.functions.zCopyFile(request.zos.sharedPath&this.optionstruct.filepath&"-imported", request.zos.sharedPath&this.optionstruct.filepath);	
							}
							throw(request.addRowErrorMessage);
						}
					}
					if(gettickcount()-request.totalRunTime GT 170000){
						echo('Aborted due to nearing time limit');
						stopProcessing=true;
						//fileClose(request.zos.idxFileHandle);
						//structdelete(application.zcore, 'mlsImportIsRunning');
						break;
					}
					if(this.optionstruct.delaybetweenloops NEQ 0){
						sleep(this.optionstruct.delaybetweenloops);
					}
				}
				startTime=gettickcount('nano');
				this.checkDuplicates();

				tempTime=gettickcount('nano');
				application.idxImportTimerStruct.checkDuplicates+=(tempTime-startTime);
				startTime=tempTime;

				r22=this.import();
	 

				if(r22 EQ false){
					break;	
				}
				if(fileComplete){
					break;
				}
				if(not processedRow or stopProcessing){
					break;
				}
			}
		}
		
		fileClose(request.zos.idxFileHandle);
		mlsUpdateDate="";
		if(fileComplete){
			writeoutput('File import, "#request.zos.sharedPath&this.optionstruct.filepath#",  is complete<br />');
			application.zcore.functions.zDeleteFile(request.zos.sharedPath&this.optionstruct.filepath&"-imported");	
			r=application.zcore.functions.zRenameFile(request.zos.sharedPath&this.optionstruct.filepath, request.zos.sharedPath&this.optionstruct.filepath&"-imported");			
			this.optionstruct.skipBytes=0;
			this.optionstruct.filePath=""; 
		}
	}catch(Any local.e){
		if(structkeyexists(variables, 'fileHandle')){
			fileClose(request.zos.idxFileHandle);
		}
		rethrow;
	}
	writeoutput('last usable offset:'&this.optionstruct.skipBytes&"<br />");
	
	db.sql="UPDATE #db.table("mls", request.zos.zcoreDatasource)# mls 
	SET mls_current_file_path=#db.param(this.optionstruct.filePath)#, 
	mls_error_sent=#db.param('0')#, 
	mls_updated_datetime=#db.param(request.zos.mysqlnow)# ,
	mls_skip_bytes=#db.param(this.optionstruct.skipBytes)# ";
	if(this.optionstruct.filePath EQ ""){
		db.sql&=" , mls_update_date = #db.param(request.zos.mysqlnow)# ";
	}
	db.sql&=" where mls_id = #db.param(this.optionstruct.mls_id)# and 
	mls_deleted=#db.param(0)#";
	db.execute("q"); 
	
	if(gettickcount()-startTimeTemp LT this.optionstruct.timeLimitInSeconds*1000){
		writeoutput('Completed in #(gettickcount()-startTimeTemp)/1000# seconds');
	}else{
		writeoutput('Stopped after #this.optionstruct.timeLimitInSeconds# seconds');
	}


	if(structkeyexists(request, 'newListingCitiesCreated')){
		cc=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
		cc.updateDistanceCache();
	}

	if(gettickcount()-request.totalRunTime GT 170000){
		echo('Aborted due to nearing time limit');
		structdelete(application.zcore, 'mlsImportIsRunning');
		abort;
	}
	</cfscript>
</cffunction>

<cffunction name="addRow" localmode="modern" access="public" returntype="any">
	<cfargument name="arrRow" type="array" required="yes">
    <cfscript>
	var ts=structnew();
	if(this.inited EQ false){
		request.addRowErrorMessage="zcorerootmapping.com.apps.idx requires init() to be called before addRow(). Reverted to previous day's file to avoid data loss.";
		return false;
	}
	ts.hash=hash(arraytolist(arguments.arrRow,chr(10)));
	ts.arrData=arguments.arrRow;
	ts.new=true;
	ts.hasListing=false; 
	ts.update=true;
	ts.listing_mls_id=this.optionstruct.mls_id;
	try{
		if(arraylen(ts.arrData) LT request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset){
			request.addRowErrorMessage="This row was not long enough to contain the listing_id column: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.arrRow,chr(10)))&". Reverted to previous day's file to avoid data loss. ";
			return false;
		} 
		ts.listing_id=this.optionstruct.mls_id&'-'&ts.arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset];
		
		if(right(ts.listing_id,1) EQ "-"){
			request.addRowErrorMessage="Invalid listing id. The field was empty.  Review the corrupt file starting with the current file path: "&this.optionstruct.filePath&". Reverted to previous day's file to avoid data loss.";
			return false;	
		}
		ts.arrData[request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset]=ts.listing_id;
	}catch(Any excpt){ 
		savecontent variable="out"{
			if(request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset EQ 0){
				echo("Couldn't find id column, you must fix the column name at top of mls-provider file and reset app scope.");
			}
			writedump(excpt);
		}
		request.addRowErrorMessage="MLS Import Add Row failed for mls_id, "&this.optionstruct.mls_id&". Length: #arraylen(ts.arrData)# | ID Offset: #request.zos.listing.mlsStruct[this.optionstruct.mls_id].sharedStruct.lookupStruct.idColumnOffset# | The column header row might be missing. Current file path: "&this.optionstruct.filePath&". Reverted to previous day's file to avoid data loss."&out;
			return false;
			
	}
	this.dataStruct[ts.listing_id]=ts; 
	return true;
	</cfscript>
</cffunction>

<cffunction name="checkDuplicates" localmode="modern" access="public" returntype="any">
	<cfscript>
	var sqllist=0;
	var db=request.zos.queryObject;
	var qt=0;
	if(structcount(this.datastruct) EQ 0) return;
	sqllist="'"&structkeylist(this.datastruct,"','")&"'";
	db.sql="select *
	from #db.table("listing_track", request.zos.zcoreDatasource)# listing_track 
	where listing_id IN (#db.trustedSQL(sqllist)#) and 
	listing_track_deleted = #db.param(0)#";
	qT=db.execute("qT"); 

	db.sql="select listing.listing_id 
	from #db.table("listing", request.zos.zcoreDatasource)# listing
	where listing_id IN (#db.trustedSQL(sqllist)#) and 
	listing_deleted = #db.param(0)#";
	qT2=db.execute("qT2");  
	</cfscript>
    <cfloop query="qT">
    	<cfscript>
		this.datastruct[qT.listing_id].listing_track_id=qT.listing_track_id;
		this.datastruct[qT.listing_id].listing_track_price=qT.listing_track_price;
		this.datastruct[qT.listing_id].listing_track_datetime=dateformat(qT.listing_track_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_datetime,"HH:mm:ss");
		this.datastruct[qT.listing_id].listing_track_updated_datetime=dateformat(qT.listing_track_updated_datetime,"yyyy-mm-dd")&" "&timeformat(qT.listing_track_updated_datetime,"HH:mm:ss");
		this.datastruct[qT.listing_id].new=false;
		this.datastruct[qT.listing_id].hasListing=false;
		if(this.datastruct[qT.listing_id].hash EQ qT.listing_track_hash){
			this.datastruct[qT.listing_id].update=false;
		}
		</cfscript>
    </cfloop> 
    <cfloop query="qT2">
    	<cfscript>
		this.datastruct[qT2.listing_id].hasListing=true;
		</cfscript>
    </cfloop> 
	
</cffunction>

    
<cffunction name="import" localmode="modern" access="public" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	if(not structkeyexists(request, 'debugtime')){
		request.debugtime=0;
		request.debugstime=gettickcount();
	}
	nowDate1=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"); 

	dataChanged=false;
	for(i in this.datastruct){
		arrayClear(request.zos.arrQueryLog);
		startTime=gettickcount('nano');
		if(this.datastruct[i].update EQ false and this.datastruct[i].haslisting){


			db.sql="update #db.table("listing_track", request.zos.zcoreDatasource)#  
			set listing_track_processed_datetime = #db.param(nowDate1)#, 
			listing_track_updated_datetime=#db.param(request.zos.mysqlnow)#,   
			listing_track_inactive=#db.param(0)# 
			WHERE listing_id = #db.param(i)# and 
			listing_track_deleted = #db.param(0)#";
			db.execute("q"); 	

			tempTime=gettickcount('nano');
			application.idxImportTimerStruct["import-update-track-only"]+=(tempTime-startTime);
			startTime=tempTime;
		}else{
			dataChanged=true;
			if(this.datastruct[i].new){
				this.datastruct[i].listing_track_datetime=this.nowDate;
			}
			this.datastruct[i].listing_track_updated_datetime=this.nowDate;
			rs2=this.optionstruct.mlsProviderCom.parseRawData(this.datastruct[i]);//, this.optionstruct);
			rs=rs2.listingData;


			
			if(this.datastruct[i].new){
				if(structkeyexists(this.datastruct[i], 'listing_track_price') EQ false){
					this.datastruct[i].listing_track_price=this.optionstruct.mlsProviderCom.price;
				}
				if(structkeyexists(this.datastruct[i], 'listing_track_price_change') EQ false){
					this.datastruct[i].listing_track_price_change=this.optionstruct.mlsProviderCom.price;
				}
			}else{
				if(structkeyexists(this.datastruct[i], 'listing_track_price_change') EQ false){
					this.datastruct[i].listing_track_price_change=this.optionstruct.mlsProviderCom.price;
				}
			} 
			if(this.datastruct[i].new){
				rs.listing_track_id="null";
				rs.listing_id=i;
				rs.listing_track_price=this.datastruct[i].listing_track_price;
				rs.listing_track_price_change=this.datastruct[i].listing_track_price_change;
				rs.listing_track_hash=this.datastruct[i].hash;
				rs.listing_track_deleted="0";
				rs.listing_track_inactive='0';
				rs.listing_track_datetime=this.datastruct[i].listing_track_datetime
				rs.listing_track_updated_datetime=this.datastruct[i].listing_track_updated_datetime;
				rs.listing_track_processed_datetime=nowDate1;
			}else{
				rs.listing_track_id=this.datastruct[i].listing_track_id;
				rs.listing_id=i;
				if(this.datastruct[i].listing_track_price GT 1000 and this.optionstruct.mlsProviderCom.price LT 200){
					rs.listing_track_price=this.datastruct[i].listing_track_price;
					rs.listing_track_price_change=this.datastruct[i].listing_track_price_change;
				}else{
					rs.listing_track_price=this.datastruct[i].listing_track_price;
					rs.listing_track_price_change=this.optionstruct.mlsProviderCom.price;
				}
				rs.listing_track_hash=this.datastruct[i].hash;
				rs.listing_track_deleted="0";
				rs.listing_track_inactive='0';
				rs.listing_track_datetime=this.datastruct[i].listing_track_datetime;
				rs.listing_track_updated_datetime=this.datastruct[i].listing_track_updated_datetime;
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

					if(this.datastruct[i].new){ 
						application.zcore.functions.zInsert(ts4);

						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-"&ts4.table]+=(tempTime-startTime);
						startTime=tempTime;
					}else{
						ts4.forceWhereFields="listing_id,listing_track_deleted";
						application.zcore.functions.zUpdate(ts4);

						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-update-"&ts4.table]+=(tempTime-startTime);
						startTime=tempTime;
					}

					if(this.datastruct[i].hasListing){
						ts2.forceWhereFields="listing_id,listing_deleted";
						application.zcore.functions.zUpdate(ts2);

						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-update-"&ts2.table]+=(tempTime-startTime);
						startTime=tempTime;

						ts3.forceWhereFields="listing_id,listing_data_deleted";
						application.zcore.functions.zUpdate(ts3);  


						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-update-"&ts3.table]+=(tempTime-startTime);
						startTime=tempTime;
					}else{
						application.zcore.functions.zInsert(ts2); 

						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-"&ts2.table]+=(tempTime-startTime);
						startTime=tempTime;

						application.zcore.functions.zInsert(ts3); 

						tempTime=gettickcount('nano');
						application.idxImportTimerStruct["import-"&ts3.table]+=(tempTime-startTime);
						startTime=tempTime;
					}
					transaction action="commit"; 

				}catch(Any e){
					transaction action="rollback";
					rethrow;
				}
			}
		}
    } 
    if(dataChanged){

		yesterday=dateformat(dateadd("d", -1, now()), "yyyy-mm-dd");
		db.sql="update #db.table("mls", request.zos.zcoreDatasource)# 
		set mls_cleaned_date=#db.param(yesterday)#, 
		mls_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		mls_id=#db.param(this.optionstruct.mls_id)# and 
		mls_deleted = #db.param(0)#";
		db.execute("qUpdateMLS");  
    }
	
	arrayClear(request.zos.arrQueryLog);
	this.datastruct=structnew();
	return true;
	</cfscript>
</cffunction>
    
<cffunction name="cleanInactive" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript> 
	var db=request.zos.queryObject; 
	var newTickTime=getTickCount(); 
	var arrTick=[];
	var nowTime=gettickcount();
	var oneMonthAgo=dateadd("m",-2,now());
	var oneDayAgo=dateadd("h",-24,now());
	var todayDate=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	var arrMLSOnly=[];
	var arrMLSIdOnly=[]; 
	var db2=request.zos.noVerifyQueryObject;
	oneDayAgo=dateformat(oneDayAgo,'yyyy-mm-dd')&' '&timeformat(oneDayAgo,'HH:mm:ss');
	
	setting requesttimeout="1000"; 
	application.zcore.idxImportStatus="cleanInactive executed";

	/*
	// this code deleted real listings for some reason
	db.sql="SELECT group_concat(listing.listing_id SEPARATOR #db.param("','")#) idlist 
	FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	LEFT JOIN #db.table("listing_track", request.zos.zcoreDatasource)# listing_track ON 
	listing_track.listing_id= listing.listing_id   and 
	listing_track_deleted = #db.param(0)# 
	WHERE listing_track.listing_id IS NULL and 
	listing_deleted = #db.param(0)#";
	qDeadListings=db.execute("qDeadListings"); 
	if(qDeadListings.recordcount NEQ 0 and qDeadListings.idlist NEQ ""){
		writeoutput('dead listings:'&qDeadListings.idlist&'<br />');
		db.sql="DELETE FROM #db.table("listing", request.zos.zcoreDatasource)#  
		WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		listing_deleted = #db.param(0)# ";	
		db.execute("q"); 
		db.sql="DELETE FROM #db.table("listing_data", request.zos.zcoreDatasource)#  
		WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		listing_data_deleted = #db.param(0)# ";	
		db.execute("q"); 
		 db.sql="DELETE FROM #db.table("listing_memory", request.zos.zcoreDatasource)#  
		 WHERE listing_id IN (#db.trustedSQL("'#qDeadListings.idlist#'")#) and 
		 listing_deleted = #db.param(0)# ";	
		 db.execute("q");
	}else{
		writeoutput('no dead listings<br />');	
	} 
	*/

	db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# mls 
	where mls_status=#db.param('1')# and 
	mls_update_date >#db.param(todayDate)# and 
	mls_cleaned_date< #db.param(dateformat(todayDate,'yyyy-mm-dd'))# and 
	mls_deleted = #db.param(0)#";
	qMLS2=db.execute("qMLS2");  
	local.arrMLSClean=[];

	rebuildTable=false;
	</cfscript>
    <cfloop from="1" to="#qmls2.recordcount#" index="n">
    	<cfscript>
    	mlsID=qMLS2.mls_id[n];
		arrayAppend(local.arrMLSClean, " listing_id like '"&qMls2.mls_id[n]&"-%' ");
		arrFileList=listtoarray(qmls2.mls_filelist[n],",");
		foundCount=0;
		arrFound=arraynew(1);
		arrFound2=arraynew(1);
		mlsProviderCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.mls-provider.#qmls2.mls_com[n]#");
		mlsproviderCom.setMLS(mlsID);  
		</cfscript>
        <cfdirectory action="list" directory="#request.zos.sharedPath#mls-data/#qmls2.mls_id[n]#/" filter="*-imported" name="qd"> 
		<cfloop query="qd">
			<cfscript>
			found1=false;
			for(n2=1;n2 LTE arraylen(arrFileList);n2++){
				if(arrFileList[n2]&"-imported" EQ qd.name){	 
					if(dateformat(qd.datelastmodified,"yyyy-mm-dd") EQ dateformat(now(),"yyyy-mm-dd")){
						foundCount++;
						found1=true;
						arrayappend(arrFound, qd.name);
						break;	
					}else{
						echo(qmls2.mls_id[n]&"/"&qd.name&" wrong date<br>");
					}
				}
			}
			if(found1 EQ false){
				arrayappend(arrFound2, qd.name);
			}
			</cfscript>
		</cfloop>
		<cfif foundCount EQ arraylen(arrFilelist)>
			<cfscript> 
			db2.sql="INSERT INTO listing_delete (listing_id, listing_delete_updated_datetime) 
			SELECT listing_id, #db2.param(request.zos.mysqlnow)# 
			FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_deleted=#db2.param('0')# and 
	   		listing_track.listing_track_inactive=#db2.param('0')# and 
			listing_track_processed_datetime < #db2.param(oneDayAgo)#  and 
			listing_id LIKE #db2.param('#mlsID#-%')# 
			ORDER BY listing_track_id ASC";
			db2.execute("qInsert"); 
			db.sql="SELECT count(listing_delete_id) count 
			FROM #db.table("listing_delete", request.zos.zcoreDatasource)# 
			where listing_delete_deleted=#db.param('0')# and 
			listing_id LIKE #db.param('#mlsID#-%')# ";
			qCount=db.execute("qCount");
			echo("MLS ID: #mlsID# | #qCount.count# records will be deleted.<br />");
			deleteCount=0;
			while(true){
				db.sql="select listing_id FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_deleted = #db.param(0)#  and 
				listing_id LIKE #db.param('#mlsID#-%')# 
				LIMIT #db.param(0)#, #db.param(5)# ";
				qIdList=db.execute("qIdList");

				if(qIdList.recordcount EQ 0){
					break;
				}
				arrId=[];
				for(row in qIdList){
					echo("Delete listing_id:"&row.listing_id&"<br>")
					arrayAppend(arrId, "'"&row.listing_id&"'");
				}
				idlist=arraytolist(arrId, ",");
				deleteCount+=qIdList.recordcount; 

				db2.sql="DELETE FROM #db2.table("listing", request.zos.zcoreDatasource)#  
				WHERE listing_id IN (#idlist#) and listing_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
				db2.sql="DELETE FROM #db2.table("listing_data", request.zos.zcoreDatasource)#  
				WHERE listing_id IN (#idlist#) and listing_data_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
				//db2.sql="DELETE FROM #db2.table("listing_memory", request.zos.zcoreDatasource)# WHERE listing_id IN (#idlist#) and listing_deleted = #db2.param(0)# ";
				//db2.execute("qDelete");
				db2.sql="UPDATE #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
				SET listing_track_hash=#db2.param('')#, 
				listing_track_inactive=#db2.param(1)#, 
				listing_track_updated_datetime=#db2.param(request.zos.mysqlnow)#  
				WHERE listing_id IN (#idlist#) and 
				listing_track_deleted = #db2.param(0)#";
				db2.execute("qDelete");
				db2.sql="DELETE FROM 
				#db2.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_id IN (#idlist#) and 
				listing_delete_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
			}

			oneMonthAgo=dateformat(oneMonthAgo,'yyyy-mm-dd')&' '&timeformat(oneMonthAgo,'HH:mm:ss'); 
			db2.sql="INSERT INTO #db2.table("listing_delete", request.zos.zcoreDatasource)# (listing_id, listing_delete_updated_datetime) 
			SELECT listing_id, #db2.param(request.zos.mysqlnow)# FROM #db2.table("listing_track", request.zos.zcoreDatasource)# 
			where listing_track_processed_datetime < #db2.param(oneMonthAgo)#  and 
			listing_track_deleted = #db2.param(0)#  and 
	   		listing_track_inactive = #db2.param(1)# and 
			listing_id LIKE #db2.param('#mlsID#-%')# 
			ORDER BY listing_track_id ASC";
			db2.execute("qInsert");
			db.sql="SELECT count(listing_delete_id) count 
			FROM #db.table("listing_delete", request.zos.zcoreDatasource)# 
			where listing_delete_deleted=#db.param('0')# and 
			listing_id LIKE #db.param('#mlsID#-%')# ";
			qCount=db.execute("qCount");
			echo("MLS ID: #mlsID# | #qCount.count# records will be deleted from listing_track because they are more then went inactive more then one month ago.<br />");
			offset=1;
			deleteCount2=0;
			while(true){
				db.sql="select listing_id FROM 
				#db.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_delete_deleted = #db.param(0)# and 
				listing_id LIKE #db.param('#mlsID#-%')# 
				LIMIT #db.param(0)#, #db.param(5)#";
				qIdList=db.execute("qIdList");
				if(qIdList.recordcount EQ 0){
					break;
				}
				arrId=[];
				for(row in qIdList){
					arrayAppend(arrId, "'"&row.listing_id&"'");
				}
				idlist=arraytolist(arrId, ",");
				deleteCount2+=qIdList.recordcount;
				db2.sql="DELETE FROM #db2.table("listing_track", request.zos.zcoreDatasource)#  
				WHERE listing_id IN (#idlist#) and 
				listing_track_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
				db2.sql="DELETE FROM 
				#db2.table("listing_delete", request.zos.zcoreDatasource)# WHERE 
				listing_id IN (#idlist#) and 
				listing_delete_deleted = #db2.param(0)# ";
				db2.execute("qDelete");
			}
			rebuildTable=true;

			db.sql="update #db.table("mls", request.zos.zcoreDatasource)# mls 
			set mls_cleaned_date=#db.param(dateformat(now(),'yyyy-mm-dd'))#, 
			mls_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE mls_id =#db.param(mlsID)# and 
			mls_deleted = #db.param(0)# ";
			db.execute("q"); 
			writeoutput('<br />MLS ID: #mlsID# | #deleteCount# listings made inactive | #deleteCount2# permanently removed.<br />');
			</cfscript>
		<cfelse>
			<cfscript>
			writeoutput(qMLS2.mls_id[n]&" was updated but not completed #foundCount# of #arraylen(arrFileList)#. Imported file list: <br /><br />"&arraytolist(arrFound)&"<br />Required File list: <br />"&arraytolist(arrFileList)&"<br /><br />Required Files that were missing: <br />"&arraytolist(arrFound2)&"<br /><br />arrFileList:"&arraytolist(arrFileList)&"<hr />");
			</cfscript>
		</cfif>
	</cfloop> 
	<cfscript>
	if(rebuildTable){
		ts={};
		ts.table="listing";
		ts.force=true;
		ts.allowFulltext=true;
		application.zcore.listingCom.zCreateMemoryTable(ts);
	}
 
	db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# mls 
	where mls_status=#db.param('1')# and 
	(mls_update_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))# or 
	mls_cleaned_date <#db.param(dateformat(oneDayAgo,"yyyy-mm-dd"))#) and 
	mls_error_sent=#db.param('0')# and 
	mls_deleted = #db.param(0)#";
	qTwoDaysAgo=db.execute("qTwoDaysAgo"); 
	</cfscript>
    <cfif qTwoDaysAgo.recordcount NEQ 0>
        <cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="MLS database(s) failed to update." type="html">
		#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>MLS Error</title>
		</head>

		<body>
		<span style="font-family:Verdana, Geneva, sans-serif; font-size:12px;">
		<h2>The following mls providers have not been updated for more than 48 hours.</h2>
		<table style="border-spacing:0px;">
		<tr><td>ID</td><td>Name</td><td>Last Updated</td></tr>
		<cfloop query="qTwoDaysAgo">
			<tr><td>#qTwoDaysAgo.mls_id#</td><td>#qTwoDaysAgo.mls_name#</td><td>#dateformat(qTwoDaysAgo.mls_update_date,"m/d/yyyy")#</td></tr>
			<cfscript>
			 db.sql="update #db.table("mls", request.zos.zcoreDatasource)# mls 
			 SET mls_error_sent=#db.param('1')#, 
			 mls_updated_datetime=#db.param(request.zos.mysqlnow)#  
			 where mls_id = #db.param(qTwoDaysAgo.mls_id)# and 
			 mls_deleted=#db.param(0)#";
			 db.execute("q");
			</cfscript>
		</cfloop>
		</table>
		</span>
		</body>
		</html>
		</cfmail>
	</cfif>
</cffunction>

</cfoutput>
</cfcomponent>