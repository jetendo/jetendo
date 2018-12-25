<cfcomponent displayname="listing" hint="Listing Application">
<cfoutput>
<cfscript>
this.app_id=11;
</cfscript>   

<cffunction name="getListingDetailRowOutput" localmode="modern" output="no" returntype="string">
<cfargument name="label" type="string" required="yes">
<cfargument name="idx" type="struct" required="yes">
<cfargument name="idxExclude" type="struct" required="yes">
<cfargument name="idxMap" type="struct" required="yes">
<cfargument name="allFields" type="struct" required="yes">
<cfscript>
	
	local.idxTemp3=structnew();
	local.idxTemp32=structnew();
	local.n1=1;
	for(local.i in arguments.idxMap){
		local.idxTemp32[arguments.idxMap[local.i]&"-"&local.n1]=local.i;
		local.idxTemp3[local.i]=arguments.idxMap[local.i];
		local.n1++;
	}
	local.arrR2=[];
	local.arrK=structkeyarray(local.idxTemp32);
	arraysort(local.arrK, "text", "asc");
	for(local.i99=1;local.i99 LTE arraylen(local.arrK);local.i99++){
		local.i=local.idxTemp32[local.arrK[local.i99]];
		local.cur99=arguments.idxMap[local.i]; 
		for(i9 in arguments.allFields){
			if(arguments.allFields[i9].field EQ local.i){
				structdelete(arguments.allFields, i9);
				break;
			}
		}
		if(structkeyexists(arguments.idxExclude, local.i) EQ false){
			if(structkeyexists(arguments.idx, local.i) and structkeyexists(arguments.idx, local.i) and arguments.idx[local.i] NEQ "" and arguments.idx[local.i] NEQ "0"){
				arrayappend(local.arrR2, '<tr><th>'&application.zcore.functions.zfirstlettercaps(local.cur99)&'</th><td>'&htmleditformat(arguments.idx[local.i])&'</td></tr>'&chr(10));
			}
		}
	} 
	if(arraylen(local.arrR2) NEQ 0){
		return '<tr><td colspan="2"><h3>'&arguments.label&'</h3></td></tr>'&arraytolist(local.arrR2,"");
	}else{
		return "";
	}
	</cfscript>
</cffunction>



<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
<cfscript>
	</cfscript>
</cffunction>

<cffunction name="isListingDetailPage" localmode="modern" access="public" output="no" returntype="boolean">
<cfscript>
	if(structkeyexists(request.zos.tempObj,'listingDetailPage')){
		return true;
	}else{
		return false;	
	}
	</cfscript>
</cffunction>


<cffunction name="calculateCommissionBack" localmode="modern" access="public" output="no" returntype="boolean">
<cfscript>
	var comPos=0;
	var commissionPercent=20;
	var commissionBack=request.zos.tempObj.currentListingIdx.rets20_subagencycompensation;
	commissionBack=replace(replace(commissionBack, ",","","all"),"$","","all");
	comPos=find("+", commissionBack);
	if(comPos NEQ 0){
		commissionBack=left(commissionBack, comPos-1);
	}
	if(isNumeric(commissionBack)){
		if(commissionBack LT 1){
			commissionBack=request.zos.tempObj.currentListingIdx.listing_price*((commissionBack*100)*(commissionPercent/100));
		}else if(commissionBack LTE 6){
			commissionBack=request.zos.tempObj.currentListingIdx.listing_price*((commissionBack/100)*(commissionPercent/100));	
		}
	}else{
		comPos=find("%", commissionBack);
		if(comPos NEQ 0){
			commissionBack=left(commissionBack, comPos-1);
			writeoutput('numeric:'&isNumeric(commissionBack)&'<br />');
			if(isNumeric(commissionBack)){
				commissionBack=request.zos.tempObj.currentListingIdx.listing_price*((commissionBack/100)*(commissionPercent/100));	
			}else{
				commissionBack=0;
			}
		}else{
			commissionBack=0;
		}
	}
	return commissionBack;
	</cfscript>
</cffunction>


<!--- #application.zcore.listingCom.getDisclaimerText()# --->
<cffunction name="getDisclaimerText" localmode="modern" output="no" returntype="any">
	<cfscript> 
	local.c=application.zcore.db.getConfig();
	local.c.cacheForSeconds=3600;
	db=application.zcore.db.newQuery(local.c);
	db.sql="SELECT mls_disclaimer_name, mls_update_date FROM 
	#db.table("mls", request.zos.zcoreDatasource)# mls, 
	#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls 
	
	WHERE mls.mls_id = app_x_mls.mls_id and 
	mls_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)# and 
	app_x_mls.site_id = #db.param(request.zos.globals.id)# and 
	mls_status = #db.param('1')#";
	qM=db.execute("qM", "", 10000, "query", false);
	</cfscript>
	<cfsavecontent variable="common">
		<div class="zlisting-common-disclaimer">All listing information is deemed reliable but not guaranteed and should be independently verified through personal inspection by appropriate professionals. Listings displayed on this website may be subject to prior sale or removal from sale; availability of any listing should always be independent verified. Listing information is provided for consumer personal, non-commercial use, solely to identify potential properties for potential purchase; all other use is strictly prohibited and may violate relevant federal and state law. 
			The source of the listing data is as follows:   
			<cfscript>
			for(row in qm){
				echo(' | '&row.mls_disclaimer_name&' (updated '&dateformat(row.mls_update_date,"m/d/yy")&') ');
			}
			</cfscript>
		</div>
	</cfsavecontent>
	<cfscript>
	return trim(common);
	</cfscript>
</cffunction>


<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
<cfargument name="site_id" type="numeric" required="yes">
<cfscript>
	return "";
	</cfscript>
</cffunction>

<!--- application.zcore.listingCom.getThumbnail(photourl, listing_id, num, width, height, autocrop); --->
<cffunction name="getThumbnail" localmode="modern" output="no" returntype="any">
<cfargument name="photourl" type="string" required="yes">
<cfargument name="listing_id" type="string" required="yes">
<cfargument name="num" type="string" required="yes">
<cfargument name="width" type="numeric" required="no" default="#221#">
<cfargument name="height" type="numeric" required="no" default="#165#">
<cfargument name="autocrop" type="numeric" required="no" default="#0#">
<cfscript>

// check for same domain or domainalias
local.c=replace(arguments.photourl, request.zos.currentHostName&"/", "/");
if(arguments.photourl contains "/z/index.php?method=size"){
	return arguments.photourl;
}
if(compare(arguments.photourl, local.c) NEQ 0){
	if(left(local.c, 12) EQ "/zretsphotos"){
		if(arguments.width EQ 10000 or arguments.height EQ 10000){ 
			return local.c; 
		}else if(listlen(arguments.listing_id,"-") EQ 3){
			return request.zos.currentHostName&"/z/index.php?method=size&w=#arguments.width#&h=#arguments.height#&m=#replace(arguments.listing_id,"-","&f=")#&a=#arguments.autocrop#";
		}else{
			return request.zos.currentHostName&"/z/index.php?method=size&w=#arguments.width#&h=#arguments.height#&m=#replace(arguments.listing_id,"-","&f=")#-#arguments.num#.jpeg&a=#arguments.autocrop#";
		} 
	}else{
		return request.zos.currentHostName&'/z/a/listing/images/image-not-available.gif';	
	}
}else{
	if(arguments.width EQ 10000 or arguments.height EQ 10000){
		if(left(arguments.photourl,5) EQ "http:" or left(arguments.photourl,6) EQ "https:"){ 
			return request.zos.currentHostName&"/z/index.php?method=size&w=#arguments.width#&h=#arguments.height#&m=#replace(arguments.listing_id,"-","&f=")#-#arguments.num#.jpeg&p=#urlencodedformat(arguments.photourl)#&a=#arguments.autocrop#";
		}else{
			return request.zos.currentHostName&arguments.photourl;
		}
	}else{
		return request.zos.currentHostName&"/z/index.php?method=size&w=#arguments.width#&h=#arguments.height#&p=#urlencodedformat(arguments.photourl)#&m=#replace(arguments.listing_id,"-","&f=")#-#arguments.num#.jpeg&a=#arguments.autocrop#";
	} 
}
</cfscript>
</cffunction>

<cffunction name="getTopActiveListingCondos" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	</cfscript>
	 <cfsavecontent variable="db.sql">
	SELECT listing_condoname as condoName, count(listing_id) count 
	FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE listing_condoname<> #db.param('')# and 
	listing_deleted = #db.param(0)# and
	listing_condoname<>#db.param('Other')# and 
	listing_condoname <> #db.param('Not On List')# and 
	#db.trustedSQL(this.getMLSIDWhereSQL("listing"))# 
	GROUP BY listing_condoname 
	HAVING (count>#db.param(10)#) 
	ORDER BY listing_condoname asc
	</cfsavecontent><cfscript>qC=db.execute("qC");
	return qC;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zRemoveHTMLForSearchIndexer(text); --->
<cffunction name="zRemoveHTMLForSearchIndexer" localmode="modern" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	var badTagList="style|script|embed|base|input|textarea|button|object|iframe|form";
	arguments.text=rereplacenocase(arguments.text,"<(#badTagList#).*?</\1>", " ", 'ALL');
	arguments.text=rereplacenocase(arguments.text,"(</|<)[^>]*>", " ", 'ALL');
	return arguments.text;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
<cfargument name="arrUrl" type="array" required="yes">
<cfscript>
	
	var t2=0;
	var returnText=0;
	var ts=application.zcore.app.getInstance(this.app_id);
	</cfscript>
	<cfsavecontent variable="returnText">
		<cfscript>
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 0){
			if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_site_map_url_id') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id NEQ 0){
				t2=StructNew();
				t2.groupName="MLS Listings";
				t2.url=request.zos.currentHostName&"/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-.html";
				t2.title="Real Estate Listings";
				arrayappend(arguments.arrUrl,t2);
			}
		}
		</cfscript>        
	</cfsavecontent>
<cfreturn arguments.arrUrl>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
<cfargument name="linkStruct" type="struct" required="yes">
<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var qCheckExclusiveListingPage=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Real Estate") EQ false){
			ts=structnew();
			ts.link='##';
			ts.children=structnew();
			arguments.linkStruct["Real Estate"]=ts;
		}
		/*db.sql="SELECT content_id cid FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		content_featured_listing_parent_page=#db.param('1')# and 
		content_deleted = #db.param(0)#";
		qCheckExclusiveListingPage=db.execute("qCheckExclusiveListingPage"); 
		if(qCheckExclusiveListingPage.recordcount NEQ 0){
			ts=structnew();
			ts.featureName="Listings";
			ts.link='/z/content/admin/content-admin/add?content_parent_id='&qCheckExclusiveListingPage.cid;
			arguments.linkStruct["Real Estate"].children["Add New Listing"]=ts;
			ts=structnew();
			ts.link='/z/content/admin/content-admin/index?content_parent_id='&qCheckExclusiveListingPage.cid;
			arguments.linkStruct["Real Estate"].children["Listings"]=ts;
  		}*/
		if(structkeyexists(arguments.linkStruct["Real Estate"].children,"Saved Listing Searches") EQ false){
			ts=structnew();
			ts.featureName="Saved Listing Searches";
			ts.link='/z/listing/admin/saved-searches/index';
			arguments.linkStruct["Real Estate"].children["Saved Searches"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Real Estate"].children,"Listing Search Filter") EQ false){
			ts=structnew();
			ts.featureName="Listing Search Filter";
			ts.link='/z/listing/admin/search-filter/index';
			arguments.linkStruct["Real Estate"].children["Listing Search Filter"]=ts;
		}  
		if(request.zos.istestserver){
			if(structkeyexists(arguments.linkStruct["Real Estate"].children,"Manual Listing") EQ false){
				ts=structnew();
				ts.featureName="Managed Listings";
				ts.link='/z/listing/admin/manual-listing/index';
				arguments.linkStruct["Real Estate"].children["Manual Listing"]=ts;
			}  
		}
		if(structkeyexists(arguments.linkStruct["Real Estate"].children,"Listing Research Tool") EQ false){
			ts=structnew();
			ts.featureName="Listing Research Tool";
			ts.link='/z/listing/admin/research-tool/index';
			arguments.linkStruct["Real Estate"].children["Listing Research Tool"]=ts;
		}  
		if(structkeyexists(arguments.linkStruct["Real Estate"].children,"Real Estate Widgets and Links") EQ false){
			ts=structnew();
			ts.featureName="Real Estate Widgets and Links";
			ts.link='/z/listing/admin/real-estate-widgets/index';
			arguments.linkStruct["Real Estate"].children["Real Estate Widgets and Links"]=ts;
		}  
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>
 

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
<cfscript>
	var qdata=0;
	var ts=StructNew();
	
	return ts;
	</cfscript>
</cffunction>



<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
<cfscript>
	var theText="";
	var qconfig=0;
	var db=request.zos.queryObject;
	
	var qconfig2=0;
	var qF=0;
	var qc=0;
	var t9=0;
	
	</cfscript>
<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = #db.param(arguments.site_id)# and 
	site_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)#
</cfsavecontent><cfscript>qConfig2=db.execute("qConfig2");</cfscript>
<cfsavecontent variable="db.sql">
SELECT app_x_mls_url_id FROM #db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls 
	WHERE site_id = #db.param(qconfig2.site_id)# and 
	app_x_mls_deleted = #db.param(0)#
</cfsavecontent><cfscript>qConfig=db.execute("qConfig");</cfscript>
<cfsavecontent variable="db.sql">
SELECT mls_option_dir_url_id, mls_option_site_map_url_id 
	FROM #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
	WHERE site_id = #db.param(qconfig2.site_id)# and 
	mls_option_deleted = #db.param(0)#
</cfsavecontent><cfscript>qC=db.execute("qC");</cfscript>
<cfif qConfig.recordcount NEQ 0>
<cfloop query="qConfig">
<cfscript>
arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.app_x_mls_url_id]=arraynew(1);
t9=structnew();
t9.type=2;
t9.scriptName="/z/listing/property/detail/index";
t9.urlStruct=structnew();
t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/property/detail/index";
t9.urlStruct.contentaction="view";
t9.mapStruct=structnew();
t9.mapStruct.urlTitle="zURLName";
t9.mapStruct.appId="mls_id";
t9.mapStruct.dataId="mls_pid";
arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.app_x_mls_url_id],t9);
</cfscript>
</cfloop>

<!--- for mls dir rules:  --->
<cfif qc.mls_option_dir_url_id NEQ "" and qc.mls_option_dir_url_id NEQ "0">
<cfscript>
arguments.sharedStruct.reservedAppUrlIdStruct[qc.mls_option_dir_url_id]=arraynew(1);
t9=structnew();
t9.type=1;
t9.scriptName="/z/listing/search-form-dir/index";
t9.urlStruct=structnew();
t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/search-form-dir/index";
t9.mapStruct=structnew();
t9.mapStruct.urlTitle="zURLName";
t9.mapStruct.dataId="mls_dir_id";
arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qc.mls_option_dir_url_id],t9);
</cfscript>
</cfif>
<cfif qc.mls_option_site_map_url_id NEQ "" and qc.mls_option_site_map_url_id NEQ "0">
<cfscript>
arguments.sharedStruct.reservedAppUrlIdStruct[qc.mls_option_site_map_url_id]=arraynew(1);
t9=structnew();
t9.type=2;
t9.scriptName="/z/listing/real-estate/index";
t9.urlStruct=structnew();
t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/real-estate/index";
t9.mapStruct=structnew();
t9.mapStruct.urlTitle="zURLName";
t9.mapStruct.dataId="zURLIDList";
arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qc.mls_option_site_map_url_id],t9);
</cfscript>
</cfif>
</cfif>


</cffunction>


