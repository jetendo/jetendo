<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject; 
	setting requesttimeout="10000";
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Export");

	if(form.method EQ "userExport"){
		// allow export
	    inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	    inquiriesCom.userInit();
	}else if(application.zcore.user.checkGroupAccess("member") EQ false){
		application.zcore.functions.z404("Only manager members can export leads.");	
	}
	form.inquiries_priority=application.zcore.functions.zso(form, "inquiries_priority");
	form.search_keyword=application.zcore.functions.zso(form, "search_keyword");
	searchTextOriginal=replace(replace(replace(form.search_keyword, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	form.search_email=application.zcore.functions.zso(form, "search_email");
	form.search_phone=application.zcore.functions.zso(form, "search_phone");
	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(form.method EQ "userExport" and structkeyexists(request.zsession, 'selectedOfficeId')){
		form.search_office_id=request.zsession.selectedOfficeId;
	}
	form.format=application.zcore.functions.zso(form,'format',false,'csv');
	form.whichfields=application.zcore.functions.zso(form, 'whichfields',false,1);
	
	form.inquiries_start_date=application.zcore.functions.zso(form,'inquiries_start_date',false,createdatetime(2009,4,10,1,1,1));
	form.inquiries_end_date=application.zcore.functions.zso(form,'inquiries_end_date',false,now());
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	form.exporttype=application.zcore.functions.zso(form,'exporttype',false,'0');

	savecontent variable="exportOut"{
		if(form.format EQ 'html'){
			//header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-inquiries.html" charset="utf-8";
			writeoutput('#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title>#request.zos.globals.shortdomain#Inquiries Export</title>
			<style type="text/css">
			body {
				font-family:Arial, Helvetica, sans-serif;
				font-size:11px;
				line-height:14px;
			}
			.row2 td {
				background-color:##EEEEEE;
			}
			.header td {
				background-color:##336699;
				color:##FFF;
				font-weight:bold;
			}
			td {
				border-right:1px solid ##CCCCCC;
			}
			h1 {
				line-height:24px;
				font-size:18px;
			}
			</style>
			</head>
			
			<body>
			<h1>#request.zos.globals.shortdomain# Inquiries Export</h1>
			<table style="border-spacing:0px;border:1px solid ##CCCCCC;">');
		}
		request.znotemplate=1;



		db.sql="SELECT * FROM #db.table("track_user", request.zos.zcoreDatasource)# 
		WHERE track_user.site_id =#db.param(request.zOS.globals.id)# AND 
		track_user_deleted = #db.param(0)#";
		if(form.inquiries_start_date NEQ false){
			db.sql&=' and track_user_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# '; 
		}
		if(form.inquiries_end_date NEQ false){
			db.sql&=' and track_user_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')# '; 
		}
		qTrack=db.execute("qTrack");
		trackLookup={};
		for(row in qTrack){
			trackLookup[row.inquiries_id]=row;
			trackLookup[row.track_user_email&"|"&dateformat(row.track_user_datetime, 'yyyy-mm-dd')]=row;
		}
		qTrack=0; 

		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE 
		site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted=#db.param(0)#";
		qType=db.execute("qType");
		typeStruct={};
		for(row in qType){
			if(row.site_id EQ request.zos.globals.id){
				sid=1;
			}else{
				sid=4;
			}
			typeStruct[row.inquiries_type_id&"|"&sid]=row.inquiries_type_name;
		}
		fieldStruct={};
		customStruct={};
		sortStruct={};


		for(i2=1;i2 LTE 2;i2++){
			doffset=0;
			// first loop finds all the field names
			// second loop outputs the field names and data in alphabetic order
			if(i2 EQ 2){ 
				structdelete(fieldStruct, 'inquiries_datetime');
				structdelete(fieldStruct, 'inquiries_custom_json');
				structdelete(fieldStruct, 'inquiries_type_id');
				structdelete(fieldStruct, 'inquiries_type_id_siteIdType');
				structdelete(fieldStruct, 'inquiries_type_other');
				structdelete(fieldStruct, 'inquiries_deleted');
				structdelete(fieldStruct, 'inquiries_status_id');
				structdelete(fieldStruct, 'inquiries_assign_email');
				structdelete(fieldStruct, 'user_id');
				structdelete(fieldStruct, 'inquiries_updated_datetime');
				structdelete(fieldStruct, 'inquiries_readonly');
				structdelete(fieldStruct, 'inquiries_external_id');
				structdelete(fieldStruct, 'site_id');
				arrF=structkeyarray(fieldStruct);
				arrayAppend(arrF, 'zsource');
				arrF2=structkeyarray(customStruct);
				for(i3=1;i3 LTE arraylen(arrF2);i3++){
					arrayAppend(arrF, arrF2[i3]);
				}

				for(i3=1;i3 LTE arraylen(arrF);i3++){
					sortStruct[i3]={field:arrF[i3]};
				}
				arrFieldSort=structsort(sortStruct, "text", "asc", "field");
				
				if(form.whichfields EQ 1){
					if(form.format EQ 'html'){
						writeoutput('<tr class="header"><td>Type</td><td>Date Received</td>');
						for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
							c=sortStruct[arrFieldSort[i3]].field;
							f=replace(replace(c, 'inquiries_', ''), '_', ' ', 'all');
							echo('<td>'&f&'</td>');
						}
						echo('<td colspan="40">Associated Links</td></tr>'&chr(10));
					}else if(form.format EQ 'csv'){
						echo('"Type","Date Received",');
						for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){ 
							c=sortStruct[arrFieldSort[i3]].field;
							f=replace(replace(c, 'inquiries_', ''), '_', ' ', 'all');
							echo('"'&replace(f, '"', '', 'all')&'",');
						}
						echo('"Associated Links"'&chr(13)&chr(10));
					}  
				}
			}
			while(true){
				if(structkeyexists(form,'keywordexport')){
					savecontent variable="theSql"{
						writeoutput(' SELECT * 
						from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
						#db.table("track_user", request.zos.zcoreDatasource)# track_user 
						WHERE inquiries.inquiries_email = track_user.track_user_email AND 
						inquiries_deleted = #db.param(0)# and 
						track_user_deleted = #db.param(0)# and 
						inquiries.site_id = track_user.site_id AND
						track_user.site_id = #db.param(request.zos.globals.id)# AND 
						track_user_keywords <> #db.param('')# and 
						track_user_email <> #db.param('')# AND 
						(track_user_keywords LIKE #db.param('%#form.keywordsearch#%')# or 
						track_user_keywords LIKE #db.param('%#application.zcore.functions.zurlencode(form.keywordsearch,"%")#%')#) 
						and inquiries.inquiries_status_id <> #db.param(0)# 
						and inquiries.inquiries_spam = #db.param(0)# 
						and inquiries_parent_id = #db.param(0)#');
						if(form.search_office_id NEQ "0"){
							echo(' and inquiries.office_id = #db.param(form.search_office_id)# ');
						}
						if(form.method EQ "userExport"){
							echo(inquiriesCom.getUserLeadFilterSQL(db));
						}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
							writeoutput(' AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
							user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#');
						}
						if(form.search_phone NEQ ""){
							echo(" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ");
						}
						if(form.search_email NEQ ""){
							echo(" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ");
						}
						if(application.zcore.functions.zso(form, "inquiries_priority") NEQ ""){
							echo(" and inquiries_priority=#db.param(form.inquiries_priority)# ");
						}
						if(searchTextOriginal NEQ ''){
							echo(" and 
							(inquiries.inquiries_id = #db.param(searchTextOriginal)# or 
							MATCH(inquiries.inquiries_search) AGAINST (#db.param(form.search_keyword)#) 
							or inquiries.inquiries_search like #db.param('%#replace(form.search_keyword,' ','%','ALL')#%')# 
							) ");
						}
						if(form.selected_user_id NEQ 0){
							writeoutput(' and inquiries.user_id = #db.param(form.selected_user_id)# and 
							user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#');
						}
						if(form.inquiries_start_date EQ false){
							writeoutput(' and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
							inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
						}else{
							writeoutput(' and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
							inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
						}
						if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ ""){
							echo(' and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
							inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ');
						}
						if(application.zcore.functions.zso(form,'exporttype') EQ 1){
							writeoutput(' GROUP BY inquiries_email');
						}else if(application.zcore.functions.zso(form,'exporttype') EQ 2){
							writeoutput(' GROUP BY inquiries_phone1, inquiries_phone2');
						}
						writeoutput(' ORDER BY inquiries_datetime DESC');
					} 
				}else{ 
					savecontent variable="theSql"{
						writeoutput('SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries WHERE
						inquiries.site_id = #db.param(request.zOS.globals.id)# and 
						inquiries.inquiries_status_id <> #db.param(0)# and 
						inquiries_deleted = #db.param(0)# and 
						inquiries.inquiries_spam = #db.param(0)# and 
						inquiries_parent_id = #db.param(0)#');
						if(form.search_office_id NEQ "0"){
							echo(' and inquiries.office_id = #db.param(form.search_office_id)# ');
						} 
						if(form.search_phone NEQ ""){
							echo(" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ");
						}
						if(form.search_email NEQ ""){
							echo(" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ");
						}
						if(application.zcore.functions.zso(form, "inquiries_priority") NEQ ""){
							echo(" and inquiries_priority=#db.param(form.inquiries_priority)# ");
						}
						if(searchTextOriginal NEQ ''){
							echo(" and 
							(inquiries.inquiries_id = #db.param(searchTextOriginal)# or 
							MATCH(inquiries.inquiries_search) AGAINST (#db.param(form.search_keyword)#) 
							or inquiries.inquiries_search like #db.param('%#replace(form.search_keyword,' ','%','ALL')#%')# 
							) ");
						}
						if(form.method EQ "userExport"){ 
							echo(inquiriesCom.getUserLeadFilterSQL(db)); 
						}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
							writeoutput(' AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
							user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#');
						}
						if(form.selected_user_id NEQ 0){
							writeoutput(' and inquiries.user_id = #db.param(form.selected_user_id)# and 
							user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ');
						}
						if(application.zcore.functions.zso(form,'searchType',true) EQ 0){
							if(form.inquiries_start_date EQ false){
								writeoutput(' and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
								inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
							}else{
								writeoutput(' and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
								inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
							}
						}else{
							if(form.inquiries_start_date EQ false){
								writeoutput(' and (inquiries_start_date >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
								inquiries_end_date <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)');
							}else{
								writeoutput(' and (inquiries_start_date >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
								inquiries_end_date <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)');
							}
						}
						if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ ""){
							echo(' and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
							inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ');
						}
						if(application.zcore.functions.zso(form,'inquiries_name') NEQ ""){
							writeoutput(' and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')#');
						}
						if(isDefined('request.zsession.leadcontactfilter')){
							if(request.zsession.leadcontactfilter EQ 'new'){
								writeoutput(' and inquiries.inquiries_status_id =#db.param('1')#');
							}else if(request.zsession.leadcontactfilter EQ 'email'){
								writeoutput(' and inquiries_phone1 =#db.param('')# 	and inquiries_phone_time=#db.param('')#');
							}else if(request.zsession.leadcontactfilter EQ 'phone'){
								writeoutput(' and inquiries_phone1 <>#db.param('')# 	and inquiries_phone_time=#db.param('')#');
							}else if(request.zsession.leadcontactfilter EQ 'forced'){
								writeoutput(' and inquiries_phone_time<>#db.param('')#');
							}
						} 
						if(application.zcore.functions.zso(form, 'exporttype') EQ 1){
							writeoutput(' GROUP BY inquiries_email');
						}else if(application.zcore.functions.zso(form, 'exporttype') EQ 2){
							writeoutput(' GROUP BY inquiries_phone1, inquiries_phone2');
						}
						writeoutput(' ORDER BY inquiries_datetime DESC ');
					}
				}
				if(form.whichfields EQ 0){ 
					if(form.format EQ 'html'){ 
						echo('<tr class="header">'); 
						echo('<td>Type</td>');
						echo('<td>Date</td>'); 
						echo('<td>First Name</td>');
						echo('<td>Last Name</td>');
						echo('<td>Email</td>');
						echo('<td>Phone</td>');
						echo('<td>Phone 2</td>');
						echo('<td>Address</td>');
						echo('<td>City</td>');
						echo('<td>State</td>');
						echo('<td>Zip</td>');
						echo('<td>Country</td>');
						echo('<td>Company</td>');
						echo('</tr>'&chr(10));
					}else{
						echo('"Type",');
						echo('"Date",');
						echo('"First Name",');
						echo('"Last Name",');
						echo('"Email",');
						echo('"Phone",');
						echo('"Phone 2",');
						echo('"Address",');
						echo('"City",');
						echo('"State",');
						echo('"Zip",');
						echo('"Country",');
						echo('"Company",'); 
						echo(chr(13)&chr(10));
					} 
				}

				db.sql=theSQL&" LIMIT #db.param(doffset)#, #db.param(100)# ";
				qInquiries=db.execute("qInquiries");
				// writedump(qInquiries);abort;
				if(qInquiries.recordcount EQ 0){
					break;
				}
				doffset+=100;
				if(form.whichfields EQ 0){ 
					currentRow=1;
					for(row in qInquiries){
						tid=row.inquiries_type_id&"|"&row.inquiries_type_id_siteIDType;
						typeName="";
						if(structkeyexists(typeStruct, tid)){
							typeName=typeStruct[tid];
						} 
						dateTime=dateformat(row.inquiries_datetime, "m/dd/yyyy")&" "&Timeformat(row.inquiries_datetime, "h:mm tt");
						if(form.format EQ 'html'){
							if(currentrow MOD 2 EQ 0){
								echo('<tr class="row2">');
							}else{
								echo('<tr>');
							}
							echo('<td>#typeName#</td>');
							echo('<td>#dateTime#</td>');
							// typeName#</td><td>#dateTime
							echo('<td>'&row.inquiries_first_name&'</td>');
							echo('<td>'&row.inquiries_last_name&'</td>');
							echo('<td>'&row.inquiries_email&'</td>');
							echo('<td>'&row.inquiries_phone1&'</td>');
							echo('<td>'&row.inquiries_phone2&'</td>');
							echo('<td>'&row.inquiries_address&'</td>');
							echo('<td>'&row.inquiries_city&'</td>');
							echo('<td>'&row.inquiries_state&'</td>');
							echo('<td>'&row.inquiries_zip&'</td>');
							echo('<td>'&row.inquiries_country&'</td>');
							echo('<td>'&row.inquiries_company&'</td>');
							echo('</tr>'&chr(10));
						}else{
							echo('"'&replace(typeName, '"', '', 'all')&'",');
							echo('"'&replace(dateTime, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_first_name, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_last_name, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_email, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_phone1, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_phone2, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_address, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_city, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_state, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_zip, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_country, '"', '', 'all')&'",');
							echo('"'&replace(row.inquiries_company, '"', '', 'all')&'",'); 
							echo(chr(13)&chr(10));
						}
						currentRow++;
					}
					break;
				}else{
					if(i2 EQ 1){
						for(row in qInquiries){
							/*if(row.inquiries_custom_json EQ ""){
								continue;
							}*/

							for(n in row){
								if(row[n] NEQ "" and row[n] NEQ "0"){
									fieldStruct[n]="";
								}
							}
							if(row.inquiries_custom_json NEQ ""){
								j=deserializeJson(row.inquiries_custom_json);
								if(not isstruct(j)){
									j={arrCustom:[]};
								}
								if(structkeyexists(j, 'arrCustom')){
									for(n=1;n LTE arraylen(j.arrCustom);n++){
										r=j.arrCustom[n];
										if(r.value NEQ "" and r.value NEQ "0"){
											customStruct[r.label]="";
										}
									}
								}
							}
						}
					}else{
						currentRow=1;
						for(row in qInquiries){
							arrLink=arraynew(1);
							if(application.zcore.app.siteHasApp("content")){
								if(row.content_id NEQ 0 and row.content_id NEQ ""){
									arrF2n28=listtoarray(row.content_id);
									for(i328=1;i328 LTE arraylen(arrF2n28);i328++){
										arrayappend(arrLink,request.zos.currentHostName&"/c-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#arrF2n28[i328]#.html");
									}
								}
							}
							if(application.zcore.app.siteHasApp("listing") and row.property_id NEQ ''){
								arrP=listtoarray(row.property_id,',');
								for(i=1;i LTE arraylen(arrP);i++){
									arrI=listtoarray(arrP[i],'-');
									if(arraylen(arrI) EQ 2){
										urlMlsId=application.zcore.listingCom.getURLIdForMLS(arrI[1]);
										urlMLSPId=arrI[2];
										arrayappend(arrLink,request.zos.currentHostName&"/c-#urlMlsId#-#urlMLSPId#.html");
									}
								}
							}
							if(row.inquiries_referer NEQ "" and row.inquiries_referer DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
								arrayappend(arrLink,row.inquiries_referer);	
							}
							if(row.inquiries_referer2 NEQ "" and row.inquiries_referer2 DOES NOT CONTAIN request.zos.currentHostName&'/inquiry'){
								arrayappend(arrLink, row.inquiries_referer2);	
							}
							if(form.format EQ 'html'){
								for(i=1;i LTE arraylen(arrLink);i++){
									if(arrLink[i] NEQ ""){	
										arrLink[i]='<a href="#arrLink[i]#" target="_blank">Link #i#</a>';
									}
								}
							}
							tid=row.inquiries_type_id&"|"&row.inquiries_type_id_siteIDType;
							typeName="";
							if(structkeyexists(typeStruct, tid)){
								typeName=typeStruct[tid];
							} 
							dateTime=dateformat(row.inquiries_datetime, "m/dd/yyyy")&" "&Timeformat(row.inquiries_datetime, "h:mm tt");
							
							if(row.inquiries_custom_json NEQ ""){
								j=deserializeJson(row.inquiries_custom_json);
								j2={};
								for(i3=1;i3 LTE arraylen(j.arrCustom);i3++){
									j2[j.arrCustom[i3].label]=j.arrCustom[i3].value;
								}
								j=j2;
							}else{
								j={};
							}

							if(structkeyexists(trackLookup, row.inquiries_id)){
								// has track record
								j.zsource=trackLookup[row.inquiries_id].track_user_source;
							}else if(structkeyexists(trackLookup, row.inquiries_email&"|"&dateformat(row.inquiries_datetime, 'yyyy-mm-dd'))){
								j.zsource=trackLookup[row.inquiries_email&"|"&dateformat(row.inquiries_datetime, 'yyyy-mm-dd')].track_user_source;
							}else{
								j.zsource="";
							}


							if(form.format EQ 'html'){
								if(currentrow MOD 2 EQ 0){
									writeoutput('<tr class="row2">');
								}else{
									writeoutput('<tr>');
								}
								writeoutput('<td>#typeName#</td><td>#dateTime#</td>');
								for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
									c=sortStruct[arrFieldSort[i3]].field;
									if(structkeyexists(j, c)){
										v=j[c];
									}else if(structkeyexists(row, c)){
										v=row[c];
									}else{
										v="";
									} 
									v=left(replace(replace(replace(rereplace(v, '<.*?>', '', 'all'), chr(13), "", "all"), chr(10), " ", "all"), '"', "", 'all'), 100);
									if(v EQ ""){
										v="&nbsp;";
									}
									if(structkeyexists(j, c)){
										echo('<td>'&v&'</td>');
									}else if(structkeyexists(row, c)){
										echo('<td>'&v&'</td>');
									}else{
										echo('<td>&nbsp;</td>');
									} 
								}
								echo('<td>');
								loop from="1" to="#arraylen(arrLink)#" index="i"{
									if(i NEQ 1){
										echo(', ');
									}
									writeoutput('#arrLink[i]#');
								}
								echo('</td>');
								echo('</tr>'&chr(10));
							}else if(form.format EQ 'csv'){
								echo('"'&replace(typeName, '"', "", 'all')&'","'&dateTime&'",');
								for(i3=1;i3 LTE arraylen(arrFieldSort);i3++){
									c=sortStruct[arrFieldSort[i3]].field;
									if(structkeyexists(j, c)){
										v=j[c];
									}else if(structkeyexists(row, c)){
										v=row[c];
									}else{
										v="";
									} 
									v=left(replace(replace(replace(rereplace(v, '<.*?>', '', 'all'), chr(13), "", "all"), chr(10), " ", "all"), '"', "", 'all'), 100);
									if(i3 NEQ 1){
										echo(",");
									}
									echo('"'&v&'"');
								}
								echo(',"');
								loop from="1" to="#arraylen(arrLink)#" index="i"{
									if(i NEQ 1){
										echo(' | ');
									}
									writeoutput(arrLink[i]);
								}
								echo('"');
								echo(chr(13)&chr(10));
							} 
							currentRow++;
						}
					}
				}
			}
			if(form.whichfields EQ 0){
				break;
			}
		}  
		if(form.format EQ 'html'){
			writeoutput('</table></body></html>');
		}
	}
	if(form.format EQ 'csv'){
		header name="Content-Type" value="text/plain" charset="utf-8";
		header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-inquiries.csv" charset="utf-8";
	}else if(form.format EQ 'html'){
		header name="Content-Disposition" value="attachment; filename=#dateformat(now(), 'yyyy-mm-dd')#-inquiries.html" charset="utf-8";
	}
	echo(exportOut);
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>