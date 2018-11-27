<!--- 
db.cfc
Version: 0.1.002

Project Home Page: https://www.jetendo.com/manual/view/current/2.1/db-dot-cfc.html
Github Home Page: https://github.com/jetendo/db-dot-cfc

Licensed under the MIT license
http://www.opensource.org/licenses/mit-license.php
Copyright (c) 2013 Far Beyond Code LLC.
 --->
<cfcomponent output="no" name="db.cfc" hint="Enhances cfquery by analyzing SQL to enforce security & framework conventions.">
	<cfoutput>
	<cffunction name="init" localmode="modern" access="public" output="no">
		<cfargument name="ts" type="struct" required="no">
		<cfscript>
		variables.config={
			insertIdSQL:"select last_insert_id() id", // the select statement required to retrieve the ID just inserted by an insert query.  Automatically executed when using db.insert()
			identifierQuoteCharacter:'`', // Modify the character that should surround database, table or field names.
			dbtype:'datasource', // query, hsql or datasource are valid values.
			datasource:false, // Optional change the datasource.  This option is required if the query doesn't use dbQuery.table().
			autoReset:true, // Set to false to allow the current db object to retain it's configuration after running db.execute().  Only the parameters will be cleared.
			lazy:false, // Lucee/Railo's lazy="true" option returns a simple Java resultset instead of the ColdFusion compatible query result.  This reduces memory usage when some of the columns are unused.
			cacheForSeconds:0, // optionally set to a number of seconds to enable query caching
			sql:"", // specify the full sql statement
			verifyQueriesEnabled:false, // Enabling sql verification takes more cpu time, so it should only run when testing in development.
			parseSQLFunctionStruct:{}, // Each struct key value should be a function that accepts and returns parsedSQLStruct. Prototype: struct customFunction(required struct parsedSQLStruct, required string defaultDatabaseName);
			queryLogFunction: false, // Set to a function that has a struct argument with the following keys { sql:, configStruct: , result: }
			cacheStructKey:'variables.cacheStruct', // Set to an application or server scope struct to store this data in shared memory. Use structnew('soft') to have automatic garbage collection when the JVM is low on memory.
			cacheEnabled: true // Set to false to disable the query cache
		};
		if(structkeyexists(arguments, 'ts')){
			structappend(variables.config, arguments.ts, true);
			if(structkeyexists(arguments.ts, 'parseSQLFunctionStruct')){
				variables.config.parseSQLFunctionStruct=arguments.ts.parseSQLFunctionStruct;
			}
		}
		variables.tableSQLString=":ztablesql:";
		variables.trustSQLString=":ztrustedsql:";
		if(not structkeyexists(variables, 'cacheStruct')){
			variables.cacheStruct={};
		}
		variables.lastSQL="";
		variables.cachedQueryObject=createobject("zcorerootmapping.com.model.dbQuery");
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getConfig" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		return duplicate(variables.config);
		</cfscript>
	</cffunction>
	
	<cffunction name="processSQL" localmode="modern" access="private" output="no" returntype="string">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfscript>
		var processedSQL=0;
		if(arguments.configStruct.verifyQueriesEnabled and not structkeyexists(form, 'zab')){
			if(compare(arguments.configStruct.sql, variables.lastSQL) NEQ 0){
				variables.lastSQL=arguments.configStruct.sql;
				variables.verifySQLParamsAreSecure(arguments.configStruct);
				processedSQL=replacenocase(arguments.configStruct.sql,variables.trustSQLString,"","all");
				processedSQL=trim(variables.parseSQL(arguments.configStruct, processedSQL, arguments.configStruct.datasource));
			}else{
				processedSQL=trim(replacenocase(replacenocase(arguments.configStruct.sql,variables.trustSQLString,"","all"), variables.tableSQLString, "","all"));
			}
		}else{
			processedSQL=trim(arguments.configStruct.sql);
		}
		return processedSQL;
		</cfscript>
	</cffunction>
	
	
	<cffunction name="checkQueryCache" localmode="modern" access="private" output="no" returntype="struct">
		<cfargument name="cacheStruct" type="struct" required="yes">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfargument name="sql" type="string" required="yes">
		<cfargument name="nowDate" type="date" required="yes">
		<cfscript>
		var arrOption=[];
		var paramIndex=0;
		var paramKey=0;
		var hashCode=0;
		var currentParamStruct=arguments.configStruct.arrParam;
		var paramCount=arraylen(currentParamStruct);
		arrayappend(arrOption, "dbtype="&arguments.configStruct.dbtype&chr(10)&"datasource="&arguments.configStruct.datasource&chr(10)&"lazy="&arguments.configStruct.lazy&chr(10)&"cacheForSeconds="&arguments.configStruct.cacheForSeconds&chr(10)&"sql="&arguments.sql&chr(10));
		for(paramIndex=1;paramIndex LTE paramCount;paramIndex++){
			for(paramKey in currentParamStruct[paramIndex]){
				arrayAppend(arrOption, paramKey&"="&currentParamStruct[paramIndex][paramKey]&chr(10));
			}
		}
		hashCode=hash(arraytolist(arrOption,""),"sha-256");
		if(structkeyexists(arguments.cacheStruct, hashCode)){
			if(datediff("s", arguments.cacheStruct[hashCode].date, arguments.nowDate) LT arguments.configStruct.cacheForSeconds){
				arguments.configStruct.dbQuery.reset();
				return { success:true, hashCode:hashCode, result:arguments.cacheStruct[hashCode].result };
			}else{
				structdelete(arguments.cacheStruct, hashCode);
			}
		}
		return {success:false, hashCode:hashCode};
		</cfscript>
	</cffunction>
	
	