<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
<cfscript>
	
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	</cfscript>
<cfreturn rCom>
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
<cfargument name="validate" required="no" type="boolean" default="#false#">
<cfscript>
	var i=0;
	var error=false;
	var df=structnew();
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
<cfscript>
	var db=request.zos.queryObject;
	var newLimit=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var primaryMLS=0;
	var primarySet=0;
	var qC=0;
	var i=0;
	var ts=StructNew();
	var arrMLS=listtoarray(application.zcore.functions.zso(form, 'mls_id'));
	
	
	ts=StructNew();
	this.site_id=application.zcore.functions.zso(form, 'sid',true);
	this.app_x_site_id=application.zcore.functions.zso(form, 'app_x_site_id',true);
	ts.arrId=arrayNew(1);
	if(arraylen(arrMLS) EQ 0){
		rCom.setError("You must select one or more MLS Provider.",1);
		return rCom;
	}
	for(i=1;i LTE arraylen(arrMLS);i++){
		form.app_x_mls_url_id=trim(application.zcore.functions.zso(form, 'app_x_mls_url_id'&arrMLS[i]));
		if(form.app_x_mls_url_id EQ ""){
			rCom.setError("You must select a URL ID for the MLS Provider in order to enable it.",2);
			return rCom;
		}
		arrayappend(ts.arrId, form.app_x_mls_url_id);
	}
	if(form.mls_option_dir_url_id EQ ""){
		rCom.setError("Directory URL ID is required.",5);
		return rCom;
	}      
	
	if(form.mls_option_dir_url_id NEQ ""){
		arrayappend(ts.arrId, form.mls_option_dir_url_id);
	}
	if(form.mls_option_site_map_url_id NEQ ""){
		arrayappend(ts.arrId, form.mls_option_site_map_url_id);
	}
	ts.app_id=this.app_id;
	ts.site_id=this.site_id;
	rCom=application.zcore.app.reserveAppUrlId(ts);
	if(rCom.isOK() EQ false){
		return rCom;
	}
	form.app_x_mls_primary=application.zcore.functions.zso(form, 'app_x_mls_primary');
	primarySet=false;
	for(i=1;i LTE arraylen(arrMLS);i++){
		if(form.app_x_mls_primary EQ arrMLS[i]){
			primarySet=true;
		}
	}
	if(primarySet EQ false and arraylen(arrMLS) NEQ 0){
		rCom.setError("You must select a primary MLS Provider.",3);
		return rCom;
	}
	db.sql="DELETE FROM #db.table("app_x_mls", request.zos.zcoreDatasource)#  
	WHERE site_id=#db.param(this.site_id)# and 
	app_x_mls_deleted = #db.param(0)# ";
	db.execute("q"); 
	for(i=1;i LTE arraylen(arrMLS);i++){
		form.app_x_mls_url_id=trim(application.zcore.functions.zso(form, 'app_x_mls_url_id'&arrMLS[i]));
		if(form.app_x_mls_primary EQ arrMLS[i]){
			primaryMLS=1;
		}else{
			primaryMLS=0;	
		}
		db.sql="REPLACE INTO #db.table("app_x_mls", request.zos.zcoreDatasource)#  SET 
		app_x_mls_office_id=#db.param(application.zcore.functions.zso(form, 'app_x_mls_office_id'&arrMLS[i]))#, 
		app_x_mls_agent_id=#db.param(application.zcore.functions.zso(form, 'app_x_mls_agent_id'&arrMLS[i]))#, 
		app_x_mls_url_id=#db.param(form.app_x_mls_url_id)#, 
		app_x_mls_primary=#db.param(primaryMLS)#, 
		mls_id=#db.param(arrMLS[i])#, 
		site_id=#db.param(this.site_id)#,
		app_x_mls_deleted = #db.param(0)#,
		app_x_mls_updated_datetime=#db.param(request.zos.mysqlnow)#
		";
		db.execute("q"); 
	}
	
	if(structkeyexists(form, 'forceupdatelistlayout')){
		if(form.mls_option_list_layout EQ 2){
			newLimit=9;	
		}else{
			newLimit=10;
		}
		db.sql="UPDATE #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		 SET search_result_layout = #db.param(form.mls_option_list_layout)#, 
		 search_result_limit =#db.param(newLimit)# 
		WHERE site_id = #db.param(form.sid)# and 
		mls_saved_search_deleted = #db.param(0)#";
		db.execute("q");
	}
	
	db.sql="select * from #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
	WHERE site_id=#db.param(this.site_id)# and 
	mls_option_deleted = #db.param(0)#";
	qC=db.execute("qC"); 
	ts=structnew();
	ts.datasource="#request.zos.zcoreDatasource#";
	ts.table="mls_option";
	ts.struct=form;
	form.site_id=this.site_id;
	if(qC.recordcount EQ 0){
		application.zcore.functions.zInsert(ts);
	}else{ 
		ts.forceWhereFields="site_id";
		a=application.zcore.functions.zUpdate(ts); 
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
</cfscript>
</cffunction>


<cffunction name="getAgentDataByAgentId" localmode="modern" output="no" returntype="struct" access="remote">
	<cfargument name="mls_id" type="string" required="yes">
	<cfargument name="agentId" type="string" required="yes">
	<cfscript>
	rs={};
	rs.success=false;
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.mls_id], "agentIdStruct") and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.mls_id].agentIdStruct, arguments.agentId)){
		rs.data=application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.mls_id].agentIdStruct[arguments.agentId];
		rs.tempData={
			photo:"",
			profileURL:""
		};
		if(fileexists(application.zcore.functions.zVar('privatehomedir',rs.data.userSiteId)&removechars(request.zos.memberImagePath,1,1)&rs.data.member_photo)){

			rs.tempData.photo=application.zcore.functions.zvar('domain',rs.data.userSiteId)&request.zos.memberImagePath&rs.data.member_photo;
		}
		if(application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id NEQ "0" and rs.data.member_public_profile EQ 1){
			tempName=application.zcore.functions.zurlencode(lcase("#rs.data.member_first_name# #rs.data.member_last_name# "),'-');
			rs.tempData.profileURL="/#tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#rs.data.user_id#.html";
		}
		rs.success=true;
	}
	return rs;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
<cfscript>
	
	var qM=0;
	var qMLS=0;
	var selectStruct=0;
	var qpCity=0;
	var theText=0;
   var qexcity2=0;
	var db=request.zos.queryObject;
   var qexcity=0;
   var rs=structnew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	rs.output="";
	this.site_id=application.zcore.functions.zso(form, 'sid',true);
	this.app_x_site_id=application.zcore.functions.zso(form, 'app_x_site_id',true);
   </cfscript>
<cfsavecontent variable="theText">
<cfscript>
   application.zcore.functions.zstatushandler(request.zsid,true);
   </cfscript>
<table style="border-spacing:0px;" class="table-list">
<tr>
<th>MLS Providers:</th>
<td>
<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls 
LEFT JOIN #db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls ON 
mls.mls_id = app_x_mls.mls_id and 
app_x_mls.site_id=#db.param(this.site_id)# and 
mls_status = #db.param('1')# and 
app_x_mls_deleted = #db.param(0)# 
WHERE mls_deleted = #db.param(0)#
 ORDER BY mls_name
</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
<table style="border-spacing:0px;">
<tr><td>&nbsp;</td><td>MLS ID</td><td>MLS Name</td><td>Office ID</td><td>Agent ID</td><td>Active</td><td>Primary</td><td>URL ID</td></tr>
<cfloop query="qmls">
		<tr <cfif qmls.currentrow MOD 2 EQ 0>style="background-color:##EFEFEF;"</cfif>>
		<cfif application.zcore.functions.zso(form, 'submitform') EQ 'save'>
				<td><input type="checkbox" name="mls_id" value="#qmls.mls_id#" <cfif ","&application.zcore.functions.zso(form, 'mls_id')&"," CONTAINS ",#qmls.mls_id#,">checked="checked"</cfif>></td>
				<td>#qmls.mls_id#</td>
				<td>#qmls.mls_name#</td>
				<td>Office Id: <input type="text" name="app_x_mls_office_id#qmls.mls_id#" style="min-width:200px; width:200px;" value="<cfif application.zcore.functions.zso(form, 'app_x_mls_office_id#qmls.mls_id#') NEQ ''>#application.zcore.functions.zso(form, 'app_x_mls_office_id#qmls.mls_id#')#</cfif>"></td>
				<td>Agent Id: <input type="text" name="app_x_mls_agent_id#qmls.mls_id#" style="min-width:200px; width:200px;" value="<cfif application.zcore.functions.zso(form, 'app_x_mls_agent_id#qmls.mls_id#') NEQ ''>#application.zcore.functions.zso(form, 'app_x_mls_agent_id#qmls.mls_id#')#</cfif>"></td>
				<td><cfif qmls.mls_status EQ 1>Yes<cfelse>No</cfif></td>
				<td><input type="radio" name="app_x_mls_primary" value="#qmls.mls_id#" <cfif app_x_mls_primary EQ 1>checked="checked"</cfif>></td>
				<td>
				<cfscript>
				writeoutput(application.zcore.app.selectAppUrlId("app_x_mls_url_id#qmls.mls_id#",application.zcore.functions.zso(form, 'app_x_mls_url_id#qmls.mls_id#'), this.app_id));
				</cfscript></td>
		<cfelse>
				<td><input type="checkbox" name="mls_id" value="#qmls.mls_id#" <cfif qmls.app_x_mls_url_id NEQ "">checked="checked"</cfif>></td>
				<td>#qmls.mls_id#</td>
				<td>#qmls.mls_name#</td>
				<td><input type="text" name="app_x_mls_office_id#qmls.mls_id#" style="min-width:200px; width:200px;" value="#qmls.app_x_mls_office_id#"></td>
				<td><input type="text" name="app_x_mls_agent_id#qmls.mls_id#" style="min-width:200px; width:200px;" value="#qmls.app_x_mls_agent_id#"></td>
				<td><cfif qmls.mls_status EQ 1>Yes<cfelse>No</cfif></td>
				<td><input type="radio" name="app_x_mls_primary" value="#qmls.mls_id#" <cfif qmls.app_x_mls_primary EQ 1>checked="checked"</cfif>></td>
				<td>
				<cfscript>
				writeoutput(application.zcore.app.selectAppUrlId("app_x_mls_url_id#qmls.mls_id#",qmls.app_x_mls_url_id, this.app_id));
				</cfscript></td>
		</cfif>
		
		</tr>
</cfloop>

</table>
</td>
</tr>

<cfscript>
if(application.zcore.functions.zso(form, 'mls_option_listing_title_format') EQ ""){
	arrK=listToArray("city,remarks,address,subdivision,bedrooms,bathrooms,type,subtype,style,view,frontage,pool,condo");
	arrK=application.zcore.functions.zRandomizeArray(arrK);
	form.mls_option_listing_title_format=arrayToList(arrK, ",");
}
</cfscript>
<tr><th>Title Format:</th>
<td><input type="text" name="mls_option_listing_title_format" value="#htmleditformat(form.mls_option_listing_title_format)#" /> 
</td></tr>

<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
	WHERE site_id=#db.param(this.site_id)# and 
	mls_option_deleted = #db.param(0)#
</cfsavecontent><cfscript>qM=db.execute("qM");
	application.zcore.functions.zquerytostruct(qM);
   application.zcore.functions.zstatushandler(request.zsid,true,true);
	</cfscript>
<tr>
<th>Rentals Only:</th>
<td>
<input type="radio" name="mls_option_rentals_only" value="1" <cfif form.mls_option_rentals_only EQ 1 >checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_rentals_only" value="0" <cfif form.mls_option_rentals_only EQ 0 or form.mls_option_rentals_only EQ "">checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Disable Detail Indexing:</th>
<td>
<input type="radio" name="mls_option_disable_detail_indexing" value="1" <cfif form.mls_option_disable_detail_indexing EQ 1 or form.mls_option_disable_detail_indexing EQ "">checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_disable_detail_indexing" value="0" <cfif form.mls_option_disable_detail_indexing EQ 0>checked="checked"</cfif>> No (Note: Yes means robots can't index/follow mls listing detail pages, nor the real estate site map.)
</td></tr>
<tr>
<th>Compliant IDX:</th>
<td>
<input type="radio" name="mls_option_compliantidx" value="1" <cfif form.mls_option_compliantidx EQ 1 or form.mls_option_compliantidx EQ "">checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_compliantidx" value="0" <cfif form.mls_option_compliantidx EQ 0>checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Email Listing Agent Only?</th>
<td>
<input type="radio" name="mls_option_email_listing_agent_only" value="1" <cfif form.mls_option_email_listing_agent_only EQ 1>checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_email_listing_agent_only" value="0" <cfif form.mls_option_email_listing_agent_only EQ 0 or form.mls_option_email_listing_agent_only EQ "">checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Lead Capture Pop-up:</th>
<td>
<input type="radio" name="mls_option_inquiry_pop_enabled" value="1" <cfif form.mls_option_inquiry_pop_enabled EQ 1>checked="checked"</cfif>> After Xth page view
<br />
<input type="radio" name="mls_option_inquiry_pop_enabled" value="3" <cfif form.mls_option_inquiry_pop_enabled EQ 3>checked="checked"</cfif>> Immediately after searching.<br /> 
<input type="radio" name="mls_option_inquiry_pop_enabled" value="2" <cfif form.mls_option_inquiry_pop_enabled EQ 2>checked="checked"</cfif>> On viewing Xth listing.<br /> 
<input type="radio" name="mls_option_inquiry_pop_enabled" value="0" <cfif form.mls_option_inquiry_pop_enabled EQ 0 or form.mls_option_inquiry_pop_enabled EQ "">checked="checked"</cfif>> Disabled
<hr />
Page count: <input type="text" name="mls_option_inquiry_pop_count" size="3" value="#form.mls_option_inquiry_pop_count#" /> | 
<input type="radio" name="mls_option_inquiry_pop_forced" value="1" <cfif form.mls_option_inquiry_pop_forced EQ 1>checked="checked"</cfif>> Forced | <input type="radio" name="mls_option_inquiry_pop_forced" value="0" <cfif form.mls_option_inquiry_pop_forced EQ 0 or form.mls_option_inquiry_pop_forced EQ "">checked="checked"</cfif>> Optional | Custom URL: 
<input type="text" name="mls_option_inquiry_pop_customurl" value="#htmleditformat(form.mls_option_inquiry_pop_customurl)#" />
<br />&nbsp;
</td></tr>

<tr>
<th>Enable Listing Alerts:</th>
<td>
<input type="radio" name="mls_option_listing_alerts" value="1" <cfif form.mls_option_listing_alerts EQ 1 or form.mls_option_listing_alerts EQ "">checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_listing_alerts" value="0" <cfif form.mls_option_listing_alerts EQ 0>checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Enable Mortgage Quote:</th>
<td>
<input type="radio" name="mls_option_enable_mortgage_quote" value="1" <cfif form.mls_option_enable_mortgage_quote EQ 1 or form.mls_option_enable_mortgage_quote EQ "">checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_enable_mortgage_quote" value="0" <cfif form.mls_option_enable_mortgage_quote EQ 0>checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Detail Layout:</th>
<td>
<input type="radio" name="mls_option_detail_layout" value="1" <cfif form.mls_option_detail_layout EQ 1 or form.mls_option_detail_layout EQ "">checked="checked"</cfif>> New
<input type="radio" name="mls_option_detail_layout" value="0" <cfif form.mls_option_detail_layout EQ 0>checked="checked"</cfif>> Old
<input type="radio" name="mls_option_detail_layout" value="2" <cfif form.mls_option_detail_layout EQ 2>checked="checked"</cfif>> Custom</td>
</tr>
<tr>
<th>Detail CFC:</th>
<td>
<input type="template" name="mls_option_detail_cfc" value="#form.mls_option_detail_cfc#" /> (i.e. root.mvc.controller.listing) (Only works with "Detail Layout" set to "custom")
</td></tr>
<tr>
<th>Detail Method:</th>
<td>
<input type="template" name="mls_option_detail_method" value="#form.mls_option_detail_method#" /> (i.e. index)
</td></tr>  
<tr><th>Search URL:</th>
<td><input type="text" name="mls_option_search_template" value="#htmleditformat(form.mls_option_search_template)#" /> Override listing search form url with custom url.
</td></tr>
<tr><th>Search CFC Path:</th>
<td><input type="text" name="mls_option_search_cfc_path" value="#htmleditformat(form.mls_option_search_cfc_path)#" /> (i.e. root.mvc.controller.search) 
</td></tr>
<tr><th>Search CFC Method:</th>
<td><input type="text" name="mls_option_search_cfc_method" value="#htmleditformat(form.mls_option_search_cfc_method)#" /> (i.e. index) 
</td></tr>
<tr>
<th>Search Header CFC Path</th>
<td><input type="text" name="mls_option_search_header_cfc_path" id="mls_option_search_header_cfc_path" value="#htmleditformat(form.mls_option_search_header_cfc_path)#" /><br />(Should begin with zcorerootmapping, root or another root relative path.)</td>
</tr>
<tr>
<th>Search Header CFC Method</th>
<td><input type="text" name="mls_option_search_header_cfc_method" id="mls_option_search_header_cfc_method" value="#htmleditformat(form.mls_option_search_header_cfc_method)#" /><br />(A function name in the CFC with access="public")</td>
</tr>
<tr>
<th>Search Listing Result CFC Path</th>
<td><input type="text" name="mls_option_listing_result_cfc_path" id="mls_option_listing_result_cfc_path" value="#htmleditformat(form.mls_option_listing_result_cfc_path)#" /><br />(Should begin with zcorerootmapping, root or another root relative path.)</td>
</tr>
<tr>
<th>Search Listing Result CFC Method</th>
<td><input type="text" name="mls_option_listing_result_cfc_method" id="mls_option_listing_result_cfc_method" value="#htmleditformat(form.mls_option_listing_result_cfc_method)#" /><br />(A function name in the CFC with access="public")</td>
</tr>
<tr>
<th>Search Footer CFC Path</th>
<td><input type="text" name="mls_option_search_footer_cfc_path" id="mls_option_search_footer_cfc_path" value="#htmleditformat(form.mls_option_search_footer_cfc_path)#" /><br />(Should begin with zcorerootmapping, root or another root relative path.)</td>
</tr>
<tr>
<th>Search Footer CFC Method</th>
<td><input type="text" name="mls_option_search_footer_cfc_method" id="mls_option_search_footer_cfc_method" value="#htmleditformat(form.mls_option_search_footer_cfc_method)#" /><br />(A function name in the CFC with access="public")</td>
</tr>
<tr><th>Force links to use<br /> custom search template:</th>
<td>
<input type="radio" name="mls_option_search_template_forced" value="1" <cfif form.mls_option_search_template_forced EQ 1>checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_search_template_forced" value="0" <cfif form.mls_option_search_template_forced EQ 0 or form.mls_option_search_template_forced EQ "">checked="checked"</cfif>> No
</td></tr>

