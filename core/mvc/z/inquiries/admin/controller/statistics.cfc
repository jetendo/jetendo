<cfcomponent>
<cfoutput> 
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
		init();
	form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
	params=[];//&#variables.pageZSID#=#form[variables.pageZSID]#");
	if(form.searchOn EQ 1){
		arrayAppend(params, "searchOn=#form.searchOn#");
	} 
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Reports");
	var db=request.zos.queryObject; 
	rs={};
	loadListLookupData();
	variables.searchFields=[]; 
	if(structkeyexists(rs, 'searchFields')){
		variables.searchFields=rs.searchFields;
	}
 	for(group in variables.searchFields){
 		if(structkeyexists(group, 'fields')){
		 	for(field in group.fields){
		 		form[field.field]=application.zcore.functions.zso(form, field.field); 

				if(form.searchOn EQ 1){
 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
 				}
		 	}
		}
	}
 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));
	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(application.zcore.functions.zso(request.zsession, "selectedofficeid", true, 0) NEQ 0){
		form.search_office_id=request.zsession.selectedofficeid;
	}
	form.searchType=application.zcore.functions.zso(form, 'searchType');
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	}
	if(structkeyexists(form, 'grouping')){
		request.zsession.leademailgrouping=form.grouping;
	}else if(structkeyexists(request.zsession, 'leademailgrouping') EQ false){
		request.zsession.leademailgrouping='0';
	}
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# ";
	if(form.method EQ "userIndex"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ '0'){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	variables.qinquiriesFirst=db.execute("qinquiriesFirst"); 
 

	if(isnull(variables.qinquiriesFirst.inquiries_datetime) EQ false and isdate(variables.qinquiriesFirst.inquiries_datetime)){
		variables.inquiryFirstDate=variables.qinquiriesFirst.inquiries_datetime;
	}else{
		variables.inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
		form.inquiries_end_date=now();
	}
	if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
		form.inquiries_start_date=variables.inquiryFirstDate; 
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(datediff("d",form.inquiries_start_date, variables.inquiryFirstDate) GT 0){
			form.inquiries_start_date=variables.inquiryFirstDate;
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	} 

	variables.searchFields=[];
	savecontent variable="typeField"{

		db.sql="SELECT *, 
		#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as 
		inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
		WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted = #db.param(0)# ";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qTypes=db.execute("qTypes");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_type_id";
		selectStruct.query = qTypes;
		selectStruct.inlineStyle="width:100%;";
		selectStruct.queryLabelField = "inquiries_type_name";
		selectStruct.queryParseValueVars=true;
		selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	savecontent variable="statusField"{
		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# 
		WHERE   
		inquiries_status_deleted = #db.param(0)# "; 
		db.sql&="ORDER BY inquiries_status_name ASC ";
		qStatus=db.execute("qStatus");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_status_id";
		selectStruct.inlineStyle="width:100%;";
		selectStruct.query = qStatus;
		selectStruct.queryLabelField = "inquiries_status_name"; 
		selectStruct.queryValueField = "inquiries_status_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}

	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Name",
			formField:'<input type="search" name="inquiries_name" id="inquiries_name" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_name'))#"> ',
			field:"inquiries_first_name",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Email",
			formField:'<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" /> ',
			field:"search_email",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Phone",
			formField:'<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />',
			field:"search_phone",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Type",
			formField:typeField,
			field:"inquiries_type_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Status",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Report Type",
			formField:statusField,
			field:"report_type",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});
	arrayAppend(variables.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});


	db.sql="SELECT COUNT(*) AS Num, inquiries_type_name
	FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type_deleted=#db.param(0)# and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# ";

	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(form.search_office_id NEQ "0"){
		db.sql&=" and inquiries.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.inquiries_status_id EQ ""){ 
		db.sql&=" and inquiries.inquiries_status_id <> #db.param(0)# ";
	}else{
		db.sql&=" and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# ";
	}
	db.sql&=" and inquiries_parent_id = #db.param(0)# ";

	if(form.method EQ "userIndex"){
		db.sql&=" #getUserLeadFilterSQL(db)#";
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
	//if(form.searchType EQ ""){
		if(form.inquiries_status_id EQ ""){ 
			if(request.zsession.leadcontactfilter NEQ 'allclosed'){
				db.sql&=" and inquiries.inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			}else{
				db.sql&=" and inquiries.inquiries_status_id IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) ";
			} 
		}
	//}else{ 
		if(form.inquiries_start_date EQ false){
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')# ";
		}
		if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|"){
			db.sql&=" and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
			inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ";
		}

	
	//}
	if(form.inquiries_status_id EQ ""){ 
		if(request.zsession.leadcontactfilter EQ 'new'){
			db.sql&=" and inquiries.inquiries_status_id =#db.param('1')#  ";
		}else if(request.zsession.leadcontactfilter EQ 'email'){
			db.sql&=" and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'phone'){
			db.sql&=" and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'forced'){
			db.sql&=" and inquiries_phone_time<>#db.param('')# ";
		} 
	}
	if(request.zsession.leademailgrouping EQ '1'){
		db.sql&=" and inquiries_primary = #db.param('1')#";
	}
	db.sql &= " GROUP BY  inquiries.inquiries_type_id ";
	db.sql&=" ORDER BY Num ASC ";
	form.zPageId3=application.zcore.functions.zso(form, 'zPageId3');
	form.zIndex = application.zcore.status.getField(form.zPageId3, "zIndex", 1, true);
	/*if(form.searchType NEQ ""){
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*10)#,#db.param(10)#";
	}else{
		db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";
	}*/
	rs.qData=db.execute("qData");  
	//echo(db.sql);
	//writeDump(rs.qData);

	//abort;
	
	</cfscript>
	<style>
	.bar {
	  fill: steelblue;
	}

	.bar:hover {
	  fill: brown;
	}

	.axis--x path {
	  display: none;
	}
	</style>
	<h2>Statistics</h2>
		<cfif arraylen(variables.searchFields)>
			<div class="z-float">
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
				<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
			</div>
			<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
				<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
					<form action="#currentLink#" method="get">
						<input type="hidden" name="searchOn" value="1">
						<cfscript>
						for(group in variables.searchFields){
							echo('<div class="z-manager-search-group"');
							if(structkeyexists(group, 'groupStyle')){
								echo(' style="#group.groupStyle#"');
							}
							echo('>');
							for(field in group.fields){

								echo('<div class="z-manager-search-field">');
								if(structkeyexists(field, 'label')){
									echo('<div class="z-manager-search-field-label"');
									if(structkeyexists(field, 'labelStyle')){
										echo(' style="#field.labelStyle#"');
									}
									echo('>#field.label#</div>');
								}
								echo('<div class="z-manager-search-field-form"');
								if(structkeyexists(field, 'fieldStyle')){
									echo(' style="#field.fieldStyle#"');
								}
								echo('>#field.formField#</div></div>');
							}
							echo('</div>');
						}
						</cfscript> 
						<div class="z-manager-search-submit">
							<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
						</div>
					</form>
				</div>
			</div>
		</cfif>
		<svg width="960" height="500"></svg>
		<script>
			zArrDeferredFunctions.push(function(){
				var rawData = JSON.parse('#serializeJson(rs.qData)#');
				var i;
				var data = [];

				for(i = 0; i < rawData.DATA.length; i++){
				    data.push({'Num' : rawData.DATA[i][0], 'Label' : rawData.DATA[i][1]});
				}
				console.log(data);
				var svg = d3.select("svg"),
				    margin = {top: 20, right: 20, bottom: 30, left: 40},
				    width = +svg.attr("width") - margin.left - margin.right,
				    height = +svg.attr("height") - margin.top - margin.bottom;

				var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
				    y = d3.scaleLinear().rangeRound([height, 0]);
				var g = svg.append("g")
				    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

				x.domain(data.map(function(d) { return d.Label; }));
				y.domain([0, d3.max(data, function(d) { return d.Num; })]);

				  g.append("g")
				      .attr("class", "axis axis--x")
				      .attr("transform", "translate(0," + height + ")")
				      .call(d3.axisBottom(x));

				  g.append("g")
				      .attr("class", "axis axis--y")
				      //.call(d3.axisLeft(y).ticks(10, "%"))
				      .call(d3.axisLeft(y).ticks(10))
				    .append("text")
				      .attr("transform", "rotate(-90)")
				      .attr("y", 6)
				      .attr("dy", "0.71em")
				      .attr("text-anchor", "end")
				      .text("Number");

				  g.selectAll(".bar")
				    .data(data)
				    .enter().append("rect")
				      .attr("class", "bar")
				      .attr("x", function(d) { return x(d.Label); })
				      .attr("y", function(d) { return y(parseFloat(d.Num)); })
				      .attr("width", x.bandwidth())
				      .attr("height", function(d) { return height - y(d.Num); });
			});
		</script>
