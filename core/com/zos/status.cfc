<!--- 
status.cfc
Version: 0.1.002

Project Home Page: Coming soon
Github Home Page: https://github.com/jetendo/status-dot-cfc

Licensed under the MIT license
http://www.opensource.org/licenses/mit-license.php
Copyright (c) 2013 Far Beyond Code LLC.
 --->
<cfcomponent displayname="Status Message System" hint="" output="no">
	<cfoutput>   
	<cffunction name="init" localmode="modern" access="public" output="no">
    	<cfargument name="config" type="struct" required="no" default="#{}#">
        <cfscript>
		var root=expandPath("/");
		var configDefault={
			sessionKey:"zStatusStruct"
		};
		structappend(variables, configDefault, true);
		structappend(variables, arguments.config, true);
		variables.initRun=true;
        </cfscript>
    </cffunction>
    
	<cffunction name="initSession" localmode="modern" access="private" returntype="any" output="no">
    	<cfscript>
		if(not structkeyexists(variables,'initRun')){
			this.init();
		}
		application.zcore.session.forceEnable();
		if(not structkeyexists(request.zsession, variables.sessionKey)){
			request.zsession[variables.sessionKey] = {
				count = 0,
				id = 0,
				dataCount = 0
			};
		}
		</cfscript>
    </cffunction>
	
	<!--- statusCom.getStruct(id); --->
	<cffunction name="getStruct" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="yes">
        <cfscript>
		var local={};
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		</cfscript>
		<cfif isNumeric(arguments.id) EQ false>
			<cfif find("@",arguments.id) NEQ 0>
				Invalid Request
				<cfscript>
				application.zcore.functions.zabort();
				</cfscript>
			</cfif>
		</cfif>
		<cfscript>
		if(structkeyexists(request.zsession[variables.sessionKey], arguments.id)){// and structkeyexists(request.zsession[variables.sessionKey][arguments.id], 'varStruct')){
			return request.zsession[variables.sessionKey][arguments.id];
		
		}else{
			// force it to exist and then return it
			request.zsession[variables.sessionKey][arguments.id]={
				arrMessages = ArrayNew(1),
				arrErrors = ArrayNew(1),
				errorStruct = StructNew(),
				varStruct = StructNew(),
				errorFieldStruct = StructNew()
			};
			if(structkeyexists(request.zsession[variables.sessionKey],'count') EQ false or arguments.id GT request.zsession[variables.sessionKey].count){
				request.zsession[variables.sessionKey].count = arguments.id;
			}
			return request.zsession[variables.sessionKey][arguments.id];
		}
		</cfscript>
	</cffunction>
	
	<!--- statusCom.getNewId(); --->
	<cffunction name="getNewId" localmode="modern" access="public" returntype="any" output="false" hint="Create new id">
		<cfscript>
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		curStruct=request.zsession[variables.sessionKey];
		if(isnumeric(curStruct.count) EQ false){
			curStruct.count=0;
		}
		curStruct.id = curStruct.count+1;
		curStruct.count = curStruct.id;
		return curStruct.id;
		</cfscript>
	</cffunction>
    
    
	<!--- statusCom.deleteId(id); --->
	<cffunction name="deleteId" localmode="modern" access="public" returntype="any" output="false" hint="Delete status id">
		<cfargument name="id" type="numeric" required="yes">
		<cfscript>
		if(structkeyexists(request.zsession, variables.sessionKey) and structkeyexists(request.zsession[variables.sessionKey], arguments.id)){
			structdelete(request.zsession[variables.sessionKey], arguments.id);
		}
		</cfscript>
	</cffunction>
    
	<!--- statusCom.deleteSessionData(); --->
	<cffunction name="deleteSessionData" localmode="modern" access="public" returntype="any" output="false" hint="Delete status id">
		<cfscript>
		structdelete(request.zsession, variables.sessionKey);
		structdelete(variables, 'statusStruct');
		</cfscript>
	</cffunction>
	
	<!--- statusCom.setFieldError(id, fieldName, isError); --->
	<cffunction name="setFieldError" localmode="modern" access="public" output="false" hint="Mark a field as having an generated an error." returntype="any">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="fieldName" required="yes" type="string">
		<cfargument name="isError" required="no" type="boolean" default="#true#">
		<cfscript>
		var statusStruct = this.getStruct(arguments.id);
		if(arguments.isError){
			statusStruct.errorFieldStruct[arguments.fieldName]=true;
		}else{
			structdelete(statusStruct.errorFieldStruct, arguments.fieldName);
		}
		</cfscript>
	</cffunction>
    
	
	<!--- statusCom.setStatus(id, status, varStruct, error); --->
	<cffunction name="setStatus" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="yes">
		<cfargument name="status" type="any" required="no" default="#false#">
		<cfargument name="varStruct" type="any" required="no" default="#StructNew()#">
		<cfargument name="error" type="boolean" required="no" default="#false#">
        <cfscript>
		
		var statusStruct=0;
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		</cfscript>
		<cfif isNumeric(arguments.id) EQ false>
			<cfif find("@",arguments.id) NEQ 0>
				Invalid Request
				<cfscript>
				application.zcore.functions.zabort();
				</cfscript>
			<cfelse>
				<cfscript>
				application.zcore.template.fail("zcorerootmapping.com.zos.status.cfc: setStatus: id must be numeric");
				</cfscript>
			</cfif>
		</cfif>
		<cfscript>
		statusStruct = this.getStruct(arguments.id);
		if(arguments.status NEQ false){
			request.zsession[variables.sessionKey].dataCount++;
			if(arguments.error){
				local.exists=false;
				for(local.i=1;local.i LTE arraylen(statusStruct.arrErrors);local.i++){
					if(statusStruct.arrErrors[local.i] EQ arguments.status){
						local.exists=true;	
						break;
					}
				}
				if(local.exists EQ false){
					ArrayAppend(statusStruct.arrErrors, arguments.status);	
				}
			}else{
				local.exists=false;
				for(local.i=1;local.i LTE arraylen(statusStruct.arrMessages);local.i++){
					if(statusStruct.arrMessages[local.i] EQ arguments.status){
						local.exists=true;	
						break;
					}
				}
				if(local.exists EQ false){
					ArrayAppend(statusStruct.arrMessages, arguments.status);
				}
			}
		}
		/*
		if(structkeyexists(statusStruct,'varStruct') EQ false){
			request.zsession[variables.sessionKey][arguments.id]={
				arrMessages = ArrayNew(1),
				arrErrors = ArrayNew(1),
				errorStruct = StructNew(),
				varStruct = StructNew(),
				errorFieldStruct = StructNew()
			};
		}
		*/
		if(structkeyexists(request.zsession[variables.sessionKey],'dataStruct') EQ false){
			request.zsession[variables.sessionKey].dataStruct=0;
		}
		if(isStruct(arguments.varStruct)){
			request.zsession[variables.sessionKey].dataCount++;
			StructAppend(statusStruct.varStruct, arguments.varStruct, true);
		}
		return arguments.id;
		</cfscript>
	</cffunction>
	
	<!--- statusCom.getField(id, fieldName, defaultValue); --->
	<cffunction name="getField" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="yes">
		<cfargument name="fieldName" type="string" required="yes">
		<cfargument name="defaultValue" type="any" required="no" default="">
		<cfargument name="forceToExist" type="boolean" required="no" default="#false#">
		<cfscript>
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		if(isDefined('request.zsession') and structkeyexists(request.zsession[variables.sessionKey],arguments.id) and structkeyexists(request.zsession[variables.sessionKey][arguments.id].varStruct, arguments.fieldName)){
			return request.zsession[variables.sessionKey][arguments.id].varStruct[arguments.fieldName];
		}else{
			if(arguments.forceToExist){
				var statusStruct = this.getStruct(arguments.id);
				statusStruct[arguments.fieldName]=arguments.defaultValue;
			}
			return arguments.defaultValue;
		}
		</cfscript>
	</cffunction>
	
	
	
	<!--- statusCom.setField(id, fieldName, value); --->
	<cffunction name="setField" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="string" required="yes">
		<cfargument name="fieldName" type="string" required="yes">
		<cfargument name="value" type="any" required="yes">
		
		<cfscript>
		var statusStruct=0;
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		statusStruct = this.getStruct(arguments.id);
		StructInsert(statusStruct.varStruct, arguments.fieldName, arguments.value, true);
		</cfscript>
	</cffunction>
	
	
	<!--- getErrorCount(id); --->
	<cffunction name="getErrorCount" localmode="modern" access="public" returntype="any" output="true">
		<cfargument name="id" type="string" required="yes">
		<cfscript>
		var statusStruct = this.getStruct(arguments.id);
		return ArrayLen(statusStruct.arrErrors)+StructCount(statusStruct.errorStruct);
		</cfscript> 
	</cffunction>
	
	<!--- getErrors(id); --->
	<cffunction name="getErrors" localmode="modern" access="public" returntype="any" output="true">
		<cfargument name="id" type="string" required="yes">
		<cfscript>
		var i = "";
		var arrTemp = ArrayNew(1); 
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		if(structkeyexists(request.zsession[variables.sessionKey],arguments.id)){
			arrTemp = duplicate(request.zsession[variables.sessionKey][arguments.id].arrErrors);
			
			for(i in request.zsession[variables.sessionKey][arguments.id].errorStruct){
				ArrayAppend(arrTemp, request.zsession[variables.sessionKey][arguments.id].errorStruct[i]);
			}		
		}
		return arrTemp;
		</cfscript> 
	</cffunction>

	<!--- getErrorFields(id); --->
	<cffunction name="getErrorFields" localmode="modern" access="public" returntype="any" output="true">
		<cfargument name="id" type="string" required="yes">
		<cfscript>
		var i = "";
		var arrTemp = ArrayNew(1); 
		if(not structkeyexists(variables, 'initRun') or not structkeyexists(request.zsession, variables.sessionKey)) variables.initSession();
		if(structkeyexists(request.zsession[variables.sessionKey],arguments.id)){
			for(i in request.zsession[variables.sessionKey][arguments.id].errorFieldStruct){
				ArrayAppend(arrTemp, i);
			}		
		}
		return arrTemp;
		</cfscript> 
	</cffunction>
	
	<!--- getErrorStyle(id, fieldName, errorClass, regularClass); --->
	<cffunction name="getErrorStyle" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="fieldName" type="string" required="yes">
		<cfargument name="errorClass" type="string" required="yes">
		<cfargument name="regularClass" type="string" required="no" default="">
		<cfscript>
		if(this.checkFieldError(arguments.id, arguments.fieldName)){
			return ' class="'&arguments.errorClass&'" ';
		}else{
			if(len(arguments.regularClass)){
				return ' class="'&arguments.regularClass&'" ';
			}else{
				return "";
			}
		}
		</cfscript>
	</cffunction>
	
	<!--- checkFieldError(id, fieldName); --->
	<cffunction name="checkFieldError" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="fieldName" type="string" required="yes">
		<cfscript>
		if(structkeyexists(request.zsession[variables.sessionKey],arguments.id) and structkeyexists(request.zsession[variables.sessionKey][arguments.id].errorFieldStruct, arguments.fieldName)){
			return true;
		}else{
			return false;
		}
		</cfscript>
	</cffunction>
	
	<!--- statusCom.setErrorFieldStruct(id, struct); --->
	<cffunction name="setErrorFieldStruct" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="struct" type="struct" required="yes">
		<cfscript>
		var statusStruct = this.getStruct(arguments.id);
		var i=0;
		for(i in arguments.struct){
			if(not arguments.struct[i]){
				structdelete(arguments.struct, i);
			}
		}
		StructAppend(statusStruct.errorFieldStruct, arguments.struct);
		</cfscript>
	</cffunction>
	
	<!--- statusCom.setErrorStruct(id, struct); --->
	<cffunction name="setErrorStruct" localmode="modern" access="public" returntype="any" output="false">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="struct" type="struct" required="yes">
		<cfscript>
		var statusStruct = this.getStruct(arguments.id);
		var i=0;
		var struct2={};
		for(i IN arguments.struct){
			struct2[i]=true;
		}
		this.setErrorFieldStruct(arguments.id, struct2);
		StructAppend(statusStruct.errorStruct, arguments.struct);
		</cfscript>
	</cffunction>
    
    
    <cffunction name="display" localmode="modern" access="public" returntype="any" output="true">
        <cfargument name="id" type="string" required="yes">
        <cfargument name="getVars" type="boolean" required="no" default="#false#">
        <cfargument name="silent" type="boolean" required="no" default="#false#">
        <cfargument name="targetStruct" type="struct" required="no" default="#form#">
        <cfscript>
        var statusStruct = StructNew();
        var arrErrors = ArrayNew(1);
        statusStruct = this.getStruct(arguments.id);
        arrErrors = this.getErrors(arguments.id);
        if(structkeyexists(statusStruct, 'arrMessages')){
            if(arguments.getVars){
                StructAppend(arguments.targetStruct, statusStruct.varStruct, true);
            }
            if(arguments.silent EQ false){
                if(ArrayLen(statusStruct.arrMessages) GT 0 or ArrayLen(arrErrors) GT 0){
                    writeoutput('<div style="float:left;width:100%;"><div style=" width:100%; overflow:hidden; display:block; clear:both;  margin-bottom:10px;">');
                }
                if(ArrayLen(statusStruct.arrMessages) GT 0){
                    writeoutput('<div style="display:block; clear:both;float:left; color:##FFFFFF; width:98%; padding:1%; background-color:##990000; font-weight:bold;">Status:</div>');
                    writeoutput('<div style="display:block; clear:both;float:left; color:##000000;width:98%; padding:1%;border-bottom:1px solid ##660000; background-color:##FFFFFF;"><p style="padding-bottom:0px;">'&ArrayToList(statusStruct.arrMessages, '</p><hr /><p style="padding-bottom:0px;">')&'</p></div>');
                    if(ArrayLen(arrErrors) GT 0){
                        writeoutput('');
                    }
                }
                if(ArrayLen(arrErrors) GT 0){
                    writeoutput('<div style="display:block; clear:both;float:left; color:##FFFFFF; width:98%; padding:1%; font-weight:bold; background-color:##993333;">The following errors occurred:</div>');
                    writeoutput('<div style="display:block; clear:both;float:left; color:##000000; width:98%; padding:1%;border-bottom:1px solid ##660000; background-color:##FFFFFF;"><p style="padding-bottom:0px;">'&ArrayToList(arrErrors, '</p><hr /><p style="padding-bottom:0px;">')&'</p></div>');
                }
                if(ArrayLen(statusStruct.arrMessages) GT 0 or ArrayLen(arrErrors) GT 0){
                    writeoutput('</div></div><br style="clear:both;" />');
                }
            }
        }
        </cfscript>
    </cffunction>


    <cffunction name="displayReturnJson" localmode="modern" access="public" returntype="any" output="true">
        <cfargument name="id" type="string" required="yes">
    	<cfscript>
		savecontent variable="errorHTML"{
			statusStruct=application.zcore.status.display(arguments.id);
		}
		application.zcore.functions.zReturnJson({success:false, errorMessage:errorHTML});
		</cfscript>
	</cffunction>
    
</cfoutput>
</cfcomponent>