<tr>
<th>Instant Search:</th>
<td>
<input type="radio" name="mls_option_enable_instant_search" value="1" <cfif form.mls_option_enable_instant_search EQ 1>checked="checked"</cfif>> Yes <!--- change this to default when it is ready --->
<input type="radio" name="mls_option_enable_instant_search" value="0" <cfif form.mls_option_enable_instant_search EQ 0 or form.mls_option_enable_instant_search EQ "">checked="checked"</cfif>> No
</td></tr>
<tr>
<th>List Layout:</th>
<td>
<input type="radio" name="mls_option_list_layout" value="2" <cfif form.mls_option_list_layout EQ 2 or form.mls_option_list_layout EQ "">checked="checked"</cfif>> Grid
<input type="radio" name="mls_option_list_layout" value="1" <cfif form.mls_option_list_layout EQ 1>checked="checked"</cfif>> List
<input type="radio" name="mls_option_list_layout" value="0" <cfif form.mls_option_list_layout EQ 0>checked="checked"</cfif>> Detail 
<br /><br />Force update existing layout setting for all site content one time right now?: <input type="checkbox" name="forceupdatelistlayout" value="1" />
</td></tr>
<tr>
<th>Enable Walkscore:</th>
<td>
<input type="radio" name="mls_option_enable_walkscore" value="1" <cfif form.mls_option_enable_walkscore EQ 1 or form.mls_option_enable_walkscore EQ "">checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_enable_walkscore" value="0" <cfif form.mls_option_enable_walkscore EQ 0>checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Hide Map Until Search Results:</th>
<td>
<input type="radio" name="mls_option_hide_map_until_search" value="1" <cfif form.mls_option_hide_map_until_search EQ 1>checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_hide_map_until_search" value="0" <cfif form.mls_option_hide_map_until_search EQ 0 or form.mls_option_hide_map_until_search EQ "">checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Agent Listings First?:</th>
<td>
<input type="radio" name="mls_option_sort_agent_top" value="1" <cfif form.mls_option_sort_agent_top EQ 1 or form.mls_option_sort_agent_top EQ "">checked="checked"</cfif>> Yes       <input type="radio" name="mls_option_sort_agent_top" value="0" <cfif form.mls_option_sort_agent_top EQ 0>checked="checked"</cfif>> No | Note: Yes, will remove the option from entire site and force every search to have this enabled.
</td></tr>
<tr>
<th>Firm Listings First?:</th>
<td>
<input type="radio" name="mls_option_sort_office_top" value="1" <cfif form.mls_option_sort_office_top EQ 1 or form.mls_option_sort_office_top EQ "">checked="checked"</cfif>> Yes  
<input type="radio" name="mls_option_sort_office_top" value="0" <cfif form.mls_option_sort_office_top EQ 0>checked="checked"</cfif>> No  | Note: Yes, will remove the option from entire site and force every search to have this enabled.
</td></tr>
<tr>
<th>Missing Listing Behavior:</th>
<td>
<input type="radio" name="mls_option_missing_listing_behavior" value="1" <cfif form.mls_option_missing_listing_behavior EQ 1 or form.mls_option_missing_listing_behavior EQ "">checked="checked"</cfif>> 404  
<input type="radio" name="mls_option_missing_listing_behavior" value="0" <cfif form.mls_option_missing_listing_behavior EQ 0>checked="checked"</cfif>> 301 to home page
</td></tr>

<tr>
<th>Disable Search:</th>
<td>
<input type="radio" name="mls_option_disable_search" value="1" <cfif form.mls_option_disable_search EQ 1>checked="checked"</cfif>> Yes 
<input type="radio" name="mls_option_disable_search" value="0" <cfif form.mls_option_disable_search EQ 0 or form.mls_option_disable_search EQ "">checked="checked"</cfif>> No 
</td></tr>
<tr>
<th>Image Thumbnail Interface:</th>
<td>
<input type="radio" name="mls_option_disable_image_enlarge" value="2" <cfif form.mls_option_disable_image_enlarge EQ 2 or form.mls_option_disable_image_enlarge EQ "">checked="checked"</cfif>> Next/Prev buttons
<input type="radio" name="mls_option_disable_image_enlarge" value="1" <cfif form.mls_option_disable_image_enlarge EQ 1>checked="checked"</cfif>> Show only 1 photo
<input type="radio" name="mls_option_disable_image_enlarge" value="0" <cfif form.mls_option_disable_image_enlarge EQ 0>checked="checked"</cfif>> Enlarger 
</td></tr>

