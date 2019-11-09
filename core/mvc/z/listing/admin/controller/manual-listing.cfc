<!--- 
still need to exclude mls listing when it manual listing matches an active mls listing
	when manual listing overrides an mls listing, need to provide excludeMLSNumbers to all public searches - this id list should be cached in application scope so that the query is more simple.  it only changes when listings are insert/update or deleted.
still need to add all the meta data fields and photo display
 --->
<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var searchTextReg=0;
	var qMLS=0;
	var searchexactonly=0;
	var rs2=0;
	var qSite=0;
	var searchTextOReg=0;
	var searchtext=0;
	var ts=0;
	var arrSearch=0;
	var searchTextOriginal=0;
	var selectStruct=0;
	var arrImages=0;
	var manual_listingphoto99=0;
	application.zcore.functions.zSetPageHelpId("6.1");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Listings");
	</cfscript>
	<h2>Manage Manual Listings</h2>
	<p>To add a new listing, select the MLS association and click add listing</p>
	<p>
		<cfscript>
		db.sql="SELECT * FROM (#db.table("mls", request.zos.zcoreDatasource)# mls, 
			#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
			#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site) 
			WHERE mls.mls_id = app_x_mls.mls_id and 
			mls_deleted = #db.param(0)# and 
			app_x_mls_deleted = #db.param(0)# and 
			app_x_site_deleted = #db.param(0)# and 
			app_x_mls.site_id = app_x_site.site_id and 
			app_x_site.site_id=#db.param(request.zos.globals.id)#  AND 
			app_x_site.app_id=#db.param(11)#";
		qMLS=db.execute("qMLS");
		// get the primary mls id from app cache variable
		form.manual_listing_mls_id=application.zcore.app.getAppData("listing").sharedStruct.primaryMlsId;
		selectStruct = StructNew();
		selectStruct.name = "manual_listing_mls_id";
		selectStruct.query=qmls;
		selectStruct.queryLabelField="mls_name";
		selectStruct.queryValueField="mls_id";
		selectStruct.onChange="setMLSDiv();";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript>
		<a href="##" onclick="window.location.href='/z/listing/admin/manual-listing/add?manual_listing_mls_id='+document.getElementById('manual_listing_mls_id').value;">Add Listing</a> </p>
	<cfscript>
		var db=request.zos.queryObject;
		application.zcore.functions.zStatusHandler(request.zsid,true, false, form); 
		searchText=trim(application.zcore.functions.zso(form, 'searchText'));
		searchexactonly=application.zcore.functions.zso(form, 'searchexactonly',false,1);
		searchTextOriginal=replace(searchText, '"', '', "all");
		searchText=application.zcore.functions.zCleanSearchText(searchText, true);
		if(searchText NEQ "" and isNumeric(searchText) EQ false and len(searchText) LTE 2){
			application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
				application.zcore.functions.zRedirect("/z/listing/admin/manual-listing/index?zsid=#request.zsid#");
		}
		searchTextReg=rereplace(searchText,"[^A-Za-z0-9[[:white:]]]*",".","ALL");
		searchTextOReg=rereplace(searchTextOriginal,"[^A-Za-z0-9 ]*",".","ALL");
		
		Request.zScriptName2 = "/z/listing/admin/manual-listing/index?searchtext=#urlencodedformat(application.zcore.functions.zso(form, 'searchtext'))#&searchexactonly=#searchexactonly#";
		</cfscript> 
	<cfscript>
		
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="manual_listing.manual_listing_image_library_id";
	ts.count =  1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript>
	<cfsavecontent variable="db.sql"> SELECT *, 
	if(manual_listing.manual_listing_price = #db.param(0)#,#db.param(0.00)#,manual_listing.manual_listing_price) manual_listing_price2, 
	if(manual_listing.manual_listing_mls_number = #db.param('')#,#db.param('z')#,manual_listing.manual_listing_mls_number) manual_listing_mls_number2,
	<cfif searchtext NEQ ''>
	
		<cfif application.zcore.enableFullTextIndex>
		MATCH(manual_listing.manual_listing_search) AGAINST (#db.param(searchText)#) as score , 
		MATCH(manual_listing.manual_listing_search) AGAINST (#db.param(searchTextOriginal)#) as score2 , 
		</cfif>
		if(manual_listing.manual_listing_unique_id = #db.param(searchtext)#, #db.param(1)#,#db.param(0)#) matchingId, 
		#db.trustedSQL("if(concat(manual_listing.manual_listing_unique_id,' ', cast(manual_listing.manual_listing_price as char(11)),' ',manual_listing.manual_listing_address,' ',manual_listing.manual_listing_mls_number)")# like #db.param('%#searchTextOriginal#%')#,#db.param(1)#,#db.param(0)#) as matchPriceAddress, 
	</cfif>
	if(manual_listing.manual_listing_address = #db.param('')#,#db.param('z')#,manual_listing.manual_listing_address) manual_listing_address2
	#db.trustedSQL(rs2.select)# 
	FROM ( #db.table("manual_listing", request.zos.zcoreDatasource)# manual_listing ) 
	#db.trustedSQL(rs2.leftJoin)# 
	WHERE 
	manual_listing_deleted = #db.param(0)# and 
	manual_listing.site_id = #db.param(request.zos.globals.id)#
	<cfif searchtext NEQ ''>
		<cfif searchexactonly EQ 1>
			and (#db.trustedSQL("concat(manual_listing.manual_listing_title, ' ',manual_listing.manual_listing_unique_id,' ',cast(manual_listing.manual_listing_price as char(11)),' ',manual_listing.manual_listing_address,' ',manual_listing.manual_listing_mls_number")#) like #db.param('%#searchTextOriginal#%')# or 
			manual_listing.manual_listing_remarks like #db.param('%#searchTextOriginal#%')# )
		<cfelse>
			and 
			
			(#db.trustedSQL("concat(manual_listing.manual_listing_title, ' ',manual_listing.manual_listing_unique_id,' ',cast(manual_listing.manual_listing_price as char(11)),' ',manual_listing.manual_listing_address,' ',manual_listing.manual_listing_mls_number)")# like #db.param('%#searchTextOriginal#%')# or 
			(
			((
			<cfif application.zcore.enableFullTextIndex>
				MATCH(manual_listing.manual_listing_search) AGAINST (#db.param(searchText)#) or 
				MATCH(manual_listing.manual_listing_search) AGAINST (#db.param('+#replace(searchText,' ','* +','ALL')#*')# IN BOOLEAN MODE)
			<cfelse>
				manual_listing.manual_listing_search like #db.param('%#replace(searchText,' ','%','ALL')#%')#
			</cfif>
			) or (
			<cfif application.zcore.enableFullTextIndex>
				MATCH(manual_listing.manual_listing_search) AGAINST (#db.param(searchTextOriginal)#) or 
				MATCH(manual_listing.manual_listing_search) AGAINST (#db.param('+#replace(searchTextOriginal,' ','* +','ALL')#*')# IN BOOLEAN MODE)
			<cfelse>
				manual_listing.manual_listing_search like #db.param('%#replace(searchTextOriginal,' ','%','ALL')#%')#
			</cfif>
			)) 
			))
		</cfif>
	</cfif>
	GROUP BY manual_listing.manual_listing_unique_id 
	ORDER BY
	<cfif searchtext NEQ ''>
		matchPriceAddress DESC ,matchingId DESC
		<cfif application.zcore.enableFullTextIndex>
			,score2 DESC, score DESC
		</cfif>
		,
	</cfif>
	manual_listing.manual_listing_created_datetime DESC, manual_listing.manual_listing_created_datetime DESC </cfsavecontent>
	<cfscript>
	
		qSite=db.execute("qSite"); 
		searchText=searchTextOriginal;
		 </cfscript>
	<script>
		 function domanual_listingSearch(){
			 window.location.href='/z/listing/admin/manual-listing/index?searchtext='+escape(document.getElementById('searchtext').value);
		 }
		 </script>
	<form name="myForm22" action="/z/listing/admin/manual-listing/index" method="GET" style="margin:0px;">
		<input type="hidden" name="method" value="list" />
		<table style="width:100%; border-spacing:0px; border:1px solid ##CCCCCC;" class="table-list">
			<tr>
				<td>Search By ID, Title, Address, MLS ## or any other text:
					<input type="text" name="searchtext" id="searchtext" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" size="20" maxchars="10">
					&nbsp;
					<input type="button" name="searchForm" value="Search" class="z-manager-search-button" onclick="domanual_listingSearch();" />
					|
					<cfif application.zcore.functions.zso(form, 'searchtext') NEQ ''>
						<input type="button" name="searchForm2" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/listing/admin/manual-listing/index';">
					</cfif>
					<input type="hidden" name="zIndex" value="1"></td>
			</tr>
		</table>
	</form><br />
	<cfif not structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct, '0') or application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[0].app_x_mls_url_id EQ "">
		<h2>Manual listings haven't been enabled for this web site.  Contact the web developer about this feature.</h2>
	<cfelseif qSite.recordcount EQ 0>
		<br />
		No listing added yet.
	<cfelse>
		<cfscript>
		arrSearch=listtoarray(searchtext," ");
		if(arraylen(arrSearch) EQ 0){
			arrSearch[1]="";	
		}			
		</cfscript>
		<cfif qSite.recordcount NEQ 0>
			<table style="border-spacing:0px; width:100%;" class="table-list">
				<tr>
					<th>ID</th>
					<th>Photo</th>
					<th>Title / Address / MLS ## / Price</th>
					<th>Admin</th>
				</tr>
				<cfloop query="qSite">
					<cfscript>
			
						ts=structnew();
						ts.image_library_id=qSite.manual_listing_image_library_id;
						ts.output=false;
						ts.query=qsite;
						ts.row=qsite.currentrow;
						ts.size="100x70";
						ts.crop=1;
						ts.count = 1; // how many images to get
						//application.zcore.functions.zdump(ts);
						arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
						manual_listingphoto99=""; 
						if(arraylen(arrImages) NEQ 0){
						manual_listingphoto99=(arrImages[1].link);
						}
						</cfscript>
					<tr <cfif qsite.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
						<td style="vertical-align:top; width:30px; ">#qSite.manual_listing_unique_id#</td>
						<td style="vertical-align:top; width:100px; "><cfif manual_listingphoto99 NEQ "">
								<img alt="Image" src="#request.zos.currentHostName&manual_listingphoto99#" style="max-width:100%;" /></a>
								<cfelse>
								&nbsp;
							</cfif></td>
						<td style="vertical-align:top; ">#qSite.manual_listing_title# <br />
							<cfif qSite.manual_listing_address NEQ ''>
								#qSite.manual_listing_address# |
							</cfif>
							<cfif qSite.manual_listing_mls_number CONTAINS '-'>
								MLS ##:#listgetat(qSite.manual_listing_mls_number,2,"-")# |
							</cfif>
							<cfif qSite.manual_listing_price NEQ 0>
								#DollarFormat(qSite.manual_listing_price)#
							</cfif>
							<br />
							<span style="color:##999; font-size:11px;">
							Status / Type
							
							| Updated #dateformat(qSite.manual_listing_updated_datetime,"m/d/yy")&" at "&timeformat(qSite.manual_listing_updated_datetime,"h:mm tt")# </span>
							</td>
						<td style="vertical-align:top; "><a href="/#application.zcore.functions.zURLEncode(qSite.manual_listing_title,"-")#-#application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[0].app_x_mls_url_id#-#qSite.manual_listing_unique_id#.html" target="_blank">View</a> | 
						<a href="/z/listing/admin/manual-listing/edit?manual_listing_mls_id=#qSite.manual_listing_mls_id#&amp;manual_listing_unique_id=#qSite.manual_listing_unique_id#&amp;return=1">Edit</a>
							| <a href="/z/listing/admin/manual-listing/delete?manual_listing_unique_id=#qSite.manual_listing_unique_id#&amp;return=1">Delete</a></td>
					</tr>
				</cfloop>
			</table>
		</cfif>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Listings", true);
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "manual_listing_return"&form.manual_listing_unique_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * FROM #db.table("manual_listing", request.zos.zcoreDatasource)# manual_listing 
	WHERE manual_listing_unique_id = #db.param(form.manual_listing_unique_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	manual_listing_deleted = #db.param(0)# ";
	qCheck=db.execute("qCheck"); 
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'You don''t have permission to delete this manual_listing.',false,true);
		if(isDefined('request.zsession.manual_listing_return'&form.manual_listing_unique_id)){
			tempURL = request.zsession['manual_listing_return'&form.manual_listing_unique_id];
			StructDelete(request.zsession, 'manual_listing_return'&form.manual_listing_unique_id);
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/index?zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.site_id=request.zos.globals.id;
		local.siteIDPadded=numberFormat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString);
		db.sql="delete from #db.table("listing", request.zos.zcoreDatasource)# 
		WHERE listing_id=#db.param('0-'&form.manual_listing_unique_id&local.siteIDPadded)#";
		db.execute("q");
		db.sql="delete from #db.table("listing_track", request.zos.zcoreDatasource)# 
		WHERE listing_id=#db.param('0-'&form.manual_listing_unique_id&local.siteIDPadded)#";
		db.execute("q");
		db.sql="delete from #db.table("listing_data", request.zos.zcoreDatasource)# 
		WHERE listing_id=#db.param('0-'&form.manual_listing_unique_id&local.siteIDPadded)#";
		db.execute("q");
		db.sql="delete from #db.table("manual_listing", request.zos.zcoreDatasource)# 
		WHERE manual_listing_unique_id=#db.param(form.manual_listing_unique_id)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("q");
		application.zcore.status.setStatus(request.zsid, 'Listing deleted.');
		application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this listing?<br />
			<br />
			ID: #qCheck.manual_listing_unique_id#<br />
			Title: #qCheck.manual_listing_title# <br />
			<br />
			<a href="/z/listing/admin/manual-listing/delete?confirm=1&amp;manual_listing_unique_id=#form.manual_listing_unique_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#application.zcore.functions.zso(request.zsession, 'manual_listing_return'&form.manual_listing_unique_id)#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
		this.update();
		</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var datastruct=0;
	var optionstruct=0;
	var ts=0;
	var i=0;
	var qCheck=0;
	var qP=0;
	var qTrackId=0;
	var myForm=structnew();
	var qManual=0;
	var errors=0;
	var tempURL=0;
	var qUpdate=0;
	var db=request.zos.queryObject;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Listings", true);
	form.manual_listing_created_datetime = application.zcore.functions.zGetDateSelect("manual_listing_created_datetime");
	if(structkeyexists(form, 'manual_listing_created_datetime') and form.manual_listing_created_datetime NEQ false){
		if(isdate(form.manual_listing_created_datetime) EQ false or (form.manual_listing_created_datetime NEQ '' and isdate(form.manual_listing_created_datetime) EQ false)){		
			application.zcore.status.setStatus(request.zsid, 'Invalid Time Format.  Please format like 1:30 pm',form,true);
			if(form.method EQ "update"){
				application.zcore.functions.zRedirect("/z/listing/admin/manual-listing/edit?manual_listing_mls_id=#form.manual_listing_mls_id#&manual_listing_unique_id=#form.manual_listing_unique_id#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/listing/admin/manual-listing/add?manual_listing_mls_id=#form.manual_listing_mls_id#&zsid="&request.zsid);
			}
		}else{
			form.manual_listing_created_datetime=parsedatetime(dateformat(form.manual_listing_created_datetime,'yyyy-mm-dd')&' '&Timeformat(form.manual_listing_created_datetime,'HH:mm:ss'));
			form.manual_listing_created_datetime=DateFormat(form.manual_listing_created_datetime,'yyyy-mm-dd')&' '&Timeformat(form.manual_listing_created_datetime,'HH:mm:ss');
		}
	}
	if(form.method EQ "update"){
		db.sql="select * from #db.table("manual_listing", request.zos.zcoreDatasource)# where site_id = #db.param(request.zos.globals.id)# and manual_listing_unique_id=#db.param(form.manual_listing_unique_id)# and 
		manual_listing_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");	
	}
	
	myForm.manual_listing_metakey.allowNull=true;
	myForm.manual_listing_metadesc.allowNull=true;
	myForm.manual_listing_title.required=true;
	myForm.manual_listing_title.friendlyName="Title";
	myForm.manual_listing_metakey.html=true;
	myForm.manual_listing_metadesc.html=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		application.zcore.status.setStatus(request.zsid,false,form,true);
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/listing/admin/manual-listing/edit?manual_listing_mls_id=#form.manual_listing_mls_id#&manual_listing_unique_id=#form.manual_listing_unique_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/listing/admin/manual-listing/add?manual_listing_mls_id=#form.manual_listing_mls_id#&zsid="&request.zsid);
		}
	}
	if(trim(application.zcore.functions.zso(form, 'manual_listing_metakey')) EQ ""){
		form.manual_listing_metakey=replace(replace(form.manual_listing_title,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'manual_listing_metadesc')) EQ ""){
		form.manual_listing_metadesc=left(replace(replace(rereplacenocase(trim(form.manual_listing_remarks),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	if(form.method EQ "update"){
		if(application.zcore.functions.zso(form, 'manual_listing_metakey') EQ qCheck.manual_listing_metakey and qCheck.manual_listing_metakey NEQ ""){
			if(replace(replace(qCheck.manual_listing_title,"|"," ","ALL"),","," ","ALL") EQ qCheck.manual_listing_metakey){
				form.manual_listing_metakey=replace(replace(form.manual_listing_title,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'manual_listing_metadesc') EQ qCheck.manual_listing_metadesc and qCheck.manual_listing_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(trim(qcheck.manual_listing_remarks),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.manual_listing_metakey){
				form.manual_listing_metadesc=left(replace(replace(rereplacenocase(trim(form.manual_listing_remarks),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
	}
	if(application.zcore.functions.zso(form, 'manual_listing_mls_number') NEQ '' and application.zcore.functions.zso(form, 'manual_listing_mls_id') NEQ '' and application.zcore.functions.zso(form, 'manual_listing_mls_price') NEQ ''){
		form.manual_listing_mls_number=form.manual_listing_mls_id&"-"&form.manual_listing_mls_number;
		if(form.manual_listing_mls_number NEQ '' and form.manual_listing_mls_price EQ 1){
			 db.sql="select listing_price,listing_longitude,listing_latitude 
			 from #db.table("listing", request.zos.zcoreDatasource)# listing 
			WHERE listing_id = #db.param(form.manual_listing_mls_number)#";
			qP=db.execute("qP");
			if(qP.recordcount NEQ 0){
				form.manual_listing_price=qP.listing_price;
				if(qP.listing_longitude NEQ ""){
					form.manual_listing_latitude=qP.listing_latitude;
					form.manual_listing_longitude=qP.listing_longitude;	
				}
			}
		}
	}else{
		//form.manual_listing_mls_id="";
		form.manual_listing_mls_number="";
	}

	ts=StructNew();
	ts.table="manual_listing";
	form.site_id=request.zos.globals.id;
	ts.struct=form;
	ts.datasource="#request.zos.zcoreDatasource#";
	form.manual_listing_updated_datetime=request.zos.mysqlnow;
	if(form.method EQ 'insert'){ 
		form.manual_listing_created_datetime = form.manual_listing_updated_datetime;
		form.manual_listing_unique_id = application.zcore.functions.zInsert(ts); 
		if(form.manual_listing_unique_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Listing with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/add?manual_listing_mls_id=#form.manual_listing_mls_id#&zsid=#request.zsid#');
		}
		form.manual_listing_id="0-"&form.manual_listing_unique_id&numberFormat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString);
		db.sql="update #db.table("manual_listing", request.zos.zcoreDatasource)# set 
		manual_listing_id=#db.param(form.manual_listing_id)#,
		manual_listing_updated_datetime=#db.param(request.zos.mysqlnow)# 
		 where 
		manual_listing_unique_id=#db.param(form.manual_listing_unique_id)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qUpdate=db.execute("qUpdate");
	}else{
		form.manual_listing_id="0-"&form.manual_listing_unique_id&numberFormat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString);
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Listing with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/edit?manual_listing_mls_id=#form.manual_listing_mls_id#&zsid=#request.zsid#&manual_listing_unique_id=#form.manual_listing_unique_id#');
		}
	}
	
	datastruct=structnew();
	optionstruct=structnew();
	
	db.sql="select * from #db.table("manual_listing", request.zos.zcoreDatasource)#
	where manual_listing_unique_id = #db.param(form.manual_listing_unique_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	manual_listing_deleted = #db.param(0)#";
	qManual=db.execute("qManual");
	application.zcore.functions.zQueryToStruct(qManual, form);
	form.manual_listing_updated_datetime=dateformat(form.manual_listing_updated_datetime, 'yyyy-mm-dd')&' '&timeformat(form.manual_listing_updated_datetime, 'HH:mm:ss');
	form.manual_listing_created_datetime=dateformat(form.manual_listing_created_datetime, 'yyyy-mm-dd')&' '&timeformat(form.manual_listing_created_datetime, 'HH:mm:ss');
	db.sql="select * from #db.table("listing_track", request.zos.zcoreDatasource)#
	where listing_id = #db.param(form.manual_listing_unique_id)# and 
	listing_track_deleted = #db.param(0)# and 
	listing_track_inactive = #db.param(0)#";
	qTrackId=db.execute("qTrackId");
	if(qTrackId.recordcount NEQ 0){
		form.listing_track_id=qTrackId.listing_track_id;
		form.listing_track_datetime=form.manual_listing_updated_datetime;
	}else{
		form.listing_track_datetime=form.manual_listing_created_datetime;
		form.listing_track_id="null";
	}
	form.listing_track_price=application.zcore.functions.zso(form,'manual_listing_price');
	form.listing_track_price_change=application.zcore.functions.zso(form,'manual_listing_price');
	form.listing_track_hash="";
	form.listing_track_deleted="0";
	form.listing_track_inactive = "0";
	form.listing_track_updated_datetime=form.manual_listing_updated_datetime;
	form.listing_track_processed_datetime=form.manual_listing_updated_datetime;
	
	application.zcore.listingStruct.mlsComObjects[0].baseInitImport(application.zcore.listingStruct.mlsStruct[0].sharedStruct);
	local.rs=application.zcore.listingStruct.mlsComObjects[0].parseRawData(form);
	structappend(form, local.rs, true);
	local.idxCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.idx");
	form.mls_id=0;
	
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'manual_listing_image_library_id'));
	
	if(form.method EQ 'insert'){
		application.zcore.status.setStatus(request.zsid, "Listing added.");
		if(isDefined('request.zsession.manual_listing_return')){
			tempURL = request.zsession['manual_listing_return'];
			StructDelete(request.zsession, 'manual_listing_return');
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Listing updated.");
	}
	if(structkeyexists(form, 'manual_listing_unique_id') and isDefined('request.zsession.manual_listing_return'&form.manual_listing_unique_id)){// and uniqueChanged EQ false){	
		tempURL = request.zsession['manual_listing_return'&form.manual_listing_unique_id];
		StructDelete(request.zsession, 'manual_listing_return'&form.manual_listing_unique_id);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/index?zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
		this.edit();
		</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
		var local={};
		var currentMethod=form.method;
		var db=request.zos.queryObject;
		var qmanual_listing=0;
		var htmlEditor=0;
		var cancelURL=0;
		var tabCom=0;
		var ts=0;
		var newAction=0; 
		application.zcore.functions.zSetPageHelpId("6.2");
  		application.zcore.adminSecurityFilter.requireFeatureAccess("Listings");
		form.manual_listing_unique_id=application.zcore.functions.zso(form, 'manual_listing_unique_id');
		if(currentMethod EQ "add"){
			application.zcore.template.appendTag('meta','<script>/* <![CDATA[ */ var zDisableBackButton=true; /* ]]> */</script>');
		}
		
		db.sql="SELECT * FROM #db.table("manual_listing", request.zos.zcoreDatasource)# manual_listing 
		WHERE manual_listing_unique_id = #db.param(form.manual_listing_unique_id)# and 
		manual_listing_deleted = #db.param(0)# and 
		manual_listing.site_id = #db.param(request.zos.globals.id)#";
		qmanual_listing=db.execute("qmanual_listing");
		if(currentMethod EQ 'edit'){
			if(qmanual_listing.recordcount EQ 0){
				application.zcore.status.setStatus(request.zsid, 'Listing doesn''t exist.',false,true);
				application.zcore.functions.zRedirect('/z/listing/admin/manual-listing/index?zsid=#request.zsid#');
			}
		}
		db.sql="SELECT * FROM (#db.table("mls", request.zos.zcoreDatasource)# mls, 
			#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
			#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site) 
			WHERE mls.mls_id = app_x_mls.mls_id and 
			mls_deleted = #db.param(0)# and 
			app_x_mls_deleted = #db.param(0)# and 
			app_x_mls.site_id = app_x_site.site_id and 
			app_x_site.site_id=#db.param(request.zos.globals.id)#  AND 
			app_x_site.app_id=#db.param(11)# and mls.mls_id = #db.param(application.zcore.functions.zso(form,'manual_listing_mls_id'))#";
		local.qMLS=db.execute("qMLS");
		if(local.qMLS.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Select a valid MLS asscoation.");
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=index&zsid=#request.zsid#");
		}
		local.curMLSId=form.manual_listing_mls_id;
		
		application.zcore.functions.zQueryToStruct(qmanual_listing, form,'manual_listing_unique_id,site_id,');
		application.zcore.functions.zStatusHandler(request.zsid,true, false, form);
		if(application.zcore.status.getErrorCount(request.zsid) NEQ 0){
			form.manual_listing_created_datetime = application.zcore.functions.zGetDateSelect("manual_listing_created_datetime");	
		}
		if(structkeyexists(form, 'return')){
			StructInsert(request.zsession, "manual_listing_return"&form.manual_listing_unique_id, request.zos.CGI.HTTP_REFERER, true);		
		}
		</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif>
		Listing</h2>
	<cfscript>
		//application.zcore.functions.zdump(application.zcore.status.getStruct(form.searchid));
		ts=StructNew();
		ts.name="zMLSSearchForm";
		ts.ajax=false;
		if(currentMethod EQ 'add'){
			newAction="insert";
		}else{
			newAction="update";
		}
		ts.enctype="multipart/form-data";
		ts.action="/z/listing/admin/manual-listing/#newAction#?manual_listing_unique_id=#form.manual_listing_unique_id#&manual_listing_mls_id=#local.curMLSID#";
		ts.method="post";
		ts.class="zFormCheckDirty";
		ts.successMessage=false;
		application.zcore.functions.zForm(ts);
		
		
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic"]);//,"Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-manual_listing-edit");
		cancelURL=application.zcore.functions.zso(request.zsession, 'manual_listing_return'&form.manual_listing_unique_id);
		if(cancelURL EQ ""){
			cancelURL="/z/listing/admin/manual-listing/index";
		}
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
#tabCom.beginTabMenu()# #tabCom.beginFieldSet("Basic")#
	<!--- <input type="hidden" name="manual_listing_mls_id" id="manual_listing_mls_id" value="#local.curMLSID#" /> --->
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="vertical-align:top; "> #application.zcore.functions.zOutputHelpToolTip("Title","member.listing.manual_listing.edit manual_listing_title")# </th>
			<td style="vertical-align:top; "><input type="text" name="manual_listing_title" value="#HTMLEditFormat(form.manual_listing_title)#" maxlength="150" size="100" /> *</td>
		</tr>
		<tr>
			<th style="vertical-align:top; "> #application.zcore.functions.zOutputHelpToolTip("Remarks","member.listing.manual_listing.edit manual_listing_remarks")#</th>
			<td style="vertical-align:top; "><cfscript>
				
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "manual_listing_remarks";
				htmlEditor.value			= form.manual_listing_remarks;
					htmlEditor.basePath		= '/';
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 400;
				htmlEditor.create();
				
				</cfscript></td>
		</tr>
		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.listing.manual_listing.edit manual_listing_image_library_id")#</th>
			<td><cfscript>
			ts=structnew();
			ts.name="manual_listing_image_library_id";
			ts.value=form.manual_listing_image_library_id;
			application.zcore.imageLibraryCom.getLibraryForm(ts);
			</cfscript></td>
		</tr>
		<tr>
			<th style="vertical-align:top;"> #application.zcore.functions.zOutputHelpToolTip("Use MLS Price?","member.listing.manual_listing.edit manual_listing_mls_price")#</th>
			<td style="vertical-align:top; "><input type="radio" name="manual_listing_mls_price" onclick="setPrice(1);" value="1" <cfif application.zcore.functions.zso(form, 'manual_listing_mls_price') EQ 1 or application.zcore.functions.zso(form, 'manual_listing_mls_price') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				Yes
				<input type="radio" name="manual_listing_mls_price" onclick="setPrice(0);" value="0" <cfif application.zcore.functions.zso(form, 'manual_listing_mls_price') EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
				No </td>
		</tr>
		<tr>
			<th style="vertical-align:top;"> #application.zcore.functions.zOutputHelpToolTip("Your Office Listing?","member.listing.manual_listing.edit manual_listing_office")#</th>
			<td style="vertical-align:top; "><input type="radio" name="manual_listing_office" value="1" <cfif application.zcore.functions.zso(form, 'manual_listing_office') EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
				Yes
				<input type="radio" name="manual_listing_office" value="0" <cfif application.zcore.functions.zso(form, 'manual_listing_office') EQ 0 or application.zcore.functions.zso(form, 'manual_listing_office') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				No </td>
		</tr>
		<tr>
			<th style="vertical-align:top;"> #application.zcore.functions.zOutputHelpToolTip("Your Agent Listing?","member.listing.manual_listing.edit manual_listing_agent")#</th>
			<td style="vertical-align:top; "><input type="radio" name="manual_listing_agent" value="1" <cfif application.zcore.functions.zso(form, 'manual_listing_agent') EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
				Yes
				<input type="radio" name="manual_listing_agent" value="0" <cfif application.zcore.functions.zso(form, 'manual_listing_agent') EQ 0 or application.zcore.functions.zso(form, 'manual_listing_agent') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				No </td>
		</tr>
		<tr>
			<th style="vertical-align:top;"> #application.zcore.functions.zOutputHelpToolTip("Override MLS?","member.listing.manual_listing.edit manual_listing_mls_override")#</th>
			<td style="vertical-align:top; "><input type="radio" name="manual_listing_mls_override" value="1" <cfif application.zcore.functions.zso(form, 'manual_listing_mls_override') EQ 1 or application.zcore.functions.zso(form, 'manual_listing_mls_override') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				Yes, show instead of MLS information.
				<input type="radio" name="manual_listing_mls_override" value="0" <cfif application.zcore.functions.zso(form, 'manual_listing_mls_override') EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
				No, show MLS info only. </td>
		</tr>
		<!--- 
			<tr id="priceTD"><th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Price","member.listing.manual_listing.edit manual_listing_price")#</th>
			<td><input type="text" name="manual_listing_price" value="<cfif form.manual_listing_price NEQ 0>#HTMLEditFormat(form.manual_listing_price)#</cfif>" size="15" />
			
			<script>
			/* <![CDATA[ */<cfif application.zcore.functions.zso(form, 'manual_listing_mls_price') EQ 1 or application.zcore.functions.zso(form, 'manual_listing_mls_price') EQ ''>setPrice(1);<cfelse>setPrice(0);</cfif>/* ]]> */
			</script>
			</td>
			</tr>
			<tr>
			<th style="vertical-align:top;">
			
			#application.zcore.functions.zOutputHelpToolTip("Beds","member.listing.manual_listing.edit manual_listing_beds")#</th><td>
			  <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "manual_listing_beds";
				selectStruct.selectedValues=form.manual_listing_beds;
				selectStruct.selectLabel = "Any";
				selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
				application.zcore.functions.zInputSelectBox(selectStruct);
			  </cfscript>
			  </td></tr>
			  <tr><th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Baths","member.listing.manual_listing.edit manual_listing_baths")#</th><td>
			  <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "manual_listing_baths";
				selectStruct.selectedValues=form.manual_listing_baths;
				selectStruct.selectLabel = "Any";
				selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
				application.zcore.functions.zInputSelectBox(selectStruct);
			  </cfscript>
			  </td></tr>
			  <tr><th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Half Baths","member.listing.manual_listing.edit manual_listing_halfbaths")#</th><td>
			  <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "manual_listing_halfbaths";
				selectStruct.selectedValues=form.manual_listing_halfbaths;
				selectStruct.selectLabel = "Any";
				selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
				application.zcore.functions.zInputSelectBox(selectStruct);
			  </cfscript>
			  </td></tr>
			  <tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Square Feet","member.listing.manual_listing.edit manual_listing_square_feet")#</th><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "manual_listing_square_feet";
		selectStruct.selectedValues=form.manual_listing_square_feet;
		selectStruct.selectLabel = "-- Select --";
		selectStruct.listLabels="< 1000,1000 - 1500,1500 - 2000,2000 - 2500,2500 - 3000,3000 - 3500,3500 - 4000,4000 - 4500,4500 - 5000,5000 - 6000,6000 - 7000,7000 - 8000,8000 - 9000,9000 - 10000,10000 +";
		selectStruct.listValues = "1-999,1000-1500,1500-2000,2000-2500,2500-3000,3000-3500,3500-4000,4000-4500,4500-5000,5000-6000,6000-7000,7000-8000,8000-9000,9000-10000,10000-900000";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript>
		</td></tr>
			<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Address","member.listing.manual_listing.edit manual_listing_address")#</th>
			<td><input type="text" name="manual_listing_address" value="#HTMLEditFormat(form.manual_listing_address)#" size="40" /></td>
			</tr>
			
			<cfscript>
			
		arrLabel=arraynew(1);
		arrValue=arraynew(1);
		rs2=structnew();
		rs2.labels="";
		rs2.values="";
		cityUnq=structnew();
		
		preLabels="";
		preValues="";
		</cfscript>
			
			  <tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("City","member.listing.manual_listing.edit manual_listing_city")#</th>
			  <td>
			
		<cfsavecontent variable="db.sql">
		SELECT cast(group_concat(distinct listing_city SEPARATOR #db.param("','")#) AS CHAR) idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
	listing_deleted = #db.param(0)# and 
		listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
		<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE '%,7,%' </cfif>
		<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
		</cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
		<cfsavecontent variable="db.sql">
		select city_x_mls.city_name label, city_x_mls.city_id value 
		from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
		WHERE city_x_mls.city_id IN (#db.trustedSQL("'#qtype.idlist#'")#) and 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
		city_id NOT IN (#db.trustedSQL("'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'")#)  and 
		city_x_mls_deleted = #db.param(0)#
			  
		</cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
		<cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
		<!--- put the primary cities at top and repeat further down too --->
		<cfsavecontent variable="db.sql">
		select city.city_name label, city.city_id value 
		from #db.table("city_memory", request.zos.zcoreDatasource)# city 
		WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) and 
		city_deleted = #db.param(0)#
		ORDER BY label 
		</cfsavecontent><cfscript>qCity10=db.execute("qCity10");
		arrK2=arraynew(1);
		arrK3=arraynew(1);
		sOut=Structnew();
		if(qCity10.recordcount NEQ 0){
			for(i=1;i LTE qCity10.recordcount;i++){
				sOut[qCity10.label[i]]=true;
				arrayappend(arrK2,qCity10.label[i]);
				arrayappend(arrK3,qCity10.value[i]);
			}
			preLabels=arraytolist(arrK2,chr(9))&chr(9)&"-----------";
			preValues=arraytolist(arrK3,chr(9))&chr(9);
		}
		
		arrKeys=structkeyarray(cityUnq);
		arraysort(arrKeys,"text","asc");
		//arrKeys=structsort(cityUnq,"text","asc");
		for(i=1;i LTE arraylen(arrKeys);i++){
		if(structkeyexists(sOut,arrKeys[i]) EQ false){
			sOut[arrKeys[i]]=true;
			arrayappend(arrLabel,arrKeys[i]);
			arrayappend(arrValue,cityUnq[arrKeys[i]]);
		}
		}
		
		rs2.labels=trim(preLabels&chr(9)&arraytolist(arrLabel,chr(9)));
		rs2.values=trim(preValues&chr(9)&arraytolist(arrValue,chr(9)));
		ts.listLabels=rs2.labels;
		ts.listValues =rs2.values;
		ts = StructNew();
		ts.name="manual_listing_city";
		ts.selectedValues=form.manual_listing_city;
		ts.enableTyping=false;
		ts.enableClickSelect=false;
		ts.overrideOnKeyUp=true;
		ts.onkeyup="application.zcore.functions.zMlsCheckCityLookup(event, this,document.getElementById(this.id+'v'),'city_id'); application.zcore.functions.zKeyboardEvent(event, this,document.getElementById(this.id+'v'));";
		ts.onButtonClick="var e2=new Object();e2.keyCode=13;e2.which=13; application.zcore.functions.zKeyboardEvent(e2, document.getElementById('#ts.name#_zmanual'),document.getElementById('#ts.name#_zmanualv'),true);";
		ts.range=false;
		ts.allowAnyText=false;
		ts.onlyOneSelection=true;
		ts.disableSpider=true;
		ts.listLabelsDelimiter = chr(9);
		ts.listValuesDelimiter = chr(9);
		ts.listLabels=rs2.labels;
		ts.listValues =rs2.values;
		ts.inputstyle="padding:0px;font-size:10px; margin:0px;";
		application.zcore.functions.zInputLinkBox(ts);
		</cfscript></td></tr>
			  
			  
			  <cfsavecontent variable="db.sql">
				SELECT * FROM #db.table("state", request.zos.zcoreDatasource)# state ORDER BY state_state ASC
			  </cfsavecontent><cfscript>qState=db.execute("qState");</cfscript>
			  <tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("State","member.listing.manual_listing.edit manual_listing_state")#</th><td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "manual_listing_state";
			selectStruct.query = qState;
			selectStruct.queryLabelField = "state_state";
			selectStruct.queryValueField = "state_code";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td>
			  </tr>
			  <cfsavecontent variable="db.sql">
				SELECT * FROM #db.table("country", request.zos.zcoreDatasource)# country ORDER BY country_name ASC
			  </cfsavecontent><cfscript>qcountry=db.execute("qcountry");</cfscript>
			  <tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Country","member.listing.manual_listing.edit manual_listing_country")#</th><td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "manual_listing_country";
			selectStruct.query = qcountry;
			selectStruct.queryLabelField = "country_name";
			selectStruct.queryValueField = "country_code";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td>
			  </tr> --->
		<tr>
			<th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Zip","member.listing.manual_listing.edit manual_listing_zip")#</th>
			<td><input type="text" name="manual_listing_zip" value="#HTMLEditFormat(application.zcore.functions.zso(form, 'manual_listing_zip'))#" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Virtual Tour","member.listing.manual_listing.edit manual_listing_virtual_tour")#</th>
			<td><input type="text" name="manual_listing_virtual_tour" value="<cfif form.manual_listing_virtual_tour NEQ 0>#HTMLEditFormat(form.manual_listing_virtual_tour)#</cfif>" size="50" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Diagonal Image<br />Message","member.listing.manual_listing.edit manual_listing_diagonal_message")#</th>
			<td><table style="width:100%;">
					<tr>
						<td style="width:1%; vertical-align:top;"><textarea cols="30" rows="3" name="manual_listing_diagonal_message" onkeyup="<!--- document.getElementById('iframe1').src='/z/misc/diagonal/index?newmessage='+escape(this.value); --->document.getElementById('zFlashDiagonalStatusMessageId').innerText=this.value; zMLSShowFlashMessage();">#htmleditformat(form.manual_listing_diagonal_message)#</textarea></td>
						<td style="vertical-align:top; "><div style="width:125px; height:125px;" id="zFlashDiagonalStatusMessageId" class="zFlashDiagonalStatusMessage">#htmleditformat(form.manual_listing_diagonal_message)#</div>
							
							<!--- <iframe id="iframe1" src="/z/misc/diagonal/index?newmessage=#urlencodedformat(form.manual_listing_diagonal_message)#"  style="border:none; overflow:auto; margin:0px;" seamless="seamless" height="125" width="125"></iframe> ---></td>
						<td style="vertical-align:top;padding-left:5px;">Make sure your message fits in the preview to the side.  Multiple lines are supported.  If entered, this field will override any other messages set like Sold or Under Contract. </td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<th style="vertical-align:top; "> #application.zcore.functions.zOutputHelpToolTip("META Title","member.listing.manual_listing.edit manual_listing_metatitle")#</th>
			<td style="vertical-align:top; "><input type="text" name="manual_listing_metatitle" value="#HTMLEditFormat(form.manual_listing_metatitle)#" maxlength="150" size="100" />
				<br />
				(Meta title is optional and overrides the &lt;TITLE&gt; HTML element to be different from the visible listing title.) </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.listing.manual_listing.edit manual_listing_metakey")#</th>
			<td style="vertical-align:top; "><textarea name="manual_listing_metakey" rows="5" cols="60">#form.manual_listing_metakey#</textarea></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.listing.manual_listing.edit manual_listing_metadesc")#</th>
			<td style="vertical-align:top; "><textarea name="manual_listing_metadesc" cols="60" rows="5">#form.manual_listing_metadesc#</textarea></td>
		</tr>
	</table>
#tabCom.endFieldSet()# 
	<!--- #tabCom.beginFieldSet("Advanced")# 
			<table style="width:100%; border-spacing:0px;" class="table-list">
			</table>
			#tabCom.endFieldSet()# ---> 
#tabCom.endTabMenu()# #application.zcore.functions.zEndForm()#
</cffunction>
</cfoutput>
</cfcomponent>
