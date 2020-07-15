<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	var i=0;
	var db=request.zos.queryObject;
	variables.searchCriteriaList="search_frontage,search_view,search_county,search_style,search_status,search_listing_type_id," &
	"search_listing_sub_type_id,search_parking,search_tenure,search_condition,search_liststatus";
	arrSearch=listToArray(variables.searchCriteriaList, ",");
	variables.searchCriteriaStruct={};
	variables.searchCriteriaSQLStruct={};
	for(i=1;i LTE arraylen(arrSearch);i++){
		variables.searchCriteriaStruct[arrSearch[i]]=true;
		variables.searchCriteriaSQLStruct[arrSearch[i]]=replace(arrSearch[i], 'search_', '');
	}
	variables.searchCriteriaSQLStruct["search_listing_type_id"]="listing_type";
	variables.searchCriteriaSQLStruct["search_listing_sub_type_id"]="listing_sub_type";
	form.mls_id1=application.zcore.functions.zso(form, 'mls_id1');
	form.mls_id2=application.zcore.functions.zso(form, 'mls_id2');
	form.searchCriteria=application.zcore.functions.zso(form, 'searchCriteria');
	form.searchCriteria2=application.zcore.functions.zso(form, 'searchCriteria2');
	if(form.method NEQ "index" and form.method NEQ "siteRemap"){
		if(not structkeyexists(variables.searchCriteriaStruct, form.searchCriteria) or not structkeyexists(variables.searchCriteriaStruct, form.searchCriteria2)){
			application.zcore.status.setStatus(request.zsid, "Search criteria must be selected.", form, true);
			application.zcore.functions.zRedirect("/z/listing/admin/remap-data/index?zsid=#request.zsid#");
		}
		db.sql="select mls_provider FROM #db.table("mls", request.zos.zcoreDatasource)# 
		where mls_id = #db.param(form.mls_id1)# and 
		mls_deleted=#db.param(0)#";
		variables.qM=db.execute("qM");
		db.sql="select mls_provider FROM #db.table("mls", request.zos.zcoreDatasource)# 
		where mls_id = #db.param(form.mls_id2)# and 
		mls_deleted=#db.param(0)# ";
		variables.qM2=db.execute("qM");
		if(variables.qM.recordcount EQ 0 or variables.qM2.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid MLS Provider.", form, true);
			application.zcore.functions.zRedirect("/z/listing/admin/remap-data/index?zsid=#request.zsid#");
		}
	}
	variables.backURL="/z/listing/admin/remap-data/index?mls_id1=#form.mls_id1#&mls_id2=#form.mls_id2#&searchCriteria=#form.searchCriteria#&searchCriteria2=#form.searchCriteria2#";
	</cfscript>
</cffunction>


<cffunction name="remapOfficeAgent" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	</cfscript>
	

	<h2>Office / Agent ID remap</h2>
	<p>These queries are no longer accurate because the agent/office tables were removed.</p>
	<p>Edit the following queries and manually update the listing application options and the associated users for each site.</p>
<textarea cols="100" rows="10" name="ccc2">
<!--- office --->
SELECT rets4_name, rets4_firmid oldOfficeId, rets26_office_0 newOfficeID, site.site_id, 
CONCAT("update `app_x_mls` set app_x_mls_office_id = '", rets26_office_0, "' where app_x_mls_id = '", app_x_mls_id, "' and site_id = '", app_x_mls.site_id, "'; ") `query`
 FROM (rets4_office, site )
LEFT JOIN app_x_mls ON mls_id = '4' AND app_x_mls_office_id <>'' AND app_x_mls.app_x_mls_office_id = rets4_office.rets4_firmid AND site.site_id = app_x_mls.site_id
LEFT JOIN rets26_office ON rets4_name = rets26_office_2 
WHERE 
app_x_mls.site_id IS NOT NULL AND 
site.site_id = app_x_mls.site_id  AND 
site_active='1'
GROUP BY oldOfficeId
LIMIT 0,1000;