<tr>
<th>Override<br />
Primary Cities:</th>
<td>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# city WHERE 
	city_deleted = #db.param(0)#
	ORDER BY city_name ASC
	</cfsavecontent><cfscript>qpcity=db.execute("qpcity");</cfscript> 
	Select a city and click add to override the default cities shown in the search form.<br /><br />
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "city_idlist";
	selectStruct.query = qpcity;
	selectStruct.queryLabelField = "##city_name##, ##state_abbr##, ##country_code##";
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryValueField = "city_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput(' <input type="button" name="submitpcity" onclick="setpcityBlock2(true);" value="Add" />');
	</cfscript>
	<div id="pcityBlock"></div>
	 <cfscript>
			 form.mls_option_primary_city_list=replace(form.mls_option_primary_city_list,chr(9),"','","ALL");
			 db.sql="SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# city 
			WHERE city_id IN (#db.trustedSQL("'#form.mls_option_primary_city_list#'")#) and 
			city_deleted = #db.param(0)#
			ORDER BY city_name ASC";
			qpcity=db.execute("qpcity");
			</cfscript>
	<script type="text/javascript">
			/* <![CDATA[ */
			var arrpcityBlock=[];
			var arrpcityIdBlock=[];
			<cfif application.zcore.functions.zso(form, 'city_idlist') NEQ "">
				<cfscript>
				arrT=listtoarray(city_idlist,chr(9));
				for(i=1;i LTE arraylen(arrT);i++){
					writeoutput('arrpcityBlock.push("#jsstringformat(arrT[i])#");');
				}
				</cfscript>
			<cfelse>
				<cfloop query="qpcity">arrpcityBlock.push("#jsstringformat('#qpcity.city_name#, #qpcity.state_abbr#, #qpcity.country_code#')#");arrpcityIdBlock.push("#jsstringformat(qpcity.city_id)#");</cfloop>
			</cfif>
			function removepcity(id){
				var ab=[];
				var ab2=[];
				for(i=0;i<arrpcityBlock.length;i++){
					if(id!=i){ ab.push(arrpcityBlock[i]);ab2.push(arrpcityIdBlock[i]); }
				}
				arrpcityBlock=ab;
				arrpcityIdBlock=ab2;
				setpcityBlock(false);
			}
	function setpcityBlock2(checkField){
				var d=document.zAppForm.city_idlist.options[document.zAppForm.city_idlist.selectedIndex].text;
				var d2=document.zAppForm.city_idlist.options[document.zAppForm.city_idlist.selectedIndex].value;
				document.zAppForm.pcitybox.value=d;
				document.zAppForm.pcityidbox.value=d2;
				setpcityBlock(checkField);
			}
	function setpcityBlock(checkField){
				if(checkField){
					var cname=document.zAppForm.pcitybox.value.replace(/^\s+|\s+$/g, '');
					var cid=document.zAppForm.pcityidbox.value;
					if(cname.length == 0){
						alert('Please type a phrase before clicking the add button.');
						return;
					}
					document.zAppForm.pcitybox.value="";
					for(var i=0;i<arrpcityBlock.length;i++){
						if(arrpcityBlock[i] == cname){
							alert('This city is already selected.');
							return;
						}
					}
					arrpcityBlock.push(cname);
					arrpcityIdBlock.push(cid);
				}
				var cb=document.getElementById("pcityBlock");
				arrpcityBlock2=[];
				arrpcityBlock2.push('<table style=" border-spacing:0px;border:1px solid ##CCCCCC;">');
				for(var i=0;i<arrpcityBlock.length;i++){
					var s='style="background-color:##F2F2F2;"';
					if(i%2==0){
						s="";
					}
					arrpcityBlock2.push('<tr '+s+'><td>'+arrpcityBlock[i]+'<\/td><td><a href="##" onclick="removepcity('+(arrpcityBlock2.length-1)+'); return false;" title="Click to remove association to this pcity.">Remove<\/a><\/td><\/tr>');
				}
				arrpcityBlock2.push('<\/table>');
				arrpcityBlock2.push('<input type="hidden" name="pcitybox" value=""><input type="hidden" name="pcityidbox" value=""><input type="hidden" name="mls_option_primary_city_list" value="'+arrpcityIdBlock.join("\t")+'">');
				cb.innerHTML=arrpcityBlock2.join('');
				if(arrpcityBlock2.length==0){
					cb.style.display="inline";
				}else{
					cb.style.display="block";
				}
			}
			setpcityBlock(false);
			/* ]]> */
			</script>
</td></tr>

<tr>
<th>Exclude Cities:</th>
<td>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# city WHERE 
	city_deleted = #db.param(0)# 
	ORDER BY city_name ASC
	</cfsavecontent><cfscript>qexcity2=db.execute("qexcity2");</cfscript> 
	Select a city and click add to override the default cities shown in the search form.<br /><br />
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "city_idlist2";
	selectStruct.query = qexcity2;
	//selectStruct.style="monoMenu";
	selectStruct.queryLabelField = "##city_name##, ##state_abbr##, ##country_code##";
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryValueField = "city_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	writeoutput(' <input type="button" name="submitexcity" onclick="setexcityBlock2(true);" value="Add" />');
	</cfscript>
	<div id="excityBlock"></div>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# city 
	WHERE city_id IN (#db.trustedSQL("'#replace(application.zcore.functions.zescape(form.mls_option_exclude_city_list),chr(9),"','","ALL")#'")#) and 
	city_deleted = #db.param(0)#
	ORDER BY city_name ASC
	</cfsavecontent><cfscript>qexcity=db.execute("qexcity");</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	var arrexcityBlock=[];
	var arrexcityIdBlock=[];
	<cfif application.zcore.functions.zso(form, 'city_idlist2') NEQ "">
		<cfscript>
		arrT=listtoarray(city_idlist2,chr(9));
		for(i=1;i LTE arraylen(arrT);i++){
			writeoutput('arrexcityBlock.push("#jsstringformat(arrT[i])#");');
		}
		</cfscript>
	<cfelse>
		<cfloop query="qexcity">arrexcityBlock.push("#jsstringformat('#qexcity.city_name#, #qexcity.state_abbr#, #qexcity.country_code#')#");arrexcityIdBlock.push("#jsstringformat(qexcity.city_id)#");</cfloop>
	</cfif>
	function removeexcity(id){
		var ab=[];
		var ab2=[];
		for(i=0;i<arrexcityBlock.length;i++){
			if(id!=i){ ab.push(arrexcityBlock[i]);ab2.push(arrexcityIdBlock[i]); }
		}
		arrexcityBlock=ab;
		arrexcityIdBlock=ab2;
		setexcityBlock(false);
	}
	function setexcityBlock2(checkField){
		var d=document.zAppForm.city_idlist2.options[document.zAppForm.city_idlist2.selectedIndex].text;
		var d2=document.zAppForm.city_idlist2.options[document.zAppForm.city_idlist2.selectedIndex].value;
		document.zAppForm.excitybox.value=d;
		document.zAppForm.excityidbox.value=d2;
		setexcityBlock(checkField);
	}
	function setexcityBlock(checkField){
		if(checkField){
			var cname=document.zAppForm.excitybox.value.replace(/^\s+|\s+$/g, '');
			var cid=document.zAppForm.excityidbox.value;
			if(cname.length == 0){
				alert('Please type a phrase before clicking the add button.');
				return;
			}
			document.zAppForm.excitybox.value="";
			for(var i=0;i<arrexcityBlock.length;i++){
				if(arrexcityBlock[i] == cname){
					alert('This city is already selected.');
					return;
				}
			}
			arrexcityBlock.push(cname);
			arrexcityIdBlock.push(cid);
		}
		var cb=document.getElementById("excityBlock");
		arrexcityBlock2=[];
		arrexcityBlock2.push('<table style=" border-spacing:0px;border:1px solid ##CCCCCC;">');
		for(var i=0;i<arrexcityBlock.length;i++){
			var s='style="background-color:##F2F2F2;"';
			if(i%2==0){
				s="";
			}
			arrexcityBlock2.push('<tr '+s+'><td>'+arrexcityBlock[i]+'<\/td><td><a href="##" onclick="removeexcity('+(arrexcityBlock2.length-1)+'); return false;" title="Click to remove association to this excity.">Remove<\/a><\/td><\/tr>');
		}
		arrexcityBlock2.push('<\/table>');
		arrexcityBlock2.push('<input type="hidden" name="excitybox" value=""><input type="hidden" name="excityidbox" value=""><input type="hidden" name="mls_option_exclude_city_list" value="'+arrexcityIdBlock.join("\t")+'">');
		cb.innerHTML=arrexcityBlock2.join('');
		if(arrexcityBlock2.length==0){
			cb.style.display="inline";
		}else{
			cb.style.display="block";
		}
	}
	setexcityBlock(false);
	/* ]]> */
	</script>
</td></tr>
<tr>
<th>Site Map Radius:</th>
<td><input type="text" name="mls_option_site_map_radius" value="<cfif form.mls_option_site_map_radius EQ "">1<cfelse>#form.mls_option_site_map_radius#</cfif>"> (Never decrease this numeric value)
</td></tr>
<tr>
<th>Site Map Radius Growth Rate:</th>
<td><input type="text" name="mls_option_site_map_growth_rate" value="<cfif form.mls_option_site_map_growth_rate EQ "">1<cfelse>#form.mls_option_site_map_growth_rate#</cfif>"> (Radius will grow each day by this number of miles - This can be a decimal)
</td></tr>
<tr>
<th>Site Map URL ID:</th>
<td>
	<cfscript>
			writeoutput(application.zcore.app.selectAppUrlId("mls_option_site_map_url_id", form.mls_option_site_map_url_id, this.app_id));
		</cfscript> (Optional, leave blank to disable.)
</td></tr>

<tr>
<th>Site Map Primary City:</th>
<td>
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "mls_option_site_map_primary_city";
	selectStruct.query = qexcity2;
	selectStruct.queryLabelField = "##city_name##, ##state_abbr##, ##country_code##";
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryValueField = "city_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript> (The radius extends from the center of this city)
</td></tr>
<tr>
<th>Limit Map to 1 State:</th>
<td>#application.zcore.functions.zstateselect("mls_option_map_state", form.mls_option_map_state)#
</td>
</tr>
<tr>
<th>Max Map Distance:</th>
<cfscript>
if(not isnumeric(form.mls_option_max_map_distance_from_primary)){
	form.mls_option_max_map_distance_from_primary=0;
}else if(form.mls_option_max_map_distance_from_primary GT 200){
	form.mls_option_max_map_distance_from_primary=200;
}else if(form.mls_option_max_map_distance_from_primary LT 0){
	form.mls_option_max_map_distance_from_primary=0;
}
</cfscript>
<td><input type="text" name="mls_option_max_map_distance_from_primary" value="#htmleditformat(form.mls_option_max_map_distance_from_primary)#" /><br />
Enter the maximum distance from the center of the primary city that you want the map to zoom out to. (Unit: miles) Maximum value is 200.  The default of 0 also defaults to 200 miles.
</td>
</tr>
<tr>
<th>Directory URL ID:</th>
<td>
	<cfscript>
			writeoutput(application.zcore.app.selectAppUrlId("mls_option_dir_url_id", form.mls_option_dir_url_id, this.app_id));
		</cfscript>
</td></tr>
</table>
</cfsavecontent>
<cfscript>
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>

<cffunction name="checkRamTables" localmode="modern" output="no" returntype="any">
<cfscript>
	var arrTables=0;
	var arrTables2=0;
	var arrTables3=0;
	var cfhttpresult=0;
	var arrQ2=0;
	var i=0;
	var db=request.zos.queryObject;
	var qc=0;
	var ts=0;
	if(structkeyexists(form, 'zrebuildramtable')){
		arrTables=['city','city_distance','listing'];//,'listing_feature','listing_property_type'];//'content',
	}else{
		arrTables2=['city','city_distance','listing'];
		arrTables4=['city_memory','city_distance_memory','listing_memory'];
		arrTables3=['city_id','city_id','listing_id'];
		arrTables=arraynew(1);
		arrQ2=arraynew(1);

		db.sql="SHOW TABLES IN `#request.zos.zcoreDatasource#` WHERE `Tables_in_#request.zos.zcoreDatasource#` IN 
		(#db.param('zram##city')#, #db.param('zram##city_distance')#, #db.param('zram##listing')#)";
		qOldCheck=db.execute("qOldCheck");
		if(qOldCheck.recordcount EQ 3){
			
			db.sql="RENAME TABLE 
			#db.table("zram##city", request.zos.zcoreDatasource)#  TO 
			#db.table("city_memory", request.zos.zcoreDatasource)# , 
			#db.table("zram##city", request.zos.zcoreDatasource)#  TO 
			#db.table("city_distance_memory", request.zos.zcoreDatasource)# , 
			#db.table("zram##listing", request.zos.zcoreDatasource)#  TO 
			#db.table("listing_memory", request.zos.zcoreDatasource)# ";
			db.execute("qRename");
		}

		db.sql="SHOW TABLES IN `#request.zos.zcoreDatasource#` WHERE `Tables_in_#request.zos.zcoreDatasource#` IN 
		(#db.param('city_memory')#, #db.param('city_distance_memory')#, #db.param('listing_memory')#)";
		qCheckRamTables=db.execute("qCheckRamTables");
		if(qCheckRamTables.recordcount NEQ 3){
			arrTables=['city','city_distance','listing'];
		}else{
			for(i=1;i<=arraylen(arrTables2);i++){
			arrayappend(arrQ2,"(SELECT #arrTables3[i]# id FROM #db.table("#arrTables4[i]#", request.zos.zcoreDatasource)#  
				LIMIT #db.param(0)#,#db.param(1)#)");
			}
			db.sql=arraytolist(arrQ2,' UNION ALL ')&' UNION ALL (SELECT #db.param(0)# id)';
			qC=db.execute("qC");
			if(isQuery(qC) EQ false or qC.recordcount NEQ 4){
				arrTables=arrTables2;
			}
		}
	}
	
	for(i=1;i<=arraylen(arrTables);i++){
		ts={};
		ts.table=arrTables[i];
		if(arrTables[i] EQ 'listing' or structkeyexists(form, 'zrebuildramtable')){
			ts.force=true;
		}
		ts.allowFulltext=true;
		this.zCreateMemoryTable(ts);
	}
	</cfscript>
</cffunction>

<cffunction name="updateSearchFilter" localmode="modern" output="no" returntype="any">
<cfscript>
	var propCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.propertyData");
	var ts=propCom.getSearchFilter(application.zcore.app.getAppData("listing").sharedStruct);
	application.zcore.functions.zdownloadlink(request.zos.currentHostName&"/z/listing/tasks/generateData/index");
	</cfscript>
</cffunction>

<cffunction name="onSiteStart" localmode="modern" output="no" returntype="struct">
<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this site.">
<cfscript>
	var arrq2=0;
	var qmls=0;
	var arrmlsid=0;
	var arrmlsid2=0;
	var arragentsql=0;
	var arrofficesql=0;
	var qm=0;
	var qmls=0;
	var usergroupcom=0;
	var userusergroupid=0;
	var arrk2=0;
	var ts4372=0;
	var n=0;
	var propcom=0;
	var arrm=0;
	var arrM343=0;
	var mAIstruct=0;
	var arrP=0;
	var arrI=0;
	var arrA1=0;
	var qtypes=0;
	var db=request.zos.queryObject;
	
	var i=0;
	var x="";
	var ts=structnew();
	ts=StructNew();
	
	db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls, 
	#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls 

	WHERE mls.mls_id = app_x_mls.mls_id and 
	app_x_mls.site_id = #db.param(request.zos.globals.id)# and 
	mls_deleted = #db.param(0)# and 
	app_x_mls_deleted = #db.param(0)# and
	mls_status=#db.param(1)#";
	qMLS=db.execute("qMLS");
	arrMlsId=ArrayNew(1);
	arrMlsId2=ArrayNew(1);
	ts.optionStruct=structnew();
	ts.mlsStruct=structnew();
	ts.urlMLSIdStruct=structnew();
	arrAgentSQL=arraynew(1);
	arrOfficeSQL=arraynew(1);
	ts.mls_primary_city_id=0;
	ts.mlsIdLookup=structnew();

	primaryNotSet=true;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	mls_option_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qM=db.execute("qM");
	arrM343=listtoarray(qm.columnlist,",");
	</cfscript>
	<cfloop query="qM">
		<cfscript>
			for(i=1;i LTE arraylen(arrM343);i++){
				ts.optionStruct[arrM343[i]]=qM[arrM343[i]];
			}
			ts.optionStruct["mls_option_primary_city_list"]=replace(qM.mls_option_primary_city_list,chr(9),"','","ALL");
			ts.optionStruct["mls_option_exclude_city_list"]=replace(qM.mls_option_exclude_city_list,chr(9),"','","ALL");
			</cfscript>
	</cfloop>
	<cfloop query="qMLS">
		<cfscript>
		ts.mlsIdLookup[qMLS.mls_provider]=qMLS.mls_id; 
		arrayappend(arrMlsId,"'#qMLS.mls_id#'");
		ts.mlsStruct[qMLS.mls_id]=structnew();
		ts.mlsStruct[qMLS.mls_id].app_x_mls_office_id=replace(qMLS.app_x_mls_office_id,",","','","ALL");
		ts.mlsStruct[qMLS.mls_id].app_x_mls_agent_id=qMLS.app_x_mls_agent_id;
		
		ts.mlsStruct[qMLS.mls_id].agentIdStruct=structnew();
		ts.mlsStruct[qMLS.mls_id].userAgentIdStruct=structnew();
		ts.mlsStruct[qMLS.mls_id].memberAgentIdStruct=structnew();
		userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
		db.sql="select *, user.site_id userSiteId from #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user.site_id = #db.param(request.zos.globals.id)#  and 
		user_group_id <>#db.param(userusergroupid)# and 
		user_active= #db.param(1)# and 
		member_public_profile= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		member_mlsagentid LIKE #db.param('%,#qMLS.mls_id#-%')#"; 
		qM=db.execute("qM"); 
		for(x=1; x LTE qM.recordcount; x++) {
			if(qM.member_mlsagentid[x] NEQ ''){
				arrP=listtoarray(qM.member_mlsagentid[x],',');
				for(i=1;i LTE arraylen(arrP);i++){
					arrI=listtoarray(arrP[i],'-');
					if(arraylen(arrI) EQ 2 and qMLS.mls_id EQ arrI[1]){
						arrK2=listtoarray(qm.columnlist);
						ts4372=structnew();
						/*for(n=1;n LTE arraylen(arrK2);n++){
							ts4372[arrK2[n]]=qM[arrK2[n]][x];
						}*/
						ts4372.userSiteId=qM.userSiteId[x];
						ts4372.member_photo=qM.member_photo[x];
						ts4372.member_first_name=qM.member_first_name[x];
						ts4372.member_last_name=qM.member_last_name[x];
						ts4372.member_phone=qM.member_phone[x];
						ts4372.member_public_profile=qM.member_public_profile[x];
						ts4372.user_id=qM.user_id[x];
						ts.mlsStruct[qMLS.mls_id].userAgentIdStruct[ts4372.user_id]=structnew();
						ts.mlsStruct[qMLS.mls_id].userAgentIdStruct[ts4372.user_id][arrI[2]]=true;
						ts.mlsStruct[qMLS.mls_id].agentIdStruct[arrI[2]]=ts4372;
					}
				}
			}
		}
		
		
		ts.mlsStruct[qMLS.mls_id].app_x_mls_url_id=qMLS.app_x_mls_url_id;
		ts.mlsStruct[qMLS.mls_id].mls_id=qMLS.mls_id;
		ts.mlsStruct[qMLS.mls_id].app_x_mls_primary=qMLS.app_x_mls_primary;
		if(qMLS.app_x_mls_primary EQ 1 or (primaryNotSet and qMLS.recordcount EQ qMLS.currentRow)){
			ts.primaryMlsId=qMLS.mls_id;
			primaryNotSet=false;
			ts.mls_primary_city_id=qMLS.mls_primary_city_id;
		}
		ts.urlMLSIdStruct[qMLS.app_x_mls_url_id]=qMLS.mls_id;
		arrA1=listtoarray(qMLS.app_x_mls_agent_id,",");
		for(x=1;x<=arraylen(arrA1);x++){
			if(trim(arrA1[x]) NEQ ''){
				arrayappend(arrAgentSQL, "(`listing`.listing_agent ='#application.zcore.functions.zescape(arrA1[x])#' and `listing`.listing_id like '#ts.mlsStruct[qMLS.mls_id].mls_id#-%')");
			}
		}
		arrA1=listtoarray(qMLS.app_x_mls_office_id,",");
		for(x=1;x<=arraylen(arrA1);x++){
			if(trim(arrA1[x]) NEQ ''){
				arrayappend(arrOfficeSQL, "(`listing`.listing_office ='#application.zcore.functions.zescape(arrA1[x])#' and `listing`.listing_id like '#ts.mlsStruct[qMLS.mls_id].mls_id#-%')");
			}
		}
		</cfscript>
	</cfloop>
	<cfscript>
	local.primaryCityId=ts.mls_primary_city_id; 

	db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
	WHERE city_deleted = #db.param(0)# and 
	city_id=#db.param(primaryCityId)# ";
	qC2=db.execute("qC2"); 

	ts.latLongBoundaries=''; 
	if(qC2.recordcount NEQ 0 and qC2.city_latitude NEQ 0){

		distanceFromPrimary=max(200, ts.optionStruct.mls_option_max_map_distance_from_primary);
		diffDegree=distanceFromPrimary/69;
		ts.latLongBoundaries=' and (listing_latitude = 0 or (
		listing_latitude>=#qC2.city_latitude-diffDegree# and 
		listing_latitude<=#qC2.city_latitude+diffDegree# and 
		listing_longitude>=#qC2.city_longitude-diffDegree# and 
		listing_longitude<=#qC2.city_longitude+diffDegree#)) ';
			 
	}

	if(local.primaryCityId NEQ 0){
		db.sql="SELECT city_latitude avgLat, city_longitude avgLong 
		FROM #db.table("city_memory", request.zos.zcoreDatasource)# city 
		WHERE city_id = #db.param(local.primaryCityId)# and 
		city_deleted = #db.param(0)#";
		local.qCenterMap=db.execute("qCenterMap"); 
		if(local.qCenterMap.recordcount NEQ 0 and local.qCenterMap.avgLat NEQ "0"){
			ts.avgLat=local.qCenterMap.avgLat;
			ts.avgLong=local.qCenterMap.avgLong;
		}else{
			db.sql="SELECT AVG(listing_latitude) avgLat, AVG(listing_longitude) avgLong 
			FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
			WHERE listing_city = #db.param(local.primaryCityId)# AND 
			listing_latitude<> #db.param('')# and 
			listing_deleted = #db.param(0)# and 
			listing_longitude<> #db.param('')# and 
			listing_latitude #db.trustedSQL("BETWEEN -180 AND 180 AND listing_longitude BETWEEN -180 AND 180")# AND listing_latitude<> #db.param(0)# and 
			listing_longitude<> #db.param(0)#";
			local.qCenterMap=db.execute("qCenterMap"); 
			if(local.qCenterMap.recordcount NEQ 0 and local.qCenterMap.avgLat NEQ "0" and local.qCenterMap.avgLat NEQ ""){
				ts.avgLat=local.qCenterMap.avgLat;
				ts.avgLong=local.qCenterMap.avgLong;
			}else{
				ts.avgLat=29;
				ts.avgLong=-81;
			}
		}
	}else{
		ts.avgLat=29;
		ts.avgLong=-81;
	}
	ts.minLat=ts.avgLat-5;
	ts.maxLat=ts.avgLat+5;
	ts.minLong=ts.avgLong-5;
	ts.maxLong=ts.avgLong+5;

	ts.agentSQL=arraytolist(arrAgentSQL," or ");
	ts.officeSQL=arraytolist(arrOfficeSQL," or ");
	propCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts.filterStruct=propCom.getSearchFilter(ts);
	
	arrM=structkeyarray(ts.mlsstruct);
	arraysort(arrM,"numeric","asc");
	ts.cityLookupFileName='/z/a/listing/scripts/cityLookup/'&arraytolist(arrM,"-")&".js";
	if(arraylen(arrMLSId) EQ 0){
		ts.mls_id_list="(0)";
	}else{
		ts.mls_id_list="("&arraytolist(arrMLSId,",")&")";
	}
	ts.mls_id_list_simple=ts.mls_id_list;
	if(structkeyexists(ts.mlsStruct, 0)){
		ts.mls_id_list&=" AND (listing.listing_mls_id <> 0 OR RIGHT(listing.listing_id,5) = '#numberformat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString)#')";
	}
	ts.resetCacheTimespan=true;
	ts.listing.appStartComplete=true;
	structappend(arguments.sharedStruct,ts,true);
	
	return arguments.sharedStruct;
	</cfscript>
</cffunction>


<cffunction name="onMemoryDatabaseStart" localmode="modern" output="no" returntype="any">
<cfscript>
	this.checkRamTables();
	</cfscript>
</cffunction>

<cffunction name="onCodeDeploy" localmode="modern" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	arguments.ss.listingStruct["func"&"tions"]=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing-functions");
	if(structkeyexists(arguments.ss.listingStruct, 'mlsStruct')){
		for(i in arguments.ss.listingStruct.mlsStruct){
			tempCom=createobject("component",arguments.ss.listingStruct.mlsStruct[i].mlsComPath);
			tempCom.setMLS(i);
			//tempCom.baseInitImport(arguments.ss.mlsStruct[i].sharedStruct);
			//tempCom.init(arguments.ss.mlsStruct[i].sharedStruct);
			arguments.ss.listingStruct.mlsComObjects[i]=tempCom;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="onApplicationStart" localmode="modern" output="no" returntype="struct">
<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
<cfscript>
	var arrM343=0;
	var qc=0;
	var cs=structnew();
	var qmls=0;
	var arrN=0;
	var arrMLSId=0;
	var arrMLSId2=0;
	var arrtables=0;
	var arrtables2=0;
	var QSAVEDSEARCHFIELDS=0;
	var mAIstruct=0;
	var arrP=0;
	var db=request.zos.queryObject;
	var arrI=0;
	var arrA1=0;
	
	var qtypes=0;
	var i=0;
	var ts=structnew();
	var qC2=0;
	var x="";
	if(not structkeyexists(request.zos, 'listingTemp')){
		request.zos.listingTemp=structnew();
	}
	this.onMemoryDatabaseStart();
	if(structkeyexists(form, 'zrebuildramtable')){
		arrTables=['city','city_distance','listing'];
	}else{
		arrTables2=['city','city_distance','listing'];
		arrTables=arraynew(1);
		for(i=1;i<=arraylen(arrTables2);i++){
			db.sql="SELECT * FROM #db.table("#arrTables2[i]#_memory", request.zos.zcoreDatasource)# c 
			WHERE #arrTables2[i]#_deleted = #db.param(0)#
			LIMIT #db.param(0)#,#db.param(1)#";
			qC=db.execute("qC"); 
			if(isQuery(qC) EQ false or qC.recordcount EQ 0){
				arrayappend(arrTables,arrTables2[i]);
			}
		}
	}
	for(i=1;i<=arraylen(arrTables);i++){
		ts={};
		ts.table=arrTables[i];
		if(arrTables[i] EQ 'listing'){
			ts.force=true;
		}
		ts.allowFulltext=true;
		zCreateMemoryTable(ts);
	}
	ts=StructNew();
	ts.zeroPadString='00000';
	ts["func"&"tions"]=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing-functions");
	ts.cacheStruct=StructNew();
	
	db.sql="select city_id, city_name, state_abbr from #db.table("city", request.zos.zcoreDatasource)# city 
	WHERE city_deleted = #db.param(0)#";
	qC2=db.execute("qC2"); 
	ts.cityNameStruct=structnew();
	ts.cityStruct=structnew();
	</cfscript>
	<cfloop query="qC2">
		<cfscript>
		ts.cityNameStruct[qC2.city_id]=qC2.city_name;
		ts.cityStruct[qC2.city_name&"|"&qC2.state_abbr]=qC2.city_id;
		</cfscript>
	</cfloop>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("listing_type", request.zos.zcoreDatasource)# listing_type WHERE 
	listing_type_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qTypes=db.execute("qTypes");
	ts.cacheStruct.listing_type=StructNew();
	ts.cacheStruct.listing_type_seo=StructNew();
	ts.cacheStruct.listing_type_id=StructNew();
	for(i=1;i LTE qTypes.recordcount;i=i+1){
	    ts.cacheStruct.listing_type_id[qTypes.listing_type_code[i]] = qTypes.listing_type_id[i];
	    ts.cacheStruct.listing_type_name[qTypes.listing_type_id[i]] = qTypes.listing_type_name[i];
	    ts.cacheStruct.listing_type_seo[qTypes.listing_type_id[i]] = qTypes.listing_type_seo[i];
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls 
	WHERE mls_status = #db.param('1')# and 
	mls_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qMLS=db.execute("qMLS");
	arrMlsId=ArrayNew(1);
	arrMlsId2=ArrayNew(1);
	ts.mlsStruct=structnew();
	ts.mls_primary_city_id=0;
	
	ts.listingToSearch=structnew();
	ts.listingToSearch["listing_city"]="search_city_id";
	ts.listingToSearch["listing_view"]="search_view";
	ts.listingToSearch["listing_type_id"]="search_listing_type_id";
	ts.listingToSearch["listing_sub_type_id"]="search_listing_sub_type_id";
	ts.listingToSearch["listing_frontage"]="search_frontage";
	ts.listingToSearch["listing_status"]="search_status";
	ts.listingToSearch["listing_liststatus"]="search_liststatus";
	ts.listingToSearch["listing_acreage"]="search_acreage_low";
	ts.listingToSearch["listing_price"]="search_rate_low";
	ts.listingToSearch["listing_square_feet"]="search_sqfoot_low";
	ts.listingToSearch["listing_style"]="search_style";
	ts.listingToSearch["listing_year_built"]="search_year_built_low";
	ts.listingToSearch["listing_beds"]="search_bedrooms_low";
	ts.listingToSearch["listing_baths"]="search_bathrooms_low";
	ts.listingToSearch["listing_county"]="search_county";
	ts.listingToSearch["listing_pool"]="search_with_pool";
	ts.listingToSearch["listing_subdivision"]="search_subdivision";
	ts.listingToSearch["listing_region"]="search_region";
	ts.listingToSearch["listing_parking"]="search_parking";
	ts.listingToSearch["listing_condition"]="search_condition";
	ts.listingToSearch["listing_tenure"]="search_tenure";
	
	ts.listingToAbbr["listing_city"]="";
	ts.listingToAbbr["listing_view"]="view";
	ts.listingToAbbr["listing_type_id"]="listing_type";
	ts.listingToAbbr["listing_sub_type_id"]="listing_sub_type";
	ts.listingToAbbr["listing_frontage"]="frontage";
	ts.listingToAbbr["listing_status"]="status";
	ts.listingToAbbr["listing_acreage"]="acreage";
	ts.listingToAbbr["listing_price"]="";
	ts.listingToAbbr["listing_square_feet"]="";
	ts.listingToAbbr["listing_year_built"]="";
	ts.listingToAbbr["listing_style"]="style";
	ts.listingToAbbr["listing_beds"]="";
	ts.listingToAbbr["listing_baths"]="";
	ts.listingToAbbr["listing_county"]="county";
	ts.listingToAbbr["listing_pool"]="";
	ts.listingToAbbr["listing_subdivision"]="";
	ts.listingToAbbr["listing_region"]="region";
	ts.listingToAbbr["listing_parking"]="parking";
	ts.listingToAbbr["listing_condition"]="condition";
	ts.listingToAbbr["listing_tenure"]="tenure";
	db.sql="SELECT * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE site_id = #db.param(-1)# and 
	mls_saved_search_deleted = #db.param(0)#";
	qSavedSearchFields=db.execute("qSavedSearchFields"); 
	arrN=listtoarray(qSavedSearchFields.columnlist);
	ts.arrSearchFields=arraynew(1);
	for(i=1;i LTE arraylen(arrN);i++){
		if(left(arrN[i],7) EQ "search_"){
			arrayappend(ts.arrSearchFields,arrN[i]);
		}
	}
	ts.arrSearchFieldsOriginal=duplicate(ts.arrSearchFields);
	arraysort(ts.arrSearchFields,"text","asc");
	ts.arrShortSearchFields=listtoarray(replacenocase(arraytolist(ts.arrSearchFields),"search_","","ALL"));
	ts.mlsIdLookup=structnew();
	ts.mlsComObjects=structnew();
	</cfscript>
	<cfloop query="qMLS">
		<cfscript>
		ts.mlsIdLookup[qMLS.mls_provider]=qMLS.mls_id; 
		arrayappend(arrMlsId,"'#qMLS.mls_id#'");
		ts.mlsStruct[qMLS.mls_id]=structnew();
		ts.mlsStruct[qMLS.mls_id].mlsComPath="zcorerootmapping.mvc.z.listing.mls-provider.#qMLS.mls_com#";
		ts.mlsStruct[qMLS.mls_id].mls_id=qMLS.mls_id;
		ts.mlsStruct[qMLS.mls_id].mls_name=qMLS.mls_name;
		ts.mlsStruct[qMLS.mls_id].mls_disclaimer_name=qMLS.mls_disclaimer_name;
		ts.mlsStruct[qMLS.mls_id].mls_login_url=qMLS.mls_login_url;
		ts.mlsStruct[qMLS.mls_id].sharedStruct={ 
			metadataDateLastModified:createdate(2000,1,1)
		}
		</cfscript>
	</cfloop>
	<cfscript>
	local.arrKey=structkeyarray(ts.mlsStruct);
	local.arrThread=arraynew(1);
	local.arrThread2=arraynew(1);
	</cfscript>

	<cfdirectory directory="#request.zos.globals.serverprivatehomedir#_cache/listing/metadata/" name="local.qD" filter="*.txt">
	<cfloop query="local.qD">
		<cfscript>
			if(right(local.qD.name, 4) EQ ".txt"){
				local.mlsId=left(local.qD.name, len(local.qD.name)-4);
				if(structkeyexists(ts.mlsStruct, local.mlsId)){
					ts.mlsStruct[local.mlsID].sharedStruct.metadataDateLastModified=local.qD.dateLastModified;
				}
			}
			</cfscript>
	</cfloop>
	<!--- <cfif request.zos.istestserver or (request.zos.isdeveloper and structkeyexists(form, 'zdebug') and structkeyexists(form, 'zDisableThread'))> --->
		<cfloop from="1" to="#arraylen(local.arrKey)#" index="local.i93933">
			<cfscript>
			ts.mlsComObjects[local.arrKey[local.i93933]]=createobject("component",ts.mlsStruct[local.arrKey[local.i93933]].mlsComPath);
			ts.mlsComObjects[local.arrKey[local.i93933]].setMLS(local.arrKey[local.i93933]);
			ts.mlsComObjects[local.arrKey[local.i93933]].baseInitImport(ts.mlsStruct[local.arrKey[local.i93933]].sharedStruct);
			ts.mlsComObjects[local.arrKey[local.i93933]].init(ts.mlsStruct[local.arrKey[local.i93933]].sharedStruct);
			</cfscript>
		</cfloop>
	<!--- <cfelse>
	    <cfloop from="1" to="#arraylen(local.arrKey)#" index="local.i93933">
		<cfscript>
		arrayappend(local.arrThread, "mlsInitThread"&local.i93933);
		</cfscript>
		<cfthread action="run" mlsComObjects="#ts.mlsComObjects#" timeout="60" mlsStruct="#ts.mlsStruct#" mlsKey="#local.arrKey[local.i93933]#" name="mlsInitThread#local.i93933#">
		    <cfscript>
		    attributes.mlsComObjects[attributes.mlsKey]=createobject("component",attributes.mlsStruct[attributes.mlsKey].mlsComPath);
		    attributes.mlsComObjects[attributes.mlsKey].setMLS(attributes.mlsKey);
		    attributes.mlsComObjects[attributes.mlsKey].baseInitImport(attributes.mlsStruct[attributes.mlsKey].sharedStruct);
		    attributes.mlsComObjects[attributes.mlsKey].init(attributes.mlsStruct[attributes.mlsKey].sharedStruct);
		    </cfscript>
		</cfthread>
	    </cfloop>
	    <cfthread action="join" name="#arraytolist(local.arrThread2,',')#" timeout="50000"></cfthread>
	    <cfscript>
	    for(local.i2=1;local.i2 LTE arraylen(local.arrThread);local.i2++){
		local.ct=cfthread[local.arrThread[local.i2]];
		if(local.ct.status EQ "TERMINATED"){
		    writeoutput("Failed to compile: "&ts.mlsStruct[local.arrKey[local.i2]].mlsComPath&" | CFTHREAD ERROR: "&local.ct.error.message);
		    writedump(local.ct);
		    application.zcore.functions.zabort();
		}else{
		    // writedump(local.ct);
		}
	    }
	    </cfscript>
	</cfif> --->
	<cfscript>
	this.initListingLookup(ts);
	arguments.sharedStruct=ts;
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="makeListingImportDataReady" localmode="modern" access="remote">
	<cfscript>
	for(i in application.zcore.listingStruct.mlsComObjects){
		//mlsStruct=application.zcore.listingStruct.mlsStruct[i];
		mlsCom=application.zcore.listingStruct.mlsComObjects[i];
		mlsCom.makeListingImportDataReady(); 
	}
	</cfscript>
</cffunction>
	

<cffunction name="updateSearchCriteriaCache" localmode="modern" output="yes" returntype="any">
<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var cs=structnew();
	var debugSearchDir=false;
	var t9=0;
	var qr=0;
	var propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_city_id";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
//ts.searchStruct.lookupName="city";
ts.searchStruct.zselect=" city_name label, listing_city value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zleftjoin=" INNER JOIN #request.zos.zcoreDatasource#.`city_memory` city ON city.city_id = listing.listing_city ";
ts.searchStruct.zgroupby=" group by listing_city ";
ts.searchStruct.zwhere=" and listing_city not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY label";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=false;
t9.beginSQL="and listing_city = '";
t9.endSQL="'";
cs["listing_city"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_county";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="county";
ts.searchStruct.zselect=" listing_county value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_county ";
ts.searchStruct.zwhere=" and listing.listing_county not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=false;
t9.beginSQL="and listing_county = '";
t9.endSQL="'";
cs["listing_county"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_listing_type_id";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="listing_type";
ts.searchStruct.zselect=" listing_type_id value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_type_id ";
ts.searchStruct.zwhere=" and listing.listing_type_id not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=false;
t9.beginSQL="and listing_type_id = '";
t9.endSQL="'";
cs["listing_type_id"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_listing_sub_type_id";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="listing_sub_type";
ts.searchStruct.zselect=" listing_sub_type_id value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_sub_type_id ";
ts.searchStruct.zwhere=" and listing.listing_sub_type_id not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=false;
t9.beginSQL="and listing_sub_type_id = '";
t9.endSQL="'";
cs["listing_sub_type_id"]=t9;

ts = StructNew();
ts.debug=true;//debugSearchDir;
ts.name="search_view";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="view";
ts.searchStruct.zselect=" listing_view value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_view ";
ts.searchStruct.zwhere=" and listing.listing_view not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);
t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=true;
t9.beginSQL="and listing_view like '%,";
t9.endSQL=",%'";
cs["listing_view"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_status";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="status";
ts.searchStruct.zselect=" listing_status value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_status ";
ts.searchStruct.zwhere=" and listing.listing_status not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=true;
t9.beginSQL="and listing_status like '%,";
t9.endSQL=",%'";
cs["listing_status"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_liststatus";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="liststatus";
ts.searchStruct.zselect=" listing_liststatus value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_liststatus ";
ts.searchStruct.zwhere=" and listing.listing_liststatus not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=true;
t9.beginSQL="and listing_status like '%,";
t9.endSQL=",%'";
cs["listing_status"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_style";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="style";
ts.searchStruct.zselect=" listing_style value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_style ";
ts.searchStruct.zwhere=" and listing.listing_style not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=true;
t9.beginSQL="and listing_style like '%,";
t9.endSQL=",%'";
cs["listing_style"]=t9;

ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_frontage";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.lookupName="frontage";
ts.searchStruct.zselect=" listing_frontage value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_frontage ";
ts.searchStruct.zwhere=" and listing.listing_frontage not in ('','0') ";
ts.searchStruct.zorderby=" ORDER BY value";
ts.searchStruct.zReturnLookupQuery=true;
qr = propertyDataCom.getSearchData(ts);

t9=structnew();
t9.arrValues=arraynew(1);
t9.arrLabels=arraynew(1);
t9.arrCount=arraynew(1);
</cfscript><cfloop query="qr"><cfscript>
arrayappend(t9.arrValues,qr.value);
arrayappend(t9.arrLabels,qr.label);
arrayappend(t9.arrCount,qr.count);
</cfscript></cfloop><cfscript>
t9.valueCount=arraylen(t9.arrValues);
t9.multiple=true;
t9.beginSQL="and listing_frontage like '%,";
t9.endSQL=",%'";
cs["listing_frontage"]=t9;

return cs;
</cfscript>
</cffunction>

<cffunction name="checkSearchFieldCache" localmode="modern" output="no" returntype="any">
<cfargument name="force" type="boolean" required="no" default="#false#">
<cfscript>
	var tempStr=application.sitestruct[request.zos.globals.id].app.appCache[this.app_id].sharedStruct;
	if(structkeyexists(tempStr,'searchFieldCache') EQ false or arguments.force){
		if(structkeyexists(tempStr,'searchFieldCache') EQ false or arguments.force){
			application.sitestruct[request.zos.globals.id].app.appCache[this.app_id].sharedStruct.searchFieldCache=this.updateSearchCriteriaCache();
		}
	}
</cfscript>
</cffunction>
		
<cffunction name="updateAgentIdStructRemote" localmode="modern" access="remote" output="no" returntype="any"><cfscript>
	if(application.zcore.app.siteHasApp("listing") and structkeyexists(form, 'user_id')){
		application.zcore.listingCom.updateAgentIdStruct(form.user_id,request.zos.globals.id);
	}
	</cfscript>done<cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>

<cffunction name="updateAgentIdStruct" localmode="modern" output="no" returntype="any">
<cfargument name="user_id" type="string" required="yes">
<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
<cfscript>
var x=0;
var i=0;
var arrK2=0;
var n=0;
var n2=0;
var arrI=0;
var arrP=0;
var ts4372=0;
var db=request.zos.queryObject;
var mAgStruct=0;
var mTemp=0;
var qm=0;
var userGroupCom= application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
var userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
db.sql="select *, user.site_id userSiteId from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user.user_id = #db.param(arguments.user_id)# and 
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
	user_group_id <>#db.param(userusergroupid)# and 
	user_active= #db.param(1)# and 
	member_public_profile=#db.param('1')# and 
	user_deleted = #db.param(0)#";
	qM=db.execute("qM"); 
x=1;
	
mTemp=application.sitestruct[request.zos.globals.id].app.appCache[this.app_id].sharedStruct.mlsStruct;
	for(n2 in mTemp){
		// delete old records
		if(structkeyexists(mTemp[n2].userAgentIdStruct, arguments.user_id)){
			mAgStruct=mTemp[n2].userAgentIdStruct[arguments.user_id];
			for(n in mAgStruct){
				StructDelete(mTemp[n2].agentIdStruct,n);
			}
		}
		mTemp[n2].userAgentIdStruct[arguments.user_id]=structnew();
		// recreate records for current member
		if(qM.recordcount NEQ 0){
			if(qM.member_mlsagentid[x] NEQ ''){
				arrP=listtoarray(qM.member_mlsagentid[x],',');
				for(i=1;i LTE arraylen(arrP);i++){
					arrI=listtoarray(arrP[i],'-');
					if(arraylen(arrI) EQ 2){
						arrK2=listtoarray(qm.columnlist);
						ts4372=structnew();
						/*
						for(n=1;n LTE arraylen(arrK2);n++){
							ts4372[arrK2[n]]=qM[arrK2[n]][x];
						}*/
						ts4372.userSiteId=qM.userSiteId[x];
						ts4372.member_photo=qM.member_photo[x];
						ts4372.member_first_name=qM.member_first_name[x];
						ts4372.member_last_name=qM.member_last_name[x];
						ts4372.member_phone=qM.member_phone[x];
						ts4372.member_public_profile=qM.member_public_profile[x];
						ts4372.user_id=qM.user_id[x];
						mTemp[arrI[1]].userAgentIdStruct[arguments.user_id][arrI[2]]=true;
						mTemp[arrI[1]].agentIdStruct[arrI[2]]=ts4372;
					}
				}
			}
		}
	}
</cfscript>
</cffunction>

<cffunction name="initListingLookup" localmode="modern" output="no" returntype="any">
<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var qlookup=0;
	var i=0;
	var db=request.zos.queryObject;
	var statusStr=structnew();
	var liststatusStr=structnew();
	var arrK2=structkeyarray(arguments.sharedStruct.mlsIdLookup);
	arguments.sharedStruct.listingLookupStruct=structnew();
	db.sql="SELECT listing_lookup_value,listing_lookup_id,listing_lookup_type,listing_lookup_oldid, listing_lookup_mls_provider 
	FROM #db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	WHERE listing_lookup_mls_provider IN (#db.trustedSQL("'#arraytolist(arrK2,"','")#'")#) and 
	listing_lookup_deleted = #db.param(0)#
	ORDER BY listing_lookup_type";
	qLookup=db.execute("qLookup"); 
	//application.zcore.functions.zdump(qLookup);
	arguments.sharedStruct.listingLookupStruct["status"]=structnew();
	arguments.sharedStruct.listingLookupStruct["status"].value=structnew();
	arguments.sharedStruct.listingLookupStruct["status"].id=structnew();
	//arguments.sharedStruct.listingLookupStruct["status"].unchangedid=structnew();
	statusStr["for sale"]=1;
	statusStr["foreclosure"]=2;
	statusStr["short sale"]=3;
	statusStr["bank owned"]=4;
	statusStr["new construction"]=5;
	//statusStr["for lease"]=6;
	statusStr["for rent"]=7;
	statusStr["pre construction"]=8;
	statusStr["model home"]=9;
	statusStr["pre-foreclosure"]=10;
	statusStr["auction"]=11;
	statusStr["remodeled"]=12;
	statusStr["hud"]=13;
	statusStr["relo company"]=14;
	  
	liststatusStr["active"]=1;   
	liststatusStr["incomplete"]=2;
	liststatusStr["withdrawn"]=3;
	liststatusStr["active continue to show"]=4;
	liststatusStr["temporarily withdrawn"]=5;
	liststatusStr["incomplete"]=6;
	liststatusStr["pending"]=7;
	liststatusStr["expired"]=8;
	liststatusStr["sold"]=9;
	liststatusStr["expired continue to show"]=10;
	liststatusStr["expired pending"]=11;
	liststatusStr["leased"]=12;
	liststatusStr["lease option"]=13;
	liststatusStr["rented"]=14;
	liststatusStr["incoming"]=15;
	liststatusStr["contingent"]=16;
	liststatusStr["deleted"]=17;
	liststatusStr["cancelled"]=18;
	arguments.sharedStruct.listingLookupStruct["liststatus"]=structnew();
	arguments.sharedStruct.listingLookupStruct["liststatus"].value=structnew();
	arguments.sharedStruct.listingLookupStruct["liststatus"].id=structnew();
	for(i in liststatusStr){
		arguments.sharedStruct.listingLookupStruct["liststatus"].value[liststatusStr[i]]=i;
		arguments.sharedStruct.listingLookupStruct["liststatus"].id[i]=liststatusStr[i];
		arguments.sharedStruct.listingLookupStruct["liststatus"].valueMLS[i]=structnew();
	}
	for(i in statusStr){
		arguments.sharedStruct.listingLookupStruct["status"].value[statusStr[i]]=i;
		arguments.sharedStruct.listingLookupStruct["status"].id[i]=statusStr[i];
		arguments.sharedStruct.listingLookupStruct["status"].valueMLS[i]=structnew();
		//arguments.sharedStruct.listingLookupStruct["status"].unchangedid[i]=statusStr[i];
	}
</cfscript>
<cfloop query="qLookup">
    <cfscript>
		if(structkeyexists(arguments.sharedStruct.mlsIdLookup,qLookup.listing_lookup_mls_provider)){
			if(structkeyexists(arguments.sharedStruct.listingLookupStruct,qLookup.listing_lookup_type) EQ false){
				arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type]=structnew();
				arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].id=structnew();
			   // arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].oldid=structnew();
				arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].value=structnew();
				arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].valueMLS=structnew();
		//arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].unchangedid=structnew();
			}
			arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].value[qLookup.listing_lookup_id]=qLookup.listing_lookup_value;
			arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].valueMLS[qLookup.listing_lookup_id]=arguments.sharedStruct.mlsIdLookup[qLookup.listing_lookup_mls_provider];
		   // arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].oldid[qLookup.listing_lookup_id]=qLookup.listing_lookup_oldid;
			arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].id[qLookup.listing_lookup_oldid]=qLookup.listing_lookup_id;
	//arguments.sharedStruct.listingLookupStruct[qLookup.listing_lookup_type].unchangedid[qLookup.listing_lookup_oldid_unchanged]=qLookup.listing_lookup_id;
		}
    </cfscript>
</cfloop> 

</cffunction>

<cffunction name="listingLookupIdByName" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="name" type="string" required="yes">
<cfscript>
	var i=0;
	var arrId=arraynew(1);
	for(i in request.zos.listing.listingLookupStruct[arguments.type].value){
		if(request.zos.listing.listingLookupStruct[arguments.type].value[i] EQ arguments.name){
			arrayappend(arrId,i);
		}
	}
	return arraytolist(arrId,",");
</cfscript>
</cffunction>

<cffunction name="listingLookupValueList" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="list" type="string" required="yes">
<cfargument name="delimiter" type="string" required="no" default=",">
<cfscript>
	var arrA=listtoarray(arguments.list, arguments.delimiter);
	var arrB=[];
	var tmp="";
	var i=0;
	for(i=1;i LTE arraylen(arrA);i++){
		tmp=request.zos.listing.listingLookupStruct[arguments.type].value[arrA[i]];
		if(tmp NEQ ""){
			arrayappend(arrB, tmp);	
		}
	}
	return arraytolist(arrB,", ");
</cfscript>
</cffunction>

<cffunction name="listingLookupValue" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="id" type="string" required="yes">
<cfargument name="defaultValue" type="string" required="no" default="">
<cfscript>
	
	if(structkeyexists(request.zos.listing.listingLookupStruct, arguments.type) and structkeyexists(request.zos.listing.listingLookupStruct[arguments.type].value,arguments.id)){
    return request.zos.listing.listingLookupStruct[arguments.type].value[arguments.id];
}else{
    return arguments.defaultValue;
}
</cfscript>
</cffunction>

<cffunction name="listingLookupValueMLS" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="id" type="string" required="yes">
<cfscript>
	try{
if(structkeyexists(request.zos.listing.listingLookupStruct[arguments.type].valueMLS,arguments.id)){
    return request.zos.listing.listingLookupStruct[arguments.type].valueMLS[arguments.id];
}else{
    return 0;
}
	}catch(Any excpt){
		writeoutput(arguments.type);
		application.zcore.functions.zabort();
	}
</cfscript>
</cffunction>


<cffunction name="includeSearchForm" localmode="modern" output="yes" returntype="any">
<cfargument name="ss" type="struct" required="no" default="#structnew()#">
<cfscript>
	var actionBackup="";
	var tempSearchURL="";
	var tempCom=0;
	var i=0;
	var searchFormHideCriteriaList="";
	var ts=structnew();
	
	if(request.cgi_script_name EQ "/z/listing/property/your-saved-searches/index"){
		return "";
	}
	ts.searchFormLabelOnInput=false;
	ts.searchDisableExpandingBox=false;
	ts.searchReturnVariableStruct=false;
	ts.disableJavascript=false;
	if(request.cgi_script_name EQ request.zos.listing.functions.getSearchFormLink() or request.cgi_script_name EQ "/z/listing/advanced-search/index" or (structkeyexists(arguments.ss,'javascript') and arguments.ss.javascript) or structkeyexists(request,'theSearchFormTemplate')){
		ts.disableJavascript=true;	
	}
	ts.advancedSearch=false;
	ts.output=true;
	structappend(arguments.ss,ts,false);
	
	if((request.zos.originalURL EQ "/z/listing/advanced-search/index" or request.zos.originalURL EQ "/z/listing/new-listing-email-signup/index") and arguments.ss.advancedSearch EQ false){
		writeoutput('<p><a href="#request.zos.listing.functions.getSearchFormLink()#">View search form</a></p>');
		return;
			
	}
	if(structkeyexists(form, 'searchid') and request.cgi_script_name NEQ "/content/index.cfm" and request.cgi_script_name NEQ "/index.cfm"){
		structdelete(arguments.ss,"searchFormLabelOnInput");
		structdelete(arguments.ss,"searchFormEnabledDropDownMenus");
	}
	if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
		arguments.ss.searchFormEnabledDropDownMenus=false;
	}else{
		arguments.ss.searchFormLabelOnInput=true;
		arguments.ss.searchid='';
		arguments.ss.searchFormEnabledDropDownMenus=true;
	}
	if(arguments.ss.output){
		arguments.ss.outputSearchForm=true;
		structdelete(arguments.ss,"output");
	}
	if(structkeyexists(arguments.ss,'searchFormHideCriteria')){
		arguments.ss.searchFormHideCriteriaList=structkeylist(arguments.ss.searchFormHideCriteria);
	}
	request.hideMLSResults=true;
	structappend(form,arguments.ss,true);
	actionBackup=application.zcore.functions.zso(form, 'action');
	form.action="form";
		//arguments.ss.disableJavascript=true;
</cfscript><cfif arguments.ss.disablejavascript EQ false and structkeyexists(request,'theSearchFormTemplate') EQ false><div id="zSearchFormJSContentDiv"></div><cfreturn></cfif><cfif request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()>#application.zcore.template.getFinalTagContent("sidebar")#<cfelseif arguments.ss.disableJavascript EQ false>
    <cfsavecontent variable="tempSearchURL">#request.zos.currentHostName#/z/listing/search-form-js/index?<cfif request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()>searchId=#application.zcore.functions.zso(form, 'searchid')#&</cfif>searchDisableExpandingBox=<cfif structkeyexists(arguments.ss,'searchDisableExpandingBox')>#arguments.ss.searchDisableExpandingBox#<cfelse>false</cfif>&searchDisableExpandingBox=<cfif structkeyexists(arguments.ss,'searchReturnVariableStruct')>#arguments.ss.searchReturnVariableStruct#<cfelse>false</cfif>&searchFormLabelOnInput=<cfif structkeyexists(arguments.ss,'searchFormLabelOnInput')>#arguments.ss.searchFormLabelOnInput#<cfelse>false</cfif>&searchFormEnabledDropDownMenus=<cfif structkeyexists(arguments.ss,'searchFormEnabledDropDownMenus') and structkeyexists(form, 'searchId') EQ false>#arguments.ss.searchFormEnabledDropDownMenus#<cfelse>false</cfif>&searchFormHideCriteriaList=#urlencodedformat(arguments.ss.searchFormHideCriteriaList)#</cfsavecontent>

<div id="zMLSSearchFormDivJSOutput"></div>
<script type="text/javascript" src="#htmleditformat(tempSearchURL)#"></script>
<cfelse>
<cfscript>
	tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search-form");
	tempCom.index();
	</cfscript></cfif><cfscript>if(actionBackup NEQ ""){form.action=actionBackup; }</cfscript>
</cffunction>

<!--- application.zcore.listingCom.listingLookupValueArray(type, idlist); --->
<cffunction name="listingLookupValueArray" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="idlist" type="string" required="yes">
<cfscript>
	var arrD=0;
	var arrL=0;
	var s2=0;
	var s3=0;
	var i=0;
	var tmp=0;
	arrD=listtoarray(arguments.idlist);
	arrL=[];
	s2=structnew();
	s3=structnew();
	for(i=1;i LTE arraylen(arrD);i++){
		s2[arrD[i]]=structnew();	
	}
	for(i in s2){
		tmp=application.zcore.listingCom.listingLookupValue(arguments.type,i);
		if(structkeyexists(s3,tmp) EQ false){
			s3[tmp]=i;
		}else{
			s3[tmp]&=","&i;	
		}
	}
	structdelete(s3,'');
	arrL=structkeyarray(s3);
	arraysort(arrL,"text","asc");
	return arrL;
</cfscript>
</cffunction>

<cffunction name="getCityIDByName" localmode="modern" output="no" returntype="string">
<cfargument name="cityName" type="string" required="yes">
<cfargument name="stateAbbr" type="string" required="yes">
<cfscript>
if(structkeyexists(application.zcore.listingStruct.cityStruct, arguments.cityName&"|"&arguments.stateAbbr)){
	return application.zcore.listingStruct.cityStruct[arguments.cityName&"|"&arguments.stateAbbr];
}else{
	return "";
}
</cfscript>
</cffunction>

<cffunction name="listingLookupNewId" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="oldid" type="string" required="yes">
<cfargument name="defaultValue" type="string" required="no" default="">
<cfscript>
	arguments.oldid=replace(arguments.oldid,'"','','all');
if(structkeyexists(request.zos.listing.listingLookupStruct[arguments.type].id,arguments.oldid)){
    return request.zos.listing.listingLookupStruct[arguments.type].id[arguments.oldid];
}else{
    return arguments.defaultValue;
}
</cfscript>
</cffunction>

<cffunction name="listingLookupOldId" localmode="modern" output="no" returntype="any">
<cfargument name="type" type="string" required="yes">
<cfargument name="oldid" type="string" required="yes">
<cfargument name="defaultValue" type="string" required="no" default="">
<cfscript>
if(structkeyexists(request.zos.listing.listingLookupStruct[arguments.type].oldid,arguments.id)){
    return request.zos.listing.listingLookupStruct[arguments.type].oldid[arguments.id];
}else{
    return arguments.defaultValue;
}
</cfscript>
</cffunction>

<cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
<cfargument name="listing_id" type="string" required="yes">
<cfargument name="num" type="numeric" required="no" default="#1#">
<cfargument name="sysid" type="any" required="no" default="0">
<cfargument name="sysid2" type="any" required="no" default="0">
<cfscript>
	var ts=structnew();//this.parseListingId(arguments.listing_id);
	var arrId=listtoarray(arguments.listing_id,"-");
	if(arraylen(arrId) NEQ 2){
		application.zcore.template.fail("Invalid listing_id, ""#arguments.listing_id#"".");	
	}else{
		ts.mls_id=arrId[1];
		ts.mls_pid=arrId[2];
	}
	return request.zos.listingMlsComObjects[ts.mls_id].getPhoto(ts.mls_pid,arguments.num, arguments.sysid, arguments.sysid2);
	</cfscript>
</cffunction>

<cffunction name="parseListingId" localmode="modern" output="no" returntype="any">
<cfargument name="listing_id" type="string" required="yes">
<cfscript>
	var ts=structnew();	
	var arrId=listtoarray(arguments.listing_id,"-");
	if(arraylen(arrId) NEQ 2){
		application.zcore.template.fail("Invalid listing_id, ""#arguments.listing_id#"".");	
	}else{
		ts.mls_id=arrId[1];
		ts.mls_pid=arrId[2];
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getMLSIDWhereSQL" localmode="modern" output="no" returntype="string">
<cfargument name="table" type="string" required="yes">
<cfscript>
if(arguments.table EQ "city_x_mls"){
	return "`"&arguments.table&"`.listing_mls_id IN "&application.zcore.app.getAppData("listing").sharedStruct.mls_id_list_simple;
}
return "`"&arguments.table&"`.listing_mls_id IN "&application.zcore.app.getAppData("listing").sharedStruct.mls_id_list;
//replace(application.zcore.app.getAppData("listing").sharedStruct.mls_id_list,"##TABLE##",arguments.table,"ALL");
</cfscript>
</cffunction>

<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	
	var db=request.zos.queryObject;
	var i=0;
	var qMapCheck=0;
	var tempSQL=0;

	if(structkeyexists(request.zsession, 'zListingHideMap') EQ false){
		request.zsession.zListingHideMap=true;
	}
	if(request.zos.functions.zso(form, 'search_map_coordinates_list') NEQ ""){
		request.zsession.zListingHideMap=false;
	}

	// proxy cache disabled on all real estate sites to avoid bugs.
	application.zcore.functions.zNoCache();

	if(request.zos.mlsImagesDomain NEQ ""){
		request.zos.retsPhotoPath=request.zos.mlsImagesDomain&'/zretsphotos/';
	}else{
		request.zos.retsPhotoPath=request.zos.currentHostName&'/zretsphotos/';
	}
	if(request.zos.allowRequestCFC){
		totalTime=0;
		while(true){
			if(not structkeyexists(application.zcore, 'listingStruct')){
				// wait a second to see if it exists then
				sleep(500);
				totalTime+=500;
			}else{
				break;
			}
			if(totalTime GT 5000){
				throw("It took too long for the application to reload application.zcore.listingStruct");
			}
		}
		request.zos["listing"]=application.zcore.listingStruct;
		request.zos["listingApp"]=application.sitestruct[request.zos.globals.id].app.appCache[this.app_id];
		request.zos["listingCom"]=this;
	}
	if(not structkeyexists(request.zos, 'listingTemp')){
		request.zos.listingTemp=structnew();
	}
	if(request.cgi_script_name EQ "/z/_a/listing/search-form" or request.cgi_script_name EQ "/z/_zcore-app/listing/search-form"){
		application.zcore.functions.z301redirect(request.zos.listing.functions.getSearchFormLink()&"?"&replacenocase(replacenocase(request.zos.cgi.query_string, request.zos.urlRoutingParameter&"=", "ztv=", "all"),"method=", "method99=", "all"));
	}

	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_detail_layout EQ 1){
		request.zos.skin.includeCSS("/z/javascript/jquery/colorbox/example3/colorbox.css");
		request.zos.skin.includeJS("/z/javascript/jquery/colorbox/colorbox/jquery.colorbox-min.js");
		request.zos.template.appendTag("meta", '<style type="text/css">##cboxNext, ##cboxPrevious{display:none !important;}</style>');
		request.zos.skin.addDeferredScript('
			$("a[rel=placeImageColorbox]").colorbox({photo:true, slideshow: true});
			zArrLoadFunctions.push({functionName:function(){
				$("a[rel=placeImageColorbox]").colorbox({photo:true, slideshow: true});
			}});
		');
	}
	
	
	if(isDefined('request.zsession.user.id') EQ false and (structkeyexists(cookie,"z_user_id") EQ false or cookie.z_user_id EQ "")){
		request.zos.zListingShowSoldData=false;
	}else{
		request.zos.zListingShowSoldData=true;
	}
	request.zos.listingMlsComObjects=structnew();     
	for(i in application.zcore.app.getAppData("listing").sharedStruct.mlsStruct){
		if(structkeyexists(application.zcore.listingStruct.mlsStruct, i)){
			request.zos.listingMlsComObjects[i]=application.zcore.functions.zcreateobject("component",application.zcore.listingStruct.mlsStruct[i].mlsComPath);
			request.zos.listingMlsComObjects[i].mls_id=i;//setMLS(i);
			if(structkeyexists(request.zos.listingMlsComObjects[i], 'retsversion') and structkeyexists(application.zcore.listingStruct.mlsStruct[i].sharedStruct,'metastruct') EQ false){
				request.zos.listingMlsComObjects[i].init(application.zcore.listingStruct.mlsStruct[i].sharedStruct);
			}
		}
	} 
		
	if(request.zos.zreset EQ 'site' or request.zos.zreset EQ 'all'){
		application.zcore.listingCom.onSiteStart(application.zcore.app.getAppData("listing"));
	}
	this.checkSearchFieldCache();
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_agent_top') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_agent_top EQ 1){
		if(structkeyexists(form,  'search_sort_agent_first') EQ false and structkeyexists(form, 'search_sort_agent_first') EQ false){
			form.search_sort_agent_first=1;
		}
	}
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_office_top') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_office_top EQ 1){
		if(structkeyexists(form,  'search_sort_office_first') EQ false and structkeyexists(form, 'search_sort_office_first') EQ false){
			form.search_sort_office_first=1;
		}
	}
	</cfscript>
<cfset tempSQL=this.getMLSIDWhereSQL("listing")>
	<cfif structkeyexists(application.sitestruct[request.zos.globals.id],'zListingMapCheck') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT listing_id FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing  
		WHERE #db.trustedSQL(tempSQL)# and 
		listing_latitude<> #db.param('')# and 
		listing_deleted = #db.param(0)# 
		LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qMapCheck=db.execute("qMapCheck");</cfscript>
    <cfif qMapCheck.recordcount EQ 0><cfset application.sitestruct[request.zos.globals.id].zListingMapCheck=false><cfelse><cfset application.sitestruct[request.zos.globals.id].zListingMapCheck=true></cfif>
</cfif>
	<cfif structkeyexists(request.zsession, 'inquiries_email') EQ false and structkeyexists(form, 'mls_saved_search_id') and structkeyexists(form, 'saved_search_email') and structkeyexists(form, 'saved_search_key')>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE mls_saved_search_id =#db.param(form.mls_saved_search_id)# and 
		saved_search_email =#db.param(form.saved_search_email)# and 
		saved_search_key =#db.param(form.saved_search_key)# and 
		saved_search_email<> #db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qSaved=db.execute("qSaved");</cfscript>
		<cfif qsaved.recordcount NEQ 0>
			<cfsavecontent variable="db.sql">
			SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
			WHERE inquiries_email <> #db.param('')# and 
			inquiries_email =#db.param(saved_search_email)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			inquiries_deleted = #db.param(0)#
			</cfsavecontent><cfscript>qinquiry=db.execute("qInquiry");</cfscript>
			<cfif qinquiry.recordcount NEQ 0>
				<cfset request.zsession.inquiries_email = qinquiry.inquiries_email>
				<cfset request.zsession.inquiries_first_name=qinquiry.inquiries_first_name>
				<cfset request.zsession.inquiries_phone1=qinquiry.inquiries_phone1>
			<cfelse>
				<cfset request.zsession.inquiries_email = qsaved.saved_search_email>
			</cfif>
		</cfif>
	</cfif>
</cffunction>


<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
<cfargument name="ss" type="struct" required="yes">
<cfscript>
	if(structkeyexists(request.zos,'listingApp') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_disable_search EQ 0){
		arrayappend(arguments.ss.js, "/zcache/listing-search-form.js");
	}
	c=arraylen(application.zcore.arrListingJsFiles);
	for(i=1;i LTE c;i++){
		arrayappend(arguments.ss.js, application.zcore.arrListingJsFiles[i]);
	} 

	arrayappend(arguments.ss.css, "/z/a/listing/stylesheets/global.css");
	if(structkeyexists(request.zos, 'fullscreenMobileEnabled')){
		arrayappend(arguments.ss.css, "/z/a/listing/stylesheets/global-large-search.css"); 
	}
	arrayappend(arguments.ss.css, "/z/a/listing/stylesheets/listing_template.css");
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
<cfscript>
var qUser=0;
var hitCount=0;
var qMapCheck=0;
var showModalForm=0;
var funcType=0;
var metaContent="";
application.zcore.functions.zrequirejquery();
if(structkeyexists(request.zsession, 'zlistingpageviewcount')){
	request.zsession.zlistingpageviewcount++;
}
if(structkeyexists(application.zcore.app.getAppData("listing"),'checkSearchFormJs') EQ false){
	application.zcore.app.getAppData("listing").checkSearchFormJs=true;
	if(fileexists(request.zos.globals.privatehomedir&"zcache/listing-search-form.js") EQ false){
		if(request.cgi_script_name NEQ "/z/listing/tasks/generateData/index"){
			application.zcore.functions.zdownloadlink(request.zos.currentHostName&"/z/listing/tasks/generateData/index");
		}
	}
}
if(request.zos.globals.enableMinCat EQ 0 or structkeyexists(request.zos.tempObj,'disableMinCat')){
	
	allowJs=true;
	if(application.zcore.skin.checkCompiledJS()){
		allowJs=false;
	}
	if(allowJs){
		c=arraylen(application.zcore.arrListingJsFiles);
		for(i=1;i LTE c;i++){
			application.zcore.skin.includeJS(application.zcore.arrListingJsFiles[i]);
		} 
	}
	if(request.cgi_script_name NEQ "/z/listing/search-js/index"){
		if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_disable_search EQ 0){
			application.zcore.skin.includeJS("/zcache/listing-search-form.js");
		}
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_detail_layout',false,0) EQ 1){
			application.zcore.functions.zRequireJQuery();
			application.zcore.skin.includeCSS("/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.css");
			application.zcore.skin.includeJS("/z/javascript/jquery/jquery.easing.1.3.js");
			application.zcore.skin.includeJS("/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.js");
			application.zcore.skin.includeJS("/z/javascript/jquery/galleryview-1.1/jquery.timers-1.2.js");
		}
	}
}

if(request.zos.globals.enableMinCat EQ 0 or structkeyexists(request.zos.tempObj,'disableMinCat')){
	metaContent&=application.zcore.skin.includeCSS("/z/a/listing/stylesheets/global.css");
	if(structkeyexists(request.zos, 'fullscreenMobileEnabled')){
		metaContent&=application.zcore.skin.includeCSS("/z/a/listing/stylesheets/global-large-search.css");
	}
	if(application.zcore.app.getAppData("content").optionStruct.content_config_override_stylesheet EQ 0){
		metaContent&=application.zcore.skin.includeCSS("/z/a/listing/stylesheets/listing_template.css");
	}
}
application.zcore.template.prependTag("meta", metaContent); 
if(right(form[request.zos.urlRoutingParameter],4) NEQ ".xml" and right(request.cgi_script_name,4) NEQ ".xml" and request.zos.inMemberArea EQ false and structkeyexists(form, 'zFPE') EQ false){
	if (request.zos.originalURL NEQ "/z/listing/sl/view" and request.cgi_script_name NEQ "/z/listing/sl/index" and request.cgi_script_name NEQ "/z/listing/inquiry/index" and structkeyexists(request,'znotemplate') EQ false) {
		if(isDefined('request.zsession.tempVars.zListingSearchId')){
			writeoutput('<div id="zListingSearchBarEnabledDiv" style="display:none;"></div>');
		}
		//application.zcore.template.prependTag("topcontent",'<div id="sl894nsdh783" style="width:100%; float:left; clear:both;"></div>');
	}
	if (not request.zos.trackingspider and (not request.zos.istestserver or structkeyexists(form, 'debugajaxgeocoder')) and request.zos.originalURL NEQ "/z/listing/ajax-geocoder/index" and (randrange(1, request.zos.geocodeFrequency) EQ 1)){
		savecontent variable="geocodeOutput"{
			geocodeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.ajax-geocoder");
			geocodeCom.index();
		}
		application.zcore.template.appendTag("scripts", geocodeOutput);
	}
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_disable_image_enlarge EQ 2){
		application.zcore.skin.addDeferredScript("zIImageClickLoad=true;");
		application.zcore.template.appendTag("meta",'<script type="text/javascript">zIImageClickLoad=true;</script>', true);
	}
	application.zcore.template.prependTag('content','<div id="zlistingnextimagebutton"><span>NEXT</span></div><div id="zlistingprevimagebutton"><span>PREV</span></div>');
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_enable_instant_search') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_enable_instant_search EQ 1){
		application.zcore.template.appendTag("content",'<input type="hidden" name="zListingEnableInstantSearch" id="zListingEnableInstantSearch" value="1" />');	
	}
	//if(request.zos.cgi.http_referer NEQ "" and 
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_enabled NEQ 0 and left(application.zcore.template.getTemplate(), 3) NEQ "/z/" and request.cgi_script_name NEQ "/z/listing/inquiry-pop/index" and request.cgi_script_name NEQ "/z/user/privacy/index"){
		if(structkeyexists(request.zsession, 'zlistingpageviewcount') EQ false){
			request.zsession.zlistingpageviewcount=1;
		}
		showModalForm=false;
		hitCount=5;
		if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_count NEQ 0){
			hitCount=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_count;
		}
		
		if(application.zcore.functions.zso(form, 'modelpopforced', true, 0) EQ 1){
			showModalForm=false;
		}else if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_enabled EQ 1){
			if(request.zsession.zlistingpageviewcount GTE hitCount){
				if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_forced EQ 1){
					if(structkeyexists(cookie, 'zPOPInquiryCompleted') EQ false and structkeyexists(request.zsession, 'zPopinquiryPopSent') EQ false){
						showModalForm=true;
					}
				}else{
					if(structkeyexists(request.zsession, 'zPopinquiryPopCompleted') EQ false){
						showModalForm=true;
					}
				}
			}
		}else if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_enabled EQ 2){
			// show on Xth listing detail page
			if(structkeyexists(request.zsession, 'zlistingdetailhitcount2') and request.zsession.zlistingdetailhitcount2 GTE hitCount){
				if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_forced EQ 1){
					if(structkeyexists(cookie, 'zPOPInquiryCompleted') EQ false and structkeyexists(request.zsession, 'zPopinquiryPopSent') EQ false){
						showModalForm=true;
					}
				}else{
					if(not structkeyexists(request.zsession, 'zPopinquiryPopCompleted')){
						showModalForm=true;
					}
				}
			}
			
		}else if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_enabled EQ 3){
			// this appears whenever search form is displayed
			searchFormURL=request.zos.listing.functions.getSearchFormLink();
			if(request.zos.originalURL EQ searchFormURL){
				// check if cookie was set
				if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_forced EQ 1){
					if(structkeyexists(cookie, 'zPOPInquiryCompleted') EQ false and structkeyexists(request.zsession, 'zPopinquiryPopSent') EQ false){
						showModalForm=true;
					}
				}else{
					// if i want it to be permanently not shown again, i could add cookie to inquiry-pop.cfc at the top and check for it to not exist.
					if(structkeyexists(request.zsession, 'zPopinquiryPopCompleted') EQ false){
						showModalForm=true;
					}
				}
			}
		}
		//showModalForm=false;
		if(showModalForm and structkeyexists(request.zos.userSession.groupAccess, "member") EQ false){
			funcType=" listingShowModalWin();";
			if(structkeyexists(form, 'zajaxdownloadcontent') EQ false){
				funcType=" zArrDeferredFunctions.push(function(){listingShowModalWin();}); ";
			}
			customformurl=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_customurl;
			if(customformurl EQ ""){
				customformurl="/z/listing/inquiry-pop/index";
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_forced EQ 1){
				writeoutput('<script type="text/javascript">/* <![CDATA[ */function listingShowModalWin(){ if(!zModalCancelFirst){var modalContent1=''<iframe src="#customformurl#" width="100%" height="98%" style="margin:0px; border:none; overflow:auto;" seamless="seamless"><\/iframe>'';var winId=false;zShowModal(modalContent1,{''width'':520,''height'':428,''disableResize'':true, ''disableClose'':true});}} '&funcType&' /* ]]> */</script>');
			}else{
				writeoutput('<script type="text/javascript">/* <![CDATA[ */function listingShowModalWin(){ if(!zModalCancelFirst){var modalContent1=''<iframe src="#customformurl#" width="100%" height="98%" style="margin:0px; border:none; overflow:auto;" seamless="seamless"><\/iframe>'';var winId=false;zShowModal(modalContent1,{''width'':520,''height'':428,''disableResize'':true});}} '&funcType&' /* ]]> */</script>');
			}
		}
	}
}

