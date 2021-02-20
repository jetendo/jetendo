<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	db=request.zos.queryObject;
	db.sql="select * from #db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
	#db.table("site", request.zos.zcoreDatasource)# site WHERE 
	site.site_id = app_x_mls.site_id and 
	site_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)#
	LIMIT #db.param(0)#, #db.param(1)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount NEQ 0){
		application.zcore.listingCom.checkRamTables();
	}
	echo('Done');abort;
	</cfscript>
</cffunction>

<!--- /z/server-manager/tasks/verify-apps/clearOldTempData --->
<cffunction name="clearOldTempData" access="remote" localmode="modern">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	// delete 404's older then 30 days 
	if(request.zos.disable404Log){

		oldDate=dateadd("d", -30, now());
		db=request.zos.queryObject;
		db.sql="delete from #db.table("log404", request.zos.zcoreDatasource)# 
		WHERE log404_deleted=#db.param(0)# and 
		log404_datetime<=#db.param(dateformat(oldDate, "yyyy-mm-dd")&" "&timeformat(oldDate, "HH:mm:ss"))# 
		";
		db.execute("qDelete");
	}

	oldDate=dateadd("h", -2, now());
	// clear old files in temp
	tempPath=request.zos.globals.serverPrivateHomeDir&"_cache/temp_files/";
	qDir=directoryList(tempPath, true, "query", false);
	arrDir=[];
	deleteCount=0;
	for(row in qDir){
		path=row.directory&"/"&row.name;
		if(datecompare(row.dateLastModified, oldDate) EQ -1){
			if(row.type EQ "dir"){
				arrayAppend(arrDir, path);
			}else{
				application.zcore.functions.zDeleteFile(path);
				deleteCount++;
			}
		}
	}
	deleteDirCount=0;
	for(path in arrDir){
		directorydelete(path, true); 
		deleteDirCount++;
	}
	echo('Deleted #deleteCount# temp files and #deleteDirCount# directories.<br>');


	</cfscript>