<!--- agent --->
SELECT rets4_firstname, rets4_lastname, rets4_agentid oldAgentId, rets26_member_0 newAgentID, site.site_id, 
CONCAT("update `app_x_mls` set app_x_mls_agent_id = '", rets26_member_0, "' where app_x_mls_id = '", app_x_mls_id, "' and site_id = '", app_x_mls.site_id, "'; ") `query`
 FROM (rets4_agent, site )
LEFT JOIN app_x_mls ON mls_id = '4' AND app_x_mls_agent_id <>'' AND app_x_mls.app_x_mls_agent_id = rets4_agent.rets4_agentid AND site.site_id = app_x_mls.site_id
LEFT JOIN rets26_activeagent ON rets4_firstname = rets26_member_3 AND rets4_lastname = rets26_member_4 
WHERE  
app_x_mls.site_id IS NOT NULL AND 
site.site_id = app_x_mls.site_id  AND 
site_active='1'
GROUP BY oldAgentId
LIMIT 0,1000;

<!--- users alternate --->
SELECT 
rets26_member_0, rets4_agentid,
CONCAT('update `user` set member_mlsagentid=\',26-', REPLACE(REPLACE(rets26_member_0, ',4-', ''), ',', ''), ',\' where user_id = \'', user_id, '\' and site_id = \'', site_id, '\'; ') QUERY 
FROM `user` 
LEFT JOIN rets4_agent ON rets4_agentid = REPLACE(REPLACE(member_mlsagentid, ',4-', ''), ',', '') 
LEFT JOIN rets26_activeagent ON rets4_agentid = rets26_member_17
WHERE member_mlsagentid LIKE '%4-%';

<!--- users --->
SELECT user_first_name, user_last_name, member_mlsagentid oldAgentId, rets4_agentid oldAgentId2, rets26_member_0 newAgentID, site.site_id, 
CONCAT("update `user` set member_mlsagentid = ',26-", rets26_member_0, ",' where user_id = '", user.user_id, "' and site_id = '", user.site_id, "'; ") `query`
FROM (site, `user`)
LEFT JOIN app_x_mls ON mls_id = '4' AND site.site_id = app_x_mls.site_id 
LEFT JOIN rets4_agent ON rets4_agentid = REPLACE(REPLACE(member_mlsagentid, ',4-', ''), ',', '') 
LEFT JOIN rets26_activeagent ON rets4_firstname = rets26_member_3 AND rets4_lastname = rets26_member_4 
WHERE  
user.site_id = site.site_id AND 
user.member_mlsagentid<> '' AND 
app_x_mls.site_id IS NOT NULL AND 
site.site_id = app_x_mls.site_id  AND 
site_active='1'
GROUP BY oldAgentId
LIMIT 0,1000;


SELECT CONCAT("update app_x_mls set app_x_mls_agent_id='",rets26_member_0,"' where mls_id='26' and app_x_mls_agent_id='", app_x_mls_agent_id, "';") `query` FROM app_x_mls
LEFT JOIN rets26_activeagent ON rets26_member_17= app_x_mls_agent_id
 WHERE mls_id = '26' AND LENGTH(app_x_mls_agent_id) < 10 AND app_x_mls_agent_id<> ''; 
 
select CONCAT("update app_x_mls set app_x_mls_office_id='",rets26_office_0,"' where mls_id='26' and app_x_mls_office_id='", app_x_mls_office_id, "';") `query` from app_x_mls
LEFT JOIN rets26_office ON rets26_office_15 = app_x_mls_office_id
 where mls_id = '26' and length(app_x_mls_office_id) < 10 and app_x_mls_office_id<> '';


;careful not to run this query until ready to go live;
update `app_x_mls` set mls_id = '26' where mls_id='4' and site_id <> '-1';
</textarea>

