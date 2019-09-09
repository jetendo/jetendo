<cfcomponent>
<cfoutput> 
<!--- 
TODO:
	need to automatically search subcategories since the main category isn't  able to show results for many of the places.
	
need to repost posted variables to the getSearchCriteria since I want to prefill form from external source.

need to integrate with search-site -> search function.

allow sub-group options to appear on each form somehow:
	i.e. to allow search the additional locations, and dining/venue/stay info

if site_option has onchange manager field, i could:
	fire custom code to display the sub-search fields (i.e. hotel, venue, dining) and sub-categories for all of them...
	
or we could show the sub-search fields on the main "Place" tab automatically via a custom callback that feeds the fields into the form.

the search sql that is generated, has to be able to be passed into a callback filter before it runs on the database.

search sql generator has to be able to search on child group data for paging to work.
	
	This is the sql needed to do a sub-group search:
	site_x_option_group_set sSet2,
	site_x_option_group sGroup2 
	WHERE 
	sSet2.site_x_option_group_set_parent_id=s1.site_x_option_group_set_id AND 
	sSet2.site_option_group_id=10 AND 
	sSet2.site_x_option_group_set_id = sGroup2.site_x_option_group_set_id AND 
	sSet2.site_id = s1.site_id AND 
	sGroup2.site_option_id = '70' AND
	sGroup2.site_x_option_group_value = 'Address1' AND 
	sGroup2.site_id = s1.site_id AND  
	

 --->
<cffunction name="search" access="remote" localmode="modern">
	
	<cfscript>
	application.zcore.functions.zNoCache();
	db=request.zos.queryObject;
	request.disableSidebar=true;
	if(structkeyexists(form, 'searchtext')){
		form.searchtext=trim(form.searchtext);
		if(application.zcore.app.siteHasApp("listing") and refind("[0-9]", form.searchtext) NEQ 0){
			// check for listing id and redirect to it if it exists.
			db.sql="select * from #db.table("listing", request.zos.zcoreDatasource)# 
			WHERE 
			listing_deleted = #db.param(0)# and 
			#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
			listing_id like #db.param("%-"&form.searchtext)# ";
    			if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
				db.sql&=" and listing_status LIKE #db.param('%,7,%')# ";
			}
			if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')){
				db.sql&=" #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# ";
			}
			qListing=db.execute("qListing");
			if(qListing.recordcount EQ 1){
				arrMLS=listToArray(qListing.listing_id, "-");
				urlId=application.zcore.listingCom.getURLIdForMLS(arrMLS[1]);
				application.zcore.functions.zRedirect("/listing-#urlId#-#arrMLS[2]#.html");
			}
		}
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# , #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option.site_id = site_option_group.site_id and 
	site_option.site_option_group_id = site_option_group.site_option_group_id and 
	site_option_public_searchable = #db.param(1)# and 
	site_option_deleted = #db.param(0)# and
	site_option_group_public_searchable = #db.param(1)# and 
	site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted = #db.param(0)# 
	GROUP BY site_option_group.site_option_group_id
	ORDER BY site_option_group_display_name ASC";
	qGroup=db.execute("qGroup");
	
	if(structkeyexists(form, 'autosearch') or structkeyexists(form, 'searchtext')){
		// autosearch allows passing in search criteria in URL/FORM variables to the ajax.
		form.autosearch=true;
		form.clearCache=true;
		rs=variables.getPublicSearchResults();
	}
	form.perpage=10;
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	if(not structkeyexists(form, 'groupId')){
		form.groupId=0;
		if(structkeyexists(request.zsession, 'searchLastGroupId')){
			form.groupId=request.zsession.searchLastGroupId;
		}
	}else{
		form.clearCache=true;
		form.autosearch=true;
		// this could be optimized more later - so it doesn't run twice.
		this.getPublicSearchCriteria();
		rs=variables.getPublicSearchResults();
	}
	if(structkeyexists(request.zsession, 'searchGroupStructCache') and structkeyexists(request.zsession.searchGroupStructCache,  form.groupId) and structkeyexists(request.zsession.searchGroupStructCache[form.groupId], 'zIndex')){
		form.zIndex=request.zsession.searchGroupStructCache[form.groupId].zIndex;
	}
	</cfscript>
	<cfsavecontent variable="meta">
	<style type="text/css">
	
	</style>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title", "Search Site");
	//application.zcore.template.setTag("pagetitle", "Search");
	application.zcore.template.setTag("meta", meta);
	tabCount=1;
	</cfscript>
	<cfsavecontent variable="groupTabHTML">
		<div id="zSearchTitleDiv">Search Everything<!--- #searchCriteriaStruct.title# ---></div>
		<div id="zSearchFilterDiv">Filter your search by sections of our web site:</div>
		<div id="zSearchTabDiv">
		<a href="##" id="searchTabAllId" data-groupId="0" <cfif form.groupID EQ 0>class="zSearchTabDivSelected"</cfif> onclick="getSearchCriteria(0); return false;">Everything</a>
		<cfscript>
		for(row in qGroup){
			if(row.site_option_group_parent_id NEQ 0){
				continue;
			}
			tabCount++;
			class='';
			if(form.groupID EQ row.site_option_group_id){
				class='class="zSearchTabDivSelected"';
			}
			echo('<a href="##" id="searchTabGroup#row.site_option_group_id#" data-groupId="#row.site_option_group_id#" #class# onclick="getSearchCriteria(#row.site_option_group_id#); return false;">#htmleditformat(row.site_option_group_display_name)#</a>');
		}
		</cfscript>
		</div>
	</cfsavecontent>
	<cfscript>
	disableSidebar=false;
	if(tabCount GT 1){
		echo(groupTabHTML);
	}else{
		application.zcore.template.setTag("pagetitle", "Search Site");
		disableSidebar=true;
	}
	</cfscript>
	<input type="hidden" name="zSearchTrackerGroupId" id="zSearchTrackerGroupId" value="#form.groupId#" />
	<input type="hidden" name="zSearchTrackerzIndex" id="zSearchTrackerzIndex" value="#form.zIndex#" /> 
	<div style="width:100%; display:table; float:left;">
		<div id="zSearchFormDiv" <cfif disableSidebar> class="zSearchFormDivNoSidebar" data-sidebar-disabled="1" style="width:100%; border-right:none; padding-bottom:10px;"<cfelse> data-sidebar-disabled="0"</cfif>>
		</div>
		<div id="zSearchResultsDiv" <cfif disableSidebar> class="zSearchResultsDivNoSidebar" </cfif>>
		</div>
	</div>
	<script type="text/javascript">
	/* <![CDATA[ */
	if(typeof reloadResultsIfBackDetected != "undefined"){
		reloadResultsIfBackDetected();
	}else{
		zArrDeferredFunctions.push(function(){ reloadResultsIfBackDetected();});
	}
	/* ]]> */
	</script>
</cffunction>


