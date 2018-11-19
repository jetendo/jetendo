<cfcomponent displayname="rental" hint="rental Application">
	<cfoutput>
	<cfscript>
	this.app_id=13;
	</cfscript>
    
    
    <cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
    	<cfargument name="site_id" type="numeric" required="yes">
        <cfscript>
		return "";
		</cfscript>
    </cffunction>
    
    <cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
    	<cfscript>
		</cfscript>
    </cffunction>
    
<!--- application.zcore.app.getAppCFC("rental").searchReindexRental(false, true); --->
<cffunction name="searchReindexRental" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexeverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental, 
		#db.table("rental_config", request.zos.zcoreDatasource)# rental_config
		WHERE 
		rental_deleted = #db.param(0)# and 
		rental_config_deleted = #db.param(0)# and
		rental_config.site_id = rental.site_id  and 
		rental.rental_active = #db.param(1)# ";
		if(arguments.indexeverything EQ false){
			db.sql&="  and rental.site_id = #db.param(request.zos.globals.id)#  ";
		}else{
			db.sql&="  and rental.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and rental_id = #db.param(arguments.id)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteRental(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.rental_name&" "&row.rental_description&" "&row.rental_amenities_text&" "&row.rental_rate_text&" "&row.rental_text;
				ds.search_title=row.rental_name;
				ds.search_summary=trim(row.rental_description);
				if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.rental_text;
				}
				
				if(row.rental_url NEQ ""){
					ds.search_url=row.rental_url;
				}else{
					ds.search_url="/"&application.zcore.functions.zURLEncode(row.rental_name,"-")&"-"&row.rental_config_rental_url_id&"-"&row.rental_id&".html";
				}
				ds.search_table_id='rental-page-'&row.rental_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=request.zos.mysqlnow;
				ds.site_id=row.site_id;
				searchCom.saveSearchIndex(ds);
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and 
		search_deleted=#db.param(0)# and 
		search_table_id LIKE #db.param("rental-page-%")# and 
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>



<!--- application.zcore.app.getAppCFC("rental").searchIndexDeleteRental(rental_id); --->
<cffunction name="searchIndexDeleteRental" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_deleted=#db.param(0)# and 
	search_table_id = #db.param("rental-"&arguments.id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>
    
