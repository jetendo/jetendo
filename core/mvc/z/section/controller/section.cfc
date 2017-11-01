<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=20;
</cfscript>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;
  
	db.sql="SELECT * from 
	#db.table("section", request.zos.zcoreDatasource)#, 
	#db.table("page", request.zos.zcoreDatasource)# 
	WHERE 
	section.site_id = page.site_id and 
	section.section_id = page.section_id and 
	section_deleted=#db.param(0)# and 
	page_deleted = #db.param(0)# and
	page_status = #db.param(1)# ";
	db.sql&="ORDER BY page_name ASC"; // section_name ASC, 
	// TODO: group by section someday
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Pages";
		t2.url=request.zos.currentHostName&getViewLink(row);
		t2.title=row.page_name;
		arrayappend(arguments.arrUrl,t2);
	}
	return arguments.arrURL;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts = 0;

	if ( structKeyExists( request.zos.userSession.groupAccess, 'administrator' ) ) { 

		if ( structKeyExists( arguments.linkStruct, 'Content Manager') EQ false ) {
			ts = structNew();
			ts.children={};
			ts.featureName = 'Pages';
			ts.link        = '/z/content/admin/content-admin/index';

			arguments.linkStruct['Content Manager'] = ts;
		}
		/*
		if ( structKeyExists( arguments.linkStruct['Content Manager'].children, 'Add Page 2.0' ) EQ false ) {
			ts = structNew();

			ts.featureName = 'Add Pages';
			ts.link        = '/z/section/admin/page-admin/add';

			arguments.linkStruct['Content Manager'].children['Add Page 2.0'] = ts;
		}

		if ( structKeyExists( arguments.linkStruct['Content Manager'].children, 'Pages 2.0' ) EQ false ) {
			ts = structNew();

			ts.featureName = 'Pages';
			ts.link        = '/z/section/admin/page-admin/index';

			arguments.linkStruct['Content Manager'].children['Pages 2.0'] = ts;
		}*/

		if ( structKeyExists( arguments.linkStruct['Content Manager'].children, 'Sections' ) EQ false ) {
			ts = structNew();

			ts.featureName = 'Page Categories';
			ts.link        = '/z/section/admin/section-admin/index';

			arguments.linkStruct['Content Manager'].children['Sections'] = ts;
		}

	}

	return arguments.linkStruct;
	</cfscript>
</cffunction>


<cffunction name="getAdminNavMenu" localmode="modern" access="public">
	<cfscript>
		application.zcore.template.setTag("title", "Pages");
	</cfscript> 
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("section_config", request.zos.zcoreDatasource)# 
	where 
	site_id = #db.param(arguments.site_id)# and 
	section_config_deleted = #db.param(0)#";
	qData=db.execute("qData"); 
	for(row in qData){
		return row;
	}
	throw("section_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


	

<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 

	db.sql="SELECT * FROM #db.table("section_config", request.zos.zcoreDatasource)# section_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = section_config.site_id and 
	section_config.site_id = #db.param(arguments.site_id)# and 
	section_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_id = #db.param(this.app_id)# and
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");  

	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.section_config_url_page_id]=[]; 

		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/section/page/view";
		t9.ifStruct=structnew();
		t9.ifStruct.dataId="1";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/section/page/view";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="urlid";
		t9.mapStruct.dataId2="zIndex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.section_config_url_page_id],t9);

		db.sql="SELECT * from #db.table("page", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		page_unique_url<>#db.param('')# and 
		page_deleted = #db.param(0)#
		ORDER BY page_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/page/view-page/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/page/view-page/viewPage";
			t9.urlStruct.page_id=qF.page_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.page_unique_url)]=t9;
		}
	} 
	</cfscript>
</cffunction> 


<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("section_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	section_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();

	// Set config defaults here 

	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"section_config_",""),"_"," ","ALL")));
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
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';

	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	

	form.site_id=form.sid; 

	ts=StructNew();
	ts.arrId=arrayNew(1);

	// Processing/validation of config options before save/update
	// Display error
	// application.zcore.status.setStatus(Request.zsid, 'Page no longer exists', form, true);

	arrayappend(ts.arrId,trim(form.section_config_url_page_id));

	ts.site_id=form.site_id;
	ts.app_id=this.app_id;

	rCom=application.zcore.app.reserveAppUrlId(ts);

	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	} 
	form.section_config_deleted=0;
	form.section_config_updated_datetime=request.zos.mysqlnow;
	ts.table="section_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'section_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);  
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");

	// Build the config form.

	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("section_config", request.zos.zcoreDatasource)# section_config 
		WHERE site_id = #db.param(form.sid)# and 
		section_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="section_config_id" value="#form.section_config_id#" />
		<table style="border-spacing:0px;" class="table-list">');

		echo(' 
		<tr>
		<th>Page URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("section_config_url_page_id", form.section_config_url_page_id, this.app_id));
		echo('</td>
		</tr>'); 
		echo('</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
 
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


<cffunction name="getPageURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.page_unique_url NEQ ""){
		return row.page_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("page").optionstruct.section_config_url_page_id;
		return "/"&application.zcore.functions.zURLEncode(row.page_title, '-')&"-"&urlId&"-"&row.page_id&".html";
	}
	</cfscript>
</cffunction>


<cffunction name="onSiteStart" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	ts={}; 

	// Cached data

	arguments.sharedStruct=ts;
	return arguments.sharedStruct;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
