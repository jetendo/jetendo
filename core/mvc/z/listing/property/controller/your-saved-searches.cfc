 	<cfcomponent>
	<cfoutput>
    <!--- <cffunction name="edit" localmode="modern" access="remote" returntype="any">
        <cfscript>
		var db=request.zos.queryObject;
        var local=structnew();
        this.init();
	writeoutput('disabled');
	abort;
        form.mls_saved_search_id=application.zcore.functions.zso(form, 'mls_saved_search_id', false, '-1');
        application.zcore.template.appendTag("scripts", '<div id="resultCountAbsolute" style="display:none;float:left; font-weight:700; padding:10px;">0 Listings</div>');
        </cfscript>
     
      
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE saved_search_email<>#db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		(saved_search_email = #db.param(form.saved_search_email)# 
        <cfif isDefined('request.zsession.user.id')> 
			or (user_id=#db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
		</cfif>)  and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_id=#db.param(form.mls_saved_search_id)#
        </cfsavecontent><cfscript>local.qSearch=db.execute("qSearch");
        if(local.qSearch.recordcount EQ 0){
            application.zcore.status.setStatus(request.zsid, "Saved search no longer exists.");
            application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&zsid="&request.zsid);	
        }
        structappend(form,request.zos.listing.functions.savedSearchQueryToStruct(local.qSearch, 1));
        //form.search_sort="newfirst";
        local.searchCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.search");
        local.searchCom.searchForm();
        </cfscript>
    </cffunction>
     --->
    <cffunction name="view" localmode="modern" access="remote" returntype="any">
        <cfscript>
		var db=request.zos.queryObject;
        var local=structnew();
        this.init();
        form.mls_saved_search_id=application.zcore.functions.zso(form, 'mls_saved_search_id', false, '-1');
	 
        </cfscript>
      
        <cfsavecontent variable="db.sql">
        SELECT * FROM 
		#request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE saved_search_email<>#db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		(saved_search_email = #db.param(form.saved_search_email)# 
        <cfif isDefined('request.zsession.user.id')> 
			or (user_id=#db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
		</cfif>)  and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_id=#db.param(form.mls_saved_search_id)#
        </cfsavecontent><cfscript>local.qSearch=db.execute("qSearch");
        if(local.qSearch.recordcount EQ 0){
            application.zcore.status.setStatus(request.zsid, "Saved search no longer exists.");
            application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&zsid="&request.zsid);	
        }
        structappend(form,request.zos.listing.functions.savedSearchQueryToStruct(local.qSearch, 1));
       // form.search_sort="newfirst";
        
        if(structkeyexists(form, 'newonly') and form.newonly EQ 1){
			if(structkeyexists(form, 'since') and isdate(form.since)){
				form.search_list_date=dateformat(form.since, 'yyyy-mm-dd')&' '&timeformat(form.since, 'HH:mm:ss');
				form.search_max_list_date=request.zos.mysqlnow;
			}else if(structkeyexists(request.zsession, 'saved_search_last_sent_date')){
				form.search_list_date=dateformat(request.zsession.saved_search_last_sent_date, 'yyyy-mm-dd')&' '&timeformat(request.zsession.saved_search_last_sent_date, 'HH:mm:ss');
				form.search_max_list_date=request.zos.mysqlnow;
			}else if(isdate(local.qSearch.saved_search_last_sent_date)){
				form.search_list_date=dateformat(local.qSearch.saved_search_last_sent_date, 'yyyy-mm-dd')&' '&timeformat(local.qSearch.saved_search_last_sent_date, 'HH:mm:ss');
				form.search_max_list_date=request.zos.mysqlnow;
			}else if(isdate(local.qSearch.saved_search_sent_date)){
				form.search_list_date=dateformat(local.qSearch.saved_search_sent_date, 'yyyy-mm-dd')&' '&timeformat(local.qSearch.saved_search_sent_date, 'HH:mm:ss');
				form.search_max_list_date=request.zos.mysqlnow;
			}else{
				form.search_list_date=dateformat(dateadd("d", -7, now()), 'yyyy-mm-dd')&' '&timeformat(dateadd("d", -7, now()), 'HH:mm:ss');
				form.search_max_list_date=request.zos.mysqlnow;
			}
        } 
		if(not structkeyexists(request.zsession, 'saved_search_last_sent_date')){
			request.zsession.saved_search_last_sent_date=local.qSearch.saved_search_sent_date;
		}
		db.sql="update #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
		set  saved_search_last_sent_date=#db.param(dateformat(local.qSearch.saved_search_sent_date,'yyyy-mm-dd')&' '&timeformat(local.qSearch.saved_search_sent_date,'HH:mm:ss'))#,
		mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE mls_saved_search_id = #db.param(local.qSearch.mls_saved_search_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted=#db.param(0)# ";
		db.execute("qUpdate");
		
	        form.searchid=application.zcore.status.getNewId();
	        application.zcore.status.setStatus(form.searchid, false, form,false);
		searchFormURL=request.zos.listing.functions.getSearchFormLink();
		writeoutput('<script type="text/javascript">window.location.href='''&searchFormURL&'?searchId='&form.searchId&''';</script>');
		
        </cfscript>
    </cffunction>
    
    
<!---     <cffunction name="update" localmode="modern" access="remote" returntype="any">
        <cfscript>
		var db=request.zos.queryObject;
        var qSearch="";
        this.init();
        </cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE saved_search_email<>#db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		(saved_search_email = #db.param(form.saved_search_email)# 
        <cfif isDefined('request.zsession.user.id')> 
			or (user_id=#db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
		</cfif>)  and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_id=#db.param(form.mls_saved_search_id)#
        </cfsavecontent><cfscript>local.qSearch=db.execute("qSearch");
        if(local.qSearch.recordcount EQ 0){
            application.zcore.status.setStatus(request.zsid, "Saved search no longer exists.");
            application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&zsid="&request.zsid);	
        }
        if(isDefined('request.zsession.user.id')){
            form.user_id=request.zsession.user.id;
        }
        form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, form.saved_search_email, form);
        
        application.zcore.status.setStatus(request.zsid, "Saved search updated.");
        application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&zsid="&request.zsid);
        </cfscript>
    </cffunction> --->

<cffunction name="init" localmode="modern" access="public" returntype="any">
        <cfscript>
		var qCheck=0;
		request.zos.currentURLISAListingPage=true;
		var db=request.zos.queryObject; 
        form.action = application.zcore.functions.zso(form, 'action',false,'list'); 
        application.zcore.functions.zStatusHandler(request.zsid);
        </cfscript>
        <script type="text/javascript">
        /* <![CDATA[ */
        function zSavedSearchEditForm(id){
            zShowModalStandard('/z/listing/search-js/index?editSavedSearch=1&mls_saved_search_id='+escape(id), 740, 630);
        }
        /* ]]> */
        </script>
        <cfscript>
	
	pageNav='<a href="/">Home</a> / ';
	
	if(application.zcore.user.checkGroupAccess("user")){
		pageNav&='<a href="/z/user/home/index">User Dashboard</a> / ';
	}else{
		echo(application.zcore.user.createAccountMessage());
	}
	application.zcore.template.setTag("pagenav", pagenav);
	
        variables.disableSavedSearchKey=false;
        if(structkeyexists(form,'saved_search_email') EQ false and isDefined('request.zsession.user.id')){
            form.saved_search_email=request.zsession.user.email;
            variables.disableSavedSearchKey=true;
        }
        form.saved_search_email=application.zcore.functions.zso(form,'saved_search_email');
        form.saved_search_key=application.zcore.functions.zso(form,'saved_search_key');
        if(form.saved_search_key EQ ""){
            if(isDefined('request.zsession.saved_search_key')){
                form.saved_search_key=request.zsession.saved_search_key;
            }else if(isDefined('cookie.saved_search_key')){
                form.saved_search_key=cookie.saved_search_key;
            }else{
                form.saved_search_key='';
            }
        }
        if(form.saved_search_email EQ ""){
            if(isDefined('request.zsession.saved_search_email')){
                form.saved_search_email=request.zsession.saved_search_email;
            }else if(isDefined('cookie.saved_search_email')){
                form.saved_search_email=cookie.saved_search_email;
            }else{
                form.saved_search_email='';
            }
        }
        request.zsession.saved_search_key=form.saved_search_key;
        cookie.saved_search_key=form.saved_search_key;
        request.zsession.saved_search_email=form.saved_search_email;
        cookie.saved_search_email=form.saved_search_email;
        </cfscript>
        
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE saved_search_email<>#db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		(saved_search_email = #db.param(form.saved_search_email)# 
        <cfif isDefined('request.zsession.user.id')> 
			or (user_id=#db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
		</cfif>)
        <cfif variables.disableSavedSearchKey EQ false> and 
		saved_search_key = #db.param(form.saved_search_key)# </cfif>  and 
		site_id = #db.param(request.zos.globals.id)#
        </cfsavecontent><cfscript>qCheck=db.execute("qCheck");</cfscript>
     
    
        <cfif qCheck.recordcount EQ 0>
            You have no saved searches.
        <cfelse>	
            <cfscript>
            request.zsession.saved_search_key=qCheck.saved_search_key;
            cookie.saved_search_key=qCheck.saved_search_key;
            request.zsession.saved_search_email=qCheck.saved_search_email;
            cookie.saved_search_email=qCheck.saved_search_email;
            </cfscript>
        </cfif>
    </cffunction>
    
<cffunction name="delete" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var qDelete=0;
	this.init();
	</cfscript>
	<cfsavecontent variable="db.sql">
	DELETE FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)#  
	WHERE mls_saved_search_id = #db.param(form.mls_saved_search_id)# and 
	(saved_search_email = #db.param(form.saved_search_email)# 
	<cfif isDefined('request.zsession.user.id')> 
		or (user_id=#db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
	</cfif>)
	<cfif variables.disableSavedSearchKey EQ false> and saved_search_key = #db.param(form.saved_search_key)# </cfif> and 
	site_id = #db.param(request.zos.globals.id)# and 
	mls_saved_search_deleted=#db.param(0)# 
	</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE saved_search_email<>#db.param('')# and 
	mls_saved_search_deleted = #db.param(0)# and 
	(saved_search_email = #db.param(form.saved_search_email)# 
	<cfif isDefined('request.zsession.user.id')>
		 or (user_id=#db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
	</cfif>)
	<cfif variables.disableSavedSearchKey EQ false> and saved_search_key = #db.param(form.saved_search_key)# </cfif>  and 
	site_id = #db.param(request.zos.globals.id)# 
	LIMIT #db.param(0)#,#db.param(1)#
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	if(qCheck.recordcount NEQ 0){
		request.zsession.saved_search_key=qCheck.saved_search_key;
		cookie.saved_search_key=qCheck.saved_search_key;
	}
	application.zcore.status.setStatus(request.zsid, 'Saved search deleted.');
	application.zcore.functions.zRedirect('/z/listing/property/your-saved-searches/index?zsid=#request.zsid#');
	</cfscript>		
</cffunction>
 
	<!--- 
<cffunction name="edit" localmode="modern" access="remote">
<cfscript> 

application.zcore.template.setTag("title","Edit Saved Search");
application.zcore.template.setTag("pagetitle","Edit Saved Search");

		searchStr=request.zos.listing.functions.searchToStruct(saved_search_email,application.zcore.functions.zso(form, 'mls_saved_search_id'));
		form.searchId = application.zcore.status.getNewId();
		application.zcore.status.setStatus(form.searchid, false,searchStr,false);
		
	city_name = 'Daytona Beach'; // forced
	
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts = StructNew();
	// required
	/*if(application.zcore.status.getField(form.searchid, "city_id") NEQ ''){
		ts.city_id = application.zcore.status.getField(form.searchid, "city_id"); 
	}*/
	// optional
	ts.offset = application.zcore.status.getField(form.searchid, "zIndex",1)-1;
	ts.perpage = application.zcore.status.getField(form.searchid, "perpage",10);
	ts.distance = 30; // in miles
	ts.searchId=form.searchId;
	//ts.debug=true;
	// hide properties from an mls provider
	//ts.arrMLSFilter=ArrayNew(1);
	//ArrayAppend(ts.arrMLSFilter, '1');
	returnStruct = propertyDataCom.getProperties(ts);
	
	
	
	// required
	searchStruct = StructNew();
	// optional
	searchStruct.showString = "";
	// allows custom url formatting
	//searchStruct.parseURLVariables = true;
	searchStruct.indexName = 'zIndex';
	searchStruct.url = request.zos.listing.functions.getSearchFormLink()&"?searchId=#form.searchid#"; 
	searchStruct.buttons = 5;
	searchStruct.count = returnStruct.count;
	// set from query string or default value
	searchStruct.index = application.zcore.status.getField(form.searchid, "zIndex",1);
	searchStruct.perpage = ts.perpage;
	// stylesheet overriding
	/*
	searchStruct.tableStyle = "property-nav";
	searchStruct.linkStyle = "property-nav";
	searchStruct.textStyle = "property-nav";
	searchStruct.highlightStyle = "property-nav-highlight";	
	*/
	
	propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	
	ts = StructNew();
	ts.baseCity = 'temp';//city_name;
	ts.datastruct=returnstruct;
	ts.navStruct=searchStruct;
	ts.searchId=form.searchId;
	propDisplayCom.init(ts);

	// inputStruct should contain all search parameters. (on daytona beach page, this would only be city_name and state_abbr)
	propertyHTML = propDisplayCom.display();	

	mapQuery=returnStruct.query;
	
	
	mapStageStruct=StructNew();
	mapStageStruct.width=508;
	mapStageStruct.height=415;
	mapStageStruct.fullscreen.width=508;
	mapStageStruct.fullscreen.height=415;
	//mapQuery=ts.query;
	</cfscript>	
	
		<cfset onSavedSearchEditForm=true>
		<cfset action='form'>
		<cfset onSavedSearchForm=true>
        <cfscript>
		searchFormCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search-form");
		searchFormCom.index();
		</cfscript>
		<br /><br />
		<h2>Current Search Results</h2>
		#propertyHTML#

</cffunction> --->
 

<cffunction name="index" localmode="modern" access="remote">
	
	<cfscript>
	var qSearch=0;
	var propertyDataCom=0;
	var returnStruct=0;
	var searchStr=0;
	var ts=0;
	var db=request.zos.queryObject;
	this.init();
	application.zcore.template.setTag("title","Your Saved Searches");
	application.zcore.template.setTag("pagetitle","Your Saved Searches");
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT * FROM #request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE saved_search_email<>#db.param('')# and 
	mls_saved_search_deleted = #db.param(0)# and 
	(saved_search_email = #db.param(form.saved_search_email)# 
    <cfif isDefined('request.zsession.user.id')> 
	or (user_id=#db.param(request.zsession.user.id)# and 
	user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#) 
	</cfif>)  and 
	site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qSearch=db.execute("qSearch");</cfscript>
    <table style="border-spacing:5px; margin-top:10px; width:100%; border:1px solid ##999999; background-color:##FFFFFF; ">
    
    <cfloop query="qSearch">
    	<cfscript>
        form.searchId = application.zcore.status.getNewId();
    	searchStr=request.zos.listing.functions.savedSearchQueryToStruct(qSearch, qSearch.currentrow);
        //searchStr.search_sort="newfirst";
        application.zcore.status.setStatus(form.searchid, false,searchStr,false);
        propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
        propertyDataCom.setSearchCriteria(searchStr);
        form.zIndex=1; 
        
        ts = StructNew(); 
        ts.offset = application.zcore.status.getField(form.searchid, "zIndex",1)-1;
        ts.perpage = 3;
        ts.distance = 30;
        ts.searchId=form.searchId;
        //ts.debug=true;
        returnStruct = propertyDataCom.getProperties(ts); 
        
        </cfscript>
		<tr><td><strong>Saved Search ###qSearch.currentrow#</strong>
		</td>
		<td style="text-align:right;">
		#numberformat(returnStruct.count)# Listings | 
		
		 <a href="/z/listing/property/your-saved-searches/view?mls_saved_search_id=#qSearch.mls_saved_search_id#" class="zNoContentTransition">View All</a> | 
		 <a href="/z/listing/property/your-saved-searches/view?newonly=1&amp;mls_saved_search_id=#qSearch.mls_saved_search_id#" class="zNoContentTransition">View New</a> | 
		 <!--- <a href="/z/listing/property/your-saved-searches/edit?mls_saved_search_id=#qSearch.mls_saved_search_id#" <!--- onclick="zSavedSearchEditForm(); return false;" --->>Edit</a> |  --->
		 <a href="/z/listing/property/your-saved-searches/delete?mls_saved_search_id=#qSearch.mls_saved_search_id#">Delete</a></td>
		</tr>
		<tr><td colspan="2">
		Criteria: #ArrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(searchStr),', ')#  <hr /></td></tr>
    </cfloop>
    </table><br />
</cffunction>
</cfoutput>
</cfcomponent>