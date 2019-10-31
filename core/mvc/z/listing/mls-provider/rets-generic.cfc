<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.base">
<cfoutput>
<cfscript>
this.retsVersion="1.5";
this.arrTypeLoop=arraynew(1);
variables.typeStruct=structnew();
variables.typeStruct["Tiny"]="int(11)";
variables.typeStruct["Character"]="varchar";
variables.typeStruct["Small"]="varchar";
variables.typeStruct["Date"]="date";
variables.typeStruct["DateTime"]="datetime"; 
variables.typeStruct["Boolean"]="varchar"; 
variables.typeStruct["Decimal"]="decimal(11,2)";
variables.typeStruct["Int"]="int(11)";
variables.typeStruct["Long"]="int(11)";
variables.typeStruct["text"]="text";
</cfscript>
	
<cffunction name="getRETSFieldName" localmode="modern" access="public" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="class" type="string" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfscript>
	
	if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct,arguments.resource)){
		ms=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].table[arguments.class];
		if(arraylen(this.arrTypeLoop) NEQ 0){
			if(structkeyexists(ms.fieldNameLookup, arguments.field&"_"&arguments.class)){
				return ms.fieldNameLookup[arguments.field&"_"&arguments.class];
			}else if(structkeyexists(ms.fieldNameLookup, arguments.field)){
				return ms.fieldNameLookup[arguments.field];
			}else{
				return arguments.field;
			}
		}else{
			return ms.fieldNameLookup[arguments.field];
		}
	}
	</cfscript>
</cffunction>
	