<!--- application.zcore.app.getAppCFC("rental").searchReindexRentalCategory(false, true); --->
<cffunction name="searchReindexRentalCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexeverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT *, rental_config_category_url_id FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category, 
		#db.table("rental_config", request.zos.zcoreDatasource)# rental_config
		WHERE 
		rental_config_deleted = #db.param(0)# and 
		rental_category_deleted = #db.param(0)# and
		rental_config.site_id = rental_category.site_id  ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and rental_category.site_id = #db.param(request.zos.globals.id)#  ";
		}else{
			db.sql&=" and rental_category.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and rental_category_id = #db.param(arguments.id)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteRentalCategory(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.rental_category_name&" "&row.rental_category_text;
				ds.search_title=row.rental_category_name;
				ds.search_summary=row.rental_category_text;
				
				if(row.rental_category_url NEQ ""){
					ds.search_url=row.rental_category_url;
				}else{
					ds.search_url="/"&application.zcore.functions.zURLEncode(row.rental_category_name,"-")&"-"&row.rental_config_category_url_id&"-"&row.rental_category_id&".html";
				}
				ds.search_table_id='rental-category-'&row.rental_category_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=request.zos.mysqlnow;
				ds.site_id=row.site_id;
				searchCom.saveSearchIndex(ds);
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and 
		search_table_id LIKE #db.param("rental-category-%")# and 
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>



<!--- application.zcore.app.getAppCFC("rental").searchIndexDeleteRentalCategory(rental_category_id); --->
<cffunction name="searchIndexDeleteRentalCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("rental-category-"&arguments.id)# and 
	search_deleted=#db.param(0)# ";
	db.execute("qDelete");
	</cfscript>
</cffunction>
    
    
	<cffunction name="onRequestEnd" localmode="modern" output="yes" access="public" returntype="void" hint="Runs after zos end file."> </cffunction>
      
      <!--- application.zcore.app.getAppCFC("rental").getAllCategory(qAll,0,rental_category_id); --->
    <cffunction name="getAllCategory" localmode="modern" output="yes" returntype="any">
	<cfargument name="arrQuery" required="yes" type="query">
	<cfargument name="level" required="no" type="any" default="#0#">
	<cfargument name="filterId" required="no" type="any" default="#false#">
	<cfargument name="usedId" required="no" type="struct" default="#structnew()#">
	<cfargument name="cropTitle" required="no" type="boolean" default="#true#">
	<cfscript>
	var cs=StructNew();
	var i=0;
	var g=0;
		var db=request.zos.queryObject;
		
	var qChildren="";
	var rs=StructNew();
	var spaces="";
	rs.arrCategoryName=ArrayNew(1);
	rs.arrCategoryId=ArrayNew(1);
	rs.arrCategoryURL=ArrayNew(1);
	rs.arrCategoryUpdatedDateTime=ArrayNew(1);
	rs.arrIndent=arraynew(1);
	for(g=0;g LT arguments.level;g=g+1){
		//spaces=spaces&"&nbsp;&nbsp;";
		spaces=spaces&"__";
	}
	for(var row in arguments.arrQuery){
		if(arguments.cropTitle){
			ArrayAppend(rs.arrCategoryName, spaces&left(row.rental_category_name,80));
		}else{
			ArrayAppend(rs.arrCategoryName, spaces&row.rental_category_name);
		}
		ArrayAppend(rs.arrIndent, spaces);
		ArrayAppend(rs.arrCategoryId, row.rental_category_id);
		ArrayAppend(rs.arrCategoryURL, row.rental_category_url);
		ArrayAppend(rs.arrCategoryUpdatedDatetime, row.rental_category_updated_datetime);
		if(arguments.filterID NEQ row.rental_category_id){
			db.sql="SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
			WHERE site_id = #db.param(row.site_id)# and 
			rental_category_parent_id = #db.param(row.rental_category_id)# and 
			rental_category_id <> #db.param(arguments.filterId)# and 
			rental_category_deleted = #db.param(0)#
			ORDER BY rental_category_name ASC";
			qChildren=db.execute("qChildren");
			if(qchildren.recordcount NEQ 0){
				cs=this.getAllCategory(qChildren,arguments.level+1,arguments.filterId,arguments.usedid,arguments.cropTitle);
				for(i=1;i LTE ArrayLen(cs.arrCategoryName);i=i+1){
        			ArrayAppend(rs.arrIndent, cs.arrIndent[i]);
					ArrayAppend(rs.arrCategoryName, cs.arrCategoryName[i]);
					ArrayAppend(rs.arrCategoryId, cs.arrCategoryId[i]);
					ArrayAppend(rs.arrCategoryURL, cs.arrCategoryURL[i]);
					ArrayAppend(rs.arrCategoryUpdatedDatetime, cs.arrCategoryUpdatedDatetime[i]);
				}
			}
		}
	}
	return rs;
	</cfscript>
</cffunction>
    
     
    
<!--- application.zcore.app.getAppCFC("rental").getCalendarLink(rental_id,rental_name,rental_url) --->
<cffunction name="getCalendarLink" localmode="modern" output="no">
	<cfargument name="rental_id" type="string" required="yes">
 	<cfargument name="rental_name" type="string" required="yes">
 	<cfargument name="rental_url" type="string" required="yes">
 	<cfscript>
	return "/"&application.zcore.functions.zURLEncode(arguments.rental_name,"-")&"-Availability-Calendar-"&application.zcore.app.getAppData("rental").optionStruct.rental_config_calendar_url_id&"-"&arguments.rental_id&".html";
	</cfscript>
</cffunction>
 
 
   <!--- application.zcore.app.getAppCFC("rental").getPhotoLink(rental_id,rental_name,rental_url,photo_number) --->
    <cffunction name="getPhotoLink" localmode="modern">
		<cfargument name="rental_id" type="string" required="yes">
        <cfargument name="rental_name" type="string" required="yes">
        <cfargument name="rental_url" type="string" required="yes">
        <cfargument name="image_id" type="numeric" required="yes">
        <cfscript>
        return "/"&application.zcore.functions.zURLEncode(arguments.rental_name,"-")&"-Photo-#arguments.image_id#-"&application.zcore.app.getAppData("rental").optionStruct.rental_config_photo_url_id&"-"&arguments.rental_id&".html";
        </cfscript>
 	</cffunction> 
    
    
   
   <!--- application.zcore.app.getAppCFC("rental").getRentalInquiryLink() --->
 <cffunction name="getRentalInquiryLink" localmode="modern" output="no" returntype="any">
 	<cfscript>
	return "/Rental-Inquiry-"&application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id&"-4.html";
	</cfscript>
 </cffunction>
 
   <!--- application.zcore.app.getAppCFC("rental").getRentalHomeLink() --->
 <cffunction name="getRentalHomeLink" localmode="modern" output="no" returntype="any">
 	<cfscript>
	return "/"&application.zcore.functions.zURLEncode(application.zcore.app.getAppData("rental").optionStruct.rental_config_home_page_title,"-")&"-"&application.zcore.app.getAppData("rental").optionStruct.rental_config_misc_url_id&"-0.html";
	</cfscript>
 </cffunction>
 
   <!--- application.zcore.app.getAppCFC("rental").getRentalLink(rental_id,rental_name,rental_url) --->
 <cffunction name="getRentalLink" localmode="modern" output="no" returntype="any">
 	<cfargument name="rental_id" type="string" required="yes">
 	<cfargument name="rental_name" type="string" required="yes">
 	<cfargument name="rental_url" type="string" required="yes">
 	<cfscript>
	if(arguments.rental_url NEQ ""){
		return arguments.rental_url;
	}else{
		return "/"&application.zcore.functions.zURLEncode(arguments.rental_name,"-")&"-"&application.zcore.app.getAppData("rental").optionStruct.rental_config_rental_url_id&"-"&arguments.rental_id&".html";
	}
	</cfscript>
 </cffunction>
 
 <!--- application.zcore.app.getAppCFC("rental").getCategoryLink(rental_category_id,rental_category_name,rental_category_url) --->
 <cffunction name="getCategoryLink" localmode="modern" output="no" returntype="any">
 	<cfargument name="rental_category_id" type="string" required="yes">
 	<cfargument name="rental_category_name" type="string" required="yes">
 	<cfargument name="rental_category_url" type="string" required="yes">
 	<cfscript>
	if(arguments.rental_category_url NEQ ""){
		return arguments.rental_category_url;
	}else{
		return "/"&application.zcore.functions.zURLEncode(arguments.rental_category_name,"-")&"-"&application.zcore.app.getAppData("rental").optionStruct.rental_config_category_url_id&"-"&arguments.rental_category_id&".html";
	}
	</cfscript>
 </cffunction>
  
    
 
    <cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
    	<cfargument name="arrUrl" type="array" required="yes">
    <cfscript>
	var childStruct='';
		var db=request.zos.queryObject;
	var returnText='';
	var i=0;
		
	var qrental=0;
	var qrentalcat=0;
	var t2=0;
	var ts=application.zcore.app.getInstance(this.app_id);
	</cfscript>
    <cfsavecontent variable="returnText">
        
 	<cfscript>
		t2=StructNew();
		t2.groupName="Rental";
		t2.url=request.zos.currentHostName&this.getRentalHomeLink();
		t2.title=application.zcore.app.getAppData("rental").optionStruct.rental_config_home_page_title;
		arrayappend(arguments.arrUrl,t2);
        </cfscript>
        
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_active = #db.param(1)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		rental_deleted = #db.param(0)#
        ORDER BY rental_name ASC 
        </cfsavecontent><cfscript>qrental=db.execute("qrental");</cfscript>
        <cfloop query="qrental"><cfscript>
		t2=StructNew();
		t2.groupName="Rental";
		t2.url=request.zos.currentHostName&this.getRentalLink(qrental.rental_id,qrental.rental_name,qrental.rental_url);
		if(isdate(qrental.rental_updated_datetime)){
			t2.lastmod=dateformat(qrental.rental_updated_datetime,'yyyy-mm-dd');
		}else{
			t2.lastmod=dateformat(now(),'yyyy-mm-dd');
		}
		t2.title=qrental.rental_name;
		arrayappend(arguments.arrUrl,t2);
		</cfscript></cfloop>
        <cfloop query="qrental"><cfscript>
		if(application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1 and qrental.rental_enable_calendar EQ '1'){
			t2=StructNew();
			t2.groupName="Rental Availability Calendars";
			t2.url=request.zos.currentHostName&this.getCalendarLink(qrental.rental_id,qrental.rental_name,qrental.rental_url);
			if(isdate(qrental.rental_updated_datetime)){
				t2.lastmod=dateformat(qrental.rental_updated_datetime,'yyyy-mm-dd');
			}else{
				t2.lastmod=dateformat(now(),'yyyy-mm-dd');
			}
			t2.title=qrental.rental_name&" Availability Calendar";
			arrayappend(arguments.arrUrl,t2);
		}
		</cfscript></cfloop>
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE rental_category_parent_id = #db.param('0')# and 
		site_id = #db.param(request.zos.globals.id)# and 
		rental_category_deleted = #db.param(0)#
		ORDER BY rental_category_sort ASC, rental_category_name ASC
        </cfsavecontent><cfscript>qrentalcat=db.execute("qrentalcat");
        childStruct=this.getAllCategory(qrentalcat,0,0,structnew(),false);
			for(i=1;i LTE arraylen(childStruct.arrCategoryId);i++){
			t2=StructNew();
			t2.groupName="Rental Category";
			t2.url=request.zos.currentHostName&this.getCategoryLink(childStruct.arrCategoryId[i],childStruct.arrCategoryName[i],childStruct.arrCategoryUrl[i]);
			if(isdate(childStruct.arrCategoryUpdatedDatetime[i])){
				t2.lastmod=dateformat(childStruct.arrCategoryUpdatedDatetime[i],'yyyy-mm-dd');
			}else{
				t2.lastmod=dateformat(now(),'yyyy-mm-dd');
			}
			t2.indent=replace(childStruct.arrIndent[i],"_","  ","ALL");
			t2.title=replace(childStruct.arrCategoryName[i],"_"," ","ALL");
			arrayappend(arguments.arrUrl,t2);
        }
        </cfscript><!--- 
        <cfloop query="qrentalcat"><cfscript>
		t2=StructNew();
		t2.groupName="rental category";
		t2.url=request.zos.currentHostName&this.getCategoryLink(rental_category_id,rental_category_name,rental_category_url);
		if(isdate(rental_category_updated_datetime)){
			t2.lastmod=dateformat(rental_category_updated_datetime,'yyyy-mm-dd');
		}else{
			t2.lastmod=dateformat(now(),'yyyy-mm-dd');
		}
		t2.title=rental_category_name;
		arrayappend(arguments.arrUrl,t2);
		</cfscript></cfloop> --->
</cfsavecontent>
    	<cfreturn arguments.arrUrl>
    </cffunction>
    
    
    
    <cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
    	<cfargument name="linkStruct" type="struct" required="yes">
    	<cfscript>
		var ts=0;
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			if(structkeyexists(arguments.linkStruct,"Rentals") EQ false){
				ts=structnew();
				ts.featureName="Rentals";
				ts.link='/z/rental/admin/rates/index';
				ts.children=structnew();
				arguments.linkStruct["Rentals"]=ts;
			}
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"View Rental Home Page") EQ false){
				ts=structnew();
				ts.featureName="Rentals";
				ts.link=application.zcore.app.getAppCFC("rental").getRentalHomeLink();
				ts.target="_blank";
				arguments.linkStruct["Rentals"].children["View Rental Home Page"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Amenities") EQ false){
				ts=structnew();
				ts.featureName="Rental Amenities";
				ts.link='/z/rental/admin/rental-amenity/index';
				arguments.linkStruct["Rentals"].children["Amenities"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Categories") EQ false){
				ts=structnew();
				ts.featureName="Rental Categories";
				ts.link='/z/rental/admin/rental-category/index';
				arguments.linkStruct["Rentals"].children["Categories"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Rentals") EQ false){
				ts=structnew();
				ts.featureName="Rentals";
				ts.link='/z/rental/admin/rates/index';
				arguments.linkStruct["Rentals"].children["Rentals"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Add Amenity") EQ false){
				ts=structnew();
				ts.featureName="Rental Amenities";
				ts.link='/z/rental/admin/rental-amenity/add';
				arguments.linkStruct["Rentals"].children["Add Amenity"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Add Category") EQ false){
				ts=structnew();
				ts.featureName="Rental Categories";
				ts.link='/z/rental/admin/rental-category/add';
				arguments.linkStruct["Rentals"].children["Add Category"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"Add Rental") EQ false){
				ts=structnew();
				ts.featureName="Rentals";
				ts.link='/z/rental/admin/rates/addRental';
				arguments.linkStruct["Rentals"].children["Add Rental"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Rentals"].children,"View All Calendars") EQ false){
				ts=structnew();
				ts.featureName="Rental Calendars";
				ts.link='/z/rental/admin/combined-availability/index';
				arguments.linkStruct["Rentals"].children["View All Calendars"]=ts;
			}
		}
		return arguments.linkStruct;
		</cfscript>
    </cffunction>
    <cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
    	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
    	<cfscript>
		var i=0;
		
		var db=request.zos.queryObject;
		var arrColumns=0;
		var qdata=0;
		var ts=StructNew();
		db.sql="SELECT * FROM #db.table("rental_config", request.zos.zcoreDatasource)# rental_config, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
		WHERE rental_config.site_id = app_x_site.site_id and 
		rental_config.site_id = #db.param(arguments.site_id)# and 
		app_x_site.site_id = rental_config.site_id and 
		rental_config_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)#";
		qData=db.execute("qData");
		for(row in qData){
			return row;
		}
		throw("rental_config record is missing for site_id=#arguments.site_id#.");
		</cfscript>
    </cffunction>
    
    
    <cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
    	<cfscript>
	
		ts2=structnew();
		ts2.uniqueURLStruct=structnew();
		ts2.reservedAppUrlIdStruct=structnew();
		setURLRewriteStruct(request.zos.globals.id,ts2);
		</cfscript>
    </cffunction>
	


    <cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
    	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
		<cfargument name="sharedStruct" type="struct" required="yes">
    	
    	<cfscript>
		
		var t9=0;
		var qrentalcat=0;
		var db=request.zos.queryObject;
		var theText="";
		var qconfig=0;
		var qrental=0;
		var link=0;
		var pos=0;
		db.sql="SELECT * FROM #db.table("rental_config", request.zos.zcoreDatasource)# rental_config, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
		#db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site.site_id = app_x_site.site_id and  
		app_x_site.site_id = rental_config.site_id and 
		rental_config.site_id = #db.param(arguments.site_id)# and 
		rental_config_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)# and 
		site_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		db.sql="SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_active = #db.param('1')# and 
		site_id = #db.param(qConfig.site_id)# and 
		rental_url <> #db.param('')# and 
		rental_url NOT LIKE #db.param('/z/%')# and 
		rental_deleted = #db.param(0)#
        ORDER BY rental_url DESC "; // put deleted rules at bottom so new pages don't conflict.
		qrental=db.execute("qrental");
		db.sql="SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE site_id = #db.param(qConfig.site_id)# and 
		rental_category_url <> #db.param('')# and 
		rental_category_url NOT LIKE #db.param('/z/%')# and 
		rental_category_deleted = #db.param(0)#
        ORDER BY rental_category_url DESC "; // put deleted rules at bottom so new pages don't conflict.
        qrentalcat=db.execute("qrentalcat");

		loop query="qConfig"{
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_rental_url_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/rentalTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/rentalTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="rental_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_rental_url_id],t9);
			
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_calendar_url_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/calendarTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/calendarTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="rental_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_calendar_url_id],t9);
			
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_photo_url_id]=arraynew(1);
			t9=structnew();
			t9.type=5;
			t9.scriptName="/z/rental/rental-front/photoTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/photoTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="rental_id";
			t9.mapStruct.dataId2="image_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_photo_url_id],t9);
			
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_category_url_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/categoryTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/categoryTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="rental_category_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_category_url_id],t9);
			
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_misc_url_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/categoryListTemplate";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="0";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/categoryListTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_misc_url_id],t9);
			
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/rateInfoTemplate";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="1";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/rateInfoTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_misc_url_id],t9);
			
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/inquiryTemplate";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="4";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/inquiryTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_misc_url_id],t9);
			
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/rental/rental-front/compareRentalAmenitiesTemplate";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="2";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/compareRentalAmenitiesTemplate";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.rental_config_misc_url_id],t9);
		}
		loop query="qrental"{
			t9=structnew();
			t9.scriptName="/z/rental/rental-front/rentalTemplate";
			t9.urlStruct=structnew();
			// hardcode the values to be insert into url scope
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/rentalTemplate";
			t9.urlStruct.rental_id=qrental.rental_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qrental.rental_url)]=t9;
		}
		loop query="qrentalcat"{
			t9=structnew();
			t9.scriptName="/z/rental/rental-front/categoryTemplate";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/rental/rental-front/categoryTemplate";
			t9.urlStruct.rental_category_id=qrentalcat.rental_category_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qrentalcat.rental_category_url)]=t9;
		}
		</cfscript>

    </cffunction>
    
    
    
    
	<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
    	<cfscript>
		var qConfig=0;
		var db=request.zos.queryObject;
		
		var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
		</cfscript>
    	<!--- delete all rental and rental_group and images? --->
        <cfsavecontent variable="db.sql">
        UPDATE #db.table("rental_config", request.zos.zcoreDatasource)# SET 
        rental_config_deleted = #db.param(1)#, 
        rental_config_updated_datetime = #db.param(request.zos.mysqlnow)# 
		WHERE site_id = #db.param(request.zos.globals.id)#
        </cfsavecontent><cfscript>qConfig=db.execute("qConfig");</cfscript>        
        <cfreturn rCom>
    </cffunction>
    
    <cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
    	<cfargument name="validate" required="no" type="boolean" default="#false#">
    	<cfscript>
		var i=0;
		var field=0;
		var error=false;
		var df=structnew();
		df.rental_config_rental_url_id="11";
		df.rental_config_calendar_url_id="12";
		df.rental_config_photo_url_id="13";
		df.rental_config_misc_url_id="14";
		df.rental_config_category_url_id="15";
		df.rental_config_home_page_title="Rentals";
		df.rental_config_availability_calendar=0;
		df.rental_config_reserve_online=0;
		for(i in df){	
			if(arguments.validate){
				if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
					error=true;
					field=trim(lcase(replacenocase(replacenocase(i,"rental_config_",""),"_"," ","ALL")));
					application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
				}
			}else{
				if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
					form[i]=df[i];
				}
			}
		}
		if(error){
			return false;
		}else{
			return true;
		}
		</cfscript>
    </cffunction>
    
	<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
    	<cfscript>
		var ts=StructNew();
		var result=0;
		var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
		if(this.loadDefaultConfig(true) EQ false){
			rCom.setError("Please correct the above validation errors and submit again.",1);
			return rCom;
		}	
		
		ts=StructNew();
		ts.arrId=arrayNew(1);
		arrayappend(ts.arrId,trim(form.rental_config_rental_url_id));
		arrayappend(ts.arrId,trim(form.rental_config_calendar_url_id));
		arrayappend(ts.arrId,trim(form.rental_config_photo_url_id));
		arrayappend(ts.arrId,trim(form.rental_config_misc_url_id)); 
		if(form.rental_config_reserve_online EQ 1){
			form.rental_config_availability_calendar=1;
		}
		
		ts.app_id=this.app_id;
		form.site_id=form.sid;
		ts.site_id=form.sid;
		rCom=application.zcore.app.reserveAppUrlId(ts);
		if(rCom.isOK() EQ false){
			return rCom;
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
			application.zcore.functions.zabort();
		}		
		ts.table="rental_config";
		ts.struct=form;
		ts.datasource=request.zos.zcoreDatasource;
		if(application.zcore.functions.zso(form,'rental_config_id',true) EQ 0){ // insert
			result=application.zcore.functions.zInsert(ts);
			if(result EQ false){
				rCom.setError("Failed to save configuration.",2);
				return rCom;
			}
		}else{ // update
			result=application.zcore.functions.zUpdate(ts);
			if(result EQ false){
				rCom.setError("Failed to update configuration.",3);
				return rCom;
			}
		}
		application.zcore.status.setStatus(request.zsid,"Configuration saved.");
		return rCom;
    	</cfscript>
	</cffunction>
    
    
	<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
       	<cfscript>
		var thetext=0;
		var db=request.zos.queryObject;
		var qconfig="";
		
		var ts=0;
		var rs=structnew();
		var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
		rs.output="";
		</cfscript>
        <cfsavecontent variable="theText">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("rental_config", request.zos.zcoreDatasource)# rental_config 
		WHERE site_id = #db.param(form.sid)# and 
		rental_config_deleted=#db.param(0)# 
        </cfsavecontent><cfscript>qConfig=db.execute("qConfig");
        application.zcore.functions.zQueryToStruct(qConfig);
		if(qconfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
        application.zcore.functions.zStatusHandler(request.zsid,true);
        </cfscript>
        <input type="hidden" name="rental_config_id" value="#form.rental_config_id#">
        <table style="border-spacing:0px;" class="table-list">
        
        <tr>
        <tr><th>Lodgix Default Property ID</th>
        <td><input type="text" name="rental_config_lodgix_property_id" id="rental_config_lodgix_property_id" value="#htmleditformat(application.zcore.functions.zso(form, 'rental_config_lodgix_property_id'))#" /></td></tr>
        <tr><th>Lodgix Email Subject</th>
        <td><input type="text" name="rental_config_lodgix_email_subject" id="rental_config_lodgix_email_subject" value="#htmleditformat(application.zcore.functions.zso(form, 'rental_config_lodgix_email_subject'))#" /></td></tr>
        <tr><th>Lodgix Email TO:</th>
        <td><input type="text" name="rental_config_lodgix_email_to" id="rental_config_lodgix_email_to" value="#htmleditformat(application.zcore.functions.zso(form, 'rental_config_lodgix_email_to'))#" /></td></tr>
        <tr>
        <th>Payment Gateway</th>
        <td>
        <cfscript>
		form.rental_config_payment_gateway=application.zcore.functions.zso(form,'rental_config_payment_gateway',true);
		ts = StructNew();
		ts.name = "rental_config_payment_gateway";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript></td>
        </tr>
        <tr>
        <th>Availability Calendars</th>
        <td>
        <cfscript>
		form.rental_config_availability_calendar=application.zcore.functions.zso(form,'rental_config_availability_calendar',true);
		ts = StructNew();
		ts.name = "rental_config_availability_calendar";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.onclick="rentalForceReserve(this);";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript></td>
        </tr>
        <tr>
        <th>Disable Child Category Links</th>
        <td>
        <cfscript>
		form.rental_config_disable_child_category_links=application.zcore.functions.zso(form,'rental_config_disable_child_category_links',true);
		ts = StructNew();
		ts.name = "rental_config_disable_child_category_links";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript></td>
        </tr>
        <tr>
        <th>Reserve Online</th>
        <td> 
        <cfscript>
		form.rental_config_reserve_online=application.zcore.functions.zso(form,'rental_config_reserve_online',true);
		ts = StructNew();
		ts.name = "rental_config_reserve_online";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.onclick="rentalForceCalendar(this);";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Reserve Online requires Availability Calendars)</td>
        </tr>
        <tr>
        <th>URL Rental ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("rental_config_rental_url_id",form.rental_config_rental_url_id, this.app_id));
		</cfscript> (This is used for viewing rental details)</td>
        </tr>
        <tr>
        <th>URL Calendar ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("rental_config_calendar_url_id",form.rental_config_calendar_url_id, this.app_id));
		</cfscript> (This is used for viewing rental calendars)</td>
        </tr>
        <tr>
        <th>URL Photo ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("rental_config_photo_url_id",form.rental_config_photo_url_id, this.app_id));
		</cfscript> (This is used for viewing enlarged rental photos)</td>
        </tr>
        <tr>
        <th>URL Category ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("rental_config_category_url_id",form.rental_config_category_url_id, this.app_id));
		</cfscript> (This is used for viewing rental category pages)</td>
        </tr>
        <tr>
        <th>URL Misc ID</th>
        <td>
        <cfscript>
		writeoutput(application.zcore.app.selectAppUrlId("rental_config_misc_url_id",form.rental_config_misc_url_id, this.app_id));
		</cfscript> (This is used for viewing miscellaneous rental system pages)</td>
        </tr> 
        <tr>
        <th>Rental Home Page Title</th>
        <td>
		<cfscript>
		ts=StructNew();
		ts.label="";
		ts.name="rental_config_home_page_title";
		ts.size="40";
		application.zcore.functions.zInput_Text(ts);
		</cfscript>
        </td>
        </tr> 
        </table>
        </cfsavecontent>
        <cfscript>
		rs.output=theText;
		rCom.setData(rs);
		return rCom;
		</cfscript>
	</cffunction>
    
    <cffunction name="onSiteStart" localmode="modern" output="no" returntype="struct"> 
    	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
		<cfscript>
		var db=request.zos.queryObject;
		var qtype=0;
		request.zos.imageLibraryCom=application.zcore.functions.zCreateObject("component","zcorerootmapping.com.app.image-library");
		//application.zcore.imageLibraryCom.init();
		/*
		//these depend on application.sitestruct already being defined, and it isn't here
		application.zcore.imageLibraryCom.registerSize(0, "350x232", 0);
		application.zcore.imageLibraryCom.registerSize(0, this.getImageSize("rental-category-thumbnail"), 0);
		application.zcore.imageLibraryCom.registerSize(0, this.getImageSize("rental-page-main"), 0);
		application.zcore.imageLibraryCom.registerSize(0, this.getImageSize("rental-page-thumbnail"), 1); */
		// force at least one availability type to exist.
		 db.sql="SELECT * FROM #db.table("availability_type", request.zos.zcoreDatasource)# availability_type 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		availability_type_deleted = #db.param(0)# ";
		qtype=db.execute("qtype");
		if(qtype.recordcount EQ 0){
			 db.sql="INSERT INTO #db.table("availability_type", request.zos.zcoreDatasource)#  
			 SET availability_type_sort = #db.param('1')# , 
			 availability_type_name=#db.param('Holiday')#, 
			 availability_type_color=#db.param('BBDDFF')#, 
			availability_type_deleted=#db.param(0)#,
			availability_type_updated_datetime=#db.param(request.zos.mysqlnow)#,
			 site_id=#db.param(request.zos.globals.id)# ";
			 db.execute("q");
		} 
		return arguments.sharedStruct;
		</cfscript>
    </cffunction>
    
    <cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
		<cfscript>
		var qtype=0;
		if(structkeyexists(request.zos, 'rentalOnRequestStartCalled')){
			return;
		}
		request.zos.rentalOnRequestStartCalled=true;
		
		if(request.zos.allowRequestCFC){
			request.zos.tempObj.rentalInstance=structnew();
			structappend(request.zos.tempObj.rentalInstance, application.sitestruct[request.zos.globals.id].app.appCache[this.app_id]);
			request.zos.tempObj.rentalInstance.configCom=this;
		}
		if(request.zos.globals.enableMinCat EQ 0 or structkeyexists(request.zos.tempObj,'disableMinCat')){
			application.zcore.template.prependtag("meta",application.zcore.skin.includeCSS("/z/a/rental/stylesheets/global.css"));
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id], 'zRentalRequestStartedOnce') EQ false){
			this.publishCSS();
			application.sitestruct[request.zos.globals.id].zRentalRequestStartedOnce=true;
		}
        </cfscript>
    </cffunction>
    
    <cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		arrayappend(arguments.ss.css, "/z/a/rental/stylesheets/global.css");
		</cfscript>
    </cffunction>
    
    <!--- application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main"); --->
    <cffunction name="getImageSize" localmode="modern" output="no" returntype="any">
    	<cfargument name="type" type="string" required="yes">
        <cfscript>
		var width=0;
		var height=0;
		var ratio=0;
		if(arguments.type EQ "rental-category-thumbnail"){
			ratio=166/250;
			width=int((request.zos.globals.maximagewidth-44)/2);
			height=int(width*ratio);
			return width&"x"&height;
		}else if(arguments.type EQ "rental-page-main"){
			width=round(request.zos.globals.maximagewidth-232);
			height=round((width/450)*299);
			return width&"x"&height;
		}else if(arguments.type EQ "rental-page-thumbnail"){
			ratio=132/200;
			width=int((request.zos.globals.maximagewidth-42)/3);
			height=int(width*ratio);
			return width&"x"&height;
		}
		</cfscript>
    </cffunction>
    
	<cffunction name="publishCSS" localmode="modern" output="no" returntype="any">
    <cfscript>
	var ts=structnew();
	var theCSS=0;
	var qView=0;
	</cfscript>
