<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	var qSiteOptionApp=0; 
	variables.allowGlobal=false;


	
	checkOptionCache();

	form.site_id=request.zos.globals.id;
	variables.siteIdList="'"&request.zos.globals.id&"'";
	variables.publicSiteIdList="'0','"&request.zos.globals.id&"'";
	if(application.zcore.user.checkGroupAccess("user")){
		if(request.zos.isDeveloper){
			variables.allowGlobal=true;
			variables.siteIdList="'0','"&request.zos.globals.id&"'";
		}
	}
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id',false,0);
	if(form.site_option_app_id NEQ 0){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
		db.sql="select * FROM #db.table("site_option_app", request.zos.zcoreDatasource)# site_option_app 
		where site_option_app_id=#db.param(form.site_option_app_id)# and 
		site_option_app_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
		qSiteOptionApp=db.execute("qSiteOptionApp");
		if(qSiteOptionApp.recordcount EQ 0){
			writeoutput('Invalid Request');
			application.zcore.functions.zabort();	
		}
		variables.currentAppId=qSiteOptionApp.app_id;
	}else{
		variables.currentAppId="0";
	}
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		if(form.method EQ "manageoptions" or form.method EQ "add" or form.method EQ "edit"){
			application.zcore.functions.z301Redirect('/member/');
		}
	}
	
	variables.recurseCount=0;
	if(form.method EQ "autoDeleteGroup" or 
		form.method EQ "publicAddGroup" or form.method EQ "publicEditGroup" or 
		form.method EQ "internalGroupUpdate" or form.method EQ "publicMapInsertGroup" or 
		form.method EQ "publicInsertGroup" or form.method EQ "publicUpdateGroup" or 
		form.method EQ "publicAjaxInsertGroup"){

	}else{ 
		if(form.method EQ "archiveGroup" or form.method EQ "unarchiveGroup" or form.method EQ "manageGroup" or form.method EQ "addGroup" or form.method EQ "editGroup" or form.method EQ "deleteGroup" or form.method EQ "insertGroup" or form.method EQ "updateGroup" or form.method EQ "getRowHTML"){
			if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
				// check if user has access to site_option_group_id only 
				groupId=application.zcore.functions.zso(form, 'site_option_group_id', true);
				i=0;
				while(true){
					i++;
					db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
					site_id = #db.param(request.zos.globals.id)# and 
					site_option_group_deleted=#db.param(0)# and 
					site_option_group_id=#db.param(groupId)#";
					qGroup=db.execute("qGroup");
					if(qGroup.site_option_group_parent_id EQ 0){
						break;
					}else{
						groupId=qGroup.site_option_group_parent_id;
					}
					if(i>255){
						throw("Infinite loop looking for site_option_group_parent_id=0");
					}
				} 
				if(form.method EQ "deleteGroup" or form.method EQ "insertGroup" or form.method EQ "updateGroup"){
					writeEnabled=true;
				}else{
					writeEnabled=false;
				} 
				application.zcore.adminSecurityFilter.requireFeatureAccess("Custom: "&qGroup.site_option_group_name, writeEnabled);	 
			} 
		}else{
			application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options");	
		}
	}

	if(structkeyexists(form, 'zQueueSortAjax')){
		return;
	}
	devToolsEnabled=false;
	if(application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zIsWidgetBuilderEnabled()){
		allowedMethods={
			"manageGroup":true,
			"manageOptions":true
		}
		if(structkeyexists(allowedMethods, form.method)){
			devToolsEnabled=true;
		}
	}
	</cfscript>
	<cfif devToolsEnabled> 
		<div class="z-float z-mb-10 z-site-option-devtools">
			DevTools:
			<cfif application.zcore.functions.zso(form, 'site_option_group_id') NEQ "">
				Current Group:
				<a href="/z/admin/site-option-group/edit?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#">Edit</a> | 
				<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#">Edit Options</a> | 
				Manage: 
			</cfif> 
			<a href="/z/admin/sync/index">Sync</a> | 
			<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#">Options</a> | 
			<a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Groups</a> | 
			Add: <a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Option</a> | 
			<a href="/z/admin/site-option-group/add?site_option_app_id=#form.site_option_app_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Group</a>
		</div> 
	</cfif>
</cffunction>



<cffunction name="searchReindex" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	form.sid=request.zos.globals.id;
	application.zcore.siteOptionCom.searchReindex();
	</cfscript>
	<h2>Search reindexed for this site only.</h2>
	<p><a href="/z/server-manager/tasks/search-index/index">Click here to reindex search on all sites</a></p>
</cffunction>
	

<cffunction name="import" localmode="modern" access="remote" roles="member">
	<cfscript>
	var row=0;
	var qOption=0;
	var db=request.zos.queryObject;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7.1.1");
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	}
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	// all options except for html separator
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_type_id <> #db.param(11)# and 
	site_option_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qOption=db.execute("qOption");
	arrRequired=arraynew(1);
	arrOptional=arraynew(1);
	for(row in qOption){
		if(row.site_option_required EQ 1){
			arrayAppend(arrRequired, row.site_option_name);	
		}else{
			arrayAppend(arrOptional, row.site_option_name);	
		}
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h3>File Import for Group: #qS.site_option_group_display_name#</h3> 
	<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish.</p>
	<p>If a value doesn't match the system, it will be left blank when imported.</p> 
	<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(arrRequired, chr(9))#</textarea></p>
	<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(arrOptional, chr(9))#</textarea></p>
	<form class="zFormCheckDirty" action="/z/admin/site-options/processImport?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#" enctype="multipart/form-data" method="post">
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify optional CFC filter.</h2>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["column1"] EQ "bad value"){
				arguments.struct["column1"]="correct value";
			}
			return true; /* return false if you do not want to import this record. */
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		 <input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
	</form>
</cffunction>

<cffunction name="processImport" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var fileContents=0;
	var d1=0;
	var qOption=0;
	var dataImportCom=0;
	var n=0;
	var row=0;
	var g=0;
	var arrData=0;
	var arrSiteOptionId=0;
	var f1=0;
	var t38=0;
	var i=0;
	var ts=0;
	var ts2=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	setting requesttimeout="10000";
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id');
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site option group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	}
	// all options except for html separator
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_deleted = #db.param(0)# and
	site_option_type_id <> #db.param(11)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qOption=db.execute("qOption");
	arrRequired=arraynew(1);
	arrOptional=arraynew(1);
	requiredStruct={};
	optionalStruct={};
	defaultStruct={};
	var optionIDLookupByName={}; 
	var dataStruct={};
	
	
	for(row in qOption){
		optionIDLookupByName[row.site_option_name]=row.site_option_id;
		defaultStruct[row.site_option_name]=row.site_option_default_value;
		
		optionStruct=deserializeJson(row.site_option_type_json); 
		var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
		dataStruct[row.site_option_id]=currentCFC.onBeforeImport(row, optionStruct); 
		
		if(row.site_option_required EQ 1){
			requiredStruct[row.site_option_name]="";	
		}else{
			optionalStruct[row.site_option_name]="";
		}
	}
	 
	if(structkeyexists(form, 'filepath') EQ false or form.filepath EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must upload a CSV file", true);
		application.zcore.functions.zRedirect("/z/admin/site-options/import?zsid=#request.zsid#&site_option_group_id=#form.site_option_group_id#&site_option_app_id=#form.site_option_app_id#");
	}
	f1=application.zcore.functions.zuploadfile("filepath", request.zos.globals.privatehomedir&"/zupload/user/",false);
	fileContents=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	d1=application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	 
	dataImportCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.dataImport");
	ts=StructNew();
	ts.escapedBy='"';
	ts.textQualifier='"';
	ts.seperator=",";
	ts.lineDelimiter=chr(10);
	ts.bufferedReadEnabled=false;  
	ts.allowUnequalColumnCount=true;
	dataImportCom.init(ts);
	dataImportCom.parseCSV(fileContents);
	dataImportCom.getFirstRowAsColumns(); 
	requiredCheckStruct=duplicate(requiredStruct); 
	ts=StructNew();
	for(n=1;n LTE arraylen(dataImportCom.arrColumns);n++){
		dataImportCom.arrColumns[n]=trim(dataImportCom.arrColumns[n]);
		if(not structkeyexists(defaultStruct, dataImportCom.arrColumns[n]) ){
			application.zcore.status.setStatus(request.zsid, "#dataImportCom.arrColumns[n]# is not a valid column name.  Please rename columns to match the supported fields or delete extra columns so no data is unintentionally lost during import.", false, true);
			application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#");
		}
		structdelete(requiredCheckStruct, dataImportCom.arrColumns[n]);
		if(structkeyexists(ts, dataImportCom.arrColumns[n])){
			application.zcore.status.setStatus(request.zsid, "The column , ""#dataImportCom.arrColumns[n]#"",  has 1 or more duplicates.  Make sure only one column is used per field name.", false, true);
			application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
		}
		ts[dataImportCom.arrColumns[n]]=dataImportCom.arrColumns[n];
	}
	if(structcount(requiredCheckStruct)){
		application.zcore.status.setStatus(request.zsid, "The following required fields were missing in the column header of the CSV file: "&structKeyList(requiredCheckStruct)&".", false, true);
		application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
	}  
	dataImportCom.mapColumns(ts); 
	arrData=arraynew(1);
	curCount=dataImportCom.getCount(); 
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	 
		for(i in requiredStruct){
			if(trim(ts[i]) EQ ""){
				application.zcore.status.setStatus(request.zsid, "#i# was empty on row #g# and it is a required field.  Make sure all required fields are entered and re-import.", false, true);
				application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#"); 
			}
		}
		// check required fields are set for all rows
	}
	dataImportCom.resetCursor();
	//dataImportCom.skipLine();
	arrSiteOptionId=[];
	for(i in defaultStruct){
		arrayAppend(arrSiteOptionId, optionIDLookupByName[i]); 
	}
	form.site_x_option_group_set_id=0;
	form.site_id=request.zos.globals.id;
	form.site_x_option_group_set_parent_id=0;
	form.site_option_id=arraytolist(arrSiteOptionId, ",");
	
	filterEnabled=false;
	if(request.zos.isDeveloper){
		if(form.cfcPath NEQ "" and form.cfcMethod NEQ ""){
			if(left(form.cfcPath, 5) EQ "root."){
				form.cfcPath=request.zrootcfcpath&removechars(form.cfcPath, 1, 5);
			}
			filterInstance=application.zcore.functions.zcreateobject("component", form.cfcPath);	
			filterEnabled=true;
		}
	}
	request.zos.disableSiteCacheUpdate=true; 
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	 
		for(i in ts){
			ts[i]=trim(ts[i]);
			if(len(ts[i]) EQ 0){
				structdelete(ts, i);
			}
		} 
		if(filterEnabled){
			result=filterInstance[form.cfcMethod](ts);
			if(not result){
				continue;
			}
		}
		structappend(ts, defaultStruct, false);  
		for(i in ts){ 
			if(structkeyexists(dataStruct, optionIDLookupByName[i]) and dataStruct[optionIDLookupByName[i]].mapData){
				arrC=listToArray(ts[i], ",");
				arrC2=[];
				for(i2=1;i2 LTE arraylen(arrC);i2++){
					c=trim(arrC[i2]); 
					if(structkeyexists(dataStruct[optionIDLookupByName[i]].struct, c)){
						// convert the name to the id because a match was found
						arrayAppend(arrC2, dataStruct[optionIDLookupByName[i]].struct[c]);
					}else{
						// put the original value to avoid losing data.
						arrayAppend(arrC2, c);
					}
				}
				ts[i]=arrayToList(arrC2, ",");
			} 
			form['newvalue'&optionIDLookupByName[i]]=ts[i];
		}   
		// writedump(ts);		writedump(form);		abort;
		form.site_x_option_group_set_approved=1;
		rs=this.importInsertGroup(); 
		arrayClear(request.zos.arrQueryLog);
	} 
	// update cache only once for better performance.
	application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(form.site_option_group_id);
	//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	application.zcore.status.setStatus(request.zsid, "Import complete.");
	application.zcore.functions.zRedirect("/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#");
	 
	</cfscript>
</cffunction> 