<cffunction name="getRETSValue" localmode="modern" access="public" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="class" type="string" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	var i=0;
	var cur=0;
	if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct,arguments.resource)){
		local.ms=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource];
		if(arraylen(this.arrTypeLoop) NEQ 0){
			
			if(structkeyexists(local.ms.tablefields, arguments.field) EQ false){
				return false;
			}
			for(i=1;i LTE arraylen(this.arrTypeLoop);i++){
				arguments.field=replacenocase(arguments.field,"_"&this.arrTypeLoop[i],"");
			}
			
			if(structkeyexists(local.ms.fieldLookup, arguments.field&"_"&arguments.class)){
				local.typeName=local.ms.fieldLookup[arguments.field&"_"&arguments.class];
				if(structkeyexists(local.ms.typeStruct[local.typeName].valueStruct, arguments.value)){
					return local.ms.typeStruct[local.typeName].valueStruct[arguments.value];
				}else{
					return arguments.value;
				}
			}
					/*
			for(i=1;i LTE arraylen(this.arrTypeLoop);i++){
					if(structkeyexists(local.ms.fieldLookup, arguments.field&"_"&this.arrTypeLoop[i])){
						local.typeName=local.ms.fieldLookup[arguments.field&"_"&this.arrTypeLoop[i]];
						//structappend(rs, local.ms.typeStruct[local.ms.fieldLookup[arguments.field&"_"&this.arrTypeLoop[i]]].valueStruct);
						if(structkeyexists(local.ms.typeStruct[local.typeName].valueStruct, arguments.value)){
							return local.ms.typeStruct[local.typeName].valueStruct[arguments.value];
						}else{
							return "";
						}
					}
			}
			*/
			
			if(structkeyexists(local.ms.fieldLookup, arguments.field) EQ false){
				return arguments.value;
			}else{
				return "";
			}
		}else{
			if(structkeyexists(local.ms.fieldLookup, arguments.field)){
				if(structkeyexists(local.ms.typeStruct[local.ms.fieldLookup[arguments.field]].valueStruct, arguments.value)){
					return local.ms.typeStruct[local.ms.fieldLookup[arguments.field]].valueStruct[arguments.value];
				}else{
					return arguments.value;
				}
			}else if(structkeyexists(local.ms.tablefields, arguments.field) EQ false){
				return false;
			}else{
				return arguments.value;
			}
		}
	}else{
		writeoutput('Invalid resource, "#arguments.resource#"');
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>

<cffunction name="getRETSValues" localmode="modern" access="public" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="class" type="string" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfscript>
	var rs=structnew();
	var i=0;
	var cur=0;
	if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct,arguments.resource)){
		if(arraylen(this.arrTypeLoop) NEQ 0){ 
			if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup, arguments.field)){
				structappend(rs, application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].typeStruct[application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup[arguments.field]].valueStruct);
			} 
			if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup, arguments.field&"_"&arguments.class)){ 
				structappend(rs, application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].typeStruct[application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup[arguments.field&"_"&arguments.class]].valueStruct);
			} 
			return rs;
		}else{
			if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup, arguments.field)){
				return application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].typeStruct[application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct[arguments.resource].fieldLookup[arguments.field]].valueStruct;
			}else{
				return false;
			}
		}
	}else{
		writeoutput('Invalid resource, "#arguments.resource#');
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>

<cffunction name="getRetsDataObject" localmode="modern">
	<cfscript>
    if(structkeyexists(variables, 'retsDataCom') EQ false){
        variables.retsDataCom=createobject("component","rets"&this.mls_id&"data");
    }
	return variables.retsDataCom;
    </cfscript>
</cffunction>

<cffunction name="parseMetaData" localmode="modern" access="public" output="yes" returntype="any">
	<cfargument name="metadataDateLastModified" type="date" required="yes">
	<cfscript> 
	var db=request.zos.queryObject; 
	var metastruct=structnew();
	var curday=dateformat(now(),'yyyy-mm-dd');
	if(request.zos.istestserver){
		path="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	}else{
		path="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	} 
	directory directory="#path#" filter="metadata*.xml" name="qD" sort="name DESC"; 
	if(qD.recordcount NEQ 0){
		metadataPath=path&qd.name[1];
		diskMetaDataDate=qD.dateLastModified[1];	
	}
	if(qD.recordcount EQ 0){
		return false; 
	}
	first=true;
	for(row in qD){
		if(first){
			first=false;
			continue;
		} 
		application.zcore.functions.zDeleteFile(path&row.name);
	}
	if(not structkeyexists(form, 'forceMetaDataRebuild') and (datecompare(diskMetaDataDate, arguments.metadataDateLastModified) LTE 0)){
		try{
			return objectload(tobinary(application.zcore.functions.zreadfile(request.zos.globals.serverprivatehomedir&"_cache/listing/metadata/"&this.mls_id&".txt")));
		}catch(Any excpt){
			// ignore error and recreate metadata file	
		}
	}
	contents=application.zcore.functions.zreadfile(metadataPath);
	try{
		xmlMeta=xmlparse(contents);
	}catch(Any e){
		savecontent variable="out"{
			echo('<h2>Invalid XML: '&metadataPath&'</h2>');
			writedump(e);
		}
		throw(out);
	}
	xmlBase=xmlMeta.rets.metadata["metadata-system"].system["metadata-resource"].resource;
	structdelete(variables,"contents");
	structdelete(variables,"xmlMeta");
	
	
	metaLookupStruct=structnew();
	for(i=1;i LTE arraylen(xmlBase);i++){
		curTables=xmlBase[i]["METADATA-CLASS"].class;
		mk=xmlBase[i]["METADATA-CLASS"].xmlattributes.resource;
		metaStruct[mk]=structnew();
		metaStruct[mk].typeStruct=structnew();
		metaStruct[mk].tableFields=structnew();
		metaStruct[mk].fieldLookup=structnew();
		
		if(this.retsVersion EQ "1.7"){
			if(structkeyexists(xmlBase[i],"METADATA-LOOKUP")){
				if(structkeyexists(xmlBase[i]["METADATA-LOOKUP"],"lookup")){
					curBase=xmlBase[i]["METADATA-LOOKUP"]["lookup"];
					for(n=1;n LTE arraylen(curBase);n++){
						lk=curBase[n].LookupName.xmltext;
						metaStruct[mk].typeStruct[lk]=structnew();
						metaStruct[mk].typeStruct[lk].valueStruct=structnew();
						if(structkeyexists(curBase[n], "METADATA-LOOKUP_TYPE")){
							if(structkeyexists(curBase[n]["METADATA-LOOKUP_TYPE"],"lookup")){
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookup;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
							}else if(structkeyexists(curBase[n]["METADATA-LOOKUP_TYPE"],"lookuptype")){
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookuptype;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
								
							}else{
								writeoutput(n&' missing: curBase[n]["METADATA-LOOKUP_TYPE"]');
								application.zcore.functions.zabort();
							}
						}
					}
				}
			}
		}else if(this.retsVersion EQ "1.5"){
			if(structkeyexists(xmlBase[i],"METADATA-LOOKUP")){
				if(structkeyexists(xmlBase[i]["METADATA-LOOKUP"],"lookuptype")){
					curBase=xmlBase[i]["METADATA-LOOKUP"]["lookuptype"];
					for(n=1;n LTE arraylen(curBase);n++){
						lk=curBase[n].LookupName.xmltext;
						metaStruct[mk].typeStruct[lk]=structnew();
						metaStruct[mk].typeStruct[lk].valueStruct=structnew();
						if(structkeyexists(curBase[n], "METADATA-LOOKUP_TYPE")){
							if(structkeyexists(curBase[n]["METADATA-LOOKUP_TYPE"],"lookup")){
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookup;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
							}else{
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookuptype;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
								
							}
						}
					}
				}
			}
		}else if(this.retsVersion EQ "1.1"){
			if(structkeyexists(xmlBase[i],"METADATA-LOOKUP")){
				if(structkeyexists(xmlBase[i]["METADATA-LOOKUP"],"lookuptype")){
					curBase=xmlBase[i]["METADATA-LOOKUP"]["lookuptype"];
					for(n=1;n LTE arraylen(curBase);n++){
						lk=curBase[n].LookupName.xmltext;
						metaStruct[mk].typeStruct[lk]=structnew();
						metaStruct[mk].typeStruct[lk].valueStruct=structnew();
						if(structkeyexists(curBase[n], "METADATA-LOOKUP_TYPE")){
							if(structkeyexists(curBase[n]["METADATA-LOOKUP_TYPE"],"lookup")){
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookup;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
							}else{
								curLookup=curBase[n]["METADATA-LOOKUP_TYPE"].lookuptype;
								for(g=1;g LTE arraylen(curLookup);g++){
									metaStruct[mk].typeStruct[lk].valueStruct[curLookup[g].value.xmltext]=curLookup[g].longvalue.xmltext;
								}
								
							}
						}
					}
				}
			}
		}
		if(structkeyexists(this,"useRetsFieldName") EQ false){
			this.useRetsFieldName="standard";	
		}
		metaStruct[mk].table=structnew();
		for(f=1;f LTE arraylen(curTables);f++){
			if(not structkeyexists(curTables[f], "METADATA-TABLE")){
				echo('metadata-table missing for #this.mls_id# metadata.xml | skipping: f=#f#');
				continue;
			}
			curTable=curTables[f]["METADATA-TABLE"];
			metaStruct[mk].table[curTable.xmlattributes.class]=structnew();
			metaStruct[mk].table[curTable.xmlattributes.class].tableFields=structnew();
			metaStruct[mk].table[curTable.xmlattributes.class].fieldLookup=structnew();
			metaStruct[mk].table[curTable.xmlattributes.class].fieldNameLookup=structnew();
			
			if(structkeyexists(curTable,'field')){
				for(n=1;n LTE arraylen(curTable.field);n++){
					ts=structnew();
					ts.length=curTable.field[n].maximumlength.xmltext;
					ts.type=curTable.field[n].datatype.xmltext;
					ts.longname=curTable.field[n].LongName.xmltext;
					if(this.useRetsFieldName EQ "long"){
						tempName=curTable.field[n].LongName.xmltext;
					}else{
						tempName=curTable.field[n].SystemName.xmltext;
						if(tempName EQ ""){
							tempName=curTable.field[n].StandardName.xmltext;
						}
					}
					tempFullName=curTable.field[n].LongName.xmltext;
					if(tempFullName EQ ""){
						tempFullName=curTable.field[n].StandardName.xmltext;
					}
					tempName=replace(tempName," ","","ALL");
					lk=curTable.field[n].LookupName.xmltext;
					if(curTable.field[n].LookupName.xmltext NEQ ""){
						if(structkeyexists(metaStruct[mk].typeStruct,lk)){
							if(structkeyexists(this, 'arrTypeLoop') and arraylen(this.arrTypeLoop)){
								local.tempname2=tempName&"_"&curTable.xmlattributes.class;
							}else{
								local.tempname2=tempName;
							}
							metaStruct[mk].fieldLookup[local.tempname2]=lk;
							metaStruct[mk].table[curTable.xmlattributes.class].fieldLookup[local.tempname2]=lk;
							metaStruct[mk].table[curTable.xmlattributes.class].fieldNameLookup[local.tempname2]=tempFullName;
						}else{
							metaStruct[mk].table[curTable.xmlattributes.class].fieldNameLookup[tempname]=tempFullName;
						}
					}else{
						metaStruct[mk].table[curTable.xmlattributes.class].fieldNameLookup[tempname]=tempFullName;
					}
					metaStruct[mk].tableFields[tempName]=ts;
					metaStruct[mk].table[curTable.xmlattributes.class].tableFields[tempName]=ts;
				}
			}
		}
	} 
	metastruct["property"].primaryKey="rets#this.mls_id#_"&variables.resourceStruct["property"].id;
	metaStruct["property"].tableFields[variables.resourceStruct["property"].id].type="character";
	metaStruct["property"].tableFields[variables.resourceStruct["property"].id].length="15";
	arrError=arraynew(1);
	alterStruct=structnew();
	db2=request.zos.noVerifyQueryObject;
	for(g2 in metastruct){
		if(structkeyexists(variables.resourceStruct, g2)){
			g=variables.resourceStruct[g2].resource;
			arrF=arraynew(1);
			arrF2=arraynew(1);
			alterStruct[g]=arraynew(1);
			fieldStruct=structnew();
			fieldNameStruct=structnew();
			columnStruct=structnew();
			columnNameStruct=structnew();
			for(n in metastruct[g].tablefields){
				if(trim(n) NEQ ""){
					nlow="rets#this.mls_id#_"&application.zcore.functions.zescape(replace(lcase(n)," ","","ALL"));
					type=variables.typeStruct[metaStruct[g].tableFields[n].type];
					if(metaStruct[g].tableFields[n].length GT 79){
						type="text";	
						metaStruct[g].tableFields[n].type="text";
					}
					field='`#nlow#` #type#';
					if(metaStruct[g].tableFields[n].type EQ "boolean"){
						field&="(1)";
					}else if(metaStruct[g].tableFields[n].type EQ "character" or metaStruct[g].tableFields[n].type EQ "small"){
						field&="(#max(1,metaStruct[g].tableFields[n].length)#)";
					}else if(metaStruct[g].tableFields[n].type EQ 'tiny' or metaStruct[g].tableFields[n].type EQ 'int' or metaStruct[g].tableFields[n].type EQ 'decimal'){
						field&=" UNSIGNED";
					}
					fieldNameStruct[nlow]=true;
					fieldStruct[field]=true;
					arrayappend(arrF2,nlow);
					arrayappend(arrF,field);
				}
			}
			db2.sql="SHOW TABLES IN #request.zos.zcoreDatasource# LIKE 'rets#this.mls_id#_#lcase(g)#'";
			local.qT=db2.execute("qT"); 
			if(local.qT.recordcount EQ 0){
				continue;
			}
			db2.sql="show fields from #db2.table("rets"&this.mls_id&"_"&lcase(g), request.zos.zcoreDatasource)#";
			qP=db2.execute("qP"); 
			if(isquery(qP) EQ false){
				continue;
			}
			for(i=1;i LTE qP.recordcount;i++){
				columnName=qP.field[i];
				if(columnName NEQ "rets#this.mls_id#_"&g&"_id"){
					column="`#columnName#` #qP.type[i]#";
					columnStruct[column]=true;
					columnNameStruct[columnName]=true;
					fieldName2=replace(columnName,"rets#this.mls_id#_","");
					if(structkeyexists(fieldNameStruct, columnName) EQ false){
						ts=structnew();
						ts.old="rets#this.mls_id#_#g#.#columnName#";
						ts.new="deleted column";
						arrayappend(alterStruct[g], "drop column `#columnName#`#chr(10)#");
						arrayappend(arrError,ts);
					}else if(structkeyexists(fieldStruct, column) EQ false){
						nlow=application.zcore.functions.zescape(lcase(columnName));
						fieldName2=replace(columnName,"rets#this.mls_id#_","");
						type=variables.typeStruct[metaStruct[g].tableFields[fieldName2].type];
						if(metaStruct[g].tableFields[fieldName2].length GT 79){
							type="text";	
							metaStruct[g].tableFields[fieldName2].type="text";
						}
						field='`#nlow#` #type#';
						if(metaStruct[g].tableFields[fieldName2].type EQ "boolean"){
							field&="(1) NOT NULL DEFAULT '0'";
						}else if(metaStruct[g].tableFields[fieldName2].type EQ "character" or metaStruct[g].tableFields[fieldName2].type EQ "small"){
							field&="(#max(1,metaStruct[g].tableFields[fieldName2].length)#) NOT NULL";
						}else if( metaStruct[g].tableFields[fieldName2].type EQ 'tiny' or metaStruct[g].tableFields[fieldName2].type EQ 'int' or metaStruct[g].tableFields[fieldName2].type EQ 'decimal'){
							field&=" UNSIGNED NOT NULL DEFAULT '0'";
						}else{
							field&=" NOT NULL ";
						}
						ts=structnew();
						ts.old="#column#";
						ts.new="#field#";
						arrayappend(alterStruct[g], "change `#columnName#` #field##chr(10)#");
						arrayappend(arrError,ts);
					}
				}
			}
			lastOne="";
			for(n=1;n LTE arraylen(arrF);n++){
				if(structkeyexists(columnNameStruct, arrF2[n]) EQ false){
					ts=structnew();
					ts.old="Column missing";
					if(lastOne EQ ""){
						ts.new="<strong>rets#this.mls_id#_#lcase(g)#.#arrF[n]#</strong>";
						arrayappend(alterStruct[g], "add column #arrF[n]##chr(10)#");
					}else{
						ts.new="<strong>rets#this.mls_id#_#lcase(g)#.#arrF[n]#</strong> after #lastOne#";
					arrayappend(alterStruct[g], "add column #arrF[n]# after `#lastOne#`#chr(10)#");
					}
					arrayappend(arrError,ts);
				}
				lastOne=arrF2[n];
			}
		}
	}
	</cfscript>
	<cfif arraylen(arrError) NEQ 0>
		<cfsavecontent variable="emailout"><span style="font-family:Verdana, Geneva, sans-serif; font-size:11px;">
		Run these queries on the test server and make sure the application still works and then run on live server and then re-run import process.;
		<hr />
		<cfscript>
		for(g2 in metaStruct){
			if(structkeyexists(variables.resourceStruct, g2)){
				g=variables.resourceStruct[g2].resource;
				if(arraylen(alterStruct[g]) NEQ 0){
					writeoutput("ALTER TABLE `#request.zos.zcoreDatasource#`.`rets#this.mls_id#_#lcase(g)#`<br /> #arraytolist(alterStruct[g],", <br />")#;<br /><hr size=""1""><br />");
				}
			}
		}
		</cfscript>
		</span></cfsavecontent>
		<cfif isDefined('server.rets#this.mls_id#metadatachangeemailsent') EQ false or application.zcore.functions.zso(application,'rets#this.mls_id#metadatachangeemailsent') NEQ curday>
			<cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="URGENT ERROR: rets#this.mls_id# metadata may have changed." type="html">
			#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title>Metadata</title>
			</head>
			
			<body>
			Changed metadata detected on #request.zos.currentHostName#. <br />
			<br />
			If I need to update the table structure, then I should first download the new metadata to the test server and then IMPORT MLS. <br />
			<br />
			IMPORT MLS ON TEST SERVER:<br />
			<a href="#request.zOS.zcoreTestAdminDomain#/z/listing/tasks/importMLS/index?zforce=1">#request.zOS.zcoreTestAdminDomain#/z/listing/tasks/importMLS/index?zforce=1</a><br />
			<br />
			If valid, delete the old metadata file and update table structure on live server.<br />
			<br />
#emailout#
			</body>
			</html>
			</cfmail>
			<cfset application["rets#this.mls_id#metadatachangeemailsent"]=curday>
		</cfif>
#emailout#
		<cfscript>
		application.zcore.functions.zabort();
		</cfscript>
	</cfif>
	<cfscript>
	structdelete(application,"rets#this.mls_id#metadatachangeemailsent");
	
	//application.zcore.functions.zdump(metastruct);
	//application.zcore.functions.zabort();
	structdelete(variables,"xmlBase");
	structdelete(variables,"curLookup");
	structdelete(variables,"curTables");
	structdelete(variables,"curTable");
	structdelete(variables,"curBase");
	
	application.zcore.functions.zWriteFile(request.zos.globals.serverprivatehomedir&"_cache/listing/metadata/"&this.mls_id&".txt", toBase64(objectsave(metaStruct)));
	
	return metaStruct;
	</cfscript>
</cffunction>

<cffunction name="convertRawDataToLookupValues" localmode="modern">
	<cfargument name="idx" type="struct" required="yes">
	<cfargument name="tableName" type="string" required="yes">
	<cfargument name="tableId" type="string" required="yes">
	<cfscript>
	var curTableData=0;
	var i10=0;
	var column=0;
	var value=0;
	var shortColumn=0;
	var arrV=0;
	var arrV2=0;
	var n=0;
	var t1=0;
	var t2=0;
	var t3=0;
	var t4=0;
	var retsPrefix='rets'&this.mls_id&"_";
	var retsPrefixLength=len(retsPrefix);
	var idx=arguments.idx;
	curTableData=false;
	if(structkeyexists(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct,'metaStruct')){
		curTableData=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct.property.table[arguments.tableName]; 
	}
	for(i10 in idx){
		if(structkeyexists(idx, i10) EQ false){
			idx[i10]="";	
		}
		if(left(i10, retsPrefixLength) EQ retsPrefix){
			column=i10;
			shortColumn=removechars(column, 1, retsPrefixLength); 
			value=idx[i10];
			if(arrayLen(this.arrTypeLoop)){
				shortColumn&="_"&arguments.tableName; // this was changed from arguments.tableId because it was wrong
			}  
			if(value NEQ ""){ 
				if(left(i10,8) NEQ 'listing_' and isstruct(curTableData) and structkeyexists(curTableData.fieldLookup, shortColumn)){
					arrV=listtoarray(trim(value),',',false);
					arrV2=arraynew(1); 
					for(n=1;n LTE arraylen(arrV);n++){
						t2=trim(arrV[n]);//replace(arrV[n]," ","","ALL");
						t4=curTableData.fieldLookup[shortColumn];
						t3=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[t4].valueStruct; 
						if(structkeyexists(t3, t2)){
							t1=t3[t2];
							arrayappend(arrV2,t1);
						}
					}
					if(arraylen(arrV2)){
						value=arraytolist(arrV2,", ");
					}
				} 
				idx[column]=value;
			}
		}
	}
	return idx;
	</cfscript>
</cffunction>

<cffunction name="setColumns" localmode="modern">
	<cfargument name="arrColumns" type="array" required="yes">
	<cfscript>
	var i=0;
	var sn=structnew();
	var arrColumns2=arraynew(1);
	application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct=structnew();
	/*for(i=1;i LTE arraylen(arguments.arrColumns);i++){
		if(structkeyexists(sn, arguments.arrColumns[i]) EQ false){
			sn[arguments.arrColumns[i]]=true;
			arrayappend(arrColumns2, arguments.arrColumns[i]);
		}else{
			application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct[i]=true;
		}
	}
	arguments.arrColumns=arrColumns2;*/
	application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns="rets#this.mls_id#_"&replace(arraytolist(arguments.arrColumns),",",",rets#this.mls_id#_","ALL");
	application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns=listtoarray(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns); 
	</cfscript>
</cffunction>

<cffunction name="getImportFilePath" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="allowSold" type="boolean" required="yes">
	<cfscript>
	var i=0;
	var path=request.zos.sharedPath&"mls-data/"&arguments.ss.row.mls_id&"/"; 

	var qD=application.zcore.functions.zReadDirectory(path, "listings-*.txt");
	for(i=1;i LTE qD.recordcount;i++){
		if(datecompare(qD.dateLastModified[i],dateadd("n",-1,now())) GTE 0){
			continue;
		}
		if(arguments.allowSold){
			if(qd.name[i] CONTAINS "sold"){
				return "mls-data/"&arguments.ss.row.mls_id&"/"&qd.name[i];	
			}
		}else{
			if(qd.name[i] DOES NOT CONTAIN "sold"){
				return "mls-data/"&arguments.ss.row.mls_id&"/"&qd.name[i];	
			}

		}
	}
	return false;	
	</cfscript>
</cffunction>

<cffunction name="setMLS" localmode="modern" output="no" returntype="any">
	<cfargument name="mls_id" type="numeric" required="yes">
	<cfscript>
	this.mls_id=arguments.mls_id;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" output="yes" returntype="any">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var g=0;
	var g2=0;
	var path=0;
	var arrim=0;
	var arrunique=0;
	var i=0;
	var newpath=0;
	var arrc=0;
	var arrtf=0;
	var type=0;
	var nlow=0;
	var ilow=0;
	var qm=0;
	var f=0;
	var db=application.zcore.db.newQuery();
	var firstline=0;
	var offset=0;
	var columns=0;
	var qc=0;
	var t44=0;
	var n=0;
	var e=0;
	var cfcatch=0;
	var newpath2=0;
	var loadnewpath2=0;
	var loadnewpath=0;
	var db3=0;
	var fieldOrderStruct=structnew();
	var dbMLS=0;
	var dbMLSData=0;
	this.getRetsDataObject();
	
	</cfscript>
</cffunction>

 
<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var qC=0;
	var i=0;
	var g=0;
	var path=0;
	var qdir=0;
	var curday=dateformat(now(),'yyyy-mm-dd');
	db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city WHERE 
	city_deleted = #db.param(0)#";
	qC=db.execute("qC"); 
	
	if(request.zos.istestserver){
		path="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	}else{
		path="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	}
	arguments.sharedStruct.lookupStruct.table="rets#this.mls_id#_#lcase(arguments.resource)#";
	arguments.sharedStruct.lookupStruct.primaryKey="rets#this.mls_id#_#variables.resourceStruct[arguments.resource].id#";
	arguments.sharedStruct.lookupStruct.arrColumns=listtoarray(arguments.sharedStruct.lookupStruct.idxColumns);
	arguments.sharedStruct.lookupStruct.idColumnOffset=0; 
	for(g=1;g LTE arraylen(arguments.sharedStruct.lookupStruct.arrColumns);g++){
		if(arguments.sharedStruct.lookupStruct.arrColumns[g] EQ arguments.sharedStruct.lookupStruct.primaryKey){
			arguments.sharedStruct.lookupStruct.idColumnOffset=g;
			break;
		}
	}
	for(local.row in qC){
        	arguments.sharedStruct.lookupStruct.cityIDXStruct[local.row.city_id]=local.row.city_name&"|"&local.row.state_abbr;
	}
	directory directory="#path#" filter="metadata*.xml" name="qDir" sort="name DESC";
	if(qDir.recordcount EQ 0){
		if(structkeyexists(application.sitestruct[request.zos.globals.id], 'rets#this.mls_id#metadatachangeemailsent') EQ false or application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'rets#this.mls_id#metadatachangeemailsent') NEQ curday){
			mail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="URGENT ERROR: rets#this.mls_id# metadata is missing."{
				if(qDir.recordcount EQ 0){
					writeoutput('Missing');
				}else{
					writeoutput('Changed');
				}
				writeoutput(' metadata detected.');
				if(qDir.recordcount NEQ 0){
					writeoutput(' If I need to update the table structure, then I should first download the new metadata to the test server and then IMPORT MLS. 

IMPORT MLS ON TEST SERVER:#request.zOS.zcoreTestAdminDomain#/z/listing/tasks/importMLS/index?zforce=1

If valid, delete the old metadata file and update table structure on live server.
Metadata paths listed below (missing if there are none)#chr(10)#');
					for(local.row in qDir){
						writeoutput(local.row.path&local.row.name&chr(10));
					}
				}else{
					writeoutput(' I must force a new download of the metadata to live server.');
				}
			}
			application.sitestruct[request.zos.globals.id]["rets#this.mls_id#metadatachangeemailsent"]=curday;
		}
	}else{
		structdelete(application.sitestruct[request.zos.globals.id],"rets#this.mls_id#metadatachangeemailsent");
	}
	</cfscript>
</cffunction>

<cffunction name="initRETSMeta" localmode="modern">
	<cfscript>
	
	lock name="#request.zos.installPath#-initRETSMeta-mls_id-#this.mls_id#" type="exclusive" timeout="1000"{
		var fieldOrderStruct=structnew();
		var db=application.zcore.db.newQuery();
		this.getRetsDataObject();
		local.c=application.zcore.db.getConfig();
		local.c.verifyQueriesEnabled=false;
		local.c.datasource=request.zos.zcoreDatasource;
		local.c.autoReset=false;
		dbMLS=application.zcore.db.newQuery(local.c);
		local.c=application.zcore.db.getConfig();
		local.c.verifyQueriesEnabled=false;
		local.c.datasource=request.zos.zcoreDatasource;
		local.c.autoReset=false;
		dbMLSData=application.zcore.db.newQuery(local.c);
		this.tablePrefix="rets#this.mls_id#_";


		sharedStruct=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct;
		if((structkeyexists(form, 'forceMetaDataRebuild') and request.zos.isDeveloper) or structkeyexists(sharedStruct,'metastruct') EQ false or structkeyexists(sharedStruct,'metaStructUpdated') EQ false){
			if(structkeyexists(sharedStruct, 'metadataDateLastModified') EQ false){
				sharedStruct.metadataDateLastModified=createdate(2000,1,1);	
			}
			sharedStruct.metaStruct=this.parseMetaData(sharedStruct.metadataDateLastModified);	
			if(not isStruct(sharedStruct.metaStruct)){
				return;
			}
			sharedStruct.metaStructUpdated=true;
		}
		if(request.zos.istestserver){
			path="#request.zos.sharedPath#mls-data/"&this.mls_id&"/";
		}else{
			path="#request.zos.sharedPath#mls-data/"&this.mls_id&"/";
		} 
	}
	</cfscript>
</cffunction>

<cffunction name="makeListingImportDataReady" localmode="modern" access="public">
	<cfscript>
	initRETSMeta();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>