</cfscript>
</cffunction>


<!--- application.zcore.listingCom.updateDistanceCache(); --->
<cffunction name="updateDistanceCache" localmode="modern" output="no" hint="Pre-index all city distances using zip code searches. This process takes over 2 minutes to complete." returntype="any">
	<cfscript>		
	// Keep track of the current offset in LIMIT statement to prevent duplicate caching.
	var distance = 100; // max distance in miles 
	var latDistance = distance/80;
	var longDistance = distance/60;
	var qzip=0;
	var qclosezips=0;
	var i=0;
	
	var qcity=0;
	var qinsert=0;
	var cs=0;
	var ts=structnew();
	var zipStruct=0;
	var city_parent_id="";
	var db=request.zos.queryObject;
	
	db.sql="truncate #db.table("city_distance_safe_update", request.zos.zcoreDatasource)# ";
	db.execute("q"); 
	db.sql="UPDATE 
	#db.table("city_memory", request.zos.zcoreDatasource)# city, 
	 #db.table("zipcode", request.zos.zcoreDatasource)#  
	 SET city_latitude=zipcode_latitude, 
	 city_longitude=zipcode_longitude,
	 city_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE `city`.city_name = zipcode.city_name AND 
	`city`.state_abbr = zipcode.state_abbr AND 
	`city`.country_code = zipcode.country_code and 
	city.city_deleted = #db.param(0)# and 
	zipcode.zipcode_deleted = #db.param(0)# ";
	db.execute("q"); 
	db.sql="UPDATE #db.table("city", request.zos.zcoreDatasource)# city, 
	#db.table("zipcode", request.zos.zcoreDatasource)#  
	SET city_latitude=zipcode_latitude, 
	city_longitude=zipcode_longitude,
	city_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE `city`.city_name = zipcode.city_name AND 
	`city`.state_abbr = zipcode.state_abbr AND 
	`city`.country_code = zipcode.country_code and 
	city.city_deleted = #db.param(0)# and 
	zipcode.zipcode_deleted = #db.param(0)# ";
    db.execute("q"); 
	db.sql="INSERT INTO 
	#db.table("city_distance_safe_update", request.zos.zcoreDatasource)# 
	 (city_parent_id, city_id, city_distance, city_distance_updated_datetime, city_distance_deleted) 
	SELECT city.city_id, city2.city_id,  
	#db.trustedSQL("ROUND((ACOS((SIN(city.city_latitude/57.2958) * SIN(city2.city_latitude/57.2958)) + (COS(city.city_latitude/57.2958) * COS(city2.city_latitude/57.2958) * COS(city2.city_longitude/57.2958 - city.city_longitude/57.2958)))) * 3963, 0) AS distance")#, 
	city.city_updated_datetime, city.city_deleted
	FROM #db.table("city_memory", request.zos.zcoreDatasource)# city
	LEFT JOIN #db.table("city_memory", request.zos.zcoreDatasource)# city2 ON  #db.trustedSQL("ROUND((ACOS((SIN(city.city_latitude/57.2958) * SIN(city2.city_latitude/57.2958)) + (COS(city.city_latitude/57.2958) * COS(city2.city_latitude/57.2958) * COS(city2.city_longitude/57.2958 - city.city_longitude/57.2958)))) * 3963, 0) <= 100
	AND city2.city_latitude<>0 AND city2.city_longitude<>0
	WHERE city.city_latitude<>0 AND city.city_longitude<>0 and 
	city.city_deleted = 0")# ";
	db.execute("q"); 
	
	db.sql="RENAME TABLE 
	#db.table("city_distance_safe_update", request.zos.zcoreDatasource)#  TO 
	#db.table("city_distance_safe_update_temp", request.zos.zcoreDatasource)# , 
	#db.table("city_distance", request.zos.zcoreDatasource)#  TO 
	#db.table("city_distance_safe_update", request.zos.zcoreDatasource)# , 
	#db.table("city_distance_safe_update_temp", request.zos.zcoreDatasource)#  TO 
	#db.table("city_distance", request.zos.zcoreDatasource)# ";
	db.execute("q"); 
	ts=structnew();
	ts.table="city_distance";
	ts.force=true;
	form.zrebuildramtable=1;
	this.zCreateMemoryTable(ts);   
	</cfscript>
