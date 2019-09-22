<cfcomponent displayname="Queue Sorting System" hint="Provides an easy way to implement sorting records of a query with a url query string." output="no">
<cfoutput>
 <!--- 
<cfscript>
inputStruct = StructNew();
// required
inputStruct.tableName = "";
inputStruct.sortFieldName = "";
inputStruct.primaryKeyName = "";
// optional
inputStruct.datasource = "";
inputStruct.where = ""; // add additional 
WHERE statement
inputStruct.disableRedirect=false;
queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
queueSortCom.init(inputStruct);
</cfscript>	
  --->
 <cffunction name="init" localmode="modern" returntype="any" output="yes">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	this.datasource = Request.zos.globals.datasource;
	this.tableName = "";
	this.sortFieldName = "";
	this.primaryKeyName = "";
	this.where = "";
	this.sortVarNameAjax="zQueueSortAjax";
	this.sortVarNameAjaxOriginal="zQueueSortAjaxOriginal";
	this.ajaxTableId="";
	this.ajaxURL="";
	this.ajaxCallback="function(){}";
	this.disableRedirect=false;
	variables.rowIndex=0;
	//this.groupBy="";
	this.comName="queueSort.cfc";

	// prepend this var name for query string variable
	this.sortVarName = "zQueueSort";
 
	var ts=0;
	StructAppend(this, arguments.inputStruct, true);
	if(this.ajaxTableId NEQ "" and this.ajaxURL NEQ ""){
		application.zcore.functions.zRequireJqueryUI();
		application.zcore.skin.addDeferredScript("
			zSetupAjaxTableSort('#this.ajaxTableId#', '#this.ajaxURL#', '#this.sortVarNameAjax#', '#this.sortVarNameAjaxOriginal#', #this.ajaxCallback#);
		");
	}
	if(len(this.tableName) EQ 0){
		application.zcore.template.fail("#this.comName#: init: inputStruct.tableName is required",true);
	}
	if(len(this.sortFieldName) EQ 0){
		application.zcore.template.fail("#this.comName#: init: inputStruct.sortFieldName is required",true);
	}
	if(len(this.primaryKeyName) EQ 0){
		application.zcore.template.fail("#this.comName#: init: inputStruct.primaryKeyName is required",true);
	}
	if(structkeyexists(form, this.sortVarNameAjax)){
		arrId=listToArray(form[this.sortVarNameAjax], "|");
		arrOriginalId=listToArray(form[this.sortVarNameAjaxOriginal], "|"); 
		request.zos.queueSortAjaxResult=processAjaxSortChange(arrOriginalId, arrId);
		if(not request.zos.queueSortAjaxResult.success){
			returnJson();
		}
	}else if(structkeyexists(form, this.sortVarName) and structkeyexists(form, this.primaryKeyName)){
		ts = StructNew();
		ts.id = form[this.primaryKeyName];
		this[form[this.sortVarName]](ts);
		if(this.disableRedirect EQ false){
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,this.sortVarName&"=","ztv=","all"));
		}
		return true;
	}else{
		return false;	
	}
	</cfscript>
 </cffunction>

<cffunction name="returnJson" localmode="modern" access="public">
	<cfscript>
	if(structkeyexists(form, this.sortVarNameAjax)){ 
		application.zcore.functions.zReturnJson(request.zos.queueSortAjaxResult);
	}
	</cfscript>
</cffunction>


<cffunction name="getRowStruct" localmode="modern" access="public">
	<cfargument name="primaryKeyId" type="string" required="yes">
	<cfscript>
	variables.rowIndex++;
	variables.primaryKeyId=arguments.primaryKeyId;
	return {id:"#this.ajaxTableId#_row#variables.rowIndex#", primaryKeyId:"#variables.primaryKeyId#"};
	</cfscript>
</cffunction>
	
<cffunction name="getRowHTML" localmode="modern" access="public">
	<cfargument name="primaryKeyId" type="string" required="yes">
	<cfscript>
	variables.rowIndex++;
	variables.primaryKeyId=arguments.primaryKeyId;
	return ' id="#this.ajaxTableId#_row#variables.rowIndex#" data-ztable-sort-primary-key-id="#variables.primaryKeyId#" ';
	</cfscript>
</cffunction>