</cffunction>
<cffunction name="init">
	<cfscript>
		application.zcore.skin.includeJS("#request.zos.globals.domain#/z/javascript/d3/d3.js");
	</cfscript>
</cffunction>
<cffunction name="loadListLookupData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
	qstatus=db.execute("qstatus");
	variables.statusName={};
	loop query="qstatus"{
		variables.statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
	}

	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
	variables.qTypes=db.execute("qTypes");
	loop query="variables.qTypes"{
		variables.typeNameLookup[variables.qTypes.inquiries_type_id&"|"&variables.qTypes.inquiries_type_id_siteIdType]=variables.qTypes.inquiries_type_name;
	}

	if(application.zcore.user.checkGroupAccess("administrator")){ 
		db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		office_deleted = #db.param(0)# 
		ORDER BY office_name ASC"; 
		qOffice=db.execute("qOffice"); 
	}else{
		qOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id); 
	}
	variables.officeLookup={};
	for(row in qOffice){
		variables.officeLookup[row.office_id]=row;
	}
	</cfscript> 

</cffunction>

<cffunction name="googleSourceBreakdown" localmode="modern" access="remote" roles="member">
	<cfscript>
		init();
		variables.searchFields=[];

		variables.inquiryFirstDate = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");

		form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
		params=[];
		if(form.searchOn EQ 1){
			arrayAppend(params, "searchOn=#form.searchOn#");
		} 
	 	for(group in variables.searchFields){
	 		if(structkeyexists(group, 'fields')){
			 	for(field in group.fields){
			 		form[field.field]=application.zcore.functions.zso(form, field.field); 
					if(form.searchOn EQ 1){
	 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
	 				}
			 	}
			}
		}
	 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));

		if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
			form.inquiries_start_date=variables.inquiryFirstDate; 
		}
		if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
			form.inquiries_end_date=dateFormat(now(), "yyyy-mm-dd"); 
		}
		if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
			form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
			form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
		}
		if(not structkeyexists(form, 'inquiries_2_percent')){
			form.inquiries_2_percent = "";
		}
		var db = request.zos.queryObject; //request.zos.noVerifyQueryObject; 
		var sChecked = "";
		if(form.inquiries_2_percent EQ "on"){
			sChecked = " checked";
		}
		arrayAppend(variables.searchFields, {
			groupStyle:'width:280px; max-width:100%; ',
			fields:[{
				label:"Start",
				formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			},{
				label:"End",
				formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			},{
				label:"Combine Less 2 % to Other",
				formField:'<input type="checkbox" name="inquiries_2_percent" #sChecked#>',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			}
			]
		});
		/*db.sql = "SELECT ga_month_channel_source_goal_channel AS mrktType, SUM(ga_month_channel_source_goal_visits) AS amt
				  , ga_month_channel_source_goal_source 
				  FROM #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)# 
				  WHERE ga_month_channel_source_goal_deleted = #db.param(0)# AND site_id = #db.param(request.zos.globals.id)# AND  ";
		if(form.inquiries_start_date EQ false){
			db.sql &= " (ga_month_channel_source_goal_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" (ga_month_channel_source_goal_date >=  #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
	    db.sql &= " GROUP BY ga_month_channel_source_goal_channel, ga_month_channel_source_goal_source ";
	    */
	    //AND ga_month_channel_source_goal_channel <> #db.param('Referral')#
	    /*var sSQL = "SELECT ga_month_channel_source_goal_channel, SUM(ga_month_channel_source_goal_visits) AS amt,
					CASE 
					WHEN INSTR(ga_month_channel_source_goal_source,'instagram') 	> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Instagram'
					WHEN INSTR(ga_month_channel_source_goal_source,'facebook') 		> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Facebook'
					WHEN INSTR(ga_month_channel_source_goal_source,'pinterest') 	> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Pinterest'
					WHEN INSTR(ga_month_channel_source_goal_source,'youtube') 		> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Youtube' 
					WHEN INSTR(ga_month_channel_source_goal_source,'vk.com') 		> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'VK' 
					WHEN INSTR(ga_month_channel_source_goal_source,'getpocket.com') > 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Getpocket' 
					WHEN INSTR(ga_month_channel_source_goal_source,'google.com') 	> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Google'
					WHEN (INSTR(ga_month_channel_source_goal_source,'lnkd.in') 		> 0 OR  INSTR(ga_month_channel_source_goal_source,'linkedin.com') > 0) AND ga_month_channel_source_goal_channel = 'Social' THEN 'Linkedin' 
					WHEN INSTR(ga_month_channel_source_goal_source,'netvibes.com') 	> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'NetVibes' 
					WHEN INSTR(ga_month_channel_source_goal_source,'reddit.com') 	> 0 AND ga_month_channel_source_goal_channel = 'Social' THEN 'Reddit' 
					WHEN (INSTR(ga_month_channel_source_goal_source,'t.co') 		> 0 OR  INSTR(ga_month_channel_source_goal_source,'twitter.com') > 0) AND ga_month_channel_source_goal_channel = 'Social' THEN 'Twitter' 
					ELSE ga_month_channel_source_goal_source 
					END  AS ga_month_channel_source_goal_source
				  	FROM `jetendo`.`ga_month_channel_source_goal`
					WHERE ga_month_channel_source_goal_deleted = 0 AND site_id = #request.zos.globals.id# AND ";
					if(form.inquiries_start_date EQ false){
						sSQL  &= " (ga_month_channel_source_goal_date >= '#dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")#" & " 00:00:00' and 
						 ga_month_channel_source_goal_date <= '#dateformat(now(), "yyyy-mm-dd")#" & " 23:59:59') ";
					}else{
						sSQL &=" (ga_month_channel_source_goal_date >=  '#dateformat(form.inquiries_start_date, "yyyy-mm-dd")#" & " 00:00:00' and 
						 ga_month_channel_source_goal_date <= '#dateformat(form.inquiries_end_date, "yyyy-mm-dd")# " & " 23:59:59') ";
					}
					sSQL &= " AND ga_month_channel_source_goal_channel <> 'Referral'  
						GROUP BY ga_month_channel_source_goal_channel,ga_month_channel_source_goal_source"
		*/
	    /*var sSQL = "SELECT ga_month_channel_source_goal_channel, SUM(ga_month_channel_source_goal_visits) AS amt,
					CASE 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('instagram')#) 	> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Instagram')#
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('facebook')#) 		> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Facebook')#
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('pinterest')#) 	> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Pinterest')#
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('youtube')#) 		> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Youtube')# 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('vk.com')#) 		> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('VK')# 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('getpocket.com')#) > 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Getpocket')# 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('google.com')#) 	> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Google')#
					WHEN (INSTR(ga_month_channel_source_goal_source,#db.param('lnkd.in')#) 	> 0 OR  INSTR(ga_month_channel_source_goal_source,#db.param('linkedin.com')#) > 0) AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Linkedin')# 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('netvibes.com')#) 	> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('NetVibes')# 
					WHEN INSTR(ga_month_channel_source_goal_source,#db.param('reddit.com')#) 	> 0 AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Reddit')# 
					WHEN (INSTR(ga_month_channel_source_goal_source,#db.param('t.co')#) 		> 0 OR  INSTR(ga_month_channel_source_goal_source,#db.param('twitter.com')#) > 0) AND ga_month_channel_source_goal_channel = #db.param('Social')# THEN #db.param('Twitter')# 
					ELSE ga_month_channel_source_goal_source 
					END  AS ga_month_channel_source_goal_source
				  	FROM #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)# 
					WHERE ga_month_channel_source_goal_deleted = #db.param(0)# AND site_id = #db.param(request.zos.globals.id)# AND ";
					if(form.inquiries_start_date EQ false){
						sSql &= " (ga_month_channel_source_goal_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
						 ga_month_channel_source_goal_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
					}else{
						sSql&=" (ga_month_channel_source_goal_date >=  #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
						 ga_month_channel_source_goal_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
					}
					sSQL &= " AND ga_month_channel_source_goal_channel <> #db.param('Referral')#  
						GROUP BY ga_month_channel_source_goal_channel,ga_month_channel_source_goal_source"
		*/
		db.sql = "SELECT ga_month_channel_source_goal_channel, SUM(ga_month_channel_source_goal_visits) AS amt,ga_month_channel_source_goal_source	
				  	FROM #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)# 
					WHERE ga_month_channel_source_goal_deleted = #db.param(0)# AND site_id = #db.param(request.zos.globals.id)# AND ";
					if(form.inquiries_start_date EQ false){
						db.sql &= " (ga_month_channel_source_goal_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
						 ga_month_channel_source_goal_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
					}else{
						db.sql &=" (ga_month_channel_source_goal_date >=  #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
						 ga_month_channel_source_goal_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
					}
					 db.sql &= " AND ga_month_channel_source_goal_channel <> #db.param('Referral')# GROUP BY ga_month_channel_source_goal_channel,ga_month_channel_source_goal_source;";
	    //echo(db.sql);
	    var theData1 = [];
	    var data = db.execute("data");
	    for(var rs in Data){
	    	var sData = StructNew();
	    	sData.mrktType 	= rs.ga_month_channel_source_goal_channel;
	    	sData.amt		= rs.amt; 
	    	if(rs.ga_month_channel_source_goal_channel EQ 'Direct'){
	    		var	idx = ArrayFind(theData1, function(struct){ 
   					return struct.mrktType == rs.ga_month_channel_source_goal_channel; 
				});
	    		if(idx  <> 0) {
	    			tmp = theData1[idx];
	    			tmp.amt += rs.amt;
	    		} else{
	    			arrayAppend(theData1, sData);
	    		}
	    	} else if(rs.ga_month_channel_source_goal_channel EQ 'Email'){
	    		var	idx = ArrayFind(theData1, function(struct){ 
   					return struct.mrktType == rs.ga_month_channel_source_goal_channel; 
				});
	    		if(idx  <> 0) {
	    			tmp = theData1[idx];
	    			tmp.amt += rs.amt;
	    		} else{
	    			arrayAppend(theData1, sData);
	    		}

	    	} else if(rs.ga_month_channel_source_goal_channel EQ 'Organic Search'){
	    		if(rs.ga_month_channel_source_goal_source EQ 'bing'){
	    			sData.mrktType = 'Organic Search Bing';
	    		} else if (rs.ga_month_channel_source_goal_source EQ 'google'){
	    			sData.mrktType = 'Organic Search Google';
	    		} else if (rs.ga_month_channel_source_goal_source EQ 'yahoo'){
	    			sData.mrktType = 'Organic Search Yahoo';
	    		}		
	    		var	idx = ArrayFind(theData1, function(struct){ 
   					return struct.mrktType == sData.mrktType; 
				});
	    		if(idx  <> 0) {
	    			tmp = theData1[idx];
	    			tmp.amt += rs.amt;
	    		} else{
	    			arrayAppend(theData1, sData);
	    		}

	    	} else if(rs.ga_month_channel_source_goal_channel EQ 'Social'){
	    		if(FindNoCase(rs.ga_month_channel_source_goal_source, "facebook") NEQ 0){
	    			sData.mrktType = 'Social Facebook';
	    		} else if(FindNoCase(rs.ga_month_channel_source_goal_source, "t.co") NEQ 0 OR FindNoCase(rs.ga_month_channel_source_goal_source, "twitter") NEQ 0){
	    			sData.mrktType = 'Social Twitter';
	    		} else if(FindNoCase(rs.ga_month_channel_source_goal_source, "instagram") NEQ 0){
	    			sData.mrktType = 'Social Instagram';
	    		}		
	    		var	idx = ArrayFind(theData1, function(struct){ 
   					return struct.mrktType == sData.mrktType; 
				});
	    		if(idx  <> 0) {
	    			tmp = theData1[idx];
	    			tmp.amt += rs.amt;
	    		} else{
	    			arrayAppend(theData1, sData);
	    		}
	    	}
		}
		//writeDump(data);
	    //writedump(theData1);
	    //abort;
	</cfscript>
	<style>
		.line {
		  fill: none;
		  stroke: steelblue;
		  stroke-width: 2px;
		}
		.area {
		  fill: lightsteelblue;
		}
		.arc text {
		  font: 13px sans-serif;
		  text-anchor: middle;
		}

		.arc path {
		  stroke: ##fff;
		}
		text{
		  font: 16px sans-serif;
		}
		th{
			background-color: ##000000;
			color:##FFFFFF;
			text-align:left;
			font-weight:bold;
		}
	</style>
	<h2>Statistics</h2>
	<cfif arraylen(variables.searchFields)>
		<div class="z-float">
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
		</div>
		<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
			<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
				<form action="#currentLink#" method="get">
					<input type="hidden" name="searchOn" value="1">
					<cfscript>
					for(group in variables.searchFields){
						echo('<div class="z-manager-search-group"');
						if(structkeyexists(group, 'groupStyle')){
							echo(' style="#group.groupStyle#"');
						}
						echo('>');
						for(field in group.fields){

							echo('<div class="z-manager-search-field">');
							if(structkeyexists(field, 'label')){
								echo('<div class="z-manager-search-field-label"');
								if(structkeyexists(field, 'labelStyle')){
									echo(' style="#field.labelStyle#"');
								}
								echo('>#field.label#</div>');
							}
							echo('<div class="z-manager-search-field-form"');
							if(structkeyexists(field, 'fieldStyle')){
								echo(' style="#field.fieldStyle#"');
							}
							echo('>#field.formField#</div></div>');
						}
						echo('</div>');
					}
					</cfscript> 
					<div class="z-manager-search-submit">
						<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
					</div>
				</form>
			</div>
		</div>
	</cfif>
	<h3 style="color:##000000;padding-left:20px;">Top Channels</h3>
	<div class="d3All" style="width:100%; height:500px;">
		<div style="width:600px; height:500px; padding-left:10px; float:left;">
				<cfscript>
					var total 	= 0;
					var pieData = [];
					if(form.inquiries_2_percent EQ "on"){
						for(var x in theData1){
							total += x.amt;
						}
						var otherAmt 	= 0;
						var otherLabel	= "";
						for(var x in theData1){
							var test = (x.amt/total);
							if(test < .02){
								//echo(x.mrktType & " " & test & "<br />");
								//x.mrktType = "Other";
								otherLabel	&= x.mrktType & " ";
								otherAmt += x.amt;
							} else {
								arrayAppend(pieData,x);
							}
						}
						if(otherAmt <> 0){
							var d = {};
							d.mrktType 	= "Other " & otherLabel;
							d.amt 		= otherAmt;
							arrayAppend(pieData,d);
						}
					} else{
						for(var x in theData1){
							arrayAppend(pieData,x);
						}
					}
					//writeDump(pieData);
					#makePieChart(serializeJSON(pieData),"pcChannels")#;	
				</cfscript>
		</div>
		<!--<div id="divSessions" style="padding-top:10px; float:left;">
			<cfscript>
				/*chartData =	[
						{elDia:"05/10/2017", close: 1400}, 
						{elDia:"06/10/2017", close: 1800}, 
						{elDia:"07/10/2017", close: 2005},
						{elDia:"08/10/2017", close: 1995},
						{elDia:"09/10/2017", close: 1776}
						];

				#makeBarGraph(serializeJson(chartData),"bgSessions", "Sessions")#;	
				*/
			</cfscript>
		</div>
		<br />--->
		<!--<div id="divTablePiano" style="padding-top:10px; float:left;">
			<cfscript>
				/*pianoData = [
					{Campaign:"Modern Piano Moving (Display)", Impressions:552602, Clicks:8551, CTR:1.55, "Avg. CPC":0.06, Cost:520.07,  "Avg. Position":1.00, Conversions:75,"Cost/Conv":6.93},
					{Campaign:"Modern Piano Moving (Search)", Impressions:58396, Clicks:2097, CTR:3.59, "Avg. CPC":2.18, Cost:4572.01,  "Avg. Position":3.30, Conversions:393, "Cost/Conv":11.63},
					{Campaign:"Remarketing (Display)", Impressions:29698, Clicks:664, CTR:2.24, "Avg. CPC":0.08, Cost:54.87,  "Avg. Position":1.00, Conversions:2, "Cost/Conv":27.44},
					{Campaign:"Recruit Drivers", Impressions:10568, Clicks:132, CTR:1.25, "Avg. CPC":4.27, Cost:563.02,  "Avg. Position":2.50, Conversions:6, "Cost/Conv":93.18}
				]
				columnData = [
					{Column:"Campaign", Label:"Campaign", TableLabel:"Campaign", Total:0, Show:0, Formula:-1, Format:-1},
					{Column:"Impressions", Label:"Impressions", TableLabel:"Impressions", Total:0, Show:1, Formula:0, Format:0},
					{Column:"Clicks", Label:"Clicks", TableLabel:"Clicks", Total:0, Show:1, Formula:0, Format:0},
					{Column:"CTR", Label:"CTR", TableLabel:"CTR", Total:0, Show:1, Formula:"3/2", Format:2},
					{Column:"Avg. CPC", Label:"Avg. CPC", TableLabel:"Avg. CPC", Total:0, Show:1, Formula:"6/3", Format:1},
					{Column:"Cost", Label:"Cost", TableLabel:"Cost", Total:0, Show:1, Formula:0, Format:1},
					{Column:"Avg. Position", Label:"Avg. Position", TableLabel:"Avg. Position", Total:0, Show:1, Formula:0, Format:-1},
					{Column:"Conversions", Label:"Conversions", TableLabel:"Conversions", Total:0, Show:1, Formula:0, Format:-1},
					{Column:"Cost/Conv", Label:"Cost/Conv", TableLabel:"Cost/Conversion", Total:0, Show:1, Formula:"6/8", Format:1}

				]
				
				deviceData = [
					{Device:"Mobile devices with full browsers", Impressions:511347, Clicks:7687, CTR:1.50, Conversions:207,"Cost/Conv":11.45},
					{Device:"Tablets with full browsers", Impressions:97267, Clicks:2473, CTR:2.54, Conversions:54,"Cost/Conv":10.75},
					{Device:"Computers", Impressions:42414, Clicks:1283, CTR:3.02, Conversions:215,"Cost/Conv":12.82},
					{Device:"Other", Impressions:236, Clicks:1, CTR:0.42, Conversions:1,"Cost/Conv":0.0}
				]
				columnData2 = [
					{Column:"Device", Label:"Device", TableLabel:"Device", Total:0, Show:0, Formula:-1, Format:-1},
					{Column:"Impressions", Label:"Impressions", TableLabel:"Impressions", Total:0, Show:0, Formula:0, Format:0},
					{Column:"Clicks", Label:"Clicks", TableLabel:"Clicks", Total:0, Show:0, Formula:-1, Format:0},
					{Column:"CTR", Label:"CTR", TableLabel:"CTR", Total:0, Show:0, Formula:-1, Format:2},
					{Column:"Conversions", Label:"Conversions", TableLabel:"Conversions", Total:0, Show:0, Formula:0, Format:-1},
					{Column:"Cost/Conv", Label:"Cost/Conv", TableLabel:"Cost/Conversion", Total:0, Show:0, Formula:-1, Format:1}

				]
				#makeTableStat(deviceData,columnData2,4)#;	
				*/
			</cfscript>
		<div>-->
	<div>