<!--- <cffunction name="recurseSOP" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="set_id" type="any" required="yes">
	<cfargument name="parent_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	if(arguments.set_id EQ false){
		setSQL="";	
	}else{
		setSQL=" and site_option_group.site_option_group_id ='"&application.zcore.functions.zescape(arguments.parent_id)&"' and 
		site_x_option_group_set.site_x_option_group_set_id = '"&application.zcore.functions.zescape(arguments.set_id)&"' ";
	}
	variables.recurseCount++;
	if(variables.recurseCount GT 20){
		writeoutput('Recurse is infinite');
		return;
	}
	db.sql="SELECT * FROM (#db.table("site_option", request.zos.zcoreDatasource)# site_option, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group) 
	LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
	site_option.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_option.site_option_id = site_x_option_group.site_option_id and 
	site_x_option_group.site_id = #db.param(arguments.site_id)# and 
	site_x_option_group_deleted = #db.param(0)#
	LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set ON 
	site_x_option_group_set.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_x_option_group_set.site_x_option_group_set_id = site_x_option_group.site_x_option_group_set_id and 
	site_x_option_group_set.site_id = site_x_option_group.site_id and 
	site_x_option_group_set_deleted = #db.param(0)#
    WHERE site_option.site_id IN (#db.param('0')#,#db.param(arguments.site_id)#) and 
    site_option_deleted = #db.param(0)# and 
    site_option_group_deleted = #db.param(0)# and
	"&setSQL&" and
    site_option_group.site_id = site_option.site_id and
    site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group.site_option_group_type=#db.param('1')#
     ORDER BY site_option_group.site_option_group_parent_id asc, site_x_option_group.site_option_group_id asc, 
	 site_x_option_group_set.site_x_option_group_set_sort asc, site_option.site_option_name ASC";
	qS2=db.execute("qS2");
	 
	lastGroup="";
	lastSet="";
	curSet=0;
	ts=structnew();
	loop query="qs2"{
		if(lastGroup NEQ site_option_group_id){
			lastGroup=site_option_group_id;
			ts[site_option_group_id]=structnew();
			curGroup=ts[site_option_group_id];
		}
		if(lastSet NEQ site_x_option_group_set_id){
			lastSet=site_x_option_group_set_id;
			t92=structnew();
			t92.optionStruct=structnew();
			t92.childStruct=structnew();
			setCount=structcount(curGroup);
			curGroup[setCount+1]=t92;
			curSet=curGroup[setCount+1];
			curSet.childStruct=variables.recurseSOP(arguments.site_id, site_x_option_group_set_id, site_option_group_parent_id);
		}
		t9=structnew();
		if(form.site_option_type_id EQ 1 and site_option_line_breaks EQ 1){
			if(site_x_option_group_id EQ ""){
				t9.value=application.zcore.functions.zparagraphformat(site_option_default_value);
			}else{
				t9.value=application.zcore.functions.zparagraphformat(site_x_option_group_value);
			}
		}else{
			if(site_x_option_group_id EQ ""){
				t9.value=site_option_default_value;
			}else{
				t9.value=site_x_option_group_value;
			}
		}
		t9.editEnabled=site_option_edit_enabled;
		t9.sort=site_x_option_group_set_sort;
		t9.editURL="&amp;site_option_group_id="&site_option_group_id&"&amp;site_x_option_group_set_id="&site_x_option_group_set_id;
		curSet.optionStruct[site_option_name]=t9;
	}
	return ts;
	</cfscript>
</cffunction> --->

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var siteIdSQL=0;
	var qS2=0;
	var theTitle=0;
	var i=0;
	var qS=0;
	var tempURL=0;
	var q=0;
	var queueSortStruct=0;
	var queueComStruct=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	siteIdSQL=" ";
	if(form.site_option_group_id NEQ 0){
		siteIdSQL=" and site_option.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"'";
		form.site_id =request.zos.globals.id;
		form.siteIDType=1;
	}else{
		if(structkeyexists(form, 'globalvar')){
			siteIdSQL=" and site_option.site_id='0'";
			form.site_id='0';
			form.siteIDType=4;
		}else{
			siteIdSQL=" and site_option.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"'";
			form.site_id=request.zos.globals.id;
			form.siteIDType=1;
		}
	}
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_id = #db.param(form.site_option_id)# and 
	site_option_deleted = #db.param(0)# and
	site_id=#db.param(form.site_id)#";
	qS2=db.execute("qS2");
	if(qS2.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Site option no longer exists.",false,true);
		if(structkeyexists(request.zsession, 'siteoption_return') and request.zsession['siteoption_return'] NEQ ""){
			tempURL = request.zsession['siteoption_return'];
			StructDelete(request.zsession, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/site-options/manageoptions?site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		var arrSiteOptionIdCustomDeleteStruct=[];
		typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
		for(i in typeCFCStruct){
			if(typeCFCStruct[i].hasCustomDelete()){
				arrayAppend(arrSiteOptionIdCustomDeleteStruct, application.zcore.functions.zescape(i));
			}
		}
		db.sql="SELECT * FROM #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option, 
		#db.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id=#db.param(form.site_id)# and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_deleted = #db.param(0)# and
		site_x_option.site_option_id = site_option.site_option_id and 
		site_option.site_option_type_id IN (#db.trustedSQL("'"&arrayToList(arrSiteOptionIdCustomDeleteStruct, "','")&"'")#) and 
		site_option.site_option_id=#db.param(form.site_option_id)#";
		qS=db.execute("qS");
		var row=0;
		for(row in qS){
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			var optionStruct=deserializeJson(row.site_option_type_json);
			currentCFC.onDelete(row, optionStruct); 
		} 
			
		db.sql="SELECT * FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
		#db.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id=#db.param(form.site_id)# and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_x_option_group.site_option_id = site_option.site_option_id and 
		site_option.site_option_type_id IN (#db.trustedSQL("'"&arrayToList(arrSiteOptionIdCustomDeleteStruct, "','")&"'")#) and 
		site_option.site_option_id=#db.param(form.site_option_id)#";
		var qSGroup=db.execute("qSGroup"); 
		for(row in qSGroup){
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
			var optionStruct=deserializeJson(row.site_option_type_json);
			currentCFC.onDelete(row, optionStruct); 
		} 
		form.site_id=request.zos.globals.id;
		db.sql="DELETE FROM #db.table("site_x_option", request.zos.zcoreDatasource)#  
		WHERE site_option_id = #db.param(form.site_option_id)# and 
		site_option_id_siteIDType=#db.param(form.siteIDType)# and 
		site_x_option_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  
		WHERE site_option_id = #db.param(form.site_option_id)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_option_id_siteIDType=#db.param(form.siteIDType)# and 
		site_id = #db.param(request.zos.globals.id)#";
		q=db.execute("q");
		if(qS2.site_option_group_id EQ 0 and qS2.site_id EQ 0){
			form.site_id=0; 
			application.zcore.functions.zDeleteRecord("site_option","site_option_id,site_id", request.zos.zcoreDatasource);
			application.zcore.siteOptionCom.updateAllSitesOptionCache();
		}else{
			form.site_id=request.zos.globals.id;
			application.zcore.functions.zDeleteRecord("site_option","site_option_id,site_id", request.zos.zcoreDatasource);
			if(qS2.site_option_group_id EQ 0){
				application.zcore.siteOptionCom.updateOptionCache(request.zos.globals.id);
			}else{
				application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(qS2.site_option_group_id);
			}
			//application.zcore.functions.zOS_cacheSiteAndUserGroups(qS.site_id[i]);
		}
		if(qS2.site_option_group_id NEQ 0){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_option";
			queueSortStruct.sortFieldName = "site_option_sort";
			queueSortStruct.primaryKeyName = "site_option_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(qS2.site_option_group_id)#' and 
			site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' and 
			site_option_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Site option deleted.");
		if(structkeyexists(request.zsession, 'siteoption_return') and request.zsession['siteoption_return'] NEQ ""){
			tempURL = request.zsession['siteoption_return'];
			StructDelete(request.zsession, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/site-options/manageOptions?site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<cfscript>
		request.zsession["siteoption_return"&form.site_option_id]=application.zcore.functions.zso(form, 'returnURL');		
		theTitle="Delete Site Option";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<div style="text-align:center;"><span class="medium"> Are you sure you want to delete this site option?<br />
			<br />
			<strong>WARNING: </strong>This cannot be undone and any saved values will be deleted and any references to the site option on the web site will throw errors upon deletion.<br />
			<br />
			Make sure you have removed all hardcoded references from the source code before continuing!<br />
			<br />
			#qS2.site_option_name#<br />
			<br />
			<script type="text/javascript">
			/* <![CDATA[ */
			function confirmDelete(){
				var r=confirm("Are you sure you want to permanently delete this option?");
				if(r){
					window.location.href='/z/admin/site-options/delete?site_option_app_id=#form.site_option_app_id#&confirm=1&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#&site_option_id=#form.site_option_id#<cfif structkeyexists(form, 'globalvar')>&globalvar=1</cfif>';	
				}else{
					window.location.href='/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_option_group_parent_id=#form.site_option_group_parent_id#';
				}
			}
			/* ]]> */
			</script> 
			<a href="##" onclick="confirmDelete();return false;">Yes, delete this option</a><br />
			<br />
			<a href="/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_option_group_parent_id=#form.site_option_group_parent_id#">No, don't delete this option</a></span>
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var result=0;
	var returnAppendString=0; 
	var tempURL=0;
	var qDF=0;
	var queueSortStruct=0;
	var queueComStruct=0;
	var ts=0;
	var myForm=structnew();
	var formaction=0;
	variables.init();
	form.siteglobal=application.zcore.functions.zso(form,'siteglobal', false, 0);

	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	 
	if(form.method EQ 'insert'){
		formaction='add';	
	}else{
		formaction='edit';
	}
	if(structkeyexists(form, 'globalvar') or (form.siteglobal EQ 1 and variables.allowGlobal)){
		form.site_id=0;	
		returnAppendString="&globalvar=1";
	}else{
		returnAppendString="";
		form.site_id=request.zos.globals.id;
	} 
	form.site_option_appidlist=","&application.zcore.functions.zso(form, 'site_option_appidlist')&",";
	
	if(form.method EQ "update"){
		db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		where site_option_id = #db.param(form.site_option_id)# and 
		site_option_deleted = #db.param(0)# and 
		site_id = #db.param(form.site_id)#"; 
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/admin/site-options/index");
		}
		// force code name to never change after initial creation
		//form.site_option_name=qCheck.site_option_name;
	}
	myForm.site_option_display_name.required=true;
	myForm.site_option_display_name.friendlyName="Display Name";
	myForm.site_option_name.required = true;
	myForm.site_option_name.friendlyName="Code Name";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/admin/site-options/#formAction#?zsid=#Request.zsid#&site_option_id=#form.site_option_id#"&returnAppendString);
	}
	var rs=0;
	var currentCFC=application.zcore.siteOptionCom.getTypeCFC(form.site_option_type_id);
	form.site_option_type_json="{}";
	// need this here someday: var rs=currentCFC.validateFormField(row, optionStruct, 'newvalue', form);
	rs=currentCFC.onUpdate(form);   
	if(not rs.success){ 
		application.zcore.functions.zRedirect("/z/admin/site-options/#formAction#?zsid=#Request.zsid#&site_option_id=#form.site_option_id#"&returnAppendString);	
	}
	db.sql="SELECT count(site_option_id) count 
	FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_name = #db.param(form.site_option_name)# and 
	site_option_deleted = #db.param(0)# and
	site_option_group_id =#db.param(form.site_option_group_id)# and 
	site_option_id <> #db.param(form.site_option_id)# and 
	site_id = #db.param(form.site_id)#";
	qDF=db.execute("qDF");
	if(qDF.count NEQ 0){
		application.zcore.status.setStatus(request.zsid,"Site option ""#form.site_option_name#"" already exists. Please make the name unique.",form);
		application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?site_option_id=#form.site_option_id#&zsid=#request.zsid#"&returnAppendString);	
	}
	ts=structnew();
	ts.table="site_option"; 
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insert'){ 
		form.site_option_id=application.zcore.functions.zInsert(ts); 
		if(form.site_option_id EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to create site option because ""#form.site_option_name#"" already exists or the insert query failed.",form);
			application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?zsid=#request.zsid#"&returnAppendString);
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to UPDATE #db.table("site", request.zos.zcoreDatasource)# site option because ""#form.site_option_name#"" already exists. Please make the name unique.",form);
			application.zcore.functions.zRedirect("/z/admin/site-options/#formaction#?site_option_id=#form.site_option_id#&zsid=#request.zsid#"&returnAppendString);	
		}
	}
	if(form.site_option_group_id EQ 0){
		if(form.siteglobal EQ 1 and variables.allowGlobal){
			application.zcore.siteOptionCom.updateAllSitesOptionCache();
		}else{
			application.zcore.siteOptionCom.updateOptionCache(request.zos.globals.id); 
		}
	}else{
		application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(form.site_option_group_id);
	}
	if(form.method EQ 'insert'){
		if(form.site_option_group_id NEQ 0 and form.site_option_group_id NEQ ""){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_option";
			queueSortStruct.sortFieldName = "site_option_sort";
			queueSortStruct.primaryKeyName = "site_option_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
			site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' and 
			site_option_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Site option added.");
		if(structkeyexists(request.zsession, 'siteoption_return')){
			tempURL = request.zsession['siteoption_return'];
			StructDelete(request.zsession, 'siteoption_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Site option updated.");
	}
	if(structkeyexists(form, 'site_option_id') and structkeyexists(request.zsession, 'siteoption_return'&form.site_option_id) and request.zsession['siteoption_return'&form.site_option_id] NEQ ""){	
		tempURL = request.zsession['siteoption_return'&form.site_option_id];
		StructDelete(request.zsession, 'siteoption_return'&form.site_option_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/site-options/manageoptions?zsid=#request.zsid#&site_option_group_id=#form.site_option_group_id#');
	}
	</cfscript>
</cffunction>

<cffunction name="autocompleteTips" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.template.setTag("pagetitle", "Option Autocomplete Tips");
	</cfscript>
	<p>The following phrases will automatically map to the corresponding field type until you override it when adding a new option. You can include any number of other words and it will still work.</p>
<table class="table-list">
<tr><th>Words</th>
<th>Field Type</th>
</tr>
<tr><td>"section" and "text"</td><td>html editor</td></tr>
<tr><td>html</td><td>html editor</td></tr>
<tr><td>heading</td><td>text</td></tr>
<tr><td>textarea</td><td>textarea</td></tr>
<tr><td>summary</td><td>html editor</td></tr>
<tr><td>title</td><td>text</td></tr>
<tr><td>subheading</td><td>text</td></tr>
<tr><td>sub-heading</td><td>text</td></tr>
<tr><td>email</td><td>email</td></tr>
<tr><td>map</td><td>map picker</td></tr>
<tr><td>location</td><td>map picker</td></tr>
<tr><td>state</td><td>state</td></tr>
<tr><td>country</td><td>country</td></tr>
<tr><td>color</td><td>color picker</td></tr>
<tr><td>email</td><td>email</td></tr>
<tr><td>url</td><td>url</td></tr>
<tr><td>image</td><td>image</td></tr>
<tr><td>photo</td><td>image</td></tr>
<tr><td>graphic</td><td>image</td></tr>
<tr><td>paragraph</td><td>html editor</td></tr>
<tr><td>"body" and "text"</td><td>html editor</td></tr>
<tr><td>date</td><td>date</td></tr>
<tr><td>file</td><td>file</td></tr>
<tr><td>time</td><td>time</td></tr>
<tr><td>user</td><td>user</td></tr>
</table>	
<br /> 
<h2>Other Autocomplete Features</h2>
	<p>You can make any field automatically become required by adding "*" to the end of the "Code Name" field. The "*" will be automatically removed once typed. Example:</p>
	<ul><li>Title*</li></ul>
	<p>Image, HTML Editor and Textarea support pasting in the dimensions to the "Code Name" field. Example:</p>
	<ul><li>Body Text 400x200</li>
	<li>Section 1 Text 400x300</li>
	</ul>
	<p>Image also lets you enable cropping by adding a third number set to 1. Example:</p>
	<ul><li>Image 250x150x1</li></ul>
	<p>The moment you paste the text, it will automatically remove the numbers from the "Code Name" field.</p>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var theTitle=0;
	var qS=0;
	var htmlEditor=0;
	var qGroup=0;
	var siteglobal=0;
	var ts=0;
	var selectStruct=0;
	var qApp=0;
	var qOptionGroup=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7.4");
	form.site_option_id=application.zcore.functions.zso(form, 'site_option_id');
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_id = #db.param(form.site_option_id)# and 
	site_option_deleted = #db.param(0)# ";
	if(structkeyexists(form, 'globalvar')){
		db.sql&="and site_id = #db.param('0')#";
	}else{
		db.sql&="and site_id = #db.param(request.zos.globals.id)#";
	}
	qS=db.execute("qS"); 
	request.zsession["siteoption_return"&form.site_option_id]=application.zcore.functions.zso(form, 'returnURL');		
	if(currentMethod EQ 'edit' and qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Site option doesn't exist.");
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");	
	}
    application.zcore.functions.zQueryToStruct(qS, form, 'site_option_group_id');
    application.zcore.functions.zstatusHandler(request.zsid,true);
	if(form.site_option_group_id NEQ "" and form.site_option_group_id NEQ 0){
		variables.allowGlobal=false;
	}
		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		WHERE site_option_group_id = #db.param(form.site_option_group_id)#  and 
		site_option_group_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qOptionGroup=db.execute("qOptionGroup");
	if(currentMethod EQ 'add'){
		theTitle="Add Site Option";
	}else{
		theTitle="Edit Site Option";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
    </cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	function setType(n){

		var count=parseInt(document.getElementById('optionTypeCount').value);	
		for(var i=0;i<=count;i++){
			var t=document.getElementById('typeOptions'+i);	
			if(t!=null){
				if(i==n){
					t.style.display="block";
				}else{
					t.style.display="none";
				}
			}
		}
	}
	var displayDefault=<cfif currentMethod EQ 'edit'>false<cfelse>true</cfif>;
	function validateOptionType(){
		var postObj=zGetFormDataByFormId("siteOptionTypeForm");
		var typeId=postObj.site_option_type_id;
		var arrError=[];  
		if(typeof window["validateOptionType"+typeId] == "undefined"){
			return true;
		}
		window["validateOptionType"+typeId](postObj, arrError);
		if(arrError.length){
			alert(arrError.join("\n"));
			return false;
		}
		return true;
	}
	/* ]]> */
	</script>

	<form class="zFormCheckDirty" name="siteOptionTypeForm" id="siteOptionTypeForm" onsubmit="return validateOptionType();" action="/z/admin/site-options/<cfif currentMethod EQ "add">insert<cfelse>update</cfif>?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#form.site_option_id#<cfif structkeyexists(form, 'globalvar')>&amp;globalvar=1</cfif>" method="post">
		<table style="border-spacing:0px;" class="table-list">
			<cfscript>
			db.sql="SELECT *  FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE
			site_option_group.site_id =#db.param(request.zos.globals.id)# and 
			site_option_group_deleted = #db.param(0)#
			order by site_option_group.site_option_group_display_name ASC ";
			qGroup=db.execute("qGroup");
			</cfscript>
			<tr>
				<th>Group:</th>
				<td><cfscript>
				selectStruct = StructNew();
				selectStruct.name = "site_option_group_id";
				selectStruct.query = qGroup;
				selectStruct.onchange="checkAssociateTr();";
				selectStruct.queryLabelField = "site_option_group_display_name";
				selectStruct.queryValueField = "site_option_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th>Code Name:</th>
				<td>
				<input type="text" size="50" name="site_option_name" id="site_option_name" value="#htmleditformat(form.site_option_name)#" onkeyup="var d1=document.getElementById('site_option_display_name');if(displayDefault){d1.value=this.value;} autofillFieldType(this.value);" onblur="var d1=document.getElementById('site_option_display_name');if(displayDefault){d1.value=this.value;}"><br />
				Note: <a href="/z/admin/site-options/autocompleteTips" target="_blank">Autocomplete tips</a>
				<cfif currentMethod NEQ "add">
					<br><strong><span style="color:##900;">BE EXTREMELY CAREFUL.</span>
					If you EDIT the Code Name, you must manually change it on all servers.<br><br>

					Sync only works when the Code Name matches on both servers.  You may cause data loss if you forget about this and Sync incorrectly.
					<br><br>
					  It is not recommended to change the Code Name after a project is live.  Be sure to communicate these changes to the other developers.<br><br>
					  Any code that refers to the Code Name MUST be manually updated immediately after changing the name, or it will throw undefined errors.</strong>
					<!--- #form.site_option_name#<br />
					<input name="site_option_name" id="site_option_name" type="hidden" value="#htmleditformat(form.site_option_name)#"  />
					Note: Code Name can't be changed after initial creation to allow for simple syncing between sites &amp; servers. --->
				</cfif>

					<script type="text/javascript">
					var optionsSetByUser=false;
					function autofillFieldType(v){
						if(typeSelectedByUser){
							console.log('typeSelectedByUser was true, cancelling autofill.');
							return;
						}
						var arrWord=zStringReplaceAll(zStringReplaceAll(v.toLowerCase(), "\t", " "), "  ", " ").split(" ");
						var arrWordOriginal=zStringReplaceAll(zStringReplaceAll(v, "\t", " "), "  ", " ").split(" ");
						var arrMap=[
							{arrWord:['section', 'text'], type:"html editor"},
							{arrWord:['html'], type:"html editor"},
							{arrWord:['heading'], type:"text"},
							{arrWord:['textarea'], type:"textarea"},
							{arrWord:['summary'], type:"html editor"},
							{arrWord:['title'], type:"text"},
							{arrWord:['subheading'], type:"text"},
							{arrWord:['sub-heading'], type:"text"},
							{arrWord:['email'], type:"email"},
							{arrWord:['map'], type:"map picker"},
							{arrWord:['location'], type:"map picker"},
							{arrWord:['state'], type:"state"},
							{arrWord:['country'], type:"country"},
							{arrWord:['color'], type:"color picker"},
							{arrWord:['email'], type:"email"},
							{arrWord:['url'], type:"url"},
							{arrWord:['image'], type:"image"},
							{arrWord:['photo'], type:"image"},
							{arrWord:['graphic'], type:"image"},
							{arrWord:['paragraph'], type:"html editor"},
							{arrWord:['body', 'text'], type:"html editor"},
							{arrWord:['date'], type:"date"},
							{arrWord:['file'], type:"file"},
							{arrWord:['time'], type:"time"},
							{arrWord:['user'], type:"user"} 
						];
						if(v.substr(v.length-1, 1) == "*"){
							// mark it required and remove *
							$("##site_option_required1")[0].checked=true;
							v=v.substr(0, v.length-1);
							$("##site_option_name").val(v);
						}
						var type="text";
						var options={}; 
						var arrWordMatch={};
						var arrWordMatchWord={};
						var removeWordIndex=-1;
						for(var n=0;n<arrMap.length;n++){
							arrWordMatch[n]=0;
							arrWordMatchWord[n]={};
						} 
						for(var i=0;i<arrWord.length;i++){
							w=arrWord[i];
							for(var n=0;n<arrMap.length;n++){
								words=arrMap[n].arrWord;
								for(var g=0;g<words.length;g++){
									var word=words[g];
									if(w == word){ 
										if(typeof arrWordMatchWord[n][word]=="undefined"){
											arrWordMatchWord[n][word]=true;
											arrWordMatch[n]++;
										}
									}
								} 
								if(arrWordMatch[n]==words.length){  
									options={};
									type=arrMap[n].type;
									if(type == "image"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.imagewidth=arrSize[0];
														options.imageheight=arrSize[1];
														removeWordIndex=g;
													}

												}else if(arrSize.length==3){
													// widthxheightxcrop
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1])) && !isNaN(parseInt(arrSize[2]))){
														options.imagewidth=arrSize[0];
														options.imageheight=arrSize[1];
														if(arrSize[2] == "1"){
															options.imagecrop=1;
														}else if(arrSize[2] == "0"){
															options.imagecrop=0;
														}
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}else if(type == "html editor"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){ 
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.editorwidth=arrSize[0];
														options.editorheight=arrSize[1];
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}else if(type == "textarea"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.editorwidth2=arrSize[0];
														options.editorheight2=arrSize[1];
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}
								}
							}
						}
						if(removeWordIndex != -1){
							optionsSetByUser=true;
							var arrNewWord=[];
							for(var i=0;i<arrWord.length;i++){
								if(removeWordIndex != i){
									arrNewWord.push(arrWordOriginal[i]);
								}
							}
							var v=arrNewWord.join(" ");
							$("##site_option_name").val(v);
						}
						if(type !=""){
							setFieldType(type, options);
						}
					} 
					function setFieldType(type, options){
						var arrMap={
							"text":"0",
							"textarea":"1",
							"email":"10",
							"map picker":"13",
							"state":"19",
							"country":"20",
							"color picker":"18",
							"email":"10",
							"url":"15",
							"image":"3",
							"file":"9",
							"date":"5",
							"time":"6",
							"user":"16",
							"html editor":"2"
						};  
						if(!optionsSetByUser){
							if(type == "html editor"){
								if(typeof options.editorwidth == "undefined"){ 
									options.editorwidth=600;
									options.editorheight=300;	
								}
							}else if(type == "textarea"){
								if(typeof options.editorwidth2 == "undefined"){
									options.editorwidth2=300;
									options.editorheight2=150;	
								}
							}
						}
						var fields=$("input[name='site_option_type_id']");
						if(typeof arrMap[type] != "undefined"){
							var fieldId=arrMap[type];
							for(var i=0;i<fields.length;i++){
								var field=fields[i];
								if(field.value == fieldId){
									setType(parseInt(fieldId));
									field.checked=true; 
									break;
								}
							} 
							for(var i in options){ 
								if(i=="imagecrop"){
									if(options[i]=="1"){
										$("##imagecrop1")[0].checked=true;
									}else{
										$("##imagecrop0")[0].checked=false;
									}
								}else{
									$("##"+i).val(options[i]);
								}
							}
						} 
					}
					var typeSelectedByUser=false;
					zArrDeferredFunctions.push(function(){
						$("input[name='site_option_type_id']").bind("click", function(){
							typeSelectedByUser=true;
						});
					});
					</script>
				</td>
			</tr>
			<tr>
				<th>Display Name:</th>
				<td><input type="text" size="50" name="site_option_display_name" id="site_option_display_name" value="#htmleditformat(form.site_option_display_name)#" onkeyup="displayDefault=false;"></td>
			</tr>
			<cfscript>
			if(form.site_option_type_json EQ ""){
				form.site_option_type_json="{}";
			}
			var optionStruct=deserializeJson(form.site_option_type_json); 
			</cfscript>
			<tr>
				<th>Type:</th>
				<td>
					<cfscript>
					if(form.site_option_type_id EQ ""){
						form.site_option_type_id=0;
					}
					var typeStruct={};
					var i=0;
					var count=0;
					typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
					for(i in typeCFCStruct){
						count++;
						typeStruct[typeCFCStruct[i].getTypeName()]=i;
					}
					var arrTemp=structkeyarray(typeStruct);
					arraySort(arrTemp, "text", "asc");
					for(i=1;i LTE arraylen(arrTemp);i++){
						var currentCFC=application.zcore.siteOptionCom.getTypeCFC(typeStruct[arrTemp[i]]);
						writeoutput(currentCFC.getTypeForm(form, optionStruct, 'site_option_type_id'));
					}
					</cfscript> 
					<input type="hidden" id="optionTypeCount" value="#count#">
					<script type="text/javascript">
					/* <![CDATA[ */
					setType(#application.zcore.functions.zso(form, 'site_option_type_id',true)#);
					/* ]]> */
					</script>
					</td>
			</tr>
			<tr>
				<th>Default Value:</th>
				<td><textarea cols="40" rows="5" name="site_option_default_value">#htmleditformat(form.site_option_default_value)#</textarea></td>
			</tr>
			<cfscript>
			if(form.site_id EQ 0){
				siteglobal=1;
			}else{
				siteglobal=0;
			}
			if(form.site_option_line_breaks EQ ""){
				form.site_option_line_breaks=0;	
			}
			if(form.site_option_edit_enabled EQ ""){
				form.site_option_edit_enabled=0;
			}
			</cfscript>
			<tr id="associateTrId">
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Associate With Apps","member.site-option.edit site_option_appidlist")#</th>
				<td class="table-white"><cfscript>
				db.sql="select app.* from #db.table("app", request.zos.zcoreDatasource)# app, 
				#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
				WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	 			app.app_built_in=#db.param(0)# and 
	 			app_deleted = #db.param(0)# and 
	 			app_x_site_deleted = #db.param(0)# and
				app_x_site.app_id = app.app_id order by app_name ";
				qApp=db.execute("qApp");
				
				selectStruct=structnew();
				selectStruct.name="site_option_appidlist";
				selectStruct.query = qApp;
				selectStruct.onchange="";
				selectStruct.queryLabelField = "app_name";
				selectStruct.queryValueField = "app_id";
				application.zcore.functions.zInput_Checkbox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th>Show in List View:</th>
				<td>
					<input name="site_option_primary_field" id="site_option_primary_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_primary_field', true, 0) EQ 1>checked="checked"</cfif> /> Yes
					<input name="site_option_primary_field" id="site_option_primary_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_primary_field', true, 0) EQ 0>checked="checked"</cfif>  onclick="document.getElementById('site_option_admin_searchable0').checked=true; document.getElementById('site_option_admin_sort_field0').checked=true; " /> No</td>
			</tr>
			<tr>
				<th>Required:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_required")#</td>
			</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Allow Public?</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_allow_public")#</td>
				</tr>
			<!--- <cfif form.site_option_group_id NEQ '' and form.site_option_group_id NEQ 0> --->
				<tr>
					<th>Use for URL/Nav Title:</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_url_title_field")#</td>
				</tr>
				<cfif qOptionGroup.recordcount NEQ 0 and qOptionGroup.site_option_group_enable_unique_url EQ 1>
					<tr>
						<th>Use for Search Summary:</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_search_summary_field")#</td>
					</tr>
					<tr>
						<th>Enable Search Index:</th>
						<td>#application.zcore.functions.zInput_Boolean("site_option_enable_search_index")#</td>
					</tr>
				</cfif>
				<tr>
					<th>Sort (admin):</th>
					<td>
						<cfif qOptionGroup.recordcount NEQ 0 and qOptionGroup.site_option_group_enable_sorting EQ 1>
						
							<input name="site_option_admin_sort_field" id="site_option_admin_sort_field0" style="border:none; background:none;" value="0" type="hidden"> Can't be used when group sorting is enabled.
						<cfelse>
							<input name="site_option_admin_sort_field" id="site_option_admin_sort_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;"  />  Ascending
							<input name="site_option_admin_sort_field" id="site_option_admin_sort_field2" style="border:none; background:none;" type="radio" value="2" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 2>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;"  />  Descending
							<input name="site_option_admin_sort_field" id="site_option_admin_sort_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_admin_sort_field', true, 0) EQ 0>checked="checked"</cfif> /> Disabled
					</cfif>
				</td>
				</tr>
				<tr>
					<th>Read-only:</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_readonly")#</td>
				</tr>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="site_option_public_searchable" id="site_option_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="site_option_public_searchable" id="site_option_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>Searchable (admin):</th>
					<td>
					<input name="site_option_admin_searchable" id="site_option_admin_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'site_option_admin_searchable', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('site_option_primary_field1').checked=true;" /> Yes
					<input name="site_option_admin_searchable" id="site_option_admin_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'site_option_admin_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				
				<!---
				not in use anywhere:
				 <tr>
					<th>Search Default (admin):</th>
					<td><input type="text" name="site_option_admin_search_default" value="#htmleditformat(form.site_option_admin_search_default)#" /></td>
				</tr> 
				<tr>
					<th>Validator CFC:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="site_option_validator_cfc";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript><br />
					(Must begin with zcorerootmapping or request.zRootCFCPath)</td>
				</tr>
				<tr>
					<th>Validator CFC Method:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="site_option_validator_method";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript></td>
				</tr>--->
			<!--- </cfif> --->

			<!--- 
			TODO: site_option_user_group_id_list | this feature is not fully implemented yet
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Enable Data Entry<br />For User Groups","member.site-option-group.edit site_option_user_group_id_list")#</th>
				<td>
				<cfscript>
				db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				user_group_deleted = #db.param(0)# 
				ORDER BY user_group_name asc"; 
				var qGroup2=db.execute("qGroup2"); 
				ts = StructNew();
				ts.name = "site_option_user_group_id_list";
				ts.friendlyName="";
				// options for query data
				ts.multiple=true;
				ts.query = qGroup2;
				ts.queryLabelField = "user_group_friendly_name";
				ts.queryValueField = "user_group_id";
				application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'site_option_user_group_id_list'));
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript></td>
			</tr> --->
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Force Small Label Width","member.site-option-group.edit site_option_small_width")#</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_small_width")# (With yes selected, public forms will force the label column to be as small as possible.)</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Hide Label?</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_hide_label")#</td>
			</tr>
			<tr>
				<th>Add Line Breaks:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_line_breaks")# (Useful for textarea field type to force newlines to &lt;br&gt;)</td>
			</tr>
			<tr>
				<th>Use Original Value?</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_use_original_value")# (Preserves links to this domain and spaces in the submitted form data)</td>
			</tr>
			<tr>
				<th>Label On Top?</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_label_on_top")# (Allows putting longer labels above the field)</td>
			</tr>
			<!---
			Not implemented yet
			 <tr>
				<th>Add To Previous Row:</th>
				<td>#application.zcore.functions.zInput_Boolean("site_option_add_to_previous_row")# (Allows putting multiple fields on the same row)</td>
			</tr> --->
			<tr>
				<th>Character Width:</th>
				<td><input type="text" size="10" style="width:auto; min-width:auto;" name="site_option_character_width" id="site_option_character_width" value="#htmleditformat(form.site_option_character_width)#" onkeyup="displayDefault=false;"> (Only works for text/select input types)</td>
			</tr>
			<cfif variables.allowGlobal>
				<tr>
					<th>Listing Only:</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_listing_only")#</td>
				</tr>
			</cfif>
			<cfif variables.allowGlobal>
				<cfscript>
				if(form.site_id EQ 0){
					form.siteglobal=1;
				}
				</cfscript>
				<tr>
					<th>Global:</th>
					<td>#application.zcore.functions.zInput_Boolean("siteglobal")#</td>
				</tr>
			</cfif>

			<cfif form.site_option_group_id EQ "" or form.site_option_group_id EQ 0>
	
				<tr>
					<th>Edit Enabled:</th>
					<td>#application.zcore.functions.zInput_Boolean("site_option_edit_enabled")# (Make sure you select no for options that are not visible.)</td>
				</tr>
			</cfif>
			<tr>
				<th>Tooltip Help Box:</th>
				<td><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "site_option_tooltip";
				htmlEditor.value			= form.site_option_tooltip;
				htmlEditor.width			= "100%";
				htmlEditor.height		= 100;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submitForm" value="Submit" class="z-manager-search-button" />
					<input type="button" name="cancel" value="Cancel" class="z-manager-search-button" onClick="window.location.href = '/z/admin/site-options/manageOptions?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#application.zcore.functions.zso(form, 'site_option_group_id')#&amp;site_option_group_parent_id=#application.zcore.functions.zso(form, 'site_option_group_parent_id')#';" /></td>
			</tr>
		</table>
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="siteglobal" value="0" />
		</cfif>
	</form>
	<script type="text/javascript">
	/* <![CDATA[ */
	function checkAssociateTr(){
		var i=document.getElementById("site_option_group_id");
		var d=document.getElementById("associateTrId");
		if(i.selectedIndex==0){
			d.style.display="table-row";	
		}else{
			d.style.display="none";
			for(i2=1;i2<255;i2++){
				var d2=document.getElementById('site_option_appidlist'+i2);
				if(d2){
					d2.checked=false;	
				}else{
					break;
				}
			}
		}
	}
	checkAssociateTr();
	/* ]]> */
	</script>
</cffunction>

<cffunction name="manageOptions" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var theTitle=0;
	var queueComStruct=0;
	var queueSortStruct=0;
	var lastGroup=0;
	var qS=0;
	var i=0;
	var arrParent=0;
	var q1=0;
	var curParentId=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7.3");
    application.zcore.functions.zstatusHandler(request.zsid);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
	form.site_option_group_parent_id=application.zcore.functions.zso(form, 'site_option_group_parent_id', true);
    db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted=#db.param(0)# ";
	qGroup=db.execute("qGroup", "", 10000, "query", false);
	queueComStruct=structnew();
	if(form.site_option_group_id NEQ 0){
		if(qGroup.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/admin/site-options/index");
		}  
		  
		theTitle="Group Site Options: "&qGroup.site_option_group_display_name;
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
	}else{
		theTitle="Site Options";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);

		queueSortStruct = StructNew();
		queueSortStruct.tableName = "site_option";
		queueSortStruct.sortFieldName = "site_option_sort";
		queueSortStruct.primaryKeyName = "site_option_id";
		//queueSortStruct.sortVarName="siteGroup"&qGroup.site_option_group_id;
		queueSortStruct.datasource=request.zos.zcoreDatasource;
		queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(0)#' and 
		site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' and 
		site_option_deleted='0' ";

		
		queueSortStruct.ajaxTableId='sortRowTable';
		queueSortStruct.ajaxURL='/z/admin/site-options/manageOptions?site_option_group_parent_id=0&site_option_group_id=0';

		queueSortStruct.disableRedirect=true;
		queueComStruct["obj0"] = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
		queueComStruct["obj0"].init(queueSortStruct);
		if(structkeyexists(form, 'zQueueSort')){
			application.zcore.siteOptionCom.updateOptionCache(request.zos.globals.id);
			//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
		if(structkeyexists(form, 'zQueueSortAjax')){
			queueComStruct["obj0"].returnJson();
		}
	}
	lastGroup="";
	loop query="qGroup"{
		lastGroup=qGroup.site_option_group_display_name;
		queueSortStruct = StructNew();
		queueSortStruct.tableName = "site_option";
		queueSortStruct.sortFieldName = "site_option_sort";
		queueSortStruct.primaryKeyName = "site_option_id";
		//queueSortStruct.sortVarName="siteGroup"&qGroup.site_option_group_id;
		queueSortStruct.datasource=request.zos.zcoreDatasource;
		queueSortStruct.where ="  site_option_group_id = '#application.zcore.functions.zescape(qGroup.site_option_group_id)#' and 
		site_option.site_id ='#application.zcore.functions.zescape(request.zos.globals.id)#' and 
		site_option_deleted='0' ";

		
		queueSortStruct.ajaxTableId='sortRowTable';
		queueSortStruct.ajaxURL='/z/admin/site-options/manageOptions?site_option_group_parent_id=#form.site_option_group_parent_id#&site_option_group_id=#form.site_option_group_id#';

		queueSortStruct.disableRedirect=true;
		queueComStruct["obj"&qGroup.site_option_group_id] = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
		queueComStruct["obj"&qGroup.site_option_group_id].init(queueSortStruct);
		application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(qGroup.site_option_group_id);
		if(structkeyexists(form, 'zQueueSort')){
			//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
		if(structkeyexists(form, 'zQueueSortAjax')){

			queueComStruct["obj"&qGroup.site_option_group_id].returnJson();
		}
	}
	if(form.site_option_group_id EQ 0){
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
		site_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_option_group.site_id=#db.param(-1)# and 
		site_option_group_deleted = #db.param(0)#
		WHERE site_option.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
		site_option_deleted = #db.param(0)#
		and site_option.site_option_group_id = #db.param('0')# 
		ORDER BY site_option_group.site_option_group_display_name asc, site_option.site_option_sort ASC, site_option.site_option_name ASC";
	}else{
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
		site_option_group_deleted = #db.param(0)# and
		site_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_option_group.site_id = site_option.site_id 
		WHERE site_option.site_id =#db.param(request.zos.globals.id)# and 
		site_option_deleted = #db.param(0)# and
		site_option.site_option_group_id = #db.param(form.site_option_group_id)# 
		ORDER BY site_option_group.site_option_group_display_name asc, site_option.site_option_sort ASC, site_option.site_option_name ASC";
	}
	qS=db.execute("qS");
	writeoutput('<p><a href="/z/admin/site-option-group/index?site_option_app_id=#form.site_option_app_id#">Manage Groups</a> / ');
	if(qgroup.recordcount NEQ 0 and qgroup.site_option_group_parent_id NEQ 0){
		curParentId=qgroup.site_option_group_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
			where site_option_group_id = #db.param(curParentId)# and 
			site_option_group_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#";
			q1=db.execute("q1", "", 10000, "query", false);
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/admin/site-option-group/index?site_option_group_parent_id=#q1.site_option_group_id#">#application.zcore.functions.zFirstLetterCaps(q1.site_option_group_display_name)#</a> / ');
				curParentId=q1.site_option_group_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.site_option_group_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GTE 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(qgroup.site_option_group_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qGroup.site_option_group_display_name)&" / ");
		}
	}
	writeoutput('</p>');
	</cfscript>
	<cfif qGroup.recordcount NEQ 0>
		<p><a href="/z/admin/site-options/add?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_option_group_parent_id=#qgroup.site_option_group_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Add Site Option</a> | <a href="/z/admin/site-option-group/index?site_option_group_parent_id=#form.site_option_group_id#">Manage Sub-Groups</a></p>
	</cfif>
	<table id="sortRowTable" class="table-list" style="width:100%;">
		<thead>
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Type</th>
			<th>List View?</th>
			<th>Required</th>
			<th>Public</th>
			<cfif variables.allowGlobal>
				<th>Global</th>
			</cfif>
			<cfif lastGroup NEQ "">
				<th>Sort</th>
			</cfif>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfscript>
		var row=0;
		for(row in qS){
			writeoutput('<tr #queueComStruct["obj"&qS.site_option_group_id].getRowHTML(qS.site_option_id)# ');
			if(qS.currentrow MOD 2 EQ 0){
				writeoutput('class="row1"');
			}else{
				writeoutput('class="row2"');
			}
			writeoutput('>
				<td>#qS.site_option_id#</td>
				<td>#qS.site_option_name#</td>
				<td>');
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(qS.site_option_type_id);
				writeoutput(currentCFC.getTypeName()); 
				writeoutput('</td>');
				if(row.site_option_primary_field EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(row.site_option_required EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(row.site_option_allow_public EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(variables.allowGlobal){
					writeoutput('<td>');
					if(qS.site_id EQ 0){
						writeoutput('Yes');
					}else{
						writeoutput('No');
					}
					writeoutput('</td>');
				}
				if(lastGroup NEQ ""){
					if(qS.site_id NEQ 0 or variables.allowGlobal){
						queueComStruct["obj"&qS.site_option_group_id].getRowStruct(qS.site_option_id);
						echo('<td>');
							echo('#queueComStruct["obj"&qS.site_option_group_id].getAjaxHandleButton(qS.site_option_id)#');
						echo('</td>');
					}
				}
				writeoutput('<td>');
				if(qS.site_id NEQ 0 or variables.allowGlobal){
					/*if(lastGroup NEQ ""){
						writeoutput('#queueComStruct["obj"&qS.site_option_group_id].getLinks(qS.recordcount, qS.currentrow, '/z/admin/site-options/manageOptions?site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_id=#qS.site_option_id#', "vertical-arrows")#');
					}*/
					var globalTemp="";
					if(qS.site_id EQ 0){
						globalTemp="&amp;globalvar=1";
					}
					writeoutput('<a href="/z/admin/site-options/edit?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#qS.site_option_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)##globalTemp#">Edit</a> | 
					<a href="/z/admin/site-options/delete?site_option_app_id=#form.site_option_app_id#&amp;site_option_id=#qS.site_option_id#&amp;site_option_group_id=#qS.site_option_group_id#&amp;site_option_group_parent_id=#qS.site_option_group_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)##globalTemp#">Delete</a>');
				}
				writeoutput('</td>
			</tr>');
		}
		</cfscript>
		</tbody>
	</table>
</cffunction>

<cffunction name="saveOptions" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var nv=0;
	var i=0;
	var qD=0;
	var nvd=0;
	var arrList=0;
	var oldnv=0;
	var tempURL=0;
	var qD2=0;
	var q=0;
	var photoresize=0;
	var nowDate=request.zos.mysqlnow;
	variables.init();
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id', true, 0);
	application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	arrSiteIdType=listtoarray(form.siteidtype);
	arrSiteOptionId=listtoarray(form.site_option_id);
	if(arraylen(arrSiteOptionId) NEQ arraylen(arrSiteIdType)){
		application.zcore.status.setStatus(request.zsid, "Invalid request");
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");	
	}
	arrSQL=arraynew(1);
	for(i=1;i LTE arraylen(arrSiteIdType);i++){
		arrayappend(arrSQL, "(site_option.site_id='"&application.zcore.functions.zescape(application.zcore.functions.zGetSiteIdFromSiteIdType(arrSiteIdType[i]))&"' and 
		site_option.site_option_id='"&application.zcore.functions.zescape(arrSiteOptionId[i])&"')");	
	}
	db.sql="SELECT *, site_option.site_id siteOptionSiteId 
	FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	LEFT JOIN #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option ON 
	site_x_option_deleted = #db.param(0)# and
	site_x_option.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_option.site_option_id = site_x_option.site_option_id and 
	site_x_option.site_id = #db.param(request.zos.globals.id)# 
	and site_option.site_id = "&db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))&" 
	WHERE ("&db.trustedSQL(arraytolist(arrSQL, " or "))&") and 
	site_option_deleted = #db.param(0)#";
	qD=db.execute("qD");
	

	var row=0;
	for(row in qD){
		if(row.site_x_option_updated_datetime EQ ""){
			row.site_x_option_group_set_created_datetime=request.zos.mysqlnow;
		}
		row.site_x_option_group_set_updated_datetime=request.zos.mysqlnow;

		var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);  
		nv=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
		var optionStruct=deserializeJson(row.site_option_type_json);
		if(row.siteOptionSiteId EQ 0){
			form.siteIDType=4;
		}else{
			form.siteIDType=1;
		} 
		var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
		var rs=currentCFC.onBeforeUpdate(row, optionStruct, 'newvalue', form);
		if(not rs.success){
			application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
		}
		nv=rs.value;
		var nvDate=rs.dateValue;  
		if(nv EQ "" and row.site_x_option_id EQ ''){
			nv=row.site_option_default_value;
			nvdate=nv;
		} 
		if(row.site_x_option_id EQ ""){
			db.sql="INSERT INTO #db.table("site_x_option", request.zos.zcoreDatasource)#  SET 
			site_option_app_id=#db.param(form.site_option_app_id)#, 
			site_id=#db.param(request.zos.globals.id)#, 
			site_option_id_siteIDType=#db.param(form.siteIDType)#, 
			site_x_option_value=#db.param(nv)#, 
			site_x_option_date_value=#db.param(nvdate)#, 
			site_x_option_deleted=#db.param(0)#, 
			site_option_id=#db.param(row.site_option_id)#, 
			site_x_option_updated_datetime=#db.param(nowDate)# ";
			if(structkeyexists(rs, 'originalFile')){
				db.sql&=", site_x_option_original=#db.param(rs.originalFile)#";
			}
			qD2=db.execute("qD2");
		}else{
			db.sql="UPDATE #db.table("site_x_option", request.zos.zcoreDatasource)#  SET 
			site_x_option_value=#db.param(nv)#, 
			site_x_option_date_value=#db.param(nvdate)#, 
			site_x_option_updated_datetime=#db.param(nowDate)# ";
			if(structkeyexists(rs, 'originalFile')){
				db.sql&=", site_x_option_original=#db.param(rs.originalFile)#";
			}
			db.sql&=" WHERE 
			site_option_app_id=#db.param(form.site_option_app_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			site_option_id_siteIDType=#db.param(form.siteIDType)# and 
			site_x_option_deleted=#db.param(0)# and 
			site_option_id=#db.param(row.site_option_id)# ";
			qD2=db.execute("qD2");
		}


	}
	db.sql="DELETE FROM #db.table("site_x_option", request.zos.zcoreDatasource)#  
	WHERE site_x_option.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_deleted = #db.param(0)# and
	site_x_option_updated_datetime<#db.param(nowDate)#";
	q=db.execute("q");
	application.zcore.siteOptionCom.updateOptionCache(request.zos.globals.id);
	//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	
	application.zcore.status.setStatus(request.zsid,"Site options saved.");
	if(structkeyexists(request.zsession, 'siteoption_return') and request.zsession['siteoption_return'] NEQ "" and form.site_option_app_id EQ 0){	
		tempURL = request.zsession['siteoption_return'];
		StructDelete(request.zsession, 'siteoption_return', true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#");
	}
	</cfscript>
</cffunction>


<cffunction name="internalGroupUpdate" localmode="modern" access="public">
	<cfscript>
	form.method="internalGroupUpdate";
	if(application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0) EQ 0){
		throw("Warning: form.site_x_option_group_set_id must be a valid id.");
	}
	return this.updateGroup();
	</cfscript>
</cffunction> 

<cffunction name="importInsertGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="importInsertGroup";
	return this.updateGroup();
	</cfscript>
</cffunction>
<cffunction name="publicMapInsertGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="publicMapInsertGroup";
	return this.updateGroup();
	</cfscript>
</cffunction>


<cffunction name="userInsertGroup" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	validateUserGroupAccess(); 
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="userUpdateGroup" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	validateUserGroupAccess(); 
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicInsertGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicInsertGroup";
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicAjaxInsertGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicAjaxInsertGroup";
	return this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicUpdateGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicUpdateGroup";
	if(application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0) EQ 0){
		throw("Warning: form.site_x_option_group_set_id must be a valid id.");
	}
	this.updateGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="insertGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateGroup();
	</cfscript>
</cffunction>

<cffunction name="updateGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject; 
	var queueSortStruct=structnew(); 
	var nowDate=request.zos.mysqlnow;
	var methodBackup=form.method;

 
	if(methodBackup NEQ "publicMapInsertGroup"){
		// bug fix for multiple insert/updates in the same request where map to group is enabled.
		structdelete(form, 'disableSiteOptionGroupMap');
	}
	defaultStruct=getDefaultStruct();


	if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup"){
		// allow email to have attachments for public submissions
		request.zos.arrForceEmailAttachment=[];
	}
	if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "insertGroup" or methodBackup EQ "userInsertGroup"){
		form.site_x_option_group_set_id=0;
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 0);
	request.zos.siteOptionInsertGroupCache={};
	form.site_option_app_id=application.zcore.functions.zso(form, 'site_option_app_id', true, 0);
	if(methodBackup NEQ "publicMapInsertGroup" and methodBackup NEQ "importInsertGroup"){
		variables.init();
	}
	if(methodBackup EQ "internalGroupUpdate" or methodBackup EQ "publicMapInsertGroup" or 
		methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or 
		methodBackup EQ "publicUpdateGroup" or methodBackup EQ "userInsertGroup"){
		application.zcore.adminSecurityFilter.auditFeatureAccess("Site Options", true);
	}else{
		setting requesttimeout="300";
		// handled in init instead
		//application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);
	}
	errors=false;
	var debug=false;
	/*if(request.zos.isdeveloper){
		debug=true;
	}*/
	var startTime=0;
	if(debug) startTime=gettickcount();
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	if(not structkeyexists(request.zos.siteOptionInsertGroupCache, form.site_option_group_id)){
		request.zos.siteOptionInsertGroupCache[form.site_option_group_id]={};
	}
	curCache=request.zos.siteOptionInsertGroupCache[form.site_option_group_id];
	if(not structkeyexists(curCache, 'qCheck')){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
		WHERE site_option_group_id=#db.param(form.site_option_group_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		qCheck=db.execute("qCheck", "", 10000, "query", false); 
		if(qCheck.recordcount EQ 0){
			application.zcore.functions.z404("Invalid site_option_group_id, #form.site_option_group_id#");	
		}
		curCache.qCheck=qCheck;
	}else{
		qCheck=curCache.qCheck;
	}

	if(methodBackup EQ "userInsertGroup" or methodBackup EQ "userUpdateGroup"){ 
		arrUserGroup=listToArray(qCheck.site_option_group_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserGroup);i++){
			if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
		}
	}
	if(qCheck.site_option_group_enable_approval EQ 0){
		form.site_x_option_group_set_approved=1;
	}
	if((methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup") and not structkeyexists(request.zos, 'disableSpamCheck')){
		 
		if(qCheck.site_option_group_enable_public_captcha EQ 1){
			if(not application.zcore.functions.zVerifyRecaptcha()){
				application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
				errors=true;
			}
		}
		form.inquiries_spam=0;
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
			form.inquiries_spam=1;
			form.inquiries_spam_description="Fake form fields not empty";
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//errors=true;
		}
		if(form.modalpopforced EQ 1){
			if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
				form.inquiries_spam=1;
				form.inquiries_spam_description="js3811 value not set";
				//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
				//errors=true;
			}
			if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
				form.inquiries_spam=1;
				form.inquiries_spam_description="Form hash value was wrong"; 
				//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
				//errors=true;
			}
		}
		/* if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
			form.inquiries_spam=1;
			form.inquiries_spam_description="zset9 was wrong";
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//errors=true;
		}*/
	}
	if(methodBackup EQ "userInsertGroup" or methodBackup EQ "userUpdateGroup"){
		if(qCheck.site_option_group_user_id_field NEQ ""){
			if(not structkeyexists(arguments.struct, 'arrForceFields')){
				arguments.struct.arrForceFields=[];
			}
			arrayAppend(arguments.struct.arrForceFields, qCheck.site_option_group_user_id_field);

		}
	}
	nowDate="#request.zos.mysqlnow#";
	if(not structkeyexists(curCache, 'qD')){
		db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set ON 
		site_x_option_group_set.site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
		site_x_option_group_set.site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
		site_x_option_group_set.site_x_option_group_set_id<>#db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# 
		LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
		site_option.site_option_id = site_x_option_group.site_option_id and 
		site_x_option_group.site_option_group_id = site_option.site_option_group_id and 
		site_x_option_group.site_x_option_group_set_id<>#db.param(0)# and 
		site_x_option_group_set.site_x_option_group_set_id = site_x_option_group.site_x_option_group_set_id and 
		site_x_option_group_set.site_id = site_x_option_group.site_id and 
		site_x_option_group_deleted = #db.param(0)# 
		WHERE 
		site_option_deleted = #db.param(0)# and ";
		if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or 
			methodBackup EQ "publicUpdateGroup" or methodBackup EQ "userInsertGroup" or methodBackup EQ "userUpdateGroup"){
			db.sql&=" (site_option_allow_public=#db.param(1)#";
			if(structkeyexists(arguments.struct, 'arrForceFields')){
				for(i=1;i LTE arraylen(arguments.struct.arrForceFields);i++){
					db.sql&=" or site_option_name = #db.param(arguments.struct.arrForceFields[i])# ";
				}
			}
			db.sql&=" ) and ";
		}else{
			db.sql&=" site_option.site_option_id IN ("&db.trustedSQL("'"&replace(application.zcore.functions.zescape(form.site_option_id),",","','","ALL")&"'")&")  and ";
		}
		db.sql&="site_option.site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option.site_id = #db.param(request.zos.globals.id)#";
		qD=db.execute("qD", "", 10000, "query", false); 
		curCache.qD=qD;
	}else{
		qD=curCache.qD;
	}
	newDataStruct={};
	var optionStructCache={};
	form.siteOptionTitle="";
	form.siteOptionSummary="";
	form.site_x_option_group_set_start_date='';
	form.site_x_option_group_set_end_date='';
	hasTitleField=false;
	hasSummaryField=false;
	hasPrimaryField=false;
	hasUserField=false;
	for(row in qD){
		var optionStruct=deserializeJson(row.site_option_type_json);
		optionStructCache[row.site_option_id]=optionStruct; 
		if(row.site_option_search_summary_field EQ 1){
			hasSummaryField=true;
		}
		if(row.site_option_url_title_field EQ 1){
			hasTitleField=true;
		}
		var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
		if(structkeyexists(form, row.site_option_name)){
			form['newvalue'&row.site_option_id]=form[row.site_option_name];
		}
		if(row.site_option_primary_field EQ 1 and currentCFC.isSearchable()){
			hasPrimaryField=true;
		}

		if(methodBackup NEQ "internalGroupUpdate"){
			nv=currentCFC.getFormValue(row, 'newvalue', form);
			if(row.site_option_required EQ 1){
				if(nv EQ ""){
					application.zcore.status.setFieldError(request.zsid, "newvalue"&row.site_option_id, true);
					application.zcore.status.setStatus(request.zsid, row.site_option_display_name&" is a required field.", false, true);
					errors=true;
					continue;
				}
			}
			var rs=currentCFC.validateFormField(row, optionStruct, 'newvalue', form); 
			if(not rs.success){
				application.zcore.status.setFieldError(request.zsid, "newvalue"&row.site_option_id, true);
				application.zcore.status.setStatus(request.zsid, rs.message, form, true);
				errors=true;
				continue;
			}
		}
	}  
	if(application.zcore.functions.zso(form,'site_x_option_group_set_override_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'site_x_option_group_set_override_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}  
	if(errors){
		for(row in qD){
			optionStruct=optionStructCache[row.site_option_id]; 
			currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
			currentCFC.onInvalidFormField(row, optionStruct, 'newvalue', form); 
		} 

		application.zcore.status.setStatus(request.zsid, false, form, true);
		if(methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or 
			methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
			return {success:false, errorMessage:"Invalid submission, please check your entries and try again.", zsid:request.zsid};
		}else if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicUpdateGroup"){
			
			if(structkeyexists(arguments.struct, 'returnURL')){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.returnURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
			}else{
				if(qCheck.site_option_group_public_form_url NEQ ""){
					application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(qCheck.site_option_group_public_form_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
				}else{
					application.zcore.functions.zRedirect("/z/misc/display-site-option-group/add?site_option_group_id=#form.site_option_group_id#&site_option_group_id=#form.site_option_group_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}else{
			if(methodBackup EQ "userInsertGroup"){
				newMethod="userAddGroup";
			}else if(methodBackup EQ "userUpdateGroup"){
				newMethod="userEditGroup";
			}else if(methodBackup EQ "insertGroup"){
				newMethod="addGroup";
			}else{
				newMethod="editGroup";
			}
			application.zcore.status.displayReturnJson(request.zsid);
			//application.zcore.functions.zRedirect("/z/admin/site-options/#newMethod#?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#form.modalpopforced#");
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1<br>'); startTime=gettickcount();
	var row=0;  
	arrTempDataInsert=[];
	arrTempDataUpdate=[];
	newDataMappedStruct={};
	newRecord=false;
	insertCount=0;
	updateCount=0;
	for(row in qD){

		if(methodBackup EQ "userInsertGroup" or methodBackup EQ "insertGroup" or methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "importInsertGroup"){
			newRecord=true;
			row.site_x_option_group_set_created_datetime=request.zos.mysqlnow;
		}
		row.site_x_option_group_set_updated_datetime=request.zos.mysqlnow;
		
		nv=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
		nvdate="";
		form.site_id=request.zos.globals.id;
		form.site_x_option_group_disable_time=0;
		var optionStruct=optionStructCache[row.site_option_id]; 
		var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
		if(row.site_option_use_original_value EQ 1){
			rs=currentCFC.onBeforeUpdate(row, optionStruct, 'newvalue', request.zos.originalFormScope);
		}else{
			rs=currentCFC.onBeforeUpdate(row, optionStruct, 'newvalue', form);
		}
		if(not rs.success){
			application.zcore.status.setFieldError(request.zsid, "newvalue"&row.site_option_id, true);
			application.zcore.status.setStatus(request.zsid, rs.message, form, true);
			newAction="";
			if(methodBackup EQ "userInsertGroup"){
				newAction="userAddGroup";
			}else if(methodBackup EQ "userUpdateGroup"){
				newAction="userEditGroup";
			}else if(methodBackup EQ "insertGroup"){
				newAction="addGroup";
			}else if(methodBackup EQ "updateGroup"){
				newAction="editGroup";
			}else{
				newAction="addGroup";
			}  
			if(methodBackup EQ "publicAjaxInsertGroup" or methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
				return {success:false, errorMessage:"Invalid submission, please check your entries and try again.", zsid:request.zsid};
			}else{ 
				if(newAction NEQ ""){
					application.zcore.status.displayReturnJson(request.zsid);
				}else{
					application.zcore.functions.zRedirect("/z/admin/site-options/#newAction#?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}
		nv=rs.value;
		nvDate=rs.dateValue; 
		if(nvDate NEQ "" and trim(nvDate) NEQ "00:00:00" and isdate(nvDate)){
			if(timeformat(nvDate, 'h:mm tt') EQ "12:00 am"){
				newDataStruct[row.site_option_name]=dateformat(nvDate, 'm/d/yyyy');
			}else{
				newDataStruct[row.site_option_name]=dateformat(nvDate, 'm/d/yyyy')&' '&timeformat(nvDate, 'h:mm tt');
			}
		}else{
			newDataStruct[row.site_option_name]=rs.value; 
		}
		if(nv EQ "" and row.site_x_option_group_id EQ ''){
			nv=row.site_option_default_value;
			nvdate=nv;
		} 
		dataStruct=currentCFC.onBeforeListView(row, optionStruct, form);
		newDataMappedStruct[row.site_option_name]=currentCFC.getListValue(dataStruct, optionStruct, nv);
		if(hasSummaryField){
			if(row.site_option_search_summary_field EQ 1){
				if(len(form.siteOptionSummary)){
					form.siteOptionSummary&=" "&newDataMappedStruct[row.site_option_name];
				}else{
					form.siteOptionSummary=newDataMappedStruct[row.site_option_name];
				}
			}
		}
		if(currentCFC.isSearchable()){
			if(hasTitleField){
				if(row.site_option_url_title_field EQ 1){
					if(len(form.siteOptionTitle)){
						form.siteOptionTitle&=" "&newDataMappedStruct[row.site_option_name];
					}else{
						form.siteOptionTitle=newDataMappedStruct[row.site_option_name];
					}
				}
			}else{
				if(not hasPrimaryField){
					if(form.siteOptionTitle EQ ""){
						form.siteOptionTitle=newDataMappedStruct[row.site_option_name]; 
					}
				}else if(row.site_option_primary_field EQ 1){
					if(len(form.siteOptionTitle)){
						form.siteOptionTitle&=" "&newDataMappedStruct[row.site_option_name];
					}else{
						form.siteOptionTitle=newDataMappedStruct[row.site_option_name];
					}
				}
			}
		}
		if(qCheck.site_option_group_user_id_field NEQ "" and row.site_option_name EQ qCheck.site_option_group_user_id_field){
			hasUserField=true;
			if(methodBackup EQ "userInsertGroup" or methodBackup EQ "userUpdateGroup"){
				if(not application.zcore.user.checkGroupAccess("member")){
					// force current user if not an administrative user.
					nv=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
				}
			}
			userFieldValue=nv;

		}
		var tempData={
			site_option_app_id:form.site_option_app_id,
			site_option_id_siteIDType:1,
			site_x_option_group_set_id: form.site_x_option_group_set_id,
			site_id:request.zos.globals.id,
			site_x_option_group_value:nv,
			site_x_option_group_disable_time:form.site_x_option_group_disable_time,
			site_x_option_group_date_value:nvDate,
			site_option_id: row.site_option_id,
			site_x_option_group_deleted:0,
			site_option_group_id: row.site_option_group_id,
			site_x_option_group_updated_datetime: nowDate,
			site_x_option_group_original:''
		}
		if(structkeyexists(rs, 'originalFile')){
			tempData.site_x_option_group_original=rs.originalFile;
		}
		if(not newRecord){
			db.sql="select * from #db.table("site_x_option_group", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(tempData.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# and 
			site_option_id=#db.param(tempData.site_option_id)# and 
			site_option_group_id=#db.param(tempData.site_option_group_id)# and 
			site_x_option_group_set_id=#db.param(tempData.site_x_option_group_set_id)# ";
			qUpdate=db.execute("qUpdate");
			if(qUpdate.recordcount){
				tempData.site_x_option_group_id=qUpdate.site_x_option_group_id;
				updateCount++;
				arrayAppend(arrTempDataUpdate, tempData); 
			}else{
				insertCount++;
				structdelete(tempData, 'site_x_option_group_id');
				arrayAppend(arrTempDataInsert, tempData); 
			}
		}else{
			insertCount++;
			structdelete(tempData, 'site_x_option_group_id');
			arrayAppend(arrTempDataInsert, tempData); 
		}
	}
	form.site_x_option_group_set_approved=application.zcore.functions.zso(form, 'site_x_option_group_set_approved', false, 1);
	if(methodBackup EQ "publicUpdateGroup" or methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "importInsertGroup" or methodBackup EQ "userUpdateGroup" or methodBackup EQ "userInsertGroup"){
		if((methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or methodBackup EQ "publicUpdateGroup") and (qCheck.recordcount EQ 0 or qCheck.site_option_group_allow_public NEQ 1)){
			hasAccess=false;
			if(qCheck.recordcount NEQ 0){
				arrUserGroup=listToArray(qCheck.site_option_group_user_group_id_list, ",");
				for(i=1;i LTE arraylen(arrUserGroup);i++){
					if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
						hasAccess=true;
						break;
					}
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
			}
		}
		if(qCheck.site_option_group_enable_approval EQ 1){
			if(methodBackup EQ "publicUpdateGroup" or methodBackup EQ "userUpdateGroup"){
				// must force approval status to stay the same on updates.
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
				site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
				site_x_option_group_set_deleted = #db.param(0)# and
				site_id = #db.param(request.zos.globals.id)# ";
				qSetCheck=db.execute("qSetCheck");
				if(not application.zcore.user.checkGroupAccess("administrator") and qSetCheck.site_x_option_group_set_approved EQ 2){
					form.site_x_option_group_set_approved=0;
				}else{
					form.site_x_option_group_set_approved=qSetCheck.site_x_option_group_set_approved;
				}
			}else{
				form.site_x_option_group_set_approved=0;
			}
		}
	}
	//writedump(arrTempData);	writedump(form);abort;
 
	if(methodBackup EQ "userInsertGroup" or methodBackup EQ "insertGroup" or 
		methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or 
		methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "importInsertGroup"){ 
		if(not structkeyexists(curCache, 'sortValue')){
			db.sql="select max(site_x_option_group_set_sort) sortid 
			from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set 
			WHERE site_option_group_id = #db.param(form.site_option_group_id)# and 
			site_x_option_group_set_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#";
			qG2=db.execute("qG2");
			if(qG2.recordcount EQ 0 or qG2.sortid EQ ""){
				sortValue=0;
			}else{
				sortValue=qG2.sortid;
			}
			curCache.sortValue=sortValue;
		}else{
			sortValue=curCache.sortValue;
		}
		sortValue++;
		form.site_x_option_group_set_sort=sortValue;
		if(methodBackup EQ "importInsertGroup"){
			form.site_x_option_group_set_approved=1;
		}
		db.sql="INSERT INTO #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#  SET 
		site_option_app_id=#db.param(form.site_option_app_id)#, 
		site_x_option_group_set_sort=#db.param(form.site_x_option_group_set_sort)#,
		site_x_option_group_set_created_datetime=#db.param(request.zos.mysqlnow)#, 
		 site_id=#db.param(request.zos.globals.id)#, 
		 site_option_group_id=#db.param(form.site_option_group_id)#,  
		 site_x_option_group_set_start_date=#db.param(form.site_x_option_group_set_start_date)#,
		 site_x_option_group_set_end_date=#db.param(form.site_x_option_group_set_end_date)#,
		 site_x_option_group_set_parent_id=#db.param(form.site_x_option_group_set_parent_id)#,
		site_x_option_group_set_override_url=#db.param(application.zcore.functions.zso(form,'site_x_option_group_set_override_url'))#,
		site_x_option_group_set_approved=#db.param(form.site_x_option_group_set_approved)#, 
		site_x_option_group_set_image_library_id=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'))#, 
		site_x_option_group_set_updated_datetime=#db.param(request.zos.mysqlNow)# , 
		site_x_option_group_set_title=#db.param(form.siteOptionTitle)# , 
		site_x_option_group_set_summary=#db.param(form.siteOptionSummary)#,
		site_x_option_group_set_metatitle=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metatitle'))#,
		site_x_option_group_set_metakey=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metakey'))#,
		site_x_option_group_set_metadesc=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metadesc'))#,
		site_x_option_group_set_deleted=#db.param(0)#";
		if(hasUserField){
			db.sql&=", site_x_option_group_set_user=#db.param(userFieldValue)# ";
		}
		rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
		if(rs.success){
			form.site_x_option_group_set_id=rs.result;
		}else{
			throw("Failed to insert site option group set");
		} 
		if(arraylen(arrTempDataInsert)){
			for(var n=1;n LTE arraylen(arrTempDataInsert);n++){
				arrTempDataInsert[n].site_x_option_group_set_id=form.site_x_option_group_set_id;
			}
		}  
	}else{ 
		structdelete(form, 'site_x_option_group_set_sort'); 


	}
	if(arraylen(arrTempDataInsert)){  
		var arrSQL=["INSERT INTO #db.table("site_x_option_group", request.zos.zcoreDatasource)#  "]; 
		var arrKey=structkeyarray(arrTempDataInsert[1]);
		var tempCount=arraylen(arrKey);
		arrayAppend(arrSQL, " ( "&arrayToList(arrKey, ", ")&" ) VALUES ");
		first=true;
		for(var n=1;n LTE arraylen(arrTempDataInsert);n++){ 
			if(not first){
				arrayAppend(arrSQL, ", ");
			}else{
				first=false;
			}
			arrayAppend(arrSQL, " ( ");
			for(var i=1;i LTE tempCount;i++){
				if(i NEQ 1){
					arrayAppend(arrSQL, ", ");
				} 
				arrayAppend(arrSQL, db.param(arrTempDataInsert[n][arrKey[i]], 'cf_sql_varchar'));
			}
			arrayAppend(arrSQL, " ) ");
		}
		db.sql=arrayToList(arrSQL, "");
		db.execute("qInsert");
	}
	if(arraylen(arrTempDataUpdate)){
		for(var n=1;n LTE arraylen(arrTempDataUpdate);n++){
			c=arrTempDataUpdate[n]; 
			db.sql="UPDATE #db.table("site_x_option_group", request.zos.zcoreDatasource)# SET  "; 
			first=true;
			for(i in c){
				if(i EQ "site_id" or i EQ "site_x_option_group_id"){
					continue;
				}
				if(not first){
					db.sql&=", ";
				}
				first=false;
				db.sql&="`"&i&"`="&db.param(c[i], 'cf_sql_varchar');
			} 
			db.sql&=" WHERE site_id =#db.param(c.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# and 
			site_x_option_group_id=#db.param(c.site_x_option_group_id)# ";
			db.execute("qUpdate");
		}
	} 
	if(form.site_x_option_group_set_id EQ 0){
		throw("An error occurred when creating the site_x_option_group_set record.");
	}
	libraryId=application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id');
	if(libraryId NEQ 0 and libraryId NEQ ""){
		if(form.site_x_option_group_set_approved EQ 1){
			application.zcore.imageLibraryCom.approveLibraryId(libraryId);
		}else{
			application.zcore.imageLibraryCom.unapproveLibraryId(libraryId);
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds2<br>'); startTime=gettickcount();
	arrDataStructKeys=structkeyarray(newDataStruct);
	if(methodBackup NEQ "publicInsertGroup" and methodBackup NEQ "publicAjaxInsertGroup" and methodBackup NEQ "publicMapInsertGroup" and methodBackup NEQ "importInsertGroup"){
		db.sql="update #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		set site_x_option_group_set_override_url=#db.param(application.zcore.functions.zso(form,'site_x_option_group_set_override_url'))#,
		site_x_option_group_set_approved=#db.param(form.site_x_option_group_set_approved)#, 
		 site_x_option_group_set_start_date=#db.param(form.site_x_option_group_set_start_date)#,
		 site_x_option_group_set_end_date=#db.param(form.site_x_option_group_set_end_date)#,
		site_x_option_group_set_image_library_id=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'))#, 
		site_x_option_group_set_updated_datetime=#db.param(request.zos.mysqlNow)# , 
		site_x_option_group_set_title=#db.param(form.siteOptionTitle)# , 
		site_x_option_group_set_summary=#db.param(form.siteOptionSummary)#,
		site_x_option_group_set_metatitle=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metatitle'))#,
		site_x_option_group_set_metakey=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metakey'))#,
		site_x_option_group_set_metadesc=#db.param(application.zcore.functions.zso(form, 'site_x_option_group_set_metadesc'))#";
		if(hasUserField){
			db.sql&=", site_x_option_group_set_user=#db.param(userFieldValue)# ";
		}
		db.sql&=" WHERE 
		site_x_option_group_set_deleted = #db.param(0)# and
		site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("qUpdate");
	}
	if(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id') NEQ ""){
        	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id'));
	}
	/*
	// this isn't necessary, is it?
	db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  WHERE 
	site_x_option_group.site_option_app_id = #db.param(form.site_option_app_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
	site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_x_option_group_updated_datetime<#db.param(nowDate)# and 
	site_x_option_group_deleted = #db.param(0)# ";
	q=db.execute("q");
	*/
	application.zcore.routing.updateSiteOptionGroupSetUniqueURL(form.site_x_option_group_set_id);


	if(qCheck.site_option_group_parent_field NEQ ""){
		// resort all records
		for(row in qCheck){
			mainGroupStruct=row;
		}
		resortSetByParentField(mainGroupStruct);
	}
	
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds3<br>'); startTime=gettickcount();
	if(request.zos.enableSiteOptionGroupCache and not structkeyexists(request.zos, 'disableSiteCacheUpdate') and qCheck.site_option_group_enable_cache EQ 1){ 
		application.zcore.siteOptionCom.updateOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id); 
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id); 
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds4<br>'); startTime=gettickcount();
	if(qCheck.site_option_group_enable_unique_url EQ 1 and qCheck.site_option_group_public_searchable EQ 1){//  and qCheck.site_option_group_parent_id EQ 0
		if(qCheck.site_option_group_parent_id NEQ 0){
			parentStruct=application.zcore.functions.zGetSiteOptionGroupById(qCheck.site_option_group_parent_id);
			arrGroupName=[];
			while(true){
				arrayAppend(arrGroupName, parentStruct.site_option_group_name);
				if(parentStruct.site_option_group_parent_id NEQ 0){
					parentStruct=application.zcore.functions.zGetSiteOptionGroupById(parentStruct.site_option_group_parent_id);
				}else{
					break;
				}
			}
			arrayAppend(arrGroupName, qCheck.site_option_group_display_name);
			application.zcore.siteOptionCom.searchReindexSet(form.site_x_option_group_set_id, request.zos.globals.id, arrGroupName);
		}else{
			application.zcore.siteOptionCom.searchReindexSet(form.site_x_option_group_set_id, request.zos.globals.id, [qCheck.site_option_group_display_name]);
		}
	}

	// If one of the parent groups has a change cfc defined, we need to execute the update function on that cfc here
	parentId=qCheck.site_option_group_parent_id; 
	loopCount=0;
	while(true){
		if(parentId EQ 0){
			break;
		}
		loopCount++;
		if(loopCount GT 50){
			throw("Possible infinite loop detected for site_option_group_id: #parentId# - must change the site_option_group_parent_id value manually.");
		}
		groupStruct=application.zcore.functions.zGetSiteOptionGroupById(parentId);
		if(groupStruct.site_option_group_change_cfc_path NEQ "" and groupStruct.site_option_group_change_cfc_children EQ 1){
			// execute the change cfc path with the parent data, not current record.

			// get the data for the right site_x_option_group_set_id based on loop of site_x_option_group_set_parent_id?
			setParentId=form.site_x_option_group_set_parent_id;
			loopCount2=0;
			while(true){
				if(setParentId EQ 0){
					break;
				} 
				loopCount2++;
				if(loopCount GT 50){
					throw("Possible infinite loop detected for site_x_option_group_set_id: #setParentId# - must change the site_x_option_group_parent_id value manually.");
				}
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
				site_x_option_group_set_deleted=#db.param(0)# and 
				site_id = #db.param(qCheck.site_id)# and 
				site_x_option_group_set_id=#db.param(setParentId)#";
				qSet=db.execute("qSet");
				if(qSet.recordcount EQ 0){
					break;
				}
				for(row in qSet){
					if(groupStruct.site_option_group_id EQ row.site_option_group_id){
						// this is the right record, execute here
						path=groupStruct.site_option_group_change_cfc_path;
						if(left(path, 5) EQ "root."){
							path=request.zRootCFCPath&removeChars(path, 1, 5);
						}
						changeCom=application.zcore.functions.zcreateObject("component", path); 
						arrGroupName=application.zcore.siteOptionCom.getOptionGroupNameArrayById(groupStruct.site_option_group_id);
						dataStruct=application.zcore.siteOptionCom.getOptionGroupSetById(arrGroupName, row.site_x_option_group_set_id, request.zos.globals.id, true);
						coreStruct={
							site_x_option_group_set_sort:dataStruct.__sort,
							// NOT USED YET: site_x_option_group_set_active:dataStruct.__active,
							site_option_group_id:dataStruct.__groupId,
							site_x_option_group_set_approved:dataStruct.__approved,
							site_x_option_group_set_override_url:application.zcore.functions.zso(dataStruct, '__url'),
							site_x_option_group_set_parent_id:dataStruct.__parentId,
							site_x_option_group_set_image_library_id:application.zcore.functions.zso(dataStruct, '__image_library_id', true),
							site_x_option_group_set_id:dataStruct.__setId
						};  
						changeCom[groupStruct.site_option_group_change_cfc_update_method](dataStruct, coreStruct);
					}
					setParentId=row.site_x_option_group_set_parent_id;
				}
			}
		}
		parentId=groupStruct.site_option_group_parent_id; 
	} 

	if(qCheck.site_option_group_change_cfc_path NEQ ""){ 
		path=qCheck.site_option_group_change_cfc_path;
		if(left(path, 5) EQ "root."){
			path=request.zRootCFCPath&removeChars(path, 1, 5);
		}
		if(form.site_x_option_group_set_approved EQ 0){
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			changeCom[qCheck.site_option_group_change_cfc_delete_method](form.site_x_option_group_set_id);
		}else{
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			arrGroupName=application.zcore.siteOptionCom.getOptionGroupNameArrayById(qCheck.site_option_group_id);
			dataStruct=application.zcore.siteOptionCom.getOptionGroupSetById(arrGroupName, form.site_x_option_group_set_id, request.zos.globals.id, true);
			coreStruct={
				site_x_option_group_set_sort:dataStruct.__sort,
				// NOT USED YET: site_x_option_group_set_active:dataStruct.__active,
				site_option_group_id:dataStruct.__groupId,
				site_x_option_group_set_approved:dataStruct.__approved,
				site_x_option_group_set_override_url:application.zcore.functions.zso(dataStruct, '__url'),
				site_x_option_group_set_parent_id:dataStruct.__parentId,
				site_x_option_group_set_image_library_id:application.zcore.functions.zso(dataStruct, '__image_library_id', true),
				site_x_option_group_set_id:dataStruct.__setId
			}; 
			changeCom[qCheck.site_option_group_change_cfc_update_method](dataStruct, coreStruct);
		}
	}
 
	
	mapRecord=false;
	if(not structkeyexists(form, 'disableSiteOptionGroupMap')){
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('disableSiteOptionGroupMap doesn''t exist (not an error) | #qCheck.site_option_group_name# | qCheck.site_option_group_map_insert_type=#qCheck.site_option_group_map_insert_type# | methodBackup = #methodBackup#<br />');
		}
		form.disableSiteOptionGroupMap=true;
		if(qCheck.site_option_group_map_insert_type EQ 1){
			if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup"){
				mapRecord=true;
			}
		}else if(qCheck.site_option_group_map_insert_type EQ 2){
			if((methodBackup EQ "updateGroup" or methodBackup EQ "userUpdateGroup" or methodBackup EQ "internalGroupUpdate") and form.site_x_option_group_set_approved EQ 1){
				// only if this record was just approved
				mapRecord=true;
			}
		}
	}else{

		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('disableSiteOptionGroupMap exists<br />');
		}
	}
	setIdBackup=form.site_x_option_group_set_id; 
	disableSendEmail=false;
	setIdBackup2=form.site_x_option_group_set_id;
	groupIdBackup2=qCheck.site_option_group_id;
	arrEmailStruct=[];
	if((methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicAjaxInsertGroup") and qCheck.site_option_group_lead_routing_enabled EQ 1 and not structkeyexists(form, 'disableGroupEmail')){
		
		if(qCheck.site_option_group_newsletter_opt_in_form EQ 1){
			form.inquiries_email_opt_in=1;
		}
		newDataStruct.site_x_option_group_set_id=setIdBackup2; 
		newDataStruct.site_option_group_id=groupIdBackup2;

		if(qCheck.site_option_group_disable_detailed_lead_email EQ 1){
			form.inquiries_disable_detailed_lead_email=1;
		}
		
		if(qCheck.site_option_group_email_cfc_path NEQ "" and qCheck.site_option_group_email_cfc_method NEQ ""){
			if(left(qCheck.site_option_group_email_cfc_path, 5) EQ "root."){
				cfcpath=replace(qCheck.site_option_group_email_cfc_path, 'root.',  request.zRootCfcPath);
			}else{
				cfcpath=qSet.site_option_group_email_cfc_path;
			}
		} 
		if(qCheck.site_option_group_map_fields_type EQ 1){
 
			if(qCheck.site_option_group_email_cfc_path NEQ "" and qCheck.site_option_group_email_cfc_method NEQ ""){ 
				tempCom=application.zcore.functions.zcreateobject("component", cfcpath); 
				emailStruct=tempCom[qCheck.site_option_group_email_cfc_method](newDataStruct, arrDataStructKeys);
				if(qCheck.site_option_group_disable_custom_routing EQ 0){
					arrayAppend(arrEmailStruct, emailStruct);
				}
				if(qCheck.site_option_group_force_send_default_email EQ 1){ 
					// ignore this branch.
				}else{
					disableSendEmail=true;
				}
				 
			}
		}else if(qCheck.site_option_group_map_fields_type EQ 0 or qCheck.site_option_group_map_fields_type EQ 2){
			if(qCheck.site_option_group_email_cfc_path NEQ "" and qCheck.site_option_group_email_cfc_method NEQ ""){
				tempCom=application.zcore.functions.zcreateobject("component", cfcpath);
				emailStruct=tempCom[qCheck.site_option_group_email_cfc_method](newDataStruct, arrDataStructKeys);
				if(qCheck.site_option_group_disable_custom_routing EQ 0){
					arrayAppend(arrEmailStruct, emailStruct);
				}
				if(qCheck.site_option_group_force_send_default_email EQ 1){
					arrayAppend(arrEmailStruct, variables.generateGroupEmailTemplate(newDataStruct, arrDataStructKeys));
				}else{
					disableSendEmail=true;
				}
			}else{
				arrayAppend(arrEmailStruct, variables.generateGroupEmailTemplate(newDataStruct, arrDataStructKeys));
				disableSendEmail=true;
			}
		} 
	}
	if(structkeyexists(request.zos, 'debugleadrouting')){
		echo('mapRecord:#mapRecord#<br />');
	}
	if(qCheck.site_option_group_lead_routing_enabled NEQ 1){
		disableSendEmail=true;
	}
	if(mapRecord){
		if(qCheck.site_option_group_map_fields_type EQ 1){ 
			newDataMappedStruct.site_option_group_id =form.site_option_group_id;
			form.inquiries_type_id =qCheck.inquiries_type_id;
			newDataMappedStruct.inquiries_type_id =qCheck.inquiries_type_id;
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo('mapDataToInquiries<br />');
			}
			form.inquiries_id=mapDataToInquiries(newDataMappedStruct, form, disableSendEmail); 
		}else if(qCheck.site_option_group_map_fields_type EQ 2){
			if(qCheck.site_option_group_map_group_id NEQ 0){
				groupIdBackup2=qCheck.site_option_group_map_group_id;
				newDataStruct.site_option_group_id =form.site_option_group_id;
				newDataStruct.site_option_group_map_group_id=qCheck.site_option_group_map_group_id;
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo('mapDataToGroup<br />');
				}
				mapDataToGroup(newDataStruct, form, disableSendEmail); 
			}
		}
		setIdBackup2=form.site_x_option_group_set_id; 
		if(qCheck.site_option_group_delete_on_map EQ 1){
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo('autoDeleteGroup<br />');
			}
			form.site_option_group_id=qCheck.site_option_group_id;
			form.site_x_option_group_set_id=setIdBackup;
			tempResult=variables.autoDeleteGroup(); 
		}
	}
	if(disableSendEmail and application.zcore.functions.zso(form, 'disableGroupEmail', false, false) EQ false){
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('site-options|sendEmail<br />');
			writedump(arrEmailStruct);
		}
 
		for(i=1;i<=arraylen(arrEmailStruct);i++){
			emailStruct=arrEmailStruct[i];
			ts=StructNew();
			
			ts.to=request.officeEmail;
			ts.from=request.fromEmail;
			ts.embedImages=true;
			structappend(ts, emailStruct, true);
			if(qCheck.inquiries_type_id NEQ 0){
				leadStruct=application.zcore.functions.zGetLeadRouteForInquiriesTypeId(ts.from, qCheck.inquiries_type_id, qCheck.inquiries_type_id_siteIDType);
				//writedump(leadStruct);
				if(structkeyexists(leadStruct, 'bcc')){
					ts.bcc=leadStruct.bcc;
				}
				if(leadStruct.user_id NEQ "0"){
					ts.user_id=leadStruct.user_id;
					ts.user_id_siteIDType=leadStruct.user_id_siteIDType;
				}
				if(leadStruct.assignEmail NEQ ""){
					ts.to=leadStruct.assignEmail;
				}
			} 
			ts.site_id=request.zos.globals.id; 
			if(structkeyexists(request.zos, 'debugleadrouting')){
				ts.preview=true;
			}
			rCom=application.zcore.email.send(ts);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				writedump(ts);
				writedump(rCom.getData());
			}
			if(rCom.isOK() EQ false){
				rCom.setStatusErrors(request.zsid);
				application.zcore.functions.zstatushandler(request.zsid);
				application.zcore.functions.zabort();
			}
		}
	}
	if(structkeyexists(request.zos, 'debugleadrouting')){
		echo("Aborted before returning from site option group processing.");
		abort;
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds5<br>'); startTime=gettickcount();
	if(debug) application.zcore.functions.zabort();

	urlformtoken="";
	formtoken="";
	if(qCheck.site_option_group_public_thankyou_token NEQ ""){
		formtoken=setIdBackup&"-"&application.zcore.functions.zso(form, 'inquiries_id');
		request.zsession[qCheck.site_option_group_public_thankyou_token]=formtoken;
		urlformtoken="&"&qCheck.site_option_group_public_thankyou_token&"="&formtoken;
	}

	if(methodBackup EQ "userUpdateGroup" or methodBackup EQ "userInsertGroup"){
		if(qCheck.site_option_group_change_email_usergrouplist NEQ ""){
			newAction='created';
			if(methodBackup CONTAINS 'update'){
				newAction='updated';
			}else if(methodBackup CONTAINS 'import'){
				newAction='imported';
			}
			application.zcore.siteOptionCom.sendChangeEmail(setIdBackup, newAction);
		}
	}
	request.zsession.zLastSiteXOptionGroupSetId=setIdBackup;
	request.zsession.zLastInquiriesID=application.zcore.functions.zso(form, 'inquiries_id');
	if(methodBackup EQ "publicMapInsertGroup" or methodBackup EQ "publicAjaxInsertGroup" or methodBackup EQ "internalGroupUpdate" or methodBackup EQ "importInsertGroup"){
		ts={success:true, zsid:request.zsid, site_x_option_group_set_id:setIdBackup, formtoken:formtoken, inquiries_id: application.zcore.functions.zso(form, 'inquiries_id')};
		return ts;
	}else if(methodBackup EQ "publicInsertGroup" or methodBackup EQ "publicUpdateGroup"){ 
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
		application.zcore.status.setStatus(request.zsid,"Saved successfully.");
		if(structkeyexists(arguments.struct, 'successURL')){
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.successURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#&site_x_option_group_set_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken));
		}else{
			if(qCheck.site_option_group_public_thankyou_url NEQ ""){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(qCheck.site_option_group_public_thankyou_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#&site_x_option_group_set_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken));
			}else{
				application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&site_x_option_group_set_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken);
			}
		}
	}else if(form.modalpopforced EQ 1 and (methodBackup EQ "updateGroup" or methodBackup EQ "userUpdateGroup" or methodBackup EQ "insertGroup" or methodBackup EQ "userInsertGroup")){
		newAction="getRowHTML";
		if(methodBackup EQ "insertGroup" or methodBackup EQ "userInsertGroup"){
			newRecord=true;
		}else{
			newRecord=false;
		}
		if(qCheck.site_option_group_parent_field NEQ ""){				

			// tell parent page to reload, instead of displaying the row html
			application.zcore.functions.zReturnJson({success:true, id:setIdBackup, reload:true, newRecord:newRecord});
		}
		form.site_x_option_group_set_id=setIdBackup;
		if(methodBackup EQ "userUpdateGroup" or methodBackup EQ "userInsertGroup"){ 
			form.method="userGetRowHTML";
			rowHTML=userGetRowHTML();
		}else{
			form.method="getRowHTML";
			rowHTML=getRowHTML();
		}
		application.zcore.functions.zReturnJson({success:true, id:setIdBackup, rowHTML:rowHTML, newRecord:newRecord});
 
	}else{


		if(form.modalpopforced NEQ 1 and structkeyexists(request.zsession, 'siteOptionGroupReturnURL') and request.zsession.siteOptionGroupReturnURL NEQ ""){
			tempLink=request.zsession.siteOptionGroupReturnURL;
			structdelete(request.zsession, 'siteOptionGroupReturnURL');
			tempLink=replace(tempLink, "zsid=", "ztv=", "all");
			//application.zcore.functions.zRedirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.status.setStatus(request.zsid,"Saved successfully.");
			tempLink=defaultStruct.listURL&"?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#form.modalpopforced#";
			//application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#form.modalpopforced#");
		}
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink: tempLink});
	}
	</cfscript>
</cffunction>

<cffunction name="getSortedData" localmode="modern" access="public">
	<cfargument name="groupQuery" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select 
	site_x_option_group_set.site_x_option_group_set_id, 
	site_x_option_group_value, 
	site_x_option_group_set_sort from 
	#db.table("site_option", request.zos.zcoreDatasource)#,
	#db.table("site_x_option_group", request.zos.zcoreDatasource)#,
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)#
	 WHERE 
	site_option_name=#db.param(arguments.groupQuery.site_option_group_parent_field)# and 
	site_option.site_option_group_id=#db.param(arguments.groupQuery.site_option_group_id)# and 
	site_option.site_id=#db.param(request.zos.globals.id)# and 
	site_x_option_group.site_option_id=site_option.site_option_id and 
	site_x_option_group.site_id=site_option.site_id and 
	site_x_option_group.site_x_option_group_deleted=#db.param(0)# and 

	site_x_option_group_set.site_x_option_group_set_id=site_x_option_group.site_x_option_group_set_id and 
	site_x_option_group_set.site_id=site_option.site_id and 
	site_x_option_group_set.site_x_option_group_set_deleted=#db.param(0)# and 
	site_option_deleted=#db.param(0)# 
	ORDER BY site_x_option_group_set_sort ASC ";
	qOption=db.execute("qOption", "", 10000, "query", false); 
	rs={
		arrOrder:[],
		arrLevel:[]
	};
	if(qOption.recordcount NEQ 0){
		addChildrenToParentOrder(qOption, rs.arrOrder, rs.arrLevel, "", 0);
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="resortSetByParentField" localmode="modern" access="public">
	<cfargument name="groupQuery" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	rs=getSortedData(arguments.groupQuery);
	for(i=1;i<=arraylen(rs.arrOrder);i++){
		db.sql="update #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#
		set 
		site_x_option_group_set_sort=#db.param(i)#, 
		site_x_option_group_set_level=#db.param(rs.arrLevel[i])# 
		WHERE 
		site_x_option_group_set.site_x_option_group_set_id=#db.param(rs.arrOrder[i])# and 
		site_x_option_group_set.site_id=#db.param(request.zos.globals.id)# and 
		site_x_option_group_set.site_x_option_group_set_deleted=#db.param(0)#";
		db.execute("qUpdate");

		// fire onChange com if there is one
		if(arguments.groupQuery.site_option_group_change_cfc_path NEQ ""){
			path=arguments.groupQuery.site_option_group_change_cfc_path;
			if(left(path, 5) EQ "root."){
				path=request.zRootCFCPath&removeChars(path, 1, 5);
			}
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			changeCom[arguments.groupQuery.site_option_group_change_cfc_sort_method](row.site_x_option_group_set_id, i); 
		}
	}
	</cfscript>
</cffunction>

<cffunction name="addChildrenToParentOrder" localmode="modern" access="public">
	<cfargument name="optionQuery" type="query" required="yes">
	<cfargument name="arrOrder" type="array" required="yes">
	<cfargument name="arrLevel" type="array" required="yes">
	<cfargument name="parentId" type="string" required="yes">
	<cfargument name="recursionCount" type="numeric" required="yes">
	<cfscript>
	arguments.recursionCount++;
	if(arguments.recursionCount GT 100){
		throw("Possible infinite recursion detected in parent/child relationships");
	}
	for(row in optionQuery){
		if(arguments.parentID EQ row.site_x_option_group_value){ 
			arrayAppend(arrOrder, row.site_x_option_group_set_id);
			arrayAppend(arrLevel, arguments.recursionCount-1);
			addChildrenToParentOrder(optionQuery, arrOrder, arrLevel, row.site_x_option_group_set_id, recursionCount);
		}
	}
	</cfscript>
</cffunction>

<!--- 
Define this function in another CFC to override the default email format
<cffunction name="publicEmailExample" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<cfscript>
	var rs={
		html:"",
		text:"",
		subject:""
	};
	rs.html='#application.zcore.functions.zHTMLDoctype()#
	<head>
	<meta charset="utf-8" />
	<title>Email</title>
	</head>
	
	<body>
	<p>Testing email</p>
	<p>'&application.zcore.functions.zso(ss, 'title')&'</p>
	</body>
	</html>';
	rs.subject="Test subject";
	rs.text="Testing email";
	return rs;
	</cfscript>
</cffunction>
 --->
 
 
<!--- variables.mapDataToInquiries(form); --->
<cffunction name="mapDataToInquiries" localmode="modern" access="public">
	<cfargument name="newDataMappedStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="disableEmail" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=arguments.newDataMappedStruct;
	var rs=0;
	var row=0;
	var db=request.zos.queryObject; 
	form.inquiries_spam=application.zcore.functions.zso(form, 'inquiries_spam', false, 0);
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# "; 
	qGroup=db.execute("qGroup"); 
	db.sql="select site_option_group_map.*, s2.site_option_display_name, s2.site_option_name originalFieldName from 
	#db.table("site_option_group_map", request.zos.zcoredatasource)# site_option_group_map,  
	#db.table("site_option", request.zos.zcoredatasource)# s2
	WHERE site_option_group_map.site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	s2.site_option_deleted = #db.param(0)# and
	site_option_group_map.site_id = #db.param(request.zos.globals.id)# and  
	site_option_group_map.site_id = s2.site_id and 
	site_option_group_map.site_option_id = s2.site_option_id and 
	site_option_group_map.site_option_group_id =s2.site_option_group_id 
	ORDER BY s2.site_option_sort asc";
	qMap=db.execute("qMap", "", 10000, "query", false);
	 
	if(qMap.recordcount EQ 0){
		throw('site_option_group_id, "#ts.site_option_group_id#", on site_id, "#request.zos.globals.id#" isn''t mapped 
		yet so the data can''t be stored in inquiries table or emailed. 
		The form data below must be manually forwarded to the web site owner or resubmitted.');
		return;
	} 


	form.emailLabelStruct={};
	countStruct=structnew();
	for(row in qMap){
		if(row.site_option_group_map_fieldname NEQ ""){
			if(not structkeyexists(countStruct, row.site_option_group_map_fieldname)){
				countStruct[row.site_option_group_map_fieldname]=1;
			}else{
				countStruct[row.site_option_group_map_fieldname]++;
			}
		}
	} 
	var jsonStruct={ arrCustom: [] };
	// this doesn't support all fields yet, I'd have to use getListValue on all the rows instead - or does it?
	for(row in qMap){ 
		if(row.site_option_group_map_fieldname NEQ ""){
			if(structkeyexists(ts, row.originalFieldName)){
				if(row.site_option_group_map_fieldname EQ "inquiries_custom_json"){
					arrayAppend(jsonStruct.arrCustom, { label: row.site_option_display_name, value: ts[row.originalFieldName] });
				}else{
					tempString="";
					if(structkeyexists(form, row.site_option_group_map_fieldname)){
						tempString=form[row.site_option_group_map_fieldname];
					}
					if(countStruct[row.site_option_group_map_fieldname] GT 1){
						//if(request.zos.isdeveloper){ writeoutput('shared:'&row.originalFieldName&'<br />'); }
						form[row.site_option_group_map_fieldname]=tempString&row.originalFieldName&": "&ts[row.originalFieldName]&" "&chr(10); 
					}else{
						//if(request.zos.isdeveloper){ writeoutput(' not shared:'&row.originalFieldName&'<br />'); }
						form[row.site_option_group_map_fieldname]=ts[row.originalFieldName]; 
					}
				}
			} 
		}
	} 
	if(structcount(jsonStruct)){
		form.inquiries_custom_json=serializejson(jsonStruct);
	}
	/*
	if(request.zos.isdeveloper){
		writedump(arguments.sourceStruct);
		writedump(ts);
		writedump(qMap);
		writedump(countStruct);
		writedump(form);
		abort;
	}*/
	form.inquiries_session_id=application.zcore.session.getSessionId(); 
	form.inquiries_type_id=qGroup.inquiries_type_id;
	form.inquiries_type_id_siteIDType=qGroup.inquiries_type_id_siteIDType; 

	if(application.zcore.functions.zso(form, 'zRefererURL') NEQ ""){
		if(left(form.zRefererURL, 1) EQ "/"){
			form.zRefererURL=request.zos.globals.domain&form.zRefererURL;
		}
		form.inquiries_referer=form.zRefererURL;
	}
	if(form.inquiries_type_id EQ 0 or form.inquiries_type_id EQ ""){
		form.inquiries_type_id=1;
		form.inquiries_type_id_siteIDType=4;
	}
	form.inquiries_datetime=request.zos.mysqlnow;
	form.inquiries_status_id = 1;
	form.site_id = request.zOS.globals.id; 
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ ""){ 
		application.zcore.tracking.setUserEmail(form.inquiries_email);
	} 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	
	application.zcore.tracking.setConversion('inquiry',form.inquiries_id);
	tempStruct=form;
	application.zcore.functions.zUserMapFormFields(tempStruct);
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ "" and application.zcore.functions.zEmailValidate(form.inquiries_email)){
		form.contact_id=application.zcore.user.automaticAddUser(form);
	}
	// form.inquiries_spam EQ 0 and 
	 if(not arguments.disableEmail and application.zcore.functions.zso(form, 'disableGroupEmail', false, false) EQ false){
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		if(qGroup.site_option_group_public_form_title EQ ""){
			tempTitle="Lead capture";
		}else{
			tempTitle=qGroup.site_option_group_public_form_title;
		}
		ts.subject="#tempTitle# form submitted on #request.zos.currentHostName#";
		// send the lead

		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('zAssignAndEmailLead<br />');
		}
		ts.disableDebugAbort=true;
		ts.arrAttachments=request.zos.arrForceEmailAttachment; 
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	 }
	return form.inquiries_id;
	</cfscript>
</cffunction>

<!--- variables.mapDataToGroup(form); --->
<cffunction name="mapDataToGroup" localmode="modern" access="public">
	<cfargument name="newDataStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="disableEmail" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=arguments.newDataStruct;
	var row=0;
	var db=request.zos.queryObject;
	if(ts.site_option_group_map_group_id EQ ts.site_option_group_id){
		// can't map to the same group
		return;
	}
	db.sql="select site_option.*, s2.site_option_name originalFieldName from 
	#db.table("site_option_group_map", request.zos.zcoredatasource)# site_option_group_map, 
	#db.table("site_option", request.zos.zcoredatasource)# site_option, 
	#db.table("site_option", request.zos.zcoredatasource)# s2
	WHERE site_option_group_map.site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_map.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_map.site_id = site_option.site_id and 
	site_option_group_map.site_option_group_map_fieldname = site_option.site_option_id and 
	site_option.site_option_group_id = #db.param(ts.site_option_group_map_group_id)# and
	site_option_deleted = #db.param(0)# and 
	s2.site_option_deleted = #db.param(0)# and 
	site_option_group_map_deleted = #db.param(0)# and
	site_option_group_map.site_id = s2.site_id and 
	site_option_group_map.site_option_id = s2.site_option_id and 
	site_option_group_map.site_option_group_id =s2.site_option_group_id
	";
	qMap=db.execute("qMap");
	if(qMap.recordcount EQ 0){
		throw('site_option_group_id, "#ts.site_option_group_id#", on site_id, "#request.zos.globals.id#" isn''t mapped 
		yet so the data can''t be stored in site_option_group table or emailed. 
		The form data below must be manually forwarded to the web site owner or resubmitted.');
		return;
	}
	arrId=[];
	countStruct=structnew();
	for(row in qMap){
		if(not structkeyexists(countStruct, row.site_option_name)){
			countStruct[row.site_option_name]=0;
		}else{
			countStruct[row.site_option_name]++;
		}
	}
	for(row in qMap){
		// new newValue
		if(structkeyexists(ts, row.originalFieldName)){
			tempString="";
			if(structkeyexists(form, row.site_option_name)){
				tempString=form[row.site_option_name];
			}
			form["newValue"&row.site_option_id]=ts[row.originalFieldName]; 
			if(countStruct[row.site_option_name] GT 1){
				ts[row.site_option_name]=tempString&row.originalFieldName&": "&ts[row.originalFieldName]&" "&chr(10); 
			}else{
				ts[row.site_option_name]=ts[row.originalFieldName]; 
			}  
		}else if(not structkeyexists(form, "newValue"&row.site_option_id)){
			form["newValue"&row.site_option_id]="";
			ts[row.site_option_name]="";
		}
		arrayAppend(arrId, row.site_option_id);
	}
	form.site_option_id=arrayToList(arrId, ",");
	form.site_id=request.zos.globals.id;
	form.site_option_group_id=ts.site_option_group_map_group_id;
	form.site_x_option_group_set_id=0;
	form.disableGroupEmail=arguments.disableEmail;

	variables.publicMapInsertGroup(); 
	structdelete(form, 'disableGroupEmail');
	</cfscript>
</cffunction>
	
<cffunction name="generateGroupEmailTemplate" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<!--- <cfargument name="site_option_group_id" type="struct" required="yes">
	<cfargument name="subject" type="struct" required="yes"> --->
	<cfscript>
	var ts=arguments.ss;
	var i=0;
	var db=request.zos.queryObject;
	var rs={
		subject:"",
		html:"",
		text:""
	};
	arraySort(arguments.arrKey, "text", "asc");
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
	WHERE site_option_group_id = #db.param(ts.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qD=db.execute("qD");
	rs.subject='New '&qd.site_option_group_display_name&' submitted on '&request.zos.globals.shortDomain;
	editLink=request.zos.currentHostName&"/z/admin/site-options/editGroup?site_option_group_id=#ts.site_option_group_id#&site_x_option_group_set_id=#ts.site_x_option_group_set_id#";
	savecontent variable="output"{
		writeoutput('New '&qd.site_option_group_display_name&' submitted'&chr(10)&chr(10));
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "site_option_group_id" and arguments.arrKey[i] NEQ "site_x_option_group_set_id"){
				writeoutput(arguments.arrKey[i]&': '&ts[arguments.arrKey[i]]&chr(10));
			}
		}
		writeoutput(chr(10)&chr(10)&'Edit in Site Manager'&chr(10)&editLink);
	}
	rs.text=output;
	savecontent variable="output"{
		writeoutput('#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>'&rs.subject&'</title>
		</head>
		
		<body>
		<p>New '&htmleditformat(qd.site_option_group_display_name)&' submitted on '&request.zos.globals.shortDomain&'</p>
		<table style="border-spacing:0px;">');
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "site_option_group_id" and arguments.arrKey[i] NEQ "site_x_option_group_set_id"){
				writeoutput('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">'&htmleditformat(arguments.arrKey[i])&':</td><td style="padding:5px; border-bottom:1px solid ##CCC;">'&htmleditformat(ts[arguments.arrKey[i]])&'</td></tr>');
			}
		}
		approved=application.zcore.functions.zso(form, 'site_x_option_group_set_approved');
		if(approved EQ 0){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Pending</td></tr>');
		}else if(approved EQ 2){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Deactivated By User</td></tr>');
		}else if(approved EQ 4){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Rejected</td></tr>');
		}else if(approved EQ 1){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved</td></tr>');
		}
		writeoutput('</table>
		<br /><p><a href="#htmleditformat(editLink)#">Edit in Site Manager</a></p>
		</body>
		</html>');
	}
	rs.html=output;
	return rs;
	</cfscript>
</cffunction>



	

<cffunction name="sectionGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;

	//echo('<p><a href="/z/admin/site-options/manageGroup?site_option_group_id=9">Back to custom</a></p>');
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	//application.zcore.siteOptionCom.displaySectionNav();

	if(application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		echo('<h2>Pages</h2><p>');
		echo('<a href="#application.zcore.app.getAppCFC("content").getSectionHomeLink(form.site_x_option_group_set_id)#" target="_blank">View Pages Section Home</a> | ');
		echo('<a href="/z/content/admin/content-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Pages</a> | ');
		echo('<a href="/z/content/admin/content-admin/add?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Page</a></p>');
	}
	if(application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		echo('<h2>Blog</h2><p>');
		echo('<a href="#application.zcore.app.getAppCFC("blog").getSectionHomeLink(form.site_x_option_group_set_id)#" target="_blank">View Blog Section Home</a> | ');
		echo('<a href="/z/blog/admin/blog-admin/articleList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Blog Articles</a> | ');
		echo('<a href="/z/blog/admin/blog-admin/articleAdd?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Article</a></p>');
		echo('<h2>Blog Category Section Links</h2>');
		db.sql="select * from #db.table("blog_category", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		blog_category_deleted = #db.param(0)# 
		ORDER BY blog_category_name ASC";
		qCategory=db.execute("qCategory");
		for(row in qCategory){
			link=application.zcore.app.getAppCFC("blog").getBlogCategorySectionLink(row, form.site_x_option_group_set_id);
			echo('<a href="#link#" target="_blank">'&row.blog_category_name&'</a><br />');
		}
	}
	/*if(application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		echo('<a href="/z/admin/menu/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Menus</a> | ');
		echo('<a href="/z/admin/menu/add?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Menu</a><br />');
	}*/
	/*if(application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Categories")){
		echo('<a href="/z/blog/admin/blog-admin/categoryList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Pages</a><br />');
		echo('<a href="/z/blog/admin/blog-admin/categoryAdd?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Add Page</a><br />');
	}*/
	</cfscript>

</cffunction>


<cffunction name="publicManageGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	this.manageGroup(arguments.struct);
	</cfscript>
</cffunction>


<cffunction name="userGetRowHTML" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	validateUserGroupAccess();
	return this.manageGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getRowHTML" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	return this.manageGroup(arguments.struct);
	</cfscript>
</cffunction>


<cffunction name="checkOptionCache" localmode="modern" access="public">
	<cfscript>
	tempStruct=application.siteStruct[request.zos.globals.id].globals; 
	if(not structkeyexists(tempStruct, 'soGroupData') or not structkeyexists(tempStruct.soGroupData, 'optionGroupLookup')){
		application.zcore.siteOptionCom.internalUpdateOptionAndGroupCache(tempStruct);
	}
	</cfscript>
</cffunction>


<cffunction name="validateUserGroupAccess" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	currentSetId=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true);
	currentParentId=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id', true);
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_id=#db.param(form.site_option_group_id)# ";
	qCheckGroup=db.execute("qCheckGroup");
	if(qCheckGroup.recordcount EQ 0){
		application.zcore.functions.z404("Invalid site_option_group_id");
	}
	if(not application.zcore.user.checkGroupAccess("user")){
		application.zcore.functions.z301redirect("/z/user/preference/index");
	}
	// only need to validate the topmost parent record.  the children should NOT be validated.
	// i should remove the options from groups that are not parent_id = 0 in edit group
	request.isUserPrimaryGroup=true;
	if(currentParentId NEQ 0 and currentSetId EQ 0){
		request.isUserPrimaryGroup=false;
		currentSetId=currentParentId;
	}
	qCheckSet={recordcount:0};
	if(currentSetId NEQ 0){ 
		first=true;
		i=0;
		while(true){
			if(not first){ 
				request.isUserPrimaryGroup=false;
			} 
			first=false;
			db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
			site_x_option_group_set_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_id=#db.param(currentSetId)# ";
			qCheckSet=db.execute("qCheckSet");
			if(qCheckSet.recordcount EQ 0){
				application.zcore.functions.z404("Invalid record.  set id doesn't exist: #currentSetId#");
			}
			if(qCheckSet.site_x_option_group_set_parent_id EQ 0){
				currentSetId=qCheckSet.site_x_option_group_set_id;
				break;
			}else{
				currentSetId=qCheckSet.site_x_option_group_set_parent_id;
			}
			i++;
			if(i > 255){
				throw("infinite loop");
			}
		} 
		if(currentSetId NEQ 0){
			if(qCheckSet.recordcount NEQ 0){
				db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
				site_option_group_deleted=#db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				site_option_group_id=#db.param(qCheckSet.site_option_group_id)# ";
				qCheckGroup=db.execute("qCheckGroup");
			}
			if(qCheckGroup.site_option_group_user_id_field EQ ""){
				application.zcore.functions.z404("This site_option_group requires site_option_group_user_id_field to be defined to enable user dashboard editing: #qCheckGroup.site_option_group_name#");
			} 
	 
			db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# site_option 
			where site_option_group_id = #db.param(qCheckSet.site_option_group_id)# and 
			site_option_deleted = #db.param(0)# and
			site_id =#db.param(request.zos.globals.id)# and 
			site_option_name=#db.param(qCheckGroup.site_option_group_user_id_field)#";
			qOption=db.execute("qOption");
			if(qOption.recordcount EQ 0){
				application.zcore.functions.z404("This site_option_group has an invalid site_option_group_user_id_field that doesn't exist: #qCheckGroup.site_option_group_user_id_field#");
			}
			db.sql="select * from #db.table("site_x_option_group", request.zos.zcoreDatasource)# WHERE 
			site_option_id=#db.param(qOption.site_option_id)# and 
			site_x_option_group_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_id=#db.param(currentSetId)# and 
			site_option_group_id=#db.param(qCheckSet.site_option_group_id)# ";
			qCheckValue=db.execute("qCheckValue");  
			if(qCheckValue.recordcount NEQ 0){
				siteIdType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id); 
				if(request.zsession.user.id&"|"&siteIdType NEQ qCheckValue.site_x_option_group_value){
					application.zcore.functions.z404("This user doesn't have access to this set record");
				}
			}else{
				application.zcore.functions.z404("User doesn't have access to this set record");
			}
		}
	} 
	if(qCheckGroup.site_option_group_user_group_id_list EQ ""){
		application.zcore.functions.z404("This site_option_group doesn't allow user dashboard editing: #qCheckGroup.site_option_group_name# (site_option_group_user_group_id_list is blank)");
	}
	arrId=listToArray(qCheckGroup.site_option_group_user_group_id_list); 
	for(i=1;i<=arraylen(arrId);i++){
		if(application.zcore.user.checkGroupIdAccess(arrId[i])){ 
			return;
		}
	} 
	application.zcore.functions.z404("User doesn't have access to this site_option_group: #qCheckGroup.site_option_group_name#");
	</cfscript>