<cffunction name="getAjaxHandleButton" localmode="modern" access="public">
	<cfargument name="primaryKeyId" type="string" required="yes">
	<cfscript>
	variables.primaryKeyId=arguments.primaryKeyId;
	return '<span class="#this.ajaxTableId#_handle" data-ztable-sort-primary-key-id="#variables.primaryKeyId#" title="Click and drag the arrow up or down to change the sort order." style="font-size:200%;cursor:move;">&##x21C5;</span>';
	</cfscript>
</cffunction>

<cffunction name="processAjaxSortChange" localmode="modern" access="private" returntype="struct">
	<cfargument name="arrOriginalId" type="array" required="yes">
	<cfargument name="arrId" type="array" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrId=arguments.arrId;
	arrOriginalId=arguments.arrOriginalId;

	db.sql="show fields from #db.table(this.tableName, this.datasource)# like #db.param(this.tableName&"_deleted")#";
	qCheck=db.execute("qCheck");

	arrOriginal=[];
	for(i=1;i LTE arraylen(arrOriginalId);i++){
		arrayAppend(arrOriginal, application.zcore.functions.zescape(arrOriginalId[i]));
	}
	db.sql="SELECT `#this.primaryKeyName#` id FROM #db.table(this.tableName, this.datasource)# #this.tablename# 
	WHERE #db.param(1)# = #db.param(1)# ";// `#this.primaryKeyName#` IN (#db.trustedSQL("'"&arrayToList(arrOriginal, "','")&"'")#)";
	if(qCheck.recordcount NEQ 0){
		db.sql&=" and `#this.tableName#_deleted`=#db.param(0)#";
	}
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	db.sql&=" ORDER BY `#this.sortFieldName#` asc";
	qSort=db.execute("qSort");

	if(not structkeyexists(form, "zDisableSortValidation")){
		if(qSort.recordcount NEQ arraylen(arrOriginalId)){
			return {success:false, errorMessage:"Sort cancelled. Data has changed. Please refresh and try again."};
		}
		arrOldSort=[];
		for(row in qSort){
			arrayAppend(arrOldSort, row.id);
		}
		if(compare(arrayToList(arrOldSort, ","), arrayTOList(arrOriginalId, ",")) NEQ 0){
			if(request.zos.istestserver){
				return {success:false, errorMessage:"Sort cancelled. Sort order has changed. Please refresh and try again."&chr(10)&"old:"&arrayToList(arrOldSort, ",")&chr(10)&"new:"&arrayTOList(arrOriginalId, ",")};
			}else{
				return {success:false, errorMessage:"Sort cancelled. Sort order has changed. Please refresh and try again." };//&chr(10)&arrayToList(arrOldSort, ",")&chr(10)&arrayTOList(arrOriginalId, ",")&chr(10)&out};
			}
		}
	}
	transaction action="begin"{
		try{
			for(i=1;i LTE arraylen(arrId);i++){
				id=arrId[i]; 
				db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
				SET `#this.sortFieldName#` = #db.param(i)#
				WHERE  `#this.primaryKeyName#` = #db.param(id)#";
				if(qCheck.recordcount NEQ 0){
					db.sql&=" and `#this.tableName#_deleted`=#db.param(0)#";
				}
				if(len(this.where) NEQ 0){
					db.sql&=" and #db.trustedSQL(this.where)#";
				}
				qSortUpdate=db.execute("qSortUpdate");
				//, `#this.tablename#_updated_datetime` = #db.param(request.zos.mysqlnow)# 
			}
			transaction action="commit";
		}catch(Any e2){
			// transaction failed.
			try{
				transaction action="rollback";
			}catch(Any e3){
				// ignore rollback failures
			}
			rethrow;
		}
	}
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="moveTop" localmode="modern" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var qLock = "";
	var qUpdate = "";
	var db=request.zos.queryObject;
	var qSelect = "";
	var newsort = 2;
	
	db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
	SET `#this.sortFieldName#` = #db.param(1)#
	WHERE `#this.primaryKeyName#` = #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qUpdate=db.execute("qUpdate");
	// ,	#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
	db.sql="SELECT `#this.primaryKeyName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.primaryKeyName#` <> #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	db.sql&=" ORDER BY `#this.sortFieldName#` ASC";
	qSelect=db.execute("qSelect");
	newsort = 2;
	for(local.row in qSelect){
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
		SET `#this.sortFieldName#` = #db.param(newsort)#
		WHERE `#this.primaryKeyName#` = #db.param(local.row[this.primaryKeyName])#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		// ,#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		newsort = newsort+1;
	}
	</cfscript>