<cffunction name="runQuery" localmode="modern" access="private" returntype="any" output="no">
	<cfargument name="configStruct" type="struct" required="yes">
	<cfargument name="name" type="variablename" required="yes" hint="A variable name for the query result.  Helps to identify query when debugging.">
	<cfargument name="sql" type="string" required="yes">
    <cfargument name="timeout" type="numeric" required="no" default="#0#">
    <cfargument name="returntype" type="string" required="no" default="">
	<cfscript>
	var running=true;
	var queryStruct={
		lazy=arguments.configStruct.lazy,
		datasource=arguments.configStruct.datasource
	}; 
	var cfquery=0;
	var cfcatch=0;
	var db=structnew();
	var startIndex=1;
	var tempSQL=0;
	var paramCount=arraylen(arguments.configStruct.arrParam);
	var questionMarkPosition=0;
	var paramIndex=1;
	var paramDump=0;
	var startTime=gettickcount('nano');
	if(arguments.timeout NEQ 0){
		queryStruct.timeout=arguments.timeout;
	}
	if(arguments.configStruct.dbtype NEQ "" and arguments.configStruct.dbtype NEQ "datasource"){
		queryStruct.dbtype=arguments.configStruct.dbtype;	
		structdelete(queryStruct, 'datasource');
	}else if(isBoolean(queryStruct.datasource)){
		throw("dbQuery.init({datasource:datasource}) must be set before running dbQuery.execute() by either using dbQuery.table() or db.datasource=""myDatasource"";", "database");
	}
	if(arguments.returnType NEQ ""){
		queryStruct.lazy=false;
		queryStruct.returnType=arguments.returnType;
	}else{
		if((left(arguments.sql, 20)) DOES NOT CONTAIN "select "){
			queryStruct.lazy=false;
		}else if(request.zos.isTestServer){
			queryStruct.lazy=true;
		}
	}
	queryStruct.name="db."&arguments.name;
	retryCount=0;
	retryLimit=3;
	retrySleep=500;
	enableRetry=false; 
	if(request.zos.istestserver and structkeyexists(request.zos, 'storeNextQuery')){
		storeLastSQL(arguments.configStruct, arguments.sql);
		structdelete(request.zos, 'storeNextQuery');
	}
	try{
		if(paramCount){
			query attributeCollection="#queryStruct#"{
				while(running){
					questionMarkPosition=find("?", arguments.sql, startIndex);
					if(questionMarkPosition EQ 0){
						if(paramCount and paramIndex-1 GT paramCount){
							throw("dbQuery.execute() failed: There were more question marks then parameters in the current sql statement.  You must use dbQuery.param() to specify parameters.  A literal question mark is not allowed.<br /><br />SQL Statement:<br />"&arguments.sql, "database");
						}
						running=false;
					}else{
						tempSQL=mid(arguments.sql, startIndex, questionMarkPosition-startIndex);
						echo(preserveSingleQuotes(tempSQL));
						if(isnull(arguments.configStruct.arrParam[paramIndex].value)){
							arguments.configStruct.arrParam[paramIndex].null=true;
						}
						queryparam attributeCollection="#arguments.configStruct.arrParam[paramIndex]#";
						startIndex=questionMarkPosition+1;
						paramIndex++;
					}
				}
				if(paramCount GT paramIndex-1){ 
					variables.throwErrorForTooManyParameters(arguments.configStruct);
				}
				tempSQL=mid(arguments.sql, startIndex, len(arguments.sql)-(startIndex-1));
				echo(preserveSingleQuotes(tempSQL));
			}
		}else{
			query attributeCollection="#queryStruct#"{
				echo(preserveSingleQuotes(arguments.sql));
			}
		}
	}catch(Any e){
		if(retryCount EQ retryLimit){
			rethrow;
		}
		if(e.message CONTAINS "Communications link failure"){
			enableRetry=true;
			application.zcore.databaseRestarted=true; 
		}else if(e.message CONTAINS "Deadlock found when trying to get lock"){
			enableRetry=true;
			form.retryCount=retryCount;
		}
		if(enableRetry){
			retryCount++;
			sleep(retrySleep);
			retrySleep*=2;
			retry;
		}else{
			rethrow;
		}
	}
	request.zos.lastDBResult=cfquery;
	if(structkeyexists(request.zos, 'queryCount')){
		request.zos.queryCount++;
	}
	if(structkeyexists(variables.config, 'queryLogFunction') and isCustomFunction(variables.config.queryLogFunction)){
		try{
			variables.config.queryLogFunction({ totalExecutionTime:((gettickcount('nano')-startTime)/1000000), sql:arguments.sql, configStruct:arguments.configStruct, result: request.zos.lastDBResult });
		}catch(Any excpt){
			if(request.zos.isDeveloper or request.zos.isTestServer){
				echo("Failed to run queryLogFunction due to error:<br />");
				writedump(excpt);
			}
		}
	}
	if(structkeyexists(db, arguments.name)){ 
		if(isArray(db[arguments.name])){
			request.zos.queryRowCount+=arrayLen(db[arguments.name]);
		}else if(structkeyexists(db[arguments.name], 'recordcount')){
			request.zos.queryRowCount+=db[arguments.name].recordcount;
		}
		return db[arguments.name];
	}else{
		return true;
	}
	</cfscript>