</cffunction>



<cffunction name="checkCache" localmode="modern" output="false" returntype="any">
    <cfargument name="mls_id" type="string" required="no" default="">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].listing, 'appStartComplete') EQ false){
		this.onSiteStart();
	}
	</cfscript>
</cffunction>



<!--- 
380mb without indexes
391mb with just primary key


ts=StructNew();
ts.table="listing_status";
// optional
ts.allowFulltext=false;
// run function
zCreateMemoryTable(ts);
--->
<cffunction name="zCreateMemoryTable" localmode="modern" output="yes" returntype="any">    
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qmls="";
	var db=request.zos.queryObject;
	var qCheck="";
	
	var keyString="";
	var i=0;
	var arrF=[];
	var arrF2=[];
	var arrF22=[];
	var arrAlter=[];
	var endPos=0;
	var notNumberField=0;
	var numberTypeList=0;
	var typeName=0;
	var theNull=0;
	var fieldString=0;
	var qFieldLengths=0;
	var qC2=0;
	var qFields=0;
	var str=0;
	var curName=0;
	var collation2=0;
	var arrKeyOrder=arraynew(1);
	var theErr="";
	var ks={};
	var arrK=arraynew(1);
	var ts=structnew();
	var db2=0;
	var db=0;
	arrCreate=[];
	setting requesttimeout="5000";
	local.c=application.zcore.db.getConfig();
	local.c.autoReset=false;
	local.c.datasource=request.zos.zcoreDatasource;
	db=application.zcore.db.newQuery(local.c);
	memoryTable=arguments.ss.table&"_memory";
	ts.force=false;
	ts.allowFulltext=false;
	structappend(arguments.ss,ts,false);
	</cfscript>

	<cflock name="zCreateMemoryTable" type="exclusive" timeout="1000">
		<cfsavecontent variable="db.sql">
		SHOW TABLES like #db.param('###(memoryTable)#')#
		</cfsavecontent><cfscript>qC2=db.execute("qC2");
		</cfscript>
		<cfif structkeyexists(form, 'zrebuildramtable') or (qC2.recordcount EQ 0)>
			<cfif arguments.ss.force EQ false>
			    <cfsavecontent variable="db.sql">
			    SHOW TABLES like #db.param('#memoryTable#')#
			    </cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
			    <cfif qmls.recordcount NEQ 0>
					<cfsavecontent variable="db.sql">
					SELECT count(*) c FROM #db.table(memoryTable, request.zos.zcoreDatasource)#
					</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
					<cfif qMLS.c NEQ 0>
					    <cfreturn 2>
					</cfif>
			    </cfif>
			</cfif>
			<!--- check for invalid column types --->
			<cfsavecontent variable="db.sql">
			show full fields from #db.table(arguments.ss.table, request.zos.zcoreDatasource)#
			</cfsavecontent><cfscript>qFields=db.execute("qFields");</cfscript>
			<cfloop query="qFields">
				<!--- check the fields are a valid type --->
				<cfif findnocase(',#qFields.field#,', ',text,blob,tinyblob,mediumblob,longblob,tinytext,longtext,mediumtext,') NEQ 0>
					<cfset arrF=arraynew(1)>
					<cfsavecontent variable="theErr">
					Validation Error: You can't create a table using ENGINE=MEMORY that contains a field using a text or blob data type.<br /><br />
					<strong>Text/Blog Fields in #arguments.ss.table#</strong><br />
					<cfloop query="qMLS">#qFields.field#<br /></cfloop>                
					</cfsavecontent>
					<cfthrow type="exception" message="#theErr#">    
				</cfif>
				<cfscript>
				theNull=' NULL ';
				if(qFields.null EQ 'NO'){
					theNull=' NOT NULL ';
				}
				collation2="";
				if(qFields.collation NEQ ''){
					collation2='COLLATE '&qFields.collation;
				}
				notNumberField=true;
				endPos=findnocase("(",qFields.type);
				if(endPos EQ 0){
					typeName=qFields.type;
				}else{
					typeName=mid(qFields.type,1,endPos-1);
				}
				numberTypeList=",smallint,mediumint,tinyint,int,integer,bigint,serial,float,double,double precision,decimal,dec,";
				if(findnocase(',#typeName#,',numberTypeList) NEQ 0){
					notNumberField=false;
				}
				if(notNumberField){
					arrayAppend(arrF2, qFields.field);
			    	//arrayappend(arrF22,'max(length(`'&qFields.field&'`)) as `'&qFields.field&'`');
			    	defaultValue="";
			    	if(qFields.type EQ "date"){
			    		defaultValue="DEFAULT '0000-00-00'";
			    	}else if(qFields.type EQ "datetime"){
			    		defaultValue="DEFAULT '0000-00-00 00:00:00'";
			    	}else if(qFields.type EQ "time"){
			    		defaultValue="DEFAULT '00:00:00'";
			    	}else if(qFields.default NEQ ""){
			    		if(left(qFields.default, 8) NEQ "DEFAULT "){
				    		defaultValue="DEFAULT '"&qFields.default&"'";
				    	}else{
				    		defaultValue=qFields.default;
				    	}
			    	}
					arrayappend(arrCreate,' `#qFields.field#` #qFields.type# #defaultValue# #theNull# #collation2# ');
					//arrayappend(arrAlter,' change `#qFields.field#` #qFields.type#  #defaultValue# #theNull# #collation2# '); // `#qFields.field#` varchar (1z_count)
				}else{
					defaultValue="";
					if(qFields.default NEQ ""){
						if(left(qFields.default, 8) NEQ "DEFAULT "){
				    		defaultValue="DEFAULT '"&qFields.default&"'";
				    	}else{
							defaultValue=qFields.default;
						}
					}
					arrayappend(arrCreate,'`#qFields.field#` #qFields.type# #defaultValue# #theNull# #qFields.extra# ');

				}
				</cfscript>
			</cfloop> 
			<!--- all columns are ok - build the sql for the indexes --->
			<cfsavecontent variable="db.sql">
			show keys from #db.table(arguments.ss.table, request.zos.zcoreDatasource)# 
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");
			curName="";
			ks=structnew();
			</cfscript>
			<cfloop query="qMLS">
				<cfscript>
				if(curName NEQ qMLS.key_name){
					curName=qMLS.key_name;
					arrayappend(arrKeyOrder, curName);
					ks[curName]=structnew();
					ks[curName].arrField=arraynew(1);
					if(qMLS.key_name EQ 'primary'){
						ks[curName].type=" primary key ";
					}else if(qMLS.index_type EQ 'btree' and qMLS.non_unique EQ 0){
						ks[curName].type=" unique `#qMLS.key_name#` ";
					}else if(qMLS.index_type EQ 'btree' and qMLS.non_unique EQ 1){
						ks[curName].type=" key `#qMLS.key_name#` ";
					}else{
						ks[curName].type=" key `#qMLS.key_name#` ";
						if(arguments.ss.allowFulltext EQ false){
							throw('FULLTEXT indexes can not be used with MEMORY tables in MySQL 5.0.  Please set "ts.allowFullText" to "true" when calling "zCreateMemoryTable" to ignore this error and use "KEY" instead of "FULLTEXT KEY". Full text searches will not work on a memory table.');
						}
					}
				}
				arrayappend(ks[curName].arrField, "`#qMLS.column_name#`");
				</cfscript>
			</cfloop>
			<cfscript>
			for(i=1;i LTE arraylen(arrKeyOrder);i=i+1){
				arrayappend(arrK, ks[arrKeyOrder[i]].type&'('&arraytolist(ks[arrKeyOrder[i]].arrField)&')');
			}
			keyString=arraytolist(arrK);
			</cfscript>
			<!--- Make the new table in ram and then rename so the operation is locked and instantaneous --->
			<cfsavecontent variable="db.sql">
			drop table if exists #db.table("##"&memoryTable, request.zos.zcoreDatasource)# 
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript><!---  --->

			<cfsavecontent variable="db.sql">
			create table #db.table("##"&memoryTable, request.zos.zcoreDatasource)#  
			(
				#db.trustedSQL(arrayToList(arrCreate, ", "))#
				<cfif trim(keyString) NEQ ''>, #db.trustedSQL(keyString)# </cfif>
			)
			 ENGINE=MEMORY 
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>

			<!--- resize the fields to minimum size possible except for number data types--->
			<!--- 
			<cfscript>
			fieldString='select '&arrayToList(arrF22,',')&' from '&db.table(arguments.ss.table, request.zos.zcoreDatasource)&'';
			</cfscript>
			<cfsavecontent variable="db.sql">
			#db.trustedSQL(fieldString)#
			</cfsavecontent><cfscript>qFieldLengths=db.execute("qFieldLengths");
			for(i=1;i<=arraylen(arrF2);i++){
				if(arrF2[i] EQ "listing_id"){
					arrAlter[i]=replacenocase(arrAlter[i], '1z_count',15);
				}else if(arrAlter[i] NEQ ''){
					arrAlter[i]=replacenocase(arrAlter[i], '1z_count',max(1,qFieldLengths[arrF2[i]][1]));
				}else{
					arraydeleteat(arrAlter,i);
					i--;
				}
			}
			str=arraytolist(arrAlter,',');
			</cfscript>
			<cfsavecontent variable="db.sql">
			alter table #db.table("##"&memoryTable, request.zos.zcoreDatasource)#  
			#db.trustedSQL(str)#
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>  
			 --->
			<cfsavecontent variable="db.sql">
			INSERT INTO #db.table("##"&memoryTable, request.zos.zcoreDatasource)#  
			SELECT * FROM #db.table(arguments.ss.table, request.zos.zcoreDatasource)# 
			<cfif request.zos.istestserver and arguments.ss.table EQ "listing"> 
				<!--- TODO: this is unsafe for replication --->
				WHERE CEILING(RAND()*#db.param(10)#) >= #db.param(7)# 
			</cfif>
			<cfif arguments.ss.table EQ "listing">
				ORDER BY listing_id ASC
			<cfelseif arguments.ss.table EQ "city">
				ORDER BY city_id ASC
			<cfelseif arguments.ss.table EQ "city_distance">
				ORDER BY city_distance_id ASC
			</cfif>
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");
			local.c=application.zcore.db.getConfig();
			local.c.datasource=request.zos.zcoreDatasource;
			structdelete(local.c, 'checkSiteId');
			local.c.autoReset=false;
			local.c.verifyQueriesEnabled=false;
			db2=application.zcore.db.newQuery(c);
			</cfscript>  
			<cfsavecontent variable="db2.sql">
			show table status from `#request.zos.zcoreDatasource#` 
			WHERE name = '#memoryTable#'
			</cfsavecontent><cfscript>
			qMLS=db2.execute("qMLS");</cfscript>


			<cfif qMLS.recordcount NEQ 0>
				<cfsavecontent variable="db.sql">
				rename table 
				#db.table("##"&memoryTable, request.zos.zcoreDatasource)#  to
				#db.table("####"&memoryTable, request.zos.zcoreDatasource)# ,
				#db.table(memoryTable, request.zos.zcoreDatasource)#  to 
				#db.table("##"&memoryTable, request.zos.zcoreDatasource)# , 
				#db.table("####"&memoryTable, request.zos.zcoreDatasource)#  to 
				#db.table(memoryTable, request.zos.zcoreDatasource)# 
				</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
			<cfelse>
				<cfsavecontent variable="db.sql">
				rename table 
				#db.table("##"&memoryTable, request.zos.zcoreDatasource)#  to #db.table(memoryTable, request.zos.zcoreDatasource)# 
				</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
			</cfif>
			<cfsavecontent variable="db.sql">
			drop table if exists 
			#db.table("##"&memoryTable, request.zos.zcoreDatasource)# , 
			#db.table("####"&memoryTable, request.zos.zcoreDatasource)# 
			</cfsavecontent><cfscript>qMLS=db.execute("qMLS");</cfscript>
		</cfif>
	</cflock>
	<cfreturn 1>
</cffunction>



<cffunction name="getURLIdForMLS" localmode="modern" output="no" returntype="any">
<cfargument name="mls_id" type="string" required="yes">
<cfscript>
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct, arguments.mls_id)){
		return application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.mls_id].app_x_mls_url_id;
	}else{
		return false;	
	}
	</cfscript>