</cffunction>
<cffunction name="googleAllLeadsByChannel" localmode="modern" access="remote" roles="member">
	<cfscript>
		init();
		variables.searchFields=[];
		variables.inquiryFirstDate = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");

		form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
		params=[];
		if(form.searchOn EQ 1){
			arrayAppend(params, "searchOn=#form.searchOn#");
		} 
	 	for(group in variables.searchFields){
	 		if(structkeyexists(group, 'fields')){
			 	for(field in group.fields){
			 		form[field.field]=application.zcore.functions.zso(form, field.field); 
					if(form.searchOn EQ 1){
	 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
	 				}
			 	}
			}
		}
	 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));

		if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
			form.inquiries_start_date=variables.inquiryFirstDate; 
		}
		if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
			form.inquiries_end_date=dateFormat(now(), "yyyy-mm-dd"); 
		}
		if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
			form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
			form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
		}
		var db=request.zos.queryObject; 
		arrayAppend(variables.searchFields, {
			groupStyle:'width:280px; max-width:100%; ',
			fields:[{
				label:"Start",
				formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			},{
				label:"End",
				formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			}
			]
		});
		db.sql = "SELECT ga_month_channel_source_goal_channel AS Channels, SUM(ga_month_channel_source_goal_sessions) AS Sessions, SUM(ga_month_channel_source_goal_conversion_rate)  AS GoalConversionRate,  
			      SUM(ga_month_channel_source_goal_conversions) AS GoalCompletions
				  FROM #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)# 
				  WHERE ga_month_channel_source_goal_deleted = #db.param(0)# AND site_id = #db.param(request.zos.globals.id)# AND  ";
		if(form.inquiries_start_date EQ false){
			db.sql &= " (ga_month_channel_source_goal_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" (ga_month_channel_source_goal_date >=  #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
	    db.sql &= " AND ga_month_channel_source_goal_channel <> #db.param('Referral')# GROUP BY ga_month_channel_source_goal_channel";
	    var theData1 			= db.execute("theData1");
	    var totalSessions 		= 0;
	    var totalCRate			= 0;
	    var totalCompletions	= 0;
	    for(var x in theData1){
	    	totalSessions 		+= x.Sessions;
	    	totalCompletions	+= x.GoalCompletions;
		}
	</cfscript>
	<style>
		.line {
		  fill: none;
		  stroke: steelblue;
		  stroke-width: 2px;
		}
		.area {
		  fill: lightsteelblue;
		}
		.arc text {
		  font: 13px sans-serif;
		  text-anchor: middle;
		}

		.arc path {
		  stroke: ##fff;
		}
		text{
		  font: 12px sans-serif;
		}
		th{
			background-color: ##000000;
			color:##FFFFFF;
			text-align:left;
			font-weight:bold;
		}
	</style>
	<h2>Statistics</h2>
	<cfif arraylen(variables.searchFields)>
		<div class="z-float">
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
		</div>
		<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
			<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
				<form action="#currentLink#" method="get">
					<input type="hidden" name="searchOn" value="1">
					<cfscript>
					for(group in variables.searchFields){
						echo('<div class="z-manager-search-group"');
						if(structkeyexists(group, 'groupStyle')){
							echo(' style="#group.groupStyle#"');
						}
						echo('>');
						for(field in group.fields){

							echo('<div class="z-manager-search-field">');
							if(structkeyexists(field, 'label')){
								echo('<div class="z-manager-search-field-label"');
								if(structkeyexists(field, 'labelStyle')){
									echo(' style="#field.labelStyle#"');
								}
								echo('>#field.label#</div>');
							}
							echo('<div class="z-manager-search-field-form"');
							if(structkeyexists(field, 'fieldStyle')){
								echo(' style="#field.fieldStyle#"');
							}
							echo('>#field.formField#</div></div>');
						}
						echo('</div>');
					}
					</cfscript> 
					<div class="z-manager-search-submit">
						<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
					</div>
				</form>
			</div>
		</div>
	</cfif>
	<h3 style="color:##000000;padding-left:20px;text-align:center;">All Leads by Channel</h3>
	<h4 style="color:##000000;padding-left:20px;text-align:center;">#DateFormat(form.inquiries_start_date,"MM/DD/YYYY")# - #DateFormat(form.inquiries_end_date,"MM/DD/YYYY")#</h4>
	<span style="font-size:15px;">
		A <b>Goal Completion</b> is a lead. Leads come in four ways
			<br />
			<br />
			• Phone Calls 
			<br />
			• Online "Quick Quote" 
			<br />
			• Online "Detailed Quote" 
			<br />
			• Contact Form
	</span>
	<div style="font-size:16px;width:100%; height:800px;">
		<br />
		<div>
			<div style="float:left; padding-left:20px;">
				<span>All Users: Sessions<br /><b>#NumberFormat(totalSessions)#</b></span> 
			</div>
			<div style="float:left; padding-left:220px;">
				<span>All Users: Goal Conversion Rate<br /><b>#NumberFormat((totalCompletions/totalSessions)*100,".000")#%</b></span> 

			</div>
			<div style="float:left; padding-left:440px;">
				<span>All Users: Goal Completions<br /><b>#NumberFormat(totalCompletions)#</b></span> 
			</div>
		</div>
		<div id="divTable" style="padding-top:10px; float:left;">
			<table style="width:90%;" border="2">
				<tr>
					<th>Channels</th>
					<th>Sessions</th>
					<th>Goal Conversion Rate</th>
					<th>Goal  Completions</th> 
				</tr>
				<cfloop query="theData1">
					<tr>
				    	<td>#theData1.Channels#</td>
				    	<td>#NumberFormat(theData1.Sessions)# (#NumberFormat((theData1.Sessions/totalSessions)*100,"0.00")#%)</td>
				    	<td>#NumberFormat(theData1.GoalConversionRate)#%</td>
				    	<td>#NumberFormat(theData1.GoalCompletions)#  (#NumberFormat((theData1.GoalCompletions/totalCompletions)*100,"0.00")#%)</td>
					</tr>
				</cfloop>
			</table>
		<div>
	<div>
</cffunction>
<cffunction name="googleTopTenBySource" localmode="modern" access="remote" roles="member">
	<cfscript>
		init();
		variables.searchFields=[];
		variables.inquiryFirstDate = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");

		form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
		params=[];
		if(form.searchOn EQ 1){
			arrayAppend(params, "searchOn=#form.searchOn#");
		} 
	 	for(group in variables.searchFields){
	 		if(structkeyexists(group, 'fields')){
			 	for(field in group.fields){
			 		form[field.field]=application.zcore.functions.zso(form, field.field); 
					if(form.searchOn EQ 1){
	 					arrayAppend(params, "#field.field#=#urlencodedformat(form[field.field])#");
	 				}
			 	}
			}
		}
	 	currentLink=application.zcore.functions.zURLAppend(request.zos.originalURL, arrayToList(params, "&"));

		if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
			form.inquiries_start_date=variables.inquiryFirstDate; 
		}
		if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
			form.inquiries_end_date=dateFormat(now(), "yyyy-mm-dd"); 
		}
		if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
			form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
			form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
		}
		var db=request.zos.queryObject; 
		arrayAppend(variables.searchFields, {
			groupStyle:'width:280px; max-width:100%; ',
			fields:[{
				label:"Start",
				formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			},{
				label:"End",
				formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
				field:"",
				labelStyle:'width:160px;',
				fieldStyle:'width:200px;'
			}
			]
		});
		db.sql = "SELECT ga_month_channel_source_goal_source  AS Source, SUM(ga_month_channel_source_goal_sessions) AS Sessions, SUM(ga_month_channel_source_goal_conversion_rate)  AS GoalConversionRate,  
					SUM(ga_month_channel_source_goal_conversions) AS GoalCompletions
					FROM #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)#
					WHERE ga_month_channel_source_goal_deleted = #db.param(0)# AND site_id = #db.param(request.zos.globals.id)# AND  ";
		if(form.inquiries_start_date EQ false){
			db.sql &= " (ga_month_channel_source_goal_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
		}else{
			db.sql&=" (ga_month_channel_source_goal_date >=  #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			 ga_month_channel_source_goal_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
		}
	    db.sql &= " AND ga_month_channel_source_goal_channel = #db.param('Referral')# GROUP BY ga_month_channel_source_goal_source ORDER BY Sessions DESC LIMIT #db.param(10)#";
	    var theData1 			= db.execute("theData1");
	    var totalSessions 		= 0;
	    var totalCRate			= 0;
	    var totalCompletions	= 0;
	    for(var x in theData1){
	    	totalSessions 		+= x.Sessions;
	    	totalCompletions	+= x.GoalCompletions;
		}
	</cfscript>
	<style>
		th{
			background-color: ##000000;
			color:##FFFFFF;
			text-align:left;
			font-weight:bold;
		}
	</style>
	<h2>Top Ten (10)</h2>
	<cfif arraylen(variables.searchFields)>
		<div class="z-float">
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 0>active</cfif>" data-tab="" data-click-location="#request.zos.originalURL#">All Data</a>
			<a href="##" class="z-manager-list-tab-button <cfif form.searchOn EQ 1>active</cfif>" data-tab="z-manager-search-fields"><div class="z-float-left">Search</div><div class="z-show-at-992 z-float-left">&nbsp;</div><div class="z-manager-list-tab-refine">Refine</div></a> 
		</div>
		<div class="z-manager-tab-container z-float" <cfif form.searchOn EQ 0>style="display:none;"</cfif>>
			<div class="z-manager-list-tab z-manager-search-fields <cfif form.searchOn EQ 1>active</cfif>">
				<form action="#currentLink#" method="get">
					<input type="hidden" name="searchOn" value="1">
					<cfscript>
					for(group in variables.searchFields){
						echo('<div class="z-manager-search-group"');
						if(structkeyexists(group, 'groupStyle')){
							echo(' style="#group.groupStyle#"');
						}
						echo('>');
						for(field in group.fields){

							echo('<div class="z-manager-search-field">');
							if(structkeyexists(field, 'label')){
								echo('<div class="z-manager-search-field-label"');
								if(structkeyexists(field, 'labelStyle')){
									echo(' style="#field.labelStyle#"');
								}
								echo('>#field.label#</div>');
							}
							echo('<div class="z-manager-search-field-form"');
							if(structkeyexists(field, 'fieldStyle')){
								echo(' style="#field.fieldStyle#"');
							}
							echo('>#field.formField#</div></div>');
						}
						echo('</div>');
					}
					</cfscript> 
					<div class="z-manager-search-submit">
						<input type="submit" name="submit1" class="z-manager-search-button" value="Submit">
					</div>
				</form>
			</div>
		</div>
	</cfif>
	<h3 style="color:##000000;padding-left:20px;text-align:center;">Top 10 Leads By Source</h3>
	<h4 style="color:##000000;padding-left:20px;text-align:center;">#DateFormat(form.inquiries_start_date,"MM/DD/YYYY")# - #DateFormat(form.inquiries_end_date,"MM/DD/YYYY")#</h4>
	<div style="font-size:16px;width:100%; height:800px;">
		<br />
		<div id="divTable" style="padding-top:10px; float:left;">
			<table style="width:90%;" border="2">
				<tr>
					<th>Source</th>
					<th>Sessions</th>
					<th>Goal Conversion Rate</th>
					<th>Goal Completions</th> 
				</tr>
				<cfloop query="theData1">
					<tr>
				    	<td>#theData1.Source#</td>
				    	<td>#NumberFormat(theData1.Sessions)# (#NumberFormat((theData1.Sessions/totalSessions)*100,"0.00")#%)</td>
				    	<td>#NumberFormat(theData1.GoalConversionRate, "0.0000")#%</td>
				    	<td>#NumberFormat(theData1.GoalCompletions)#  (#NumberFormat((theData1.GoalCompletions/totalCompletions)*100,"0.00")#%)</td>
					</tr>
				</cfloop>
			</table>
		<div>
	<div>
