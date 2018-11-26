<cfcomponent>
	<cffunction name="init" localmode="modern" access="package" output="no">
    	<cfargument name="dbObject" type="component" required="yes">
    	<cfargument name="config" type="struct" required="no">
        <cfscript>
		variables.config=arguments.dbObject.getConfig();
		arguments.config.dbQuery=this;
		variables.db=arguments.dbObject;
		if(structkeyexists(arguments, 'config')){
			structappend(variables.config, arguments.config, true);
			if(structkeyexists(arguments.config, 'parseSQLFunctionStruct')){
				variables.config.parseSQLFunctionStruct=duplicate(arguments.config.parseSQLFunctionStruct);
			}
		}
		variables.lastSQL="";
		variables.lastQueryName="";
		variables.tableSQLString=":ztablesql:";
		variables.trustSQLString=":ztrustedsql:";
		variables.config.arrParam=[];
		</cfscript>
    </cffunction>
    
	<cffunction name="getLastSQL" localmode="modern" access="package" output="no" hint="Returns a COPY of the config data for debugging purposes.">
    	<cfscript>
		return {sql:variables.lastSQL, name:variables.lastQueryName};
		</cfscript>
    </cffunction>
    
	<cffunction name="getConfig" localmode="modern" access="public" output="no" hint="Returns a COPY of the config data for debugging purposes.">
    	<cfscript>
		return duplicate(variables.config);
		</cfscript>
    </cffunction>
    
	<cffunction name="param" localmode="modern" access="public" returntype="string" output="no">
    	<cfargument name="value" type="string" required="yes">
    	<cfargument name="cfsqltype" type="string" required="no">
        <cfscript>
		if(structkeyexists(arguments, 'cfsqltype')){
			arrayappend(variables.config.arrParam, {value:arguments.value, cfsqltype:arguments.cfsqltype});
		}else{
			if(isnumeric(arguments.value) and len(arguments.value) LT 10){
				if(find(".", arguments.value)){
					arrayappend(variables.config.arrParam, {value:arguments.value, cfsqltype:'cf_sql_float'});
				}else{
					arrayappend(variables.config.arrParam, {value:arguments.value, cfsqltype:'cf_sql_bigint'});
				}
			}else{
				arrayappend(variables.config.arrParam, {value:arguments.value});
			}
		}
		return "?";
		</cfscript>
	</cffunction>
    
	<cffunction name="table" localmode="modern" access="public" returntype="string" output="no">
    	<cfargument name="name" type="string" required="yes">
    	<cfargument name="datasource" type="string" required="no" default="#variables.config.datasource#">
        <cfscript>
		var zt="";
		if(variables.config.verifyQueriesEnabled and not structkeyexists(form, 'zab')){
			zt=variables.tableSQLString;
		}
		if(len(arguments.datasource)){
			variables.config.datasource=arguments.datasource;
			return variables.config.identifierQuoteCharacter&arguments.datasource&variables.config.identifierQuoteCharacter&"."&variables.config.identifierQuoteCharacter&zt&arguments.name&variables.config.identifierQuoteCharacter;
		}else{
			return variables.config.identifierQuoteCharacter&zt&arguments.name&variables.config.identifierQuoteCharacter;
		}
		</cfscript>
	</cffunction>
    
	<cffunction name="trustedSQL" localmode="modern" access="public" returntype="string" output="no">
    	<cfargument name="value" type="string" required="yes">
        <cfscript>
		if(variables.config.verifyQueriesEnabled and not structkeyexists(form, 'zab')){
			return variables.trustSQLString&arguments.value&variables.trustSQLString;
		}else{
			return arguments.value;
		}
		</cfscript>
	</cffunction>
    
    <cffunction name="execute" localmode="modern" access="public" returntype="any" output="no" hint="Use for any query.">
    	<cfargument name="name" type="variablename" required="yes" hint="A variable name for the query result.  Helps to identify query when debugging.">
    	<cfargument name="datasource" type="string" required="no" default="" hint="Optionally change the datasource.  Useful for show, set, etc queries that have no table clause to retain the same mysql connection request.zsession.">
    	<cfargument name="timeout" type="numeric" required="no" default="#0#">
    	<cfargument name="returnType" type="string" required="no" default="query">
        <cfscript>
		variables.config.sql=this.sql;
		if(arguments.datasource NEQ ""){
			variables.config.datasource=arguments.datasource;
		}
		var executeResult=variables.db.execute(arguments.name, variables.config, arguments.timeout, arguments.returnType);
		variables.lastSQL=this.sql;
		variables.lastQueryName=arguments.name;
		this.reset();
		return executeResult.result;
		</cfscript>
    </cffunction>
    
    <cffunction name="insert" localmode="modern" access="public" returntype="any" output="no" hint="Use for insert statements to auto-retrieve the inserted id more easily.">
    	<cfargument name="name" type="variablename" required="yes" hint="A variable name for the query result.  Helps to identify query when debugging.">
    	<cfargument name="idColumn" type="string" required="no" default="id" hint="The name of the sql id column.">
        <cfscript>
		var executeResult=0;
		variables.config.sql=this.sql;
		executeResult=variables.db.insertAndReturnId(arguments.name, arguments.idColumn, variables.config);
		variables.lastSQL=this.sql;
		variables.lastQueryName=arguments.name;
		this.reset();
		return executeResult;
		</cfscript>
    </cffunction>
    
	<cffunction name="reset" localmode="modern" access="public" returntype="any" output="no">
    	<cfscript>
		var c=0;
		if(variables.config.autoReset){
			c=variables.db.getConfig();
        	structappend(variables.config, c, true);
			variables.config.parseSQLFunctionStruct=duplicate(c.parseSQLFunctionStruct);
		}
		variables.config.arrParam=[];
		</cfscript>
    </cffunction>

	<cffunction name="getSQL" localmode="modern" access="public">
    	<cfscript>
		return variables.db.getSQL();
		</cfscript>
    </cffunction>
	<cffunction name="saveSQL" localmode="modern" access="public">
    	<cfscript>
		request.zos.storeNextQuery=true;
		</cfscript>
    </cffunction>

</cfcomponent>