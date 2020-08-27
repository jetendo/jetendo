<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	
	application.zcore.functions.checkIfCronJobAllowed();
	pastDate=application.zcore.functions.zAddTimespanToDate(-request.zos.passwordExpirationTimeSpan, now());

	db.sql="SELECT site_id FROM #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and 
	(site_enable_demo_mode=#db.param('1')# or 
	site_require_login=#db.param(1)# ) ";
	qDemo=db.execute("qDemo");
	arrSite=[];
	for(row in qDemo){
		// exclude demo and dev sites from inactive password deletion
		arrayAppend(arrSite, "'"&row.site_id&"'");
	}
	siteIdList=arrayToList(arrSite, ",");
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# 
	SET 
	user_password = #db.param('')#,
	user_created_ip = #db.param('')#, 
	user_updated_ip = #db.param('')#,
	user_key = #db.param('')#,
	user_password = #db.param('')#,
	member_password = #db.param('')#,
	user_last_ip = #db.param('')#,
	user_salt  = #db.param('')#,  
	user_security_question1  = #db.param('')#,  
	user_security_answer1  = #db.param('')#,  
	user_security_question2  = #db.param('')#,  
	user_security_answer2  = #db.param('')#,  
	user_security_question3  = #db.param('')#,  
	user_security_answer3  = #db.param('')# ,
	user_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE ";
	if(arraylen(arrSite)){
		db.sql&=" site_id NOT IN ("&db.trustedSQL(siteIdList)&") and ";
	}
	db.sql&=" user_password <> #db.param('')# and 
	user_updated_datetime <= #db.param(dateformat(pastDate, "yyyy-mm-dd")&" "&timeformat(pastDate, "HH:mm:ss"))# and 
	user_encrypted_key = #db.param('')# and 
	user_deleted = #db.param(0)# and
	site_id <> #db.param(-1)#";
	db.execute("qUpdate");
	writeoutput("Old passwords were expired.");


	db.sql="delete from #db.table("user_token", request.zos.zcoreDatasource)# WHERE 
	user_token_updated_datetime <= #db.param(dateformat(pastDate, "yyyy-mm-dd")&" "&timeformat(pastDate, "HH:mm:ss"))# and 
	user_token_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)#";
	db.execute("qDeleteToken");
	abort;
	</cfscript>
</cffunction>

<cffunction name="deleteOldUserToken" access="remote" localmode="modern">
	<cfscript>
	
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>