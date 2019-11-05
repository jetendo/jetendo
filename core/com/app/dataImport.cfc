<cfcomponent displayname="Data Import">
<cfoutput>	
<cfscript>
this.comName = 'zcorerootmapping.com.app.dataImport.cfc';
this.cursor=1;
this.arrColumns = ArrayNew(1);
this.arrLines = ArrayNew(1);
this.arrMappedColumns=ArrayNew(1);

this.config=StructNew();
this.config.escapedBy='"';
this.config.textQualifier='"';
this.config.seperator=",";
this.config.lineDelimiter =chr(10);
this.config.bufferedReadEnabled=false;
this.config.ignoreDuplicateSeparator=false; 
this.currentLine="";
</cfscript>
<!--- 
<!--- Data Import Component USAGE:	 --->
<cfscript>

dataImportCom = CreateObject("component", "zcorerootmapping.com.app.dataImport");
csvData = "string with csv data";
dataImportCom.parseCSV(csvData);
// use this when columns are in csv
dataImportCom.getFirstRowAsColumns();
// otherwise:
arrColumns = ListToArray("col1,col2,col3,col4");
dataImportCom.setColumns(arrColumns);
// map csv column to database field name
ts=StructNew();
ts["col1"] = "test_id";
ts["col2"] = "mls_daytona_state";
ts["col3"] = "mls_daytona_number";
ts["col4"] = "mls_daytona_tln_firm_id";
dataImportCom.mapColumns(ts);
</cfscript>
<!--- loop rows of data --->
<cfloop from="1" to="#dataImportCom.getCount()#" index="g">
	<cfscript>
	ts=dataImportCom.getRow();	
	</cfscript>
	<Cfdump var="#ts#">
</cfloop>
 --->

<!--- 
ts=StructNew();
ts.escapedBy='"';
ts.textQualifier='"';
ts.seperator=",";
ts.lineDelimiter=chr(10);
ts.ignoreDuplicateSeparator=false; // if you set this to true, it will allow duplicate separators to be used when there is no escaping of the delimiter, such as in a tab format
ts.bufferedReadEnabled=true; // warning - if the file has rows with line breaks between text qualifiers, then you must set bufferedReadEnabled to false.
dataImportCom.init(ts);
 --->
<cffunction name="init" localmode="modern" output="true" returntype="any">		
	<cfargument name="inputStruct" type="struct" required="no" default="#StructNew()#">
	<cfscript>
	StructAppend(this.config,arguments.inputStruct,true);
	</cfscript>
	<cfif this.config.bufferedReadEnabled and isDefined('this.config.filename') and isDefined('this.config.lineDelimiter') and this.config.lineDelimiter EQ chr(10)>
		<cfscript>
		this.fileHandle=fileopen(this.config.filename, "read", "utf-8");
		</cfscript>	
	</cfif>
</cffunction>

<cffunction name="mapColumns" localmode="modern" output="true" returntype="any">
	<cfargument name="mapStruct" type="struct" required="yes">
	<cfscript>
	var i=1;
	var tempColumn=0;
	var arrTemp=ArrayNew(1); 
	for(i=1;i LTE ArrayLen(this.arrColumns);i=i+1){
		try{
			tempColumn = arguments.mapStruct[this.arrColumns[i]];
		}catch(Any excpt){
			tempColumn = false;
		}
		ArrayAppend(arrTemp, tempColumn);
	}
	this.arrMappedColumns = arrTemp;
	</cfscript>
</cffunction>

<cffunction name="resetCursor" localmode="modern" output="false" returntype="any">
	<cfscript>
	this.cursor=1;
	this.init(this.config);
	</cfscript>
</cffunction>

<cffunction name="getCount" localmode="modern" output="false" returntype="any">
	<cfscript>
	if(this.config.bufferedReadEnabled){
		application.zcore.template.fail("#this.comName#: getCount can't be used with buffered reader",true);
	}
	return ArrayLen(this.arrLines);
	</cfscript>
</cffunction>