</cffunction>
	
	<cffunction name="throwErrorForTooManyParameters" localmode="modern" access="private" output="no">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfscript>
		var s=0;
		var errorMessage="dbQuery.execute() failed: There were more parameters then question marks in the current sql statement.  You must run dbQuery.execute() before building any additional sql statements with the same db object.  If you need to build multiple queries before executing the query, you must create a new dbQuery object using db.newQuery();<br /><br />";
		savecontent variable="paramDump"{
			writedump(arguments.configStruct.arrParam);	
		}
		s=arguments.configStruct.dbQuery.getLastSQL();
		throw(errorMessage&"<br />Current SQL Statement:<br />"&arguments.configStruct.sql&"<br />Parameters:<br />"&paramDump&"<br /><br />Previous SQL Statement:<br />"&s.sql&"<br />Last Query Name:"&s.name, "database");
		</cfscript>
	</cffunction>
	
	<cffunction name="newQuery" localmode="modern" access="public">
		<cfargument name="config" type="struct" required="no">
		<cfscript>
		var queryCopy=duplicate(variables.cachedQueryObject, true);
		if(structkeyexists(arguments, 'config')){
			config=duplicate(arguments.config);
			config.dbQuery=queryCopy;
			queryCopy.init(this, config);
		}else{
			queryCopy.init(this);
		}
		return queryCopy;
		</cfscript>
	</cffunction>
	
	<cffunction name="insertAndReturnID" localmode="modern" access="package" returntype="any" output="no" hint="Executes the insert statement and returns the inserted ID if insert was successful.">
		<cfargument name="name" type="variablename" required="yes" hint="A variable name for the query result.  Helps to identify query when debugging.">
		<cfargument name="idColumn" type="string" required="no" default="id" hint="The name of the sql id column.">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfscript>
		var db=structnew();
		var cfquery=0;
		var queryStruct={
			lazy=arguments.configStruct.lazy,
			datasource=arguments.configStruct.datasource,
			name:"db."&arguments.name&"_id"
		};
		transaction action="begin"{
			try{
				var result=variables.execute(arguments.name, arguments.configStruct);
				if(result.success){
					query attributeCollection="#queryStruct#"{
						echo(preserveSingleQuotes(arguments.configStruct.insertIDSQL));
					}
					transaction action="commit";
					return {success:true, result:db[arguments.name&"_id"][arguments.idColumn]};
				}else{
					transaction action="commit";
					return {success:false, result:result};
				}
			}catch(Any e){
				transaction action="rollback";
				rethrow;
			}
		}
		</cfscript>
		
	</cffunction>
	
	<cffunction name="execute" localmode="modern" access="package" returntype="struct" output="yes">
		<cfargument name="name" type="variablename" required="yes" hint="A variable name for the query result.  Helps to identify query when debugging.">
		<cfargument name="configStruct" type="struct" required="yes">
    	<cfargument name="timeout" type="numeric" required="no" default="#0#">
    	<cfargument name="returnType" type="string" required="no" default="">
		<cfscript>
		var cfcatch=0;
		var errorStruct=0;
		var cacheStruct=structget(arguments.configStruct.cacheStructKey);
		if(not structkeyexists(arguments.configStruct, 'sql') or not len(arguments.configStruct.sql)){
			throw("The sql statement must be set before executing the query;", "database");
		}
		
		processedSQL=variables.processSQL(arguments.configStruct);
		if(arguments.configStruct.cacheEnabled and arguments.configStruct.cacheForSeconds and left(processedSQL, 7) EQ "SELECT "){
			tempCacheEnabled=true;
		}else{
			tempCacheEnabled=false;
		}
		if(tempCacheEnabled){
			nowDate=now();
			cacheResult=variables.checkQueryCache(cacheStruct, arguments.configStruct, processedSQL, nowDate);
			if(cacheResult.success){
				return {success:true, result:cacheResult.result};
			}
		}
		try{
			result=variables.runQuery(arguments.configStruct, arguments.name, processedSQL, arguments.timeout, arguments.returnType);
		}catch(database errorStruct){
			arguments.configStruct.dbQuery.reset();
			rethrow;
		}
		arguments.configStruct.dbQuery.reset();
		if(isSimpleValue(result)){
		  	return {success:true, result: true};
		}else{
			if(tempCacheEnabled){
				cacheStruct[cacheResult.hashCode]={date:nowDate, result:result};
			}
			return {success:true, result:result};
		}
		</cfscript>
	</cffunction>
	
	
	<cffunction name="getCleanSQL" localmode="modern" access="private" output="no" returntype="string">
		<cfargument name="sql" type="string" required="yes">
		<cfscript>
		return replace(replace(arguments.sql, variables.trustSQLString, "", "all"), variables.tableSQLString, "", "all");
		</cfscript>
	</cffunction>
	
	<cffunction name="verifySQLParamsAreSecure" localmode="modern" access="private" output="no" returntype="any">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfscript>
		var sql=arguments.configStruct.sql;
		// strip trusted sql
		sql=rereplace(sql, variables.trustSQLString&".*?"&variables.trustSQLString, chr(9), "all");
		
		// detect string literals
		if(find("'", sql) NEQ 0 or find('"', sql) NEQ 0){
			throw("The SQL statement can't contain single or double quoted string literals when using the db component.  You must use dbQuery.param() to specify all values including constants.<br /><br />SQL Statement:<br />"&variables.getCleanSQL(arguments.configStruct.sql), "database");	
		}
		// strip c style comments
		sql=replace(sql, chr(10), " ", "all");
		sql=replace(sql, chr(13), " ", "all");
		sql=replace(sql, chr(9), " ", "all");
		sql=replace(sql, "/*", chr(10), "all");
		sql=replace(sql, "*/", chr(13), "all");
		sql=replace(sql, "*", chr(9), "all");
		sql=rereplace(sql, chr(10)&"[^\*]*?"&chr(13), chr(9), "all");
		
		// strip table/db/field names
		if(arguments.configStruct.identifierQuoteCharacter NEQ "" and arguments.configStruct.identifierQuoteCharacter NEQ "'"){
			sql=rereplace(sql, arguments.configStruct.identifierQuoteCharacter&"[^"&arguments.configStruct.identifierQuoteCharacter&"]*"&arguments.configStruct.identifierQuoteCharacter, chr(9), "all");
		}
		
		// strip words not beginning with a number
		sql=rereplace(sql, "[a-zA-Z_][a-zA-Z\._0-9]*", chr(9), "all");
		
		// detect any remaining numbers
		if(refind("[0-9]", sql) NEQ 0){
			throw("The SQL statement can't contain literal numbers when using the db component.  You must use dbQuery.param() to specify all values including constants.<br /><br />SQL Statement:<br />"&variables.getCleanSQL(arguments.configStruct.sql), "database"); 	
		}
		return sql;
		</cfscript> 
	</cffunction>
	
	<cffunction name="parseSQL" localmode="modern" access="private" output="no" returntype="any">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfargument name="sqlString" type="string" required="yes">
		<cfargument name="defaultDatabaseName" type="string" required="yes">
		<cfscript>
		var tableStruct={};
		var local={};
		var i=0;
		var parseStruct={};
		var tempSQL=arguments.sqlString;
		parseStruct.arrError=arraynew(1);
		parseStruct.arrTable=arraynew(1);
		tempSQL=replace(replace(replace(replace(replace(tempSQL,chr(10)," ","all"),chr(9)," ","all"),chr(13)," ","all"),")"," ) ","all"),"("," ( ","all");
		tempSQL=" "&rereplace(replace(replace(replace(lcase(tempSQL),"\\"," ","all"),"\'"," ","all"),'\"'," ","all"), "/\*.*?\*/"," ", "all")&" ";
		tempSQL=replace(replace(replace(replace(replace(tempSQL, ",", ", ", "all"), "=", " = ","all"), ".`", ".","all"), "`.", ".","all"), "`", " ", "all");
		tempSQL=rereplace(tempSQL,"'[^']*?'","''","all");
		tempSQL=rereplace(tempSQL,'"[^"]*?"',"''","all");
		parseStruct.columnList="";
		parseStruct.wherePos=findnocase(" where ",tempSQL);
		parseStruct.setPos=findnocase(" set ",tempSQL);
		parseStruct.valuesPos=refindnocase("\)\s*values",tempSQL);
		parseStruct.fromPos=findnocase(" from ",tempSQL);
		parseStruct.selectPos=findnocase(" select ",tempSQL);
		parseStruct.insertPos=findnocase(" insert ",tempSQL);
		parseStruct.replacePos=findnocase(" replace ",tempSQL);
		parseStruct.updatePos=findnocase(" update ",tempSQL);
		parseStruct.intoPos=findnocase(" into ",tempSQL);
		parseStruct.limitPos=findnocase(" limit ",tempSQL, parseStruct.fromPos);
		parseStruct.groupByPos=findnocase(" group by ",tempSQL, parseStruct.fromPos);
		parseStruct.orderByPos=findnocase(" order by ",tempSQL, parseStruct.fromPos);
		parseStruct.havingPos=findnocase(" having ",tempSQL, parseStruct.fromPos);
		parseStruct.firstLeftJoinPos=findnocase(" left join ",tempSQL, parseStruct.fromPos);
		parseStruct.firstParenthesisPos=findnocase(" ( ",tempSQL);
		parseStruct.firstWHEREPos=len(tempSQL);
		curTempSQL=trim(tempSQL);
		if(left(curTempSQL, 5) EQ "show "){
			if(parseStruct.fromPos EQ 0 or left(trim(removechars(trim(curTempSQL), 1, 5)),6) EQ "tables"){
				return arguments.sqlString;
			}
		}
		if(parseStruct.wherePos){
			parseStruct.firstWHEREPos=parseStruct.wherePos;
		}else if(parseStruct.groupByPos){
			parseStruct.firstWHEREPos=parseStruct.groupByPos;
		}else if(parseStruct.orderByPos){
			parseStruct.firstWHEREPos=parseStruct.orderByPos;
		}else if(parseStruct.orderByPos){
			parseStruct.firstWHEREPos=parseStruct.orderByPos;
		}else if(parseStruct.havingPos){
			parseStruct.firstWHEREPos=parseStruct.havingPos;
		}else if(parseStruct.limitPos){
			parseStruct.firstWHEREPos=parseStruct.limitPos;
		}
		parseStruct.lastWHEREPos=len(tempSQL);
		if(parseStruct.groupByPos){
			parseStruct.lastWHEREPos=parseStruct.groupByPos;
		}else if(parseStruct.orderByPos){
			parseStruct.lastWHEREPos=parseStruct.orderByPos;
		}else if(parseStruct.havingPos){
			parseStruct.lastWHEREPos=parseStruct.havingPos;
		}else if(parseStruct.limitPos){
			parseStruct.lastWHEREPos=parseStruct.limitPos;
		}
		parseStruct.setStatement="";
		if(parseStruct.setPos){
			if(parseStruct.wherePos){
				parseStruct.setStatement=" "&mid(tempSQL, parseStruct.setPos+5, parseStruct.wherePos-(parseStruct.setPos+5))&" ";
			}else{
				parseStruct.setStatement=" "&mid(tempSQL, parseStruct.setPos+5, len(tempSQL)-(parseStruct.setPos+5))&" ";
			}
		}
		if(parseStruct.wherePos){
			parseStruct.whereStatement=" "&mid(tempSQL, parseStruct.wherePos+6, parseStruct.lastWHEREPos-(parseStruct.wherePos+6))&" ";
		}else{
			parseStruct.whereStatement="";
		}
		parseStruct.arrLeftJoin=arraynew(1);
		matching=true;
		curPos=1;
		while(matching){
			tableStruct=structnew();
			tableStruct.leftJoinPos=findnocase(" left join ",tempSQL, curPos);
			if(tableStruct.leftJoinPos EQ 0) break;
			tableStruct.onPos=findnocase(" on ",tempSQL, tableStruct.leftJoinPos+1);
			if(tableStruct.onPos EQ 0 or tableStruct.onPos GT parseStruct.firstWHEREPos){
				tableStruct.onPos=parseStruct.firstWHEREPos;
			}
			tableStruct.table=mid(tempSQL, tableStruct.leftJoinPos+11, tableStruct.onPos-(tableStruct.leftJoinPos+11));
			if(arguments.configStruct.identifierQuoteCharacter NEQ ""){
				tableStruct.table=trim(replace(tableStruct.table, arguments.configStruct.identifierQuoteCharacter,"","all"));
			}
			if(tableStruct.table CONTAINS " as "){
				stringPosition=findnocase(" as ",tableStruct.table);
				tableStruct.tableAlias=trim(mid(tableStruct.table, stringPosition+4, len(tableStruct.table)-(stringPosition+3)));
				tableStruct.table=trim(left(tableStruct.table,stringPosition-1));
			}else if(tableStruct.table CONTAINS " "){
				stringPosition=findnocase(" ",tableStruct.table);
				tableStruct.tableAlias=trim(mid(tableStruct.table, stringPosition+1, len(tableStruct.table)-(stringPosition)));
				tableStruct.table=trim(left(tableStruct.table,stringPosition-1));
			}else{
				tableStruct.table=trim(tableStruct.table);
				tableStruct.tableAlias=trim(tableStruct.table);
			}
			if(tableStruct.tableAlias CONTAINS "FORCE " or tableStruct.tableAlias CONTAINS "USE "){ 
				tableStruct.tableAlias=trim(listgetat(tableStruct.tableAlias, 1, " "));
				if(tableStruct.tableAlias EQ "FORCE" or tableStruct.tableAlias EQ "USE"){
					tableStruct.tableAlias=tableStruct.table;
				}
			}
			if(findnocase(variables.tableSQLString,tableStruct.table) EQ 0){
				arrayappend(parseStruct.arrError, "All tables in queries must be generated with dbQuery.table(table, datasource); function. This table wasn't: "&tableStruct.table);
			}else{
				tableStruct.table=replacenocase(tableStruct.table,variables.tableSQLString,"");
				tableStruct.tableAlias=replacenocase(tableStruct.tableAlias,variables.tableSQLString,"");
			}
			tableStruct.onstatement="";
			if(tableStruct.table DOES NOT CONTAIN "."){
				tableStruct.table=arguments.defaultDatabaseName&"."&tableStruct.table;
			}else{
				if(tableStruct.tableAlias CONTAINS "."){
					tableStruct.tableAlias=trim(listgetat(tableStruct.tableAlias,2,"."));
				}
			}
			curPos=tableStruct.onPos+1;
			arrayappend(parseStruct.arrLeftJoin, tableStruct);
		}
		
		
		
		if(parseStruct.firstLeftJoinPos){
			parseStruct.endOfFromPos=parseStruct.firstLeftJoinPos;
		}else if(parseStruct.firstWHEREPos){
			parseStruct.endOfFromPos=parseStruct.firstWHEREPos;
		}else{
			parseStruct.endOfFromPos=len(tempSQL);
		}
		
		if(parseStruct.intoPos and (parseStruct.selectPos EQ 0 or parseStruct.selectPos GT parseStruct.intoPos)){
			if(parseStruct.setPos){
				tableStruct=structnew();
				tableStruct.type="into";
				tableStruct.table=mid(tempSQL, parseStruct.intoPos+5, parseStruct.setPos-(parseStruct.intoPos+5));
				tableStruct.tableAlias=tableStruct.table;
				arrayappend(parseStruct.arrTable, tableStruct);
			}else if(parseStruct.firstParenthesisPos){
				tableStruct=structnew();
				tableStruct.type="into";
				tableStruct.table=mid(tempSQL, parseStruct.intoPos+5, parseStruct.firstParenthesisPos-(parseStruct.intoPos+5));
				tableStruct.tableAlias=tableStruct.table;
				arrayappend(parseStruct.arrTable, tableStruct);
			}else{
				if(parseStruct.selectPos){
					tableStruct=structnew();
					tableStruct.type="into";
					tableStruct.table=mid(tempSQL, parseStruct.intoPos+5, parseStruct.selectPos-(parseStruct.intoPos+5));
					tableStruct.tableAlias=tableStruct.table;
					arrayappend(parseStruct.arrTable, tableStruct);
				}
			}
		} 
		fromType="from";
		if(parseStruct.fromPos EQ 0){
			if(parseStruct.setPos NEQ 0 and parseStruct.valuesPos EQ 0){
				// detected replace or update sql like this:  UPDATE/REPLACE table, table1 SET ... WHERE ... 
				if(parseStruct.replacePos and parseStruct.intoPos){
					parseStruct.fromPos=parseStruct.intoPos;
					fromType="replace";
				}else if(parseStruct.insertPos and parseStruct.intoPos){
					parseStruct.fromPos=parseStruct.intoPos;
					fromType="insert";
				}else if(parseStruct.updatePos){
					parseStruct.fromPos=parseStruct.updatePos+2;
					fromType="update";
				}
				parseStruct.endOfFromPos=parseStruct.setPos-1;
			}else if(parseStruct.valuesPos){
				if(parseStruct.replacePos and parseStruct.intoPos){
					parseStruct.fromPos=parseStruct.intoPos;
					fromType="replace";

					parseStruct.endOfFromPos=find("(", tempSQL, parseStruct.intoPos);
					endColumnList=find(")", tempSQL, parseStruct.intoPos)-1;
					parseStruct.columnList=" "&mid(tempSQL, parseStruct.endOfFromPos+1, endColumnList-(parseStruct.endOfFromPos+1))&" ";
				}else if(parseStruct.insertPos and parseStruct.intoPos){
					parseStruct.fromPos=parseStruct.intoPos;
					fromType="insert";

					parseStruct.endOfFromPos=find("(", tempSQL, parseStruct.intoPos);
					endColumnList=find(")", tempSQL, parseStruct.intoPos)-1;
					parseStruct.columnList=" "&mid(tempSQL, parseStruct.endOfFromPos+1, endColumnList-(parseStruct.endOfFromPos+1))&" ";
				}
			}
		}
		if(parseStruct.fromPos){
			c2=mid(tempSQL, parseStruct.fromPos+5, parseStruct.endOfFromPos-(parseStruct.fromPos+5));
			c2=replacenocase(replacenocase(replacenocase(replacenocase(replace(replace(c2,")"," ","all"),"("," ","all"), " STRAIGHT_JOIN ", " , ","all"), " CROSS JOIN ", " , ","all"), " INNER JOIN ", " , ","all"), " JOIN ", " , ","all");
			arrT2=listtoarray(c2, ","); 
			for(i=1;i LTE arraylen(arrT2);i++){
				arrT2[i]=trim(arrT2[i]);
				if(arrT2[i] EQ "''"){
					continue;
				}
				tableStruct=structnew();
				tableStruct.type=fromType;
		
				if(arrT2[i] CONTAINS " as "){
					stringPosition=findnocase(" as ", arrT2[i]);
					tableStruct.tableAlias=trim(mid(arrT2[i], stringPosition+4, len(arrT2[i])-(stringPosition+3)));
					tableStruct.table=trim(left(arrT2[i],stringPosition-1));
				/*}else if(arrT2[i] CONTAINS " on "){
					stringPosition=findnocase(" ", arrT2[i]);
					tableStruct.tableAlias=trim(mid(arrT2[i], stringPosition+1, len(arrT2[i])-(stringPosition)));
					tableStruct.table=trim(left(arrT2[i],stringPosition-1));*/
				}else if(arrT2[i] CONTAINS " "){
					stringPosition=findnocase(" ", arrT2[i]);
					tableStruct.tableAlias=trim(mid(arrT2[i], stringPosition+1, len(arrT2[i])-(stringPosition)));
					tableStruct.table=trim(left(arrT2[i],stringPosition-1));
				}else{
					tableStruct.table=trim(arrT2[i]);
					tableStruct.tableAlias=trim(arrT2[i]);
				}
				onPos2=findNoCase(" on ", tableStruct.tableAlias);
				
				if(onPos2){
					parseStruct.whereStatement&=" and "&mid(tableStruct.tableAlias, onPos2+4, (len(tableStruct.tableAlias)-onPos2)+5);
					tableStruct.tableAlias=left(tableStruct.tableAlias, onPos2-1);
				}
				if(findnocase(variables.tableSQLString,tableStruct.table) EQ 0){
					arrayappend(parseStruct.arrError, "All tables in queries must be generated with dbQuery.table(table, datasource); function. This table wasn't: "&tableStruct.table);
				}else{
					tableStruct.table=replacenocase(tableStruct.table,variables.tableSQLString, "");//arguments.configStruct.identifierQuoteCharacter);
					tableStruct.tableAlias=replacenocase(tableStruct.tableAlias,variables.tableSQLString, "");//arguments.configStruct.identifierQuoteCharacter);
				}
				if(tableStruct.tableAlias CONTAINS "FORCE " or tableStruct.tableAlias CONTAINS "USE "){ 
					tableStruct.tableAlias=trim(listgetat(tableStruct.tableAlias, 1, " "));
					if(tableStruct.tableAlias EQ "FORCE" or tableStruct.tableAlias EQ "USE"){
						tableStruct.tableAlias=tableStruct.table;
					}
				}
				arrayappend(parseStruct.arrTable, tableStruct);
			}
		} 
		
		
		for(i=1;i LTE arraylen(parseStruct.arrLeftJoin);i++){
			if(i EQ arraylen(parseStruct.arrLeftJoin)){
				np=parseStruct.firstWHEREPos;
			}else{
				np=parseStruct.arrLeftJoin[i+1].leftJoinPos;
			}
			if(np NEQ parseStruct.arrLeftJoin[i].onPos){
				parseStruct.arrLeftJoin[i].onstatement=mid(tempSQL, parseStruct.arrLeftJoin[i].onPos+4, np-(parseStruct.arrLeftJoin[i].onPos+4));
			}
		}
		for(i=1;i LTE arraylen(parseStruct.arrTable);i++){
			if(arguments.configStruct.identifierQuoteCharacter NEQ ""){
				parseStruct.arrTable[i].table=trim(replace(parseStruct.arrTable[i].table,arguments.configStruct.identifierQuoteCharacter,"","all"));
				parseStruct.arrTable[i].tableAlias=trim(replace(parseStruct.arrTable[i].tableAlias,arguments.configStruct.identifierQuoteCharacter,"","all"));
			}
			if(parseStruct.arrTable[i].table DOES NOT CONTAIN "."){
				parseStruct.arrTable[i].table=arguments.defaultDatabaseName&"."&parseStruct.arrTable[i].table;
			}else{
				if(parseStruct.arrTable[i].tableAlias CONTAINS "."){
					parseStruct.arrTable[i].tableAlias=trim(listgetat(parseStruct.arrTable[i].tableAlias,2,"."));
				}
			}
		}
		parseStruct.defaultDatabaseName=arguments.defaultDatabaseName;
		parseStruct.sql=replace(arguments.sqlString, variables.tableSQLString,"","all");

		for(functionIndex in arguments.configStruct.parseSQLFunctionStruct){
			parseStruct=arguments.configStruct.parseSQLFunctionStruct[functionIndex](parseStruct); 
		}
		if(arraylen(parseStruct.arrError) NEQ 0){
			throw(arraytolist(parseStruct.arrError, "<br />")&"<br /><br />SQL Statement<br />"&parseStruct.sql, "database");
		}
		return parseStruct.sql;
		</cfscript>
	</cffunction> 
	
	<cffunction name="storeLastSQL" localmode="modern" access="public">
		<cfargument name="configStruct" type="struct" required="yes">
		<cfargument name="sql" type="string" required="yes">
		<cfscript>
		configStruct=arguments.configStruct;
		sql=arguments.sql;
		arrSQL=[];
		startIndex=1;
		running=true;
		paramCount=arraylen(configStruct.arrParam);
		paramIndex=1; 
		savecontent variable="sql2"{
			if(paramCount){
				while(running){
					questionMarkPosition=find("?", sql, startIndex);
					if(questionMarkPosition EQ 0){
						if(paramCount and paramIndex-1 GT paramCount){
							throw("dbQuery.execute() failed: There were more question marks then parameters in the current sql statement.  You must use dbQuery.param() to specify parameters.  A literal question mark is not allowed.<br /><br />SQL Statement:<br />"&sql, "database");
						}
						running=false;
					}else{
						tempSQL=mid(sql, startIndex, questionMarkPosition-startIndex);
						echo(tempSQL);						
						echo("'"&application.zcore.functions.zescape(configStruct.arrParam[paramIndex].value)&"'");
						startIndex=questionMarkPosition+1;
						paramIndex++;
					}
				}
				tempSQL=mid(sql, startIndex, len(sql)-(startIndex-1));
				echo(tempSQL); 
			}else{
				echo(sql); 
			}
		}
		variables.lastFullSQL=sql2;
		</cfscript>
	</cffunction>

	<cffunction name="getSQL" localmode="modern" access="public">
		<cfscript>
		if(structkeyexists(variables, 'lastFullSQL')){
			return variables.lastFullSQL;
		}else{
			return '';
		}
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>