<cffunction name="ajaxGetPublicSearchResults" output="yes" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	rs=this.getPublicSearchResults();
	application.zcore.functions.zReturnJson(rs); 
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="regularSearch" output="yes" access="public" returntype="struct" localmode="modern">
	<cfscript>
	application.zcore.functions.zNoCache();
	rs2={ hasMoreRecords:false};
	form.searchtext=application.zcore.functions.zso(form, 'searchtext');
	if(trim(form.searchtext) EQ ""){
		return rs2;
	}
	db=request.zos.queryObject;
	
	/*db.sql="select count(search_id) count
	from #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	match(search_fulltext) against(#db.param(form.searchtext)#) and 
	search_deleted = #db.param(0)#";
	qCount=db.execute("qCount");*/
	db.sql="select *, match(search_fulltext) against(#db.param(form.searchtext)#) relevance
	from #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	(match(search_fulltext) against(#db.param(form.searchtext)#) or search_fulltext like #db.param('%'&form.searchtext&'%')#) and 
	search_deleted = #db.param(0)# and 
	( user_group_id=#db.param(0)# ";
	arrId=application.zcore.user.getGroupIdArrayForLoggedInUser();
	for(id in arrId){
		db.sql&=" or user_group_id=#db.param(id)# ";
	}
	db.sql&=")
	ORDER BY relevance DESC 
	LIMIT #db.param((form.zIndex-1)*10)#, #db.param(11)#";
	qSearch=db.execute("qSearch", "", 10000, "query", false);   
	</cfscript>
	<cfif qSearch.recordcount EQ 0>
		<h2>No results matched your criteria.</h2>
		<p>Please <a href="##zSearchFormDiv">try another search</a> or <a href="/">browse our web site</a>.</p>
	</cfif>
	<!--- <cfscript>
	searchStruct = StructNew(); 
	searchStruct.indexName = 'zIndex'; 
	searchStruct.url = "/z/misc/search-site/search";  
	searchStruct.buttons = 5; 
	// set from query string or default value 
	searchStruct.perpage = 10;	
	searchStruct.index = form.zIndex; 
	searchStruct.count=qCount.count;
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript> --->
	<div class="z-search-results">
		<!--- <div class="z-search-results-heading">Search Results</div> --->
		<cfscript>
		hasImage=false;
		loop query="qSearch"{
			if(qSearch.search_image NEQ ""){
				hasImage=true;
			}
		}
		</cfscript>
		<cfloop query="qSearch">
			<div class="z-search-link">	
				<!--- <div class="z-search-link-image"></div> --->
				<cfscript>
				if(hasImage){
					echo('<div class="z-search-link-image">');
					if(qSearch.search_image NEQ ""){
						echo('<img src="#qSearch.search_image#" alt="#htmleditformat(qSearch.search_title)#" />');
					}else{
						echo('&nbsp;');
					}
					echo('</div>');
					echo('<div class="z-search-link-text">');
				}
				echo('<div class="z-search-link-heading"><a href="#htmleditformat(qSearch.search_url)#">#htmleditformat(qSearch.search_title)#</a></div>');
				if(qSearch.search_summary NEQ ""){
					echo('<div class="z-search-link-summary">#(qSearch.search_summary)#</div>');
				}
				if(qSearch.search_content_datetime NEQ "" and qSearch.search_content_datetime NEQ "0000-00-00 00:00:00"){
					echo('<div class="z-search-link-date">Updated #dateformat(qSearch.search_content_datetime, "m/d/yy")#</div>');
				}
				if(hasImage){
					echo('</div>');
				}
				</cfscript>
			</div>
		</cfloop>
		<!--- <cfif qCount.count GT 10 or form.zIndex NEQ 1><div class="z-search-nav">#searchNav#</div></cfif> --->
	</div>
	<cfscript>
	if(qSearch.recordcount EQ 11){
		rs2.hasMoreRecords=true;
	}
	return rs2;
	</cfscript>
</cffunction>

<cffunction name="embedSearchForm" localmode="modern" access="remote">
	<cfargument name="groupId" type="string" required="no" default="0">
	<cfscript>
	application.zcore.functions.zNoCache();
	form.autosearch=true;
	if(request.zos.originalURL EQ "/z/misc/search-site/search"){
		return;
	}
	form.groupId=application.zcore.functions.zso(arguments, 'groupId', true, 0);
	form.embeddedSearchForm=true;
	request.zos.debuggerEnabled=false;
	if(left(request.zos.originalURL, len("/z/misc/search-site/embedSearchForm")) EQ "/z/misc/search-site/embedSearchForm"){
		application.zcore.template.setPlainTemplate();
	}
	rs=variables.getPublicSearchCriteria();
	echo(rs.html);
	application.zcore.skin.addDeferredScript("
		zSearchCriteriaSetupSubGroupButtons();
	");
	</cfscript>
</cffunction>


<cffunction name="getPublicSearchResults" output="no" localmode="modern" access="public">
	<cfscript>
	application.zcore.functions.zNoCache();
	db=request.zos.queryObject;
	form.siteOptionGroupId=application.zcore.functions.zso(form, 'siteOptionGroupId');
	variables.setupSearchCache();
	rs={ success:true, groupId: form.groupId};
	// cache search criteria values in session scope with groupId as the key, so form prefills when user returns
	// cache last groupId, so search form re-displays the same way.
	searchCacheStruct={zIndex:form.zIndex};
	savecontent variable="rs.html"{
		if(form.groupId EQ 0){
			searchCacheStruct.searchtext=application.zcore.functions.zso(form, 'searchtext');
			if(not structkeyexists(form, 'autosearch')){
				rs2=this.regularSearch();
			}
		}else{
			// in search results, need to parse form.siteOptionGroupId and convert the search to have ts.subGroup for the ones that don't match the primary group.
			arrGroupOption=listToArray(form.siteOptionGroupId, ",");
			groupOptionStruct={};
			groupNameCache={};
			for(i=1;i LTE arrayLen(arrGroupOption);i++){
				arr1=listToArray(arrGroupOption[i], "|");
				if(arraylen(arr1) EQ 2){
					if(not structkeyexists(groupNameCache, arr1[2])){
						groupStruct=application.zcore.functions.zGetSiteOptionGroupById(arr1[2]);
						groupNameCache[arr1[2]]=groupStruct.site_option_group_name;
					}
					groupOptionStruct[arr1[1]]={groupName:groupNameCache[arr1[2]], groupId:arr1[2]};
				}
			}
			groupStruct=application.zcore.functions.zGetSiteOptionGroupById(form.groupId);
			if(structcount(groupStruct) EQ 0){
				return { success:false, errorMessage:'form.groupId, "#form.groupId#" doesn''t exist.'}; 
			}
			tempStruct=application.sitestruct[request.zos.globals.id].globals.soGroupData;
			if(groupStruct.site_option_group_search_result_cfc_path EQ "" or groupStruct.site_option_group_search_result_cfc_method EQ ""){
				customRenderEnabled=false;
			}else{
				customRenderEnabled=true;
				searchMethod=groupStruct.site_option_group_search_result_cfc_method;
				if(left(groupStruct.site_option_group_search_result_cfc_path, 5) EQ "root."){
					cfcPath=request.zRootCFCPath&removeChars(groupStruct.site_option_group_search_result_cfc_path, 1, 5);
				}else{
					cfcPath=groupStruct.site_option_group_search_result_cfc_path;
				}
				searchCom=application.zcore.functions.zcreateobject("component", cfcPath);
			}
			arrSearch=[];
			for(i in form){
				if(left(i, 8) EQ 'newvalue'){
					if(form[i] NEQ ""){
						site_option_id=removeChars(i, 1, 8);
						if(structkeyexists(tempStruct.optionLookup, site_option_id)){
							searchCacheStruct[i]=form[i];
							var currentCFC=application.zcore.siteOptionCom.getTypeCFC(tempStruct.optionLookup[site_option_id].type);
							if(currentCFC.isSearchable()){
								ts=currentCFC.getSearchSQLStruct(tempStruct.optionLookup[site_option_id], tempStruct.optionLookup[site_option_id].optionStruct, 'newvalue', form, form[i]); 
								if(structkeyexists(groupOptionStruct, site_option_id) and groupOptionStruct[site_option_id].groupId NEQ form.groupId){
									ts.subGroup=groupOptionStruct[site_option_id].groupName;
								}
								arrayAppend(arrSearch, ts);
							}
						}
					}
				}
			}
			if(not structkeyexists(form, 'autosearch')){
				rs2=application.zcore.siteOptionCom.searchOptionGroup(groupStruct.site_option_group_name, arrSearch, 0, true, (form.zIndex-1)*10, 10);
				/*application.zcore.functions.zheader("x_ajax_id", form.x_ajax_id);
				writedump(rs2); abort; //application.zcore.functions.zReturnJson({arrSearch:arrSearch, rs2:rs2});abort;
				*/
				 if(arrayLen(rs2.arrResult) EQ 0){
					echo('<h2>No #groupStruct.site_option_group_display_name#(s) matched your search.</h2><p>Please <a href="##zSearchFormDiv">try another search</a> or <a href="/">browse our web site</a>.</p>'); 
				 }
				 if(customRenderEnabled){
					for(i=1;i LTE arrayLen(rs2.arrResult);i++){
						c=rs2.arrResult[i];
						searchCom[searchMethod](c);
					}
				}else{
					imageStruct={};
					hasImage=false;
					for(i=1;i LTE arrayLen(rs2.arrResult);i++){
						c=rs2.arrResult[i];
						if(structkeyexists(c, '__image_library_id') and c.__image_library_id NEQ 0){
							ts={};
							ts.output=false;
							ts.size="150x120";
							ts.layoutType="";
							ts.image_library_id=c.__image_library_id;
							ts.forceSize=true;
							ts.crop=0;
							ts.offset=0;
							ts.limit=1; // zero will return all images
							var arrImage=request.zos.imageLibraryCom.displayImages(ts);
						}else{
							arrImage=[];
						}
						if(arraylen(arrImage)){
							hasImage=true;
							imageStruct[c.__setId]='<img src="#arrImage[1].link#" alt="#htmleditformat(arrImage[1].caption)#" />';
						}else{
							imageStruct[c.__setId]="";
						}
					}
					 echo('<div class="z-search-results">');
					 for(i=1;i LTE arrayLen(rs2.arrResult);i++){
						c=rs2.arrResult[i];
						echo('<div class="z-search-link">');
							if(hasImage){
								image=imageStruct[c.__setId];
								echo('<div class="z-search-link-image">');
								if(image NEQ ""){
									echo('<a href="#c.__url#" target="_blank">'&image&'</a>');
								}else{
									echo('&nbsp;');
								}
								echo('</div>');
								echo('<div class="z-search-link-text">');
							}
							echo('<div class="z-search-link-heading"><a href="#htmleditformat(c.__url)#" target="_blank">#htmleditformat(c.__title)#</a></div>');
							if(c.__summary NEQ ""){
								echo('<div class="z-search-link-summary">#htmleditformat(c.__summary)#</div>');
							}
							if(c.__dateModified NEQ "" and c.__dateModified NEQ "0000-00-00 00:00:00"){
								echo('<div class="z-search-link-date">Updated #dateformat(c.__dateModified, "m/d/yy")#</div>');
							}
							if(hasImage){
								echo('</div>');
							}
							//<div class="z-search-link-image"></div>
						echo('</div>');
					 }
					 echo('</div>');
				}
			}
		}
	}
	if(not structkeyexists(form, 'autosearch')){
		savecontent variable="navigation"{
			if(form.zIndex GT 1 or rs2.hasMoreRecords){
				echo('<div class="zSearchNavDiv">');
				if(form.zIndex NEQ 1){
					echo('<a class="zSearchNavBack" href="##" onclick="getSearchResults(#form.groupId#, #max(1, form.zIndex-1)#); return false;">Previous Page</a>');
				}
				if(rs2.hasMoreRecords and form.zIndex+1 LT 100){
					echo('<a class="zSearchNavNext" href="##" onclick="getSearchResults(#form.groupId#, #max(1, form.zIndex+1)#); return false;">Next Page</a>');
				}
				echo('</div>');
			}
		}
		rs.html=rs.html&navigation;
	}
	if(not structkeyexists(request.zsession, 'searchGroupStructCache')){
		request.zsession.searchGroupStructCache={};
	}
	if(not structkeyexists(request.zsession.searchGroupStructCache,  form.groupId)){
		request.zsession.searchGroupStructCache[form.groupId]={};
	}
	request.zsession.searchGroupStructCache[form.groupId]=searchCacheStruct;
	return rs;
	</cfscript>
</cffunction>

<cffunction name="ajaxGetPublicSearchCriteria" output="yes" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	rs=this.getPublicSearchCriteria();
	application.zcore.functions.zReturnJson(rs); 
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="setupSearchCache" output="no" localmode="modern" access="public">
	<cfscript>
	application.zcore.functions.zNoCache();
	form.groupId=application.zcore.functions.zso(form, 'groupId', true);
	form.clearCache=application.zcore.functions.zso(form, 'clearCache', false, false);
	request.zsession.searchLastGroupId=form.groupId;
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	if(not structkeyexists(request.zsession, 'searchGroupStructCache')){
		request.zsession.searchGroupStructCache={};
	}
	if(not structkeyexists(request.zsession.searchGroupStructCache,  form.groupId) or form.clearCache){
		request.zsession.searchGroupStructCache[form.groupId]={};
	}
	if(structkeyexists(request.zsession.searchGroupStructCache[form.groupId], 'zIndex')){
		rs.zIndex=request.zsession.searchGroupStructCache[form.groupId].zIndex;
	}else{
		rs.zIndex=1;
	}
	if(form.zIndex GTE 100 or form.zIndex LT 1){
		form.zIndex=1; // don't allow pagination for more then the first 1000 results.
	}
	request.zsession.searchGroupStructCache[form.groupId].zIndex=rs.zIndex;
	</cfscript>
</cffunction>

<cffunction name="getPublicSearchCriteria" output="yes" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	db=request.zos.queryObject;
	form.disableSidebar=application.zcore.functions.zso(form, 'disableSidebar', false, '1');
	form.embeddedSearchForm=application.zcore.functions.zso(form, 'embeddedSearchForm', false, false);
	variables.setupSearchCache();
	if(form.embeddedSearchForm){
		onSubmit="this.target='_top'; this.action='#request.zos.currentHostName#/z/misc/search-site/search?autosearch=1&groupId=#form.groupId#'; return true;";
		onchange="";
	}else{
		onSubmit="try{ getSearchResults(#form.groupId#, 0); }catch(e){console.log(e);} return false;";
		onchange="getDelayedSearchResults();";
	}
	structappend(form, request.zsession.searchGroupStructCache[form.groupId], true);
	rs={success:true, groupId: form.groupId};
	if(form.groupId EQ 0){
		rs.title="Search Everything";
		savecontent variable="rs.html"{
			echo('
			<form id="searchForm#form.groupId#" data-ajax="false" action="" onsubmit="#onSubmit#" method="post">
			Keyword Search:<br />
			<input type="text" name="searchtext" id="zSearchTextInput" onkeyup="#onchange#" onpaste="#onchange#" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" />');
			if(form.disableSidebar EQ 1){
				echo('<button type="submit" class="zSearchCriteriaButtonSmall" name="publicSearchSubmit1">Search</button>');
			}else{
				echo('<br /><br /><button type="submit" class="zSearchCriteriaButton" name="publicSearchSubmit1">Search</button>');
			}
			echo('</form>');
		}
		return rs;
	}
	if(form.groupId EQ ""){
		rs.success=false;
		rs.errorMessage="form.groupId is required.";
		return rs;
	}
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_id = #db.param(form.groupId)# and 
	site_option_group_public_searchable = #db.param(1)# and 
	site_option_group_deleted = #db.param(0)# ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		rs.success=false;
		rs.errorMessage="This group is not searchable by the public.";
		return rs;
	}
	rs.title="Search "&qGroup.site_option_group_display_name&"(s)";
	
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_id = #db.param(form.groupId)# and 
	site_option_public_searchable = #db.param(1)# and 
	site_option_deleted = #db.param(0)#
	ORDER BY site_option_sort ASC";
	qOption=db.execute("qOption");
	if(qOption.recordcount EQ 0){
		rs.success=false;
		rs.errorMessage="No public search criteria are available for this group.";
		return rs;
	}
	savecontent variable="rs.html"{
		echo('<form id="searchForm#form.groupId#" data-ajax="false" action="" onsubmit="#onSubmit#" method="post">');
		//echo("Group Id: "&form.groupId);
		optionStruct={};
		for(row in qOption){
			optionStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			dataStruct=currentCFC.onBeforeListView(row, optionStruct[row.site_option_id], form);
			value=currentCFC.getListValue(dataStruct, optionStruct[row.site_option_id], application.zcore.functions.zso(form, "newvalue"&row.site_option_id));
			if(value EQ ""){
				value=row.site_option_default_value;
			}
			labelStruct[row.site_option_name]=value;
		}
		for(row in qOption){
			echo('<div class="zSearchCriteriaField">'&row.site_option_display_name&"<br />");
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			var rs2=currentCFC.getSearchFormField(row, optionStruct[row.site_option_id], 'newvalue', form, application.zcore.functions.zso(form, "newvalue"&row.site_option_id), "#onchange#");
			echo(rs2&"</div>");
			echo('<input type="hidden" name="siteOptionGroupId" value="'&row.site_option_id&"|"&row.site_option_group_id&'" />');
		}
		// get sub-groups and show them as divided sections:
		db.sql="select site_option_group_display_name, site_option_group_id from #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id = #db.param(form.groupId)# and 
		site_option_group_public_searchable = #db.param(1)# and 
		site_option_group_deleted = #db.param(0)#
		ORDER BY site_option_group_display_name ASC";
		qChildGroup=db.execute("qChildGroup");
		arrChildGroupID=[];
		childGroupStruct={};
		for(row in qChildGroup){
			arrayAppend(arrChildGroupID, row.site_option_group_id);	
			childGroupStruct[row.site_option_group_id]=row;
		}
		db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_id IN (#db.trustedSQL("'"&arrayToList(arrChildGroupId, "','")&"'")#) and 
		site_option_public_searchable = #db.param(1)# and 
		site_option_deleted = #db.param(0)#
		ORDER BY 
		FIELD(site_option_group_id, #db.trustedSQL("'"&arrayToList(arrChildGroupId, "','")&"'")#), 
		site_option_sort ASC";
		qChildOption=db.execute("qChildOption");
		lastGroupId="0";
		optionChildStruct={};
		groupForceOpenStruct={};
		for(row in qChildOption){
			optionChildStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			dataStruct=currentCFC.onBeforeListView(row, optionChildStruct[row.site_option_id], form);
			value=currentCFC.getListValue(dataStruct, optionChildStruct[row.site_option_id], application.zcore.functions.zso(form, "newvalue"&row.site_option_id));
			if(not structkeyexists(groupForceOpenStruct, row.site_option_group_id)){
				groupForceOpenStruct[row.site_option_group_id]="";
			}
			if(value EQ ""){
				value=row.site_option_default_value;
			}
			if(application.zcore.functions.zso(form, "newvalue"&row.site_option_id) NEQ ""){
				groupForceOpenStruct[row.site_option_group_id]=' style="display:block; " ';
			}
			labelStruct[row.site_option_name]=value;
		}
		currentRow=1;
		subGroupCount=1;
		if(qChildOption.recordcount NEQ 0){
			echo('<h2>Additional Options</h2><p>Click the boxes below to show more options.</p>');
			
		}
		for(row in qChildOption){
			if(lastGroupId NEQ row.site_option_group_id){
				lastGroupId=row.site_option_group_id;
				if(currentRow NEQ 1){
					echo('</div>');
				}
				toggleHTML="+";
				if(groupForceOpenStruct[row.site_option_group_id] NEQ ""){
					toggleHTML="-";
				}
				echo('<a href="##" class="zSearchCriteriaSubGroup" data-group-id="#row.site_option_group_id#" id="zSearchCriteriaSubGroup#row.site_option_group_id#"><span class="zSearchCriteriaSubGroupLabel" data-group-id="#row.site_option_group_id#">'&childGroupStruct[row.site_option_group_id].site_option_group_display_name&'</span><span class="zSearchCriteriaSubGroupToggle" id="zSearchCriteriaSubGroupToggle#row.site_option_group_id#" data-group-id="#row.site_option_group_id#">#toggleHTML#</span></a><div class="zSearchCriteriaSubGroupContainer" id="zSearchCriteriaSubGroupContainer#row.site_option_group_id#" #groupForceOpenStruct[row.site_option_group_id]#>');
			}
			echo('<div class="zSearchCriteriaField">'&row.site_option_display_name&"<br />");
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			var rs2=currentCFC.getSearchFormField(row, optionChildStruct[row.site_option_id], 'newvalue', form, application.zcore.functions.zso(form, "newvalue"&row.site_option_id), "#onchange#");
			echo(rs2&"</div>");
			echo('<input type="hidden" name="siteOptionGroupId" value="'&row.site_option_id&"|"&row.site_option_group_id&'" />');
			currentRow++;
		}
		echo('</div>');
		
		echo('<div style="width:100%; float:left;"><button type="submit" class="zSearchCriteriaButton" name="publicSearchSubmit1">Search</button>');
		if(not form.embeddedSearchForm){
		 	echo('<button type="reset" class="zSearchCriteriaButton" onclick="getSearchCriteria(document.getElementById(''zSearchTrackerGroupId'').value, true);" name="publicSearchReset">Reset</button></div>');
		}
		echo('</form>');
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	application.zcore.functions.z301Redirect("/z/misc/search-site/search?searchtext="&application.zcore.functions.zso(form, 'searchtext'));
	var temppageNav=0;
	
		var db=request.zos.queryObject;
		
		</cfscript>
    <cfsavecontent variable="temppageNav">
        <a href="#request.zos.currentHostName#">Home</a> / 
</cfsavecontent>
    <cfscript>
	application.zcore.template.setTag("title","Search Entire Site");
	application.zcore.template.setTag("pagetitle","Search Entire Site");
	application.zcore.template.setTag("pagenav",temppageNav);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	
	this.searchForm();
	if(structkeyexists(form, 'action') and structkeyexists(form, 'searchtext')){
		application.zcore.functions.zRedirect('/z/misc/search-site/results?searchtext='&urlencodedformat(form.searchtext));
	}
    </cfscript>
   <cfif structkeyexists(form, 'updateContentCache') and request.zos.isdeveloper>
		<cfif request.zos.globals.datasource NEQ "#request.zos.zcoreDatasource#">
           <cfsavecontent variable="db.sql">
            SELECT * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
			WHERE content_deleted=#db.param('0')# and 
			content.site_id = #db.param(request.zos.globals.id)# 
            </cfsavecontent>
            <cfscript>
            qC=db.execute("qC");
            </cfscript>
            <cfloop query="qC">
            <cfscript>
			cns=qc.content_name&" "&qc.content_id&" ";
			if(isDefined('qc.content_address')){
				cns&=qc.content_address&" ";
			}
			cns&=qc.content_text;
			</cfscript>
            <cfsavecontent variable="db.sql">
            UPDATE #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
			SET content_search = #db.param(application.zcore.functions.zCleanSearchText(cns,true))# 
			where content_id = #db.param(qc.content_id)# and 
			content.site_id=#db.param(request.zos.globals.id)# 
            </cfsavecontent>
			<cfscript>
			qC2=db.execute("qC2");
			</cfscript>
            </cfloop>
        </cfif>
        <!--- update all sites --->
       <cfsavecontent variable="db.sql">
        SELECT * from #request.zos.queryObject.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE blog.site_id <> #db.param('0')# and 
		blog_deleted = #db.param(0)#
        </cfsavecontent>
		<cfscript>
        qC=db.execute("qC");
        </cfscript>
        <cfloop query="qC">
        	<cfscript>
			if(left(qc.blog_summary,100) NEQ left(qc.blog_story,100)){
				rs=application.zcore.functions.zCleanSearchText(qc.blog_title&' '&qc.blog_summary&' '&qc.blog_story,true);
			}else{
				rs=application.zcore.functions.zCleanSearchText(qc.blog_title&' '&qc.blog_summary&' '&qc.blog_story,true);
			}
			</cfscript>
            <cfsavecontent variable="db.sql">
            UPDATE #request.zos.queryObject.table("blog", request.zos.zcoreDatasource)# blog 
			SET blog_search = #db.param(rs)# 
			where blog_id = #db.param(qc.blog_id)# and 
			blog.site_id #db.param(qc.site_id)#
            </cfsavecontent>
			<cfscript>
            qC2=db.execute("qC2");
            </cfscript>
        </cfloop>
    
    </cfif>
    
    
</cffunction>

<cffunction name="searchForm" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.zNoCache();
	form.searchtext=application.zcore.functions.zso(form, 'searchtext');
	if(not isSimpleValue(form.searchtext)){
		form.searchtext="";
	}
	</cfscript>
	<form action="/z/misc/search-site/results" method="get" style="margin:0px; padding:0px;">
	<table>
	<tr>
	<td style="font-size:14px; padding:0px;">Enter a search phrase: <input type="text" name="searchtext" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" style="font-size:14px; width:200px; padding:5px;" /></td><td style="padding-left:10px;"><button type="submit" name="submitForm" style="font-size:14px; padding:5px;">Search Site</button></td>
	</tr>
	</table>
	<input type="hidden" name="action" value="search" />
	</form><br />
</cffunction>
    
<cffunction name="results" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.zNoCache();
	var propCodes=0;
	var perpage=0;
	var curQuery=0;
	var checkMLSNumber=0;
	var searchTextOriginal=0;
	var found=0;
	var qSearch={};
	var propertyHTML3=0;
	var prevDots=0;
	var next=0;
	var ofs=0;
	var prev=0;
	var pos=0;
	var tempId=0;
	var qBlog=0;
	var n22=0;
	var i=0;
	var qM3=0;
	var arrM=0;
	var qM4=0;
	var propDisplayCom=0;
	var perpageDefault=0;
	var qSearch2={};
	var qSearchCount2={};
	var arrM2=0;
	var searchTextOReg=0;
	var specialCodes=0;
	var qBlogCount=0;
	var ss=0;
	var qSearchCount={};
	var temppageNav=0;
	var qM2=0;
	var searchStructData=0;
	var searchStruct=0;
	var enableRedirects=0;
	var g2=0;
	var searchTextReg=0;
	var thereAreResults=0;
	var propertyDataCom=0;
	var mls_id=0;
	var titleStruct=0;
	var arrSearch=0;
	var cT=0;
	var rs2=0;
	var newMLSdataStruct=0;
	var searchNav=0;
	var link=0;
	var tempStruct=0;
	var propertyLink=0;
	var t493=0;
	var g=0;
	var returnStruct=0;
	var notMLS=0;
	var theSearchResultText=0;
	var idx=0;
	var arrMM=0;
	var r1=0;
	var qM=0;
	var t99=0;
	var newMLSdataStruct2=0;
	var propertyHTML4=0;
	var ts=0;
	var db=request.zos.queryObject;
	application.zcore.template.setTag("title", "Site Search");
	application.zcore.template.setTag("pagetitle", "Site Search");
	</cfscript>
	<cfsavecontent variable="temppageNav">
	<a href="#request.zos.currentHostName#">Home</a> / 
	</cfsavecontent>
	<cfscript>
	this.searchForm();
	
	perpageDefault=10;
	form.zIndex=application.zcore.functions.zso(form, 'zIndex',false,1);
	if(form.zIndex GT 100){
		application.zcore.functions.z301Redirect(request.cgi_script_name&"?action=search&searchtext=#application.zcore.functions.zso(form, 'searchtext')#&zIndex=100&zsid=#request.zsid#");
	}
	enableRedirects=false;
	if(request.cgi_script_name EQ '/z/misc/search-site/index'){
		enableRedirects=true;
		if(structkeyexists(form, 'customheader')){
			application.zcore.template.setTag("title",form.customheader);//"Unbelievable Pricing on these #form.searchtext# listings");
			application.zcore.template.setTag("pagetitle",form.customheader);//"Unbelievable Pricing on these #form.searchtext# listings");
		}else{
			application.zcore.template.setTag("title","Search Results");
			application.zcore.template.setTag("pagetitle","Search Results");
		}
		application.zcore.template.setTag("pagenav",temppageNav);
	}
	
	ss=StructNew();
	// required
	form.searchtext=trim(application.zcore.functions.zso(form, 'searchtext'));
	form.searchtext=application.zcore.functions.zCleanSearchText(form.searchtext,true);
	if(len(form.searchtext) LTE 2){
		application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
		if(enableRedirects){
			application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
		}
	}
	</cfscript>
	
	<cfscript>
	form.zsearchtexthighlight=form.searchtext;
	searchTextOriginal=rereplace(replace(replace(form.searchtext, '"', '', "all"), '+', ' ', 'all'), '\s', ' ', 'all');
	
	searchTextReg=rereplace(trim(form.searchtext),"[^A-Za-z0-9\s]*",".","ALL");
	searchTextOReg=rereplace(trim(searchTextOriginal),"[^A-Za-z0-9 ]*",".","ALL");
	</cfscript>
	<cfif len(form.searchtext) GT 2>
		<!--- http://www.brainbell.com/tutorials/MySQL/Using_MySQL_Regular_Expressions.htm
		you can use regular expression in queries!!!
		--->
		<cfscript>
		notMLS=false;
		arrM=listtoarray(searchTextOriginal,',');
		arrM2=listtoarray(searchTextOriginal,' ');
		for(i=1;i LTE arraylen(arrM2);i++){
			found=false;
			for(g=1;g LTE arraylen(arrM);g++){
				if(arrM[g] EQ arrM2[i]){
					found=true;
					break;
				}
			}
			if(found EQ false and trim(arrM2[i]) NEQ ''){
				arrayappend(arrM,arrM2[i]);
			}
		}
		for(i=1;i LTE arraylen(arrM);i++){
			arrM[i]=trim(arrM[i]);
		}
		propCodes=structnew();
		propCodes["Commercial"]="C";
		propCodes["Family"]="S";
		propCodes["Home"]="S";
		propCodes["House"]="S";
		propCodes["Homes"]="S";
		propCodes["Houses"]="S";
		propCodes["single-family"]="S";
		propCodes["multi-family"]="D";
		propCodes["multi"]="D";
		propCodes["condo"]="M";
		propCodes["Condominium"]="M";
		propCodes["condos"]="M";
		propCodes["Condominiums"]="M";
		propCodes["Townhouse"]="M";
		propCodes["Townhouses"]="M";
		propCodes["Townhome"]="M";
		propCodes["Townhomes"]="M";
		specialCodes=structnew();
		specialCodes["bed"]="BR";
		specialCodes["beds"]="BR";
		specialCodes["BR"]="BR";
		specialCodes["bedroom"]="BR";
		specialCodes["bedrooms"]="BR";
		specialCodes["room"]="BR";
		specialCodes["rooms"]="BR";
		specialCodes["bath"]="BA";
		specialCodes["ba"]="BA";
		specialCodes["bathroom"]="BA";
		specialCodes["bathrooms"]="BA";
		specialCodes["pool"]="pool";
		specialCodes["pools"]="pool";
		// bedroom / bathroom
		searchStructData=structnew();
		searchStructData.surrounding_cities=1;
		checkMLSNumber=false;
		if(arraylen(arrM) GTE 1){
			if(isnumeric(arrM[1])){
				checkMLSNumber=true;
			}else{
				n22=rereplace(arrM[1],"([0-9]*)","","ALL");
				if(len(n22)+2 LTE len(arrM[1])){
					checkMLSNumber=true;
				}
			}
		}
		for(i=1;i LTE arraylen(arrM);i++){
			if(isnumeric(arrM[i]) and arrM[i] GT 100){
				checkMLSNumber=true;
			}
			if(structkeyexists(propCodes,arrM[i])){
				searchStructData.property_type_code=propCodes[arrM[i]];
				continue;
			}
			if(structkeyexists(specialCodes,arrM[i])){
				if(specialCodes[arrM[i]] EQ 'BR' and i NEQ 1 and isnumeric(arrM[i-1])){
					searchStructData.bedrooms=arrM[i-1];
					searchStructData.exact_match=1;
					
				}else if(specialCodes[arrM[i]] EQ 'BA' and i NEQ 1 and isnumeric(arrM[i-1])){
					searchStructData.bathrooms=arrM[i-1];
					searchStructData.exact_match=1;
				}else if(specialCodes[arrM[i]] EQ 'pool'){
					searchStructData.has_pool=1;
				}
				continue;
			}
		}	
		</cfscript> 
		<cfif application.zcore.app.siteHasApp("content")>
			<cfsavecontent variable="db.sql">
			SELECT count(content_id) as count
			FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content
			<cfif application.zcore.app.siteHasApp("listing")>, 
				#request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search
				WHERE mls_saved_search.mls_saved_search_id = content.content_saved_search_id and 
				mls_saved_search.site_id = content.site_id and 
				mls_saved_search_deleted = #db.param(0)# and 
			<cfelse>
				WHERE 
			</cfif>
			((
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or
				MATCH(content_search) AGAINST (#db.param('+#replace(form.searchtext,' ',' +','ALL')#')# IN BOOLEAN MODE) 
			<cfelse>
				content_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
			</cfif>
			) or (
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or 
				MATCH(content_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE)
			<cfelse>
				content_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
			</cfif>
			)) 
			<cfif isDefined('request.excludeContentId')>
				and content_id <> #db.param(request.excludeContentId)#
			</cfif>
			and content.site_id = #db.param(request.zos.globals.id)# 
			<cfif application.zcore.app.siteHasApp("listing")>
				<cfif isDefined('searchStructData.bedrooms')>
					and search_bedrooms_low >= #db.param(searchStructData.bedrooms)# 
					and search_bedrooms_high <= #db.param(searchStructData.bedrooms)# 
				</cfif>
				<cfif isDefined('searchStructData.bathrooms')>
					and search_bathrooms_low >= #db.param(searchStructData.bathrooms)# 
					and search_bathrooms_high <= #db.param(searchStructData.bathrooms)# 
				</cfif> 
			</cfif>
			and content_for_sale = #db.param('1')# and 
			content_hide_link =#db.param('0')# and 
			content_deleted=#db.param('0')# 
			</cfsavecontent>
			<cfscript>
			qSearchCount2=db.execute("qSearchCount2");
			</cfscript>
			<cfsavecontent variable="db.sql">
			SELECT *
			<cfif application.zcore.enableFullTextIndex> , 
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) as score , 
				MATCH(content_search) AGAINST (#db.param(searchTextOriginal)#) as score2 
			</cfif>
			FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
			<cfif application.zcore.app.siteHasApp("listing")>, 
				#request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search
				WHERE mls_saved_search.mls_saved_search_id = content.content_saved_search_id and 
				mls_saved_search.site_id = content.site_id and 
				mls_saved_search_deleted = #db.param(0)# and 
			<cfelse>
				WHERE 
			</cfif>
			content_deleted = #db.param(0)# and 
			((
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or
				MATCH(content_search) AGAINST (#db.param('+#replace(form.searchtext,' ',' +','ALL')#')# IN BOOLEAN MODE) 
			<cfelse>
				content_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
			</cfif>
			) or (
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or 
				MATCH(content_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE)
			<cfelse>
				content_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
			</cfif>
			)) 
			<cfif isDefined('request.excludeContentId')>
				and content_id <> #db.param(request.excludeContentId)#
			</cfif>
			and content.site_id = #db.param(request.zos.globals.id)# 
			<cfif application.zcore.app.siteHasApp("listing")>
				<cfif isDefined('searchStructData.bedrooms')>
					and search_bedrooms_low >= #db.param(searchStructData.bedrooms)# 
					and search_bedrooms_high <= #db.param(searchStructData.bedrooms)# 
				</cfif>
				<cfif isDefined('searchStructData.bathrooms')>
					and search_bathrooms_low >= #db.param(searchStructData.bathrooms)# 
					and search_bathrooms_high <= #db.param(searchStructData.bathrooms)# 
				</cfif> 
			</cfif>
			and content_for_sale = #db.param('1')# and 
			content_hide_link =#db.param('0')# and 
			content_deleted=#db.param('0')# 
			
			<cfif application.zcore.enableFullTextIndex>
				ORDER BY score2 DESC, score DESC  
			</cfif>
			LIMIT #db.param(perpageDefault*(form.zIndex-1))#, #db.param(perpageDefault)# 
			</cfsavecontent>
			<cfscript>
			qSearch2=db.execute("qSearch2");
			</cfscript>
		
		<cfelse>
			<cfscript>
			qSearchCount2.recordcount=0;
			qSearch2.recordcount=0;
			</cfscript>
		</cfif>
		<cfif request.zos.globals.datasource NEQ "#request.zos.zcoreDatasource#" and application.zcore.app.siteHasApp("content") EQ false>
			<cfsavecontent variable="db.sql">
			SELECT count(content_id) as count
			FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content WHERE 
			content_deleted = #db.param(0)# and 
			((
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or 
				MATCH(content_search) AGAINST (#db.param('+#replace(form.searchtext,' ','* +','ALL')#*')# IN BOOLEAN MODE) 
			<cfelse>
				content_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
			</cfif>
			) or (
			<cfif application.zcore.enableFullTextIndex>
				MATCH(content_search) AGAINST (#db.param(searchTextOriginal)#) or 
				MATCH(content_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE)
			<cfelse>
				content_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
			</cfif>
			)) 
			<cfif isDefined('request.excludeContentId')>
				and content_id <> #db.param(request.excludeContentId)#
			</cfif>
			and 
			site_id = #db.param(request.zos.globals.id)# 
			<cfif isDefined('searchStructData.bedrooms')>
				and search_bedrooms = #db.param(searchStructData.bedrooms)# 
			</cfif>
			<cfif isDefined('searchStructData.bathrooms')>
				and search_bathrooms = #db.param(searchStructData.bathrooms)# 
			</cfif> 
			and content_for_sale = #db.param('1')# and 
			content_hide_link =#db.param('0')#
		</cfsavecontent>
		<cfscript>
		qSearchCount=db.execute("qSearchCount");
		</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT *
		<cfif application.zcore.enableFullTextIndex> , 
			MATCH(content_search) AGAINST (#db.param(form.searchtext)#) as score , 
			MATCH(content_search) AGAINST (#db.param(searchTextOriginal)#) as score2 
		</cfif>
		FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content WHERE 
		content_deleted = #db.param(0)# and 
		((
		<cfif application.zcore.enableFullTextIndex>
			MATCH(content_search) AGAINST (#db.param(form.searchtext)#) or 
			MATCH(content_search) AGAINST (#db.param('+#replace(form.searchtext,' ','* +','ALL')#*')# IN BOOLEAN MODE) 
		<cfelse>
			content_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
		</cfif>
		) or (
		<cfif application.zcore.enableFullTextIndex>
			MATCH(content_search) AGAINST (#db.param(searchTextOriginal)#) or 
			MATCH(content_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE)
		<cfelse>
			content_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
		</cfif>
		)) 
		<cfif isDefined('request.excludeContentId')>
			and content_id <> #db.param(request.excludeContentId)#
		</cfif>
		and 
		site_id = #db.param(request.zos.globals.id)# 
		<cfif isDefined('searchStructData.bedrooms')>
			and search_bedrooms = #db.param(searchStructData.bedrooms)# 
		</cfif>
		<cfif isDefined('searchStructData.bathrooms')>
			and search_bathrooms = #db.param(searchStructData.bathrooms)# 
		</cfif> 
		and content_for_sale = #db.param('1')# and 
		content_hide_link =#db.param('0')#
		<cfif application.zcore.enableFullTextIndex>
			ORDER BY score2 DESC, score DESC  
		</cfif>
		LIMIT #db.param(perpageDefault*(form.zIndex-1))#, #db.param(perpageDefault)# 
		</cfsavecontent>
		<cfscript>
		qSearch=db.execute("qSearch");
		</cfscript>
		<cfelse>
			<cfscript>
			qSearchCount.recordcount=0;
			qSearch.recordcount=0;
			</cfscript>
		</cfif>
		<cfscript>
		// you must have a group by in your query or it may miss rows
		ts=structnew();
		ts.image_library_id_field="blog.blog_image_library_id";
		ts.count = 1; // how many images to get
		rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
		</cfscript> 
		<cfsavecontent variable="db.sql">
		SELECT count(blog_id) as count
		from #db.table("blog", request.zos.zcoreDatasource)# blog
		WHERE 
		blog_deleted = #db.param(0)# and 
		((
		<cfif application.zcore.enableFullTextIndex>
			MATCH(blog_search) AGAINST (#db.param(form.searchtext)#) or 
			MATCH(blog_search) AGAINST (#db.param("+#replace(form.searchtext,' ',' +','ALL')#")# IN BOOLEAN MODE)
		<cfelse>
			blog_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
		</cfif> 
		) or (
		<cfif application.zcore.enableFullTextIndex>
			MATCH(blog_search) AGAINST (#db.param(searchTextOriginal)#) or 
			MATCH(blog_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE) 
		<cfelse>
			blog_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
		</cfif>
		))
		and blog.site_id = #db.param(request.zos.globals.id)# 
		</cfsavecontent>
		<cfscript>
		qBlogCount=db.execute("qBlogCount");
		</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT * 
		<cfif application.zcore.enableFullTextIndex> , 
			MATCH(blog_search) AGAINST (#db.param(form.searchtext)#) as score , 
			MATCH(blog_search) AGAINST (#db.param(searchTextOriginal)#) as score2 
		</cfif>
		
		#db.trustedsql(rs2.select)#
		FROM #request.zos.queryObject.table("blog", request.zos.zcoreDatasource)# blog  
		#db.trustedsql(rs2.leftJoin)#
		left join #request.zos.queryObject.table("blog_category", request.zos.zcoreDatasource)# blog_category on 
		blog_category.blog_category_id = blog.blog_category_id and 
		blog_category.site_id = blog.site_id and 
		blog_category_deleted = #db.param(0)# 
		LEFT JOIN #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user ON 
		blog.user_id = user.user_id  and 
		user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("blog.user_id_siteIDType"))# and 
		user_deleted = #db.param(0)#
		WHERE 
		blog_deleted = #db.param(0)# and 
		((
		<cfif application.zcore.enableFullTextIndex>
			MATCH(blog_search) AGAINST (#db.param(form.searchtext)#) or 
			MATCH(blog_search) AGAINST (#db.param('+#application.zcore.functions.zescape(replace(form.searchtext,' ',' +','ALL'))#')# IN BOOLEAN MODE)
		<cfelse>
			blog_search like #db.param('%#replace(form.searchtext,' ','%','ALL')#%')#
		</cfif> 
		) or (
		<cfif application.zcore.enableFullTextIndex>
			MATCH(blog_search) AGAINST (#db.param(searchTextOriginal)#) or 
			MATCH(blog_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ',' +','ALL')#')# IN BOOLEAN MODE) 
		<cfelse>
			blog_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
		</cfif>
		))
		and blog.site_id = #db.param(request.zos.globals.id)# 
		GROUP BY blog.blog_id 
		<cfif application.zcore.enableFullTextIndex>
			ORDER BY score2 DESC, score DESC 
		</cfif>
		LIMIT #db.param(perpageDefault*(form.zIndex-1))#, #db.param(perpageDefault)# 
		</cfsavecontent>
		<cfscript>
		qBlog=db.execute("qBlog"); 
		</cfscript>
		
		<cfset thereAreResults=false>
		<cfscript>
		qM=structnew();
		qM2=structnew();
		qM.recordcount=0;
		qM2.recordcount=0;
		qM3=structnew();
		qM4=structnew();
		qM3.recordcount=0;
		qM4.recordcount=0;
		propertyHTML3="";
		propertyHTML4="";
		</cfscript>
		<cfif application.zcore.app.siteHasApp("listing")>
			<cfscript>	
			propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
			propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
			
			
			if(checkMLSNumber or find(" ",trim(searchTextOriginal)) EQ 0){
				ts = StructNew();
				ts.offset = form.zIndex-1;
				perpageDefault=10;
				perpage=10;
				perpage=max(1,min(perpage,100));
				ts.perpage = perpage;
				ts.distance = 30; // in miles
				ts.disableCount=true;
				//ts.debug=true;
				tempId = application.zcore.status.getNewId();	
				tempStruct=StructNew();	
				arrMM=arraynew(1);
				for(i=1;i LTE arraylen(arrM);i++){
					if(arrM[i] DOES NOT CONTAIN ' '){
						arrayappend(arrMM,application.zcore.functions.zescape(arrM[i]));
					}
				}
				//tempStruct.mls_numbers="'"&arraytolist(arrMM,"','")&"'";
				tempStruct.mls_numbers="listing.listing_id LIKE '%"&arraytolist(arrMM,"' or listing.listing_id LIKE '%")&"'";
				application.zcore.status.setStatus(tempId,false,tempStruct);
				ts.searchId=tempId;
				
				returnStruct = propertyDataCom.getProperties(ts);
				newMLSdataStruct=returnstruct;
				structdelete(variables,'ts');
				qM3.recordcount=returnstruct.count;
				if(returnStruct.count NEQ 0){	
				
					thereAreResults=true;
					searchStruct = StructNew();
					searchStruct.showString = "";
					searchStruct.indexName = 'zIndex';
					searchStruct.url = request.zos.listing.functions.getSearchFormLink();
					if(isDefined('tempId')){
						searchStruct.url &= "&searchId=#tempId#"; 
						searchStruct.index = form.zIndex;
					}else{
						searchStruct.index=1;
					}
					searchStruct.buttons = 5;
					searchStruct.count = returnStruct.count;
					searchStruct.perpage = perpageDefault;
					
					ts = StructNew();
					ts.dataStruct = returnStruct;
					ts.navStruct=searchStruct;
					ts.searchId=tempId;
					propDisplayCom.init(ts);
					propertyHTML3=propDisplayCom.display();
				}
			}
			
				
			ts = StructNew();
			ts.offset =0;
			perpageDefault=10;
			perpage=10;
			ts.perpage =10;// perpage;
			ts.distance = 30; // in miles
			ts.disableCount=true;
			//ts.debug=true;
			ts.searchcriteria=structnew();
			tempId = application.zcore.status.getNewId();	
			ts.searchcriteria.search_remarks=searchTextOriginal;
			
			for(i in searchStructData){
				ts.searchcriteria["search_"&i]=searchStructData[i];
			}
			application.zcore.status.setStatus(tempId,false,ts.searchcriteria);
			ts.searchId=tempId;
			
			returnStruct = propertyDataCom.getProperties(ts);
			newMLSdataStruct2=returnstruct;
			structdelete(variables,'ts');
			qM4.recordcount=returnstruct.count;
			if(returnStruct.count NEQ 0){	
			
				thereAreResults=true;
				searchStruct = StructNew();
				searchStruct.showString = "";
				searchStruct.indexName = 'zIndex';
				searchStruct.url = request.zos.listing.functions.getSearchFormLink();
				if(isDefined('tempId')){
					searchStruct.url &= "&searchId=#tempId#"; 
					searchStruct.index = form.zIndex;
				}else{
					searchStruct.index=1;
				}
				searchStruct.buttons = 5;
				searchStruct.count = returnStruct.count;
				searchStruct.perpage = perpageDefault;
				
				ts = StructNew();
				ts.dataStruct = returnStruct;
				ts.navStruct=searchStruct;
				ts.searchId=tempId;
				propDisplayCom.init(ts);
				propertyHTML4=propDisplayCom.display();
			}
		
			</cfscript>
		<cfelse>
			<cfscript>
			qM.recordcount=0;
			qM2.recordcount=0;
			</cfscript>
		</cfif>
		
		<hr size="1" /> 
		<cfif qSearch2.recordcount EQ 0 and qSearch.recordcount EQ 0 and qM.recordcount EQ 0 and qM2.recordcount EQ 0 and qM3.recordcount EQ 0 and qM4.recordcount EQ 0 and qBlog.recordcount EQ 0>
			<h2>No pages on our web site matched your search criteria. Please try something less specific.</h2> 
		<cfelse>
			<cfsavecontent variable="theSearchResultText">
			
			
			<cfif qBlog.recordcount NEQ 0>
				<h2>Matching results for &quot;#form.searchtext#&quot; in our blog</h2>
				<hr size="1" />
				<cfscript>
				
				// required
				searchStruct = StructNew();
				// optional
				searchStruct.showString = "";
				// allows custom url formatting
				//searchStruct.parseURLVariables = true;
				searchStruct.indexName = 'zIndex';
				searchStruct.url = request.cgi_script_name&"?action=search&searchtext=#URLEncodedformat(searchTextOriginal)#"; 
				searchStruct.buttons = 5;
				searchStruct.count = qBlogcount.count;
				// set from query string or default value
				searchStruct.index = form.zIndex;
				searchStruct.perpage = perpageDefault;
				// stylesheet overriding
				/*
				searchStruct.tableStyle = "property-nav";
				searchStruct.linkStyle = "property-nav";
				searchStruct.textStyle = "property-nav";
				searchStruct.highlightStyle = "property-nav-highlight";	
				*/
				searchNav=application.zcore.functions.zSearchResultsNav(searchStruct);
				
				arrSearch=listtoarray(form.searchtext," ");
				
				
				application.zcore.app.getAppCFC("blog").displayBlogSummaries(qBlog);
				</cfscript>
			
			</cfif>
		
		
		
		
		
		
		
		
		
		
		
			<cfif qSearch2.recordcount NEQ 0>
				<cfset thereAreResults=true>
				<h2>Matching results for &quot;#form.searchtext#&quot; in our site content</h2>
				<hr size="1" />
				<cfscript>
				
				// required
				searchStruct = StructNew();
				// optional
				searchStruct.showString = "";
				// allows custom url formatting
				//searchStruct.parseURLVariables = true;
				searchStruct.indexName = 'zIndex';
				searchStruct.url = request.cgi_script_name&"?action=search&searchtext=#URLEncodedformat(searchTextOriginal)#"; 
				searchStruct.buttons = 5;
				searchStruct.count = qsearchcount2.count;
				// set from query string or default value
				searchStruct.index = form.zIndex;
				searchStruct.perpage = perpageDefault;
				// stylesheet overriding
				/*
				searchStruct.tableStyle = "property-nav";
				searchStruct.linkStyle = "property-nav";
				searchStruct.textStyle = "property-nav";
				searchStruct.highlightStyle = "property-nav-highlight";	
				*/
				searchNav=application.zcore.functions.zSearchResultsNav(searchStruct);
				
				arrSearch=listtoarray(form.searchtext," ");
				if(arraylen(arrSearch) EQ 0){
					arrSearch[1]="";	
				}
				</cfscript>
				#searchNav#<hr size="1" />
				<cfloop query="qSearch2">
					<cfscript>
					link=qSearch2.content_unique_name;
					if(qSearch2.content_unique_name EQ ''){
						link="/#application.zcore.functions.zURLEncode(qSearch2.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qSearch2.content_id#.html";
					}
					
					if(enableRedirects){
						if(qSearch2.recordcount EQ 1 and qSearch.recordcount EQ 1 and qBlog.recordcount EQ 0){
							// the only match - autoredirect
							application.zcore.functions.zRedirect(link);
						}
					}
					cT="";
					if(qSearch2.content_summary neq ''){
						cT=qSearch2.content_summary;
					}else if(qSearch2.content_text NEQ ""){
						cT=rereplacenocase(qSearch2.content_text,"<.*?>", " ", 'ALL');
						pos=findnocase(arrSearch[1], cT);
						ofs=200;
						if(pos EQ 0){
							pos=1;
						}
						// find the phrase and go back and forwards.  
						prev=pos-ofs;
						next=pos+ofs;
						// find the previous space
						for(i=1;i<100;i++){
							prev--;
							if(prev LT 1){
								prev=1;
								break;
							}
							if(mid(cT,prev,1) EQ ' '){
								break;
							}
						}
						// find the next space
						for(i=1;i<100;i++){
							next++;
							if(next GT len(cT)){
								next=max(1,len(cT));
								break;
							}
							if(mid(cT,next,1) EQ ' '){
								break;
							}
						}
						cT=mid(cT, prev, next-prev);
						prevDots=false;
						if(prev NEQ 1){
							prevDots=true;
						}
						if(next NEQ len(cT)){
							cT=cT&" ...";
						}
						if(prevDots){
							cT="..."&cT;
						}
					}
					if(structkeyexists(request,'arrSearchSiteLinks')){
						n2=content_name;
						pos=find("|",n2);
						if(pos NEQ 0){ 
							n2=trim(left(n2,pos-1)); 
						}
						arrayappend(request.arrSearchSiteLinks,'<a href="#link#">#n2#</a>');
					}
					t493=structnew();
					t493.contentForceOutput=true;
					application.zcore.app.getAppCFC("content").setContentIncludeConfig(t493);
					application.zcore.app.getAppCFC("content").getPropertyInclude(qSearch2.content_id);
					</cfscript>
				</cfloop>
				#searchNav#
		
				<hr size="1" />
				<cfscript>
				//zdump(qsearch);
				//zdump(qsearchcount);
				</cfscript>
			</cfif>
		
		 
		
			<cfif qSearch.recordcount NEQ 0>
				<cfset thereAreResults=true>
				<h2>Matching results for &quot;#form.searchtext#&quot; in our site content</h2>
				<hr size="1" />
				<cfscript>
				
				// required
				searchStruct = StructNew();
				// optional
				searchStruct.showString = "";
				// allows custom url formatting
				//searchStruct.parseURLVariables = true;
				searchStruct.indexName = 'zIndex';
				searchStruct.url = request.cgi_script_name&"?action=search&searchtext=#URLEncodedformat(searchTextOriginal)#"; 
				searchStruct.buttons = 5;
				searchStruct.count = qsearchcount.count;
				// set from query string or default value
				searchStruct.index = form.zIndex;
				searchStruct.perpage = perpageDefault;
				// stylesheet overriding
				/*
				searchStruct.tableStyle = "property-nav";
				searchStruct.linkStyle = "property-nav";
				searchStruct.textStyle = "property-nav";
				searchStruct.highlightStyle = "property-nav-highlight";	
				*/
				searchNav=application.zcore.functions.zSearchResultsNav(searchStruct);
				
				arrSearch=listtoarray(form.searchtext," ");
				if(arraylen(arrSearch) EQ 0){
					arrSearch[1]="";	
				}
				</cfscript>
				#searchNav#<hr size="1" />
				<cfloop query="qSearch">
					<cfscript>
					link=content_unique_name;
					if(content_unique_name EQ ''){
					link="/#application.zcore.functions.zURLEncode(content_name,'-')#-#request.zos.globals.contentUrlId#-#content_id#.html";
					}
					
					if(enableRedirects){
						if(qSearch.recordcount EQ 1 and qBlog.recordcount EQ 0 and qSearch2.recordcount EQ 0){
							// the only match - autoredirect
							application.zcore.functions.zRedirect(link);
						}
					}
					cT="";
					if(content_summary neq ''){
						cT=content_summary;
					}else if(content_text NEQ ""){
						cT=rereplacenocase(content_text,"<.*?>", " ", 'ALL');
						pos=findnocase(arrSearch[1], cT);
						ofs=200;
						if(pos EQ 0){
							pos=1;
						}
						// find the phrase and go back and forwards.  
						prev=pos-ofs;
						next=pos+ofs;
						// find the previous space
						for(i=1;i<100;i++){
							prev--;
							if(prev LT 1){
								prev=1;
								break;
							}
							if(mid(cT,prev,1) EQ ' '){
								break;
							}
						}
						// find the next space
						for(i=1;i<100;i++){
							next++;
							if(next GT len(cT)){
								next=max(1,len(cT));
								break;
							}
							if(mid(cT,next,1) EQ ' '){
								break;
							}
						}
						cT=mid(cT, prev, next-prev);
						prevDots=false;
						if(prev NEQ 1){
							prevDots=true;
						}
						if(next NEQ len(cT)){
							cT=cT&" ...";
						}
						if(prevDots){
							cT="..."&cT;
						}
					}
					
					if(structkeyexists(request,'arrSearchSiteLinks')){
						n2=content_name;
						pos=find("|",n2);
						if(pos NEQ 0){ 
							n2=trim(left(n2,pos-1)); 
						}
						arrayappend(request.arrSearchSiteLinks,'<a href="#link#">#n2#</a>');
					}
					</cfscript>
					<table style="width:100%;">
					<tr><cfif fileexists(request.absDomainHomeDir&'images/content/'&content_thumbnail)>
					<td style="vertical-align:top;padding-right:10px;"><a href="#link#"><img src="#request.absDomainSiteRoot&'/images/content/'##content_thumbnail#" /></a></td></cfif>
					<td style="vertical-align:top; "><h2><a href="#link#">#content_name#</a></h2>
					<cfif content_for_sale EQ '3'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is SOLD</span><br /><br /><cfelseif content_for_sale EQ '4'><span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is UNDER CONTRACT</span><br /><br /></cfif>
					<cfif isnull(content_datetime) EQ false><strong class="news-date">#DateFormat(content_datetime,'m/d/yyyy')#
					<cfif Timeformat(content_datetime,'HH:mm:ss') NEQ '00:00:00'>#TimeFormat(content_datetime,'h:mm tt')#</cfif></strong> <br /></cfif>
					#cT#
					<cfif content_price NEQ 0 and content_for_sale EQ 1><br /><span style="font-size:14px; font-weight:bold;">Priced at #dollarformat(content_price)#</span></cfif></td>
					</tr>
					<tr>
					<td colspan="2"><hr /></td></tr>
					</table> 
				</cfloop>
				#searchNav#
				
				<hr size="1" />
				<cfscript>
				//application.zcore.functions.zdump(qsearch);
				//application.zcore.functions.zdump(qsearchcount);
				</cfscript>
			</cfif>
		
		
		<cfif qM.recordcount NEQ 0>
			<cfset thereAreResults=true>
			<h2>The following MLS Numbers matched your search</h2>
			<hr size="1" />
			<cfloop query="qM" startrow="1" endrow="1">
				<cfscript>
				titleStruct = application.sitestruct[request.zos.globals.id].zrealestate.mls[qM.mls_id].functions.getTitle();
				propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#qM.mls_id#-#qM.mls_pid#.html';
				if(enableRedirects){
					if(qm.recordcount EQ 1 and qSearch2.recordcount EQ 0 and qSearch.recordcount EQ 0 and qBlog.recordcount EQ 0){
						application.zcore.functions.zRedirect(propertyLink);
					}
				}
				</cfscript>	
			</cfloop>
			#propertyHTML#
		</cfif>
		<cfif qM3.recordcount NEQ 0>
			<cfset thereAreResults=true>
			<h2>The following MLS Numbers matched your search</h2>
			<hr size="1" /> 
			<cfscript>
			for(row in newMLSdataStruct.arrData){

				mls_id=listgetat(row.listing_id,1,"-");
				idx=structnew();
				structappend(idx, request.zos.listingMlsComObjects[mls_id].baseGetDetails(row, 1), true);
				idx.listing_id=row.listing_id;
				titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
				propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
				if(enableRedirects){
					if(qm3.recordcount EQ 1 and qSearch2.recordcount EQ 0 and qSearch.recordcount EQ 0 and qBlog.recordcount EQ 0){
						application.zcore.functions.zRedirect(propertyLink);
					}
				}
				break;
			}
			</cfscript> 
			#propertyHTML3#
		</cfif>
		
		
		
		<cfif qM4.recordcount NEQ 0>
			<cfset thereAreResults=true>
			<h2>Matching results for &quot;#form.searchtext#&quot; in the entire MLS database</h2>
			<hr size="1" />
			<cfscript>
			for(row in newMLSdataStruct2.arrData){

				mls_id=listgetat(row.listing_id,1,"-");
				idx=structnew();
				structappend(idx, request.zos.listingMlsComObjects[mls_id].baseGetDetails(row, 1), true);
				idx.listing_id=row.listing_id;
				titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
				propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
				if(enableRedirects){
					if(qm4.recordcount EQ 1 and qSearch2.recordcount EQ 0 and qSearch.recordcount EQ 0 and qBlog.recordcount EQ 0){
						application.zcore.functions.zRedirect(propertyLink);
					}
				}
				break;
			}
			</cfscript> 
			#propertyHTML4#
		</cfif>
		
		
		</cfsavecontent>
		<cfscript>
		if(thereAreResults){
			t99=application.zcore.functions.zhighlightHTML(form.searchtext,theSearchResultText);
			writeoutput(t99);
		}
		</cfscript>
		</cfif> 
	
	</cfif>

</cffunction>
    
</cfoutput>
</cfcomponent>