<cffunction name="getRow" localmode="modern" hint="returns false at end of recordset" output="true" returntype="any">
	<cfscript>
	var i=1;
	var ts=StructNew();
	var arrData = this.parseCSVRow(); 
	if(isArray(arrData) EQ false){
		return false;
	}
	if(structkeyexists(this.config, 'allowUnequalColumnCount') EQ false and (ArrayLen(arrData) NEQ ArrayLen(this.arrMappedColumns))){
		return false;
	}
	for(i=1;i LTE ArrayLen(this.arrMappedColumns);i=i+1){
		if(this.arrMappedColumns[i] NEQ false){
			try{
				StructInsert(ts, this.arrMappedColumns[i], arrData[i],true);
			}catch(Any excpt){
				StructInsert(ts, this.arrMappedColumns[i], '{no data}',true);
			}
		}
	} 
	this.cursor=this.cursor+1;
	return ts;
	</cfscript>
</cffunction>

<cffunction name="setColumns" localmode="modern" output="false" returntype="any">
	<cfargument name="arrColumns" type="array" required="yes">
	<cfscript>
	this.arrColumns=arguments.arrColumns;
	</cfscript>
</cffunction>


<cffunction name="getColumns" localmode="modern" output="false" returntype="any">
	<cfscript>
	return this.arrColumns;
	</cfscript>
</cffunction>

