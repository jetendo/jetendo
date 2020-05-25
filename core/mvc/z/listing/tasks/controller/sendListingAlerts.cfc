<cfcomponent>
<cfoutput>
<cffunction name="send" localmode="modern" access="remote" returntype="any">
        <cfscript>
	
	var alertsPerLoop=10;
	var qM=0;
	var qM2=0;
	var i2=0;
	var db=request.zos.queryObject;
	var t9=0;
	var db.sql=0;
	var db=request.zos.queryObject;
	var ts=0;
	var oldDate=0;
	var searchStr=0;
	var i=0; 
	var row=0;
	var row2=0;
	var propertyDataCom=0;
	var rs=0;
	var qu=0;
	var link1=0;
	var link2=0;
	var nowDate=request.zos.mysqlnow;
	var rCom=0; 
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}
	setting requesttimeout="10000";
	if((request.zos.istestserver EQ false or structkeyexists(form, 'forceEmail')) and not structkeyexists(form, 'forceDebug')){
		form.debug=false;
	}else{
		form.debug=true;
	}
	db.sql="select group_concat(mls_saved_search_id SEPARATOR #db.param(',')#) idlist, min(contact_id) contact_id, saved_search_email, min(mls_saved_search.user_id) user_id from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE saved_search_email<>#db.param('')# and 
	mls_saved_search_deleted = #db.param(0)# and 
	saved_search_sent_date < #db.param(dateformat(now(),'yyyy-mm-dd')&' 00:00:00')# and 
	site_id = #db.param(request.zos.globals.id)# ";
	if(dayofweek(now()) EQ 6){
		// get the saved searches that only go out on fridays:
		db.sql&=" and saved_search_frequency = #db.param(0)# ";
	}
	db.sql&=" group by saved_search_email
	LIMIT #db.param(0)#,#db.param(alertsPerLoop)#";
	qM=db.execute("qM");
	if(qM.recordcount EQ 0){
		writeoutput('All alerts sent');
		if(form.debug){
			writedump(qM);
		}
		application.zcore.functions.zabort();
	}
	for(row in qm){
		if(row.contact_id EQ 0){
			// convert record to a real user if possible.
			db.sql="select * FROM #db.table("contact", request.zos.zcoreDatasource)# 
			WHERE contact_email = #db.param(row.saved_search_email)# and 
			contact_parent_id=#db.param(0)# and 
			contact_deleted = #db.param(0)# and 
			site_id= #db.param(request.zos.globals.id)#";
			qU=db.execute("qU");
			if(qU.recordcount NEQ 0){
				db.sql="update #db.table("mls_saved_search", request.zos.zcoreDatasource)# set 
				contact_id = #db.param(qU.contact_id)#,
				mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)# 
				where mls_saved_search_id in (#db.trustedSQL(row.idlist)#) and 
				site_id = #db.param(request.zos.globals.id)# ";
				db.execute("qUpdate");
			}
		}
		if(row.user_id EQ 0){
			// convert record to a real user if possible.
			db.sql="select * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_username = #db.param(row.saved_search_email)# and 
			user_deleted = #db.param(0)# and 
			#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL("user", request.zos.globals.id))#";
			qU=db.execute("qU");
			if(qU.recordcount NEQ 0){
				db.sql="update #db.table("mls_saved_search", request.zos.zcoreDatasource)# set 
				user_id = #db.param(qU.user_id)#, 
				user_id_siteIDType = #db.param(application.zcore.functions.zGetSiteIdType(qU.site_id))#,
				mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)#  
				where mls_saved_search_id in (#db.trustedSQL(row.idlist)#) and 
				site_id = #db.param(request.zos.globals.id)# ";
				db.execute("qUpdate");
			}
		}
		if(form.debug){
			writedump('mls_saved_search_id list: '&row.idlist);
		}
		db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE mls_saved_search_id IN (#db.trustedSQL(row.idlist)#) and 
		site_id = #db.param(request.zos.globals.id)#";
		qM2=db.execute("qM2");
		local.arrSearch=[]; 
		local.rowIndex=1;
		for(t9 in qM2){ 
			searchStr=request.zos.listing.functions.savedSearchQueryToStruct(qM2, local.rowIndex);
			searchStr.search_sort="newfirst"; 
			propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
			propertyDataCom.setSearchCriteria(searchStr); 
			ts = StructNew();
			ts.searchCriteria=searchStr;
			ts.onlyCount=true;
			ts.offset = 0;
			if(form.debug){
				ts.debug=true;
			}
			ts.perpage = 1;
			ts.distance = 30;  
			oldDate=dateformat(t9.saved_search_sent_date,'yyyy-mm-dd')&' '&timeformat(t9.saved_search_sent_date,'HH:mm:ss');
			ts.searchCriteria.search_list_date=oldDate;
			ts.searchCriteria.search_max_list_date=nowDate; 
			rs = propertyDataCom.getProperties(ts);
			if(rs.count GT 0){
				arrayAppend(local.arrSearch, { 
					count: rs.count, 
					contact_id: t9.contact_id, 
					user_id: t9.user_id, 
					user_id_siteIDType: t9.user_id_siteIDType, 
					criteria: 'Criteria: '&ArrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(t9),', '),
					link: "#request.zos.currentHostName#/z/listing/property/your-saved-searches/view?newonly=1&since=#urlencodedformat(oldDate)#&mls_saved_search_id=#t9.mls_saved_search_id#&saved_search_email=#t9.saved_search_email#&saved_search_key=#t9.saved_search_key#"
				});
			}
			local.rowIndex++;
		} 
		if(arraylen(local.arrSearch)){ 
			local.arrHTML=[];
			local.arrText=[];
			local.curMailUserId=local.arrSearch[1].contact_id;
			local.curUserId=local.arrSearch[1].user_id;
			local.curUserIdSiteIDType=local.arrSearch[1].user_id_siteIDType;
			for(i=1;i LTE arraylen(local.arrSearch);i++){
				arrayAppend(local.arrHTML, '<h3 style="font-size:18px;"><a href="#htmleditformat(local.arrSearch[i].link)#">###i# | #numberformat(local.arrSearch[i].count)# new listings (click to view)</a></h3>'&chr(10)&'<p style="font-size:14px;">'&htmleditformat(local.arrSearch[i].criteria)&'</p><hr />'&chr(10));
				arrayAppend(local.arrText, '###i# | #numberformat(local.arrSearch[i].count)# new listings'&chr(10)&chr(10)&local.arrSearch[i].link&chr(10)&chr(10)&local.arrSearch[i].criteria&chr(10)&chr(10)&"--------------"&chr(10)&chr(10));
			}
			link2="#request.zos.currentHostName#/z/listing/property/your-saved-searches/index";
			request.zTempNewEmailListingAlertHTML='<h1 style="font-size:24px;">New Listing Email Alert</h1>';
			savecontent variable="request.zTempNewEmailListingAlertHTMLFooter"{
				writeoutput('<h2 style="font-size:18px;">New listings match your saved real estate listing search.</h2>
				<p style="font-size:14px;">Click the links below to view these listings on our web site, <a href="#request.zos.currentHostName#">#request.zos.globals.shortDomain#</a>.</p>
				#arrayToList(local.arrHTML, '')#
				
				<p style="font-size:14px; font-weight:bold;"><a href="#(link2)#">Click here to manage your saved searches.</a></p>');
			}
			request.zTempNewEmailListingAlertPlainText='New Listing Email Alert';
			savecontent variable="request.zTempNewEmailListingAlertPlainTextFooter"{
				writeoutput('New listings match your saved real estate listing search.  Click the links below to view these listings on our web site, #request.zos.globals.shortDomain#.#chr(10)&chr(10)##arrayToList(local.arrText, '')#Click the following link to manage your saved searches#chr(10)##link2##chr(10)&chr(10)#If you have trouble viewing the links above, please copy and paste them into the address bar of your browser and press enter.');
			}
			ts=StructNew(); 
			ts.site_id=request.zos.globals.id;
			
			// change this to be a custom script in the database, so that the variables read in.
			ts.zemail_template_type_name="New Listing Alert";
			if(t9.saved_search_format EQ 1){
				ts.html=true;
			}else{
				ts.html=false;
			}
			if(request.zos.globals.emailCampaignFrom EQ ""){
				throw("request.zos.globals.emailCampaignFrom is missing, can't send listing alerts.");
			}
			ts.from=request.zos.globals.emailCampaignFrom;
			ts.arrParameters=arraynew(1);
			arrayappend(ts.arrParameters,t9.mls_saved_search_id); 
			if(form.debug){
				ts.to=request.zos.developerEmailTo;
			}else{
				if(local.curMailUserId NEQ 0){
					ts.contact_id=local.curMailUserId;
				}else if(local.curUserId NEQ 0){
					ts.user_id=local.curUserId;
					ts.user_id_siteIDType=local.curUserIdSiteIDType;
				}else{
					ts.to=row.saved_search_email;
				}
			} 
			if(form.debug){
				ts.preview=true;
			}  
			rCom=application.zcore.email.sendEmailTemplate(ts); 
			if(rCom.isOK() EQ false){
				// user has opt out probably...
				if(form.debug){
					rCom.setStatusErrors(request.zsid);
					application.zcore.functions.zstatushandler(request.zsid); 
				}
			}
			if(form.debug){
				local.emailRS=rCom.getData();
				if(structkeyexists(local.emailRS, 'emailData')){
					writeoutput(local.emailRS.emailData.html);
					writeoutput('<pre>'&local.emailRS.emailData.text&'</pre>');
				}
				writedump(local.emailRS);
				application.zcore.functions.zabort(); 
			}
		}else{
			if(form.debug){
				writeoutput('No listings found');
			}
		}
		if(form.debug){
			writeoutput('<br />Debug request aborted on first loop');
			application.zcore.functions.zabort();
		}else{
			db.sql="update #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
			set 
			saved_search_sent_date=#db.param(nowDate)#,
			mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)#   
			where mls_saved_search_id in (#db.trustedSQL(row.idlist)#) and 
			site_id = #db.param(request.zos.globals.id)#";  
			db.execute("q");
		}
	}
	writeoutput('Successfully completed');
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any">
        <cfscript>
        
	var db=request.zos.queryObject;
        var cfhttp=0;
	var row=0;
        if(request.zos.istestserver EQ false){
            form.debug=false;
        }else{
            form.debug=true;
        } 
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	} 
        db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# site, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("mls_option", request.zos.zcoreDatasource)# mls_option, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search
	where site.site_id = app_x_site.site_id and 
	site_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	mls_option_deleted = #db.param(0)# and 
	mls_saved_search_deleted = #db.param(0)# and  
	mls_option.site_id = site.site_id and 
	site.site_id = mls_saved_search.site_id and 
	mls_saved_search.saved_search_email <> #db.param('')# and 
	mls_saved_search.saved_search_sent_date < #db.param(dateformat(now(),'yyyy-mm-dd')&' 00:00:00')# and 
	mls_option.mls_option_listing_alerts = #db.param(1)# and 
	app_x_site.app_id = #db.param('11')# and  
	site_active=#db.param('1')# ";
	if(dayofweek(now()) EQ 6){
		// get the saved searches that only go out on fridays:
		db.sql&=" and saved_search_frequency = #db.param(0)# ";
	}
	if(request.zos.istestserver EQ false){
		db.sql&=" and site_live=#db.param('1')#";
	}else{
		db.sql&=" LIMIT #db.param(0)#, #db.param(1)# ";
	}
	local.qM=db.execute("qM");  
	for(row in local.qM){
        // send email with zDownloadLink(); to run the alert on the correct domain
        local.link=row.site_domain&'/z/listing/tasks/sendListingAlerts/send';
        local.r1=application.zcore.functions.zDownloadLink(local.link);
        /*if(local.r1.success EQ false){
            writeoutput('Send Listing Alert failed');
            application.zcore.functions.zdump(cfhttp);
            application.zcore.functions.zabort();
        }*/
	    if(request.zos.isTestServer){
            writeoutput(local.r1.cfhttp.FileContent&'<br /><br />');
			application.zcore.functions.zabort();
	    }
	}
	writeoutput('Complete');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>