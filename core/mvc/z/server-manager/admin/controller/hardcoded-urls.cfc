<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id', form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	if(form.sid EQ '1'){
		application.zcore.functions.zRedirect("/z/server-manager/admin/hardcoded-urls/index");
	}
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var qSite=0;
	var sid=0;
	var qU=0;
	var arrURL2=0;
	var path=0;
	var arrKey=0;
	var ts2=0;
	var urlStruct=0;
	var ts=0;
	var i=0;
	var urlIndex=0;
	var str=0;
	var qSites=0;
	var selectStruct=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	urlStruct=structnew();
	urlIndex=0;
	db.sql="select * from #request.zos.queryObject.table("link_hardcoded", request.zos.zcoreDatasource)#  
	WHERE link_hardcoded_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)#";
	qCheck=db.execute("qCheck"); 
	uniqueStruct={};
	for(row in qCheck){
		uniqueStruct[row.link_hardcoded_url]=row.link_hardcoded_id;
	}
	for(i=1;i LTE form.linkcount;i++){
		ts=StructNew();
		ts.url=application.zcore.functions.zso(form, 'url'&i);
		ts.title=application.zcore.functions.zso(form, 'title'&i);
		form.link_hardcoded_url=ts.url;
		if(form.link_hardcoded_url EQ ""){
			continue;
		}
		form.link_hardcoded_updated_datetime = request.zos.mysqlnow;
		form.link_hardcoded_title=ts.title;
		form.site_id=form.sid;
		ts2=structnew();
		ts2.table="link_hardcoded";
		ts2.struct=form;
		ts2.datasource=request.zos.zcoreDatasource;
		if(structkeyexists(uniqueStruct, ts.url)){
			ts2.struct.link_hardcoded_id=uniqueStruct[ts.url];
			application.zcore.functions.zUpdate(ts2);
		}else{
			application.zcore.functions.zInsert(ts2);
		}
		urlIndex++;
		urlStruct[urlIndex]=ts;
	}
	db.sql="update #request.zos.queryObject.table("link_hardcoded", request.zos.zcoreDatasource)#  
	set link_hardcoded_deleted = #db.param(1)#,
	link_hardcoded_updated_datetime=#db.param(request.zos.mysqlnow)#
	WHERE site_id = #db.param(form.sid)# and 
	link_hardcoded_updated_datetime < #db.param(request.zos.mysqlnow)#";
	db.execute("q"); 
	arrKey=structsort(urlStruct, "textnocase", "asc", "title");
	arrURL2=arraynew(1);
	for(i=1;i LTE arraylen(arrKey);i++){
		arrayappend(arrURL2, urlStruct[arrKey[i]]);	
	}
	
	path=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar("shortDomain", form.sid))&"_cache/scripts/hardcoded-urls.json";
	application.zcore.functions.zwritefile(path, serializeJson(arrURL2));
	
	application.zcore.status.setStatus(request.zsid,"Hardcoded urls saved successfully.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/hardcoded-urls/edit?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var qU=0;
	var qSite=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.10");
	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/hardcoded-urls/index?zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #request.zos.queryObject.table("link_hardcoded", request.zos.zcoreDatasource)# link_hardcoded 
	WHERE site_id = #db.param(form.sid)# and 
	link_hardcoded_deleted=#db.param(0)# 
	ORDER BY link_hardcoded_id ASC";
	qU=db.execute("qU");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript> 
	<h2>Edit Hardcoded URLs for #qsite.site_domain#</h2>
	<p>This feature allows you to add URLs to the site map that are otherwise not able to be included in the site map automatically.</p>
	<p>Type a title and url, and click add for each link.  Then click Save to save all the links.</p>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/hardcoded-urls/update?sid=#form.sid#" method="post" style="margin:0px;">
		<table style="width:100%; border-spacing:0px;" class="table-white">
			<tr>
				<td colspan="2" style="padding:10px;"> 
					<a href="/z/server-manager/admin/hardcoded-urls/verifyLinks?sid=#form.sid#">Click here to verify all links</a></td>
			</tr>
		</table>
		<div id="categoryBlock"></div>
		<input type="hidden" name="linkcount" value="#qu.recordcount#" />
		<script>
		/* <! [[CDATA] */	
		var arrBlock=new Array();
		var arrBlockUrl=new Array();
		<cfloop query="qU">arrBlockUrl.push("#jsstringformat(replace(qU.link_hardcoded_url,application.zcore.functions.zvar('domain', form.sid),""))#");arrBlock.push("#jsstringformat(qU.link_hardcoded_title)#");</cfloop>
		function removeCat(Url){
			var ab=new Array();
			var ab2=new Array();
			for(i=0;i<arrBlock.length;i++){
				if(Url!=i){ 
					ab.push(arrBlock[i]); 
					ab2.push(arrBlockUrl[i]);
				}
			}
			arrBlock=ab;
			arrBlockUrl=ab2;
			setCatBlock(false);
		}
		function updateTitle(n,o){
			arrBlock[n]=o.value;
		}
		function updateUrl(n,o){
			for(var i=0;i<arrBlockUrl.length;i++){
				if(i != n && arrBlockUrl[i] == o.value){
					alert('This URL is already added above.');
					o.value=arrBlockUrl[n];
					return;
				}
			}
			arrBlockUrl[n]=o.value;
		}
		function setCatBlock(checkField){
			if(checkField){
				var cUrl=document.editForm.addUrl.value;
				var cname=document.editForm.addTitle.value;
				if(cUrl.length ==0 || cname.length==0){
					alert('You must type a valid url and title.');
					return;
				}
				for(var i=0;i<arrBlockUrl.length;i++){
					if(arrBlockUrl[i] == cUrl){
						alert('This URL is already added above.');
						return;
					}
				}
				arrBlockUrl.push(cUrl);
				arrBlock.push(cname);
			}
			document.editForm.linkcount.value=arrBlock.length+1;
			var cb=document.getElementById("categoryBlock");
			arrBlock2=new Array();
			arrBlock2.push('<table style="border-spacing:0px;border:1px solUrl ##CCCCCC;"><tr class="table-list" ><td>Title</td><td>URL</td><td>Admin</td></tr>');
			for(var i=0;i<arrBlock.length;i++){
				var s='style="background-color:##F2F2F2;"';
				if(i%2==0){
					s="";
				}
				arrBlock2.push('<tr '+s+'><td><input type="text" name="title'+(i+1)+'" value="'+arrBlock[i]+'" onkeyup="updateTitle('+i+',this);"></td><td><input type="text" name="url'+(i+1)+'" value="'+arrBlockUrl[i]+'" onkeyup="updateUrl('+i+',this);"></td><td><a href="##" onclick="removeCat('+(arrBlock2.length-1)+');return false;" title="Click to remove link.">Remove</a></td></tr>');
			}
			arrBlock2.push('<tr><td style="vertical-align:top;"><input type="text" name="addTitle" value=""></td><td ><input type="text" name="addUrl" value=""></td><td> <input type="button" name="addButton" value="Add" onClick="setCatBlock(true);"></td></tr><tr><td colspan="3"><input type="submit" name="submit" value="Save Hardcoded Urls"> <input type="button" name="cancel" value="Cancel" onClick="window.location.href = \'/z/server-manager/admin/hardcoded-urls/index?sid=#form.sid#\';"></td></tr></table>');
			arrBlock2.push('<input type="hidden" name="ccUrl" value="'+arrBlockUrl.join(",")+'">');
			cb.innerHTML=arrBlock2.join('');
			if(arrBlock2.length==0){
				cb.style.display="inline";
			}else{
				cb.style.display="block";
			}
		}
		setCatBlock(false);
		/* ]]> */
		</script>
	</form>
</cffunction>

<cffunction name="verifyLinks" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var qU=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	if(form.sid EQ ""){
		application.zcore.status.setStatus(request.zsid,"You must select a site before verifying links");
		application.zcore.functions.zRedirect("/z/server-manager/admin/hardcoded-urls/index?zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #request.zos.queryObject.table("link_hardcoded", request.zos.zcoreDatasource)# link_hardcoded 
	WHERE site_id = #db.param(form.sid)# and 
	link_hardcoded_deleted=#db.param(0)# 
	ORDER BY link_hardcoded_id ASC";
	qU=db.execute("qU");
	for(local.row in qU){
		if(application.zcore.functions.zVerifyLink(local.row.link_hardcoded_url) EQ false){
			application.zcore.status.setStatus(request.zsid,"#local.row.link_hardcoded_url# failed to verify.",false,true);
		}
	}
	application.zcore.status.setStatus(request.zsid,"Links verified.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/hardcoded-urls/edit?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var qSites=0;
	var selectStruct=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param('1')# and 
	site_deleted = #db.param(0)#
	ORDER BY site_domain asc";
	qSites=db.execute("qSites");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript> 
	<h2>Hardcoded URLs</h2>
	<table style="width:100%; border-spacing:0px;" class="table-white"> 
		<tr>
			<td class="table-white"> Select a site to edit rules:
				<cfscript>
				selectStruct = StructNew();
				selectStruct.name = "sid";
				// options for query data
				selectStruct.onChange="var d=this.options[this.selectedIndex].value; 
				if(d != ''){
					window.location.href='/z/server-manager/admin/hardcoded-urls/edit?sid='+escape(d);
				}";
				selectStruct.query = qSites;
				selectStruct.queryLabelField = "site_domain";
				selectStruct.queryValueField = "site_id";	
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
		</tr>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