</cffunction>

<cffunction name="makeTableStat" localmode="modern" access="remote" roles="member">
	<cfargument name="achartData" type="array" required="yes">
	<cfargument name="acolumnData" type="array" required="yes">
	<cfargument name="anumBreaks" type="number" required="yes">
	<cfscript>
		var chartData 	= arguments.achartData;
		var	columnData 	= arguments.acolumnData;
		var numBreaks	= arguments.anumBreaks;

		for(var i=1; i <= arrayLen(chartData); i++){
			for(var j=1; j <= arrayLen(columnData); j++){
				if(columnData[j].Formula <> -1){
					columnData[j].Total += chartData[i][columnData[j].Column];
				}
			}
		}
		echo('<div style="width:100%; float:left">');
		for(var j=1; j <= arrayLen(columnData); j++){
			if(columnData[j].Show == 1){
				if(columnData[j].Formula <> -1){
					echo("<div style=""float:left; width:150px; height:50px;"">");
					if(columnData[j].Formula EQ 0){
						if(columnData[j].Format EQ -1){
							echo("<span><b>" & columnData[j].TableLabel & "</b></span><br />" & "<span>" & columnData[j].Total & "</span>");
						} else if(columnData[j].Format EQ 0 AND isNumeric(columnData[j].Total)){
							echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & numberFormat(columnData[j].Total, ",") & "<br />");
						} else if(columnData[j].Format EQ 1 AND isNumeric(columnData[j].Total)){
							echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & numberFormat(columnData[j].Total, ",.000") & "<br />");
						}
					} else {
						var formula = columnData[j].Formula;
						var iPos 	= Find("/",formula,1);
						if(iPos NEQ 0){
							var fc = Mid(formula,1,iPos-1);
							var sc = Mid(formula,iPos+1);
							//echo("The first is : " & fc & " <=> " & sc & "<br />"); 
							if(columnData[j].Format EQ -1){
								echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & columnData[fc].Total/columnData[sc].Total & "</span>");
							} else if(columnData[j].Format EQ 0){
								echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & numberFormat(columnData[fc].Total/columnData[sc].Total, ",") & "</span>");
							} else if(columnData[j].Format EQ 1){
								echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & numberFormat(columnData[fc].Total/columnData[sc].Total, ",.000") & "</span>");
							} else if(columnData[j].Format EQ 2){
								echo("<span><b>" & columnData[j].TableLabel  & "</b></span><br />" & "<span>" & numberFormat((columnData[fc].Total/columnData[sc].Total)*100, ",.00") & "%</span>");
							}
						}
					}
					echo("</div>");
					if(j mod numBreaks EQ 1){
						echo("<br style=""clear:both;"" />");
					}
				}
			}
		}
		echo('</div>'); 
		echo("<br />");
		echo("<table border=""2"" style=""width:1100px;""><tr>");
		for(var i=1; i <= arrayLen(columnData); i++){
			echo("<th>");
			echo(columnData[i].Label);
			echo("</th>");
		}
		echo("</tr>");
		for(var i=1; i <= arrayLen(chartData); i++){
			echo("<tr>");
			for(var j=1; j <= arrayLen(columnData); j++){
				echo("<td>");
				if(columnData[j].Format EQ -1){
					echo(chartData[i][columnData[j].Column]);
				} else if(columnData[j].Format EQ 0){
					echo(numberFormat(chartData[i][columnData[j].Column],","));
				} else if(columnData[j].Format EQ 1){
					echo(numberFormat(chartData[i][columnData[j].Column], ",.00"));
				} else if(columnData[j].Format EQ 2){
					echo(numberFormat(chartData[i][columnData[j].Column], ",.00") & "%");
				}
				echo("</td>");
			}
			echo("</tr>");
		}
		echo("</table>");
	</cfscript>