</cffunction>


	
<cffunction name="verifySiteOptionConfig" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
 	if(not structkeyexists(ss, "excludeGroupStruct")){
 		ss.excludeGroupStruct={};
 	}

	db=request.zos.queryObject;

	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_domain IN (#db.trustedSQL("'"&arrayToList(ss.arrSiteDomain, "', '")&"'")#) and
	site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)# and 
	site_active=#db.param(1)# ";
	qSite=db.execute("qSite");

	siteStruct={};
	arrId=[];
	primarySiteId=0;
	for(row in qSite){
		if(row.site_domain EQ ss.primaryDomain){
			primarySiteId=row.site_id;
		}
		siteStruct[row.site_id]={
			domain:row.site_domain,
			groups:{},
			groupNameLookup:{},
			groupLookup:{},
			options:{}
		};
		arrayAppend(arrId, row.site_id);
	}
	if(primarySiteId EQ 0){
		throw("primaryDomain couldn't be found: #ss.primaryDomain#");
	}
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE 
	site_id IN (#db.trustedSQL("'"&arrayToList(arrId, "', '")&"'")#) and
	site_option_group_id <> #db.param(0)# and 
	site_option_group_deleted=#db.param(0)# ";
	qGroup=db.execute("qGroup", "", 10000, "query", false);

	arrError=["<h2>It's ok to ignore some of the differences, since the sites might be different on purpose and orphaned fields don't break anything.</h2>"];
	tempGroupNameLookup={};
	for(group in qGroup){
		tempGroupNameLookup[group.site_option_group_id&":"&group.site_id]=group.site_option_group_name;
		if(structkeyexists(ss.excludeGroupStruct, group.site_option_group_name)){
			continue; // skip
		}
		groups=siteStruct[group.site_id].groups;
		group.arrGroupName=[];
		groups[group.site_option_group_id]=group;
		siteStruct[group.site_id].groupNameLookup["0"]="(no group)";
		
	}
	for(group in qGroup){
		if(structkeyexists(ss.excludeGroupStruct, group.site_option_group_name)){
			continue; // skip
		}
		groups=siteStruct[group.site_id].groups;
		currentGroup=groups[group.site_option_group_id];
		i=0;
		while(true){
			arrayPrepend(groups[group.site_option_group_id].arrGroupName, currentGroup.site_option_group_name);
			if(currentGroup.site_option_group_parent_id EQ 0){
				break;
			}
			if(not structkeyexists(groups, currentGroup.site_option_group_parent_id)){
				arrayAppend(arrError, currentGroup.site_option_group_name&" with site_option_group_id:"&currentGroup.site_option_group_id&" may be orphaned in site_id:#group.site_id# | #siteStruct[group.site_id].domain# - loop was broken to avoid infinite loop<br>");
				break;
			}else{
				currentGroup=groups[currentGroup.site_option_group_parent_id];
				i++;
				if(i GT 50){
					throw("Detected infinite loop for #currentGroup.site_option_group_id# parent ids");
				}
			}
		}
		siteStruct[group.site_id].groups[group.site_option_group_id].groupName=arrayToList(groups[group.site_option_group_id].arrGroupName, " -> "); 
		siteStruct[group.site_id].groupNameLookup[group.site_option_group_id]=siteStruct[group.site_id].groups[group.site_option_group_id].groupName;
		siteStruct[group.site_id].groupLookup[siteStruct[group.site_id].groups[group.site_option_group_id].groupName]=group;
	} 
	/*for(i in siteStruct){
	 for(n in siteStruct[i].groupNameLookup){
	 	writedump(siteStruct[i].groupNameLookup[n]);
	 }
	}*/ 

	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE 
	site_id IN (#db.trustedSQL("'"&arrayToList(arrId, "', '")&"'")#) and
	site_option_group_id <> #db.param(0)# and 
	site_option_deleted=#db.param(0)# ";
	qOption=db.execute("qOption");

	for(option in qOption){ 
		if(not structkeyexists(tempGroupNameLookup, option.site_option_group_id&":"&option.site_id)){
			arrayAppend(arrError, "a) option.site_id: #option.site_id# has missing group: site_option_group_id: #option.site_option_group_id# is missing for option name: #option.site_option_name#<br>");
			continue;
		}
		if(structkeyexists(ss.excludeGroupStruct, tempGroupNameLookup[option.site_option_group_id&":"&option.site_id])){
			continue; // skip
		}
		if(not structkeyexists(siteStruct[option.site_id].groupNameLookup, option.site_option_group_id)){
			arrayAppend(arrError, "b) option.site_id: #option.site_id# has missing group: site_option_group_id: #option.site_option_group_id# is missing for option name: #option.site_option_name#<br>");
			continue;
		}
		groupName=siteStruct[option.site_id].groupNameLookup[option.site_option_group_id];
		if(not structkeyexists(siteStruct[option.site_id].options, groupName)){
			siteStruct[option.site_id].options[groupName]={};
		}
		siteStruct[option.site_id].options[groupName][option.site_option_name]=option;
	}

	primarySite=siteStruct[primarySiteId];
	structdelete(siteStruct, primarySiteId); 

	ignoreGroupSettings={
		"arrGroupName":true,
		"groupName":true,
		"site_option_group_id":true,
		"site_option_group_parent_id":true,
		"site_id":true,
		"site_option_group_updated_datetime":true
	};
	ignoreOptionSettings={ 
		"site_id":true,
		"site_option_id":true,
		"site_option_sort":true,
		"site_option_group_id":true,
		"site_option_updated_datetime":true
	};

	for(siteId in siteStruct){
		site=siteStruct[siteId];  
		groupUnique=[];
		for(groupId in site.groups){
			group=site.groups[groupId]; 
			// check for missing group
			if(not structkeyexists(primarySite.groupLookup, group.groupName)){
				arrayAppend(arrError, 'Group missing: #group.groupName# on #site.domain#');
			}else{
				primaryGroup=primarySite.groupLookup[group.groupName];
				// check for changed group settings
				for(setting in group){
					if(structkeyexists(ignoreGroupSettings, setting)){
						continue;
					}
					if(primaryGroup[setting] NEQ group[setting]){
						arrayAppend(arrError, 'Group settings doesn''t match: #group.groupName#: #setting# on #site.domain#');
					}
				}
			}
		} 

		for(groupName in site.options){
			optionUnique={};
			primaryOptions={};
			for(optionName in site.options[groupName]){
				option=site.options[groupName][optionName]; 
				currentGroup=siteStruct[group.site_id].groupLookup[groupName];
				if(not structkeyexists(primarySite.groupLookup, groupName)){
					arrayAppend(arrError, "groupName: #groupName# is missing in primarySite: primarySite: #primarySite.domain#");
					continue;
				}

				// get the primary group and options: 
				primaryGroup=primarySite.groupLookup[groupName];
				/*writedump(groupName);
				writedump(primaryGroup);
				writedump(primarySite.options);
				abort;*/
				primaryOptions=primarySite.options[groupName];

				optionUnique[optionName]=true;
				// check for extra fields not in primary
				if(not structkeyexists(primaryOptions, optionName)){
					arrayAppend(arrError, 'Group: #groupName# has extra field: #optionName# on #site.domain#');
				}else{
					if(option.site_option_type_id EQ 13){
						continue;
					}
					// check for changed group settings
					currentPrimaryOption=primaryOptions[optionName];  
					for(setting in option){
						if(structkeyexists(ignoreOptionSettings, setting)){
							continue;
						}
						if(currentPrimaryOption[setting] NEQ option[setting]){
							arrayAppend(arrError, 'Options settings doesn''t match: #groupName# -> #option.site_option_name#: #setting# on #site.domain#');
						}
					}
				}
			}
			// check for missing fields not in primary
			for(optionName in primaryOptions){
				if(not structkeyexists(optionUnique, optionName)){
					arrayAppend(arrError, 'Group: #groupName# is missing field: #optionName# on #site.domain#');
				}
			}
			

			// check for changed fields
		}
		// check for extra groups not in primary

		// check for extra fields not in primary
	} 
	savecontent variable="out"{
		echo('<h2>The site option group configuration was compared to #ss.primaryDomain#</h2>');
		if(arraylen(arrError) EQ 0){
			echo('<h2>No configuration differences found</h2>');
		}else{
			echo('<p>'&arrayToList(arrError, '</p><p>')&'</p>');
		}
	}

	if(arraylen(arrError) NEQ 0){
		throw(out);
	}
	echo(out);
	abort;
	</cfscript>

</cffunction>	
</cfoutput>
</cfcomponent>