<cffunction name="getFirstRowAsColumns" localmode="modern" output="true" returntype="any">
	<cfscript>
	var arrData = parseCSVRow();
	if(ArrayLen(arrData) EQ 0){
		this.arrColumns = ArrayNew(1);
	}else{
		this.arrColumns=arrData;
		if(this.config.bufferedReadEnabled EQ false){
			ArrayDeleteAt(this.arrLines,1);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="skipLine" localmode="modern" output="false" returntype="any">	
	<cfscript>
	if(this.config.bufferedReadEnabled){
		filereadline(this.fileHandle);
	}
	this.cursor++;
	// return this.reader.readLine();
	</cfscript>
</cffunction>

<cffunction name="parseLine" localmode="modern" output="false" returntype="any">	
	<cfscript>
	this.currentLine=this.reader.readLine();
	if(isDefined('this.currentLine') EQ false or len(this.currentLine) EQ 0){
		false;
	}else{
		return parseCSVRow();
	}
	</cfscript>
</cffunction>


<!--- need to grab one row at a time now... --->
<cffunction name="parseCSV" localmode="modern" output="true" returntype="any">
	<cfargument name="data" type="string" required="yes">
	<cfscript>
	//this.arrLines = ListToArray(arguments.data, this.config.lineDelimiter);
	chars=len(arguments.data);  
	arrList = ArrayNew(1);
	currentGroupId=0;  
	inQuote=false;
	arrFields=ArrayNew(1);
	this.arrLines=[];
	fStart=1; 
	lastFieldEndPosition=0;
	if(this.config.lineDelimiter EQ chr(10)){
		returnChar=chr(13);
	}
	if(this.config.lineDelimiter EQ chr(13)){
		returnChar=chr(10);
	}
	line=arguments.data;
	for(i=1;i LTE chars;i++){
		letter=line[i];
		if(inQuote){
			if(letter EQ this.config.textQualifier and (fStart EQ i or (mid(line,i-1,1) NEQ this.config.escapedBy))){
				//if(mid(line,i+1,1) EQ this.config.seperator){// or i+1 GTE len(line)){
					inQuote=false;
					field = mid(line,fStart,(i-fStart));
					// unescape double quotes
					if(this.config.escapedBy NEQ ''){
						field = replace(field,this.config.escapedBy&this.config.textQualifier,this.config.textQualifier,"ALL");
					}
					ArrayAppend(arrFields,field);
					lastFieldEndPosition=i;
					fStart=i+1;
				//}
			}
		}else{
			if(letter EQ this.config.lineDelimiter){ 
				storeField=true;
				if(i GT 1 and line[i-1] EQ this.config.seperator){
					storeField=false;
				}else if(i GT 1 and line[i-2] EQ this.config.textQualifier){
					storeField=false;
				}else if(i GT 2 and line[i-2] EQ this.config.seperator and line[i-1] EQ returnChar){
					storeField=false;
				}else if(i GT 2 and line[i-2] EQ this.config.textQualifier and line[i-1] EQ returnChar){
					storeField=false;
				}
				if(storeField){
					field = trim(mid(line,fStart,(i-fStart))); 
					ArrayAppend(arrFields, field); 
				}
				arrayAppend(this.arrLines, arrFields);
				arrFields=[];
				fStart=i+1;
			}else if(letter EQ this.config.textQualifier and fStart EQ i){
				inQuote=true;
				fStart=i+1;
			}else if(letter EQ this.config.seperator){
				// if first time, or the separator is repeated
				if(this.config.ignoreDuplicateSeparator EQ false){
					if(i EQ 1 or mid(line,i-1,1) EQ this.config.seperator){
						ArrayAppend(arrFields,'');
						lastFieldEndPosition=i;
					}else if(fStart NEQ i){
						field = mid(line,fStart,(i-fStart));
						ArrayAppend(arrFields, trim(field));
						lastFieldEndPosition=i;
					}
					if(i+1 EQ len(line)){
						ArrayAppend(arrFields,'');
						lastFieldEndPosition=i;
					}
				}else{
					if(fStart NEQ i){
						field = mid(line,fStart,(i-fStart));
						ArrayAppend(arrFields, trim(field));
						lastFieldEndPosition=i;
					}else{
						ArrayAppend(arrFields, "");
					}
				}
				fStart=i+1;
			}else if(i EQ len(line) and fStart NEQ i){
				field = mid(line,fStart,(i-fStart)+1);
				ArrayAppend(arrFields, trim(field));
				lastFieldEndPosition=i;
			}
		}
	}
	if(right(trim(line),1) EQ this.config.seperator){
		ArrayAppend(arrFields,'');
	} 
	if(arrayLen(arrFields)){
		arrayAppend(this.arrLines, arrFields);
	} 
	</cfscript>
</cffunction>

<cffunction name="close" localmode="modern" returntype="any" output="true">
	<cfscript>
	if(structkeyexists(this, 'fileHandle')){
		fileclose(this.fileHandle);
		structdelete(this, 'fileHandle');
	}
	</cfscript>
</cffunction>

<cffunction name="parseCSVRow" localmode="modern" returntype="any" output="true">
	<cfscript>
	// define tracking variables
	var inQuote=false;
	var i=0;
	var letter=0;
	var arrFields=0;
	var line=0;
	var field=0;
	var fStart=1;
	var arrList = ArrayNew(1);
	var currentGroupId=0;
	var f=this.cursor;
	if(this.config.bufferedReadEnabled){
		if(fileiseof(this.fileHandle)){
			fileclose(this.fileHandle);
			return false;
		}
		line=filereadline(this.fileHandle); 
		// TODO: enable buffered csv parse not based on filereadline
	}else{
		return this.arrLines[f];
		// line = this.arrLines[f];
	} 
	this.currentLine=line;
	inQuote=false;
	arrFields=ArrayNew(1);
	fStart=1;
	for(i=1;i LTE len(line);i=i+1){
		letter = mid(line,i,1);
		if(inQuote){
			if(letter EQ this.config.textQualifier and (fStart EQ i or (mid(line,i-1,1) NEQ this.config.escapedBy))){// and mid(line,i+1,1) NEQ this.config.escapedBy))){
				if(mid(line,i+1,1) EQ this.config.seperator or i+1 GTE len(line)){
					inQuote=false;
					field = mid(line,fStart,(i-fStart));
					// unescape double quotes
					if(this.config.escapedBy NEQ ''){
						field = replace(field,this.config.escapedBy&this.config.textQualifier,this.config.textQualifier,"ALL");
					}
					ArrayAppend(arrFields, trim(field));
					fStart=i+1;
				}
			}
		}else{
			if(letter EQ this.config.textQualifier and fStart EQ i){
				inQuote=true;
				fStart=i+1;
			}else if(letter EQ this.config.seperator){
				if(i EQ 1 or mid(line,i-1,1) EQ this.config.seperator){
					ArrayAppend(arrFields,'');
				}else if(fStart NEQ i){
					field = mid(line,fStart,(i-fStart));
					ArrayAppend(arrFields, trim(field));
				} 
				fStart=i+1;
			}else if(i EQ len(line) and fStart NEQ i){
				field = mid(line,fStart,(i-fStart)+1); 
				ArrayAppend(arrFields, trim(field));
			}
		}
	} 
	if(right(line,1) EQ this.config.seperator){ 
		ArrayAppend(arrFields,'');
	}else if(len(line) EQ fStart){ 
		ArrayAppend(arrFields, trim(right(line,1)));
	} 
	return arrFields;
	</cfscript>
</cffunction>



</cfoutput>
</cfcomponent>