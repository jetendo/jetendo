<cfcomponent>
<cfoutput>
<!--- All the functions in this component are incomplete and/or not tested --->

	<!--- 
	siteIDType has not been implemented on these tables, which makes them unsafe to use on multiple sites currently.
	-----------
	zemail_folder
	zemail_template_type
	MAYBE DONE: zemail_template
	zemail_list
	----------- 
	
	<cfscript>
	request.zos.emailData.email_account_id=false;
	request.zos.emailData.zemail_account_id=false;
	request.zos.emailData.sitePath='/e/attachments/';
	request.zos.emailData.from='';
	request.zos.emailData.absPath=request.zos.globals.serverhomedir&'static/e/attachments/';
	//this.init();
	</cfscript> --->
	<!--- <cffunction name="init" localmode="modern" output="no" returntype="any">
		<cfscript>
		if(structkeyexists(this, 'initOnce') EQ false){
			this.initOnce=true;
			request.zos.emailData.absPath=request.zos.globals.serverhomedir&'static/e/attachments/';
			request.zos.emailData.popserver=request.zos.globals.emailpopserver;
			request.zos.emailData.username=request.zos.globals.emailusername;
			request.zos.emailData.password=request.zos.globals.emailpassword;
			request.zos.emailData.defaultOfficeEmail=application.zcore.functions.zvarso('zofficeemail');
			if(request.zos.globals.emailCampaignFrom NEQ ""){
				request.zos.emailData.defaultfromemail=request.zos.globals.emailCampaignFrom;
				if(len(request.zos.emailData.defaultOfficeEmail) EQ 0){
					request.zos.emailData.defaultOfficeEmail	= request.zos.emailData.defaultfromemail;
				}
			}else{
				if(len(request.zos.emailData.defaultOfficeEmail)){
					request.zos.emailData.defaultfromemail=request.zos.emailData.defaultOfficeEmail;
				}else{
					request.zos.emailData.defaultfromemail=request.zos.developerEmailFrom;
				}
			}
		}
		</cfscript>
	</cffunction> --->


<!--- 
ts=StructNew();
// required
ts.string="test";
eCom.search(ts);
 --->
