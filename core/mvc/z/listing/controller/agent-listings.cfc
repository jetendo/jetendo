<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript> 
	request.zos.currentURLISAListingPage=true;
	var db=request.zos.queryObject;
	returnStruct={count:0};
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");

	application.zcore.app.getAppCFC("content").initExcludeContentId();

	form.content_listing_user_id=application.zcore.functions.zso(form, 'content_listing_user_id');
	userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
	db.sql="select *, user.site_id userSiteId 
	from #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user 
	where user.user_id = #db.param(form.content_listing_user_id)#  and 
	user_active=#db.param('1')# and 
	member_public_profile=#db.param('1')# and 
	user_deleted = #db.param(0)# and 
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#";
	qM=db.execute("qM"); 
	if(isQuery(qM) EQ false or qM.recordcount EQ 0){
		application.zcore.functions.z404("user record is missing.");
	}
	t2="#qM.member_first_name# #qM.member_last_name# ";
	application.zcore.template.settag("title",t2);
	application.zcore.template.settag("pagetitle",t2);
	application.zcore.template.settag("pagenav","<a href=""#application.zcore.functions.zvar('domain')#/"">Home</a> / <a href=""/z/misc/members/index"">Our Team</a> /");
	tempName=application.zcore.functions.zurlencode(lcase(t2),'-');

	customRender=false;
	if(application.zcore.app.siteHasApp("content")){
		db.sql="select * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
		where content_listing_user_id = #db.param(form.content_listing_user_id)# and 
		content_mls_number = #db.param('')# and 
		content_for_sale=#db.param('1')# and 
		content_deleted=#db.param('0')# and 
		site_id = #db.param(request.zos.globals.id)#";
		qC=db.execute("qC"); 
		if(tempName NEQ form.zURLName){
			application.zcore.functions.z301Redirect("/#tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#qM.user_id#.html");
		}
		if(application.zcore.functions.zso(application.zcore.app.getAppData("content").optionStruct, 'content_config_detail_cfc_path') NEQ ""){
			customRender=true;
			cfcPath=application.zcore.app.getAppData("content").optionStruct.content_config_detail_cfc_path;
			if(left(cfcPath, 5) EQ "root."){
				cfcPath=replace(cfcPath, "root.", request.zRootCFCPath);
			}
			customCFC=application.zcore.functions.zcreateobject("component", cfcPath); 
			customMethod=application.zcore.app.getAppData("content").optionStruct.content_config_detail_cfc_method;
		}

	}else{
		// old table
		db.sql="select * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
		where content_listing_user_id = #db.param(form.content_listing_user_id)# and 
		content_for_sale = #db.param('1')# and 
		site_id = #db.param(request.zos.globals.id)# and 
		content_deleted = #db.param(0)#";
		qC=db.execute("qC"); 
		if(tempName NEQ form.zURLName){
			application.zcore.functions.z301Redirect("/#tempName#-#urlappid#-#qM.user_id#.html");
		}
	}


	request.contentCount=0;
	request.cOutStruct=structnew();	 
	for(row in qM){	
		if(not customRender){
			echo('<div class="zMemberFullDiv">
				<div class="zMemberImageDiv"><a id="member#row.user_id#"></a>');
			if(fileexists(application.zcore.functions.zVar('privatehomedir',row.userSiteId)&removechars(request.zos.memberImagePath,1,1)&row.member_photo)){
				echo('<span><img src="');
				if(application.zcore.functions.zvar('domainaliases',row.userSiteId) NEQ ""){
					echo('http://'&application.zcore.functions.zvar('domainaliases',row.userSiteId));
				}else{
					echo(application.zcore.functions.zvar('domain',row.userSiteId));
				}
				echo(request.zos.memberImagePath&row.member_photo&'" alt="#htmleditformat(row.member_first_name&" "&row.member_last_name)#" style="border:none;" /></span>');
			}else{
				echo('Image N/A');
			}
			echo('</div>
				<div class="zMemberTextDiv">');
			if(row.member_title NEQ ''){
				echo('<strong>Title:</strong> #row.member_title#<br />');
			}
			if(row.member_phone NEQ ''){
				echo('<strong>Phone:</strong> #row.member_phone#<br />');
			}
			if(row.member_email NEQ '' and row.user_hide_public_email EQ 0){
				echo('<strong>Email:</strong>');
				application.zcore.functions.zEncodeEmail(row.member_email,true);
				echo('<br />');
			}
			if(row.member_website NEQ ''){
				echo('<strong>Web Site:</strong> <a href="#row.member_website#" target="_blank">Visit Web Site</a><br />');
			}
			if(row.user_twitter_url NEQ ''){
				echo('<a href="#row.user_twitter_url#" target="_blank">Find me on Twitter</a><br />');
			}
			if(row.user_facebook_url NEQ ''){
				echo('<a href="#row.user_facebook_url#" target="_blank">Find me on Facebook</a><br />');
			}
			if(row.user_instagram_url NEQ ''){
				echo(' <a href="#row.user_instagram_url#" target="_blank">Find me on Instagram</a><br />');
			}
			if(row.user_linkedin_url NEQ ''){
				echo('<a href="#row.user_linkedin_url#" target="_blank">Find me on LinkedIn</a><br />');
			}

			if(row.member_description NEQ ''){
				echo('<div>#trim(row.member_description)#</div>');
			}
			echo('	</div>
			</div>');
		}

		searchResultStruct={count:0};
		savecontent variable="local.tempAgentOutput"{ 
			if(application.zcore.app.siteHasApp("listing") and row.member_mlsagentid NEQ "" and row.member_mlsagentid NEQ ",,"){
				propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
				propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");

				form.pw=250;
				form.ph=180;
				form.pa=1;

				ts = StructNew();
				ts.offset =0;
				perpageDefault=100;
				perpage=100;
				perpage=max(1,min(perpage,100));
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					ts.debug=true;	
				}
				ts.perpage = perpage;
				ts.distance = 30; // in miles
				ts.disableCount=true;
				ts.searchCriteria=structnew();
				ts.searchCriteria.search_result_limit=100;
				form.search_result_limit=ts.searchCriteria.search_result_limit;
				if(row.user_listing_sort EQ 2){
					parentChildSorting2=2;
					ts.searchCriteria.search_sort="priceasc";
				}else{
					parentChildSorting2=1;
					ts.searchCriteria.search_sort="pricedesc";
				}
				ts.searchCriteria.search_result_layout=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_list_layout;
				form.search_result_layout=ts.searchCriteria.search_result_layout; 
				ts.searchCriteria.search_agent=row.member_mlsagentid;
				//ts.debug=true;
				returnStruct = propertyDataCom.getProperties(ts);
				structdelete(variables,'ts');
				if(returnStruct.count NEQ 0){	
					ts = StructNew();
					ts.output=false;
					returnStruct.perpage=form.search_result_limit;
					ts.search_result_layout=form.search_result_layout;
					ts.dataStruct = returnStruct;
					propDisplayCom.init(ts);
					
					if(customRender){
						searchResultStruct=propDisplayCom.getAjaxObject();
					}else{
						res=propDisplayCom.display();
					}
				} 

				if(not customRender){
				    if(parentChildSorting2 EQ 1){
						arrOrder=structsort(request.cOutStruct,"numeric","desc","price");
					}else if(parentChildSorting2 EQ 2){
						arrOrder=structsort(request.cOutStruct,"numeric","asc","price");
					}else if(parentChildSorting2 EQ 0){
						arrOrder=structsort(request.cOutStruct,"numeric","asc","sort");
					}
					for(i=1;i LTE arraylen(arrOrder);i++){
						writeoutput(request.cOutStruct[arrOrder[i]].output);
					}
				}
			}
		}
		if(customRender){ 
			customCfc[customMethod](row, searchResultStruct);
		}else{
			if(returnStruct.count NEQ 0){
				echo('<h2>View My Listings</h2>#local.tempAgentOutput#');
			}

		}
	} 
	</cfscript> 
</cffunction>
 </cfoutput>
 </cfcomponent>