<cfsavecontent variable="theCSS">
.zrental-subtitle{ width:#request.zos.globals.maximagewidth-(12)#px; }
.zrental-main-header {width:#request.zos.globals.maximagewidth-(20+2+20+450)#px;}
.zrental-main-header h2{ color:##FFF; }
</cfsavecontent>
    <cfscript>
    ts=structnew();
    ts.uniquePhrase="zcorerootmapping.com.zapp.rental";
    ts.code=theCSS;
    application.zcore.functions.zPublishCss(ts);
    </cfscript>
    
    </cffunction>
    
    
    
    
    <!--- 
	<cfscript>
	ts=StructNew();
	ts.rental_id=rental_id;
	ts.startDate=startDate;
	ts.endDate=endDate;
	ts.adults=inquiries_adults;
	ts.children=inquiries_children;
	ts.couponCode=inquiries_coupon;
	rs=rateCalc(ts);
	</cfscript>
	 --->
	<cffunction name="rateCalc" localmode="modern" output="yes">
		<cfargument name="ss" type="struct" required="yes">
		<cfscript>
		var overGuestRate=0;
		var totalCleaningRate=0;
		var tax=0;
		var cday=0;
		var qMultipleNightSpecial=0;
		var totalRate=0;
		var sd2=0;
		var totalRateSub=0;
		var qholiday=0;
		var inquiries_pet_cleaning_fee=0;
		var inquiries_discount=0;
		var overCleaning=0;
		var totalSavings=0;
		var qOverride=0;
		var dw=0;
		var mnd=0;
		var availability_list=0;
		var arrRates=[];
		var propregularrate=0;
		var inquiries_night_breakdown=0;
		var arrOnlyRate=0;
		var current_row=0;
		var inquiries_pet_total_fee=0;
		var checkDate=0;
		var inc_date=0;
		var nights=0;
		var cmonth=0;
		var arrBaseRate=0;
		var qholidayOverride=0;
		var qrental=0;
		var nightTotalRate=0;
		var guestOver=0;
		var propholidayrate=0;
		var thetotal=0;
		var numGuests=0;
		var deposit=0;
		var x=0;
		var ed2=0;
		var thetotalWithCleaning=0;
		var number_of_columns=0;
		var ts=0;

		var db=request.zos.queryObject;
		// recalculate the rates here:
		var rateStruct=structNew();
		rateStruct.inquiries_nights_total=0;
		rateStruct.inquiries_night_breakdown=0;
		rateStruct.inquiries_tax=0;
		rateStruct.inquiries_discount=0;
		rateStruct.inquiries_discount_desc="";
		rateStruct.inquiries_cleaning=0;
		//rateStruct.inquiries_addl_cleaning=0;
		rateStruct.inquiries_addl_rate=0;
		rateStruct.inquiries_total=0;
		rateStruct.inquiries_deposit=0;
		rateStruct.inquiries_balance_due=0;
		rateStruct.inquiries_pet_total_fee=0;
		rateStruct.arrNights=arraynew(1);
		rateStruct.error=false;
		rateStruct.zsid=request.zsid;
		if(arguments.ss.children EQ ''){
			arguments.ss.children=0;
		}
		if(structkeyexists(arguments.ss,'pets') EQ false){
			arguments.ss.pets=0;
		}
		sd2=(arguments.ss.startDate);
		ed2=(arguments.ss.endDate);
		if(application.zcore.functions.zso(local, 'sd2') EQ '' or application.zcore.functions.zso(local, 'ed2') EQ ''){
			return rateStruct;
		}
		if(application.zcore.functions.zso(local, 'sd2') EQ '' and isdate(sd2) EQ false or application.zcore.functions.zso(local, 'ed2') EQ '' or isdate(ed2) EQ false){
			application.zcore.status.setStatus(request.zsid, 'The check-in and check-out dates must be valid.');
			rateStruct.error=true;
		}
		sd2=parsedatetime(DateFormat(sd2,'yyyy-mm-dd')&' 00:00:00');
		ed2=parsedatetime(DateFormat(ed2,'yyyy-mm-dd')&' 00:00:00');
		if(DateCompare(sd2, ed2) GTE 0){
			application.zcore.status.setStatus(request.zsid, 'The check-out date must be after the check-in date.');
			rateStruct.error=true;
		}else if(DateCompare(sd2, now()) EQ -1){
			application.zcore.status.setStatus(request.zsid, 'The check-in date must be at least one day into the future.');
			rateStruct.error=true;
		}
		if(rateStruct.error){
			return rateStruct;
		}
		arguments.ss.startDate=sd2;
		arguments.ss.endDate=ed2;
		
		
		totalRate = 0;
		totalCleaningRate=0;
		nights=DateDiff("d",arguments.ss.startDate, arguments.ss.endDate);
		inc_date = arguments.ss.startDate;
		cmonth = dateformat(arguments.ss.endDate,"mmmm");
		cday = 'sunday';
		number_of_columns = 4;
		current_row = 1;
		availability_list = '';
		checkDate = arguments.ss.startDate;
		arrRates=arraynew(1); 
		
		mnd=StructNew();
		mnd.enabled=false;
		mnd.type=0;
		mnd.number=0;
		
		 db.sql="SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_active = #db.param(1)# and 
		rental_deleted=#db.param(0)# and 
		rental_id = #db.param(arguments.ss.rental_id)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qrental=db.execute("qrental");
		if(qrental.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Invalid Rental Selected.');
			rateStruct.error=true;
			return rateStruct;
		}
		/*
		// disabled because percent discount and free nights doesn't work
		sdd=checkdate;
		arrD2=arraynew(1);
		for (x=1; x le nights; x=x+1){	
			arrayappend(arrD2," rate_day like '%,"&lcase(dateformat(sdd,'ddd'))&",%'");
			sdd = DateAdd("d", 1, sdd);	
		}
		dayList="";
		if(arraylen(arrD2) NEQ 0){
			dayList=" and ( "&arraytolist(arrD2, " and ")&" )";
		}*/
		// is there any multiple night discounts - like "cheapest day is free" when you stay 5 nights
		 db.sql="SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
		WHERE rate_period <= #db.param(nights)# and 
		rate_coupon_type <> #db.param('0')# and 
		rental_id = #db.param(arguments.ss.rental_id)# and 
		rate_start_date <=#db.param(DateFormat(arguments.ss.endDate,'yyyy-mm-dd'))# and 
		rate_end_date >= #db.param(DateFormat(checkDate,'yyyy-mm-dd'))# and 
		site_id = #db.param(request.zos.globals.id)# and 
		rate_deleted = #db.param(0)#
		ORDER BY rate_period DESC, rate_sort asc 
		LIMIT #db.param(0)#,#db.param(1)#";
		qMultipleNightSpecial=db.execute("qMultipleNightSpecial");
		if(qMultipleNightSpecial.recordcount NEQ 0){
			mnd.enabled=true;
			mnd.days=qMultipleNightSpecial.rate_day;
			mnd.type=qMultipleNightSpecial.rate_coupon_type;
			mnd.number=qMultipleNightSpecial.rate_coupon;
			mnd.name=qMultipleNightSpecial.rate_event_name;
			mnd.overrideHoliday=qMultipleNightSpecial.rate_override_holiday;
		}else{
			// is there any multiple night discounts - like "cheapest day is free" when you stay 5 nights
			 db.sql="SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
			WHERE rate_period <= #db.param(nights)# and 
			rate_coupon_type <> #db.param('0')# and 
			rental_id = #db.param('0')# and 
			rate_property NOT LIKE #db.param('%,#arguments.ss.rental_id#,%')# and 
			rate_start_date <=#db.param(DateFormat(arguments.ss.endDate,'yyyy-mm-dd'))# and 
			rate_end_date >= #db.param(DateFormat(checkDate,'yyyy-mm-dd'))# and 
			site_id = #db.param(request.zos.globals.id)# and 
			rate_deleted = #db.param(0)#
			ORDER BY rate_period DESC,  rate_sort ASC 
			LIMIT #db.param(0)#,#db.param(1)#";
			qMultipleNightSpecial=db.execute("qMultipleNightSpecial");
			if(qMultipleNightSpecial.recordcount NEQ 0){
				mnd.enabled=true;
				mnd.days=qMultipleNightSpecial.rate_day;
				mnd.type=qMultipleNightSpecial.rate_coupon_type;
				mnd.number=qMultipleNightSpecial.rate_coupon;
				mnd.name=qMultipleNightSpecial.rate_event_name;
				mnd.overrideHoliday=qMultipleNightSpecial.rate_override_holiday;
			}
		}
		if(qrental.rental_display_holiday EQ 0){
			propholidayrate=qrental.rental_rate_holiday;
		}else{
			propholidayrate=qrental.rental_display_holiday;	
		}
		if(qrental.rental_display_regular EQ 0){
			propregularrate=qrental.rental_rate;
		}else{
			propregularrate=qrental.rental_display_regular;	
		}
		//zdump(mnd);
		arrBaseRate=arraynew(1);
		for (x=1; x le nights; x=x+1){		
			dw=lcase(dateformat(checkdate,'ddd'));
			// check for holiday override rate
			 db.sql="SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
			WHERE rental_id = #db.param(arguments.ss.rental_id)# and 
			rate_coupon_type = #db.param('0')# and 
			rate_start_date <= #db.param(DateFormat(checkDate, 'yyyy-mm-dd'))# and 
			rate_end_date >= #db.param(DateFormat(checkDate, 'yyyy-mm-dd'))# and 
			rate_override_holiday= #db.param(1)# and 
			rate_day like #db.param('%,#dw#,%')# and 
			rate_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#  
			ORDER BY rate_sort ASC";
			qholidayOverride=db.execute("qholidayOverride");
			if(qholidayOverride.recordcount neq 0){
				ts = structNew();
				ts.night = x;
				ts.percentDiscount=0;
				ts.date = checkDate;
				ts.rate = qholidayOverride.rate_rate;
				ts.type = "special holiday rate";
				ts.holiday=true;
				if(qholidayOverride.rate_event_name NEQ ''){
					ts.type&=" (qholidayOverride.rate_event_name)";	
				}
				arrayappend(arrRates, ts); 
				arrayappend(arrBaseRate, propholidayrate);
			}else{
				// is this a holiday?	
				 db.sql="SELECT * FROM #db.table("availability", request.zos.zcoreDatasource)# availability 
				WHERE availability.rental_id = #db.param('29')# and 
				availability_date >= #db.param(DateFormat(checkDate, 'yyyy-mm-dd'))# and 
				availability_date <= #db.param(DateFormat(checkDate, 'yyyy-mm-dd'))# and 
				availability_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)#";
				qholiday=db.execute("qholiday");
				if(qholiday.recordcount neq 0){
					ts = structNew();
					ts.night = x;
					ts.percentDiscount=0;
					ts.date = checkDate;
					ts.rate = qrental.rental_rate_holiday;
					ts.holiday=true;
					ts.type = "holiday rate";
					arrayappend(arrRates, ts); 
					arrayappend(arrBaseRate, propholidayrate);
				}else{	
					// if not a holiday, check rate table and sort by number of days
					// removed:  and rate_coupon_type = '0'
					db.sql="SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
					WHERE rate_period <=#db.param(nights)# and
					rental_id = #db.param(arguments.ss.rental_id)# and 
					rate_start_date <=#db.param(DateFormat(checkDate,'yyyy-mm-dd'))# and 
					rate_end_date >= #db.param(DateFormat(checkDate,'yyyy-mm-dd'))# and 
					rate_day like #db.param('%,#dw#,%')# and 
					site_id = #db.param(request.zos.globals.id)# and 
					rate_deleted = #db.param(0)#
					ORDER BY rate_sort ASC ";
					qOverride=db.execute("qOverride"); 		
					if (qOverride.recordcount neq 0){
						ts = structNew();
						ts.night = x;
						ts.date = checkDate;
						ts.holiday=false;
						if(qOverride.rate_coupon_type EQ 2){
							ts.rate=qrental.rental_rate;
							// percent discount on this day.
							ts.percentDiscount=qOverride.rate_coupon;
							ts.type = ts.percentDiscount&"% off special";
							ts.rate= ts.rate-(ts.rate*(ts.percentDiscount/100));
						}else{
							ts.rate = qOverride.rate_rate;
							ts.percentDiscount=0;	
							ts.type = "special rate";
						}
						if(qOverride.rate_event_name NEQ ''){
							ts.type&=" (#qOverride.rate_event_name#)";	
						}
						arrayappend(arrRates, ts); 
						arrayappend(arrBaseRate, propregularrate);
					}else{
						// use default from qrental
						ts = structNew();
						ts.night = x;
						ts.holiday=false;
						ts.percentDiscount=0;
						ts.date = checkDate;
						ts.rate = qrental.rental_rate;
						ts.type = "regular rate";
						arrayappend(arrRates, ts); 
						arrayappend(arrBaseRate, propregularrate);
					}
				}
			}
			checkDate = DateAdd("d", 1, checkDate);	
		}
		//zdump(request.zos.arrQueryLog);
		inquiries_discount=0;
		arrOnlyRate=arraynew(1);
		for(x=1;x LTE arraylen(arrRates);x=x+1){
			arrayappend(arrOnlyRate,arrRates[x].rate); 
			totalRate = totalRate + arrRates[x].rate;
		}
		totalSavings=arraysum(arrBaseRate);
		inquiries_night_breakdown=arraytolist(arrOnlyRate);
		inquiries_pet_cleaning_fee=0;
		inquiries_pet_total_fee=0;
		if(arguments.ss.rental_id EQ 47 and isNumeric(arguments.ss.pets) and arguments.ss.pets GTE 1){
			inquiries_pet_total_fee=75;
			inquiries_pet_cleaning_fee=0;
			totalRate = totalRate + inquiries_pet_total_fee;
		}else if(arguments.ss.rental_id EQ 26 and isNumeric(arguments.ss.pets) and arguments.ss.pets GTE 1){
			inquiries_pet_total_fee=arguments.ss.pets * 15 * nights;
			inquiries_pet_cleaning_fee=arguments.ss.pets * 20;
			totalRate = totalRate + inquiries_pet_total_fee;
		}else if(arguments.ss.rental_id EQ 49 and isNumeric(arguments.ss.pets) and arguments.ss.pets GTE 1){
			inquiries_pet_total_fee=arguments.ss.pets * 20 * nights;
			inquiries_pet_cleaning_fee=arguments.ss.pets * 20;
			totalRate = totalRate + inquiries_pet_total_fee;
		}else if(arguments.ss.rental_id EQ 52 and isNumeric(arguments.ss.pets) and arguments.ss.pets GTE 1){
			inquiries_pet_total_fee=arguments.ss.pets * 10 * nights;
			inquiries_pet_cleaning_fee=arguments.ss.pets * 20;
			totalRate = totalRate + inquiries_pet_total_fee;
		}
		if(isnumeric(arguments.ss.adults) EQ false){
			arguments.ss.adults=0;
		}
		if(isnumeric(arguments.ss.children) EQ false){
			arguments.ss.children=0;
		}
		numGuests = arguments.ss.adults + arguments.ss.children;
		totalCleaningRate=totalCleaningRate+qrental.rental_rate_cleaning+inquiries_pet_cleaning_fee;
		guestOver=0;
		overGuestRate=0;
		overCleaning=inquiries_pet_cleaning_fee;
		if(numGuests gt qrental.rental_addl_guest_count){// qrental.rental_max_guest){
		  guestOver = numGuests - qrental.rental_addl_guest_count;//qrental.rental_max_guest;
		  
		  overGuestRate = (guestOver * qrental.rental_rate_addl_guests * nights);
		  overCleaning = (guestOver * qrental.rental_rate_cleaning_addl_guests);
			overCleaning=overCleaning+inquiries_pet_cleaning_fee;
		  totalCleaningRate = totalCleaningRate + overCleaning;
		  totalRate = totalRate + overGuestRate;
		  totalSavings = totalSavings + overGuestRate;
		}
		if(mnd.enabled){
			if(mnd.type EQ '1'){
				// day off
				arraysort(arrOnlyRate,"numeric","asc");
				for (x=1; x le min(nights,mnd.number); x=x+1){
					//mnd.number;
					inquiries_discount=inquiries_discount+arrOnlyRate[x];
				}
				if(guestOver){
					// remove the extra charge for the free nights
					  totalRate = totalRate - overGuestRate;
					newGuestRate = (guestOver * qrental.rental_rate_addl_guests * (nights-mnd.number));
					inquiries_discount=inquiries_discount+ (overGuestRate-newGuestRate);
					overGuestRate=newGuestRate;
					  totalRate = totalRate + overGuestRate;
				}
			}else if(mnd.type EQ '2'){
				// only subtract the discount for days it is enabled for...
				inquiries_discount=0;
				for (x=1; x le nights; x=x+1){
					//mnd.number;
					curdate=dateadd("d",x-1,arguments.ss.startDate);
					if(findnocase(',#dateformat(curdate,'ddd')#,', mnd.days) NEQ 0){
						if(mnd.overrideHoliday EQ 1 or arrRates[x].holiday EQ false){
						//	writeoutput(curdate&'<br />');
							//zdump(arrRates[x]);
							disc=arrRates[x].rate*(mnd.number/100);
							arrRates[x].rate-=disc;
							inquiries_discount+=disc;
							if(mnd.name NEQ ''){
								arrRates[x].type&=" (#mnd.name#)";	
							}
						}
					}
				}
				// percent discount
			}
		}
		if(inquiries_discount NEQ 0){
			if(mnd.type EQ '1'){
				// day off
				
			rateStruct.inquiries_discount_desc=rateStruct.inquiries_discount_desc&"(";
			rateStruct.inquiries_discount_desc=rateStruct.inquiries_discount_desc&round(mnd.number)&' free night';
				if(mnd.number GT 1){
					rateStruct.inquiries_discount_desc=rateStruct.inquiries_discount_desc&'s';
				}
			rateStruct.inquiries_discount_desc=rateStruct.inquiries_discount_desc&")";
			}else if(mnd.type EQ '2'){
				// percent discount
				//rateStruct.inquiries_discount_desc=rateStruct.inquiries_discount_desc&mnd.number&'% off';
			}
		}
		nightTotalRate=(totalRate)-overGuestRate;
		tax=.1; // 10% ga tourism tax
		totalRate=totalRate-inquiries_discount;
		totalRate+=totalCleaningRate;
		totalSavings+=totalCleaningRate;
		totalRateSub=totalRate;
		thetotal = (totalRate + (totalRate * tax));
		totalSavings=(totalSavings + (totalSavings * tax))-thetotal;
		thetotalWithCleaning=thetotal;
		if(arguments.ss.rental_id EQ 18 or arguments.ss.rental_id EQ 42){
			deposit = thetotal * .5;
		}else{
			deposit=250;
		}
		rateStruct.inquiries_pet_total_fee=inquiries_pet_total_fee;
		rateStruct.nights=nights;
		rateStruct.guests=arguments.ss.adults+arguments.ss.children;
		rateStruct.inquiries_total_savings=totalSavings;
		rateStruct.inquiries_nights_total=nightTotalRate;
		rateStruct.inquiries_night_breakdown=inquiries_night_breakdown;
		rateStruct.inquiries_tax=totalRate*tax;
		rateStruct.inquiries_discount=inquiries_discount;
		rateStruct.inquiries_cleaning=qrental.rental_rate_cleaning;
		rateStruct.inquiries_addl_guest=guestover;
		rateStruct.inquiries_addl_cleaning=overCleaning;
		rateStruct.inquiries_addl_rate=overGuestRate;
		rateStruct.inquiries_total=thetotalWithCleaning;
		rateStruct.inquiries_subtotal=totalRateSub;//rateStruct.inquiries_total-(rateStruct.inquiries_discount+rateStruct.inquiries_tax);
		rateStruct.inquiries_deposit=deposit;
		rateStruct.inquiries_balance_due=rateStruct.inquiries_total-rateStruct.inquiries_deposit;
		rateStruct.arrNights=arrRates;
		rateStruct.arrRegularNights=arrBaseRate; 
		return rateStruct;
		</cfscript>
	</cffunction>
    
    <cffunction name="isRentalPage" localmode="modern" output="no" returntype="boolean">
    	<cfscript>
		if(left(request.cgi_script_name,len('/z/rental/rental')) EQ '/z/rental/rental' and (structkeyexists(form, 'method') EQ false or form.method NEQ "inquiryTemplate")){
			return true;
		}else{
			return false;	
		}
		</cfscript>
    </cffunction>
    
    
    
    <cffunction name="isCategoryId" localmode="modern" output="no" access="public" returntype="any">
    	<cfargument name="category_id" type="numeric" required="yes">
    	<cfscript>
		if(structkeyexists(request.zos.tempObj,'currentRentalCategoryIdStruct') and structkeyexists(request.zos.tempObj.currentRentalCategoryIdStruct, arguments.category_id)){
			return true;
		}else{
			return this.isRentalInCategoryId(arguments.category_id);
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="isRentalInCategoryId" localmode="modern" output="no" access="public" returntype="any">
    	<cfargument name="category_id" type="numeric" required="yes">
    	<cfscript>
		if(structkeyexists(request.zos.tempObj,'currentRentalQuery') and request.zos.tempObj.currentRentalQuery.rental_category_id_list CONTAINS ","&arguments.category_id&","){
			return true;
		}else{
			return false;
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="onRentalPage" localmode="modern" access="public" returntype="any" output="no">
    	<cfscript>
		application.zcore.functions.zModalCancel();
		</cfscript>
    </cffunction>
    
    </cfoutput>
</cfcomponent>