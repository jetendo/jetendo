<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	throw("deploy archive is no longer implemented");
	if(not request.zOS.cfmlAdminWriteEnabled){
		throw("request.zOS.cfmlAdminWriteEnabled is not enabled.");
	}
	form.pw=application.zcore.functions.zso(form, 'pw');
	form.remoteurl=application.zcore.functions.zso(form, 'remoteurl');
	form.clearcache=application.zcore.functions.zso(form, 'clearcache');
	form.remotepw=application.zcore.functions.zso(form, 'remotepw');
	if(request.zos.isTestServer){
		if(form.pw NEQ ""){
			application.zcore.functions.zcookie({name:'cfmllocaladminpassword',value:form.pw,expires='never'});
		}
		if(form.remotepw NEQ ""){
			application.zcore.functions.zcookie({name:'cfmlremoteadminpassword',value:form.remotepw,expires='never'});
		}
	}
	form.adminType="web";
	setting requesttimeout="500";
	</cfscript>
</cffunction>

<!--- <cffunction name="deployCfmlArchive" localmode="modern" access="private" output="no">
	<cfscript>
	
	var qDir=0;
	var r1=0; 
	variables.init();
	if(request.zos.cfmlServerKey EQ "railo"){
		local.path=expandpath("/railo-context/")&"archives/";
	}else{
		local.path=expandpath("/lucee/")&"archives/";
	}
	local.fileName=application.zcore.functions.zUploadFile(form.fileName, local.path);
	
	admin action="getMappings" type="#form.adminType#" password="#form.pw#" returnVariable="local.mappings";
	admin action="getRemoteClients" type="#form.adminType#" password="#form.pw#" returnVariable="local.clients";
	local.found=false;
	local.curIndex=0;
	local.archiveStruct=structnew();
	for(local.i=1;local.i LTE local.mappings.recordcount;local.i++){
		if(toString(local.mappings.archive[local.i]) NEQ ""){
			local.archiveStruct[toString(local.mappings.archive[local.i])]=true;
		}
		if(local.mappings.virtual[local.i] EQ "/zcorerootmapping"){
			local.found=true;
			local.curIndex=local.i;
		}
	}
	directory name="qDir" directory="#local.path#" action="list" sort="datelastmodified desc";
	local.i=0;
	for(local.row in qDir){
		local.i++;
		if(local.i GT 10){
			if(structkeyexists(local.archiveStruct, local.path&local.row.name) EQ false){
				application.zcore.functions.zdeletefile(local.path&local.row.name);
			}
		} 
	}
	admin action="updateMapping" type="#form.adminType#" password="#form.pw#" virtual="/zcorerootmapping" physical="#local.mappings.physical[local.curIndex]#" archive="#local.path&local.fileName#" primary="archive" trusted="true"	toplevel="true" remoteClients="#local.clients#";
	
	application.zcore.functions.zClearCFMLTemplateCache();
	codeDeployCom=createobject("component", "zcorerootmapping.com.zos.codeDeploy");
	codeDeployCom.onCodeDeploy();
	
	if(form.clearcache EQ "app"){
		r1=application.zcore.functions.zdownloadlink(request.zOS.zcoreAdminDomain&"/z/server-manager/tasks/deploy-archive/index?zreset=app");
		if(r1.success EQ false){
			application.zcore.template.fail("Archive deployed, but failed to clear cache: app.  You should manually verify the web sites on the target server are still working.");
		}
	}else if(form.clearcache EQ "app,listing"){
		r1=application.zcore.functions.zdownloadlink(request.zOS.zcoreAdminDomain&"/z/server-manager/tasks/deploy-archive/index?zreset=app&zforcelisting=1");
		if(r1.success EQ false){
			application.zcore.template.fail("Archive deployed, but failed to clear cache: app & listing.  You should manually verify the web sites on the target server are still working.");
		}
	}else if(form.clearcache EQ "app,skin"){
		r1=application.zcore.functions.zdownloadlink(request.zOS.zcoreAdminDomain&"/z/server-manager/tasks/deploy-archive/index?zreset=app&zforce=1");
		if(r1.success EQ false){
			application.zcore.template.fail("Archive deployed, but failed to clear cache: app & skin.  You should manually verify the web sites on the target server are still working.");
		}
		
	}else if(form.clearcache EQ "all"){
		r1=application.zcore.functions.zdownloadlink(request.zOS.zcoreAdminDomain&"/z/server-manager/tasks/deploy-archive/index?zreset=all");
		if(r1.success EQ false){
			application.zcore.template.fail("Failed to clear cache: all.  You should manually verify the web sites on the target server are still working.");
		}
	}else if(form.clearcache EQ "all,skin"){
		r1=application.zcore.functions.zdownloadlink(request.zOS.zcoreAdminDomain&"/z/server-manager/tasks/deploy-archive/index?zreset=all&zforce=1");
		if(r1.success EQ false){
			application.zcore.template.fail("Failed to clear cache: all & skin cache.  You should manually verify the web sites on the target server are still working.");
		}
	}
	</cfscript>
