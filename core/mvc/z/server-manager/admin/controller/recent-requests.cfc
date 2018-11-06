<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var countStruct=0;
	var t9=0;
	var n=0;
	var arrM=0;
	var tmp=0;
	var row=0;
	var zsascriptruntime=0;
	var c=0;
	var zsascriptruntime2=0;
	var cfmlPassword=0;
	var data=0;
	var pos2=0;
	var i=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.3.1");
	</cfscript>
	<h2>Recent Request History</h2>
	<!--- 
    <!--- 
    <cfadmin 
        action="getContexts"
        type="server"
        password="#cfmlPassword#"
        returnVariable="contexts"> --->

	for(local.i2 in data){
		//writeoutput('Context:'&local.i2&'<br />');
		for(local.i=1;local.i LTE arraylen(data[local.i2]);local.i++){
			//writedump(getmetadata[local.i2](data[local.i2][local.i]));
	
			for(local.n=1;local.n LTE contexts.recordcount;local.n++){
				if(contexts.hash[local.n] EQ local.i2){
					local.contextid=contexts.id[local.n];
				}
			}
			writeoutput("requestid:"&data[local.i2][local.i].requestid&"<br />");
			writeoutput('<a href="/z/server-manager/admin/recent-requests/index?action=killThread&threadId='&data[local.i2][local.i].requestid&'&contextId='&urlencodedformat(local.contextid)&'">Kill thread with context id</a><br />');
			writeoutput('<a href="/z/server-manager/admin/recent-requests/index?action=killThread&threadId='&data[local.i2][local.i].requestid&'&contextId='&urlencodedformat(local.i2)&'">Kill thread with context hash</a><br />');
			writeoutput("startTime:"&data[local.i2][local.i].startTime&"<br />");
			// endtime is when the thread will be automatically killed.
			writeoutput("endTime:"&data[local.i2][local.i].endTime&"<br />");
			writeoutput("urlToken:"&data[local.i2][local.i].urlToken&"<br />");
			writeoutput("thread name:"&data[local.i2][local.i].thread.name&"<br />");
			writeoutput("thread priority:"&data[local.i2][local.i].thread.priority&"<br />");
			writeoutput("timeout:"&data[local.i2][local.i].timeout&"<br />");
			writeoutput("debugger values:<br />");
			writedump(data[local.i2][local.i].debugger);
			writeoutput("tagcontext values:<br />");
			for(local.n=1;local.n LTE min(3,arraylen(data[local.i2][local.i].TagContext));local.n++){
				for(local.g in data[local.i2][local.i].TagContext[local.n]){
					writedump(local.g&"="&data[local.i2][local.i].TagContext[local.n][local.g]);
				}
			}
	 --->
	 
	 <cfif request.zOS.cfmlAdminReadEnabled>
		<h2>Running Threads</h2>
		<cfscript>
		form.pw=application.zcore.functions.zso(form, 'pw');
		if(form.pw NEQ ""){
			application.zcore.functions.zcookie({name:'cfmllocaladminpassword',value:form.pw,expires='never'});
		}
		</cfscript>
		<cfif structkeyexists(cookie, 'cfmllocaladminpassword') EQ false>
			<p>Set the cfml admin password to view/terminate running threads.</p>
		</cfif>
		<form action="#request.cgi_script_name#" method="post">
			cfml Admin Password:
			<input type="text" name="pw" value="<cfif structkeyexists(cookie, 'cfmllocaladminpassword')>#cookie.cfmllocaladminpassword#</cfif>" />
			<input type="submit" name="Submit" value="Submit" />
		</form>
		<cfif structkeyexists(cookie, 'cfmllocaladminpassword')>
			
			<!--- java.util.ConcurrentModificationException - error can't be try/catch when looping surveillance data --->
			<cfset cfmlPassword=cookie.cfmllocaladminpassword>
			<cfif request.zOS.cfmlAdminWriteEnabled>
				<cfif structkeyexists(form,'action') and form.action EQ "killAllThreads">
					<cfadmin action="surveillance" type="server" password="#cfmlPassword#" returnVariable="data">
					<cfscript>
					for(local.i2 in data){
						for(local.i=1;local.i LTE arraylen(data[local.i2]);local.i++){
							admin action="terminateRunningThread" type="server" password="#cfmlPassword#" id="#data[local.i2][local.i].requestid#";
						}
					}
					application.zcore.status.setStatus(request.zsid, "All threads terminated");
					application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
					</cfscript>
				</cfif>
				<cfif structkeyexists(form,'action') and form.action EQ "killThread">
					<cfadmin action="terminateRunningThread" type="server" password="#cfmlPassword#" id="#form.threadId#">
					<cfscript>
					application.zcore.status.setStatus(request.zsid, "Thread, #form.threadid#, terminated");
					application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
					</cfscript>
				</cfif>
			</cfif>
			<cfadmin action="surveillance" type="server" password="#cfmlPassword#" returnVariable="data">
			<cfscript>
			c=0;
			for(local.i2 in data){
				c+=arraylen(data[local.i2]);
			}
			</cfscript>
			<cfif c EQ 0>
				<p>There are no running threads.</p>
			<cfelse>
				<table class="table-list">
					<tr>
						<th>Thread ID</th>
						<th>Start Time</th>
						<th>End Time</th>
						<th>Running Code</th>
						<th>Admin</th>
					</tr>
					<cfscript>
					local.g=0;
					for(local.i2 in data){
					for(local.i=1;local.i LTE arraylen(data[local.i2]);local.i++){
						local.g++;
						if(local.g MOD 2 EQ 0){
							writeoutput('<tr class="row1">');
						}else{
							writeoutput('<tr class="row2">');
						}
						writeoutput('
						<td>#data[local.i2][local.i].requestid#</td>
						<td>#dateformat(data[local.i2][local.i].startTime, "m/d/yy")# #timeformat(data[local.i2][local.i].startTime,"h:mm:sstt")#</td>
						<td>#dateformat(data[local.i2][local.i].endTime, "m/d/yy")# #timeformat(data[local.i2][local.i].endTime,"h:mm:sstt")#</td>
						
						<td><textarea name="t'&local.g&'" rows="3" cols="150">
						');
						
						for(local.n=1;local.n LTE min(3,arraylen(data[local.i2][local.i].TagContext));local.n++){
							writeoutput('#data[local.i2][local.i].TagContext[local.n].line#: #data[local.i2][local.i].TagContext[local.n].template#<br />'&
							htmleditformat(data[local.i2][local.i].TagContext[local.n].codeprintplain));
						}
						writeoutput('</textarea></td><td>');
						if(request.zOS.cfmlAdminWriteEnabled){
							echo('<a href="/z/server-manager/admin/recent-requests/index?action=killThread&threadId=#data[local.i2][local.i].requestid#">Terminate</a>');
						}
						echo('	</td>
						</tr>');
						}
					}
					</cfscript>
				</table>
				<cfif request.zOS.cfmlAdminWriteEnabled>
				<p><a href="/z/server-manager/admin/recent-requests/index?action=killAllThreads">Terminate All Running Threads</a></p>
				</cfif>
			</cfif>
			<hr />
		</cfif>
	</cfif>
	<cfscript>
	if(isDefined('application.zcore.runningScriptStruct')){
		t9=duplicate(application.zcore.runningScriptStruct);
		
		writeoutput('<h2>Robots hitting spam trap</h2>');
		if(structkeyexists(application.zcore,'robotThatHitSpamTrap')){
			writeoutput('<table style="border-spacing:0px; padding:5px;">
			<tr><td>IP+User Agent</td><td>Hits</td></tr>');
			
			for(i in application.zcore.robotThatHitSpamTrap){
				writeoutput('<tr><td>'&i&'</td><td>'&application.zcore.robotThatHitSpamTrap[i]&'</td></tr>');
			}
			writeoutput('</table><br />');
		}
	
		structdelete(application.zcore.runningScriptStruct,'r'&request.zos.trackingRunningScriptIndex);
		writeoutput('<h2>Running Scripts</h2><p><a href="#request.cgi_script_name#?clearOldRunning=1">Clear Old Scripts</a></p><table style="border-spacing:0px; padding:5px;">
		<tr><td>Running Time (seconds)</td><td>URL</td></tr>');
		
		for(i in t9){  
			seconds=datediff("s",t9[i].startTime, now());
			if(structkeyexists(form, 'clearOldRunning') and seconds GT 3600){
				structdelete(application.zcore.runningScriptStruct,i);	
			}else{
				writeoutput('<tr><td>'&seconds&'</td><td>'&t9[i].url&'</td></tr>');
			} 
		}
		writeoutput('</table>');
		if(structkeyexists(form, 'clearOldRunning')){
			application.zcore.functions.zredirect(request.cgi_script_name);	
		}
	}
	
	t9=application.zcore.arrRequestcache;
		
		
	countStruct=structnew();
	zsascriptruntime=structnew();
	zsascriptruntime2=structnew();
	arrM=["scriptName","queryString","userAgent","host","runtime","datetime","zsascript","formvars"];
	for(n=1;n LTE arraylen(arrM);n++){
		countStruct[arrM[n]]=structnew();
	}
	writeoutput('<h2>Scripts Slower Then 1 Second</h2><br />	<table style="border-spacing:0px;" class="table-list"><tr><td>Link</td><td style="width:120px;">Script</td><td>Host</td><td>Query String / User Agent</td><td>Runtime</td><td>Date/time</td></tr>');
	row=0;
	for(i=1;i LTE arraylen(t9);i++){
		if(arrayisdefined(t9,i) EQ false) continue;
		if(isstruct(t9[i]) EQ false or structkeyexists(t9[i],"scriptName") EQ false) continue;
		for(n=1;n LTE arraylen(arrM);n++){
			if(structkeyexists(t9[i], arrM[n]) EQ false and arrM[n] NEQ "zsascript"){
				if(arrM[n] EQ "runtime"){
					t9[i][arrM[n]]=0;
				}else if(arrM[n] EQ "datetime"){
					t9[i][arrM[n]]=now();
				}else if(arrM[n] EQ "formVars"){
					t9[i][arrM[n]]=structnew();
				}else{
					t9[i][arrM[n]]="";
				}
			}
			if(arrM[n] EQ "zsascript"){
				tmp=t9[i].scriptName;
				if(left(tmp, 5) EQ "/z/_-"){
					tmp=left(tmp, 7);
				}
				pos2=find('__zcoreinternalroutingpath=',t9[i].queryString);
				if(pos2 NEQ 0){
					pos=find("&",	t9[i].queryString,pos2);
					if(pos NEQ 0){
						tmp="/z/_"&mid(t9[i].queryString,pos2+11,pos-(pos2+11));
					}	
				}
				
				if(structkeyexists(zsascriptruntime2,tmp) EQ false){
					zsascriptruntime2[tmp]="http://"&t9[i].host&t9[i].scriptName&"?"&t9[i].queryString;
				}
				if(structkeyexists(zsascriptruntime,tmp) EQ false){
					zsascriptruntime[tmp]=arraynew(1);
				}
				arrayappend(zsascriptruntime[tmp],t9[i].runtime);
				if(structkeyexists(countStruct[arrM[n]], tmp) EQ false){
					countStruct[arrM[n]][tmp]=0;
				}
				countStruct[arrM[n]][tmp]++;
			}else if(arrM[n] EQ "datetime"){
				tmp=dateformat(	t9[i][arrM[n]],"yyyy-mm-dd")&" "&timeformat(t9[i][arrM[n]],"HH:mm");//&":"&int(timeformat(t9[i][arrM[n]],"s")/10)&"0";
				if(structkeyexists(countStruct[arrM[n]], tmp) EQ false){
					countStruct[arrM[n]][tmp]=0;
				}
				countStruct[arrM[n]][tmp]++;
			}else if(arrM[n] EQ "runtime"){
				tmp=fix(t9[i][arrM[n]]/1)*1; // 1 second intervals
				if(tmp EQ 1){
				}
				tmp=(fix(t9[i][arrM[n]]*100)*10)&"ms";
				if(structkeyexists(countStruct[arrM[n]], tmp) EQ false){
					countStruct[arrM[n]][tmp]=0;
				}
				countStruct[arrM[n]][tmp]++;
			}else if(arrM[n] EQ "formvars"){
			}else{
				if(structkeyexists(countStruct[arrM[n]], t9[i][arrM[n]]) EQ false){
					countStruct[arrM[n]][t9[i][arrM[n]]]=0;
				}
				countStruct[arrM[n]][t9[i][arrM[n]]]++;
			}
		}
		if(t9[i].runtime GT 1){
			row++;
			writeoutput('<tr ');
			if(row MOD 2 EQ 0){ writeoutput('style="background-color:##EFEFEF;">'); }else{ writeoutput('>'); }
				writeoutput('<td style="width:20px;">');
				if(structcount(t9[i].formvars) NEQ 0){
					writeoutput('<form action="http://#t9[i].host##t9[i].scriptName#?#t9[i].queryString#" method="post"><input type="submit" name="submit11" value="Repost Form ###row#">');
					for(gg in t9[i].formvars){
						writeoutput('<input type="hidden" name="#gg#" value="#htmleditformat(t9[i].formvars[gg])#">');
					}
					writeoutput('</form>');
				}else{
					writeoutput('<input type="button" name="button11" value="View Link ###row#" onclick="window.location.href=''http://#t9[i].host##t9[i].scriptName#?#t9[i].queryString#'';">');
				}
				writeoutput('</td><td style="width:120px;">#t9[i].scriptName#</td><td>#t9[i].host#</td><td >#t9[i].queryString#<br />#t9[i].userAgent#</td><td>#t9[i].runtime#</td><td>#dateformat(t9[i].datetime,'m d, yy')&' '&timeformat(t9[i].datetime,'h:mm:ss')#</td></tr>');
		}
	}
	writeoutput('</table>');
	arrayappend(arrM,"zsascript");
	for(i in countStruct){
		if(i EQ 'zsascript'){
			writeoutput('<h2>#i# Count</h2><table style="border-spacing:0px;" class="table-list"><tr><td>Count</td><td>Runtime</td><td>Value</td></tr>');
			row=1;
			for(n in countStruct[i]){
				writeoutput('<tr');
				if(row MOD 2 EQ 0){ writeoutput(' style="background-color:##EFEFEF;"'); }
				writeoutput('><td>#countStruct[i][n]#</td><td>#arrayavg(zsascriptruntime[n])#</td><td><a href="#zsascriptruntime2[n]#" target="_blank">#htmleditformat(n)#</a></td></tr>');
				row++;
			}
			writeoutput('</table><br />');
		}else if(i NEQ "ScriptName" and i NEQ "queryString" and i NEQ "formvars"){
			writeoutput('<h2>#i# Count</h2><table style="border-spacing:0px;" class="table-list"><tr><td>Count</td><td>Value</td></tr>');
			row=1;
			for(n in countStruct[i]){
				writeoutput('<tr');
				if(row MOD 2 EQ 0){ writeoutput(' style="background-color:##EFEFEF;"'); }
				writeoutput('><td>#countStruct[i][n]#</td><td>#n#</td></tr>');
				row++;
			}
			writeoutput('</table><br />');
		}
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