</cffunction>




<cffunction name="moveBottom" localmode="modern" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var qLock = "";
	var qUpdate = "";
	var db=request.zos.queryObject;
	
	var qSelect = "";
	db.sql="SELECT count(`#this.primaryKeyName#`) as count 
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#";
	if(len(this.where) NEQ 0){
		db.sql&=" WHERE #db.trustedSQL(this.where)#";
	}
	qSelect=db.execute("qSelect");
	db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
	SET `#this.sortFieldName#` = #db.param(qSelect.count)#
	WHERE `#this.primaryKeyName#` = #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qUpdate=db.execute("qUpdate");
	// ,#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
	db.sql="SELECT `#this.primaryKeyName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.primaryKeyName#` <> #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	db.sql&="ORDER BY `#this.sortFieldName#` ASC";
	qSelect=db.execute("qSelect");
	local.i=1;
	for(local.row in qSelect){
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
		SET `#this.sortFieldName#` = #db.param(local.i)#
		WHERE `#this.primaryKeyName#` = #db.param(local.row[this.primaryKeyName])#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		// ,		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		local.i++;
	}
	</cfscript>
</cffunction>

<cffunction name="moveUp" localmode="modern" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	var qLock = "";
	var qUpdate = "";
	
	var db=request.zos.queryObject;
	var qSelect = "";
	var qCurrent = "";
	var newsort = 2;
	db.sql="SELECT `#this.sortFieldName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.primaryKeyName#` = #db.param(arguments.id)# ";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qCurrent=db.execute("qCurrent");
	if(qCurrent.recordcount NEQ 0 and qCurrent[this.sortFieldName] EQ 0){
		variables.fixZeroSortValues();
		db.sql="SELECT `#this.sortFieldName#`
		FROM #db.table(this.tableName, this.datasource)# #this.tablename#
		WHERE `#this.primaryKeyName#` = #db.param(arguments.id)# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qCurrent=db.execute("qCurrent");
	}
	if(qCurrent[this.sortFieldName][1] NEQ 1){
		db.sql="SELECT `#this.primaryKeyName#`
		FROM #db.table(this.tableName, this.datasource)# #this.tablename#
		WHERE `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1]-1)#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qSelect=db.execute("qSelect");
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
		SET `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1]-1)#
		WHERE `#this.primaryKeyName#` = #db.param(arguments.id)#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		// ,	#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
		SET `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1])#
		WHERE `#this.primaryKeyName#` = #db.param(qSelect[this.primaryKeyName][1])#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		// ,		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
	}
	</cfscript>
</cffunction>


<cffunction name="fixZeroSortValues" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select max(`#this.sortFieldName#`) maxSort from #db.table(this.tableName, this.datasource)# ";
	if(len(this.where) NEQ 0){
		db.sql&=" WHERE #db.trustedSQL(this.where)#";
	}
	local.qMax=db.execute("qMax");
	db.sql="select `#this.primaryKeyName#` id, `#this.sortFieldName#` sort from #db.table(this.tableName, this.datasource)# ";
	if(len(this.where) NEQ 0){
		db.sql&=" WHERE #db.trustedSQL(this.where)#";
	}
	db.sql&=" ORDER BY `#this.sortFieldName#` asc";
	local.qAll=db.execute("qAll");
	local.i=local.qMax.maxSort+1;
	for(local.row in local.qAll){
		if(local.row.sort EQ 0){
			db.sql="update #db.table(this.tableName, this.datasource)# set 
			 `#this.sortFieldName#` = #db.param(local.i)# ,
			#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
			 WHERE  `#this.primaryKeyName#` = #db.param(local.row.id)#";
			if(len(this.where) NEQ 0){
				db.sql&=" and #db.trustedSQL(this.where)#";
			}
			db.execute("qFix");
			local.i++;	
		}
	}
	</cfscript>
</cffunction>

