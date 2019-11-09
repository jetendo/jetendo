<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	var qCh=0;

	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows");	

	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	form.site_id=request.zos.globals.id;
	if(application.zcore.functions.zso(form, 'slideshow_id') NEQ ""){
		db.sql="SELECT * FROM #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
		where slideshow_id=#db.param(form.slideshow_id)# and 
		slideshow_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		qCh=db.execute("qCh");
		if(qCh.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid,"Access Denied");
			application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");
		}
	}
	if(structkeyexists(form, 'slideshow_id')){
		variables.queueSortStruct = StructNew();
		// required 
		if (structkeyexists(form, 'slideshow_image_id') AND structkeyexists(form, 'slideshow_tab_id')) {
			variables.queueSortStruct.ajaxURL='/z/admin/slideshow/managePhoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#';
			variables.queueSortStruct.tableName = "slideshow_image";
			variables.queueSortStruct.sortFieldName = "slideshow_image_sort";
			variables.queueSortStruct.primaryKeyName = "slideshow_image_id";
			// optional
			variables.queueSortStruct.where="slideshow_id = '#application.zcore.functions.zescape(form.slideshow_id)#' AND 
			slideshow_tab_id = '#application.zcore.functions.zescape(form.slideshow_tab_id)#' and 
			slideshow_image.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"' and slideshow_image_deleted='0' ";
		} else if(structkeyexists(form, 'slideshow_tab_id')) {
			variables.queueSortStruct.tableName = "slideshow_tab";
			variables.queueSortStruct.sortFieldName = "slideshow_tab_sort";
			variables.queueSortStruct.primaryKeyName = "slideshow_tab_id";
			// optional
			variables.queueSortStruct.where="slideshow_id = '#application.zcore.functions.zescape(form.slideshow_id)#'  and 
			slideshow_tab.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"' and 
			slideshow_tab_deleted='0' ";
		} else { 
			variables.queueSortStruct.ajaxURL='/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#';
			variables.queueSortStruct.tableName = "slideshow_image";
			variables.queueSortStruct.sortFieldName = "slideshow_image_sort";
			variables.queueSortStruct.primaryKeyName = "slideshow_image_id";

			// optional
			variables.queueSortStruct.where="slideshow_id = '#application.zcore.functions.zescape(form.slideshow_id)#' and 
			slideshow_image.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"' and slideshow_image_deleted='0' ";
		}
		if(form.method EQ "managePhoto"){
			variables.queueSortStruct.ajaxURL='/z/admin/slideshow/managePhoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#';
			variables.queueSortStruct.tableName = "slideshow_image";
			variables.queueSortStruct.sortFieldName = "slideshow_image_sort";
			variables.queueSortStruct.primaryKeyName = "slideshow_image_id";
			// optional
			variables.queueSortStruct.where="slideshow_id = '#application.zcore.functions.zescape(form.slideshow_id)#' AND 
			slideshow_tab_id = '#application.zcore.functions.zescape(form.slideshow_tab_id)#' and 
			slideshow_image.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"' and 
			slideshow_image_deleted='0' ";
		}else if(form.method EQ "manageTabs"){
			variables.queueSortStruct.ajaxURL='/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#';
			variables.queueSortStruct.tableName = "slideshow_tab";
			variables.queueSortStruct.sortFieldName = "slideshow_tab_sort";
			variables.queueSortStruct.primaryKeyName = "slideshow_tab_id";
			// optional
			variables.queueSortStruct.where="slideshow_id = '#application.zcore.functions.zescape(form.slideshow_id)#'  and 
			slideshow_tab.site_id='"&application.zcore.functions.zescape(request.zos.globals.id)&"' and 
			lideshow_tab_deleted='0' ";
		}
		variables.queueSortStruct.ajaxTableId='sortRowTable';
		variables.queueSortStruct.datasource=request.zos.zcoreDatasource;
		variables.queueSortStruct.disableRedirect=true;
		variables.queueSortCom.init(variables.queueSortStruct);
		if(structkeyexists(form, 'zQueueSort')){
			application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
		if(structkeyexists(form, 'zQueueSortAjax')){
			application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
			variables.queueSortCom.returnJson();
		}
	}
	</cfscript>
</cffunction>

<cffunction name="copy" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var sql=0;
	var n=0;
	var arrF=0;
	var arrI=0;
	var q=0;
	var tabidstruct=0;
	var qId=0;
	var newmlssavedsearchid=0;
	var newslideshowid=0;
	var qM=0;
	var qS=0;
	var arrS=0;
	var i=0; 
	var qI=0;
	var arrM=0;
	var arrT=0;
	var newname22=0;
	var qT=0;
	var qS2=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.6");
	</cfscript>
	<h2>Copy Slideshow</h2>
	<cfif application.zcore.functions.zso(form, 'newname') EQ "">
		<cfscript>
		db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
		 where slideshow_id = #db.param(form.slideshow_id)# and 
		 slideshow_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
        qS=db.execute("qS");
		</cfscript>
		Selected Slideshow: #qs.slideshow_name#<br />
		<br />
		<form class="zFormCheckDirty" action="/z/admin/slideshow/copy" method="get">
			<input type="hidden" name="slideshow_id" value="#htmleditformat(form.slideshow_id)#" />
			<table style="border-spacing:0px; padding:5px;">
				<tr>
					<td>#application.zcore.functions.zOutputHelpToolTip("New Name","member.slideshow.copy newname")# </td>
					<td><input type="text" name="newname" value="#htmleditformat(qs.slideshow_name)#" /></td>
				</tr>
				<cfif application.zcore.user.checkServerAccess()>
					<tr>
						<td>#application.zcore.functions.zOutputHelpToolTip("New Site","member.slideshow.copy newsiteid")# </td>
						<td><cfscript>
                    application.zcore.functions.zGetSiteSelect('newsiteid');
                    </cfscript></td>
					</tr>
				</cfif>
				<tr>
					<td>#application.zcore.functions.zOutputHelpToolTip("Rename existing slideshow","member.slideshow.copy renameexisting")# </td>
					<td><input type="checkbox" name="renameexisting" value="1" />
						(Only happens if there is a slideshow matches the name entered above.)</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="submit" name="submit1" value="Copy Slideshow" />
						<input type="button" name="button1" value="Cancel" onclick="window.location.href='/z/admin/slideshow/index';" /></td>
				</tr>
			</table>
		</form>
	<cfelse>
		<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
		if(application.zcore.user.checkServerAccess()){
			form.newsiteid=application.zcore.functions.zso(form,'newsiteid', true);
			if(form.newsiteid EQ 0){
				form.newsiteid=request.zos.globals.id;
			}
		}else{
			form.newsiteid=request.zos.globals.id;
		}
		path=application.zcore.functions.zvar("shortDomain", form.newsiteid);
		if(path EQ ""){
			application.zcore.status.setStatus(request.zsid, "Failed to copy slideshow. Destination site was incorrectly configured.", form,true);
			application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
		}
		form.newsitedir=application.zcore.functions.zGetDomainWritableInstallPath(path);

		db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
		where slideshow_id = #db.param(form.slideshow_id)# and 
		slideshow_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
		qS=db.execute("qS");
		db.sql="select * from #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab
		where slideshow_id = #db.param(form.slideshow_id)# and 
		slideshow_tab_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
		qT=db.execute("qT");
		db.sql="select * from #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image
		where slideshow_id = #db.param(form.slideshow_id)# and 
		slideshow_image_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
		qI=db.execute("qI");
		
		if(application.zcore.functions.zso(form, 'renameexisting') EQ 1){
			db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
			where slideshow_name = #db.param(form.newname)# and 
			slideshow_deleted = #db.param(0)# and 
			site_id = #db.param(form.newsiteid)#";
			qS2=db.execute("qS2");
			if(qS2.recordcount NEQ 0){
				newname22=qS2.slideshow_name&" (renamed on "&dateformat(now(),"m/d/yy")&" at "&timeformat(now(),"HH:mm:ss")&")";
				db.sql="update #db.table("slideshow", request.zos.zcoreDatasource)# slideshow set 
				slideshow_locked = #db.param(0)#, 
				slideshow_name =#db.param(newname22)#, 
				slideshow_codename=#db.param(newname22)#,
				slideshow_updated_datetime=#db.param(request.zos.mysqlnow)# 
				where slideshow_id = #db.param(qs2.slideshow_id)# and 
				site_id=#db.param(qS2.site_id)#";
				q=db.execute("q");
			}
		}
		
		arrS=listtoarray(lcase(qS.columnlist));
		arrT=listtoarray(lcase(qT.columnlist));
		arrI=listtoarray(lcase(qI.columnlist));
		
		sql="INSERT	INTO #db.table("slideshow", request.zos.zcoreDatasource)#  SET ";
		arrF=arraynew(1);
		for(i=1;i LTE arraylen(arrS);i++){
			if(arrS[i] EQ "slideshow_id"){
				//	arrayappend(arrF, arrS[i]&"= NULL");
			}else if(arrS[i] EQ "slideshow_name"){
				arrayappend(arrF, arrS[i]&"="&db.param(form.newname));
			}else if(arrS[i] EQ "slideshow_codename"){
				arrayappend(arrF, arrS[i]&"="&db.param(form.newname));
			}else if(arrS[i] EQ "site_id"){
				arrayappend(arrF, arrS[i]&"="&db.param(form.newsiteid));
			}else if(arrS[i] EQ "slideshow_updated_datetime"){
				arrayappend(arrF, arrS[i]&"="&db.param(request.zos.mysqlnow));
			}else{
				arrayappend(arrF, arrS[i]&"="&db.param(qS[arrS[i]][1]));
			}
		}
		sql&=arraytolist(arrF,", ");
		db.sql=sql;
		try{
			local.rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable);
			if(local.rs.success){
				newslideshowid=local.rs.result;
			}
		}catch(database e){
			local.rs={success:false, errorMessage:e.detail};
		}
		if(not local.rs.success){ 
			application.zcore.status.setStatus(request.zsid, "Failed to copy slideshow.  Make sure the new code name is unique. Error Message:"&local.rs.errorMessage, form,true);
			application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
		}
		tabidstruct=structnew();
		for(n=1;n LTE qT.recordcount;n++){
			if(qT.mls_saved_search_id[n] NEQ 0){
				db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search
				where mls_saved_search_id = #db.param(qT.mls_saved_search_id[n])# and 
				mls_saved_search_deleted = #db.param(0)# and
				site_id=#db.param(request.zos.globals.id)#";
				qM=db.execute("qM");
				if(qM.recordcount EQ 0){
					newmlssavedsearchid=0;
				}else{
					arrM=listtoarray(lcase(qM.columnlist));
					sql="INSERT	INTO #db.table("mls_saved_search", request.zos.zcoreDatasource)#  SET ";
					arrF=arraynew(1);
					for(i=1;i LTE arraylen(arrM);i++){
						if(arrM[i] EQ "mls_saved_search_id"){
						}else if(arrM[i] EQ "saved_search_created_date"){
							arrayappend(arrF, arrM[i]&"="&db.param(dateformat(qM[arrM[i]][1],'yyyy-mm-dd')&' '&timeformat(qM[arrM[i]][1],'HH:mm:ss')));
						}else if(arrM[i] EQ "saved_search_updated_date"){
							arrayappend(arrF, arrM[i]&"="&db.param(dateformat(qM[arrM[i]][1],'yyyy-mm-dd')&' '&timeformat(qM[arrM[i]][1],'HH:mm:ss')));
						}else if(arrM[i] EQ "saved_search_last_sent_date"){
							arrayappend(arrF, arrM[i]&"="&db.param(dateformat(qM[arrM[i]][1],'yyyy-mm-dd')&' '&timeformat(qM[arrM[i]][1],'HH:mm:ss')));
						}else if(arrM[i] EQ "saved_search_sent_date"){
							arrayappend(arrF, arrM[i]&"="&db.param(dateformat(qM[arrM[i]][1],'yyyy-mm-dd')&' '&timeformat(qM[arrM[i]][1],'HH:mm:ss')));
						}else if(arrM[i] EQ "site_id"){
							arrayappend(arrF, arrM[i]&"="&db.param(form.newsiteid));
						}else if(arrM[i] EQ "mls_saved_search_updated_datetime"){
							arrayappend(arrF, arrM[i]&"="&db.param(request.zos.mysqlnow));
						}else{
							arrayappend(arrF, arrM[i]&"="&db.param(qM[arrM[i]][1]));
						}
					}
					sql&=arraytolist(arrF,", ");
					db.sql=sql;
					local.rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable);
					if(local.rs.success){
						newmlssavedsearchid=local.rs.result;
					}else{
						throw("mls_saved_search insert failed");
					}
				}
			}else{
				newmlssavedsearchid=0;
			}
		
		
			sql="INSERT	INTO #db.table("slideshow_tab", request.zos.zcoreDatasource)#  SET ";
			arrF=arraynew(1);
			for(i=1;i LTE arraylen(arrT);i++){
				if(arrT[i] EQ "slideshow_tab_id"){
				}else if(arrT[i] EQ "slideshow_id"){
					arrayappend(arrF, arrT[i]&"="&db.param(newslideshowid));
				}else if(arrT[i] EQ "site_id"){
					arrayappend(arrF, arrT[i]&"="&db.param(form.newsiteid));
				}else if(arrT[i] EQ "mls_saved_search_id"){
					arrayappend(arrF, arrT[i]&"="&db.param(newmlssavedsearchid));
				}else if(arrT[i] EQ "slideshow_tab_updated_datetime"){
					arrayappend(arrF, arrT[i]&"="&db.param(request.zos.mysqlnow));
				}else{
					arrayappend(arrF, arrT[i]&"="&db.param(qT[arrT[i]][n]));
				}
			}
			sql&=arraytolist(arrF,", ");
			db.sql=sql;
			local.rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable);
			if(local.rs.success){
				tabidstruct[qT.slideshow_tab_id]=local.rs.result;
			}else{
				throw("slideshow_tab insert failed.");
			}
		}
		for(n=1;n LTE qI.recordcount;n++){
			sql="INSERT	INTO #db.table("slideshow_image", request.zos.zcoreDatasource)#  SET ";
			arrF=arraynew(1);
			for(i=1;i LTE arraylen(arrI);i++){
				if(arrI[i] EQ "slideshow_image_id"){
				}else if(arrI[i] EQ "slideshow_id"){
					arrayappend(arrF, arrI[i]&"="&db.param(newslideshowid));
				}else if(arrI[i] EQ "slideshow_tab_id"){
					arrayappend(arrF, arrI[i]&"="&db.param(tabidstruct[qI.slideshow_tab_id[n]]));
				}else if(arrI[i] EQ "site_id"){
					arrayappend(arrF, arrI[i]&"="&db.param(form.newsiteid));
				}else if(arrI[i] EQ "slideshow_image_updated_datetime"){
					arrayappend(arrF, arrI[i]&"="&db.param(request.zos.mysqlnow));
				}else{
					arrayappend(arrF, arrI[i]&"="&db.param(qI[arrI[i]][n]));
				}
			}
			sql&=arraytolist(arrF,", ");
			db.sql=sql;
			q=db.execute("q");
		}
		application.zcore.functions.zcreatedirectory(form.newsitedir&'zupload/slideshow/');
		application.zcore.functions.zcreatedirectory(form.newsitedir&'zupload/slideshow/#newslideshowid#');
		application.zcore.functions.zCopyDirectory(request.zos.globals.privatehomedir&'zupload/slideshow/#form.slideshow_id#', form.newsitedir&'zupload/slideshow/#newslideshowid#');
		application.zcore.status.setStatus(request.zsid, "Slideshow copied");
		application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");
		</cfscript>
	</cfif>