</cffunction>

<cffunction name="getMLSStruct" localmode="modern" output="no" returntype="any">
<cfargument name="mls_id" type="string" required="yes">
<cfscript>
	if(structkeyexists(request.zos.listing.mlsStruct, arguments.mls_id)){
		return request.zos.listing.mlsStruct[arguments.mls_id];
	}else{
		return false;	
	}
	</cfscript>
</cffunction>


<cffunction name="updateUserSavedListings" localmode="modern" output="no" returntype="any">
	<cfscript>
	db=request.zos.queryObject;
	if(isDefined('request.zsession.user.id')){
		if((isDefined('request.zsession.listing.savedListingStruct') EQ false and structcount(request.zsession.listing.savedListingStruct) EQ 0)){
			db.sql="DELETE FROM #db.table("saved_listing", request.zos.zcoreDatasource)#  
			WHERE site_id=#db.param(request.zos.globals.id)# and 
			user_id=#db.param(request.zsession.user.id)#  and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
			db.execute("q"); 
		}else{
			db.sql="SELECT saved_listing_id FROM #db.table("saved_listing", request.zos.zcoreDatasource)#  
			 WHERE 
			  site_id=#db.param(request.zos.globals.id)# and 
			  user_id=#db.param(request.zsession.user.id)# and 
			  saved_listing_deleted=#db.param(0)# and 
			  user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
			qId=db.execute("qId");
			if(qId.recordcount NEQ 0){
			 	db.sql="UPDATE #db.table("saved_listing", request.zos.zcoreDatasource)#  
				SET 
				saved_listing_count=#db.param(structcount(request.zsession.listing.savedListingStruct))#,
				saved_listing_idlist=#db.param(structkeylist(request.zsession.listing.savedListingStruct))#,  
				saved_listing_datetime=#db.param(request.zos.mysqlnow)#,  
				saved_listing_updated_datetime=#db.param(request.zos.mysqlnow)#
				WHERE 
				site_id=#db.param(request.zos.globals.id)# and 
				saved_listing_id=#db.param(qId.saved_listing_id)# and  
				saved_listing_deleted=#db.param(0)# ";
				db.execute("qUpdate");
			}else{
				db.sql="INSERT INTO #db.table("saved_listing", request.zos.zcoreDatasource)#  
				SET saved_listing_count=#db.param(structcount(request.zsession.listing.savedListingStruct))#,
				saved_listing_idlist=#db.param(structkeylist(request.zsession.listing.savedListingStruct))#,  
				saved_listing_datetime=#db.param(request.zos.mysqlnow)#,  
				site_id=#db.param(request.zos.globals.id)#, 
				user_id=#db.param(request.zsession.user.id)#, 
				saved_listing_deleted=#db.param(0)#,
				saved_listing_updated_datetime=#db.param(request.zos.mysqlnow)#,
				user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
				db.execute("qInsert");
			}
		}
	}
	</cfscript>
</cffunction>



<!--- 
arrCity=['Ponce Inlet', 'Ormond Beach', 'Daytona Beach', 'Port Orange', 'Holly Hill', 'Wilbur by the Sea', 'Ormond by the sea', 'New Smyrna Beach', 'Daytona Beach Shores'];
application.zcore.app.getAppCFC('listing').getCitiesByName(arrCity, 'FL');
 --->
<cffunction name="getCitiesByName" localmode="modern" output="no" returntype="query">
	<cfargument name="cities" type="array" required="yes">
	<cfargument name="stateAbbr" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrCity=[];
	for(i in arguments.cities){
		arrayAppend(arrCity, application.zcore.functions.zEscape(i));
	}
	db.sql="SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# WHERE 
	state_abbr=#db.param(arguments.stateAbbr)# AND 
	city_name IN (#db.trustedSQL("'"&arrayToList(arrCity, "','")&"'")#) AND 
	city_deleted=#db.param(0)#";
	qCity=db.execute("qCity");
	return qCity;
	</cfscript>
</cffunction>


<cffunction name="isCurrentPageInListing" localmode="modern" returntype="boolean" access="remote">
	<cfscript>
	if(structkeyexists(request.zos, 'currentURLISAListingPage')){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>