<cffunction name="moveDown" localmode="modern" returntype="any" output="false">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	
	var qLock = "";
	var qUpdate = "";
	var qSelect = "";
	var qCurrent = "";
	var db=request.zos.queryObject;
	var newsort = 2;
	db.sql="SELECT `#this.sortFieldName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.primaryKeyName#` = #db.param(arguments.id)# ";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qCurrent=db.execute("qCurrent");
	if(qCurrent.recordcount NEQ 0 and qCurrent[this.sortFieldName] EQ 0){
		variables.fixZeroSortValues();
		db.sql="SELECT `#this.sortFieldName#`
		FROM #db.table(this.tableName, this.datasource)# #this.tablename#
		WHERE `#this.primaryKeyName#` = #db.param(arguments.id)# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qCurrent=db.execute("qCurrent");
	}
	db.sql="SELECT `#this.primaryKeyName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1]+1)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qSelect=db.execute("qSelect");
	if(qSelect.recordcount NEQ 0){
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
		SET `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1]+1)#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE `#this.primaryKeyName#` = #db.param(arguments.id)# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename#
		SET `#this.sortFieldName#` = #db.param(qCurrent[this.sortFieldName][1])#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE `#this.primaryKeyName#` = #db.param(qSelect[this.primaryKeyName][1])# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		
	}
	</cfscript>
</cffunction>

<!--- queueSortCom.moveTo(id, position); --->
<cffunction name="moveTo" localmode="modern" returntype="any" output="true">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="position" type="string" required="yes">
	<cfscript>
	
	var qLock = "";
	var qUpdate = "";
	var qSelect = "";
	var db=request.zos.queryObject;
	var newPosition = 1;
	if(isNumeric(arguments.position) EQ false){
		return false;
	}
	if(arguments.position LTE 0){
		arguments.position = 1;
	}
	db.sql="SELECT count(`#this.primaryKeyName#`) as count 
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qSelect=db.execute("qSelect");
	if(qSelect.count LT arguments.position){
		arguments.position = qSelect.count;
	}
	db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
	SET `#this.sortFieldName#` = #db.param(arguments.position)#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE `#this.primaryKeyName#` = #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	qUpdate=db.execute("qUpdate");
	db.sql="SELECT `#this.primaryKeyName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#
	WHERE `#this.primaryKeyName#` <> #db.param(arguments.id)#";
	if(len(this.where) NEQ 0){
		db.sql&=" and #db.trustedSQL(this.where)#";
	}
	db.sql&=" ORDER BY `#this.sortFieldName#` ASC";
	qSelect=db.execute("qSelect");
	local.i=1;
	for(local.row in qSelect){
		if(qSelect.currentRow GTE arguments.position){
			newPosition = local.i+1;
		}else{
			newPosition =local.i;
		}
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
		SET `#this.sortFieldName#` = #db.param(newPosition)#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE `#this.primaryKeyName#` = #db.param(local.row[this.primaryKeyName])#";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		qUpdate=db.execute("qUpdate");
		local.i++;
	}
	</cfscript>
</cffunction>

<!--- on delete queueSortCom.sortAll(); --->
<cffunction name="sortAll" localmode="modern" returntype="any" output="false">
	<cfscript>
	
	var qLock = "";
	var db=request.zos.queryObject;
	var qSelect = "";
	db.sql="SELECT `#this.primaryKeyName#`, `#this.sortFieldName#`
	FROM #db.table(this.tableName, this.datasource)# #this.tablename#";
	if(len(this.where) NEQ 0){
		db.sql&=" WHERE #db.trustedSQL(this.where)#";
	}
	db.sql&="ORDER BY `#this.sortFieldName#` ASC";
	qSelect=db.execute("qSelect");
	local.i=1;
	local.zeroStruct={};
	for(local.row in qSelect){
		if(local.row[this.sortFieldName] EQ 0){
			local.zeroStruct[local.row[this.primaryKeyName]]=true;
			continue;
		}
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
		SET `#this.sortFieldName#` = #db.param(local.i)#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE `#this.primaryKeyName#` = #db.param(local.row[this.primaryKeyName])# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		db.execute("qUpdate");
		local.i++;
	}
	for(local.n in local.zeroStruct){
		db.sql="UPDATE #db.table(this.tableName, this.datasource)# #this.tablename# 
		SET `#this.sortFieldName#` = #db.param(local.i)#,
		#this.tablename#_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE `#this.primaryKeyName#` = #db.param(local.n)# ";
		if(len(this.where) NEQ 0){
			db.sql&=" and #db.trustedSQL(this.where)#";
		}
		db.execute("qUpdate");
		local.i++;
	}
	</cfscript>