</cffunction>

<cffunction name="deletePhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var tempURL=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * FROM #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image, #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	where slideshow.site_id = slideshow_image.site_id and 
	slideshow.slideshow_id = slideshow_image.slideshow_id and 
	slideshow.slideshow_id = #db.param(form.slideshow_id)# and 
	slideshow_image.slideshow_image_id = #db.param(form.slideshow_image_id)# and 
	slideshow.site_id = #db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'You don''t have permission to delete this slideshow.',false,true);
		if(isDefined('request.zsession.slideshow_return'&form.slideshow_id)){
			tempURL = request.zsession['slideshow_return'&form.slideshow_id];
			StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.status.setStatus(request.zsid, 'Slideshow Image deleted.');
		if(qCheck.slideshow_image_thumbnail_url NEQ ''){
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/#form.slideshow_id#/'&qCheck.slideshow_image_thumbnail_url);
		}
		if(qCheck.slideshow_image_url NEQ ''){
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/#form.slideshow_id#/'&qCheck.slideshow_image_url);
		}
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zDeleteRecord("slideshow_image","slideshow_image_id,site_id",request.zos.zcoreDatasource);
		variables.queueSortCom.sortAll();
		application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
		application.zcore.functions.zRedirect('/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Slideshow Image?<br />
		<br />
		<img src="/zupload/slideshow/#qCheck.slideshow_id#/#qCheck.slideshow_image_thumbnail_url#" /><br />
		<br />
		<a href="/z/admin/slideshow/deletePhoto?confirm=1&amp;slideshow_id=#form.slideshow_id#&amp;slideshow_image_id=#qcheck.slideshow_image_id#&amp;slideshow_tab_id=#qcheck.slideshow_tab_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="#application.zcore.functions.zso(request.zsession,'slideshow_return'&form.slideshow_id)#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="deleteTab" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var q=0;
	var qCheck2=0;
	var tempURL=0;
	var qCheck=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab, 
	#db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	where slideshow.site_id = slideshow_tab.site_id and 
	slideshow_deleted = #db.param(0)# and 
	slideshow_tab_deleted = #db.param(0)# and
	slideshow.slideshow_id = slideshow_tab.slideshow_id and 
	slideshow.slideshow_id = #db.param(form.slideshow_id)# and 
	slideshow_tab.slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
	slideshow.site_id = #db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'You don''t have permission to delete this slideshow.',false,true);
		if(isDefined('request.zsession.slideshow_return'&form.slideshow_id)){
			tempURL = request.zsession['slideshow_return'&form.slideshow_id];
			StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="SELECT * FROM #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image
		where slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
		slideshow_image_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)# ";
		qCheck2=db.execute("qCheck2");
		loop query="qCheck2"{
			if(qCheck2.slideshow_image_thumbnail_url NEQ ''){
				application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/#qCheck2.slideshow_id#/'&qCheck2.slideshow_image_thumbnail_url);
			}
			if(qCheck2.slideshow_image_url NEQ ''){
				application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/#qCheck2.slideshow_id#/'&qCheck2.slideshow_image_url);
			}
			db.sql="DELETE FROM #db.table("slideshow_image", request.zos.zcoreDatasource)# 
			where slideshow_image_id=#db.param(qCheck2.slideshow_image_id)# and 
			slideshow_image_deleted = #db.param(0)# and
			site_id=#db.param(request.zos.globals.id)#";
			q=db.execute("q");
		}
		application.zcore.status.setStatus(request.zsid, 'Slideshow Tab deleted.');
		if(qCheck.slideshow_tab_url NEQ ''){
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/#form.slideshow_id#/tabs/'&qCheck.slideshow_tab_url);
		}
		if(application.zcore.app.siteHasApp("listing")){
			request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qCheck.mls_saved_search_id);
		}
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zDeleteRecord("slideshow_tab","slideshow_tab_id,site_id",request.zos.zcoreDatasource);


		variables.queueSortCom.sortAll();
		application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
		application.zcore.functions.zRedirect('/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#&zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Tab?<br />
		<br />
		Title: #qCheck.slideshow_tab_caption# <br />
		<br />
		<cfif trim(qCheck.slideshow_tab_url) NEQ ''>
			<img src="/zupload/slideshow/#qCheck.slideshow_id#/tabs/#qCheck.slideshow_tab_url#" /><br />
			<br />
		</cfif>
		<a href="/z/admin/slideshow/deleteTab?confirm=1&amp;slideshow_id=#form.slideshow_id#&amp;slideshow_tab_id=#qcheck.slideshow_tab_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="#application.zcore.functions.zso(request.zsession,'slideshow_return'&form.slideshow_id)#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var q=0;
	var tempURL=0;
	var qCheck=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	LEFT JOIN #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image ON 
	slideshow_image.slideshow_id = slideshow.slideshow_id and 
	slideshow_image.site_id = slideshow.site_id and 
	slideshow_image_deleted = #db.param(0)#
	where slideshow.slideshow_id = #db.param(form.slideshow_id)# and 
	slideshow_deleted = #db.param(0)# and
	slideshow.site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount GT 1){
		application.zcore.status.setStatus(request.zsid, 'You must delete all the slideshow images before deleting a slideshow.',false,true);
		if(isDefined('request.zsession.slideshow_return'&form.slideshow_id)){
			tempURL = request.zsession['slideshow_return'&form.slideshow_id];
			StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
		}
	}else if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'This slideshow no longer exists.',false,true);
		if(isDefined('request.zsession.slideshow_return'&form.slideshow_id)){
			tempURL = request.zsession['slideshow_return'&form.slideshow_id];
			StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.functions.zdeletedirectory(request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id);
		db.sql="DELETE FROM #db.table("slideshow_image", request.zos.zcoreDatasource)# 
		 where slideshow_id=#db.param(form.slideshow_id)# and 
		 slideshow_image_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
        q=db.execute("q");
		db.sql="DELETE FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# 
		 where slideshow_id=#db.param(form.slideshow_id)# and 
		 slideshow_tab_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
        q=db.execute("q");
		db.sql="DELETE from #db.table("slideshow", request.zos.zcoreDatasource)# 
		 where slideshow_id=#db.param(form.slideshow_id)# and 
		 slideshow_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
        q=db.execute("q");
		
		ts=structnew();
		ts.uniquePhrase="zSlideshowCSS#form.slideshow_id#";
		ts.code="";
		ts.site_id=request.zos.globals.id;
		application.zcore.functions.zPublishCss(ts);
		
		application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
		application.zcore.status.setStatus(request.zsid, 'Slideshow deleted.');
		application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this slideshow?<br />
			<br />
			Title: #qCheck.slideshow_name# <br />
			<br />
			<a href="/z/admin/slideshow/delete?confirm=1&amp;slideshow_id=#form.slideshow_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="#application.zcore.functions.zso(request.zsession,'slideshow_return'&form.slideshow_id)#">No</a> </h2>
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
	var firstTileCount=0;
	var thumbAreaHeight=0;
	var firstTileCount=0;
	var qss2=0;
	var tabHeight=0;
	var thumbAreaWidth=0;
	var ts=0;
	var currentHeight=0;
	var tempURL=0;
	var currentWidth=0;
	var output=0;
	var imPath2=0;
	var imPath=0;
	var qCheck=0;
	var ts1=0;
	var ts2=0;
	var errors=0;
	var myForm=structnew();
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	form.slideshow_updated_datetime=request.zos.mysqlnow;
	if(form.method EQ 'update'){
		db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
		where slideshow_id = #db.param(form.slideshow_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		slideshow_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this slideshow.',false,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
		}
	}
	myForm.slideshow_name.required=true;
	myForm.slideshow_width.required=true;
	myForm.slideshow_height.required=true;
	myForm.slideshow_thumb_width.required=true;
	myForm.slideshow_thumb_height.required=true;
	
	if(structkeyexists(form,'slideshow_image_thumbnail_url') EQ false){
		form.slideshow_image_thumbnail_url='';	
	}
	
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/slideshow/add?zsid="&request.zsid);
		}
	}
	form.slideshow_codename=form.slideshow_name;
	if(form.slideshow_thumb_width EQ 0 or form.slideshow_thumb_height EQ 0){
		application.zcore.status.setStatus(request.zsid,"Thumbnail width and height cannot be 0 pixels.",form,true);
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/slideshow/add?zsid="&request.zsid);
		}
	}
	ts=StructNew();
	ts.table="slideshow";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insert'){
		form.slideshow_id = application.zcore.functions.zInsert(ts);
		if(form.slideshow_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Slideshow with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/add?zsid=#request.zsid#');
		}
		//here we are going to create a default tab.
		ts2=structnew();
		ts2.slideshow_tab_caption="Home";
		ts2.slideshow_tab_link="";
		ts2.slideshow_id = form.slideshow_id;
		ts2.slideshow_tab_type_id="1";
		ts2.slideshow_tab_search_mls="0";
		ts2.site_id=request.zos.globals.id;
		
		ts1=StructNew();
		ts1.table="slideshow_tab";
		ts1.struct=form;
		ts1.datasource=request.zos.zcoreDatasource;
		ts1.struct = ts2;
		form.slideshow_tab_id = application.zcore.functions.zInsert(ts1);
		// done creating the default tab.
		form.method="update";
		db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
		where slideshow_id = #db.param(form.slideshow_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		slideshow_deleted = #db.param(0)#";
		qcheck=db.execute("qcheck");
	}
	
	if (DirectoryExists(request.zos.globals.privatehomedir&"zupload/slideshow/") EQ false) {
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&"zupload/slideshow/");
	}
	if (DirectoryExists(request.zos.globals.privatehomedir&"zupload/slideshow/"&form.slideshow_id) EQ false) {
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&"zupload/slideshow/"&form.slideshow_id);
	}
	
	 if(form.slideshow_back_image NEQ ''){
		  form.slideshow_back_image=application.zcore.functions.zUploadFile("slideshow_back_image", request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', false);
		  if(form.slideshow_back_image EQ false){
			   application.zcore.status.setStatus(request.zsid, 'Failed to upload forward image',form,true);
			   if(form.method EQ "update"){
					application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }else{
					application.zcore.functions.zRedirect("/z/admin/slideshow/add?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }
		  }
	 }else{
		StructDelete(form, 'slideshow_back_image');
	 }
	 if(form.slideshow_forward_image NEQ ''){
		  form.slideshow_forward_image=application.zcore.functions.zUploadFile("slideshow_forward_image", request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', false);
		  if(form.slideshow_forward_image EQ false){
			   application.zcore.status.setStatus(request.zsid, 'Failed to back image',form,true);
			   if(form.method EQ "update"){
					application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }else{
					application.zcore.functions.zRedirect("/z/admin/slideshow/add?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }
		  }
	 }else{
		StructDelete(form, 'slideshow_forward_image');
	}
	
	 if(form.slideshow_background_image NEQ ''){
		  form.slideshow_background_image=application.zcore.functions.zUploadFile("slideshow_background_image", request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', false);
		  if(form.slideshow_background_image EQ false){
			   application.zcore.status.setStatus(request.zsid, 'Failed to upload background image.',form,true);
			   if(form.method EQ "update"){
					application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }else{
					application.zcore.functions.zRedirect("/z/admin/slideshow/add?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			   }
		  }
	 }else{
		StructDelete(form, 'slideshow_background_image');
	 }
	  if(application.zcore.functions.zso(form,'slideshow_back_image_delete') EQ 1){
		   application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/' & qCheck.slideshow_back_image);
		   form.slideshow_back_image='';
	  }
	  if(application.zcore.functions.zso(form, 'slideshow_forward_image_delete') EQ 1){
		   application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/'&qCheck.slideshow_forward_image);
		   form.slideshow_forward_image='';
	  }

	  if(application.zcore.functions.zso(form, 'slideshow_background_image_delete') EQ 1){
		   application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/'&qCheck.slideshow_background_image);
		   form.slideshow_background_image='';
	  }
	
	imPath=false;
	imPath2=false;
	if(application.zcore.functions.zso(form, 'slideshow_back_image') EQ '' and form.method EQ 'update'){
		imPath="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/#qcheck.slideshow_back_image#";
	}else if(application.zcore.functions.zso(form, 'slideshow_back_image') NEQ ''){
		imPath="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/#form.slideshow_back_image#";
	}
	if(application.zcore.functions.zso(form, 'slideshow_forward_image') EQ '' and form.method EQ 'update'){
		imPath2="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/#qcheck.slideshow_forward_image#";
	}else if(application.zcore.functions.zso(form, 'slideshow_forward_image') NEQ ''){
		imPath2="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/#form.slideshow_forward_image#";
	}
	form.slideshow_back_image_size=0;
	form.slideshow_forward_image_size=0;
	if(form.slideshow_tabistext EQ 0 and fileexists(imPath)){
		
		local.imageSize=application.zcore.functions.zGetImageSize(imPath);      
		if(not local.imageSize.success){
			application.zcore.status.setStatus(request.zsid, local.imageSize.errorMessage, form, true);
			if(form.method EQ "update"){
				application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/admin/slideshow/add?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			}
		}
		if(form.slideshow_slide_direction EQ "y"){
    		form.slideshow_back_image_size=local.imageSize.height;
		}else{
    		form.slideshow_back_image_size=local.imageSize.width;
		}
	}
	if(form.slideshow_tabistext EQ 0 and fileexists(imPath2)){
		local.imageSize=application.zcore.functions.zGetImageSize(imPath2);    
		if(not local.imageSize.success){
			application.zcore.status.setStatus(request.zsid, local.imageSize.errorMessage, form, true);
			if(form.method EQ "update"){
				application.zcore.functions.zRedirect("/z/admin/slideshow/edit?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/admin/slideshow/add?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			}
		}
		if(form.slideshow_slide_direction EQ "y"){
    		form.slideshow_back_image_size=local.imageSize.height;
		}else{
    		form.slideshow_back_image_size=local.imageSize.width;
		}
	}
	db.sql="select count(slideshow_id) count 
	from #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab
	where slideshow_id=#db.param(form.slideshow_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	slideshow_tab_deleted = #db.param(0)# ";
	qss2=db.execute("qss2");
	if(form.slideshow_thumb_width NEQ 0){
		if(form.slideshow_slide_direction EQ "y"){
			if(form.slideshow_tabistext){
				if(qss2.recordcount EQ 1 and qss2.count EQ 1){
					tabHeight=0;
				}else{
					tabHeight=8+(form.slideshow_tabpadding*2);
				}
				thumbAreaHeight=form.slideshow_height-(12+12+(form.slideshow_thumb_padding*2)+tabHeight);
			}else{
				if(qss2.recordcount EQ 1 and qss2.count EQ 1){
					tabHeight=0;
				}else{
					tabHeight=qcheck.slideshow_tab_size;
				}
				thumbAreaHeight=form.slideshow_height-(form.slideshow_back_image_size+form.slideshow_forward_image_size+(form.slideshow_thumb_padding*2)+tabHeight);
			}
			firstTileCount=ceiling(thumbAreaHeight/form.slideshow_thumb_height)+1+form.slideshow_moved_tile_count;
		}else{
			if(form.slideshow_tabistext){
				thumbAreaWidth=form.slideshow_width-(12+12);
			}else{
				thumbAreaWidth=form.slideshow_width-(form.slideshow_back_image_size+form.slideshow_forward_image_size);
			}
			firstTileCount=ceiling(thumbAreaWidth/form.slideshow_thumb_width)+1+form.slideshow_moved_tile_count;
		}
		form.slideshow_thumb_display_count=firstTileCount;
	}else{
		form.slideshow_thumb_display_count=0;
	}
	
	ts=StructNew();
	ts.struct=form;
	ts.table="slideshow";
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zUpdate(ts) EQ false){
		application.zcore.status.setStatus(request.zsid, 'Slideshow with this name already exists.  Please type a unique name',form,true);
		application.zcore.functions.zRedirect('/z/admin/slideshow/edit?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#');
	}
	
	application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
		
	if(form.method EQ 'insert'){
		application.zcore.status.setStatus(request.zsid, "Slideshow added.");
	}else{
		application.zcore.status.setStatus(request.zsid, "Slideshow saved.");
	}
	if(structkeyexists(form, 'slideshow_id') and isDefined('request.zsession.slideshow_return'&form.slideshow_id)){	
		tempURL = request.zsession['slideshow_return'&form.slideshow_id];
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="addTab" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editTab();
	</cfscript>
</cffunction>

<cffunction name="editTab" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var showTable=0;
	var currentMethod=form.method;
	var ts=0;
	var newaction=0;
	var qTabData=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.3");
    form.slideshow_tab_id=application.zcore.functions.zso(form, 'slideshow_tab_id');
    if(structkeyexists(form, 'return')){
    StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
    }
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# s
	LEFT JOIN #db.table("slideshow_tab", request.zos.zcoreDatasource)# st ON 
	st.slideshow_id = s.slideshow_id and 
	st.slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
	st.site_id = s.site_id and 
	st.slideshow_tab_deleted = #db.param(0)#
	where s.slideshow_id=#db.param(form.slideshow_id)# and 
	s.slideshow_deleted = #db.param(0)# and 
	s.site_id =#db.param(request.zos.globals.id)# ";
	qTabData=db.execute("qTabData");
    if(qTabData.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"This Tab no longer exists.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
    }else if(currentMethod EQ 'editTab' and qTabData.slideshow_tab_id EQ ""){
		application.zcore.status.setStatus(request.zsid,"This Tab no longer exists.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#&zsid=#request.zsid#");	
    }
	application.zcore.functions.zQueryToStruct(qTabData);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
	if(qTabData.slideshow_tab_type_id EQ '') {
		form.slideshow_tab_type_id='1';
	}
	
    </cfscript>
	<h2>
		<cfif currentMethod EQ 'addTab'>
			Add
			<cfelse>
			Edit
		</cfif>
		Tab</h2>
	<cfscript>
    ts=StructNew();
    ts.name="zMLSSearchForm";
    ts.ajax=false;
    if(currentMethod EQ 'addTab'){
        newAction="insertTab";
    }else{
        newAction="updateTab";
    }
	ts.class="zFormCheckDirty";
    ts.enctype="multipart/form-data";
    ts.action="/z/admin/slideshow/#newAction#?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#";
    ts.method="post";
    ts.successMessage=false;
    if(application.zcore.app.siteHasApp("listing")){
        ts.onLoadCallback="loadMLSResults";
        ts.onChangeCallback="getMLSCount";
    }
    application.zcore.functions.zForm(ts);
    
    </cfscript>
	<p>Select a .jpg, .gif or .png image.</p>
	<table class="table-list">
	<cfif form.slideshow_tabistext EQ 1>
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Tab Name","member.slideshow.editTab slideshow_tab_caption")#</th>
			<td><input type="text" size="50" name="slideshow_tab_caption" id="slideshow_tab_caption" value="#HTMLEditFormat(form.slideshow_tab_caption)#"></td>
		</tr>
		<cfelse>
		<tr>
			<th style="width:130px;">#application.zcore.functions.zOutputHelpToolTip("Select File","member.slideshow.editTab slideshow_tab_url")#</th>
			<td>#application.zcore.functions.zInputImage('slideshow_tab_url', request.zos.globals.privatehomedir&'zupload/slideshow/'& form.slideshow_id &'/tabs/', request.zos.currentHostName&'/zupload/slideshow/'& form.slideshow_id & '/tabs/')#</td>
		</tr>
	</cfif>
	<tr>
		<th>#application.zcore.functions.zOutputHelpToolTip("Tab Link","member.slideshow.editTab slideshow_tab_link")#</th>
		<td><input type="text" size="50" name="slideshow_tab_link" id="slideshow_tab_link" value="#HTMLEditFormat(form.slideshow_tab_link)#">
			(Leave blank unless this tab should click through to another page)</td>
	</tr>
	<tr>
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Ajax Enabled?","member.slideshow.editTab slideshow_tab_ajax_enabled")#</th>
		<td style="vertical-align:top; "><input type="radio" name="slideshow_tab_ajax_enabled" id="sajaxyes" value="1" style="border:none; background:none;" <cfif form.slideshow_tab_ajax_enabled EQ 1>checked="checked"</cfif> />
			Yes
			<div id="ajaxnodiv" style="display:inline;<cfif form.slideshow_tab_type_id EQ 2>display:none;</cfif>">
				<input type="radio" name="slideshow_tab_ajax_enabled" value="0" style="border:none; background:none;" <cfif form.slideshow_tab_ajax_enabled EQ 0 or form.slideshow_tab_ajax_enabled EQ ''>checked="checked"</cfif> />
				No </div></td>
	</tr>
	<cfif currentMethod NEQ 'editTab'>
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Overwrite<br />Existing Files?","member.slideshow.editTab image_overwrite")#</th>
			<td><input type="radio" name="image_overwrite" value="1" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
				Yes
				<input type="radio" name="image_overwrite" value="0" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 0 or application.zcore.functions.zso(form, 'image_overwrite') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				No </td>
		</tr>
	</cfif>
	<tr>
		<th>#application.zcore.functions.zOutputHelpToolTip("Slideshow Tab Type","member.slideshow.editTab slideshow_tab_type_id")#</th>
		<td><cfscript>
		ts = StructNew();
		ts.name = "slideshow_tab_type_id";
		ts.friendlyName="Tab Type";
		if(application.zcore.app.siteHasApp("listing")){
			ts.labelList = "Image,Saved Search";
			ts.valueList = "1,2";
			ts.onclick="switchImageSavedSearch(this);";
		}else{
			ts.labelList = "Image";
			ts.valueList = "1";
		}
		ts.defaultValue = "1";
		ts.style = "border:none;background:none;";
		ts.className = "";
		//ts.required=true;
		ts.statusbar = "";
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript></td>
	</tr>
	<cfif application.zcore.app.siteHasApp("listing")>
		</table>
		<script>
		/* <![CDATA[ */
		function showMLSSearchTable(showTable) {
			var m=document.getElementById("tblSearchOptions");
			var d2=document.getElementById("ajaxnodiv");
			if (showTable == true) {
				var d1=document.getElementById("sajaxyes");
				d1.checked=true;
				d2.style.display="none";
				m.style.display="block";
			} else {
				d2.style.display="inline";
				m.style.display="none";
			}
		}
		
		function switchImageSavedSearch(obj) {
			if(obj.value == 2) {
				showMLSSearchTable(true);
			} else {
				showMLSSearchTable(false);
			}
		}
		/* ]]> */
		</script>
		<table style="width:100%; border-spacing:0px;" id="tblSearchOptions">
			<tr>
				<td style="vertical-align:top; "><strong>MLS Search Options</strong><br />
					<cfscript>
					form.slideshow_tab_search_mls=1;
					request.zos.listing.functions.zMLSSearchOptions(form.mls_saved_search_id, "slideshow_tab_search_mls", form.slideshow_tab_search_mls);
					</cfscript></td>
			</tr>
		</table>
		<table style="width:100%; border-spacing:0px;" class="table-list">
	</cfif>
	<tr>
		<th>&nbsp;</th>
		<td><button type="submit" name="tab_submit" value="Save">Save</button>
			<button type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#&amp;zsid=#request.zsid#';">Cancel</button></td>
	</tr>
	</table>
	#application.zcore.functions.zEndForm()#
	<cfif application.zcore.app.siteHasApp("listing")>
		<cfif form.slideshow_tab_type_id EQ 2>
			<script>/* <![CDATA[ */ zArrDeferredFunctions.push(function(){getMLSCount('zMLSSearchForm'); });/* ]]> */</script>
		</cfif>
		<cfscript>
		if(form.slideshow_tab_type_id EQ 2) {
			showTable = "true";
		} else {
			showTable = "false";
		}
		</cfscript>
		<script>
		/* <![CDATA[ */ 	
		zArrDeferredFunctions.push(function(){
			showMLSSearchTable(#showTable#);
			document.getElementById('search_with_photos_name1').checked=true;
		});
		 /* ]]> */
		</script>
	</cfif>
</cffunction>

<cffunction name="insertTab" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateTab();
	</cfscript>
</cffunction>

<cffunction name="updateTab" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var firstTileCount=0;
	var thumbAreaWidth=0;
	var thumbAreaHeight=0;
	var q=0;
	var qss2=0;
	var tabHeight=0;
	var currentWidth=0;
	var currentHeight=0;
	var imPath=0;
	var arrList=0;
	var overwrite=0;
	var photoResize=0;
	var output=0;
	var qId=0;
	var errors=0;
	var tempUrl=0;
	var ts=0;
	var qM=0;
	var myForm=0;
	var qCheck=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# s
	LEFT JOIN #db.table("slideshow_tab", request.zos.zcoreDatasource)# st 
	ON st.slideshow_id = s.slideshow_id and 
	st.slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
	st.site_id = s.site_id and 
	st.slideshow_tab_deleted = #db.param(0)# and 
	st.slideshow_tab_deleted = #db.param(0)#
	where s.slideshow_id = #db.param(form.slideshow_id)# and 
	s.slideshow_deleted = #db.param(0)# and
	s.slideshow_deleted = #db.param(0)# and
	s.site_id =#db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qcheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"The selected slideshow doesn't exist.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
	}
	db.sql="SELECT max(slideshow_tab_sort) m from #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab
	where slideshow_id=#db.param(form.slideshow_id)# and 
	slideshow_tab_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)# ";
	qM=db.execute("qM");
	if(form.method EQ 'insertTab' and qM.recordcount NEQ 0){
		if(isNumeric(qM.m)){
			form.slideshow_tab_sort=qM.m+1;
		}else{
			form.slideshow_tab_sort=1;
		}
	}
	myForm=structnew();
	if(qCheck.slideshow_tabistext EQ 1){
		myForm.slideshow_tab_caption.required=true;
	}else{
		if(form.method EQ 'insertTab'){
			myForm.slideshow_tab_url.required=true;
			myForm.slideshow_tab_url.friendlyName="Tab Image";
		}
	}
	errors = application.zcore.functions.zValidateStruct(form, myForm,request.zsid, true);
	if(errors){
		if(form.method EQ "updateTab"){
			application.zcore.functions.zRedirect("/z/admin/slideshow/editTab?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/slideshow/addTab?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
		}
	}
	if(DirectoryExists(request.zos.globals.privatehomedir&"zupload/slideshow/"&qCheck.slideshow_id&"/tabs/") EQ false){
    	application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&"zupload/slideshow/"&qCheck.slideshow_id&"/tabs/");
	}
	if(qCheck.slideshow_tabistext EQ 1){
		form.slideshow_tab_url='';
	}else{
		if(trim(form.slideshow_tab_url) EQ '' AND qcheck.slideshow_tab_url NEQ '') {
			form.slideshow_tab_url = qCheck.slideshow_tab_url;
		}
		if(trim(form.slideshow_tab_url) EQ '' AND form.slideshow_tab_type_id EQ '1'){
			application.zcore.status.setStatus(request.zsid,"No File was uploaded.");
			if(form.method EQ 'insertTab'){
				application.zcore.functions.zRedirect('/z/admin/slideshow/addTab?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_tab_id=#application.zcore.functions.zso(form, 'slideshow_tab_id')#');	
			}else{
				application.zcore.functions.zRedirect('/z/admin/slideshow/editTab?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_tab_id=#application.zcore.functions.zso(form, 'slideshow_tab_id')#');	
			}
		}
	}
	
	if(structkeyexists(request.zos,'listing')){
		if(form.method NEQ 'insertTab') {
			db.sql="SELECT mls_saved_search_id FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab
			 where slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
			 slideshow_tab_deleted = #db.param(0)# and
			site_id=#db.param(request.zos.globals.id)#";
			qId=db.execute("qId");
			form.mls_saved_search_id=qid.mls_saved_search_id;
		}else{
			form.mls_saved_search_id="";
		}
		if(form.slideshow_tab_type_id EQ 2) {
			form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, '', form);
		} else if(form.mls_saved_search_id NEQ "") {
			form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.mls_saved_search_id);
			form.mls_saved_search_id="";
		}
	}
	
	photoResize="1000x1000";
	if(application.zcore.functions.zso(form, 'image_overwrite') EQ 1){
		overwrite=true;
	}else{
		overwrite=false;
	}
	
	arrList=ArrayNew(1);
	if(trim(form.slideshow_tab_url) NEQ '') {
		if(form.method EQ 'insertTab'){
			arrList = application.zcore.functions.zUploadResizedImagesToDb("slideshow_tab_url", request.zos.globals.privatehomedir&'zupload/slideshow/'&qCheck.slideshow_id&"/tabs/", photoresize,"","","",request.zos.zcoreDatasource);
		}else{
			arrList = application.zcore.functions.zUploadResizedImagesToDb("slideshow_tab_url", request.zos.globals.privatehomedir&'zupload/slideshow/'&qCheck.slideshow_id&"/tabs/", photoresize, 'slideshow_tab', 'slideshow_tab_id', "slideshow_tab_url_delete",request.zos.zcoreDatasource);
		}
	}
	
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").', form, true);	
		StructDelete(form,'slideshow_tab_url');
		StructDelete(variables,'slideshow_tab_url');
	}else if(ArrayLen(arrList) NEQ 0){
		form.slideshow_tab_url=arrList[1];
	}else if(structkeyexists(form,'slideshow_tab_url_delete')) {
		form.slideshow_tab_url ='';
	} else {
		StructDelete(form,'slideshow_tab_url');
		StructDelete(variables,'slideshow_tab_url');
	}
	imPath=false;
	if(application.zcore.functions.zso(form, 'slideshow_tab_url') EQ '' and form.method EQ 'update'){
		imPath="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/tabs/#qcheck.slideshow_tab_url#";
	}else if(application.zcore.functions.zso(form, 'slideshow_tab_url') NEQ ''){
		imPath="#request.zos.globals.privatehomedir#zupload/slideshow/#form.slideshow_id#/tabs/#form.slideshow_tab_url#";
	}
	form.slideshow_tab_size=0;
	if(qcheck.slideshow_tabistext EQ 0 and imPath NEQ false and fileexists(imPath)){
		local.imageSize=application.zcore.functions.zGetImageSize(imPath); 
		if(not local.imageSize.success){
			application.zcore.status.setStatus(request.zsid, local.imageSize.errorMessage, form, true);
			if(form.method EQ "updateTab"){
				application.zcore.functions.zRedirect("/z/admin/slideshow/editTab?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/admin/slideshow/addTab?slideshow_id=#form.slideshow_id#&zsid="&request.zsid);
			}
		}
		form.slideshow_tab_size=local.imageSize.height; 
	}
	firstTileCount=0;
	db.sql="select count(slideshow_id) count 
	from #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab
	 where slideshow_id=#db.param(form.slideshow_id)# and 
	 slideshow_tab_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)#";
	qss2=db.execute("qss2");
	if(qcheck.slideshow_thumb_width NEQ 0){
		if(qcheck.slideshow_slide_direction EQ "y"){
			if(qcheck.slideshow_tabisText){
				if(qss2.recordcount EQ 1 and qss2.count EQ 1){
					tabHeight=0;
				}else{
					tabHeight=8+(qcheck.slideshow_tabPadding*2);
				}
				thumbAreaHeight=qcheck.slideshow_height-(12+12+(qcheck.slideshow_thumb_padding*2)+tabHeight);
			}else{
				if(qss2.recordcount EQ 1 and qss2.count EQ 1){
					tabHeight=0;
				}else{
					tabHeight=form.slideshow_tab_size;
				}
				thumbAreaHeight=qcheck.slideshow_height-(qcheck.slideshow_back_image_size+qcheck.slideshow_forward_image_size+(qcheck.slideshow_thumb_padding*2)+tabHeight);
			}
			firstTileCount=ceiling(thumbAreaHeight/qcheck.slideshow_thumb_height)+1+qcheck.slideshow_moved_tile_count;
		}else{
			if(qcheck.slideshow_tabisText){
				thumbAreaWidth=qcheck.slideshow_width-(12+12);
			}else{
				thumbAreaWidth=qcheck.slideshow_width-(qcheck.slideshow_back_image_size+qcheck.slideshow_forward_image_size);
			}
			firstTileCount=ceiling(thumbAreaWidth/qcheck.slideshow_thumb_width)+1+qcheck.slideshow_moved_tile_count;
		}
		db.sql="UPDATE #db.table("slideshow", request.zos.zcoreDatasource)# slideshow SET 
		slideshow_tab_size=#db.param(form.slideshow_tab_size)#, 
		slideshow_thumb_display_count=#db.param(firstTileCount)#,
		slideshow_updated_datetime=#db.param(request.zos.mysqlnow)# 
		 where slideshow_id=#db.param(form.slideshow_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		slideshow_deleted = #db.param(0)#";
		q=db.execute("q");
	}else{
		db.sql="UPDATE #db.table("slideshow", request.zos.zcoreDatasource)# slideshow SET 
		slideshow_tab_size=#db.param(form.slideshow_tab_size)#, 
		slideshow_thumb_display_count=#db.param('0')#,
		slideshow_updated_datetime=#db.param(request.zos.mysqlnow)# 
		 where slideshow_id=#db.param(form.slideshow_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		slideshow_deleted = #db.param(0)#";
		q=db.execute("q");
	}
	ts=StructNew();
	ts.table="slideshow_tab";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;

	if(form.method EQ 'insertTab'){
		form.slideshow_tab_id = application.zcore.functions.zInsert(ts);
		if(form.slideshow_tab_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Slideshow Tab with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/addTab?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Slideshow Tab with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/editTab?zsid=#request.zsid#&slideshow_tab_id=#form.slideshow_tab_id#&slideshow_id=#form.slideshow_id#');
		}
	}

	application.zcore.functions.zSlideshowClearCache(form.slideshow_id);

	if(form.method EQ 'insertTab'){
		application.zcore.status.setStatus(request.zsid, "Tab added.");
		if(isDefined('request.zsession.slideshow_return')){
			tempURL = request.zsession['slideshow_return'];
			StructDelete(request.zsession, 'slideshow_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Tab updated.");
	}
	if(structkeyexists(form, 'slideshow_tab_id') and isDefined('request.zsession.slideshow_return'&form.slideshow_id) ) {
		tempURL = request.zsession['slideshow_return'&form.slideshow_id];
		StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#&zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="addPhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editPhoto();
	</cfscript>
</cffunction>

<cffunction name="editPhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qImageData=0;
	var ts=0;
	var newAction=0;
	var currentMethod=form.method;
	var db=request.zos.queryObject;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.5");
    form.slideshow_image_id=application.zcore.functions.zso(form, 'slideshow_image_id');
    if(structkeyexists(form, 'return')){
    	StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
    }
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# s
	LEFT JOIN #db.table("slideshow_image", request.zos.zcoreDatasource)# si 
	ON si.slideshow_id = s.slideshow_id and 
	si.slideshow_image_id = #db.param(form.slideshow_image_id)# and 
	si.site_id = s.site_id and 
	si.slideshow_image_deleted = #db.param(0)#
	where s.slideshow_id=#db.param(form.slideshow_id)# and 
	s.slideshow_deleted = #db.param(0)# and
	s.site_id =#db.param(request.zos.globals.id)# ";
	qImageData=db.execute("qImageData");
    if(qimagedata.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"This image no longer exists.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
    }else if(currentMethod EQ 'editPhoto' and qimagedata.slideshow_image_id EQ ""){
		application.zcore.status.setStatus(request.zsid,"This image no longer exists.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid=#request.zsid#");	
    }
	application.zcore.functions.zQueryToStruct(qImageData,form,'slideshow_tab_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);
    </cfscript>
	<h2>
		<cfif currentMethod EQ 'addPhoto'>
			Add
		<cfelse>
			Edit
		</cfif>
		Tab Photo</h2>
	<p><cfif currentMethod NEQ 'editPhoto'>
		<strong style="color:##FF0000;">NEW:</strong> Now supports ZIP archives to allow uploading & resizing of multiple photos in one step.<br />
		<br />
	</cfif>
	
	The photo size required for a perfect fit is: #qImageData.slideshow_width#x#qImageData.slideshow_height#<br />
	<br />
	Select a .gif, .jpg, or .png image
	<cfif currentMethod NEQ 'editPhoto'>
		or a .ZIP archive with .gif, .jpg, and .png files inside
	</cfif>
	</p>
	<cfscript>
    ts=StructNew();
    ts.name="zMLSSearchForm";
    ts.ajax=false;
    if(currentMethod EQ 'addPhoto'){
        newAction="insertPhoto";
    }else{
        newAction="updatePhoto";
    }
	ts.class="zFormCheckDirty";
    ts.enctype="multipart/form-data";
    ts.action="/z/admin/slideshow/#newAction#?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&slideshow_image_id=#form.slideshow_image_id#";
    ts.method="post";
    ts.successMessage=false;
    application.zcore.functions.zForm(ts);
    
    </cfscript>
	<table class="table-list">
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Select File","member.slideshow.editPhoto slideshow_image_thumbnail_url")#</th>
			<td>#application.zcore.functions.zInputImage('slideshow_image_thumbnail_url', request.zos.globals.privatehomedir & 'zupload/slideshow/' & form.slideshow_id & '/', request.zos.currentHostName & '/zupload/slideshow/' & form.slideshow_id & '/')#</td>
		</tr>
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Photo Caption","member.slideshow.editPhoto slideshow_image_caption")#</th>
			<td><input type="text" size="50" name="slideshow_image_caption" id="slideshow_image_caption" value="#HTMLEditFormat(form.slideshow_image_caption)#"></td>
		</tr>
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Photo Thumbnail<br />Caption","member.slideshow.editPhoto slideshow_image_thumb_caption")#</th>
			<td><textarea type="text" cols="30" rows="4" name="slideshow_image_thumb_caption" id="slideshow_image_thumb_caption">#HTMLEditFormat(form.slideshow_image_thumb_caption)#</textarea></td>
		</tr>
		<tr>
		<tr>
			<th>#application.zcore.functions.zOutputHelpToolTip("Photo Link","member.slideshow.editPhoto slideshow_image_link")#</th>
			<td><input type="text" size="50" name="slideshow_image_link" id="slideshow_image_link" value="#HTMLEditFormat(form.slideshow_image_link)#"></td>
		</tr>
		<cfif currentMethod NEQ 'editPhoto'>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Overwrite<br />Existing Files?","member.slideshow.editPhoto image_overwrite")#</th>
				<td><input type="radio" name="image_overwrite" value="1" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
					Yes
					<input type="radio" name="image_overwrite" value="0" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 0 or application.zcore.functions.zso(form, 'image_overwrite') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
					No </td>
			</tr>
		</cfif>
		<tr>
			<th>&nbsp;</th>
			<td><input type="submit" name="image_submit" value="Upload Image">
				<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&amp;slideshow_tab_id=#form.slideshow_tab_id#&amp;zsid=#request.zsid#';" /></td>
		</tr>
	</table>
	#application.zcore.functions.zEndForm()#
</cffunction>

<cffunction name="insertPhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updatePhoto();
	</cfscript>
</cffunction>

<cffunction name="updatePhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var photoResize=0;
	var arrList=0;
	var ts=0;
	var tempURL=0;
	var overwrite=0;
	var qM=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Slideshows", true);	
	form.slideshow_image_id=application.zcore.functions.zso(form, 'slideshow_image_id');
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# s
	LEFT JOIN #db.table("slideshow_image", request.zos.zcoreDatasource)# si ON 
	si.slideshow_id = s.slideshow_id and 
	si.slideshow_image_deleted = #db.param(0)# and 
	si.slideshow_image_id = #db.param(form.slideshow_image_id)# and 
	si.site_id = s.site_id
	where s.slideshow_id=#db.param(form.slideshow_id)# and 
	s.slideshow_deleted = #db.param(0)# and
	s.site_id =#db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qcheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"The selected slideshow doesn't exist.");
		application.zcore.functions.zRedirect("/z/admin/slideshow/index?zsid=#request.zsid#");	
	}
	if(DirectoryExists(request.zos.globals.privatehomedir&"zupload/slideshow/"&qCheck.slideshow_id&"/") EQ false){
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&"zupload/slideshow/");
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&"zupload/slideshow/"&qCheck.slideshow_id&"/");
	}
	db.sql="SELECT max(slideshow_image_sort) m 
	from #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image
	where slideshow_id=#db.param(form.slideshow_id)# and 
	slideshow_image_deleted = #db.param(0)# and 
	slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qM=db.execute("qM");
	if(form.method EQ 'insertPhoto' and qM.recordcount NEQ 0){
		if(isNumeric(qM.m)){
			form.slideshow_image_sort=qM.m+1;
		}else{
			form.slideshow_image_sort=1;
		}
	}
	
	if(trim(form.slideshow_image_thumbnail_url) EQ '' AND qcheck.slideshow_image_thumbnail_url NEQ '') {
		form.slideshow_image_thumbnail_url = qCheck.slideshow_image_thumbnail_url;
	}

	if(trim(form.slideshow_image_thumbnail_url) EQ ''){
		application.zcore.status.setStatus(request.zsid,"No File was uploaded.",form,true);
		if(form.method EQ 'insertPhoto'){
			application.zcore.functions.zRedirect('/z/admin/slideshow/addPhoto?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#');	
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/editPhoto?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_image_id=#application.zcore.functions.zso(form, 'slideshow_image_id')#&slideshow_tab_id=#form.slideshow_tab_id#');	
		}
	}
	
	photoResize=qcheck.slideshow_thumb_width&"x"& qcheck.slideshow_thumb_height&","&qCheck.slideshow_width&"x"&qCheck.slideshow_height;
	if(application.zcore.functions.zso(form,'image_overwrite') EQ 1){
		overwrite=true;
	}else{
		overwrite=false;
	}
	
	arrList=ArrayNew(1);
	
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("slideshow_image_thumbnail_url,slideshow_image_url", request.zos.globals.privatehomedir&'zupload/slideshow/'&qCheck.slideshow_id&'/',photoresize,"","","",request.zos.zcoreDatasource,"1,1");
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("slideshow_image_thumbnail_url,slideshow_image_url", request.zos.globals.privatehomedir&'zupload/slideshow/'&qCheck.slideshow_id&'/',photoresize, 'slideshow_image', 'slideshow_image_id', "slideshow_image_thumbnail_url_delete",request.zos.zcoreDatasource,"1,1");
	}
	
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please check the file is a valid 8-bit RGB color image (not CMYK).', form, true);	
		if(form.method EQ 'insertPhoto'){
			application.zcore.functions.zRedirect('/z/admin/slideshow/addPhoto?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#');	
		}else{
			application.zcore.functions.zRedirect('/z/admin/slideshow/editPhoto?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#&slideshow_image_id=#application.zcore.functions.zso(form, 'slideshow_image_id')#&slideshow_tab_id=#form.slideshow_tab_id#');	
		}
		StructDelete(form,'slideshow_image_thumbnail_url');
		StructDelete(variables,'slideshow_image_thumbnail_url');
	}else if(ArrayLen(arrList) EQ 2){
		form.slideshow_image_thumbnail_url=arrList[1];
		form.slideshow_image_url=arrList[2];
	}else{
		StructDelete(form,'slideshow_image_thumbnail_url');
		StructDelete(variables,'slideshow_image_thumbnail_url');
	}

	ts=StructNew();
	ts.struct=form;
	ts.table="slideshow_image";
	ts.datasource=request.zos.zcoreDatasource;
	
	if(form.method EQ 'insertPhoto'){
		form.slideshow_image_id = application.zcore.functions.zInsert(ts);
		if(form.slideshow_image_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Slideshow Image with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/addPhoto?zsid=#request.zsid#&slideshow_id=#form.slideshow_id#');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Slideshow Image with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/editPhoto?zsid=#request.zsid#&slideshow_image_id=#form.slideshow_image_id#&slideshow_id=#form.slideshow_id#');
		}
	}
	application.zcore.functions.zSlideshowClearCache(form.slideshow_id);
		
	if(form.method EQ 'insert'){
		application.zcore.status.setStatus(request.zsid, "Image added.");
		if(isDefined('request.zsession.slideshow_return')){
			tempURL = request.zsession['slideshow_return'];
			StructDelete(request.zsession, 'slideshow_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Image updated.");
	}
	if(structkeyexists(form, 'slideshow_image_id') and isDefined('request.zsession.slideshow_return'&form.slideshow_id) ) {
		tempURL = request.zsession['slideshow_return'&form.slideshow_id];
		StructDelete(request.zsession, 'slideshow_return'&form.slideshow_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/slideshow/managephoto?slideshow_id=#form.slideshow_id#&slideshow_tab_id=#form.slideshow_tab_id#&zsid=#request.zsid#');
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
	var db=request.zos.queryObject;
	var ts=0;
	var tabCom=0;
	var cancelURL=0;
	var htmlEditor=0;
	var newAction=0;
	var qSlideshow=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.1");
	form.slideshow_id=application.zcore.functions.zso(form,'slideshow_id');
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	WHERE slideshow_id = #db.param(form.slideshow_id)# and 
	slideshow_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qSlideshow=db.execute("qSlideshow");
	if(currentMethod EQ 'edit'){
		if(qSlideshow.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this slideshow.',false,true);
			application.zcore.functions.zRedirect('/z/admin/slideshow/index?zsid=#request.zsid#');
		}
	}
	application.zcore.functions.zQueryToStruct(qSlideshow,form,'slideshow_id,site_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "slideshow_return"&form.slideshow_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
		<cfelse>
			Edit
		</cfif>
		Slideshow</h2>
	<cfscript>
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	if(currentMethod EQ 'add'){
		newAction="insert";
	}else{
		newAction="update";
	}
	ts.class="zFormCheckDirty";
	ts.enctype="multipart/form-data";
	ts.action="/z/admin/slideshow/#newAction#?slideshow_id=#form.slideshow_id#";
	ts.method="post";
	ts.successMessage=false;
	application.zcore.functions.zForm(ts);
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
	tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
	tabCom.setMenuName("member-slideshow-edit");
	cancelURL=application.zcore.functions.zso(request.zsession,'slideshow_return'&form.slideshow_id);
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	</cfscript>
	#tabCom.beginTabMenu()# 
	#tabCom.beginFieldSet("Basic")#
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Name","member.slideshow.edit slideshow_name")#</th>
			<td style="vertical-align:top; ">
				<cfif form.slideshow_locked EQ 1>
					#form.slideshow_name#
					<input type="hidden" name="slideshow_name" value="#HTMLEditFormat(form.slideshow_name)#" size="50" />
				<cfelse>
					<input type="text" name="slideshow_name" value="#HTMLEditFormat(form.slideshow_name)#" size="50" />
				</cfif></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slideshow","member.slideshow.edit slideshow_text")#</th>
			<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "slideshow_text";
            htmlEditor.value			= form.slideshow_text;
            htmlEditor.width			= "100%";
            htmlEditor.height		= 200;
            htmlEditor.create();
            </cfscript></td>
		</tr>
	</table>
	#tabCom.endFieldSet()# #tabCom.beginFieldSet("Advanced")#
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr>
			<th style="vertical-align:top; width:155px !important;">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.slideshow.edit slideshow_metakey")#</th>
			<td style="vertical-align:top; "><textarea name="slideshow_metakey" rows="5" cols="60">#form.slideshow_metakey#</textarea></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.slideshow.edit slideshow_metadesc")#</th>
			<td style="vertical-align:top; "><textarea name="slideshow_metadesc" cols="60" rows="5">#form.slideshow_metadesc#</textarea></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Width","member.slideshow.edit slideshow_width")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_width" value="<cfif form.slideshow_width EQ "">#request.zos.globals.maximagewidth#<cfelse>#HTMLEditFormat(form.slideshow_width)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Height","member.slideshow.edit slideshow_height")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_height" value="<cfif form.slideshow_height EQ "">188<cfelse>#HTMLEditFormat(form.slideshow_height)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Type","member.slideshow.edit slideshow_tabistext")#</th>
			<td style="vertical-align:top; "><script>
			/* <![CDATA[ */
			  function toggletabtext(o){
				var a2=document.getElementById("tabtexttable");
				var a3=document.getElementById("tabimagetable");
				if(o.value == 1){
					a2.style.display="block";
					a3.style.display="none";
				}else{
					a2.style.display="none";
					a3.style.display="block";
				}
			  }
			  /* ]]> */
			  </script>
				<cfscript>
				if(form.slideshow_tabistext EQ ""){
					form.slideshow_tabistext=1;
				}
				ts= StructNew();
				ts.name = "slideshow_tabistext";
				ts.valueList = "1,0";
				ts.labelList= "Text,Image";
				ts.style="border:none; background:none;";
				ts.onclick="toggletabtext(this);";
				ts.output=true;
				application.zcore.functions.zInput_RadioGroup(ts);
				application.zcore.functions.zIncludeJsColor();
				</cfscript>
				<br />
				<br />
				<table id="tabtexttable" <cfif form.slideshow_tabistext EQ 0>style="display:none;"</cfif>>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Background Color","member.slideshow.edit slideshow_tabbgcolor")#</th>
						<td style="vertical-align:top; "><input type="text" class="zColorInput {required:false}" name="slideshow_tabbgcolor" value="<cfif form.slideshow_tabbgcolor EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.slideshow_tabbgcolor)#</cfif>" size="10" /></td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Text Color","member.slideshow.edit slideshow_tabtextcolor")#</th>
						<td style="vertical-align:top; "><input type="text" class="zColorInput {required:false}" name="slideshow_tabtextcolor" value="<cfif form.slideshow_tabtextcolor EQ "">000000<cfelse>#HTMLEditFormat(form.slideshow_tabtextcolor)#</cfif>" size="10" /></td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Over Background Color","member.slideshow.edit slideshow_taboverbgcolor")#</th>
						<td style="vertical-align:top; "><input type="text" class="zColorInput {required:false}" name="slideshow_taboverbgcolor" value="<cfif form.slideshow_taboverbgcolor EQ "">000000<cfelse>#HTMLEditFormat(form.slideshow_taboverbgcolor)#</cfif>" size="10" /></td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Over Text Color","member.slideshow.edit slideshow_tabovertextcolor")#</th>
						<td style="vertical-align:top; "><input type="text" class="zColorInput {required:false}" name="slideshow_tabovertextcolor" value="<cfif form.slideshow_tabovertextcolor EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.slideshow_tabovertextcolor)#</cfif>" size="10" /></td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Padding","member.slideshow.edit slideshow_tabpadding")#</th>
						<td style="vertical-align:top; "><input type="text" name="slideshow_tabpadding" value="<cfif form.slideshow_tabpadding EQ "">5<cfelse>#HTMLEditFormat(form.slideshow_tabpadding)#</cfif>" size="10" /></td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Tab Side Padding","member.slideshow.edit slideshow_tabsidepadding")#</th>
						<td style="vertical-align:top; "><input type="text" name="slideshow_tabsidepadding" value="<cfif form.slideshow_tabsidepadding EQ "">15<cfelse>#HTMLEditFormat(form.slideshow_tabsidepadding)#</cfif>" size="10" /></td>
					</tr>
				</table>
				<table id="tabimagetable" <cfif form.slideshow_tabistext EQ 1 or form.slideshow_tabistext EQ ''>style="display:none;"</cfif>>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Back Image","member.slideshow.edit slideshow_back_image")#</th>
						<td style="vertical-align:top; ">#application.zcore.functions.zInputImage('slideshow_back_image', request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', request.zos.currentHostName&'/zupload/slideshow/' & form.slideshow_id & '/')# </td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Forward Image","member.slideshow.edit slideshow_forward_image")#</th>
						<td style="vertical-align:top; ">#application.zcore.functions.zInputImage('slideshow_forward_image', request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', request.zos.currentHostName&'/zupload/slideshow/' & form.slideshow_id & '/')# </td>
					</tr>
					<tr>
						<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Background Image","member.slideshow.edit slideshow_background_image")#</th>
						<td style="vertical-align:top; ">#application.zcore.functions.zInputImage('slideshow_background_image', request.zos.globals.privatehomedir&'zupload/slideshow/' & form.slideshow_id & '/', request.zos.currentHostName&'/zupload/slideshow/' & form.slideshow_id & '/')# </td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Padding","member.slideshow.edit slideshow_thumb_padding")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_padding" value="<cfif form.slideshow_thumb_padding EQ "">4<cfelse>#HTMLEditFormat(form.slideshow_thumb_padding)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Area Padding","member.slideshow.edit slideshow_thumb_area_padding")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_area_padding" value="<cfif form.slideshow_thumb_area_padding EQ "">0<cfelse>#HTMLEditFormat(form.slideshow_thumb_area_padding)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Width","member.slideshow.edit slideshow_thumb_width")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_width" value="<cfif form.slideshow_thumb_width EQ "">115<cfelse>#HTMLEditFormat(form.slideshow_thumb_width)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Height","member.slideshow.edit slideshow_thumb_height")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_height" value="<cfif form.slideshow_thumb_height EQ "">83<cfelse>#HTMLEditFormat(form.slideshow_thumb_height)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Text Height","member.slideshow.edit slideshow_thumb_text_height")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_text_height" value="<cfif form.slideshow_thumb_text_height EQ "">63<cfelse>#HTMLEditFormat(form.slideshow_thumb_text_height)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Margin Left","member.slideshow.edit slideshow_thumb_margin_left")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_margin_left" value="<cfif form.slideshow_thumb_margin_left EQ "">0<cfelse>#HTMLEditFormat(form.slideshow_thumb_margin_left)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbnail Margin Top","member.slideshow.edit slideshow_thumb_margin_top")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumb_margin_top" value="<cfif form.slideshow_thumb_margin_top EQ "">5<cfelse>#HTMLEditFormat(form.slideshow_thumb_margin_top)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Thumbbar Margin","member.slideshow.edit slideshow_thumbbar_margin")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_thumbbar_margin" value="<cfif form.slideshow_thumbbar_margin EQ "">5<cfelse>#HTMLEditFormat(form.slideshow_thumbbar_margin)#</cfif>" size="10" /></td>
		</tr>
		<cfif application.zcore.user.checkServerAccess()>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Custom CFM Include","member.slideshow.edit slideshow_custom_include")#</th>
				<td style="vertical-align:top; "><input type="text" name="slideshow_custom_include" value="#htmleditformat(form.slideshow_custom_include)#" /></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Format","member.slideshow.edit slideshow_format")#</th>
				<td style="vertical-align:top; "><input type="radio" name="slideshow_format" value="1" style="border:none; background:none;" <cfif form.slideshow_format EQ 1>checked="checked"</cfif> />
					HTML
					<input type="radio" name="slideshow_format" value="0" style="border:none; background:none;" <cfif form.slideshow_format EQ 0 or form.slideshow_format EQ ''>checked="checked"</cfif> />
					Flash (Note: HTML doesn't work for all features yet.) </td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Enable Ajax","member.slideshow.edit slideshow_enable_ajax")#</th>
				<td style="vertical-align:top; "><input type="radio" name="slideshow_enable_ajax" value="1" style="border:none; background:none;" <cfif form.slideshow_enable_ajax EQ 1>checked="checked"</cfif> />
					Yes
					<input type="radio" name="slideshow_enable_ajax" value="0" style="border:none; background:none;" <cfif form.slideshow_enable_ajax EQ 0 or form.slideshow_enable_ajax EQ ''>checked="checked"</cfif> />
					No</td>
			</tr>
		</cfif>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Included Images","member.slideshow.edit slideshow_large_image")#</th>
			<td style="vertical-align:top; "><input type="radio" name="slideshow_large_image" value="2" style="border:none; background:none;" <cfif form.slideshow_large_image EQ 2>checked="checked"</cfif> />
				Large Images Only
				<input type="radio" name="slideshow_large_image" value="1" style="border:none; background:none;" <cfif form.slideshow_large_image EQ 1>checked="checked"</cfif> />
				Thumbnails Only
				<input type="radio" name="slideshow_large_image" value="0" style="border:none; background:none;" <cfif form.slideshow_large_image EQ 0 or form.slideshow_large_image EQ ''>checked="checked"</cfif> />
				Large Images &amp; Thumbnail </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Resize Image?","member.slideshow.edit slideshow_resize_image")#</th>
			<td style="vertical-align:top; "><input type="radio" name="slideshow_resize_image" value="1" style="border:none; background:none;" <cfif form.slideshow_resize_image EQ 1 or form.slideshow_resize_image EQ ''>checked="checked"</cfif> />
				Yes
				<input type="radio" name="slideshow_resize_image" value="0" style="border:none; background:none;" <cfif form.slideshow_resize_image EQ 0>checked="checked"</cfif> />
				No </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Resize Image Bottom?","member.slideshow.edit slideshow_resize_image_bottom")#</th>
			<td style="vertical-align:top; "><input type="radio" name="slideshow_resize_image_bottom" value="1" style="border:none; background:none;" <cfif form.slideshow_resize_image_bottom EQ 1 or form.slideshow_resize_image_bottom EQ ''>checked="checked"</cfif> />
				Yes
				<input type="radio" name="slideshow_resize_image_bottom" value="0" style="border:none; background:none;" <cfif form.slideshow_resize_image_bottom EQ 0>checked="checked"</cfif> />
				No </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Image Fade Duration","member.slideshow.edit slideshow_image_fade_duration")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_image_fade_duration" value="<cfif form.slideshow_image_fade_duration EQ "">70<cfelse>#HTMLEditFormat(form.slideshow_image_fade_duration)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("X Duration","member.slideshow.edit slideshow_x_duration")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_x_duration" value="<cfif form.slideshow_x_duration EQ "">70<cfelse>#HTMLEditFormat(form.slideshow_x_duration)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Y Duration","member.slideshow.edit slideshow_y_duration")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_y_duration" value="<cfif form.slideshow_y_duration EQ "">70<cfelse>#HTMLEditFormat(form.slideshow_y_duration)#</cfif>" size="10" /></td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Auto Slide Delay","member.slideshow.edit slideshow_auto_slide_delay")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_auto_slide_delay" value="<cfif form.slideshow_auto_slide_delay EQ "">0<cfelse>#HTMLEditFormat(form.slideshow_auto_slide_delay)#</cfif>" size="10" />
				(Set to zero to disable auto slide) </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slide Direction?","member.slideshow.edit slideshow_slide_direction")#</th>
			<td style="vertical-align:top; "><input type="radio" name="slideshow_slide_direction" value="x" style="border:none; background:none;" <cfif form.slideshow_slide_direction EQ 'x' or form.slideshow_slide_direction EQ ''>checked="checked"</cfif> />
				X (horizontal)
				<input type="radio" name="slideshow_slide_direction" value="y" style="border:none; background:none;" <cfif form.slideshow_slide_direction EQ 'y'>checked="checked"</cfif> />
				Y  (vertical) </td>
		</tr>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Moved Tile Count","member.slideshow.edit slideshow_moved_tile_count")#</th>
			<td style="vertical-align:top; "><input type="text" name="slideshow_moved_tile_count" value="<cfif form.slideshow_moved_tile_count EQ "">5<cfelse>#HTMLEditFormat(form.slideshow_moved_tile_count)#</cfif>" size="10" /></td>
		</tr>
		<cfif application.zcore.user.checkSiteAccess()>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Lock slideshow?","member.slideshow.edit slideshow_locked")#</th>
				<td style="vertical-align:top; "><input type="radio" name="slideshow_locked" value="1" <cfif form.slideshow_locked EQ 1 or form.slideshow_locked EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
					Yes
					<input type="radio" name="slideshow_locked" value="0" <cfif form.slideshow_locked EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
					No </td>
			</tr>
		</cfif>
		<tr>
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Show on site map?","member.slideshow.edit slideshow_show_site_map")#</th>
			<td style="vertical-align:top; "><input type="radio" name="slideshow_show_site_map" value="1" <cfif application.zcore.functions.zso(form, 'slideshow_show_site_map') EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
				Yes
				<input type="radio" name="slideshow_show_site_map" value="0" <cfif application.zcore.functions.zso(form, 'slideshow_show_site_map') EQ 0 or application.zcore.functions.zso(form, 'slideshow_show_site_map') EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
				No </td>
		</tr>
	</table>
	#tabCom.endFieldSet()# 
	#tabCom.endTabMenu()# 
	#application.zcore.functions.zEndForm()#
	<cfscript>
	if(currentMethod EQ "edit"){
		form.method=currentMethod;
		this.manageTabs();
	}
	</cfscript>
</cffunction>

<cffunction name="managePhoto" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qImages=0;
	var qS=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.4");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	db.sql="SELECT * FROM #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image
	where slideshow_id=#db.param(form.slideshow_id)# and 
	slideshow_image.slideshow_tab_id = #db.param(form.slideshow_tab_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	slideshow_image_deleted = #db.param(0)#
	ORDER BY slideshow_image_sort ASC, slideshow_image_caption ASC";
	qImages=db.execute("qImages");
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	where slideshow.site_id = #db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)# and 
	slideshow_id = #db.param(form.slideshow_id)#";
	qS=db.execute("qS");
	</cfscript>
	<h2 style="display:inline; ">Manage Tab Photos | </h2>
	<a href="/z/admin/slideshow/index">Manage Slideshow</a> | 
	<a href="/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#">Manage Tabs</a><br />
	<br />
	<a href="/z/admin/slideshow/index">Manage Slideshows</a> / 
	<a href="/z/admin/slideshow/manageTabs?slideshow_id=#form.slideshow_id#">Manage Slideshow: #qS.slideshow_name#</a> / <br />
	<br />
	<h2>Manage Slideshow Photos: #qS.slideshow_name#</h2>
	<a href="/z/admin/slideshow/addPhoto?slideshow_id=#form.slideshow_id#&amp;slideshow_tab_id=#form.slideshow_tab_id#&amp;return=1">Add Photo</a><br />
	<br />
	<cfif qImages.recordcount EQ 0>
		<p>No tab photos added yet, click Add Tab Photos above.</p>
	<cfelse>
		<table id="sortRowTable" style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th style="width:100px;">&nbsp;</th>
				<th>Image Caption</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
			<cfloop query="qImages"> 
				<tr #variables.queueSortCom.getRowHTML(qImages.slideshow_image_id)# <cfif qImages.currentrow MOD 2 EQ 0>class="table-bright"<cfelse>class="table-white"</cfif>>
					<td style="width:100px;"><img src="/zupload/slideshow/#qImages.slideshow_id#/#qImages.slideshow_image_thumbnail_url#" /></td>
					<td>#qImages.slideshow_image_caption#</td>
					<td>#variables.queueSortCom.getAjaxHandleButton(qImages.slideshow_image_id)#</td>
					<td><!--- #variables.queueSortCom.getLinks(qImages.recordcount, qImages.currentrow, 
					'/z/admin/slideshow/managePhoto?slideshow_id=#qImages.slideshow_id#&slideshow_tab_id=#qImages.slideshow_tab_id#&slideshow_image_id=#qImages.slideshow_image_id#', 
					"vertical-arrows")#  --->
					<a href="/zupload/slideshow/#qImages.slideshow_id#/#qImages.slideshow_image_url#">Download</a> | 
					<a href="/z/admin/slideshow/editPhoto?slideshow_id=#qImages.slideshow_id#&amp;slideshow_image_id=#qImages.slideshow_image_id#&amp;slideshow_tab_id=#qImages.slideshow_tab_id#&amp;return=1">Edit</a> | 
					<a href="/z/admin/slideshow/deletePhoto?slideshow_id=#qImages.slideshow_id#&amp;slideshow_image_id=#qImages.slideshow_image_id#&amp;slideshow_tab_id=#qImages.slideshow_tab_id#&amp;return=1">Delete</a></td>
				</tr>
			</cfloop>
			</tbody>
		</table>
	</cfif>
	
</cffunction>

<cffunction name="manageTabs" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qTabs=0;
	var qS=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.4.2");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	db.sql="SELECT * FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab  
	where slideshow_tab.site_id = #db.param(request.zos.globals.id)# AND 
	slideshow_tab_deleted = #db.param(0)# and
	slideshow_tab.slideshow_id = #db.param(form.slideshow_id)# GROUP BY slideshow_tab.slideshow_tab_id 
	ORDER BY slideshow_tab_sort ASC, slideshow_tab_caption ASC ";
	qTabs=db.execute("qTabs");
	db.sql="SELECT * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	where slideshow.site_id = #db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)# and
	slideshow_id = #db.param(form.slideshow_id)#";
	qS=db.execute("qS");
	</cfscript>
	<cfif form.method EQ "edit">
		<br />
		<br />
		<h2 style="display:inline; ">Manage Tabs </h2>
		<br />
		<br />
	<cfelse>
		<h2 style="display:inline; ">Manage Tabs | </h2>
		<a href="/z/admin/slideshow/index">Manage Slideshows</a> <br />
		<br />
		<a href="/z/admin/slideshow/index">Manage Slideshows</a> / <br />
		<br />
		<h2>Manage Slideshow Tabs: #qS.slideshow_name#</h2>
	</cfif>
	<a href="/z/admin/slideshow/addTab?slideshow_id=#form.slideshow_id#&amp;return=1">Add Tab</a> | You must create at least 1 tab to have a slideshow. Images or other information are associates with tabs<br />
	<br />
	<table id="sortRowTable" style="border-spacing:0px; width:100%;" class="table-list">
		<thead>
		<tr>
			<th>&nbsp;</th>
			<th>Tab Caption</th>
			<th>Tab Link</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfif qTabs.recordcount EQ 0>
			<tr>
				<td colspan="2">No Tabs added yet, click Add Tab above.</td>
			</tr>
		</cfif>
		<cfloop query="qTabs">
			<cfscript>
			variables.queueSortCom.getRowStruct(qTabs.slideshow_tab_id);
			</cfscript>
			<tr #variables.queueSortCom.getRowHTML(qTabs.slideshow_tab_id)# <cfif qTabs.currentrow MOD 2 EQ 0>class="table-bright"<cfelse>class="table-white"</cfif>>
				<td><cfif trim(qTabs.slideshow_tab_url) NEQ ''>
						<img src="/zupload/slideshow/#qTabs.slideshow_id#/tabs/#qTabs.slideshow_tab_url#" width="100" />
					<cfelse>
						&nbsp;
					</cfif></td>
				<td>#qTabs.slideshow_tab_caption#</td>
				<td>#qTabs.slideshow_tab_link#</td>
				<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qTabs.slideshow_tab_id)#</td>
				<td><!--- #variables.queueSortCom.getLinks(qTabs.recordcount, qTabs.currentrow, '/z/admin/slideshow/manageTabs?slideshow_id=#qTabs.slideshow_id#&slideshow_tab_id=#qTabs.slideshow_tab_id#', "vertical-arrows")# ---> <a href="/z/admin/slideshow/editTab?slideshow_id=#qTabs.slideshow_id#&amp;slideshow_tab_id=#qTabs.slideshow_tab_id#&amp;return=1">Edit</a> |
				<cfif qTabs.slideshow_tab_type_id EQ 1>
					<a href="/z/admin/slideshow/managePhoto?slideshow_id=#qTabs.slideshow_id#&amp;slideshow_tab_id=#qTabs.slideshow_tab_id#&amp;return=1">Manage Photos</a> |
				<cfelseif qTabs.slideshow_tab_type_id EQ 2>
					Saved Search |
				</cfif>
				<a href="/z/admin/slideshow/deleteTab?slideshow_id=#qTabs.slideshow_id#&amp;slideshow_tab_id=#qTabs.slideshow_tab_id#&amp;return=1">Delete</a></td>
			</tr>
		</cfloop>
		</tbody>
	</table>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qSite=0;
	var qSortCom=0;
	var zSSId=0;
	var zSSIndex=0;
	variables.init(); 
	application.zcore.functions.zSetPageHelpId("2.4");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	qSortCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.querySort");
	zSSId = qSortCom.init("zSSId");
	if(structkeyexists(form, 'zSSIndex')){
		application.zcore.status.setField(zSSId, "zSSIndex", zSSIndex);
	}else{
		zSSIndex = application.zcore.status.getField(zSSId, "zSSIndex", 1, true);
		if(zSSIndex EQ ""){
			zSSIndex = 1;
			qSortCom.setDefault("slideshow.slideshow_id", "ASC");
		}
	}
	</cfscript>
	<h2>Manage Slideshow</h2>
	<p>Note: You may want to contact the web developer for assistance creating new slideshows using this feature.  This feature requires advanced configuration to display correctly. <strong>It is easier to create slideshows using the Add/Edit Page photo library and photo layout features instead.</strong></p>
	<cfscript>
	db.sql="SELECT *  FROM #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	WHERE slideshow.site_id = #db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)#
	GROUP BY slideshow.slideshow_id";
	local.sortBy=qSortCom.getOrderBy(true);
	if(local.sortBy NEQ ''){
		db.sql&=local.sortBy;
	}
	qSite=db.execute("qSite");
	</cfscript>
	<div style="width:65%; text-align:left; float:left;">You must delete all tabs before you can delete a slideshow.</div>
	<div style="width:35%; text-align:right; float:right;"> <a href="/z/admin/slideshow/add?return=1"><strong style="font-size:14px;">Add Slideshow</strong></a> </div>
	<br />
	<cfif qSite.recordcount NEQ 0>
		<br />
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th><a href="#qSortCom.getColumnURL("slideshow.slideshow_id", "/z/admin/slideshow/index")#">ID</a> #qSortCom.getColumnIcon("slideshow.slideshow_id")#</th>
				<th><a href="#qSortCom.getColumnURL("slideshow.slideshow_name", "/z/admin/slideshow/index")#">Title</a> #qSortCom.getColumnIcon("slideshow.slideshow_name")# </th>
				<th>Admin</th>
			</tr>
			<cfloop query="qSite">
				<tr <cfif qSite.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td style="vertical-align:top; width:30px; ">#qSite.slideshow_id#</td>
					<td style="vertical-align:top; ">#qSite.slideshow_name# </td>
					<td style="vertical-align:top; white-space:nowrap;">
					<a href="/z/admin/slideshow/viewembed?slideshow_id=#qSite.slideshow_id#" target="_blank">View/Embed</a> | 
					<a href="/z/admin/slideshow/edit?slideshow_id=#qSite.slideshow_id#&amp;return=1">Edit</a> | 
					<a href="/z/admin/slideshow/copy?slideshow_id=#qSite.slideshow_id#&amp;return=1">Copy</a> | 
					<a href="/z/admin/slideshow/manageTabs?slideshow_id=#qSite.slideshow_id#">Manage Tabs</a>
						<cfif qSite.slideshow_locked EQ 0>
							| <a href="/z/admin/slideshow/delete?slideshow_id=#qSite.slideshow_id#&amp;return=1">Delete</a>
							<cfelse>
							| <span style="color:##999999;">Delete Disabled</span>
						</cfif></td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>

<cffunction name="viewEmbed" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qS=0;
	var theEmbed=0;
	db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	where slideshow_id = #db.param(form.slideshow_id)# and 
	slideshow_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qS=db.execute("qS");
	</cfscript>
	<cfsavecontent variable="theEmbed">
	<iframe src="#request.zos.currentHostName#/z/misc/slideshow/embed?action=slideshow&slideshow_id=#form.slideshow_id#" width="#qs.slideshow_width#" height="#qs.slideshow_height#"  style="border:none; overflow:auto;" seamless="seamless"></iframe>
	</cfsavecontent>
	<h2>View Slideshow</h2>
#theEmbed# 	<br />
	<hr />
	<h2>Embed Slideshow</h2>
	<cfif qS.slideshow_custom_include NEQ "">
		<p>This is a custom slideshow and can't be embedded without developer assistance.</p>
		<cfelse>
		<p>You can copy the code below to any HTML based web site on the Internet to make this slideshow visible there.</p>
		<textarea style="width:100%; height:50px; font-size:14px;" onclick="this.select();">#htmleditformat(theEmbed)#</textarea>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