</cffunction>
<cffunction name="makePieChart" localmode="modern" access="remote" roles="member">
	<cfargument name="chartData" type="string" required="yes">
	<cfargument name="chartName" type="string" required="yes">
	<div style="width:900px;">
	<div style="float:left; padding-top:5px;"><svg id="#arguments.chartName#" width="380" height="380"></svg></div>
	<div id="#arguments.chartName#divPieLabels" style="padding-left:5px; padding-top:5px; float:left;"></div>
	<script>
		zArrDeferredFunctions.push(
		function(){
			var i				= 0;
			var data	 		= JSON.parse('#arguments.chartData#');
			var total 			= 0;
			var $divPieLabels 	= $("###arguments.chartName#divPieLabels");
			//var color = d3.scale.category20c();
			var arrColors 		= ["##058dc7", "##50b432", "##ed561b", "##edef00", "##24cbe5", "##d0743c", "##ff8c00", "##336600", "##DDDDDD"];
			var color 			= d3.scaleOrdinal(arrColors);	
			for(i=0; i < data.length; i++){
				total	+= data[i].amt;
				$divPieLabels.append("<div style=\"float:left; width:15px;background-color:" 
					+ arrColors[i] 
					+ "\">&nbsp;</div>&nbsp;&nbsp;&nbsp;<span style=\"font:16px  sans-serif;font-weight:bold;\">" 
					+ data[i].mrktType 
					+ "</span><br /><br />"); 		
			}
			var svg = d3.select("###arguments.chartName#"),
				width = 350 /*+svg.attr("width")*/,
				height = 350/*+svg.attr("height")*/,
				radius = Math.min(width, height) / 2.5,
				g = svg.append("g").attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

			
			var pie = d3.pie()
		    	.sort(null)
		    	.value(function(d) { return d.amt; });

			var path = d3.arc()
		    	.outerRadius(radius - 10)
		    	.innerRadius(0);

			var label = d3.arc()
		    	.outerRadius(radius + 20)
		    	.innerRadius(radius + 5);

			var arc = g.selectAll(".arc")
			.data(pie(data))
			.enter().append("g")
			  .attr("class", "arc");

			arc.append("path")
			  .attr("d", path)
			  .attr("fill", function(d) { return color(d.data.mrktType); 
			});
			arc.append("text")
			  .attr("transform", function(d) { return "translate(" + label.centroid(d) + ")"; })
			  .attr("dy", "0.35em")
			  .text(function(d) { 
			  	var amt 	= (100 * parseFloat(d.data.amt/total).toFixed(2)).toString();
			  	var iPos 	= amt.indexOf(".");
			  	if(iPos	!= -1){
			  		amt = amt.substr(0, iPos);
			  	}
			  	//return d.data.mrktType + " " + (amt) + " %"; 
			  	return " " + amt + "%"; 
			});
		});
	</script>
	</div>