<cffunction name="search" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	
	var rs=StructNew();
	var ns=StructNew();
	var db=request.zos.queryObject;
	var qsearch="";
	var qsearchcount="";
	StructAppend(arguments.ss,ns,false);
	arguments.ss.string=application.zcore.functions.zCleanSearchText(arguments.ss.string);
	if(len(arguments.ss.string) LTE 2){
		rs.success=false;
		rs.count=0;
		rs.error="The search string must be 3 or more characters.";
		return rs;
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT count(zemail_id) as count
	FROM #db.table("zemail_data", request.zos.zcoreDatasource)# zemail_data WHERE 
	 <cfif application.zcore.enableFullTextIndex>
	 zemail_data_search like #db.param(arguments.ss.string)# 
	 <cfelse>
	 MATCH(zemail_data_search) AGAINST (#db.param(arguments.ss.string)#) or 
	 MATCH(zemail_data_search) AGAINST (#db.trustedSQL('+#replace(application.zcore.functions.zescape(arguments.ss.string),' ','* +','ALL')#*')# IN BOOLEAN MODE) 
	 </cfif>
	 ) and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_id = #db.param(request.zsession.user.id)# and 
	zemail_data_deleted = #db.param(0)# 
	</cfsavecontent><cfscript>qSearchCount=db.execute("qSearchCount");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT *
	
	 <cfif application.zcore.enableFullTextIndex>, 
	MATCH(zemail_data_search) AGAINST (#db.param(arguments.ss.string)#) as score 
	</cfif>
	FROM #db.table("zemail_data", request.zos.zcoreDatasource)# zemail_data WHERE 
	 <cfif application.zcore.enableFullTextIndex>
	 zemail_data_search like #db.param(arguments.ss.string)# 
	 <cfelse>
	 MATCH(zemail_data_search) AGAINST (#db.param(arguments.ss.string)#) or 
	 MATCH(zemail_data_search) AGAINST (#db.trustedSQL('+#replace(application.zcore.functions.zescape(arguments.ss.string),' ','* +','ALL')#*')# IN BOOLEAN MODE) 
	 </cfif>
	 ) and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_id = #db.param(request.zsession.user.id)# and 
	zemail_data_deleted = #db.param(0)# 
	 <cfif application.zcore.enableFullTextIndex>
	ORDER BY score DESC 
	</cfif>
	</cfsavecontent><cfscript>qSearch=db.execute("qSearch");
	rs.count=qsearchcount.count;
	rs.query=qsearch;
	rs.success=true;
	return rs;
	</cfscript>		
</cffunction>

<!--- 
eCom.delete(zemail_id);
--->
<cffunction name="delete" localmode="modern" returntype="any" output="yes">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	var newFileName=0;
	var qd=0;
	var qC="";
	var qC2="";
	var path=request.zos.globals.serverhomedir&'static/e/attachments/';
	var np=application.zcore.functions.zGetHashPath(path,arguments.id);
	var domainpath=request.zos.emailData.sitePath&replace(np,request.zos.emailData.absPath,"","ONE");
	if(this.zemail_account_id EQ false){
		application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: delete() - you must call this.setAccount() before using this function.");
	}
	</cfscript>
	<cflock name="zcorerootmapping.com.app.email.cfc:delete:#request.zsession.user.id#:#request.zos.emailData.popserver#:#request.zos.emailData.username#" timeout="300" type="exclusive">
	<!--- query to check if downloaded --->
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail", request.zos.zcoreDatasource)# zemail 
	WHERE zemail_id =#db.param(arguments.id)# and 
	zemail_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_id = #db.param(request.zsession.user.id)#
	</cfsavecontent><cfscript>qC=db.execute("qC");
	if(qC.recordcount EQ 0){
		return false;
	}
	newFileName=lcase(hash(qC.zemail_uid))&'-'&arguments.id&'-';
	</cfscript>
	<cfif qC.zemail_processed EQ 1>
		<cfdirectory name="qD" filter="#newFileName#*-#qC.zemail_rename_number#.*" directory="#np#" action="list">
		<cfloop query="qD">
			<cfscript>
			application.zcore.functions.zDeleteFile(np&name);
			</cfscript>
		</cfloop>
		<cfscript>
		application.zcore.functions.zDeleteFile(np&newFileName&qc.zemail_rename_number&'-original.ini');
		application.zcore.functions.zDeleteFile(np&newFileName&qc.zemail_rename_number&'-html.ini');
		application.zcore.functions.zDeleteFile(np&newFileName&qc.zemail_rename_number&'-text.ini');
		</cfscript>
	</cfif>
	<cftry>
	   <CFPOP
		ACTION="Delete" 
		uid="#qC.zemail_uid#"
		SERVER="#request.zos.emailData.popserver#"
		USERNAME="#request.zos.emailData.username#"
		PASSWORD="#request.zos.emailData.password#" 
		timeout="10">
		<cfcatch type="any">
		<!--- ignore delete errors --->
		</cfcatch>
	</cftry>
	<cfsavecontent variable="db.sql">
	DELETE FROM #db.table("zemail", request.zos.zcoreDatasource)#  
	WHERE zemail_id = #db.param(arguments.id)# and 
	zemail_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_id = #db.param(request.zsession.user.id)#
	</cfsavecontent><cfscript>qC=db.execute("qC");</cfscript>
	<cfsavecontent variable="db.sql">
	DELETE FROM #db.table("zemail_data", request.zos.zcoreDatasource)#  
	WHERE zemail_id = #db.param(arguments.id)# and 
	zemail_data_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_id = #db.param(request.zsession.user.id)#
	</cfsavecontent><cfscript>qC=db.execute("qC");</cfscript>
	<cfreturn true>
	</cflock>
</cffunction>  

<!--- 
eCom.getEmail(query);
eCom.getEmail(query,queryRowNumber);
eCom.getEmail(query,queryRowNumber,original);
 --->
<cffunction name="getEmail" localmode="modern" returntype="struct" output="no">
	<cfargument name="q" type="query" required="yes">
	<cfargument name="row" type="numeric" required="no" default="1">
	<cfargument name="original" type="boolean" required="no" default="#false#">
	<cfscript>
	var arrA='';
	
	var db=request.zos.queryObject;
	var i='';
	var ext='';
	var fileName='';
	var ts='';
	var qemail2="";
	var np=application.zcore.functions.zGetHashPath(request.zos.emailData.absPath,arguments.q.zemail_id[arguments.row]);
	var domainpath=request.zos.emailData.sitePath&replace(np,request.zos.emailData.absPath,"","ONE");
	var newFileName=lcase(hash(arguments.q.zemail_uid[arguments.row]))&'-'&arguments.q.zemail_id[arguments.row]&'-';
	var rs=structnew();
	rs.arrAttachments=arraynew(1);
	rs.html=application.zcore.functions.zReadFile(np&newFileName&arguments.q.zemail_rename_number[arguments.row]&'-html.ini');
	rs.text=application.zcore.functions.zReadFile(np&newFileName&arguments.q.zemail_rename_number[arguments.row]&'-text.ini');
	if(arguments.original){
		rs.original=application.zcore.functions.zReadFile(np&newFileName&arguments.q.zemail_rename_number[arguments.row]&'-original.ini');
	}
	</cfscript>
	<cfif arguments.q.zemail_attachment_count[arguments.row] NEQ 0>
		<cfsavecontent variable="db.sql">
		SELECT zemail_data_attachments 
		FROM #db.table("zemail_data", request.zos.zcoreDatasource)# zemail_data 
		WHERE zemail_id = #db.param(arguments.q.zemail_id[arguments.row])# and 
		zemail_data_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		user_id = #db.param(request.zsession.user.id)#
		</cfsavecontent><cfscript>qEmail2=db.execute("qEmail2");</cfscript>
		<cfif qEmail2.recordcount NEQ 0>
			<cfscript>
			arrA=listtoarray(qemail2.zemail_data_attachments,chr(9));
			for(i=1;i LTE arraylen(arrA);i++){
				ts=StructNew();
				ext=application.zcore.functions.zGetFileExt(arrA[i]);
				fileName=newFileName&i&'-'&arguments.q.zemail_rename_number[arguments.row];
				if(ext NEQ ''){
					fileName=fileName&'.'&ext;
				}
				ts.siteFilePath=domainpath&fileName;
				ts.absFilePath=np&fileName;
				ts.originalFileName=arrA[i];
				arrayappend(rs.arrAttachments, ts);
			}
			</cfscript>
		</cfif>
	</cfif>
	<cfreturn rs>
</cffunction>

<!--- 
ts=StructNew();
// optional
//ts.id='';
//ts.daysBeforeDelete=3;
eCom.pop(ts);
--->
<cffunction localmode="modern" name = "pop" returnType = "struct" output="yes" displayName = "pop" >
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>		
	
	var checkList='';
	var tmpPath='';
	var messageCount='';
	var zemail_id='';
	var twoWeeksAgo='';
	var msgDate='';
	var ts='';
	var fromNameArr='';
	var fromName='';
	var fromNameLen='';
	var fromEmailLen='';
	var inputStruct='';
	var tmpHtmlBody='';
	var np='';
	var domainpath='';
	var newFileName='';
	var arrFileNames='';
	var arrAttachPath='';
	var arrTA='';
	var arrCA='';
	var i='';
	var curC='';
	var ext='';
	var p2='';
	var renaming='';
	var res='';
	var arrDelete='';
	var qEmail='';
	var db=request.zos.queryObject;
	var qC='';
	var arrHashPath=arraynew(1);
	var uidStruct=StructNew();
	var deleteStruct=StructNew();
	var newMailCount=0;
	var emailIdStruct=StructNew();
	var uidList="";
	var arrEmailId=arraynew(1);
	var rs=StructNew();
	var ns=StructNew();
	ns.id='';
	ns.daysBeforeDelete=3;
	StructAppend(arguments.ss,ns,false);
	if(this.zemail_account_id EQ false){
		application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - you must call this.setAccount() before using this function.");
	}
	rs.count=0;
	rs.success=true;
	zemail_id=false;
	</cfscript>
	<!--- do a named lock for this specific connection so it can't have 2 threads running at the same time on the same email account.  5 minute timeout --->
	<cflock name="zcorerootmapping.com.app.email.cfc:pop:#request.zsession.user.id#:#request.zos.emailData.popserver#:#request.zos.emailData.username#" timeout="300" type="exclusive">
	<!--- get headers so we can check what has already been downloaded --->
	<cfif arguments.ss.id NEQ ''>
		<cfsavecontent variable="db.sql">
		SELECT * FROM 
		#db.table("zemail", request.zos.zcoreDatasource)# zemail 
		WHERE zemail_id =#db.param(arguments.ss.id)# and 
		zemail_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		user_id = #db.param(request.zsession.user.id)#
		</cfsavecontent><cfscript>qEmail=db.execute("qEmail");
		if(qEmail.recordcount EQ 0){
			rs.success=false;
			rs.error="zemail_id, #arguments.ss.id#, doesn't exist.";
			return rs;
		}else if(qEmail.zemail_processed EQ 1){
			rs=this.getEmail(qemail);
			rs.success=true;
			rs.count=1;
			rs.query=qEmail;
			return rs;
		}
		arrayappend(arrEmailId,arguments.ss.id);
		uidList=qemail.zemail_uid;
		deleteStruct[qemail.zemail_uid]=false;//arguments.ss.id;
		emailIdStruct[qemail.zemail_uid]=arguments.ss.id;
		</cfscript>
	<cfelse>
		<cftry>
			<CFPOP
			ACTION="GetHeaderOnly"
			NAME="qHeader"
			SERVER="#request.zos.emailData.popserver#"
			USERNAME="#request.zos.emailData.username#"
			PASSWORD="#request.zos.emailData.password#" 
			timeout="30">
			<cfscript> 
			twoWeeksAgo=dateadd("d",-abs(arguments.ss.daysBeforeDelete),now());
			</cfscript>
			<cfif qHeader.recordcount EQ 0>
				<cfscript>
				return rs; // no new email
				</cfscript>
			</cfif>
			<!--- store only uid and check if dates are older then 2 weeks so they will be deleted --->
			<cfloop query="qHeader">
				<cfscript>
				uidStruct[uid]=true;
				if(datecompare(twoWeeksAgo, ParseDateTime(date, "POP")) EQ 1){
					deleteStruct[uid]=false;
				}
				</cfscript>
			</cfloop>
			<!--- check zemail that we don't already have the email --->
			<cfset checkList="'"&structkeylist(uidStruct,"','")&"'">
			<cfsavecontent variable="db.sql">
			SELECT zemail_id,zemail_uid,zemail_processed 
			FROM #db.table("zemail", request.zos.zcoreDatasource)# zemail 
			WHERE zemail_uid IN (#db.trustedSQL(checkList)#) and 
			zemail_deleted = #db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			user_id = #db.param(request.zsession.user.id)#
			</cfsavecontent><cfscript>qC=db.execute("qC");</cfscript>
			<cfloop query="qC">
				<cfscript>
				if(structkeyexists(deleteStruct,zemail_uid) EQ false){
					structdelete(uidStruct,zemail_uid);
				}
				emailIdStruct[zemail_uid]=zemail_id;
				if(zemail_processed EQ '1'){
					deleteStruct[zemail_uid]=true;
				}
				</cfscript>
			</cfloop>
			<cfloop query="qHeader">
			<cfscript>
			if(structkeyexists(emailIdStruct,uid) EQ false and structkeyexists(uidStruct,uid)){
				msgDate = ParseDateTime(date, "POP");
				ts = structnew();
				ts.zemail_datetime=DateFormat(msgDate,'yyyy-mm-dd')&' '&TimeFormat(msgDate,'HH:mm:ss');
				ts.zemail_subject = subject;
				ts.zemail_replyto = replyto;
				ts.zemail_cc = cc;
				ts.zemail_to = to;
				ts.zemail_uid = uid;
				ts.zemail_account_id=request.zos.emailData.zemail_account_id;
				
				ts.zemail_from =from;
				ts.zemail_folder_id = this.getFolder("inbox");
				ts.site_id=request.zos.globals.id;
				ts.user_id=request.zsession.user.id;
				fromNameArr = listtoarray(from, "<");
				fromName = removechars(fromNameArr[1], 1, 1);
				fromNameLen = len(fromName) - 1;
				ts.zemail_from_name = removechars(fromName, fromNameLen, 2);		
				if(arraylen(fromNameArr) gt 1){
					fromEmailLen = len(fromNameArr[2]);
					ts.zemail_from_email = removechars(fromNameArr[2], fromEmailLen, 1);
				   /* if(ts.zemail_from_email eq """system administrator"""){
					ts.zemail_from_name = "";
					}*/
				}else{
					ts.zemail_from_email = fromNameArr[1];
				}
				inputStruct = StructNew();
				inputStruct.table = 'zemail';
				inputStruct.datasource="#request.zos.zcoreDatasource#";
				inputStruct.struct = ts;
				zemail_id = application.zcore.functions.zInsert(inputStruct);
				if(zemail_id EQ false){
					application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - zemail zInsert failed for uid=#uid#");
				}
				ts=StructNew();
				ts.site_id=request.zos.globals.id;
				ts.user_id=request.zsession.user.id;
				ts.zemail_id=zemail_id;
				ts.zemail_data_search=from&' '&to&' '&cc&' '&subject; // concat all searchable fields
				inputStruct = StructNew();
				inputStruct.table = 'zemail_data';
				inputStruct.datasource="#request.zos.zcoreDatasource#";
				inputStruct.struct = ts;
				zemail_id = application.zcore.functions.zInsert(inputStruct);
				if(zemail_id EQ false){
					application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - zemail_data zInsert failed for uid=#uid#");
				}
				//structdelete(uidStruct,uid);
				arrayappend(arrEmailId,zemail_id);
				if(structkeyexists(deleteStruct,uid)){
					//deleteStruct[uid]=zemail_id;
					emailIdStruct[uid]=zemail_id;
				}
				newMailCount++;
			}
			</cfscript>
			</cfloop>
			<cfscript>
			uidList=structkeylist(emailIdStruct);
			</cfscript>
			<cfcatch>
				<!--- mail server or database is unavailable - ignore errors and let user try again later. --->
				<cfscript>
				rs.count=0;
				rs.success=false;
				rs.error="Mail server or database is unavailable - ignore errors and let user try again later.";
				return rs;
				</cfscript>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif uidList NEQ ''>
		<cftry>
		<cfset tmpPath=request.zos.globals.serverhomedir&"static/e/tmp/##"&dateformat(now(),'yyyy-mm-dd')&TimeFormat(now(),'-HH-mm-ss-')&getTickCount()>
		<!--- get all email we don't have yet using structkeylist --->
		<CFPOP
		ACTION="GetAll"
		NAME="qMessage"
		SERVER="#request.zos.emailData.popserver#"
		USERNAME="#request.zos.emailData.username#"
		PASSWORD="#request.zos.emailData.password#"
		uid="#uidList#" 
		ATTACHMENTPATH="#tmpPath#"
		GENERATEUNIQUEFILENAMES="Yes" 
		timeout="60">
		<cfset messageCount=qMessage.recordcount>
		<cfloop query="qMessage">
			<!--- store attachments on filesystem and the emails in database --->
			<cfscript>
			//	if(arguments.ss.id NEQ ''){
			// process and move files to final path after email_id is made
			ts=StructNew();
			ts.zemail_id=emailIdStruct[uid];
			tmpHtmlBody = htmlbody;
			
			// this section builds a new path for the attachment that is secure and unique by combining unique ids and a private hash key and then updates all the paths in the email's html and stores the original file name so they have friendly names when they are downloaded by the user.
			np=application.zcore.functions.zGetHashPath(request.zos.emailData.absPath,ts.zemail_id);
			domainpath=request.zos.emailData.sitePath&replace(np,request.zos.emailData.absPath,"","ONE");
			newFileName=lcase(hash(uid))&'-'&ts.zemail_id&'-';
			ts.zemail_rename_number=0;
			
			if(attachmentfiles NEQ ''){
				arrHashPath=arraynew(1);
				arrFileNames=arraynew(1);
				arrAttachPath = listtoarray(ATTACHMENTFILES, chr(9));
				// seperate cid: embedded files from attached files
				arrTA=arraynew(1);
				arrCA=arraynew(1);
				for(i=1;i LTE arraylen(arrAttachPath);i++){
					fileName=getFileFromPath(arrAttachPath[i]);
					curC="";
					// find the matching cid and process it
					for(n in cids){
						if(cids[n] neq "null" and fileName EQ n){
							curC='cid:'&replace(replace(cids[n], '<', ""), '>', "");
						}
					}
					ns=structnew();
					ns.cid=curC;
					ns.filename=fileName;
					ns.path=arrAttachPath[i];
					if(len(curC) EQ 0){
						arrayappend(arrTA,ns);
					}else{
						arrayappend(arrCA,ns);
					}
				}
				// make sure that non-embedded files are first in the sequence for file naming routine so they can be referenced automatically later.
				for(i=1;i LTE arraylen(arrCA);i++){
					arrayappend(arrTA, arrCA[i]);
				}
				for(i=1;i LTE arraylen(arrTA);i++){
					
					p=newFileName&i;
					ext=application.zcore.functions.zGetFileExt(arrTA[i].fileName);
					p2=p&'-0';
					if(ext NEQ ''){
						p2=p2&"."&ext;
					}
					// replace cids with relative paths
					// make sure file is unique when renamed by looping
					renaming=true;
					while(renaming){
						res=application.zcore.functions.zRenameFile(arrTA[i].path,np&p2);
						if(res EQ true or ts.zemail_rename_number GT 1000){
							renaming=false;
							break;
						}else{
							ts.zemail_rename_number++;
							p2=p&'-'&ts.zemail_rename_number;
							if(ext NEQ ''){
								p2=p2&"."&ext;
							}
						}
					}
					if(arrTA[i].cid NEQ ''){
						tmpHtmlBody = replace(tmpHtmlBody, arrTA[i].cid, domainpath&p2,'all');
					}else{
						// don't store filenames for embedded files
						arrayappend(arrFileNames,arrTA[i].fileName);
					}
					arrayappend(arrHashPath,np&p2);
				}
				ts.zemail_data_attachments = arraytolist(arrFileNames,chr(9));
				ts.zemail_attachment_count=arraylen(arrHashPath);
				// fail when database will truncate data
				if(len(ts.zemail_data_attachments) GT 1000){
					application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - The email for uid=#uid# has way too many attachments. check the email account manually and to resolve: SERVER=""#request.zos.emailData.popserver#"" USERNAME=""#request.zos.emailData.username#"" PASSWORD=""#request.zos.emailData.password#"".");
				}
			}
			// make the html safer
			tmpHtmlBody=this.cleanHTML(tmpHtmlBody);
			
			ts.zemail_processed=1;
			application.zcore.functions.zWriteFile(np&newFileName&ts.zemail_rename_number&'-original.ini',trim(header&chr(10)&chr(10)&htmlbody&chr(10)&chr(10)&textbody));
			application.zcore.functions.zWriteFile(np&newFileName&ts.zemail_rename_number&'-html.ini',trim(tmpHtmlBody));
			application.zcore.functions.zWriteFile(np&newFileName&ts.zemail_rename_number&'-text.ini',trim(textbody));
			
			ts.site_id=request.zos.globals.id;
			ts.user_id=request.zsession.user.id;
			// prepare update
			inputStruct = StructNew();
			inputStruct.table = 'zemail';
			inputStruct.datasource="#request.zos.zcoreDatasource#";
			inputStruct.forceWhereFields = "zemail_id,site_id,user_id";
			inputStruct.struct = ts;
			if(application.zcore.functions.zUpdate(inputStruct) EQ false){
				application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - zemail zUpdate failed for uid=#uid#");
			}
			// concat all searchable fields
			ts.zemail_data_search=from&' '&to&' '&cc&' '&subject&' ';
			if(trim(textbody) EQ ''){
				ts.zemail_data_search&=tmphtmlbody;
			}else{
				ts.zemail_data_search&=textbody;
			}
			ts.zemail_data_search=application.zcore.functions.zCleanSearchText(ts.zemail_data_search);
			
			// remove all special characters, white space, 
			// clean the text  
			//ts.zemail_search_text=this.zCleanTextForSearch();
			
			// prepare update
			inputStruct = StructNew();
			inputStruct.table = 'zemail_data';
			inputStruct.datasource="#request.zos.zcoreDatasource#";
			inputStruct.forceWhereFields = "zemail_id,site_id,user_id";
			inputStruct.struct = ts;
			if(application.zcore.functions.zUpdate(inputStruct) EQ false){
				application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: pop() - zemail_data zUpdate failed for uid=#uid#");
			}
			if(structkeyexists(deleteStruct,uid)){
				deleteStruct[uid]=true;
			}
			</cfscript>
		</cfloop>
		<cfcatch type="any">
			<cfscript>
			// delete incomplete files due to the error.
			if(isdefined('arrHashPath')){
				for(i=1;i LTE arraylen(arrHashPath);i++){
					application.zcore.functions.zDeleteFile(arrHashPath[i]);
				}
			}
			if(zemail_id NEQ false){
				db.sql="DELETE FROM #db.table("zemail", request.zos.zcoreDatasource)#  
				WHERE zemail_id = #db.param(zemail_id)# and 
				zemail_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				user_id = #db.param(request.zsession.user.id)#";
				db.execute("q");
				db.sql="DELETE FROM #db.table("zemail_data", request.zos.zcoreDatasource)#  
				WHERE zemail_id = #db.param(zemail_id)# and 
				zemail_data_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				user_id = #db.param(request.zsession.user.id)#";
				db.execute("q");
			}
			</cfscript>
		</cfcatch>
		</cftry>
		<cfscript>
		if(isdefined('messageCount') and messageCount GT 0){
			application.zcore.functions.zDeleteDirectory(tmpPath);
		}
		</cfscript>
	</cfif>
	<cfscript>
	// delete only the emails that were successfully processed
	arrDelete=arraynew(1);
	for(i in deleteStruct){
		if(deleteStruct[i] EQ true){
			arrayappend(arrDelete,i);
		}
	}
	</cfscript>
	<!--- delete old mail --->
	<cfif arraylen(arrDelete) NEQ 0>
		<cftry>
			<CFPOP
			ACTION="Delete" 
			uid="#arraytolist(arrDelete)#"
			SERVER="#request.zos.emailData.popserver#"
			USERNAME="#request.zos.emailData.username#"
			PASSWORD="#request.zos.emailData.password#">
			<cfcatch type="any">
			<!--- ignore delete errors --->
			</cfcatch>
		</cftry>
	</cfif>
	<cfif arguments.ss.id NEQ ''>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("zemail", request.zos.zcoreDatasource)# zemail 
		WHERE zemail_id =#db.param(arguments.ss.id)# and 
		zemail_processed=#db.param('1')# and 
		zemail_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		user_id = #db.param(request.zsession.user.id)#
		</cfsavecontent><cfscript>qEmail=db.execute("qEmail");
		if(qEmail.recordcount EQ 0){
			rs.count=0;
			rs.success=false;
			rs.error="Mail failed to be retrieved.  May have been deleted.";
			return rs;
		}else{
			rs=this.getEmail(qemail);
			rs.success=true;
			rs.count=1;
			rs.query=qEmail;
			return rs;
		}
		</cfscript>
	<cfelse>
		<cfscript>
		rs.count=newMailCount;
		return rs;
		</cfscript>
	</cfif>
	</cflock>
</cffunction>


<!--- 
// build application scope cache and pulls zemail_folder_id from shared memory
eCom.getFolder("inbox");
 --->
<cffunction name="getFolder" localmode="modern" returntype="any" output="no">
	<cfargument name="folderName" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var ts=StructNew();
	var qf="";
	if(structkeyexists(application.sitestruct[request.zos.globals.id],'email') EQ false){
		application.sitestruct[request.zos.globals.id].email=structnew();
	}
	if(structkeyexists(application.sitestruct[request.zos.globals.id].email,'folders')){
		if(structkeyexists(application.sitestruct[request.zos.globals.id].email.folders,arguments.folderName)){
			return application.sitestruct[request.zos.globals.id].email.folders[arguments.folderName];
		}
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_folder", request.zos.zcoreDatasource)# zemail_folder 
	WHERE site_id = #db.param('0')# and 
	zemail_folder_deleted = #db.param(0)# and 
	user_id = #db.param('0')#
	</cfsavecontent><cfscript>qF=db.execute("qF");
	ts=StructNew();
	</cfscript>
	<cfloop query="qF">
	<cfscript>
	ts[qF.zemail_folder_name]=qF.zemail_folder_id;
	</cfscript>
	</cfloop>
	<cfscript>
	if(structkeyexists(ts,arguments.folderName)){
		application.sitestruct[request.zos.globals.id].email.folders=ts;
		return ts[arguments.folderName];
	}else{
		application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: getFolder() - arguments.folderName must be a predefined system folder (i.e. inbox, sent, draft, deleted).");
	}
	</cfscript>
</cffunction>

<!--- 
eCom.setAccount(zemail_account_id);
// optionally override site_id to send mail using a different site's mail server
eCom.setAccount(zemail_account_id, site_id);
 --->
<cffunction name="setAccount" localmode="modern" returntype="any" output="no">
	<cfargument name="zemail_account_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	
	var qAccount="";
	var db=request.zos.queryObject;
	var qsite=0;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("zemail_account", request.zos.zcoreDatasource)# zemail_account 
	WHERE zemail_account_id = #db.param(arguments.zemail_account_id)# and 
	site_id = #db.param(arguments.site_id)# and 
	user_id = #db.param(request.zsession.user.id)# and 
	zemail_account_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qAccount=db.execute("qAccount");
	if(qAccount.recordcount EQ 0){
		application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: setAccount() - the email account, #arguments.zemail_account_id#, doesn't exist or this user doesn't have permission to this account.");
	}
	</cfscript>
	<cfif qAccount.zemail_account_alias EQ 1>
		<!--- must use the site email account login for aliases --->
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site_id = #db.param(arguments.site_id)# and 
		site_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qSite=db.execute("qSite");
		if(qSite.recordcount EQ 0){
			application.zcore.template.fail("COMPONENT: zcorerootmapping.com.app.email.cfc - FUNCTION: setAccount() - site_id, #arguments.site_id#, doesn't exist.");
		}
		request.zos.emailData.popserver=qSite.site_email_popserver;
		request.zos.emailData.username=qSite.site_email_username;
		request.zos.emailData.password=qSite.site_email_password;
		request.zos.emailData.zemail_account_id=arguments.zemail_account_id;
		request.zos.emailData.from='';
		</cfscript>
	<cfelse>
		<cfscript>
		request.zos.emailData.popserver=qaccount.zemail_account_popserver;
		request.zos.emailData.username=qaccount.zemail_account_username;
		request.zos.emailData.password=qaccount.zemail_account_password;
		if(qaccount.zemail_account_name NEQ ''){
			request.zos.emailData.from='"'&this.escapeEmailName(qaccount.zemail_account_name)&'" <'&qaccount.zemail_account_email&'>';
		}else{
			request.zos.emailData.from=qaccount.zemail_account_email;
		}
		request.zos.emailData.zemail_account_id=arguments.zemail_account_id;
		</cfscript>
	</cfif>
</cffunction>


<cffunction name="findParentMessage" localmode="modern" output="yes" returntype="any">
	<cfargument name="sub" type="any" required="yes">
	<cfscript>
	
	</cfscript>
	<!--- remove these lines and search for a message with the same subject --->
Fw: [Fw: Fwd: Fw: (Re: Re: Fw: [Some Stuff])]

	<!--- consider adding a custom header or hidden html so replies are identified automatically. --->
	
	<!--- consider checking part of the message text with database like '%partialtext%' --->
	
	<!--- consider remove all special chars and doing a fulltext search with relevance scoring to see which message is closest. --->
	
	<!--- consider detecting when a previous message is in the body text --->
</cffunction>


<!--- 
text=eCom.displayBody(text);
 --->
<cffunction name="displayBody" localmode="modern" output="no" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="width" type="string" required="no" default="100%">
	<cfscript>
	var theBody="";
	var body=arguments.text;
	var bodyPos=findNoCase("<body",body);
	if(isdefined('request.zos.zEmailDisplayBodyCount') EQ false){
		request.zos.zEmailDisplayBodyCount=0;
	}
	request.zos.zEmailDisplayBodyCount++;
	// javascript setTimeout is used to force internet explorer to resize the iframe correctly when nested in a table. Other browsers don't need it
	// add javascript callback to body onload
	if(bodyPos NEQ 0){
		body=replacenocase(body,"onload=",'onload2=','ALL');
		body=replacenocase(body,"<body", '<body onload="setTimeout(''window.parent.zSetEmailBodyHeight(#request.zos.zEmailDisplayBodyCount#)'',1);" ','ALL');
	}else{
		body='#application.zcore.functions.zHTMLDoctype()#<head><title>Email</title></head><body onload="setTimeout(''window.parent.zSetEmailBodyHeight(#request.zos.zEmailDisplayBodyCount#)'',1);" >'&body&'</body></html>';
	}
	// add inline stylesheet
	body=replace(body,'</head>','<style type="text/css">/* <![CDATA[ */ body,html{ margin:0px; background-color:##FFFFFF; } body,html,table{ font-size:12px; font-family:Arial, Helvetica, sans-serif; line-height:18px; } /* ]]> */</style></head>','ONE');
	// add target="_blank"
	body=rereplacenocase(body,'<(area|a)\s(.*)?\starget\s*=\s*(.*)?>','<\1 \2 target="_blank" z=\3>','ALL');
	</cfscript>
<cfsavecontent variable="theBody"><iframe id="zEmailBody#request.zos.zEmailDisplayBodyCount#" scrolling="no" style="width:#arguments.width#; display:none; border:none;  overflow:auto;" seamless="seamless"></iframe> 
<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
zSetEmailBody(#request.zos.zEmailDisplayBodyCount#,"#replace(jsstringformat(body),"</","<\/","all")#");
});
/* ]]> */
</script></cfsavecontent>
	<cfreturn theBody>
</cffunction>
</cfoutput>
</cfcomponent>