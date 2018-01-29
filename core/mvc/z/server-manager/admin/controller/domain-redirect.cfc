<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	form.sid=application.zcore.functions.zso(form, 'sid');
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql="SELECT * FROM #db.table("domain_redirect", request.zos.zcoreDatasource)# domain_redirect
	WHERE domain_redirect_id= #db.param(application.zcore.functions.zso(form,'domain_redirect_id'))# and 
	domain_redirect_deleted = #db.param(0)#  and 
	site_id = #db.param(form.sid)#";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'domain_redirect no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/index?zsid=#request.zsid#&sid=#form.sid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		db.sql="UPDATE #db.table("domain_redirect", request.zos.zcoreDatasource)# 
		set domain_redirect_deleted = #db.param(form.domain_redirect_id)#,
		domain_redirect_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE domain_redirect_id= #db.param(form.domain_redirect_id)# and 
		site_id = #db.param(form.sid)# and 
		domain_redirect_deleted=#db.param(0)# ";
		q=db.execute("q"); 
		application.zcore.functions.zUpdateDomainRedirectCache();
		rs=application.zcore.functions.zGenerateNginxMap();
		application.zcore.status.setStatus(Request.zsid, 'Domain redirect deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/index?zsid=#request.zsid#&sid=#form.sid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this domain redirect?<br />
			<br />
			#qCheck.domain_redirect_old_domain# (Address: #qCheck.domain_redirect_old_domain#) 			<br />
			<br />
			<a href="/z/server-manager/admin/domain-redirect/delete?confirm=1&amp;domain_redirect_id=#form.domain_redirect_id#&amp;sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/domain-redirect/index?sid=#form.sid#">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts={};
	var result=0; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	form.site_id = form.sid;
	ts.domain_redirect_old_domain.required = true;
	ts.domain_redirect_new_domain.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/edit?domain_redirect_id=#form.domain_redirect_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='domain_redirect';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){ 
		form.domain_redirect_id = application.zcore.functions.zInsert(ts); 
		if(form.domain_redirect_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save domain redirect.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/add?zsid=#request.zsid#&sid=#form.sid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'domain redirect saved.'); 
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save domain redirect.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/edit?domain_redirect_id=#form.domain_redirect_id#&sid=#form.sid#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'domain redirect updated.');
		}
		
	} 
	application.zcore.functions.zUpdateDomainRedirectCache();

	var rs=application.zcore.functions.zGenerateNginxMap();
	application.zcore.status.setStatus(request.zsid, rs.message, form, not rs.success);
	
	application.zcore.functions.zRedirect('/z/server-manager/admin/domain-redirect/index?zsid=#request.zsid#&sid=#form.sid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject;
	var qRoute=0;
	var currentMethod=form.method;
	var htmlEditor=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.2.1");
	if(application.zcore.functions.zso(form,'domain_redirect_id') EQ ''){
		form.domain_redirect_id = -1;
	}
	db.sql="SELECT * FROM #db.table("domain_redirect", request.zos.zcoreDatasource)# domain_redirect 
	WHERE site_id =#db.param(form.sid)# and 
	domain_redirect_deleted = #db.param(0)#  and 
	domain_redirect_id=#db.param(form.domain_redirect_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript> 
	<form class="zFormCheckDirty" action="/z/server-manager/admin/domain-redirect/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?domain_redirect_id=#form.domain_redirect_id#&amp;sid=#form.sid#" method="post"> 
		<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr class="table-white"><td colspan="2"><span class="large"><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Domain Redirect</span>
		</td>
		</tr>
			<tr>
				<td class="table-list">Old Domain</td>
				<td class="table-white">http(s)://<input type="text" name="domain_redirect_old_domain" size="100" value="#htmleditformat(form.domain_redirect_old_domain)#" /><br />
				Don't include anything after the .com, .net, etc.  i.e. enter example.com instead of example.com/</td>
			</tr>  
			<tr>
				<td class="table-list">New Domain</td>
				<td class="table-white">http(s)://<input type="text" name="domain_redirect_new_domain" size="100" value="#htmleditformat(form.domain_redirect_new_domain)#" /><br />
				When "Type" is set to "Force To Exact URL", make sure to enter the complete url in this field, otherwise leave it as a simple domain without any forward slash at the end. i.e. example.com</td>
			</tr>  
			<tr>
				<td class="table-list">Type</td>
				<td class="table-white"><cfscript>
				form.domain_redirect_type=application.zcore.functions.zso(form, 'domain_redirect_type', true, 0);
				ts = StructNew();
				ts.name = "domain_redirect_type"; 
				ts.labelList = "Preserve URL,Force To Root,Force To Exact URL,404 Not Found";
				ts.valueList = "0,1,2,3";  
				ts.struct=form;
				writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
				</cfscript></td>
			</tr>  
			<tr>
				<td class="table-list">Force SSL?</td>
				<td class="table-white"><cfscript>
				writeoutput(application.zcore.functions.zInput_Boolean("domain_redirect_secure"));
				</cfscript></td>
			</tr>  
			<tr>
				<td class="table-list">Domain Masking?</td>
				<td class="table-white"><cfscript>
				writeoutput(application.zcore.functions.zInput_Boolean("domain_redirect_mask"));
				</cfscript> | "Yes" forces the old domain to display the new domain in an iframe instead of redirecting to it.<br /></td>
			</tr>  
			<tr>
				<td class="table-list">Domain Mask Title</td>
				<td class="table-white"><input type="text" name="domain_redirect_title" size="100" value="#htmleditformat(form.domain_redirect_title)#" /></td>
			</tr>  
			<tr>
				<td class="table-list">&nbsp;</td>
				<td class="table-white"><button type="submit" name="submitForm">Save Domain Redirect</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/server-manager/admin/domain-redirect/index?sid=#form.sid#';">Cancel</button></td>
			</tr>
		</table>
	</form>  
</cffunction>



<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qDomainRedirect=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init(); 
	application.zcore.functions.zSetPageHelpId("8.1.1.2");
	application.zcore.functions.zStatusHandler(request.zsid); 
	db.sql="SELECT * 
	FROM #db.table("domain_redirect", request.zos.zcoreDatasource)# domain_redirect  
	WHERE domain_redirect.site_id = #db.param(form.sid)# and 
	domain_redirect_deleted = #db.param(0)# 
	order by domain_redirect_old_domain";
	qDomainRedirect=db.execute("qDomainRedirect");
	</cfscript>
	<h2>Manage Domain Redirects</h2>
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr class="table-list"><td>
			<a href="/z/server-manager/admin/domain-redirect/add?sid=#form.sid#">Add Domain Redirect</a>
			</td></tr>
		<tr class="table-list"><td> 
	<cfif qDomainRedirect.recordcount EQ 0>
		<p>No domain redirects have been added.</p>
		<cfelse>
		<table  class="table-list">
			<tr>
				<th>Old domain</th>
				<th>New domain</th> 
				<th>Admin</th>
			</tr>
			<cfloop query="qDomainRedirect">
				<tr <cfif qDomainRedirect.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>> 
					<td><a href="http://#qDomainRedirect.domain_redirect_old_domain#" target="_blank">#qDomainRedirect.domain_redirect_old_domain#</a></td>
					<td><a href="http://#qDomainRedirect.domain_redirect_new_domain#" target="_blank">#qDomainRedirect.domain_redirect_new_domain#</a>
						</td>
					<td>
					<a href="/z/server-manager/admin/domain-redirect/edit?domain_redirect_id=#qDomainRedirect.domain_redirect_id#&amp;sid=#form.sid#">Edit</a> | 
					<a href="/z/server-manager/admin/domain-redirect/delete?domain_redirect_id=#qDomainRedirect.domain_redirect_id#&amp;sid=#form.sid#">Delete</a></td>
				</tr>
			</cfloop>
		</table>
	</cfif>
			</td></tr>
			</table>
</cffunction>
</cfoutput>
</cfcomponent>