</cffunction>



<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	variables.init();
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.4.6"); 
	if(request.zos.isTestServer EQ false){
		writeoutput('Deploy can''t be run on a production server since it is designed to deploy an archive from the test server to the production server. 
			<a href="#request.zos.testAdminDomain#/z/server-manager/admin/deploy/index">Go to test server deploy page</a>');
		application.zcore.functions.zabort();
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<form class="zFormCheckDirty" action="/z/server-manager/tasks/deploy-archive/update" method="post">
		<h2>Local cfml Web Admin</h2>
		<p>Password:
			<input type="text" name="pw" id="pw" value="<cfif structkeyexists(cookie, 'cfmllocaladminpassword')>#cookie.cfmllocaladminpassword#</cfif>" />
		</p>
		<h2>Remote cfml Web Admin</h2>
		<p>URL:
			<input type="text" name="remoteurl" style="width:500px;" value="#request.zOS.zcoreAdminDomain#/z/server-manager/tasks/deploy-archive/deploy" />
		</p>
		<p>Password:
			<input type="text" name="remotepw" value="<cfif structkeyexists(cookie, 'cfmlremoteadminpassword')>#cookie.cfmlremoteadminpassword#</cfif>" />
		</p>
		<p>Clear Cache:
			<input type="radio" name="clearcache" value="" <cfif form.clearcache EQ "">checked="checked"</cfif> />
			Code
			<input type="radio" name="clearcache" value="app" />
			App
			<input type="radio" name="clearcache" value="app,skin" />
			App &amp; Skin
			<input type="radio" name="clearcache" value="app,listing" />
			App &amp; Listing 
			<input type="radio" name="clearcache" value="all" />
			All
			<input type="radio" name="clearcache" value="all,skin" />
			All &amp; Skin Cache Rebuild</p>
		<div style="width:100%; float:left">
			<input type="submit" name="submit1" value="Submit" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
			<div id="pleaseWait" style="display:none;">Please wait...</div>
		</div>
	</form>
</cffunction>

<cffunction name="update" localmode="modern" access="remote">
	<cfscript>
	var qDir=0;
	var cfcatch=0;
	var e=0;
	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	variables.init();
	if(request.zos.cfmlServerKey EQ "railo"){
		local.path=expandpath("/railo-context/")&"archives/";
	}else{
		local.path=expandpath("/lucee/")&"archives/";
	}
	admin action="getMappings" type="#form.adminType#" password="#form.pw#" returnVariable="local.mappings";
	admin action="getRemoteClients" type="#form.adminType#" password="#form.pw#" returnVariable="local.clients";
	local.found=false;
	local.curIndex=0;
	local.archiveStruct=structnew();
	for(local.i=1;local.i LTE local.mappings.recordcount;local.i++){
		if(toString(local.mappings.archive[local.i]) NEQ ""){
			local.archiveStruct[toString(local.mappings.archive[local.i])]=true;
		}
		if(local.mappings.virtual[local.i] EQ "/zcorerootmapping"){
			local.found=true;
			local.curIndex=local.i;
		}
	}
	directory name="qDir" directory="#local.path#" action="list" sort="datelastmodified desc";
	local.i=0;
	for(local.row in qDir){
		local.i++;
		if(local.i GT 10){
			if(structkeyexists(local.archiveStruct, local.path&local.row.name) EQ false){
				application.zcore.functions.zdeletefile(local.path&local.row.name);
			}
		}
	}
	local.fileName="zcorerootmapping-archive"&dateformat(now(),'yyyymmdd')&timeformat(now(),'HHmmss')&".ras";
	if(local.found EQ false){
		application.zcore.template.fail("Mapping, /zcorerootmapping, not defined in cfml #form.adminType# admin.");
	}
	try{
		admin action="createArchive" type="#form.adminType#" password="#form.pw#" file="#local.path&local.fileName#" virtual="/zcorerootmapping" append="true" addCFMLFiles="false" addNonCFMLFiles="false" remoteClients="#local.clients#";
	}catch(Any e){
		writeoutput('<h2>Failed to compile archive</h2>');
		writedump(e);
		application.zcore.functions.zabort();  
	}
	
	admin action="updateMapping" type="#form.adminType#" password="#form.pw#" virtual="/zcorerootmapping" physical="#local.mappings.physical[local.curIndex]#" archive="#local.path&local.fileName#" primary="physical" trusted="false" toplevel="true" remoteClients="#local.clients#";
	
	application.zcore.functions.zClearCFMLTemplateCache();
	</cfscript>
	<cftry>
		<cfhttp url="#form.remoteurl#" result="local.mycfhttp" timeout="400" throwonerror="yes" method="post" multipart="yes">
		<cfhttpparam type="formField" name="clearcache" value="#form.clearcache#">
		<cfhttpparam type="formField" name="fileName" value="#local.fileName#">
		<cfhttpparam type="formField" name="pw" value="#form.remotepw#">
		<cfhttpparam type="file" name="#local.fileName#" file="#local.path&local.fileName#">
		</cfhttp>
		<cfcatch type="any">
			<h2>Failed to upload or deploy archive</h2>
			<p>You should manually verify the web sites on the remote server are still working.</p>
			<h2>CFCATCH Object</h2>
			<cfdump var="#cfcatch#">
			<h2>CFHTTP Object</h2>
			<cfdump var="#local.mycfhttp#">
			<cfscript>
			application.zcore.functions.zabort();
			</cfscript>
		</cfcatch>
	</cftry>
	<cfscript>
	if(local.mycfhttp.filecontent DOES NOT CONTAIN "Deploy Successful"){
		writeoutput(local.mycfhttp.filecontent);
		application.zcore.functions.zabort();
	}
	application.zcore.status.setStatus(request.zsid, "Archive deployed");
	application.zcore.functions.zRedirect("/z/server-manager/tasks/deploy-archive/index?zsid=#request.zsid#");
    </cfscript>
</cffunction>

<cffunction name="deploy" localmode="modern" access="remote">
	<cfscript>
	var e=0;
	variables.init();
	try{
		if(form.clearcache NEQ ""){
			application.zDeployExclusiveLock=true;
			lock type="exclusive" timeout="400" throwontimeout="no" name="#request.zos.installPath#-zDeployExclusiveLock"{
				sleep(1000); // allow other requests to finish before starting
				variables.deploycfmlArchive();
			}
		}else{
			variables.deploycfmlArchive();	
		}
	}catch(Any e){
		writeoutput('<h2>Failed to deploy archive</h2>');
		writedump(e);
		application.zcore.functions.zabort();	
	}	
	structdelete(application, 'zDeployExclusiveLock');
	writeoutput('Deploy Successful');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction> --->
</cfoutput>
</cfcomponent>