</cffunction>


<cffunction name="userManageGroup" localmode="modern" access="remote"> 
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	echo('<p><a href="/z/user/home/index">Back to User Dashboard</a></p>');
	validateUserGroupAccess();
	manageGroup(arguments.struct);
	</cfscript>
</cffunction>
		

<cffunction name="manageGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var queueSortStruct = StructNew(); 
	var arrLabel=arraynew(1);
	var arrVal=arraynew(1);
	var arrType=arraynew(1);
	var arrRow=arraynew(1);

	fakeRow={};
	fakePrimaryId=0;	
	fakePrimaryLabel="";	
	fakePrimaryType="";	
	var arrDisplay=[];
	var arrOptionStruct=[]; 
	var fakeRow={}; 
	methodBackup=form.method;
	if(methodBackup EQ "userManageGroup"){
		application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
	}
	request.isUserPrimaryGroup=application.zcore.functions.zso(request, 'isUserPrimaryGroup', false, false);
	savecontent variable="out"{
		defaultStruct=getDefaultStruct();
		structappend(arguments.struct, defaultStruct, false);
		if(not structkeyexists(arguments.struct, 'recurse')){
			variables.init(); 
		}
		
		
		form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
		if(not structkeyexists(request, 'manageGroupStatusHandlerOutput')){
			application.zcore.functions.zstatusHandler(request.zsid);
			request.manageGroupStatusHandlerOutput=true;
		}
		form.enableSorting=application.zcore.functions.zso(form, 'enableSorting', true, 0);

		if ( structKeyExists( form, 'searchOn' ) ) {
			form.enableSorting = 0;
			form.disableSorting = 1;
		}
		sog=application.zcore.siteOptionCom.getTypeData(request.zos.globals.id); 

		form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
		form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id',true);
		mainGroupStruct=application.zcore.functions.zso(sog.optionGroupLookup, form.site_option_group_id, false, {});
		if(structcount(mainGroupStruct) EQ 0){
			application.zcore.functions.zredirect("/z/admin/site-options/index");
		} 
		// db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
		// site_option_group_id = #db.param(form.site_option_group_id)# and 
		// site_option_group_deleted = #db.param(0)# and
		// site_id =#db.trustedsql(request.zos.globals.id)# ";
		// qGroup=db.execute("qGroup"); 
		
		// if(mainGroupStruct.recordcount EQ 0){
		// 	application.zcore.functions.zredirect("/z/admin/site-options/index");
		// }

		if(mainGroupStruct.site_option_group_enable_archiving EQ 1){
			form.showArchived=application.zcore.functions.zso(form, 'showArchived');
			if(form.showArchived EQ "1"){
				request.zsession['siteOptionGroupShowArchived#mainGroupStruct.site_option_group_id#']=true;
			}else if(form.showArchived EQ "0"){
				structdelete(request.zsession, 'siteOptionGroupShowArchived#mainGroupStruct.site_option_group_id#');
			}
		}
		showArchived=false;
		if(structkeyexists(request.zsession, 'siteOptionGroupShowArchived#mainGroupStruct.site_option_group_id#')){
			showArchived=true;
		}
		if(methodBackup EQ "userManageGroup"){ 
			arrUserGroup=listToArray(mainGroupStruct.site_option_group_user_group_id_list, ",");
			hasAccess=false;
			for(i=1;i LTE arraylen(arrUserGroup);i++){
				if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
					hasAccess=true;
					break;
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
			} 
		}


		// these are groups that children of mainGroupStruct
		// we also get the count of those children's set records
		arrChildGroup=[];
		for(groupId in sog.optionGroupLookup){
			group=sog.optionGroupLookup[groupId];
			if(group.site_option_group_parent_id EQ form.site_option_group_id){
				arrayAppend(arrChildGroup, group);
			}
		}
		// db.sql="select * 
		// from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group  
		// where 
		// site_option_group_deleted = #db.param(0)# and
		// site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_id)# and 
		// site_option_group.site_id = #db.param(request.zos.globals.id)# 
		// GROUP BY site_option_group.site_option_group_id
		// ORDER BY site_option_group.site_option_group_display_name";
		// q1=db.execute("q1");
		// this childCount wasn't used anymore
		// db.sql="select *, count(s3.site_option_group_id) childCount 
		// from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		// left join #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s3 ON 
		// site_option_group.site_option_group_id = s3.site_option_group_id and 
		// s3.site_id = site_option_group.site_id  and 
		// s3.site_x_option_group_set_master_set_id = #db.param(0)# and 
		// s3.site_x_option_group_set_deleted = #db.param(0)# ";
		// if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
		// 	db.sql&=" and site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
		// }
		// db.sql&=" where 
		// site_option_group_deleted = #db.param(0)# and
		// site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_id)# and 
		// site_option_group.site_id = #db.param(request.zos.globals.id)# 
		// GROUP BY site_option_group.site_option_group_id
		// ORDER BY site_option_group.site_option_group_display_name";
		// q1=db.execute("q1");


		sortEnabled=true;
		subgroupRecurseEnabled=false;
		subgroupStruct={}; 
		for(n in arrChildGroup){
			if(methodBackup EQ "userManageGroup"){ 
				arrUserGroup=listToArray(n.site_option_group_user_group_id_list, ",");
				hasAccess=false;
				for(i=1;i LTE arraylen(arrUserGroup);i++){
					if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
						hasAccess=true;
						break;
					}
				}
				if(hasAccess){
					subgroupStruct[n.site_option_group_id]=true;
				}
			}else{
				subgroupStruct[n.site_option_group_id]=true;
			}
		}
		if(form.enableSorting EQ 0){
			for(n in arrChildGroup){
				if(n.site_option_group_enable_list_recurse EQ "1"){
					sortEnabled=false;
					subgroupRecurseEnabled=true;
					break;
				}
			}
		}
		if(application.zcore.functions.zso(form, 'disableSorting', true, 0) EQ 1){
			sortEnabled=false;
			subgroupRecurseEnabled=false;
		}
		if(structkeyexists(arguments.struct, 'recurse') or mainGroupStruct.site_option_group_enable_sorting EQ 0){
			sortEnabled=false;
		}
		if(methodBackup EQ "userManageGroup"){
			currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
		}
		if(sortEnabled){
			queueSortStruct.tableName = "site_x_option_group_set";
			queueSortStruct.sortFieldName = "site_x_option_group_set_sort";
			queueSortStruct.primaryKeyName = "site_x_option_group_set_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.ajaxTableId='sortRowTable';
			queueSortStruct.ajaxURL=application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#&enableSorting=1");
			
			queueSortStruct.where =" site_x_option_group_set.site_option_app_id = '#application.zcore.functions.zescape(form.site_option_app_id)#' and  
			site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
			site_x_option_group_set_parent_id='#application.zcore.functions.zescape(form.site_x_option_group_set_parent_id)#' and 
			site_id = '#request.zos.globals.id#' and 
			site_x_option_group_set_master_set_id = '0' and 
			site_x_option_group_set_deleted='0' ";
			if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
				queueSortStruct.where &=" and site_x_option_group_set_user = '#application.zcore.functions.zescape(currentUserIdValue)#'";
			}
			
			queueSortStruct.disableRedirect=true;
			queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			r1=queueSortCom.init(queueSortStruct);
			if(structkeyexists(form, 'zQueueSort')){
				// update cache
				if(request.zos.enableSiteOptionGroupCache and mainGroupStruct.site_option_group_enable_cache EQ 1){
					application.zcore.siteOptionCom.updateOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id); 
				}
				//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
				// redirect with zqueuesort renamed
				application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
			}
			if(structkeyexists(form, 'zQueueSortAjax')){
				if(mainGroupStruct.site_option_group_parent_field NEQ ""){
					// resort all records
					resortSetByParentField(mainGroupStruct);
				}else{

					// update cache
					if(request.zos.enableSiteOptionGroupCache and mainGroupStruct.site_option_group_enable_cache EQ 1){
						application.zcore.siteOptionCom.resortOptionGroupSets(request.zos.globals.id, form.site_option_app_id, form.site_option_group_id, form.site_x_option_group_set_parent_id); 
					}else{

						t9=application.zcore.siteOptionCom.getTypeData(request.zos.globals.id);
						var groupStruct=t9.optionGroupLookup[form.site_option_group_id];
	 
						if(groupStruct.site_option_group_change_cfc_path NEQ ""){
							path=groupStruct.site_option_group_change_cfc_path;
							if(left(path, 5) EQ "root."){
								path=request.zRootCFCPath&removeChars(path, 1, 5);
							}
							changeCom=application.zcore.functions.zcreateObject("component", path); 
							offset=0;
							while(true){
								db.sql="select site_x_option_group_set_id FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
								WHERE 
								site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and  
								site_option_group_id = #db.param(form.site_option_group_id)# and 
								site_x_option_group_set_parent_id=#db.param(form.site_x_option_group_set_parent_id)# and 
								site_id = #db.param(request.zos.globals.id)# and 
								site_x_option_group_set_master_set_id = #db.param(0)# and 
								site_x_option_group_set_deleted=#db.param(0)# ";
								if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
									db.sql&=" and site_x_option_group_set_user = '#application.zcore.functions.zescape(currentUserIdValue)#'";
								}
								db.sql&=" ORDER BY site_x_option_group_set_sort ASC 
								LIMIT #db.param(offset)#, #db.param(20)#";
								qSorted=db.execute("qSorted");
								if(qSorted.recordcount EQ 0){
									break;
								}
								for(row in qSorted){
									offset++;
									changeCom[groupStruct.site_option_group_change_cfc_sort_method](row.site_x_option_group_set_id, offset); 
								}
							}
						}
					}
				}
				queueSortCom.returnJson();
			}
		}
		// if(form.site_option_group_id NEQ 0){
		// 	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
		// 	where site_option_group_id = #db.param(form.site_option_group_id)# and 
		// 	site_option_group_deleted = #db.param(0)# and
		// 	site_id = #db.param(request.zos.globals.id)# 
		// 	ORDER BY site_option_group_display_name";
		// 	q12=db.execute("q12");
		// 	if(q12.recordcount EQ 0){
		// 		application.zcore.functions.z301redirect("/z/admin/site-options/index");	
		// 	}
		// }
		// db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# site_option 
		// where site_option_group_id = #db.param(form.site_option_group_id)# and 
		// site_option_deleted = #db.param(0)# and
		// site_id =#db.param(request.zos.globals.id)# 
		// ORDER BY site_option_sort";
		// qS2=db.execute("qS2");
		arrMainOption=[];
		mainOptionStruct={};
		if(not structkeyexists(sog.optionGroupFieldLookup, form.site_option_group_id)){
			echo("This group has no options yet.");
			abort;
		}
		for(optionId in sog.optionGroupFieldLookup[form.site_option_group_id]){
			mainOptionStruct[optionId]={ sort: sog.optionLookup[optionId].site_option_sort, row: sog.optionLookup[optionId]};
		}
		arrKey=structsort(mainOptionStruct, "numeric", "asc", "sort");
		for(i=1;i<=arrayLen(arrKey);i++){
			arrayAppend(arrMainOption, mainOptionStruct[arrKey[i]].row);
		}  
		parentIndex=0;
		arrSearchTable=[];
		arrSortSQL=[];
		for(row in arrMainOption){
			if(row.site_option_admin_searchable EQ 1){
				arrayAppend(arrSearchTable, row);
			}
			added=false;
			ts2={};
			if(mainGroupStruct.site_option_group_parent_field NEQ "" and mainGroupStruct.site_option_group_parent_field EQ row.site_option_name){
				added=true;
				arrayappend(arrRow, row);
				arrayappend(arrLabel, row.site_option_display_name);
				arrayappend(arrVal, row.site_option_id);
				arrayappend(arrType, row.site_option_type_id);
				parentIndex=arraylen(arrVal);
				if(row.site_option_primary_field EQ 1){
					arrayAppend(arrDisplay, 1);
				}else{
					arrayAppend(arrDisplay, 0);
				}
			}else if(row.site_option_primary_field EQ 1){
				added=true;
				arrayAppend(arrDisplay, 1);
				arrayappend(arrRow, row);
				arrayappend(arrLabel, row.site_option_display_name);
				arrayappend(arrVal, row.site_option_id);
				arrayappend(arrType, row.site_option_type_id);
			}
			if(added){
				if(row.site_option_admin_sort_field NEQ 0){ 
					var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
					var sortDirection="asc";
					if(row.site_option_admin_sort_field EQ 2){
						sortDirection="desc";
					}
					tempSQL=currentCFC.getSortSQL(arraylen(arrVal), sortDirection);
					if(tempSQL NEQ ""){
						arrayAppend(arrSortSQL, tempSQL);
					}
				}
			}
			if(row.site_option_type_id EQ 0){
				fakeRow=row;
				fakePrimaryId=row.site_option_id;	
				fakePrimaryLabel=row.site_option_display_name;	
				fakePrimaryType=row.site_option_type_id;	
			}
		} 
		if(fakePrimaryId EQ 0 and arrayLen(arrMainOption) NEQ 0){
			for(row in arrMainOption){
				fakeRow=row;
				break;
			}
			fakePrimaryId=arrMainOption[1].site_option_id;
			fakePrimaryLabel=arrMainOption[1].site_option_display_name;
			fakePrimaryType=arrMainOption[1].site_option_type_id;
		}
		if(arraylen(arrVal) EQ 0){
			arrayAppend(arrDisplay, 1);
			arrayappend(arrRow, fakeRow);
			arrayappend(arrVal, fakePrimaryId);
			arrayappend(arrLabel, fakePrimaryLabel);
			arrayappend(arrType, fakePrimaryType);
		} 
		arrSearch=[];
		var dataStruct=[];
		for(i=1;i LTE arraylen(arrType);i++){
			if(not structkeyexists(arrRow[i], 'site_option_type_json')){
				continue;
			}
			var optionStruct=deserializeJson(arrRow[i].site_option_type_json);
			arrayAppend(arrOptionStruct, optionStruct);
			
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(arrType[i]);
			dataStruct[i]=currentCFC.onBeforeListView(arrRow[i], optionStruct, form);
		}
		listDescription="";
		if(not structkeyexists(arguments.struct, 'recurse')){
			if(methodBackup EQ "userManageGroup"){ 
				application.zcore.template.setTag('pagenav', '<p><a href="/z/user/home/index">User Home Page</a></p>');
			}
			theTitle="#htmleditformat(mainGroupStruct.site_option_group_display_name)#(s)";
			application.zcore.template.setTag("title",theTitle);
			if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup"){ 
				application.zcore.template.setTag("pagetitle",theTitle);  
			} 
			curParentId=mainGroupStruct.site_option_group_parent_id;
			curParentSetId=form.site_x_option_group_set_parent_id;
			if(not structkeyexists(arguments.struct, 'hideNavigation') or not arguments.struct.hideNavigation){
				application.zcore.siteOptionCom.getSetParentLinks(mainGroupStruct.site_option_group_id, curParentId, curParentSetId, false);
			}
			if(mainGroupStruct.site_option_group_list_description NEQ ""){
				listDescription=mainGroupStruct.site_option_group_list_description;
			}
		}


		arrSearchSQL=[];
		searchStruct={};
		searchFieldEnabledStruct={};
	
		tempGroupKey="#form.site_option_app_id#-#form.site_option_group_id#";
		if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
			if(structkeyexists(request.zsession, 'siteOptionGroupSearch') and structkeyexists(request.zsession.siteOptionGroupSearch, tempGroupKey)){
				if(structkeyexists(form, 'clearSearch')){
					structdelete(request.zsession.siteOptionGroupSearch, tempGroupKey);
				}else if(not structkeyexists(form, 'searchOn')){
					form.searchOn=1;
					structappend(form, request.zsession.siteOptionGroupSearch[tempGroupKey], false);
				}
			}
		}
		if(not structkeyexists(arguments.struct, 'recurse') and form.site_option_group_id NEQ 0 and arraylen(arrSearchTable)){ 
			arrayAppend(arrSearch, '<form action="#arguments.struct.listURL#" method="get">
			<input type="hidden" name="searchOn" value="1" />
			<input type="hidden" name="site_x_option_group_set_parent_id" value="#form.site_x_option_group_set_parent_id#" />
			<input type="hidden" name="site_option_group_id" value="#form.site_option_group_id#" />
			<input type="hidden" name="site_option_app_id" value="#form.site_option_app_id#" />
			<div class="z-float " style="border-bottom:1px solid ##CCC; padding-bottom:10px;">');
			for(n=1;n LTE arraylen(arrVal);n++){
				arrSearchSQL[n]="";
			}
			for(i=1;i LTE arraylen(arrSearchTable);i++){
				row=arrSearchTable[i];
				for(n=1;n LTE arraylen(arrVal);n++){
					if(row.site_option_id EQ arrVal[n]){
						curValIndex=n;
						break;
					}
				}
				
				form['newvalue'&row.site_option_id]=application.zcore.functions.zso(form, 'newvalue'&row.site_option_id);
				 
				var optionStruct=arrOptionStruct[curValIndex];
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
				if(currentCFC.isSearchable()){
					arrayAppend(arrSearch, '<div class="z-float-left z-pr-10 z-pb-10">'&row.site_option_display_name&'<br />');
					var tempValue=currentCFC.getSearchValue(row, optionStruct, 'newvalue', form, searchStruct);
					if(structkeyexists(form, 'searchOn')){
						arrSearchSQL[curValIndex]=currentCFC.getSearchSQL(row, optionStruct, 'newvalue', form, 's#curValIndex#.site_x_option_group_value',  's#curValIndex#.site_x_option_group_date_value', tempValue); 
						if(arrSearchSQL[curValIndex] NEQ ""){
							searchFieldEnabledStruct[curValIndex]=true;
						}
						arrSearchSQL[curValIndex]=replace(arrSearchSQL[curValIndex], "?", "", "all");
						searchStruct['newvalue'&row.site_option_id]=tempValue;
					}
					arrayAppend(arrSearch, currentCFC.getSearchFormField(row, optionStruct, 'newvalue', form, tempValue, '')); 
					arrayAppend(arrSearch, '</div>');
				}
			} 
			if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
				if(structkeyexists(form, 'searchOn')){
					if(not structkeyexists(request.zsession, 'siteOptionGroupSearch')){
						request.zsession.siteOptionGroupSearch={};
					}
					request.zsession.siteOptionGroupSearch[tempGroupKey]=searchStruct;
				}
			}
			arrNewSearchSQL=[];
			for(n=1;n LTE arraylen(arrSearchSQL);n++){
				if(arrSearchSQL[n] NEQ ""){
					arrayappend(arrNewSearchSQL, arrSearchSQL[n]);
				}
			}
			arrSearchSQL=arrNewSearchSQL; 
			
			if(mainGroupStruct.site_option_group_enable_approval EQ 1){
				if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
					if(structkeyexists(form, 'searchOn')){
						searchStruct['site_x_option_group_set_approved']=application.zcore.functions.zso(form,'site_x_option_group_set_approved');
						if(not structkeyexists(request.zsession, 'siteOptionGroupSearch')){
							request.zsession.siteOptionGroupSearch={};
						}
						request.zsession.siteOptionGroupSearch[tempGroupKey]=searchStruct;
					}
				}
				arrayAppend(arrSearch, '<div class="z-float-left z-pr-10 z-pb-10">Approval Status:<br />');
				ts = StructNew();
				ts.name = "site_x_option_group_set_approved";
				ts.listLabels= "Approved|Pending|Deactivated By User|Rejected";
				ts.listValues= "1|0|2|3";
				ts.listLabelsdelimiter="|";
				ts.listValuesdelimiter="|";
				ts.output=false;
				ts.struct=form;
				arrayAppend(arrSearch, application.zcore.functions.zInputSelectBox(ts));
				arrayAppend(arrSearch, '</div>');
			}
			arrayAppend(arrSearch, '<div class="z-float-left">&nbsp;<br><input type="submit" name="searchSubmit1" value="Search" class="z-manager-search-button" /> 
				 <input type="button" onclick="window.location.href=''#application.zcore.functions.zURLAppend(arguments.struct.listURL, 'site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&amp;clearSearch=1')#''; " value="Clear Search" class="z-manager-search-button" >
			</div></div></form>');

			if ( mainGroupStruct.site_option_group_enable_sorting EQ 1 ) {
				if ( structKeyExists( form, 'searchOn' ) and form.searchOn) {
					// echo( 'Sorting disabled when searching.' );
					arrayAppend(arrSearch, '<div style="width:100%; float:left; padding: 10px; border-bottom: 1px solid ##CCCCCC;"><strong>Sorting is disabled when searching.</strong></div>' );
				}
			}
		}
		status=application.zcore.functions.zso(searchStruct, 'site_x_option_group_set_approved');


		if(mainGroupStruct.site_option_group_limit GT 0){
			db.sql="SELECT count(site_option_group.site_option_group_id) count
			FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set)  "; 
			db.sql&="WHERE  
			site_x_option_group_set_deleted = #db.param(0)# and 
			site_option_group_deleted = #db.param(0)# and 
			site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
			site_x_option_group_set_master_set_id = #db.param(0)# and 
			site_option_group.site_id=site_x_option_group_set.site_id and 
			site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id "; 
			if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
				db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
			}
			if(form.site_x_option_group_set_parent_id NEQ 0){
				db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
			} 
			if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
				db.sql&=" and site_x_option_group_set.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
			}
			if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
			}
			db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
			site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
			site_option_group.site_option_group_type=#db.param('1')# ";
			qCountAllLimit=db.execute("qCountAllLimit");
		}

		if(methodBackup EQ "userManageGroup"){
			db.sql="SELECT count(site_option_group.site_option_group_id) count
			FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set)  ";
			for(i=1;i LTE arraylen(arrVal);i++){
				if(structkeyexists(searchFieldEnabledStruct, i)){
					db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
					s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
					s#i#.site_option_id = #db.param(arrVal[i])# and 
					s#i#.site_option_group_id = site_option_group.site_option_group_id and 
					s#i#.site_id = site_option_group.site_id and 
					s#i#.site_option_app_id = #db.param(form.site_option_app_id)# and 
					s#i#.site_x_option_group_deleted = #db.param(0)# ";
				}
			}
			db.sql&="WHERE  
			site_x_option_group_set_deleted = #db.param(0)# and 
			site_option_group_deleted = #db.param(0)# and 
			site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
			site_x_option_group_set_master_set_id = #db.param(0)# and 
			site_option_group.site_id=site_x_option_group_set.site_id and 
			site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
			if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
				db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
			}
			if(form.site_x_option_group_set_parent_id NEQ 0){
				db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
			}
			if(status NEQ ""){
				db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
			}
			if(arraylen(arrSearchSQL)){
				db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
			}
			if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
				db.sql&=" and site_x_option_group_set.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
			}
			if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
			}
			db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
			site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
			site_option_group.site_option_group_type=#db.param('1')# ";
			qCount=db.execute("qCount");

			if(mainGroupStruct.site_option_group_user_child_limit NEQ 0){
				db.sql="SELECT count(site_option_group.site_option_group_id) count
				FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
				#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set)  ";
				for(i=1;i LTE arraylen(arrVal);i++){
					if(structkeyexists(searchFieldEnabledStruct, i)){
						db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
						s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
						s#i#.site_option_id = #db.param(arrVal[i])# and 
						s#i#.site_option_group_id = site_option_group.site_option_group_id and 
						s#i#.site_id = site_option_group.site_id and 
						s#i#.site_option_app_id = #db.param(form.site_option_app_id)# and 
						s#i#.site_x_option_group_deleted = #db.param(0)# ";
					}
				}
				db.sql&="WHERE  
				site_x_option_group_set_deleted = #db.param(0)# and 
				site_option_group_deleted = #db.param(0)# and 
				site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
				site_x_option_group_set_master_set_id = #db.param(0)# and 
				site_option_group.site_id=site_x_option_group_set.site_id and 
				site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
				if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
					db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
				}
				if(form.site_x_option_group_set_parent_id NEQ 0){
					db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
				} 
				if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
					db.sql&=" and site_x_option_group_set.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
				}
				if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
					db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
				}
				db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
				site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
				site_option_group.site_option_group_type=#db.param('1')# ";
				qCountLimit=db.execute("qCountLimit"); 
			}
		}else{ 
			if(arraylen(arrSearchSQL) GT 0 or mainGroupStruct.site_option_group_enable_cache EQ 0 or mainGroupStruct.site_option_group_admin_paging_limit NEQ 0){
				db.sql="SELECT count(site_option_group.site_option_group_id) count
				FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
				#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set)  ";
				for(i=1;i LTE arraylen(arrVal);i++){
					if(structkeyexists(searchFieldEnabledStruct, i)){
						db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
						s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
						s#i#.site_option_id = #db.param(arrVal[i])# and 
						s#i#.site_option_group_id = site_option_group.site_option_group_id and 
						s#i#.site_id = site_option_group.site_id and 
						s#i#.site_option_app_id = #db.param(form.site_option_app_id)# and 
						s#i#.site_x_option_group_deleted = #db.param(0)# ";
					}
				}
				db.sql&="WHERE  
				site_x_option_group_set_deleted = #db.param(0)# and 
				site_option_group_deleted = #db.param(0)# and 
				site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
				site_x_option_group_set_master_set_id = #db.param(0)# and 
				site_option_group.site_id=site_x_option_group_set.site_id and 
				site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id "; 
				if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
					db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
				}
				if(form.site_x_option_group_set_parent_id NEQ 0){
					db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
				}
				if(status NEQ ""){
					db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
				}
				if(arraylen(arrSearchSQL)){
					db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
				}
				if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
					db.sql&=" and site_x_option_group_set.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
				}
				if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
					db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
				}
				db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
				site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
				site_option_group.site_option_group_type=#db.param('1')# ";
				qCount=db.execute("qCount");  
			}else{
				// get the things
				qCount={recordcount:1, count: 0 }; 
			}
		} 


		db.sql="SELECT site_option_group.*,  site_x_option_group_set.*";
		for(i=1;i LTE arraylen(arrVal);i++){
			db.sql&=" , s#i#.site_x_option_group_value sVal#i# ";
		}
		db.sql&=" FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set) ";
		for(i=1;i LTE arraylen(arrVal);i++){
			db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
			s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
			s#i#.site_option_id = #db.param(arrVal[i])# and 
			s#i#.site_option_group_id = site_option_group.site_option_group_id and 
			s#i#.site_id = site_option_group.site_id and 
			s#i#.site_option_app_id = #db.param(form.site_option_app_id)# and 
			s#i#.site_x_option_group_deleted = #db.param(0)# ";
		}
		db.sql&="
		WHERE  
		site_option_group_deleted = #db.param(0)# and
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
		site_option_group.site_id=site_x_option_group_set.site_id and 
		site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
		if(arraylen(arrSearchSQL)){
			db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
		}
		if(status NEQ ""){
			db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
		}
		if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
			db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
		}
		if(form.site_x_option_group_set_parent_id NEQ 0){
			db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
		}
		if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
			db.sql&=" and site_x_option_group_set.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
		}
		db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
		site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option_group.site_option_group_type=#db.param('1')# ";

		if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
			db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
		}
		//GROUP BY site_x_option_group_set.site_x_option_group_set_id
		if(arraylen(arrSortSQL)){
			db.sql&= "ORDER BY "&arraytolist(arrSortSQL, ", ");
		}else{
			db.sql&=" ORDER BY site_x_option_group_set_sort asc ";
		}
		if(mainGroupStruct.site_option_group_admin_paging_limit NEQ 0){
			db.sql&=" LIMIT #db.param((form.zIndex-1)*mainGroupStruct.site_option_group_admin_paging_limit)#, #db.param(mainGroupStruct.site_option_group_admin_paging_limit)# ";
		}
		qS=db.execute("qS"); 


		if(mainGroupStruct.site_option_group_limit GT 0){
			db.sql="SELECT site_option_group.*,  site_x_option_group_set.*";
			for(i=1;i LTE arraylen(arrVal);i++){
				db.sql&=" , s#i#.site_x_option_group_value sVal#i# ";
			}
			db.sql&=" FROM (#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set) ";
			for(i=1;i LTE arraylen(arrVal);i++){
				db.sql&="LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s#i# on 
				s#i#.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
				s#i#.site_option_id = #db.param(arrVal[i])# and 
				s#i#.site_option_group_id = site_option_group.site_option_group_id and 
				s#i#.site_id = site_option_group.site_id and 
				s#i#.site_option_app_id = #db.param(form.site_option_app_id)# and 
				s#i#.site_x_option_group_deleted = #db.param(0)# ";
			}
			db.sql&="
			WHERE  
			site_option_group_deleted = #db.param(0)# and
			site_x_option_group_set_master_set_id = #db.param(0)# and 
			site_x_option_group_set_deleted = #db.param(0)# and 
			site_x_option_group_set.site_option_app_id = #db.param(form.site_option_app_id)# and 
			site_option_group.site_id=site_x_option_group_set.site_id and 
			site_option_group.site_option_group_id=site_x_option_group_set.site_option_group_id ";
			if(arraylen(arrSearchSQL)){
				db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
			}
			if(status NEQ ""){
				db.sql&=" and site_x_option_group_set_approved = #db.param(status)# ";
			}
			if(methodBackup EQ "userManageGroup" and request.isUserPrimaryGroup){
				db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
			}
			if(form.site_x_option_group_set_parent_id NEQ 0){
				db.sql&=" and site_x_option_group_set.site_x_option_group_set_parent_id = #db.param(form.site_x_option_group_set_parent_id)#";
			} 
			if(mainGroupStruct.site_option_group_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and site_x_option_group_set_archived =#db.param(0)# ";
			}
			db.sql&=" and site_option_group.site_id =#db.param(request.zos.globals.id)# and 
			site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
			site_option_group.site_option_group_type=#db.param('1')# ";
			//GROUP BY site_x_option_group_set.site_x_option_group_set_id
			if(arraylen(arrSortSQL)){
				db.sql&= "ORDER BY "&arraytolist(arrSortSQL, ", ");
			}else{
				db.sql&=" ORDER BY site_x_option_group_set_sort asc ";
			}
			if(mainGroupStruct.site_option_group_admin_paging_limit NEQ 0){
				db.sql&=" LIMIT #db.param((form.zIndex-1)*mainGroupStruct.site_option_group_admin_paging_limit)#, #db.param(mainGroupStruct.site_option_group_admin_paging_limit)# ";
			}
			qSCount=db.execute("qSCount");
		}
		//writedump(qS);abort;
		// sort and indent 
		if(parentIndex NEQ 0){
			rs=application.zcore.siteOptionCom.prepareRecursiveData(arrVal[parentIndex], form.site_option_group_id, arrOptionStruct[parentIndex], false);
		}
		
		rowStruct={};
		rowIndexFix=1;
		if(structkeyexists(arguments.struct, 'recurse') and qS.recordcount NEQ 0){
			echo('<h3>Sub-group: #mainGroupStruct.site_option_group_display_name#</h3>');
		}
		addEnabled=true;
		sortLink='';
		if(not structkeyexists(arguments.struct, 'recurse')){
			if(mainGroupStruct.site_option_group_enable_sorting EQ 1){
				if(not sortEnabled and subgroupRecurseEnabled){
					sortLink=('<a href="/z/admin/site-options/#methodBackup#?site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&amp;enableSorting=1" class="z-manager-search-button">Enable Sorting</a>');
					
				}else if(form.enableSorting EQ 1){
					sortLink=('<a href="/z/admin/site-options/#methodBackup#?site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#" class="z-manager-search-button">Disable Sorting</a>');
				}
			}
		} 
		if(mainGroupStruct.site_option_group_limit EQ 0 or qCountAllLimit.count LT mainGroupStruct.site_option_group_limit){
			if(methodBackup EQ "userManageGroup"){ 
				if(mainGroupStruct.site_option_group_user_child_limit NEQ 0 and qCountLimit.count GTE mainGroupStruct.site_option_group_user_child_limit){
					addEnabled=false;
				}
			}
			if(structkeyexists(arguments.struct, 'recurse') EQ false){ 
				echo('<div class="z-float z-mb-10"><h2 style="display:inline-block; ">#mainGroupStruct.site_option_group_display_name#(s)</h2> &nbsp;&nbsp; ');
				if(addEnabled){
					writeoutput('<a href="#application.zcore.functions.zURLAppend(arguments.struct.addURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#&modalpopforced=1" onclick="zTableRecordAdd(this, ''sortRowTable''); return false; " class="z-manager-quick-add-link z-manager-search-button ">Add</a>');
					if(application.zcore.functions.zso(form, 'zManagerAddOnLoad', true, 0) EQ 1){
						application.zcore.skin.addDeferredScript(' $(".z-manager-quick-add-link").trigger("click"); ');
					} 
				} 
				if(methodBackup EQ "manageGroup" and mainGroupStruct.site_option_group_disable_export EQ 0){
					echo(' <a href="/z/admin/site-option-group/export?site_option_group_id=#mainGroupStruct.site_option_group_id#" class="z-button" target="_blank">Export CSV</a>');
				}

				if(mainGroupStruct.site_option_group_enable_archiving EQ 1){
					if(showArchived){ 
						echo(' <a href="/z/admin/site-options/#methodBackup#?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&showArchived=0" class="z-button">Hide Archived</a>'); 
					}else{
						echo(' <a href="/z/admin/site-options/#methodBackup#?site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&showArchived=1" class="z-button">Show Archived</a>');
					}
				}
				echo(' #sortLink#</div>'); 
			}
		}else{

			if(structkeyexists(arguments.struct, 'recurse') EQ false){
				echo('<div class="z-float z-mb-10"><h2 style="display:inline-block; ">#mainGroupStruct.site_option_group_display_name#(s)</h2> &nbsp;&nbsp; #sortLink#</div>');
			}

		} 
		echo(listDescription);
		if(not structkeyexists(arguments.struct, 'recurse') and form.site_option_group_id NEQ 0 and arraylen(arrSearchTable)){ 
			if(mainGroupStruct.site_option_group_limit EQ 0 or (qCountAllLimit.recordcount NEQ 0 and qCountAllLimit.count > 0)){
				echo(arraytolist(arrSearch, ""));
			}
		}
		if(qS.recordcount){
			columnCount=0;
			if(sortEnabled){
				echo('<table id="sortRowTable" class="table-list" style="width:100%;">');
			}else{
				echo('<table class="table-list" style="width:100%;" >');
			}
			echo('<thead>
			<tr>');
			echo('<th class="z-hide-at-767">ID</th>');
			columnCount++;
			for(i=1;i LTE arraylen(arrVal);i++){
				if(arrDisplay[i]){
					writeoutput('<th>#arrLabel[i]#</th>');
					columnCount++;
				}
			}
			if(mainGroupStruct.site_option_group_enable_approval EQ 1){
				echo('<th>Approval Status</th>');
				columnCount++;
			}
			/*if(sortEnabled){
				echo('<th>Sort</th>');
				columnCount++;
			}*/
			writeoutput('
			<th>Last Updated</th>
			<th style="white-space:nowrap;">Admin</th>
			</tr>
			</thead><tbody>');
			columnCount+=2;
			var row=0;
			var currentRowIndex=0;
			for(row in qS){
				currentRowIndex++;
				// if(parentIndex){
				// 	curRowIndex=0;
				// 	curIndent=0;
				// 	curParentId=0;
				// 	// writedump(parentIndex);
				// 	// writedump(rs.arrLabel);
				// 	// writedump(rs.arrValue);abort;
				// 	for(n=1;n LTE arraylen(rs.arrValue);n++){
				// 		if(row.site_x_option_group_set_id EQ rs.arrValue[n]){
				// 			curRowIndex=n;
				// 			curParentId=rs.arrParent[n];
				// 			curIndent=len(rs.arrLabel[n])-len(replace(rs.arrLabel[n], "_", "", "all"));
				// 			break;
				// 		}
				// 	}
				// 	if(curRowIndex EQ 0){
				// 		curRowIndex="1000000"&rowIndexFix;
				// 		rowIndexFix++;
				// 	}
				// }else{
				// 	curRowIndex=qS.currentrow;
				// 	curParentId=0;
				// }
				curRowIndex=qS.currentrow;
				firstDisplayed=true; 
				// image is not being added to list view
				savecontent variable="rowOutput"{ 
					echo('<td class="z-hide-at-767">'&row.site_x_option_group_set_id&'</td>');
					for(var i=1;i LTE arraylen(arrVal);i++){
						if(arrDisplay[i]){
							writeoutput('<td>');
							if(firstDisplayed){
								firstDisplayed=false;
								if(row.site_x_option_group_set_level GT 0){
									writeoutput(replace(ljustify(" ", row.site_x_option_group_set_level*4), " ", "&nbsp;", "all"));
								}
							}
							var currentCFC=application.zcore.siteOptionCom.getTypeCFC(arrType[i]);
							value=currentCFC.getListValue(dataStruct[i], arrOptionStruct[i], application.zcore.functions.zso(row, 'sVal'&i));
							if(arrType[i] EQ 1){
								if(value EQ ""){
									writeoutput(htmleditformat(arrRow[i].site_option_default_value));
								}else{
									writeoutput(htmleditformat(value));
								}
							}else{
								if(value EQ ""){
									writeoutput(arrRow[i].site_option_default_value);
								}else{
									writeoutput(value);
								}
							}
							writeoutput('</td>');
						}
					}
					if(mainGroupStruct.site_option_group_enable_approval EQ 1){
						echo('<td>'&application.zcore.siteOptionCom.getStatusName(row.site_x_option_group_set_approved)&'</td>');
					}
					/*if(sortEnabled){
						echo('<td>');
						if(row.site_id NEQ 0 or variables.allowGlobal){
							queueSortCom.getRowStruct(row.site_x_option_group_set_id);
							echo(queueSortCom.getAjaxHandleButton(row.site_x_option_group_set_id));
						}
						echo('</td>');
					}*/
					echo('<td>'&application.zcore.functions.zGetLastUpdatedDescription(row.site_x_option_group_set_updated_datetime)&'</td>');
					writeoutput('<td style="white-space:nowrap;white-space: nowrap;" class="z-manager-admin">'); 
					if(row.site_id NEQ 0 or variables.allowGlobal){
						if(sortEnabled){
							if(row.site_id NEQ 0 or variables.allowGlobal){
								echo('<div class="z-manager-button-container">');
								queueSortCom.getRowStruct(row.site_x_option_group_set_id);
								echo(queueSortCom.getAjaxHandleButton(row.site_x_option_group_set_id));
								echo('</div>');
							}
						}
 

						if(row.site_option_group_enable_unique_url EQ 1){
							var tempLink="";
							if(row.site_x_option_group_set_override_url NEQ ""){
								tempLink=row.site_x_option_group_set_override_url;
							}else{
								tempLink="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#request.zos.globals.optionGroupURLID#-#row.site_x_option_group_set_id#.html";
							}
							if(row.site_option_group_enable_approval EQ 1){

								if(row.site_x_option_group_set_approved NEQ 1){
									echo('<div class="z-manager-button-container">
										<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
									</div>');
								}else{
									echo('<div class="z-manager-button-container">
										<a title="Active"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
									</div>');
								}
							}

							if(row.site_x_option_group_set_approved EQ 1){
								writeoutput('<div class="z-manager-button-container"><a href="'&tempLink&'" target="_blank" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
							}else{
								writeoutput('<div class="z-manager-button-container"><a href="'&application.zcore.functions.zURLAppend(tempLink, "zpreview=1")&'" target="_blank" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
							}
						}
						echo('<div class="z-manager-button-container">');
						hasMultipleEditFeatures=false;
						savecontent variable="editHTML"{
							echo('
							<a href="##" class="z-manager-edit" id="z-manager-edit#row.site_x_option_group_set_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
							<div class="z-manager-edit-menu">');

							editLink=application.zcore.functions.zURLAppend(arguments.struct.editURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#&amp;modalpopforced=1");
							if(not sortEnabled){
								editLink&="&amp;disableSorting=1";
							}
							echo('<a href="#editLink#"  onclick="zTableRecordEdit(this);  return false;">Edit</a> ');
							if(arrayLen(arrChildGroup) NEQ 0){ 
								for(n in arrChildGroup){
									if(structkeyexists(subgroupStruct, n.site_option_group_id)){
										link=application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_group_id=#n.site_option_group_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_id#");
										echo('<a href="#link#">Manage #application.zcore.functions.zFirstLetterCaps(n.site_option_group_display_name)#(s)</a>'); // n.childCount
										hasMultipleEditFeatures=true;
									}
								} 
							}
							copyLink="";
							if(methodBackup NEQ "userManageGroup" and methodBackup NEQ "userGetRowHTML"){
								if(mainGroupStruct.site_option_group_limit EQ 0 or qSCount.recordcount LT mainGroupStruct.site_option_group_limit){
									if(mainGroupStruct.site_option_group_enable_versioning EQ 1 and row.site_x_option_group_set_parent_id EQ 0){
										copyLink=application.zcore.functions.zURLAppend(arguments.struct.copyURL, "site_x_option_group_set_id=#row.site_x_option_group_set_id#"); 
										echo('<a href="#application.zcore.functions.zURLAppend(arguments.struct.versionURL, "site_x_option_group_set_id=#row.site_x_option_group_set_id#")#">Versions</a>');
										hasMultipleEditFeatures=true;
									}else{
										copyLink=application.zcore.functions.zURLAppend(arguments.struct.addURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#");
										
									}
								}
							}
							
							if(row.site_option_group_enable_section EQ 1){
								echo('<a href="#application.zcore.functions.zURLAppend(arguments.struct.sectionURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#")#">Manage Section</a> ');
								hasMultipleEditFeatures=true;
							}
							if(row.site_option_group_enable_archiving EQ 1){
								if(row.site_x_option_group_set_archived EQ 1){
									echo('<a href="#application.zcore.functions.zURLAppend(arguments.struct.unarchiveURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#")#">Unarchive</a> ');
								}else{
									echo('<a href="#application.zcore.functions.zURLAppend(arguments.struct.archiveURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#")#" onclick="archiveGroupRecord(this); return false;">Archive</a> ');
								}
								hasMultipleEditFeatures=true;
							}
							echo('</div>');
						}
						if(hasMultipleEditFeatures){
							echo(editHTML);
						}else{
							echo('<a href="#editLink#" onclick="zTableRecordEdit(this);  return false;" class="z-manager-edit" id="z-manager-edit#row.site_x_option_group_set_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>');
						}

						echo('</div>');

						if(copyLink NEQ ""){
							echo('<div class="z-manager-button-container"><a href="#copyLink#" class="z-manager-copy" title="Copy"><i class="fa fa-clone" aria-hidden="true"></i></a></div>');
						}
						deleteLink=application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#row.site_option_group_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#&amp;returnJson=1&amp;confirm=1");
						//zShowModalStandard(this.href, 2000,2000, true, true);
						allowDelete=true;
						if(methodBackup EQ "userManageGroup" or methodBackup EQ "userGetRowHTML"){
							if(mainGroupStruct.site_option_group_allow_delete_usergrouplist NEQ ""){
								arrUserGroup=listToArray(mainGroupStruct.site_option_group_allow_delete_usergrouplist, ",");
								allowDelete=false;
								for(i=1;i LTE arraylen(arrUserGroup);i++){
									if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
										allowDelete=true;
										break;
									}
								}
							}
						}
						if(allowDelete){
							if(methodBackup NEQ "userManageGroup" and methodBackup NEQ "userGetRowHTML" and not application.zcore.functions.zIsForceDeleteEnabled(row.site_x_option_group_set_override_url) and mainGroupStruct.site_option_group_enable_locked_delete EQ 0){
								//echo('Delete disabled');
							}else{
								echo('<div class="z-manager-button-container"><a href="##"  onclick="zDeleteTableRecordRow(this, ''#deleteLink#'');  return false;" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a></div>');
							}
						}
						if(row.site_x_option_group_set_copy_id NEQ 0){
							echo('<div class="z-manager-button-container"><a title="This record is a copy of another record" style="padding-top:6px;display:inline-block;">Copy of ###row.site_x_option_group_set_copy_id#</a></div>');
						}
					}
					writeoutput('</td>'); 
				}

				sublistEnabled=false;
				backupSiteOptionAppId=form.site_option_app_id;
				backupSiteOptionGroupId=form.site_option_group_id;
				backupSiteXOptionGroupSetParentId=form.site_x_option_group_set_parent_id;
				savecontent variable="recurseOut"{
					if(subgroupRecurseEnabled and form.enableSorting EQ 0 and arrayLen(arrChildGroup) NEQ 0){
						for(var n in arrChildGroup){
							if(n.site_option_group_enable_list_recurse EQ "1"){
								form.site_option_group_app_id=row.site_option_app_id;
								form.site_x_option_group_set_parent_id=row.site_x_option_group_set_id;
								form.site_option_group_id=n.site_option_group_id;
								if(methodBackup EQ "userManageGroup"){
									userManageGroup({recurse:true});
								}else{
									manageGroup({recurse:true});
								}
								sublistEnabled=true;
							}
						}
					}
				}
				form.site_x_option_group_set_parent_id=backupSiteXOptionGroupSetParentId;
				form.site_option_group_id=backupSiteOptionGroupId;
				form.site_option_app_id=backupSiteOptionAppId;
				if(not sublistEnabled){
					recurseOut="";
				}
				rowStruct[curRowIndex]={
					index:curRowIndex,
					parentId:curParentId,
					row:rowOutput,
					trHTML:"",
					sublist:recurseOut
				};
				lastRowStruct=rowStruct[curRowIndex];

				if(sortEnabled){
					if(row.site_id NEQ 0 or variables.allowGlobal){
						rowStruct[curRowIndex].trHTML=queueSortCom.getRowHTML(row.site_x_option_group_set_id);
					}
				}
			}
			arrKey=structsort(rowStruct, "numeric", "asc", "index");
			arraysort(arrKey, "numeric", "asc");
			for(i=1;i LTE arraylen(arrKey);i++){
				writeoutput('<tr '&rowStruct[arrKey[i]].trHTML&'  data-ztable-sort-parent-id="#rowStruct[arrKey[i]].parentId#" ');
				if(i MOD 2 EQ 0){
					writeoutput('class="row2"');
				}else{
					writeoutput('class="row1"');
				}
				writeoutput('>'&rowStruct[arrKey[i]].row&'</tr>');
				if(rowStruct[arrKey[i]].sublist NEQ ""){
					echo('<tr><td colspan="#columnCount#" style="padding:20px;">'&rowStruct[arrKey[i]].sublist&'</td></tr>');
				}
			} 
			writeoutput('</tbody></table>');
			if(form.site_option_group_id NEQ 0){
				if(mainGroupStruct.site_option_group_admin_paging_limit NEQ 0){
					searchStruct = StructNew();
					searchStruct.count = qCount.count;
					searchStruct.index = form.zIndex;
					searchStruct.showString = "Results ";
					searchStruct.url = application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#");
					searchStruct.indexName = "zIndex";
					searchStruct.buttons = 5;
					searchStruct.perpage = mainGroupStruct.site_option_group_admin_paging_limit;
					if(searchStruct.count GT searchStruct.perpage){
						writeoutput( '<table class="table-list" style="width:100%; border-spacing:0px;" ><tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>');
					}
				} 
			}
		}

	}


	if((methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML")){ 
		if(arraylen(rowStruct)){
			return lastRowStruct.row;  
		}else{
			return '<td colspan="2">Data missing, please reload the page.</td>';
		}
		/*
		rowOut=lastRowStruct.row; 
		echo('done.<script type="text/javascript">
		window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
		window.parent.zCloseModal();
		</script>');
		abort;
		*/
	}else{
		hasListRecurseGroup=false; 
		for(var n in arrChildGroup){
			if(n.site_option_group_enable_list_recurse EQ "1"){
				hasListRecurseGroup=true;
				break;
			}
		}
		if(hasListRecurseGroup){
			echo(out);
		}else{
			echo('<div class="z-manager-list-view">'); 
			echo(out);
			echo('</div>');
		}
	}
	</cfscript> 
	<script type="text/javascript"> 
	function archiveGroupRecord(obj){ 
		var tr, table;
		var i=0;
		linkObj=obj;
		while(true){
			i++;
			if(obj.tagName.toLowerCase() == 'tr'){
				tr=obj;
			}else if(obj.tagName.toLowerCase() == 'table'){
				table=obj;
				break;
			}
			obj=obj.parentNode;
			if(i > 50){
				alert('infinite loop. invalid table html structure');
				return false;
			}
		}
		var cellCount=zCalculateTableCells(table);

		var t={
			id:"ajaxGroupArchive",
			method:"post",
			postObj:{},
			ignoreOldRequests:false,
			callback:function(r){
				r=JSON.parse(r);
				if(r.success){ 
					$(tr).html('<td class="zDeletedRow" colspan="'+cellCount+'">Row Archived</td>');
				}
			},
			errorCallback:function(){
				alert("Archived failed, please try again later.");
			},
			url:linkObj.href
		};  
		zAjax(t);
	}
	</script>


</cffunction>

<cffunction name="userAddGroup" localmode="modern" access="remote"> 
	<cfscript> 
	validateUserGroupAccess();
	editGroup();
	</cfscript>
</cffunction>

<cffunction name="userEditGroup" localmode="modern" access="remote"> 
	<cfscript> 
	validateUserGroupAccess();
	editGroup();
	</cfscript>
</cffunction>

<cffunction name="publicEditGroup" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicEditGroup";
	this.editGroup(arguments.struct);
	</cfscript>
</cffunction>
<cffunction name="publicAddGroup" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicAddGroup";
	this.editGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="addGroup" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editGroup();
	</cfscript>
</cffunction>

<cffunction name="editGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var qS=0;
	var theTitle=0;
	var htmlEditor=0;
	var selectStruct=0;
	var ts=0;

	defaultStruct=getDefaultStruct();
	if(not structkeyexists(arguments.struct, 'action')){
		arguments.struct.action='/z/misc/display-site-option-group/insert';	
	}
	if(application.zcore.functions.zso(form, 'site_option_group_id') EQ ""){
		if(application.zcore.user.checkGroupAccess("member")){
			application.zcore.functions.z301redirect("/z/admin/site-options/index");
		}else{
			application.zcore.functions.z301redirect("/");
		}
	}
	if(structkeyexists(form, 'returnURL') and form.returnURL NEQ ""){
		arguments.struct.returnURL=application.zcore.functions.zso(form, 'returnURL');
	}
	request.zsession.siteOptionGroupReturnURL=application.zcore.functions.zso(form, 'returnURL');
	if(not structkeyexists(arguments.struct, 'returnURL')){
		arguments.struct.returnURL='/z/misc/display-site-option-group/add?site_option_group_id=#form.site_option_group_id#';	
	}
	variables.init();
	methodBackup=form.method;
	application.zcore.functions.zstatusHandler(request.zsid, true, false, form); 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id',true);
	 
 
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow();
	}
	form.set9=application.zcore.functions.zGetHumanFieldIndex(); 

	form.jumpto=application.zcore.functions.zso(form, 'jumpto');
	db.sql="SELECT * FROM (#db.table("site_option", request.zos.zcoreDatasource)# site_option, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group) 
	LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group ON 
	site_x_option_group_deleted = #db.param(0)# and
	site_option.site_option_group_id = site_x_option_group.site_option_group_id and 
	site_option.site_option_id = site_x_option_group.site_option_id and 
	site_x_option_group.site_id = site_option_group.site_id and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group.site_x_option_group_set_id<>#db.param(0)#
	WHERE 
	site_option_deleted = #db.param(0)# and 
	site_option_group_deleted = #db.param(0)# and
	site_option.site_id = site_option_group.site_id and 
	site_option.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group.site_option_group_id = #db.param(form.site_option_group_id)# and 
	site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group.site_option_group_type=#db.param('1')# ";
	if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup" or 
		methodBackup EQ "userEditGroup" or methodBackup EQ "userAddGroup"){
		db.sql&=" and site_option_allow_public=#db.param(1)#";
	}
	db.sql&=" ORDER BY site_option.site_option_sort asc, site_option.site_option_name ASC";
	qS=db.execute("qS", "", 10000, "query", false); 
	if(qS.recordcount EQ 0){
		application.zcore.functions.z404("No site_options have been set to allow public form data entry.");	
	}

	if(methodBackup EQ "userAddGroup" or methodBackup EQ "userEditGroup"){ 
		arrUserGroup=listToArray(qS.site_option_group_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserGroup);i++){
			if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
		}
	}

	curParentId=qS.site_option_group_parent_id;
	curParentSetId=form.site_x_option_group_set_parent_id;
	/*
	arrParent=arraynew(1);
	if(not structkeyexists(arguments.struct, 'hideNavigation') or not arguments.struct.hideNavigation){
		if(curParentSetId NEQ 0){
			loop from="1" to="25" index="i"{
				db.sql="select s1.*, s2.site_x_option_group_set_title, s2.site_x_option_group_set_id d2, s2.site_x_option_group_set_parent_id d3 
				from #db.table("site_option_group", request.zos.zcoreDatasource)# s1, 
				#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s2
				where s1.site_id = s2.site_id and 
				s1.site_id = #db.param(request.zos.globals.id)# and 
				s1.site_option_group_id=s2.site_option_group_id and 
				s2.site_x_option_group_set_id=#db.param(curParentSetId)# and 
				s1.site_option_group_id = #db.param(curParentId)# and 
				s1.site_option_group_deleted = #db.param(0)# and 
				s2.site_x_option_group_set_deleted = #db.param(0)#
				LIMIT #db.param(0)#,#db.param(1)#";
				q12=db.execute("q12");
				loop query="q12"{
					arrayappend(arrParent, '<a href="#application.zcore.functions.zURLAppend("/z/admin/site-options/#methodBackup#", "site_option_group_id=#q12.site_option_group_id#&amp;site_x_option_group_set_parent_id=#q12.d3#")#">#application.zcore.functions.zFirstLetterCaps(q12.site_option_group_display_name)#</a> / #q12.site_x_option_group_set_title# / ');
					curParentId=q12.site_option_group_parent_id;
					curParentSetId=q12.d3;
				}
				if(q12.recordcount EQ 0 or curParentSetId EQ 0){
					break;
				}
			}
		}
		if(arraylen(arrParent)){
			writeoutput('<p>');
			for(i = arrayLen(arrParent);i GTE 1;i--){
				writeOutput(arrParent[i]&' ');
			}
			writeoutput(" </p>");
		}
	}*/
	db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoredatasource)# 
	WHERE
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
	site_id = #db.param(request.zos.globals.id)#  ";
	
	qSet=db.execute("qSet");
	if(methodBackup EQ "editGroup" or methodBackup EQ "userEditGroup"){
		if(qSet.recordcount EQ 0){
			application.zcore.functions.z404("This site option group no longer exists.");	
		}else{
			application.zcore.functions.zQueryToStruct(qSet, form);
			application.zcore.functions.zstatusHandler(request.zsid, true, true, form); 
		}
	} 
	
	if(qS.site_option_group_limit NEQ 0){
		if(methodBackup EQ "addGroup"){ 
			db.sql="select site_id from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_deleted=#db.param(0)# and 
			site_x_option_group_set_parent_id=#db.param(form.site_x_option_group_set_parent_id)# and 
			site_option_group_id=#db.param(form.site_option_group_id)# ";
			qCountCheck=db.execute("qCountCheck");
			if(qS.site_option_group_limit NEQ 0 and qCountCheck.recordcount GTE qS.site_option_group_limit){
				application.zcore.status.setStatus(request.zsid, "You can't add another record of this type because you've reached the limit.", form, true);
				application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#");
			}
		}
	}
	if(methodBackup EQ "userAddGroup" or methodBackup EQ "userEditGroup"){
		currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	}
	// check limit for user if this
	if(qS.site_option_group_user_child_limit NEQ 0){
		if(methodBackup EQ "userAddGroup"){
			db.sql="select site_id from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			site_x_option_group_set_deleted=#db.param(0)# and 
			site_x_option_group_set_parent_id=#db.param(form.site_x_option_group_set_parent_id)# and 
			site_option_group_id=#db.param(form.site_option_group_id)# and 
			site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
			qCountCheck=db.execute("qCountCheck");
			if(qS.site_option_group_user_child_limit NEQ 0 and qCountCheck.recordcount GTE qS.site_option_group_user_child_limit){
				application.zcore.status.setStatus(request.zsid, "You can't add another record of this type because you've reached the limit.", form, true);
				application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&site_option_app_id=#form.site_option_app_id#&site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#");
			}
		}
	}

	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# 
	WHERE site_option_group_id=#db.param(form.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck", "", 10000, "query", false); 
	if(qCheck.recordcount EQ 0){
		application.zcore.functions.z404("This group doesn't allow public data entry.");	
	}
	if(qCheck.site_option_group_form_description NEQ ""){
		writeoutput(qCheck.site_option_group_form_description);
	}
	for(row in qCheck){
		mainGroupStruct=row;
	}
	if(methodBackup EQ "publicAddGroup" or methodBackup EQ "addGroup" or methodBackup EQ "userAddGroup"){
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}
	if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup"){
		// 404 if group doesn't allow public entry
		if(qCheck.site_option_group_allow_public NEQ 1){
			arrUserGroup=listToArray(qCheck.site_option_group_user_group_id_list, ",");
			hasAccess=false;
			for(i=1;i LTE arraylen(arrUserGroup);i++){
				if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
					hasAccess=true;
					break;
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
			}
		}
		
		if(qCheck.site_option_group_public_form_title NEQ ""){
			theTitle=qCheck.site_option_group_public_form_title;
		}else if(methodBackup EQ "publicEditGroup"){
			theTitle="Edit "&qCheck.site_option_group_display_name;
		}else{
			theTitle="Add "&qCheck.site_option_group_display_name;
		}
	}else if(methodBackup EQ "addGroup" or methodBackup EQ "userAddGroup"){
		theTitle="Add "&qCheck.site_option_group_display_name;
	}else{
		theTitle="Edit "&qCheck.site_option_group_display_name;
	}
	echo('<div class="z-manager-edit-head">');
		if(methodBackup NEQ "publicAddGroup" or request.cgi_script_name EQ "/z/misc/display-site-option-group/add"){
			if(application.zcore.template.getTagContent("title") EQ ""){
				application.zcore.template.setTag("title",theTitle);
			}
		}
		if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup"){
			if(application.zcore.template.getTagContent("pagetitle") EQ ""){
				application.zcore.template.setTag("pagetitle",theTitle);
			}
		}else{
			if(application.zcore.template.getTagContent("pagetitle") EQ ""){
				echo('<h2 style="font-weight:normal; color:##369;">#theTitle#</h2>'); 
			}
		}
		arrEnd=arraynew(1);

		resortSetByParentField(mainGroupStruct);
		</cfscript>
		<script type="text/javascript">
		var zDisableBackButton=true;
		zArrDeferredFunctions.push(function(){
			zDisableBackButton=true;
		});
		</script>
		<cfif methodBackup EQ "publicEditGroup">
			<cfif qSet.site_x_option_group_set_approved EQ 2>
				<p><strong>Note: Updating this record will re-submit this listing for approval.</strong></p>
			</cfif>
		</cfif>
		<p>* Denotes required field.
		<cfif methodBackup EQ "addGroup" or methodBackup EQ "editGroup">
			 | <a href="/z/admin/site-option-group/help?site_option_group_id=#form.site_option_group_id#" target="_blank">View help in new window.</a>
		</cfif>
		</p>

		<cfif methodBackup EQ "editGroup"> 
			<cfscript> 
			db.sql="select * 
			from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
			 WHERE 
			site_option_group_deleted = #db.param(0)# and
			site_option_group.site_option_group_parent_id = #db.param(form.site_option_group_id)# and 
			site_option_group.site_id = #db.param(request.zos.globals.id)#";
			q1=db.execute("q1", "", 10000, "query", false); 
			sortEnabled=true;
			subgroupRecurseEnabled=false;
			subgroupStruct={}; 
			for(n in q1){
				subgroupStruct[n.site_option_group_id]=n;
			}
			 

			if(q1.recordcount NEQ 0){
				echo('<h3 style="font-weight:normal; color:##369;">Edit Sub-groups</h3>');
				echo('<p>This record has additional records attached to it. Click the following link(s) to view/edit them.</p>');
				echo('<ul>');
				for(var n in q1){
					if(structkeyexists(subgroupStruct, n.site_option_group_id)){
						echo('<li><a href="#application.zcore.functions.zURLAppend(defaultStruct.listURL, "site_option_group_id=#n.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_id#")#" target="_top">#subgroupStruct[n.site_option_group_id].site_option_group_display_name#</a></li>');
					}
				}
				echo('</ul>');

				echo('<h3>or Edit Current Record Below</h3>'); 
			}
			</cfscript>
		</cfif>

	</div>


	<div class="z-manager-edit-errors z-float"></div>
	<cfscript>
	echo('<form class="zFormCheckDirty" id="siteOptionGroupForm#qCheck.site_option_group_id#" action="');
	if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup"){
		echo(arguments.struct.action);
	}else{
		echo('/z/admin/site-options/');
		if(methodBackup EQ "userAddGroup"){
			echo('userInsertGroup');
		}else if(methodBackup EQ "userEditGroup"){
			echo('userUpdateGroup');
		}else if(methodBackup EQ "addGroup"){
			echo('insertGroup');
		}else{
			echo('updateGroup');
		}
		echo('?site_option_app_id=#form.site_option_app_id#');
	}
	echo('" method="post" enctype="multipart/form-data" ');
	if(qCheck.site_option_group_public_thankyou_url NEQ ""){
		echo(' data-thank-you-url="'&htmleditformat(qCheck.site_option_group_public_thankyou_url)&'" ');
	}
	if(methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup"){
		echo('onsubmit="zSet9(''zset9_#form.set9#''); ');
		if(methodBackup EQ "publicAddGroup" and qCheck.site_option_group_ajax_enabled EQ 1){
			echo('zSiteOptionGroupPostForm(''siteOptionGroupForm#qCheck.site_option_group_id#''); return false;');
		}
		echo('"');
	}else if(methodBackup EQ "addGroup" or methodBackup EQ "userAddGroup" or methodBackup EQ "editGroup" or methodBackup EQ "userEditGroup"){
		echo(' onsubmit=" return zSubmitManagerEditForm(this);  " ');
	}
	echo('>');
	</cfscript>
		<cfif application.zcore.functions.zso(form, 'zRefererURL') NEQ "">
			<input type="hidden" name="zRefererURL" id="zRefererURL" value="#htmleditformat(form.zRefererURL)#" />
		</cfif>
		<cfif methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			#application.zcore.functions.zFakeFormFields()#
		</cfif>
		<input type="hidden" name="disableSorting" value="#application.zcore.functions.zso(form, 'disableSorting', true, 0)#" />
		<input type="hidden" name="site_option_group_id" value="#htmleditformat(form.site_option_group_id)#" />
		<input type="hidden" name="site_x_option_group_set_id" value="#htmleditformat(form.site_x_option_group_set_id)#" />
		<input type="hidden" name="site_x_option_group_set_parent_id" value="#htmleditformat(form.site_x_option_group_set_parent_id)#" />
		<table style="border-spacing:0px;" class="table-list">

			<cfscript>
			cancelLink="#defaultStruct.listURL#?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#";
			if(methodBackup EQ "editGroup" and qSet.site_x_option_group_set_master_set_id NEQ 0){
				cancelLink="/z/admin/site-option-group-deep-copy/versionList?site_x_option_group_set_id=#qSet.site_x_option_group_set_master_set_id#";
			}
			</cfscript>
			<cfif methodBackup EQ "addGroup" or methodBackup EQ "editGroup" or 
			methodBackup EQ "userEditGroup" or methodBackup EQ "userAddGroup">
				<tr><td>&nbsp;</td><td>
					<div class="tabWaitButton zSiteOptionGroupWaitDiv" style="float:left; padding:5px; display:none; ">Please wait...</div>
					<button type="submit" name="submitForm" class="z-manager-search-button tabSaveButton zSiteOptionGroupSubmitButton">Save</button>
						&nbsp;
						<cfif form.modalpopforced EQ 1>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
						<cfelse>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
					</td></tr>
			</cfif>
	
			<cfscript>
			var row=0;
			var currentRowIndex=0;
			var optionStruct={};
			var dataStruct={};
			var labelStruct={};
			posted=false;
			for(row in qS){
				currentRowIndex++;
				if(form.jumpto EQ "soid_#application.zcore.functions.zurlencode(row.site_option_name,"_")#"){
					jumptoanchor="soid_#row.site_option_id#";
				}
				if(not structkeyexists(form, "newvalue"&row.site_option_id)){
					if(structkeyexists(form, row.site_option_name)){
						posted=true;
						form["newvalue"&row.site_option_id]=form[row.site_option_name];
					}else{
						if(row.site_x_option_group_value NEQ ""){
							form["newvalue"&row.site_option_id]=row.site_x_option_group_value;
						}else{
							form["newvalue"&row.site_option_id]=row.site_option_default_value;
						}
					}
				}else{
					posted=true;
				}
				form[row.site_option_name]=form["newvalue"&row.site_option_id];
				if(row.site_x_option_group_id EQ ""){
					if(not structkeyexists(form, "newvalue"&row.site_option_id)){
						form["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				optionStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
				dataStruct=currentCFC.onBeforeListView(row, optionStruct[row.site_option_id], form);
				if(methodBackup EQ "addGroup" and not posted and not currentCFC.isCopyable()){
					form["newvalue"&row.site_option_id]='';
				}
				value=currentCFC.getListValue(dataStruct, optionStruct[row.site_option_id], form["newvalue"&row.site_option_id]);
				if(value EQ ""){
					value=row.site_option_default_value;
				}
				labelStruct[row.site_option_name]=value;
			}
			var currentRowIndex=0;
			for(row in qS){
				currentRowIndex++;
			
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
				var rs=currentCFC.getFormField(row, optionStruct[row.site_option_id], 'newvalue', form);
				if(rs.hidden){
					arrayAppend(arrEnd, '<input type="hidden" name="site_option_id" value="'&row.site_option_id&'" />');
					arrayAppend(arrEnd, rs.value);
				}else{
					writeoutput('<tr class="siteOptionFormField#qS.site_option_id# ');
					if(currentRowIndex MOD 2 EQ 0){
						writeoutput('row1');
					}else{
						writeoutput('row2');
					}
					writeoutput('">');
					if(rs.label and row.site_option_hide_label EQ 0){
						if(row.site_option_label_on_top EQ 1){
							//<th style="vertical-align:top; ">&nbsp;</th>
							echo('
							<td colspan="2">');
							echo('<div style="padding-bottom:0px;float:left; width:100%;">'&application.zcore.functions.zOutputToolTip(row.site_option_display_name, row.site_option_tooltip)&'<a id="soid_#row.site_option_id#" style="display:block; float:left;"></a> ');

							if(row.site_option_required and row.site_option_hide_label EQ 0){
								writeoutput(' <span style="font-size:80%;">*</span> ');
							} 
							echo('</div>'); 

						}else{
							tdOutput="";
							if(row.site_option_small_width EQ 1){
								tdOutput=' width:1%; white-space:nowrap; ';
							}
							writeoutput('<th style="vertical-align:top;#tdOutput#"><div style="padding-bottom:0px;float:left;">'&application.zcore.functions.zOutputToolTip(row.site_option_display_name, row.site_option_tooltip)&'<a id="soid_#row.site_option_id#" style="display:block; float:left;"></a> ');

							if(row.site_option_required and row.site_option_hide_label EQ 0){
								writeoutput(' <span style="font-size:80%;">*</span> ');
							} 
							echo('</div></th>
							<td style="vertical-align:top; "><input type="hidden" name="site_option_id" value="#htmleditformat(row.site_option_id)#" />');
						}
					}else{
						if(row.site_option_type_id EQ 11){
							writeoutput('<td style="vertical-align:top; padding-top:15px; padding-bottom:0px;" colspan="2">');
						}else{
							writeoutput('<td style="vertical-align:top; padding-top:5px;" colspan="2">');
						}
						if(rs.label){
							writeoutput('<input type="hidden" name="site_option_id" value="#htmleditformat(row.site_option_id)#" />');
						}
					}
					if(row.site_option_readonly EQ 1 and labelStruct[row.site_option_name] NEQ ""){
						echo('<div class="zHideReadOnlyField" id="zHideReadOnlyField#currentRowIndex#">'&rs.value);
					}else{
						echo(rs.value);
					}
				} 
				requiredEnabled=true;
				if(application.zcore.functions.zso(optionStruct[row.site_option_id], 'selectmenu_multipleselection', true, 0) EQ 1 or application.zcore.functions.zso(optionStruct[row.site_option_id], 'checkbox_values') NEQ ""){
					requiredEnabled=false;
				} 

				if(requiredEnabled and row.site_option_required and row.site_option_hide_label EQ 1){
					writeoutput(' <span style="font-size:80%;">*</span> ');
				}  
				if(row.site_option_type_id EQ 3){
					if(row.site_x_option_group_original NEQ ""){
						echo('<p><a href="/zupload/site-options/#row.site_x_option_group_original#" target="_blank">View Original Image</a></p>');
					}
				}

				if(row.site_option_readonly EQ 1){// and labelStruct[row.site_option_name] NEQ ""){
					echo('</div>');
					echo('<div id="zReadOnlyButton#currentRowIndex#" class="zReadOnlyButton">#labelStruct[row.site_option_name]#');
					if(labelStruct[row.site_option_name] NEQ ""){
						echo('<hr />');
					}
					echo('<strong>Read only value</strong> | <a href="##" class="zEditReadOnly" data-readonlyid="zReadOnlyButton#currentRowIndex#" data-fieldid="zHideReadOnlyField#currentRowIndex#">Edit Anyway</a></div> ')
				}
				if(rs.label){
					writeoutput('</td>');	
					writeoutput('</tr>');
				}
			}

			if(methodBackup EQ 'addGroup'){ 
				if(not posted){
					form.site_x_option_group_set_override_url='';
					qSet={ recordcount: 0};
					form.site_x_option_group_set_image_library_id='';
				}
			}
			</cfscript>
			<cfset tempIndex=qS.recordcount+1>
			<cfif methodBackup NEQ "publicAddGroup" and methodBackup NEQ "publicEditGroup" and methodBackup NEQ "userAddGroup" and methodBackup NEQ "userEditGroup">
				<cfif qCheck.site_option_group_enable_approval EQ 1>
					<cfscript>
					if(methodBackup EQ 'addGroup'){
						form.site_x_option_group_set_approved=1;
					}else{
						form.site_x_option_group_set_approved=qSet.site_x_option_group_set_approved;
					}
					</cfscript>
					<tr class="siteOptionFormField#qS.site_option_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Approved?</div></th>
					<td style="vertical-align:top; ">
						<cfscript>
						ts = StructNew();
						ts.name = "site_x_option_group_set_approved";
						ts.labelList = "Approved|Pending|Deactivated By User|Rejected";
						ts.valueList = "1|0|2|3";
						ts.delimiter="|";
						ts.output=true;
						ts.struct=form;
						writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
						</cfscript>
					</td>
					</tr>
					<cfset tempIndex++>
				</cfif>

				<cfif qS.site_option_group_enable_meta EQ "1">
		 
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Title:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="site_x_option_group_set_metatitle" value="#htmleditformat(application.zcore.functions.zso(form, 'site_x_option_group_set_metatitle'))#" /> 
					</td>
					</tr>
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Keywords:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="site_x_option_group_set_metakey" value="#htmleditformat(application.zcore.functions.zso(form, 'site_x_option_group_set_metakey'))#" /> 
					</td>
					</tr>
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Description:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="site_x_option_group_set_metadesc" value="#htmleditformat(application.zcore.functions.zso(form, 'site_x_option_group_set_metadesc'))#" /> 
					</td>
					</tr>
				</cfif>

				<cfif qS.site_option_group_is_home_page EQ 0 and qS.site_option_group_enable_unique_url EQ 1 and methodBackup NEQ "userAddGroup" and methodBackup NEQ "userEditGroup">
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Override URL:</div></th>
					<td style="vertical-align:top; "> 

						<cfif form.method EQ "publicAddGroup" or form.method EQ "addGroup">
							#application.zcore.functions.zInputUniqueUrl("site_x_option_group_set_override_url", true)#
						<cfelse>
							#application.zcore.functions.zInputUniqueUrl("site_x_option_group_set_override_url")# 
						</cfif>
					</td>
					</tr>
					<cfset tempIndex++>
				</cfif>
			</cfif>
			<cfif qS.site_option_group_enable_image_library EQ 1>
				<tr class="siteOptionFormField#qS.site_option_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Image Library:</div></th>
				<td style="vertical-align:top;">
					<cfscript>
					ts=structnew();
					ts.name="site_x_option_group_set_image_library_id";
					ts.value=application.zcore.functions.zso(form, 'site_x_option_group_set_image_library_id', true);
					ts.allowPublicEditing=true;
					application.zcore.imageLibraryCom.getLibraryForm(ts);
					
					</cfscript>
				</td>
				</tr>
				<cfset tempIndex++>
			</cfif> 
			<cfif qS.site_option_group_enable_public_captcha EQ 1 and (methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup")>
				<tr class="siteOptionFormField#qS.site_option_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">&nbsp;</div></th>
				<td style="vertical-align:top; ">
				#application.zcore.functions.zDisplayRecaptcha()#
				</td>
				</tr>
				<cfset tempIndex++>
			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td>
				<cfif qS.site_option_group_is_home_page EQ 1>
					<input type="hidden" name="site_x_option_group_set_override_url" value="/" />
				</cfif>
				#arraytolist(arrEnd, '')#
				<cfif qS.site_option_group_enable_unique_url EQ 1 and (methodBackup EQ "userAddGroup" or methodBackup EQ "userEditGroup")>
					<input type="hidden" name="site_x_option_group_set_override_url" value="#application.zcore.functions.zso(form, 'site_x_option_group_set_override_url')#" />
				</cfif>
				<cfif form.modalpopforced EQ 1>
					<input type="hidden" name="modalpopforced" value="1" />
				</cfif>
	
				<cfif methodBackup EQ "publicAddGroup" or methodBackup EQ "publicEditGroup">
					<button type="submit" name="submitForm" class="zSiteOptionGroupSubmitButton">Submit</button>
					<div class="zSiteOptionGroupWaitDiv" style="display:none; float:left; padding:5px; margin-right:5px;">Please Wait...</div>
					<cfif structkeyexists(arguments.struct, 'cancelURL')>
						<button type="button" name="cancel1" onclick="window.location.href='#htmleditformat(arguments.struct.cancelURL)#';">Cancel</button>
					</cfif>
					&nbsp;&nbsp; <a href="/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a>
					    <cfif form.modalpopforced EQ 1>
							<input type="hidden" name="js3811" id="js3811" value="" />
							<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
					    </cfif>
				<cfelse>
					<div class="tabWaitButton zSiteOptionGroupWaitDiv" style="float:left; padding:5px; display:none; ">Please wait...</div>
					<button type="submit" name="submitForm" class="z-manager-search-button tabSaveButton zSiteOptionGroupSubmitButton">Save</button>
						&nbsp;
						<cfif form.modalpopforced EQ 1>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
						<cfelse>

							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
				</cfif>
				</td>
			</tr>
		</table>
	</form>
	<cfscript> 
	if(qCheck.site_option_group_bottom_form_description NEQ ""){
		echo(qCheck.site_option_group_bottom_form_description);
	}
	</cfscript>
	<div style="width:100%; <cfif form.site_option_group_id EQ "">min-height:1000px; </cfif> float:left; clear:both;"></div>
	<cfif structkeyexists(form, 'jumptoanchor')>
		<script type="text/javascript">
		/* <![CDATA[ */
		var d1=document.getElementById("#form.jumptoanchor#");
		var p=zGetAbsPosition(d1);
		window.scrollTo(0, p.y);
		/* ]]> */
		</script>
	</cfif>
</cffunction>


<cffunction name="autoDeleteGroup" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="autoDeleteGroup";
	form.confirm=1;
	form.site_option_app_id=0;
	this.deleteGroup();
	</cfscript>
</cffunction>


<cffunction name="publicDeleteGroup" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicDeleteGroup";
	this.deleteGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getDefaultStruct" localmode="modern" access="public">
	<cfscript>  
	if(left(form.method, 4) EQ "user"){

		defaultStruct={
			versionURL:"",///z/admin/site-option-group-deep-copy/userVersionList",
			copyURL:"",///z/admin/site-option-group-deep-copy/user",
			addURL:"/z/admin/site-options/userAddGroup",
			editURL:"/z/admin/site-options/userEditGroup",
			sectionURL:"/z/admin/site-options/userSectionGroup",
			deleteURL:"/z/admin/site-options/userDeleteGroup",
			insertURL:"/z/admin/site-options/userInsertGroup",
			updateURL:"/z/admin/site-options/userUpdateGroup",
			listURL:"/z/admin/site-options/userManageGroup",
			getRowURL:"/z/admin/site-options/userGetRowHTML",
			archiveURL:"/z/admin/site-options/userArchiveGroup",
			unarchiveURL:"/z/admin/site-options/userUnarchiveGroup"
		};
	}else{
		defaultStruct={
			versionURL:"/z/admin/site-option-group-deep-copy/versionList",
			copyURL:"/z/admin/site-option-group-deep-copy/index",
			addURL:"/z/admin/site-options/addGroup",
			editURL:"/z/admin/site-options/editGroup",
			sectionURL:"/z/admin/site-options/sectionGroup",
			deleteURL:"/z/admin/site-options/deleteGroup",
			insertURL:"/z/admin/site-options/insertGroup",
			updateURL:"/z/admin/site-options/updateGroup",
			listURL:"/z/admin/site-options/manageGroup",
			errorURL:"/z/admin/site-options/index",
			getRowURL:"/z/admin/site-options/getRowHTML",
			archiveURL:"/z/admin/site-options/archiveGroup",
			unarchiveURL:"/z/admin/site-options/unarchiveGroup"
		};
	}
	return defaultStruct;
</cfscript>
</cffunction>

<cffunction name="userArchiveGroup" localmode="modern" access="remote"> 
	<cfscript>
	validateUserGroupAccess(); 
	this.archiveGroup();
	</cfscript>
</cffunction>

<cffunction name="userUnarchiveGroup" localmode="modern" access="remote">
	<cfscript>
	validateUserGroupAccess(); 
	this.unarchiveGroup();
	</cfscript>
</cffunction>

<cffunction name="archiveGroup" localmode="modern" access="remote"> 
	<cfscript>
	var db=request.zos.queryObject;
	init();
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true);
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id', true);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true);
	db.sql="update #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# SET 
	site_x_option_group_set_archived=#db.param(1)# 
	WHERE 
	site_x_option_group_set_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# ";
	db.execute("qUpdate");/**/

	application.zcore.functions.zReturnJson({success:true});
	/*
	application.zcore.status.setStatus(request.zsid, "Record archived.");
	if(form.method EQ "userUnarchiveGroup"){
		application.zcore.functions.zRedirect("/z/admin/site-options/userManageGroup?site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_id=#row.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#");
	}else{
		application.zcore.functions.zRedirect("/z/admin/site-options/manageGroup?site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_id=#row.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#");
	}*/
	</cfscript>
</cffunction>

<cffunction name="unarchiveGroup" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true);
	form.site_x_option_group_set_parent_id=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id', true);
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true);
	db.sql="update #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# SET 
	site_x_option_group_set_archived=#db.param(0)# 
	WHERE 
	site_x_option_group_set_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# ";
	db.execute("qUpdate");

	application.zcore.status.setStatus(request.zsid, "Record unarchived.");
	if(form.method EQ "userUnarchiveGroup"){
		application.zcore.functions.zRedirect("/z/admin/site-options/userManageGroup?site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#");
	}else{
		application.zcore.functions.zRedirect("/z/admin/site-options/manageGroup?site_option_group_id=#form.site_option_group_id#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#");
	}
	</cfscript>
</cffunction>

<cffunction name="userDeleteGroup" localmode="modern" access="remote" roles="user">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	validateUserGroupAccess();
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css"); 
	deleteGroup(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="deleteGroup" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var queueSortStruct=0;
	var queueSortCom=0;
	var r1=0;
	var qS=0;
	var qCheck=0;
	var theTitle=0;
	var i=0;
	var result=0;   
	setting requesttimeout="100000";

	defaultStruct=getDefaultStruct();
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	//if(form.method EQ "deleteGroup"){
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
		if(form.modalpopforced EQ 1){
			application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
			application.zcore.functions.zSetModalWindow();
		}
	//}
	structappend(arguments.struct, defaultStruct, false);
	
	variables.init();
	if(form.method NEQ "autoDeleteGroup"){
		// handled in init instead
		//application.zcore.adminSecurityFilter.requireFeatureAccess("Site Options", true);	
	}
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group, 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set WHERE
	site_option_group_deleted = #db.param(0)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set.site_id = site_option_group.site_id and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
	site_option_group.site_option_group_id= #db.param(form.site_option_group_id)# and 
	site_x_option_group_set.site_id= #db.param(request.zos.globals.id)#";
	if(form.method EQ "userDeleteGroup" and request.isUserPrimaryGroup){
		currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
		db.sql&=" and site_x_option_group_set_user = #db.param(currentUserIdValue)# ";
	}
	qCheck=db.execute("qCheck", "", 10000, "query", false);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Site Option Group is missing");
		if(form.method EQ "autoDeleteGroup"){
			return false;
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id="&form.site_option_app_id&"&site_option_group_id="&form.site_option_group_id&"&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&zsid="&request.zsid));
		}
	} 

	if(form.method EQ "userDeleteGroup"){ 
		allowDelete=true;
		if(qCheck.site_option_group_allow_delete_usergrouplist NEQ ""){
			arrUserGroup=listToArray(qCheck.site_option_group_allow_delete_usergrouplist, ",");
			allowDelete=false;
			for(i=1;i LTE arraylen(arrUserGroup);i++){
				if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
					allowDelete=true;
					break;
				}
			}
		} 
		if(not allowDelete){
			application.zcore.functions.z404("user delete is disabled for site_option_group_id, #form.site_option_group_id#.");
		}
		arrUserGroup=listToArray(qCheck.site_option_group_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserGroup);i++){
			if(application.zcore.user.checkGroupIdAccess(arrUserGroup[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("site_option_group_id, #form.site_option_group_id#, doesn't allow public data entry.");
		}
	}

	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(form.method EQ "userDeleteGroup"){ 
			if(qCheck.site_option_group_change_email_usergrouplist NEQ ""){
				newAction='deleted'; 
				application.zcore.siteOptionCom.sendChangeEmail(qCheck.site_x_option_group_set_id, newAction);
			}
		}
		for(row in qCheck){
			application.zcore.siteOptionCom.deleteGroupSetRecursively(row.site_x_option_group_set_id, row);
		}
 
		if(qCheck.site_option_group_enable_sorting EQ 1){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "site_x_option_group_set";
			queueSortStruct.sortFieldName = "site_x_option_group_set_sort";
			queueSortStruct.primaryKeyName = "site_x_option_group_set_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			
			queueSortStruct.where =" site_x_option_group_set.site_option_app_id = '#application.zcore.functions.zescape(form.site_option_app_id)#' and  
			site_option_group_id = '#application.zcore.functions.zescape(form.site_option_group_id)#' and 
			site_id = '#request.zos.globals.id#' and 
			site_x_option_group_set_master_set_id = '0' and 
			site_x_option_group_set_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			r1=queueSortCom.init(queueSortStruct);
			queueSortCom.sortAll();
		}
		if((request.zos.enableSiteOptionGroupCache and qCheck.site_option_group_enable_cache EQ 1) or (qCheck.site_option_group_enable_versioning EQ 1 and qCheck.site_x_option_group_set_master_set_id NEQ 0)){
			application.zcore.siteOptionCom.deleteOptionGroupSetIdCache(request.zos.globals.id, form.site_x_option_group_set_id);
		}
		//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
		application.zcore.status.setStatus(request.zsid, "Deleted successfully.");
		if(form.method EQ "autoDeleteGroup"){
			return true;
		}else if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else if(qcheck.site_x_option_group_set_master_set_id NEQ 0){
			application.zcore.functions.zRedirect("/z/admin/site-option-group-deep-copy/versionList?site_x_option_group_set_id=#qcheck.site_x_option_group_set_master_set_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id="&form.site_option_app_id&"&site_option_group_id="&form.site_option_group_id&"&site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#&zsid="&request.zsid));
		}
        	</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Group";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2>
		Are you sure you want to delete this data?<br />
		<br />
		#qcheck.site_option_group_display_name# 		<br />
		ID## #form.site_x_option_group_set_id# <br />
		<br />
		<cfscript>
		if(qcheck.site_x_option_group_set_master_set_id NEQ 0){
			deleteLink="/z/admin/site-option-group-deep-copy/versionList?site_x_option_group_set_id=#qcheck.site_x_option_group_set_master_set_id#";
		}else{
			deleteLink="#application.zcore.functions.zURLAppend(arguments.struct.listURL, "site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#";
		}
		</cfscript>
		<a href="#application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "site_option_app_id=#form.site_option_app_id#&amp;confirm=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;site_option_group_id=#form.site_option_group_id#&amp;site_x_option_group_set_parent_id=#form.site_x_option_group_set_parent_id#")#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#deleteLink#">No</a>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qS=0;
	var qGroup=0;
	var qU9=0;
	var theTitle=0;
	var htmlEditor=0;
	var lastGroup=0;
	var ts=0;
	var site_option_group_id=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.7");
	application.zcore.functions.zStatusHandler(request.zsid);
	request.zsession["siteoption_return"&application.zcore.functions.zso(form, 'site_option_id')]=application.zcore.functions.zso(form, 'returnURL');		
	form.jumpto=application.zcore.functions.zso(form, 'jumpto');
	site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id',true);
   	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	LEFT JOIN #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option ON 
	site_option.site_option_id = site_x_option.site_option_id and 
	site_x_option.site_id = #db.param(request.zos.globals.id)# and 
	site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))# and 
	site_x_option.site_option_app_id=#db.param(form.site_option_app_id)# and 
	site_x_option_deleted = #db.param(0)#
	LEFT JOIN #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group ON 
	site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_group_deleted = #db.param(0)# and
	site_option_group.site_id = site_x_option.site_id and 
	site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	(site_option_group.site_option_group_appidlist like #db.param('%,#variables.currentAppId#,%')#";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option_group.site_option_group_appidlist like #db.param('%,,%')# and 
		site_option_group_admin_app_only= #db.param(0)# ";
	}
	db.sql&=")
	WHERE site_option.site_id IN (#db.trustedSQL(variables.publicSiteIdList)#) and 
	site_option_deleted = #db.param(0)# and
	(site_option_group.site_option_group_id IS NULL or 
	site_option_group.site_option_group_type =#db.param('0')#)
	and (site_option.site_option_appidlist like #db.param('%,#variables.currentAppId#,%')#";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option.site_option_appidlist like #db.param('%,,%')#";
	}
	db.sql&=")";
	if(site_option_group_id EQ 0){
		db.sql&=" and site_option.site_option_group_id=#db.param('0')#";
	}
	if(structkeyexists(request.zos,'listing') EQ false){
		db.sql&=" and site_option_listing_only=#db.param('0')#";
	}
	db.sql&=" ORDER BY site_option_group.site_option_group_display_name ASC, site_option.site_option_name ASC ";
	qS=db.execute("qS");
	theTitle="Site Options";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	db.sql="SELECT site_option_group.*, count(site_x_option_group_set.site_option_group_id) childCount 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	LEFT JOIN #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set ON 
	site_x_option_group_set.site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set.site_option_group_id = site_option_group.site_option_group_id and 
	site_option_app_id=#db.param(form.site_option_app_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# 
	WHERE site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group_type =#db.param('1')# and 
	(site_option_group.site_option_group_appidlist like #db.param('%,#variables.currentAppId#,%')# ";
	if(variables.currentAppId EQ 0){
		db.sql&=" or site_option_group.site_option_group_appidlist like #db.param('%,,%')# and 
		site_option_group_admin_app_only= #db.param(0)# ";
	}
	db.sql&=" )  and 
	site_option_group.site_option_group_disable_admin=#db.param(0)#
	GROUP BY site_option_group.site_option_group_id 
	ORDER BY site_option_group.site_option_group_display_name ASC ";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount NEQ 0){
		writeoutput('<h2>Site Features</h2>
		<table style="border-spacing:0px;" class="table-list">');
		var row=0;
		for(row in qGroup){
			writeoutput('<tr ');
			if(qGroup.currentRow MOD 2 EQ 0){
				writeoutput('class="row2"');
			}else{
				writeoutput('class="row1"');
			}
			writeoutput('>
				<td>#qGroup.site_option_group_display_name#</td>
				<td><a href="/z/admin/site-options/manageGroup?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#" class="z-manager-search-button">List/Edit</a> 
					 <a href="/z/admin/site-options/import?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#" class="z-manager-search-button">Import</a> ');
				
					if(qGroup.site_option_group_allow_public NEQ 0){
						writeoutput(' ');
						if(qGroup.site_option_group_public_form_url NEQ ""){
							writeoutput('<a href="#htmleditformat(qGroup.site_option_group_public_form_url)#" target="_blank" class="z-manager-search-button">Public Form</a> ');
						}else{
							writeoutput('<a href="/z/misc/display-site-option-group/add?site_option_group_id=#qGroup.site_option_group_id#" target="_blank" class="z-manager-search-button">Public Form</a> ');
						}
					}
					if(qGroup.site_option_group_limit EQ 0 or qGroup.childCount LT qGroup.site_option_group_limit){
						writeoutput(' <a href="/z/admin/site-options/addGroup?site_option_app_id=#form.site_option_app_id#&amp;site_option_group_id=#qGroup.site_option_group_id#" class="z-manager-search-button">Add</a>');
					}else{
						writeoutput(' Limit Reached');
					}
					writeoutput('</td>
			</tr>');
		}
		writeoutput('</table>
		<br />');
	}

	featuresCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
	featuresCom.index();

	writeoutput('<h2>Global Site Options</h2>');
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	where user_id = #db.param(request.zsession.user.id)# and 
	user_deleted = #db.param(0)# and
	site_id=#db.param(request.zsession.user.site_id)#";
	qU9=db.execute("qU9");
	if(qu9.recordcount NEQ 0 and form.site_option_app_id EQ 0){
		writeoutput('<a href="/z/-evm#request.zsession.user.id#.0.#qu9.user_key#.1" rel="external" onclick="window.open(this.href); return false;"  class="z-manager-search-button">View email autoresponder</a>');
		if(application.zcore.functions.zvar('sendConfirmOptIn', request.zos.globals.id) NEQ 1){
			echo(" (Autoresponder DISABLED - contact web developer to enable)");
		}else{
			echo(' (Autoresponder Enabled)');
		}
		echo('<br /><br />
			<form class="zFormCheckDirty" action="/z/admin/site-options/sendAutoresponderTest" method="get">
			Send Autoresponder To Email: <input type="text" name="email" value="#request.zsession.user.email#" /> <input type="submit" name="submit1" value="Send" class="z-manager-search-button" />
			</form><br />
		<br />');
	}
	if(qS.recordcount EQ 0){
		writeoutput('<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>No site options are available at this time.</th>
			</tr>
		</table>');
	}else{
		writeoutput('
			<h3>Click on an option name below to edit it</h3> <form  class="zFormCheckDirty" name="myForm" action="/z/admin/site-options/saveOptions?site_option_app_id=#form.site_option_app_id#" method="post" enctype="multipart/form-data">
			<table style="border-spacing:0px; width:100%;" class="table-list">');
			lastGroup="";
			var row=0;
			var optionStruct={};
			var currentRowIndex=0;
			var dataStruct={};
			var labelStruct={};
			arrRow=[];  
			for(row in qS){ 
				arrayAppend(arrRow, row);
				currentRowIndex++;
				if(form.jumpto EQ "soid_#application.zcore.functions.zurlencode(row.site_option_name,"_")#"){
					jumptoanchor="soid_#row.site_option_id#";
				}
				if(not structkeyexists(form, "newvalue"&row.site_option_id)){
					form["newvalue"&row.site_option_id]=row.site_x_option_value;
					if(row.site_x_option_id EQ ""){
						form["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				form[row.site_option_name]=form["newvalue"&row.site_option_id];
				if(row.site_x_option_id EQ ""){
					if(not structkeyexists(form, "newvalue"&row.site_option_id)){
						form["newvalue"&row.site_option_id]=row.site_option_default_value;
					}
				}
				optionStruct[row.site_option_id]=deserializeJson(row.site_option_type_json);
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
				dataStruct=currentCFC.onBeforeListView(row, optionStruct[row.site_option_id], form);
				value=currentCFC.getListValue(dataStruct, optionStruct[row.site_option_id], application.zcore.functions.zso(form, "newvalue"&row.site_option_id));
				if(value EQ ""){
					value=row.site_option_default_value;
				}
				labelStruct[row.site_option_name]=value;
			}
			currentRowIndex=0; 
			for(row in arrRow){ 
				currentRowIndex++;
				if(lastGroup NEQ row.site_option_group_name){
					lastGroup = row.site_option_group_name;
					writeoutput('<tr>
						<td colspan="2"><h2>#htmleditformat(row.site_option_group_display_name)#</h2></td>
					</tr>');
				}
				writeoutput('<tr ');
				if(currentRowIndex MOD 2 EQ 0){
					writeoutput('class="row2"');
				}else{
					writeoutput('class="row1"');
				}
 
				writeoutput('>
				<td style="vertical-align:top;" colspan="2" style="padding-bottom:10px;"><a id="soid_#row.site_option_id#" style="display:block; float:left;"></a>
					<div style="padding-bottom:5px;float:left; width:99%;"><a href="##" class="soid_link" title="Click to toggle editing the value of this option." data-id="#row.site_option_id#">#row.site_option_display_name#</a> 
					<a href="##" onclick="document.myForm.submit();return false;" class="zSiteOptionSave" id="soid_save#row.site_option_id#" style="display:none;">Save</a></div>
					<div id="soid_field#row.site_option_id#" style="display:none;">
					<input type="hidden" name="site_option_id" value="#row.site_option_id#" />
					<input type="hidden" name="siteidtype" value="#application.zcore.functions.zGetSiteIdType(row.site_id)#" />
					<br style="clear:both;" />');
					var currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id); 
					var rs=currentCFC.getFormField(row, optionStruct[row.site_option_id], 'newvalue', form);
					writeoutput(rs.value);
					writeoutput('</div></td>
				</tr>');
			}
			writeoutput('<tr>
				<td>&nbsp;</td>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save Options</button>
					&nbsp;');
					if(structkeyexists(form,'returnURL') and form.returnURL NEQ ""){
						writeoutput('<button type="button" name="cancel" onclick="window.location.href=''#form.returnURL#'';" class="z-manager-search-button">Cancel</button>');
					}
					writeoutput('</td>
				</tr>
			</table>
		</form>
		<a name="s1"></a>
		<div style="width:100%; height:1000px; float:left; clear:both;"></div>

		');

		writeoutput('<script type="text/javascript">
		/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){ 

			$(".soid_link").bind("click", function(e){
				e.preventDefault();
				var id=$(this).attr("data-id");
				if($("##soid_field"+id).css("display") == "block"){
					$("##soid_field"+id).hide();
					$("##soid_save"+id).hide();
				}else{
					$("##soid_field"+id).show();
					$("##soid_save"+id).show();
				}
			});
		});
		/* ]]> */
		</script>');
		if(structkeyexists(form, 'jumptoanchor')){
			writeoutput('<script type="text/javascript">
			/* <![CDATA[ */
			zArrDeferredFunctions.push(function(){
				setTimeout(function(){
				var d1=document.getElementById("#form.jumptoanchor#");
				var p=zGetAbsPosition(d1);
				window.scrollTo(0, p.y);
				},600); 
			});
			/* ]]> */
			</script>');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="sendAutoresponderTest" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;

	form.email=application.zcore.functions.zso(form, 'email');
	if(not application.zcore.functions.zEmailValidate(form.email)){
		application.zcore.status.setStatus(request.zsid, "Invalid email address.", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
	}
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
	user_username = #db.param(form.email)# and 
	site_id IN (#db.param(request.zos.globals.serverId)#, #db.param(request.zos.globals.id)#, #db.param(request.zos.globals.parentId)#) 
	LIMIT #db.param(1)#";
	qCheck=db.execute("qCheck");
	ts=StructNew();
	// optional
	ts.force=1; // force ignores opt-in status // TEMPORARY FOR DEBUG
	ts.zemail_template_type_name="confirm opt-in";
	ts.site_id=request.zos.globals.id; // TEMPORARY FOR DEBUG
	if(qCheck.recordcount){
		ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qCheck.site_id);
        if(qCheck.zemail_template_id NEQ 0){
            ts.zemail_template_id=qCheck.zemail_template_id;
        }
        if(qCheck.user_pref_html EQ 1){
            ts.html=true;
        }else{
            ts.html=false;
        }
		ts.user_id=qCheck.user_id;
    }else{
		db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
		contact_email = #db.param(form.email)# and 
		contact_parent_id=#db.param(0)# and 
		site_id IN (#db.param(request.zos.globals.id)#) 
		LIMIT #db.param(1)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount){
			ts.contact_id=qCheck.contact_id;
		}else{
    		ts.to=form.email;
    	}
    }
	rCom=request.zos.email.sendEmailTemplate(ts);
	if(rCom.isOK() EQ false){
		savecontent variable="out"{
			echo(arraytolist(rCom.getErrors(), "<br />"));
		}
		application.zcore.status.setStatus(request.zsid, "Failed to send autoresponder. Errors:<br />"&out, form, true);
		application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
	}
	application.zcore.status.setStatus(request.zsid, "Autoresponder sent.");
	application.zcore.functions.zRedirect("/z/admin/site-options/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