</cffunction>
<cffunction name="makeBarGraph" localmode="modern" access="remote">
	<cfargument name="chartData" type="string" required="yes">
	<cfargument name="chartName" type="string" required="yes">
	<cfargument name="chartLabel" type="string" required="yes">

	<div style="float:left;">
		<svg id="#arguments.chartName#" width="500" height="400">
		</svg>
	</div>
	<script>
	function #arguments.chartName#loadLineCharts(){
		// parse the date / time
		var parseTime = d3.timeParse("%m/%d/%Y");

		var data	 = JSON.parse('#arguments.chartData#');
		for(var i=0;i<data.length;i++){
			data[i].elDia=parseTime(data[i].elDia);
		}
		data.sort(function(a,b) { return a.elDia - b.elDia; });
		var svg = d3.select("###arguments.chartName#"),
			margin = {top: 20, right: 20, bottom: 30, left: 50},
			width = +svg.attr("width") - margin.left - margin.right,
			height = +svg.attr("height") - margin.top - margin.bottom,
			g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		var x = d3.scaleTime()
		    .rangeRound([0, width])
		    .domain([data[0].elDia, data[data.length-1].elDia])
  			.range([0, 700]);

		var y = d3.scaleLinear()
			.rangeRound([height, 0]);
		var area = d3.area()
			.x(function(d) { return x(d.elDia); })
			.y1(function(d) { return y(d.close); });

		x.domain(d3.extent(data, function(d) { return d.elDia; }));
		y.domain([0, d3.max(data, function(d) { return d.close; })]);
		area.y0(y(0));
		g.append("path")
			.datum(data)
			.attr("fill", "rgba(0,68,175,1)")
			.attr("d", area);
		g.append("g")
			.attr("transform", "translate(0," + height + ")")
			.call(d3.axisBottom(x));
		g.append("g")
			.call(d3.axisLeft(y))
			.append("text")
			.attr("fill", "##000")
			.attr("transform", "rotate(-90)")
			.attr("y", 1)
			.attr("dy", "0.71em")
			.attr("text-anchor", "end")
			.text("#arguments.chartLabel#");
		/*var line = d3.line()
    		.x(function(d) { return x(d.elDia); })
    		.y(function(d) { return y(d.close); });
		g.append("path")
	      .datum(data)
	      .attr("fill", "none")
	      .attr("stroke", "steelblue")
	      .attr("stroke-linejoin", "round")
	      .attr("stroke-linecap", "round")
	      .attr("stroke-width", 1.5)
	      .attr("d", line);
	    */
	}
	zArrDeferredFunctions.push(function(){
		#arguments.chartName#loadLineCharts();
	});
	</script>
</cffunction>


</cfoutput>

</cfcomponent>