</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var selectStruct=0;
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zStatusHandler(request.zsid, true);
	/*db.sql="SELECT * FROM app_x_mls, mls_saved_search 
	WHERE mls_id='11' AND 
	mls_saved_search.site_id = app_x_mls.site_id";
	select mls_id 1 and mls_id 2 and 1 search_field that has ids, then submit
	show all USED values for each mls, map left to right, then submit.
		query for used values
	*/
	db.sql="select * from #db.table("mls", request.zos.zcoreDatasource)# 
	WHERE mls_deleted = #db.param(0)# ";
	qMLS=db.execute("qMLS");
	
	writeoutput('<form class="zFormCheckDirty" action="/z/listing/admin/remap-data/select" method="get">
	<h2>Remap Real Estate Saved Search Data</h2>
	<h2>Step 1: Remap search values</h2>
	<p>Map each criteria from old to new mls for all search criteria (frontage, view, listing type, etc).</p>
	<table style="border-spacing:0px; " class="table-list"><tr><th>MLS From: </th><td class="table-white">');
	// build 2 select menus
	selectStruct = StructNew();
	selectStruct.name = "mls_id1";
	selectStruct.query = qMLS;
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
	selectStruct.queryValueField = "mls_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	
	writeoutput('</td></tr><th>MLS To: </th><td class="table-white">');
	selectStruct = StructNew();
	selectStruct.name = "mls_id2";
	selectStruct.query = qMLS;
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
	selectStruct.queryValueField = "mls_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput('</td></tr><tr><th>Search criteria from: </th><td class="table-white">');
	
	selectStruct = StructNew();
	selectStruct.name = "searchCriteria";
	selectStruct.listValues = variables.searchCriteriaList;
	selectStruct.listLabels = replace(selectStruct.listValues, 'search_', '', 'all');
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput('</td></tr><tr><th>Search criteria to: </th><td class="table-white">');
	
	selectStruct = StructNew();
	selectStruct.name = "searchCriteria2";
	selectStruct.listValues = variables.searchCriteriaList;
	selectStruct.listLabels = replace(selectStruct.listValues, 'search_', '', 'all');
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(selectStruct);
	
	writeoutput('</td></tr><tr><td>&nbsp;</td><td class="table-white"><input type="submit" name="submit1" value="Submit" /></td></tr></table>
	</form>');
	</cfscript>

	<hr />
	<h2>Step 2: Finalize MLS Change</h2>
	<div style="width:100%; float:left; padding-bottom:20px;">Select MLS ID
	<cfscript>
	db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# office 
	WHERE mls_status = #db.param(1)# and 
	mls_deleted = #db.param(0)# 
	ORDER BY mls_name";
	qMLS=db.execute("qMLS");
	selectStruct = StructNew();
	selectStruct.name = "mls_id";
	selectStruct.query = qMLS;
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryLabelField = "##mls_name## (##mls_id##)";
	selectStruct.queryValueField = "mls_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	</div>

	<p> 
		1. Manually remap all the office / agent id to new MLS: <a href="/z/listing/admin/remap-data/remapOfficeAgent" target="_blank">click here for example queries</a>.<br />
		<!--- 2. Select the MLS ID you are moving FROM above.<br />
		3. Click <a href="##" onclick="showAssociatedSites(); return false;" target="_blank">Show Associated Sites</a> to get a list of all sites using the selected mls_id.<br />
		4. Activate the new mls and deactivate the old mls that uses it under server manager applications for each site.<br /> --->
		2. Run <a href="/z/listing/admin/remap-data/index?zreset=all">zReset=all</a> and come back here.<br />
		3. Select the MLS ID you are moving TO above.<br />
		4. Click <a href="##" onclick="remapSites(); return false;">Remap Sites</a> and wait for it to complete.</p>

	<div style="width:100%; float:left; padding-bottom:10px;"><strong>Remap Sites Status:</strong> <div class="statusDiv">
		<cfif application.zcore.functions.zso(application.zcore, 'listingRemapCurrentSite') EQ "">
			Not running
		<cfelse>
			#application.zcore.functions.zso(application.zcore, 'listingRemapCurrentSite')&" | "&application.zcore.functions.zso(application.zcore, 'listingRemapProgress')#
		</cfif></div><br />
		<a href="/z/listing/admin/remap-data/cancelRemap" target="_blank">Cancel Remap</a></div>
	<script>
	function processRemapStatus(r){ 
		var r=eval('('+r+')');
		$(".statusDiv").html(r.message);

	}
	function showAssociatedSites(){ 
		if($("##mls_id").val() == ''){
			alert('You must select an MLS ID first.');
			return;
		}
		var v='/z/listing/admin/remap-data/remapSites?showList=1&mls_id='+$("##mls_id").val(); 
		window.open(v);
	}
	function showRemapStatus(){ 
		var obj={
			id:"ajaxCheckStatus",
			method:"get",
			ignoreOldRequests:true,
			callback:processRemapStatus,
			errorCallback:function(){
				alert('Check remap status failed');
			},
			url:"/z/listing/admin/remap-data/getRemapStatus"
		}; 
		zAjax(obj);
	} 
	var remapRunning=true;
	function remapSites(){ 
		if($("##mls_id").val() == ''){
			alert('You must select an MLS ID first.');
			return;
		}
		var status=$(".statusDiv")[0].innerText.trim();
		if(status.toLowerCase() != "not running"){
			alert("Remap Sites is already running.  Please cancel it before running it again.");
			return;
		}
		clearInterval(remapIntervalId);
		remapIntervalId=setInterval(showRemapStatus, 1000);
		$(".statusDiv").html("Starting...");
		var obj={
			id:"ajaxRemapSites",
			method:"get",
			ignoreOldRequests:true,
			callback:function(r){
				console.log(r);
				clearInterval(remapIntervalId);
				$(".statusDiv").html("Not running");
				alert('Remap sites is complete');
			},
			errorCallback:function(){
				alert('Remap sites failed');
				$(".statusDiv").html("Not running");
			},
			url:"/z/listing/admin/remap-data/remapSites?mls_id="+$("##mls_id").val()
		}; 
		zAjax(obj);

	}
	var remapIntervalId=0;
	zArrDeferredFunctions.push(function(){
		var status=$(".statusDiv")[0].innerText.trim();
		if(status.toLowerCase() != "not running"){
			remapRunning=true;
			remapIntervalId=setInterval(showRemapStatus, 1000);
		}
	});
	</script>
</cffunction>


<cffunction name="cancelRemap" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.listingRemapCancel=true;

	</cfscript>
	Remap Sites is set to be cancelled.<cfabort>
</cffunction>

<cffunction name="getRemapStatus" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	rs={
		message:application.zcore.functions.zso(application.zcore, 'listingRemapCurrentSite')&" | "&application.zcore.functions.zso(application.zcore, 'listingRemapProgress')
	};
	if(application.zcore.functions.zso(application.zcore, 'listingRemapCurrentSite') EQ ""){
		rs.message="Not running";
	}
	application.zcore.functions.zreturnjson(rs);
	</cfscript>
</cffunction>
<cffunction name="select" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var i=0;
	var row=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	// on submit
	/*
	db.sql="SELECT GROUP_CONCAT(DISTINCT `#form.searchCriteria#` SEPARATOR #db.param(",")#) idlist 
	FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# 
	WHERE app_x_mls.mls_id=#db.param(form.mls_id1)# AND 
	mls_saved_search.site_id = app_x_mls.site_id and
	app_x_mls_deleted = #db.param(0)# and 
	mls_saved_search_deleted = #db.param(0)# 
	and `#form.searchCriteria#` <> '' ";
	qId=db.execute("qId"); 
	
	uniqueStruct={};
	for(row in qId){
		arrID=listToArray(row.idlist, ',', false); 
		for(i=1;i LTE arraylen(arrID);i++){
			uniqueStruct[arrID[i]]=true;
		}
	} 
	if(structcount(uniqueStruct) EQ 0){
		application.zcore.status.setStatus(request.zsid, "No data left to map for this field.");
		application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	}
	db.sql="select listing_lookup.* from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	where listing_lookup_id in ("&db.trustedSQL("'"&structkeylist(uniqueStruct, "','")&"'")&") and
	listing_lookup_deleted = #db.param(0)# and
	(listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria])# "; 
	qLookup=db.execute("qLookup"); //
	*/


	db.sql="SELECT group_concat(mls_saved_search_id separator #db.param("','")#) idlist, `#form.searchCriteria#` field 
	FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# 
	WHERE app_x_mls.mls_id = #db.param(form.mls_id1)# AND 
	mls_saved_search.site_id = app_x_mls.site_id and 
	mls_saved_search_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)# 
	and 
	`#form.searchCriteria#` <> #db.param('')# 
	GROUP BY  `#form.searchCriteria#` ";
	qId=db.execute("qId");   

	includeStruct={};
	for(row in qId){
		arrF=listToArray(row.field, ",");
		for(i=1;i LTE arraylen(arrF);i++){
			includeStruct[application.zcore.functions.zescape(arrF[i])]=true;
		}
	} 
	arrInclude=structkeyarray(includeStruct);

	db.sql="select listing_lookup.* from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	where 
	listing_lookup_deleted = #db.param(0)# and
	(listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria])# or
	listing_lookup.listing_lookup_type =#db.param(variables.searchCriteriaSQLStruct[form.searchCriteria2])#) AND 
	(listing_lookup_mls_provider= #db.param(variables.qM.mls_provider)# or listing_lookup_mls_provider= #db.param(variables.qM2.mls_provider)# )  and
	(listing_lookup_id = #db.trustedSQL("'"&arraytolist(arrInclude, "' or listing_lookup_id = '")&"'")#)";
	qLookup=db.execute("qLookup"); 

	
	if(qLookup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "No data left to map for this field.");
		application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	}
	 
	db.sql="select * from 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup
	where
	listing_lookup_deleted = #db.param(0)# and
	listing_lookup_mls_provider = #db.param(variables.qM2.mls_provider)#
	and listing_lookup.listing_lookup_type = #db.param(variables.searchCriteriaSQLStruct[form.searchCriteria2])# 
	";
	qLookup2=db.execute("qLookup");  

	leftStruct={};
	rightStruct={};

	leftStruct2={};
	i2=0;
	for(row in qLookup){
		if(not structkeyexists(leftStruct, row.listing_lookup_value)){
			leftStruct[row.listing_lookup_value]=[];
		}
		arrayAppend(leftStruct[row.listing_lookup_value], row.listing_lookup_id);
	} 
	vs={};
	for(i in leftStruct){
		i2++;
		vs[i2]={
			label: i,
			value: arrayToList(leftStruct[i], ",")
		};
	}

	arrKey2=structsort(vs, "text", "asc", "label");
	leftStruct=vs;
	for(row in qLookup2){
		if(not structkeyexists(rightStruct, row.listing_lookup_value)){
			rightStruct[row.listing_lookup_value]=[];
		}
		arrayAppend(rightStruct[row.listing_lookup_value], row.listing_lookup_id);
	} 
	vs={};
	arrRightLabel=["-- Delete Option --"];
	arrRightValue=["0"];
	i2=0;
	for(i in rightStruct){
		i2++;
		vs[i2]={
			label: i,
			value: arrayToList(rightStruct[i], ",")
		}
	}
	arrKey=structsort(vs, 'text', 'asc', "label");
	for(i=1;i LTE arraylen(arrKey);i++){
		arrayAppend(arrRightLabel, vs[arrKey[i]].label);
		arrayAppend(arrRightValue, vs[arrKey[i]].value);
	}
	writeoutput('<form class="zFormCheckDirty" action="/z/listing/admin/remap-data/map" method="post">
	<input type="hidden" name="mls_id1" value="#form.mls_id1#" />
	<input type="hidden" name="mls_id2" value="#form.mls_id2#" />
	<input type="hidden" name="searchCriteria" value="#htmleditformat(form.searchCriteria)#" />
	<input type="hidden" name="searchCriteria2" value="#htmleditformat(form.searchCriteria2)#" />
	<h2>Map Search Criteria: #replace(form.searchCriteria, 'search_', '')# to #replace(form.searchCriteria2, 'search_', '')#</h2>
	<p>Select the option to remap the data for each of the existing used options. If no option is selected, the option will be removed from the saved search</p>
	<table style="border-spacing:0px; " class="table-list">
	<tr><th>From</th><th>To</th></tr>');
	rowIndex=1; 
	for(i2=1;i2 LTE arraylen(arrKey2);i2++){
		i=arrKey2[i2];

		writeoutput('<tr><td class="table-white"><input type="hidden" name="listing_lookup_id_old#rowIndex#" value="'&leftStruct[i].value&'" />'&htmleditformat(leftStruct[i].label)&'</td><td class="table-white">'); 
		selectStruct = StructNew();
		selectStruct.multiple=true;
		selectStruct.name = "listing_lookup_id_new#rowIndex#";
		selectStruct.listLabels = arrayToList(arrRightLabel, chr(9));
		selectStruct.listValues =arrayToList(arrRightValue, chr(9));
		selectStruct.listLabelsDelimiter = chr(9);
		selectStruct.listValuesDelimiter = chr(9); 
		application.zcore.functions.zInputSelectBox(selectStruct);
		application.zcore.functions.zSetupMultipleSelect("listing_lookup_id_new#rowIndex#", application.zcore.functions.zso(form, "listing_lookup_id_new#rowIndex#"));
		writeoutput('</td></tr>');
		rowIndex++;
	}
	writeoutput('</table>');
	writeoutput('<br /><br />
	<input type="hidden" name="rowIndex" value="#rowIndex-1#" />
	<input type="submit" name="submit1" value="submit" /> 
	<input type="button" onclick="window.location.href=''/z/listing/admin/remap-data/index'';" name="cancel1" value="cancel" /></p></form>');
	</cfscript>
</cffunction>
 
<cffunction name="map" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var i=0;
	var row=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	form.rowIndex=application.zcore.functions.zso(form, 'rowIndex');
	mapStruct={};
	for(i=1;i LTE form.rowIndex;i++){
		oldId=application.zcore.functions.zso(form, 'listing_lookup_id_old#i#');
		newId=application.zcore.functions.zso(form, 'listing_lookup_id_new#i#');
		if(newId NEQ ""){
			arrOld=listToArray(oldId, ",");
			for(n=1;n LTE arraylen(arrOld);n++){
				mapStruct[arrOld[n]]=newId;
			}
		}
	}  
	xCount=0;
	//writedump(mapStruct);
	db.sql="SELECT group_concat(mls_saved_search_id separator #db.param("','")#) idlist, 
	`#form.searchCriteria#` field, `#form.searchCriteria2#` field2, mls_saved_search.site_id 
	FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# 
	WHERE app_x_mls.mls_id IN (#db.trustedSQL("'"&form.mls_id1&"','"&form.mls_id2&"'")#) AND 
	mls_saved_search.site_id = app_x_mls.site_id and 
	mls_saved_search_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)# 
	and (`#form.searchCriteria#` <> #db.param('')# or `#form.searchCriteria2#` <> #db.param('')# ) 
	GROUP BY mls_saved_search.site_id, `#form.searchCriteria#`, `#form.searchCriteria2#`  ";
	qId=db.execute("qId");  
	for(row in qId){
		changed=false;
		arrData1=listToArray(row.field, ",", false);
		arrData2=listToArray(row.field2, ",", false);
		
		uniqueStruct1={};
		uniqueStruct2={};
		deleted=false;
		for(i=1;i LTE arraylen(arrData1);i++){
			if(structkeyexists(mapStruct, arrData1[i])){
				if(mapStruct[arrData1[i]] EQ 0){
					deleted=true;
					// need to delete these from the mls_saved_search record
				}else if(mapStruct[arrData1[i]] NEQ ""){
					changed=true; 
					//uniqueStruct1[arrData1[i]]=true;
					//uniqueStruct1[mapStruct[arrData1[i]]]=true;
				}
			}else{
				uniqueStruct1[arrData1[i]]=true;
			}
		}
		for(i=1;i LTE arraylen(arrData2);i++){
			if(structkeyexists(mapStruct, arrData2[i])){
				if(mapStruct[arrData2[i]] EQ 0){
					deleted=true;
				}else if(mapStruct[arrData2[i]] NEQ ""){
					changed=true; 
					uniqueStruct2[arrData2[i]]=true;
					uniqueStruct2[mapStruct[arrData2[i]]]=true;
				}
			}else{
				uniqueStruct2[arrData2[i]]=true;
			}
		}
		if(changed){  
			for(i in uniqueStruct1){
				uniqueStruct2[i]=true;
			}
			//result1=structkeylist(uniqueStruct1, ",");
			result2=structkeylist(uniqueStruct2, ",");
			if(deleted){
				result2="";
			}
			/*
				echo(form.searchCriteria&":"&row.field&"<br />");
				echo(form.searchCriteria2&":"&row.field2&"<br />");
				 writeoutput("UPDATE mls_saved_search 
				SET 
				mls_saved_search_updated_datetime='#request.zos.mysqlnow#' ,
				 `#form.searchCriteria2#` = '#result2#' 
				WHERE mls_saved_search_id IN ('#row.idlist#')  and 
				site_id=#row.site_id# and 
				mls_saved_search_deleted=0"); 
				 abort;
			*/
			xCount++;
			// `#form.searchCriteria#` = '#application.zcore.functions.zescape(result1)#',
			db.sql="UPDATE #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
			SET 
			mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)# ,
			 `#form.searchCriteria2#` = #db.param(result2)# 
			WHERE mls_saved_search_id IN ("&db.trustedSQL("'"&row.idlist&"'")&")  and 
			site_id=#db.param(row.site_id)# and 
			mls_saved_search_deleted=#db.param(0)# ";
			db.execute("qUpdate"); 
		}
	}
	// application.zcore.functions.zabort();
	application.zcore.status.setStatus(request.zsid, "Data mapped for #xCount# records successfully.");
	application.zcore.functions.zRedirect("#variables.backURL#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="remapSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	setting requesttimeout="50000";
	db=request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.showList=application.zcore.functions.zso(form, 'showList', true, 0);
	form.mls_id=application.zcore.functions.zso(form, 'mls_id', true, 0);
	if(form.mls_id EQ "0"){

		rs={success:false, errorMessage:'You must select an mls_id first.' };
		application.zcore.functions.zReturnJson(rs);
	}
	db=request.zos.queryObject;
	db.sql="select site.* from #db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("app_x_site")# 
	WHERE 
	app_x_site.site_id = site.site_id and 
	app_id = #db.param(11)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_x_site_status = #db.param(1)# and 
	site_active = #db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site.site_id <> #db.param(-1)#  
	GROUP BY site.site_id";
	qSites=db.execute("qSites");
	if(form.showList){
		echo('<h2>Sites using mls_id: #form.mls_id#</h2>
		<p>Click on applications for each site if you want to change the associated MLS data sources.</p>');
	}
	savecontent variable="out"{
		for(row in qSites){
			if(form.mls_id NEQ "0"){
				db.sql="select * from #db.table("app_x_mls", request.zos.zcoreDatasource)# 
				WHERE 
				app_x_mls.site_id = #db.param(row.site_id)# and 
				mls_id = #db.param(form.mls_id)# and 
				app_x_mls_deleted = #db.param(0)#";
				qCheck=db.execute("qCheck");
				if(qCheck.recordcount EQ 0){
					continue;
				}
			}
			if(form.showList){
				echo('<p>#row.site_short_domain# | <a href="/z/_com/zos/app?method=instanceSiteList&sid=#row.site_id#" target="_blank">Applications</a> | <a href="#row.site_domain#/z/listing/admin/remap-data/siteRemap" target="_blank">Remap Site</a></p>');
			}else{
				if(structkeyexists(application.zcore, 'listingRemapCancel')){
					structdelete(application.zcore, 'listingRemapCancel');
					break;
				}
				application.zcore.listingRemapCurrentSite=row.site_short_domain;
				//echo(row.site_domain&"/z/listing/admin/remap-data/siteRemap"&"<br>");
				a=application.zcore.functions.zdownloadlink(row.site_domain&"/z/listing/admin/remap-data/siteRemap", 2000, true);
				if(a.success){
					echo(row.site_short_domain&": "&a.cfhttp.filecontent);
				}else{
					echo(row.site_short_domain&": failed");
				}
			}
			if(request.zos.isTestServer){
				// uncomment this break only for debugging purposes
				//break;
			}
		}
	}
	if(form.showList){
		echo(out);
	}else{
		structdelete(application.zcore, 'listingRemapCancel');
		structdelete(application.zcore, 'listingRemapCurrentSite');
		structdelete(application.zcore, 'listingRemapProgress');

		rs={success:true, output:out };
		application.zcore.functions.zReturnJson(rs);
	}
	</cfscript>
</cffunction>


	
<cffunction name="siteRemap" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer / server ips can access this.");
	}
	if(not application.zcore.app.siteHasApp("listing")){
		application.zcore.functions.z404("This site doesn't have the listing app.");
	}
	init();
	setting requesttimeout="2000";
	// get the search data
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.search");
	rs=local.searchCom.getSearchCriteriaStruct();

	lookupStruct={};
	for(i in variables.searchCriteriaStruct){
		key=replace(i, "search_", ""); 
		a=listToArray(rs[key].values, "|");
		for(n=1;n LTE arraylen(a);n++){
			if(not structkeyexists(lookupStruct, i)){
				lookupStruct[i]={};
			}
			lookupStruct[i][a[n]]=true;
		}
	} 
	offset=0;
	rowCount=0;
	while(true){
		db.sql="SELECT *
		FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
		WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted = #db.param(0)#  
		LIMIT #db.param(offset)#, #db.param(50)# ";
		qSaved=db.execute("qSaved");  
		if(qSaved.recordcount EQ 0){
			break;
		}
		echo('Processing '&qSaved.recordcount&' records<br />');
		for(row2 in qSaved){ 
			rowCount++;
			row=duplicate(row2); 
			for(i in variables.searchCriteriaStruct){
				if(row[i] != ""){  
					arrData=listToArray(row[i], ",");

					arrNew=[];
					for(n=1;n LTE arraylen(arrData);n++){
						if(structkeyexists(lookupStruct[i], arrData[n])){
							arrayAppend(arrNew, arrData[n]);
						}
					}
					row[i]=arrayToList(arrNew, ",");
				}
			}

			structdelete(row, 'search_status');
			structdelete(row, 'search_liststatus');
			structdelete(row, 'saved_search_created_date');
			structdelete(row, 'saved_search_sent_date');
			structdelete(row, 'saved_search_updated_date');
			structdelete(row, 'mls_saved_search_created_datetime'); 
			structdelete(row, 'saved_search_last_sent_date');
			row.mls_saved_search_updated_datetime=request.zos.mysqlnow;
			//writedump(row);			abort;
			ts={
				table:"mls_saved_search",
				datasource:request.zos.zcoreDatasource,
				struct:row
			}
			application.zcore.functions.zUpdate(ts);
			application.zcore.listingRemapProgress=rowCount&" records processed";
			if(structkeyexists(application.zcore, 'listingRemapCancel')){
				echo('Site remap cancelled');
				abort;
			}
		}
		offset+=50;
	}
	echo('Site remap complete');
	abort;
	</cfscript>

</cffunction>
</cfoutput>
</cfcomponent>