</cffunction>


<cffunction name="getAjaxLink" localmode="modern" returntype="any">
	<cfscript>
	return application.zcore.functions.zURLAppend(arguments.prependURL, this.sortVarNameAjax&'=');
	</cfscript>
</cffunction>
	
<!--- queueSortCom.getLinks(recordcount, currentrow, prependURL, outputDefaultLinks); --->
<cffunction name="getLinks" localmode="modern" returntype="any" output="true">
	<cfargument name="recordcount" type="numeric" required="yes">
	<cfargument name="currentRow" type="numeric" required="yes">
	<cfargument name="prependURL" type="string" required="no" default="#request.cgi_script_name#">
	<cfargument name="outputDefaultLinks" type="any" required="no" default="#false#">		
	<cfscript>
	var tempStruct = StructNew();
	var icondomain="/z";
	if(arguments.currentRow EQ 1){
		tempStruct.moveTop = '';
		tempStruct.moveUp = '';		
	}else{
		tempStruct.moveTop = application.zcore.functions.zURLAppend(arguments.prependURL, this.sortVarName&'=moveTop');
		tempStruct.moveUp = application.zcore.functions.zURLAppend(arguments.prependURL, this.sortVarName&'=moveUp');
	}
	if(arguments.currentRow EQ arguments.recordcount){
		tempStruct.moveDown = '';
		tempStruct.moveBottom = '';
	}else{
		tempStruct.moveDown = application.zcore.functions.zURLAppend(arguments.prependURL, this.sortVarName&'=moveDown');
		tempStruct.moveBottom = application.zcore.functions.zURLAppend(arguments.prependURL, this.sortVarName&'=moveBottom');
	}
	if(arguments.outputDefaultLinks EQ true){
		if(tempStruct.moveTop NEQ ''){
			writeoutput('<a href="#tempStruct.moveTop#">|&lt;</a> ');
		}else{
			writeoutput('&nbsp;&nbsp;&nbsp;&nbsp;');
		}
		if(tempStruct.moveUp NEQ ''){
			writeoutput('<a href="#tempStruct.moveUp#">&lt;</a> ');
		}else{
			writeoutput('&nbsp;&nbsp;&nbsp;&nbsp;');
		}
		if(tempStruct.moveDown NEQ ''){
			writeoutput('<a href="#tempStruct.moveDown#">&gt;</a> ');
		}else{
			writeoutput('&nbsp;&nbsp;&nbsp;&nbsp;');
		}
		if(tempStruct.moveBottom NEQ ''){
			writeoutput('<a href="#tempStruct.moveBottom#">&gt;|</a> ');
		}else{
			writeoutput('&nbsp;&nbsp;&nbsp;&nbsp;');
		}
	}else if(arguments.outputDefaultLinks EQ "vertical-arrows"){
		if(tempStruct.moveTop NEQ ''){
			writeoutput('<a href="#tempStruct.moveTop#"><img src="#icondomain#/images/icons/sort-arrow-top.gif" width="11" height="9"></a> ');
		}else{
			writeoutput('<img src="#icondomain#/images/icons/sort-arrow-blank.gif" width="11" height="9"> ');
		}
		if(tempStruct.moveUp NEQ ''){
			writeoutput('<a href="#tempStruct.moveUp#"><img src="#icondomain#/images/icons/sort-arrow-up.gif" width="11" height="9"></a> ');
		}else{
			writeoutput('<img src="#icondomain#/images/icons/sort-arrow-blank.gif" width="11" height="9"> ');
		}
		if(tempStruct.moveDown NEQ ''){
			writeoutput('<a href="#tempStruct.moveDown#"><img src="#icondomain#/images/icons/sort-arrow-down.gif" width="11" height="9"></a> ');
		}else{
			writeoutput('<img src="#icondomain#/images/icons/sort-arrow-blank.gif" width="11" height="9"> ');
		}
		if(tempStruct.moveBottom NEQ ''){
			writeoutput('<a href="#tempStruct.moveBottom#"><img src="#icondomain#/images/icons/sort-arrow-bottom.gif" width="11" height="9"></a> ');
		}else{
			writeoutput('<img src="#icondomain#/images/icons/sort-arrow-blank.gif" width="11" height="9"> ');
		}
	}else{
		return tempStruct;
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>