<cfcomponent>
<cfoutput>
<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Saved Listing Searches", true);
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(trim(form.saved_search_email) EQ ""){
			application.zcore.status.setStatus(request.zsid,"Invalid Request");
			application.zcore.functions.zRedirect("/z/listing/admin/saved-searches/index?zsid=#request.zsid#");	
		}
		db.sql="delete from #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
		WHERE saved_search_email = #db.param(form.saved_search_email)# and 
		site_id = #db.param(request.zos.globals.id)# and 
        mls_saved_search_deleted = #db.param(0)#";
		db.execute("q"); 
		application.zcore.status.setStatus(request.zsid, 'Saved search deleted');
		application.zcore.functions.zRedirect('/z/listing/admin/saved-searches/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2>
		Are you sure you want to delete saved search for this email address?<br /><br />
		#form.saved_search_email#<br /><br />
		<a href="/z/listing/admin/saved-searches/delete?saved_search_email=#urlencodedformat(form.saved_search_email)#&amp;confirm=1">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/listing/admin/saved-searches/index">No</a>
		</h2>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qCheck=0;
	var searchStr=0;
	var searchNav=0;
	var inputStruct=0;
	var qCount=0;
	var rollOverCode=0;
    application.zcore.functions.zSetPageHelpId("6.5");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Saved Listing Searches");
		var db=request.zos.queryObject;
    application.zcore.functions.zStatusHandler(Request.zsid);
    </cfscript>
    <h2>Saved Searches</h2>
        
    <cfscript>
    if(structkeyexists(form, 'tid') EQ false){
        form.tid = application.zcore.status.getNewId();
    }
    if(structkeyexists(form, 'zSearchXIndex')){
        application.zcore.status.setField(form.tid, "zSearchXIndex", form.zSearchXIndex);
    }else{
        form.zSearchXIndex = application.zcore.status.getField(form.tid, "zSearchXIndex");
        if(form.zSearchXIndex EQ ""){
            form.zSearchXIndex = 1;
        }
    }
    Request.zScriptName="/z/listing/admin/saved-searches/index?tid=#form.tid#";
    </cfscript>
    <cfsavecontent variable="db.sql">
    SELECT count(distinct saved_search_email) count 
	FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
    WHERE  site_id = #db.param(request.zos.globals.id)# and 
    mls_saved_search_deleted = #db.param(0)#
    <cfif structkeyexists(form, 'searchemail')>
     and saved_search_email like #db.param('%#form.searchemail#%')#
    </cfif>  and saved_search_email <>#db.param('')#
    </cfsavecontent><cfscript>qCount=db.execute("qCount");</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT *, count(mls_saved_search_id) count, max(mls_saved_search_id) maxid 
	FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search
    WHERE  site_id = #db.param(request.zos.globals.id)# and 
    mls_saved_search_deleted = #db.param(0)#
    <cfif structkeyexists(form, 'searchemail')>
    and saved_search_email like #db.param('%#form.searchemail#%')#
    </cfif> and saved_search_email <>#db.param('')#
     GROUP BY saved_search_email
     ORDER BY saved_search_created_date desc
    
        LIMIT #db.param((form.zSearchXIndex-1)*30)#,#db.param(30)#
    </cfsavecontent><cfscript>qCheck=db.execute("qCheck");</cfscript>
    <style>
    .table-bright {
        background-color:##F0F0F0;
    }
    .table-highlight {
        background-color:##F6F6F6;
    }
    .table-white {
        background-color:##FFFFFF;
    }
    .table-shadow {
        background-color:##CCCCCC;
    }
    </style>
        <cfscript>
        if(qCount.count GT 30){
            // required
            searchStruct = StructNew();
            searchStruct.count = qCount.count;
            searchStruct.index = form.zSearchXIndex;
            // optional
            searchStruct.url = "/z/listing/admin/saved-searches/index";
            searchStruct.buttons = 5;
            searchStruct.perpage = 30;
            searchStruct.indexName= "zSearchXIndex";
            // stylesheet overriding
            searchStruct.tableStyle = "table-highlight tiny";
            searchStruct.linkStyle = "tiny";
            searchStruct.textStyle = "tiny";
            searchStruct.highlightStyle = "table-white tiny";
            
            searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
        }else{
            searchNav = "";
        }
        </cfscript>
        <form action="/z/listing/admin/saved-searches/index" method="get">
        <p><strong>Email Address:</strong> <input type="text" name="searchemail" value="#application.zcore.functions.zso(form, 'searchemail')#" /> <input type="submit" name="searchButton" value="Search" class="z-manager-search-button" style="text-align:center;" />
        <cfif structkeyexists(form, 'searchemail')> <input type="button" onclick="window.location.href='/z/listing/admin/saved-searches/index';" class="z-manager-search-button" value="Show All"></cfif></p>
        </form>
        <p>Use the "Delete All Searches" link below to manually unsubscribe a user if they complain about these emails.</p>
        <cfif structkeyexists(form, 'searchemail') and qcount.count EQ 0>
        <p>No saved searches match your search.</p>
        <cfelse>
			<cfif qcount.count EQ 0>
            There are no saved searches yet.
            <cfelse><br />
            
            	<cfscript>writeoutput(searchNav);</cfscript>
                <table style="border-spacing:0px;" class="table-list">
                <tr class="table-shadow">
                <td>Email</td>
                <td>Searches</td> 
                <td>Date Created</td>
                <td>Date Updated</td>
                <td>Admin</td>
                </tr> 
                <cfloop query="qCheck">
					<cfscript>
                    // create input structure
                    inputStruct = StructNew();
                    // required
                    inputStruct.currentRow = qCheck.currentRow;
                    inputStruct.style = "table-bright";
                    inputStruct.style2 = "table-highlight";
                    inputStruct.styleOver = "table-white";
                    inputStruct.output = false;
                    inputStruct.name = "search_rollover"; // must follow variable naming conventions
                    // run function
                    rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
                    
                    searchStr=StructNew();
                    application.zcore.functions.zQueryToStruct(qCheck, searchStr,"", qCheck.currentRow);
                    </cfscript>
                    <tr #rollOverCode#>
                    <td><a href="mailto:#qCheck.saved_search_email#">#qCheck.saved_search_email#</a></td>
                    <!--- <td>#ArrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(searchStr),', ')#</td> --->
                    <td>#qCheck.count#</td>
                    <td>#DateFormat(qCheck.saved_search_created_date,'m/d/yy')&' '&TimeFormat(qCheck.saved_search_created_date,'h:mm:ss')#</td>
                    <td>#DateFormat(qCheck.saved_search_updated_date,'m/d/yy')&' '&TimeFormat(qCheck.saved_search_updated_date,'h:mm:ss')#</td>
                    <td><!--- <a href="#request.cgi_SCRIPT_NAME#?action=view&saved_search_email=#saved_search_email#&saved_search_id=#maxid#">View/Edit Current Results</a> | ---> <a href="/z/listing/admin/saved-searches/delete?saved_search_email=#qCheck.saved_search_email#">Delete All Searches</a></td>
                    </tr>
                          <!---   <tr #rollOverCode#>
                    <td colspan="5">#ArrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(searchStr),', ')#</td>
                    </tr> --->
            	</cfloop>
        		</table>
            	<cfscript>writeoutput(searchNav);</cfscript>
        	</cfif>
        </cfif>
    </cffunction>
    </cfoutput>
</cfcomponent>