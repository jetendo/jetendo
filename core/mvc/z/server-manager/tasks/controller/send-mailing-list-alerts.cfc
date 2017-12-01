<cfcomponent>
<cfoutput>
<!--- 
To debug call this url on a client domain where you know there was a new blog article after the overrideYesterdayDate you specify in the URL.
/z/server-manager/tasks/send-mailing-list-alerts/send?overrideYesterdayDate=2017-11-27&forceDebug=true
--->
<cffunction name="send" localmode="modern" access="remote" returntype="any">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	if((request.zos.istestserver EQ false or structkeyexists(form, 'forceEmail')) and not structkeyexists(form, 'forceDebug')){
		form.debug=false;
	}else{
		form.debug=true;
	}
	form.site_id=request.zos.globals.id;

	if(structkeyexists(form, 'overrideYesterdayDate')){
		yesterdayDate=dateformat(form.overrideYesterdayDate, "yyyy-mm-dd")&" 00:00:00";
	}else{
		yesterdayDate=dateformat(dateadd("d", -1, now()), "yyyy-mm-dd")&" 00:00:00";
	}
	midnightDate=dateformat(now(), "yyyy-mm-dd")&" 00:00:00";

	
	emailAlertsEnabled=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_email_alerts_enabled', true, 0);
	if(emailAlertsEnabled EQ 0){
		echo("Blog email alerts are not enabled for this site.");
		abort;
	}
	// get all non-event blog articles published and made active yesterday.
	db.sql="select * from #db.table("blog", request.zos.zcoreDatasource)# blog WHERE 
	blog_deleted = #db.param(0)# and
	blog_datetime <#db.param(midnightDate)# and ";
	if(not request.zos.istestserver){
		db.sql&="blog_datetime >=#db.param(yesterdayDate)# and ";
	}else{
		// always pull 1 article on test server for debugging purposes
	}
	db.sql&="blog_datetime <=#db.param(request.zos.mysqlnow)# and 
	blog_status <> #db.param(2)# and 
	blog.site_id = #db.param(form.site_id)# 
	ORDER BY site_id ASC, blog_datetime ASC ";
	if(request.zos.istestserver){
		db.sql&="LIMIT #db.param(0)#, #db.param(2)#";
	}else{
		db.sql&="LIMIT #db.param(0)#, #db.param(10)#;"
	}
	qBlog=db.execute("qBlog");

	// convert record to a real user if possible.
	db.sql="select contact_email, contact_id FROM #db.table("contact", request.zos.zcoreDatasource)#  
	WHERE site_id= #db.param(request.zos.globals.id)# and 
	contact_deleted = #db.param(0)# and 
	contact_parent_id=#db.param(0)# and 
	contact_opt_in = #db.param(1)# ";
	if(form.debug){
		db.sql&=" LIMIT #db.param(1)# ";
	}
	qU=db.execute("qU");
	emailStruct={};
	contactCount=0;
	for(row in qU){
		contactCount++;
		emailStruct[row.contact_email]={
			contact_id:row.contact_id,
			user_id:0,
			user_id_siteIDType:0,
			html:1
		};
	}
	db.sql="select user_username, site_id, user_id, user_pref_html FROM #db.table("user", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	user_pref_email = #db.param(1)# and 
	user_active = #db.param(1)# and 
	user_deleted = #db.param(0)#";
	if(form.debug){
		db.sql&=" LIMIT #db.param(1)# ";
	}
	qU=db.execute("qU");
	userCount=0;
	for(row in qU){
		userCount++;
		emailStruct[row.user_username]={
			contact_id:0,
			user_id:row.user_id,
			user_id_siteIDType:application.zcore.functions.zGetSiteIdType(row.site_id),
			html:row.user_pref_html
		};
	}
	currentSubject=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_email_alert_subject');
	if(currentSubject EQ ""){
		currentSubject=request.zos.globals.shortDomain&" Blog Updates";
	}
	fullArticle=application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionstruct, 'blog_config_email_full_article', true, 0);
	arrPlainOut=[];
	arrOut=[];
	arrayAppend(arrPlainOut, currentSubject&chr(10)&'-----');
	arrayAppend(arrOut, '<h2>'&currentSubject&'</h2>');
	firstArticle=true;
	if(fullArticle EQ 1){
		// full articles
		for(blog in qBlog){
			if(not firstArticle){
				arrayAppend(arrOut, '<hr />');
				arrayAppend(arrPlainOut, '-----');
			}
			firstArticle=false;
			arrayAppend(arrOut, '<h3><a href="#application.zcore.app.getAppCFC("blog").getBlogLinkFromStruct(blog)#" target="_blank">#blog.blog_title#</a></h3>');
			arrayAppend(arrOut, '<p>Posted: #dateformat(blog.blog_datetime, "mmm d, yyyy")# at #timeformat(blog.blog_datetime, "h:mm tt")#</p>');
			arrayAppend(arrOut, blog.blog_story);

			arrayAppend(arrPlainOut, '#blog.blog_title##chr(10)##application.zcore.app.getAppCFC("blog").getBlogLinkFromStruct(blog)#');
			arrayAppend(arrPlainOut, 'Posted: #dateformat(blog.blog_datetime, "mmm d, yyyy")# at #timeformat(blog.blog_datetime, "h:mm tt")#');
			bodyText=rereplace(blog.blog_story,"<[^>]*>"," ","ALL");
			bodyText=wrap(bodyText, 72);
			arrLine=listToArray(bodyText, chr(10));
			for(i=1;i LTE arraylen(arrLine);i++){
				arrLine[i]=trim(arrLine[i]);
			}
			bodyText=arrayToList(arrLine, chr(10));
			arrayAppend(arrPlainOut, bodyText);

		}
	}else{
		// summaries
		for(blog in qBlog){
			if(not firstArticle){
				arrayAppend(arrOut, '<hr />');
				arrayAppend(arrPlainOut, '-----');
			}
			firstArticle=false;
			if(blog.blog_summary NEQ ""){
				summaryLength=0;
				shortSummary=blog.blog_summary;
			}else{
				shortSummary=rereplace(blog.blog_story,"<[^>]*>"," ","ALL");
				summaryLength=len(shortSummary);
				shortSummary=application.zcore.functions.zLimitStringLength(shortSummary,350); 
			}
			shortSummary=wrap(shortSummary, 72);
			arrLine=listToArray(shortSummary, chr(10));
			for(i=1;i LTE arraylen(arrLine);i++){
				arrLine[i]=trim(arrLine[i]);
			}
			shortSummary=arrayToList(arrLine, chr(10));
			link=application.zcore.app.getAppCFC("blog").getBlogLinkFromStruct(blog);
			arrayAppend(arrOut, '<h3><a href="#link#" target="_blank">#blog.blog_title#</a></h3>');
			arrayAppend(arrOut, '<p>Posted: #dateformat(blog.blog_datetime, "mmm d, yyyy")# at #dateformat(blog.blog_datetime, "h:mm tt")#</p>');
			arrayAppend(arrOut, '<p>'&shortSummary);
			if(summaryLength LT len(shortSummary)){
				arrayAppend(arrOut, '... <a href="#link#" target="_blank">Read More</a></p>');
			}else{
				arrayAppend(arrOut, '</p>');
			}

			arrayAppend(arrPlainOut, '#blog.blog_title##chr(10)##application.zcore.app.getAppCFC("blog").getBlogLinkFromStruct(blog)#');
			arrayAppend(arrPlainOut, 'Posted: #dateformat(blog.blog_datetime, "mmm d, yyyy")# at #dateformat(blog.blog_datetime, "h:mm tt")#');
			if(summaryLength LT len(shortSummary)){
				shortSummary&='...';
			}
			arrayAppend(arrPlainOut, shortSummary);
		} 
	}
	for(email in emailStruct){
		row=emailStruct[email];
		curMailUserId=row.contact_id;
		curUserSiteIdType=row.user_id_siteIDType;
		curUserId=row.user_id;

		ts=StructNew(); 
		ts.subject=currentSubject;
		ts.site_id=request.zos.globals.id;
		
		// change this to be a custom script in the database, so that the variables read in.
		ts.zemail_template_type_name="general";
		if(row.html EQ 1){
			request.zTempNewEmailHTML=arrayToList(arrOut, chr(10));
			ts.html=true;
		}else{
			request.zTempNewEmailHTML="";
			ts.html=false;
		}
		request.zTempNewEmailPlainText=arrayToList(arrPlainOut, chr(10));
		if(request.zos.globals.emailCampaignFrom EQ ""){
			throw("request.zos.globals.emailCampaignFrom is missing, can't send listing alerts.");
		}
		ts.from=request.zos.globals.emailCampaignFrom;
		if(form.debug or request.zos.istestserver){
			ts.to=request.zos.developerEmailTo;
		}else{
			if(curMailUserId NEQ 0){
				ts.contact_id=curMailUserId;
			}else{
				ts.user_id=curUserId;
				ts.user_id_siteIDType=curUserSiteIdType;
			}
		} 
		if(form.debug){
			ts.preview=true;
		}else{
			ts.preview=false;
		}  
		/*if(structkeyexists(ts, 'contact_id') and ts.contact_id EQ 10){
			echo('sending to contact_id 10 only - which is skyflare@gmail.com');
		}else{
			continue;
		}*/
		//writedump(ts);		continue;
		rCom=application.zcore.email.sendEmailTemplate(ts); 
		if(rCom.isOK() EQ false){
			// user has opt out probably...
			if(form.debug){
				rCom.setStatusErrors(request.zsid);
				application.zcore.functions.zstatushandler(request.zsid); 
			}
		}
		if(form.debug or request.zos.istestserver){
			emailRS=rCom.getData();
			if(structkeyexists(emailRS, 'emailData')){
				writeoutput(emailRS.emailData.html);
				writeoutput('<pre>'&emailRS.emailData.text&'</pre>');
			}
			writedump(emailRS);
			application.zcore.functions.zabort(); 
		}
		if(request.zos.istestserver){
			echo("This script aborts on the first email when test server.");
			abort;
		}
	}
	writeoutput('#qBlog.recordcount# new blog articles | Sent email to #contactCount# contacts, and #userCount# users completed');
	if(form.debug){
		echo('<br>Debug enabled, no real emails were sent to contacts or users, just the developer');
	}
	abort;
	</cfscript>
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" returntype="any">
    <cfscript>
	var alertsPerLoop=10;
	var db=request.zos.queryObject;
	var nowDate=request.zos.mysqlnow;
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	if((request.zos.istestserver EQ false or structkeyexists(form, 'forceEmail')) and not structkeyexists(form, 'forceDebug')){
		form.debug=false;
	}else{
		form.debug=true;
	}
	if(structkeyexists(form, 'overrideYesterdayDate')){
		yesterdayDate=dateformat(form.overrideYesterdayDate, "yyyy-mm-dd")&" 00:00:00";
	}else{
		yesterdayDate=dateformat(dateadd("d", -1, now()), "yyyy-mm-dd")&" 00:00:00";
	}
	midnightDate=dateformat(now(), "yyyy-mm-dd")&" 00:00:00";

	db.sql="select * from (#db.table("site", request.zos.zcoreDatasource)# site, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site,
	#db.table("blog_config", request.zos.zcoreDatasource)# blog_config, 
	#db.table("blog", request.zos.zcoreDatasource)# blog)
	where site.site_id = app_x_site.site_id and 
	site_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	blog_config_deleted = #db.param(0)# and 
	blog_deleted = #db.param(0)# and
	app_x_site.app_id = #db.param('10')# and  
	blog_config.site_id = site.site_id and 
	blog_config_email_alerts_enabled = #db.param(1)# and 
	site_active=#db.param('1')# and ";
	if(not request.zos.istestserver){
		db.sql&=" blog_datetime >=#db.param(yesterdayDate)# and ";
	}else{
		// always pull 1 article on test server for debugging purposes
	}
	db.sql&=" blog_datetime <#db.param(midnightDate)# and 
	blog_datetime<=#db.param(request.zos.mysqlnow)# and 
	blog_status <> #db.param(2)# and 
	blog.site_id = site.site_id ";
	if(not request.zos.istestserver){
		db.sql&=" and site_live=#db.param('1')#";
	}
	db.sql&=" GROUP BY site.site_id 
	ORDER BY site.site_id ASC ";
	if(request.zos.istestserver){
		db.sql&=" LIMIT #db.param(0)#, #db.param(1)# ";
	}
	qM=db.execute("qM");   
	if(qM.recordcount EQ 0){
		echo("No articles to send an alert for today<br />");
	}
	for(row in qM){ 
        // send email with zDownloadLink(); to run the alert on the correct domain
        link=row.site_domain&'/z/server-manager/tasks/send-mailing-list-alerts/send?ztv=1';
		if(structkeyexists(form, 'overrideYesterdayDate')){
			link&="&overrideYesterdayDate=#form.overrideYesterdayDate#";
		}
        if(structkeyexists(form, 'forceDebug')){
        	link&="&forceDebug=1";
        }
        if(structkeyexists(form, 'forceEmail')){
        	link&="&forceEmail=1";
        }
        r1=application.zcore.functions.zDownloadLink(link);
	    if(request.zos.isTestServer){
	    	echo("Downloaded: "&link&"<br />");
	    	if(r1.success EQ false){
	    		writedump(r1);
	    	}else{
	            writeoutput(r1.cfhttp.FileContent&'<br /><br />');
				application.zcore.functions.zabort();
			}
	    }else{
			echo('<h2>#row.site_domain# result:</h2><p><a href="#link#" target="_blank">Run manually</a></p>');
			echo(r1.cfhttp.filecontent&"<hr>");
		} 
	}
	writeoutput('Complete');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>