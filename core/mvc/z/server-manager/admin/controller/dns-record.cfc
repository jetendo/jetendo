<cfcomponent>
<cfoutput>
<cffunction name="incrementZoneSerial" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	zoneCom.incrementZoneSerial(arguments.dns_zone_id, false);

	</cfscript>
</cffunction>


<cffunction name="formatDNSRecord" localmode="modern" access="public">
	<cfargument name="record" type="struct" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	return zoneCom.formatDNSRecord(arguments.record);
	</cfscript>
</cffunction>

<cffunction name="setCustom" localmode="modern" access="public">
	<cfargument name="dns_zone_id" type="string" required="yes">
	<cfargument name="dns_record_type" type="string" required="yes">
	<cfscript>
	zoneCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.dns-zone");
	zoneCom.setCustom(arguments.dns_zone_id, arguments.dns_record_type);
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>	
	form.dns_zone_id=application.zcore.functions.zso(form, 'dns_zone_id', true, 0);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone, 
	#db.table("dns_group", request.zos.zcoreDatasource)# dns_group
	WHERE dns_zone.dns_zone_id=#db.param(form.dns_zone_id)# and 
	dns_group_deleted = #db.param(0)# and 
	dns_group.dns_group_id = dns_zone.dns_group_id and 
	dns_zone_deleted = #db.param(0)# ";
	qZone=db.execute("qZone");
	if(qZone.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "The selected DNS Zone doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/dns-record/index?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#");
	}
	form.dns_group_id=qZone.dns_group_id;
	form.dns_zone_name=qZone.dns_zone_name;
	form.dns_group_name=qZone.dns_group_name;
	</cfscript>
</cffunction>	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	init();
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT * FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record
	LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
	ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
	WHERE dns_record_id= #db.param(application.zcore.functions.zso(form,'dns_record_id'))# and 
	dns_record_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	application.zcore.functions.zSetModalWindow();
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'DNS Record no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/index?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		setCustom(form.dns_record_id, qCheck.dns_record_type);
		db.sql="UPDATE #db.table("dns_record", request.zos.zcoreDatasource)#  
		set dns_record_deleted = #db.param(1)#,
		dns_record_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE dns_record_id= #db.param(application.zcore.functions.zso(form, 'dns_record_id'))# and 
		dns_record_deleted = #db.param(0)# 
		";
		q=db.execute("q");
		incrementZoneSerial(form.dns_zone_id);
		application.zcore.status.setStatus(Request.zsid, 'DNS Record deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/autoCloseAndRefresh?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this DNS Record?<br />
			<br />
			#qCheck.dns_record_host# <cfif qCheck.dns_record_ttl NEQ 0>
						#qCheck.dns_record_ttl#
					</cfif>
					 IN #qCheck.dns_record_type# 
					 <cfif qCheck.dns_ip_address NEQ "">
						#qCheck.dns_ip_address#
					<cfelse>
					 	#qCheck.dns_record_value#
					 </cfif> ;
					 #qCheck.dns_record_comment#<br />
			<br />
			<a href="/z/server-manager/admin/dns-record/delete?confirm=1&amp;dns_record_id=#form.dns_record_id#&amp;dns_zone_id=#form.dns_zone_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="##"  onclick="window.parent.zCloseModal();">No</a> 
		</div>
	</cfif>
</cffunction>


<cffunction name="autoCloseAndRefresh" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetModalWindow();
	//application.zcore.functions.zStatusHandler(Request.zsid);
	</cfscript>
	<script>
	zArrDeferredFunctions.push(function(){
		//setTimeout(function(){
			window.parent.zCloseModal();
			window.parent.location.href="/z/server-manager/admin/dns-record/index?dns_zone_id=#form.dns_zone_id#";
		//}, 10);
	});
	</script>
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
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	init();
	ts.dns_record_type.required = true;
	error=false;

	form.dns_record_value=rereplace(form.dns_record_value, "\s+", " ", "all");
	if(left(form.dns_record_value,1) EQ '"'){
		form.dns_record_value=trim(mid(form.dns_record_value, 2, len(form.dns_record_value)-1));
	}
	if(right(form.dns_record_value,1) EQ '"'){
		form.dns_record_value=trim(left(form.dns_record_value, len(form.dns_record_value)-1));
	}
	if(right(form.dns_record_value,1) EQ "."){
		form.dns_record_value=trim(left(form.dns_record_value, len(form.dns_record_value)-1));
	}
	if(right(form.dns_record_value,1) EQ "."){
		form.dns_record_value=trim(left(form.dns_record_value, len(form.dns_record_value)-1));
	}

	if(form.dns_record_value EQ "" and form.dns_ip_id EQ ""){
		application.zcore.status.setStatus(Request.zsid, "You must select an IP or enter a value.",form,true);
		error=true;
	}
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result or error){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/add?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/edit?dns_record_id=#form.dns_record_id#&dns_zone_id=#form.dns_zone_id#&zsid=#request.zsid#');
		}
	}
	setCustom(form.dns_zone_id, form.dns_record_type);
	form.dns_record_updated_datetime = request.zos.mysqlnow;

	ts=StructNew();
	ts.table='dns_record';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.dns_record_id = application.zcore.functions.zInsert(ts);
		if(form.dns_record_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save DNS Record.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/add?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Record saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save DNS Record.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/edit?dns_record_id=#form.dns_record_id#&dns_zone_id=#form.dns_zone_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'DNS Record updated.');
		}
		
	}
	incrementZoneSerial(form.dns_zone_id);
	application.zcore.functions.zRedirect('/z/server-manager/admin/dns-record/autoCloseAndRefresh?zsid=#request.zsid#&dns_zone_id=#form.dns_zone_id#');
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
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	if(application.zcore.functions.zso(form,'dns_record_id') EQ ''){
		form.dns_record_id = -1;
	}
	db.sql="SELECT * FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone
	WHERE dns_zone_id=#db.param(form.dns_zone_id)# and 
	dns_zone_deleted = #db.param(0)# ";
	qZone=db.execute("qZone");

	application.zcore.functions.zSetModalWindow();
	db.sql="SELECT * FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record 
	WHERE dns_record_id=#db.param(form.dns_record_id)# and 
	dns_record_deleted = #db.param(0)# ";
	qRoute=db.execute("qRoute");
	if(structkeyexists(form, 'dns_record_type')){
		application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_zone_id,dns_record_type');
	}else{
		application.zcore.functions.zQueryToStruct(qRoute, form, 'dns_zone_id');
	}
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif>
		DNS Record</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/dns-record/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?dns_record_id=#form.dns_record_id#&amp;dns_zone_id=#form.dns_zone_id#" onsubmit="return checkDNSValue();" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:60px;">Name</th>
				<td><cfscript>
				ts = StructNew();
				ts.name = "dns_record_type";
				ts.hideSelect=true;
				ts.queryValueField = "dns_zone_id";
				ts.listLabels = "A|AAAA|CNAME|MX|NS|SRV|TXT";
				ts.listValues = "A|AAAA|CNAME|MX|NS|SRV|TXT";
				ts.listLabelsDelimiter = "|"; 
				ts.listValuesDelimiter = "|";
				ts.onchange="validateDNSValue();";
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:60px;">Host</th>
				<td><cfscript>
				if(form.dns_record_host EQ "@"){
					form.dns_record_host="";
				}
				ts=StructNew();
				ts.name="dns_record_host";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript><br />(Leave blank to use @/root host | Required for CNAME)</td>
			</tr>
			<tr>
				<th style="width:60px;">TTL</th>
				<td><cfscript>
				if(form.dns_record_ttl EQ 0){
					form.dns_record_ttl="";
				}

				ts=StructNew();
				ts.name="dns_record_ttl";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript><br />(Leave blank to inherit default: #qZone.dns_zone_ttl#)</td>
			</tr>
			</table>
			<table style="width:100%;" class="selectIPRow table-list">
				<tr>
					<td colspan="2">Select an IP or a enter valid IP address</td>
				</tr>
				<tr>
					<th style="width:60px;">IP</th>
					<td><cfscript>
						db.sql="SELECT * FROM #db.table("dns_ip", request.zos.zcoreDatasource)# 
						WHERE dns_ip_parent_id = #db.param(0)#
						ORDER BY dns_ip_address ASC";
						qGroups=db.execute("qGroups");
						selectStruct = StructNew();
						selectStruct.name = "dns_ip_id";
						selectStruct.query = qGroups;
						selectStruct.queryParseLabelVars=true;
						selectStruct.queryLabelField = "##dns_ip_address## (##dns_ip_comment##)";
						selectStruct.queryValueField = "dns_ip_id";
						selectStruct.onchange="$('##dns_record_value').val(''); validateDNSValue();";
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript></td>
				</tr>
			</table>
			<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:60px;">Value</th>
				<td>
				<script>
				function validateIPV6(str){
					return /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/.test(str);
				}
				function checkDNSValue(){
					if(dnsValueStatus == 1){
						return true;
					}else{
						alert("You must enter a valid value.");
						return false;
					}
				}
				function validateHostname(str){
					arrHost=str.trim().split(".");
					if(arrHost.length <= 1){
						return false;
					}
					return /^\s*((?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|\b-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|\b-){0,61}[0-9A-Za-z])?)*\.?)\s*$/.test(str);
				}
				var dnsValueStatus=false;
				function setDNSExample(){
					var type=$("##dns_record_type").val();
					var e=$("##dnsExampleDiv");
					if(type == "A"){
						e.html("Format: 1.2.3.4");
					}else if(type == "AAAA"){
						e.html("Format: FE80:0000:0000:0000:0202:B3FF:FE1E:8329");
					}else if(type == "CNAME"){
						e.html("Format: example.domain.com");
					}else if(type == "MX"){
						e.html("Format: 10 mail.domain.com");
					}else if(type == "NS"){
						e.html("Format: ns.domain.com");
					}else if(type == "SRV"){
						e.html("Format: 1 10 5269 xmpp-server.example.com.");
					}else if(type == "TXT"){
						e.html("Format: v=spf1 mx ptr include:sendgrid.net include:mailgun.org include:_spf.google.com ?all");
					}
				
				}
				function validateDNSValue(){
					var type=$("##dns_record_type").val();
					setDNSExample();
					var v=$("##dns_record_value").val();
					if(type != "A" && type != "AAAA"){
						$(".selectIPRow").css("display", "none");
						$("##dns_ip_id")[0].selectedIndex=0;
					}else{
						$(".selectIPRow").css("display", "block");
					}
					var status=-1;
					v=v.trim();
					if(v.substr(0,1) == '"'){
						v=v.substr(1);
					}
					if(v.substr(v.length-1,1) == '"'){
						v=v.substr(0, v.length-1);
					}
					if(v ==""){
						if(type == "A" || type == "AAAA"){
							if($("##dns_ip_id")[0].selectedIndex != 0){
								var ip=$("##dns_ip_id")[0].options[$("##dns_ip_id")[0].selectedIndex].text;
								var arrIP=ip.trim().split(" ");
								if(type == "A"){
									arrIP=arrIP[0].trim().split(".");
									if(arrIP.length != 4){
										status=0;
									}else{
										status=1;
									}
								}else if(type == "AAAA"){
									arrIP=arrIP[0].trim().split(":");
									if(arrIP.length == 8 || (ip.indexOf("::") != -1 && arrIP.length == 5)){
										status=1;
									}else{
										status=0;
									}
								}
							}else{
								status=0;
							}
						}else{
							status=0;
						}
					}else{
						v=v.trim();
						if(type == "A"){
							var arrIp=v.split(".");
							if(arrIp.length!=4){
								status=0;
							}else{
								for(var i=0;i<arrIp.length;i++){
									if(arrIp[i] == ""){
										status=0;
									}else if(isNaN(arrIp[i])){
										status=0;
										break;
									}else if(arrIp[i]>255 || arrIp[i]<0){
										status=0;
										break;
									}
								}
							}
							if(status == -1){
								status=1;
							}
						}else if(type == "AAAA"){
							if(validateIPV6(v)){
								status=1;
							}else{
								status=0;
							}
						}else if(type == "CNAME"){
							if(v.substr(v.length-1,1) == '.'){
								v=v.substr(0, v.length-1);
							}
							if($("##dns_record_host").val().trim() == ""){
								status=0;
							}else if(validateHostname(v)){
								status=1;
							}else{
								status=0;
							}
						}else if(type == "MX"){
							if(v.substr(v.length-1,1) == '.'){
								v=v.substr(0, v.length-1);
							}
							v=v.replace(/\s+/g, " ").replace(/\t+/g, " ").replace(/ /g, " ").trim();
							var arr1=v.split(" ");
							if(arr1.length != 2){
								status=0;
							}else{
    							var priority=arr1[0];
    							var host=arr1[1];
								if(host=="" || !validateHostname(host)){
									status=0;
								}else if(priority == "" || isNaN(priority)){
									status=0;
								}else{
									status=1;
								}
							}
						}else if(type == "NS"){
							if(v.substr(v.length-1,1) == '.'){
								v=v.substr(0, v.length-1);
							}
							if(validateHostname(v)){
								status=1;
							}else{
								status=0;
							}
						}else if(type == "SRV"){
							if(v.substr(v.length-1,1) == '.'){
								v=v.substr(0, v.length-1);
							}
							v=v.replace(/\s+/g, " ").replace(/\t+/g, " ").replace(/ /g, " ").trim();
							var arr1=v.split(" ");
							if(arr1.length != 4){
								status=0;
							}else{
    							var priority=arr1[0];
    							var weight=arr1[1];
    							var port=arr1[2];
    							var host=arr1[3];
								if(host=="" || !validateHostname(host)){
									status=0;
								}else if(priority == "" || isNaN(priority)){
									status=0;
								}else if(weight == "" || isNaN(weight)){
									status=0;
								}else if(port == "" || isNaN(port)){
									status=0;
								}else if(port<0 || port>65535){
									status=0;
								}else{
									status=1;
								}
							}
						}else if(type == "TXT"){
							status=1;
						}
					}
					dnsValueStatus=status;
					if(status==-1){
						$(".dnsValueDiv").css("background-color", "##FFF").html("");
					}else if(status == 0){
						$(".dnsValueDiv").css("background-color", "##C00").css("color", "##FFF").html("X");
					}else if(status == 1){
						$(".dnsValueDiv").css("background-color", "##0C0").css("color", "##000").html("&##x2713;");
					}
				}
				zArrDeferredFunctions.push(function(){
					validateDNSValue();
				});
				</script>
					<cfscript>
				ts=StructNew();
				ts.name="dns_record_value";
				ts.multiline=false;
				ts.onchange="document.getElementById('dns_ip_id').selectedIndex=0; ";
				ts.onkeyup="document.getElementById('dns_ip_id').selectedIndex=0; validateDNSValue(); ";
				ts.size=70;
				ts.style="float:left; width:80% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript>
				<div class="dnsValueDiv" style="margin-left:10px; font-weight:bold;width:23px;padding-top:4px;padding-bottom:4px; margin-top:1px;height:17px; text-align:center; font-size:14px; line-height:18px; float:left; background-color:##FFF;"></div>
				<div id="dnsExampleDiv" style="width:100%; float:left; padding-top:3px;">
				</div>
				</td>
			</tr>
			<tr>
				<th style="width:60px;">Comment</th>
				<td><cfscript>
				ts=StructNew();
				ts.name="dns_record_comment";
				ts.multiline=false;
				ts.size=70;
				ts.style="width:90% !important;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:60px;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qdns_record=0;
	var arrImages=0;
	var ts=0;
	var i=0;
	var rs=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	init();
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
		application.zcore.functions.zredirect('/member/');	
	}
	application.zcore.functions.zStatusHandler(request.zsid);

	db.sql="SELECT *
	FROM #db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone
	WHERE dns_zone_id = #db.param(form.dns_zone_id)# and 
	dns_zone_deleted = #db.param(0)# ";
	qZone=db.execute("qZone");

	db.sql="SELECT *
	FROM #db.table("dns_record", request.zos.zcoreDatasource)# dns_record 
	LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
	ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
	WHERE
	dns_record.dns_zone_id = #db.param(form.dns_zone_id)#  and 
	dns_record_deleted = #db.param(0)# 
	order by dns_record_host asc, dns_record_type asc, dns_record_value ASC";
	qRecords=db.execute("qdns_record");
	</cfscript>
	<p><a href="/z/server-manager/admin/dns-group/index">DNS Groups</a> / <a href="/z/server-manager/admin/dns-zone/index?dns_group_id=#form.dns_group_id#">#form.dns_group_name#</a> / #form.dns_zone_name#</p>
	<h2>Manage DNS Records</h2>
	<script>
	function openDNSModal(link){
		zShowModalStandard(link, Math.min(550, zWindowSize.width-50), Math.min(500, zWindowSize.height-50));
	}
	zArrDeferredFunctions.push(function(){
		$(".addButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var type=this.innerHTML;
			var link='/z/server-manager/admin/dns-record/add?dns_zone_id='+zoneId+'&dns_record_type='+type;
			openDNSModal(link);
			return false;
		});
		$(".editButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var recordId=this.getAttribute("data-dns-record-id");
			var link='/z/server-manager/admin/dns-record/edit?dns_zone_id='+zoneId+'&dns_record_id='+recordId;
			openDNSModal(link);
			return false;

		});
		$(".deleteButton").bind("click", function(){
			var zoneId=this.getAttribute("data-dns-zone-id");
			var recordId=this.getAttribute("data-dns-record-id");
			var link='/z/server-manager/admin/dns-record/delete?dns_zone_id='+zoneId+'&dns_record_id='+recordId;
			openDNSModal(link);
			return false;

		});
	});
	</script>
	<cfsavecontent variable="css">
	
	<style>
	.addButtonLabel{ display:block; float:left; padding:5px;font-weight:bold; margin-right:5px;}
	.addButton:link, .addButton:visited{ display:block; cursor:pointer;float:left; text-decoration:none; font-weight:bold; padding:5px; background-color:##EEE; border:1px solid ##CCC; margin-right:5px; color:##000;}
	.addButton:hover{background-color:##FFF;  color:##666;}
	##zModalOverlayDiv2{overflow:hidden;}
	</style>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("stylesheets", css);
	</cfscript>
	<div style="width:100%; float:left; padding-bottom:10px;">
		<div class="addButtonLabel">Add DNS Record:</div>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">A</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">AAAA</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">CNAME</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">MX</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">NS</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">SRV</a>
		<a href="##" class="addButton" data-dns-zone-id="#form.dns_zone_id#">TXT</a>
	</div>
	<table  class="table-list">
		<tr>
			<th>Record</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		i=1;
		for(record in qRecords){
			echo('<tr ');
			if(i MOD 2 EQ 0){
				echo('class="row2"');
			}else{
				echo('class="row1"');
			}
			echo('>
				<td>#formatDNSRecord(record)#</td>
				<td>
					<a href="##" class="editButton" data-dns-record-id="#record.dns_record_id#" data-dns-zone-id="#form.dns_zone_id#">Edit</a> | 
					<a href="##" class="deleteButton" data-dns-record-id="#record.dns_record_id#" data-dns-zone-id="#form.dns_zone_id#">Delete</a></td>
			</tr>');
			i++;
		}
		if(qZone.dns_zone_name NEQ "default"){
			db.sql="select * from 
			(#db.table("dns_record", request.zos.zcoreDatasource)# dns_record,
			#db.table("dns_zone", request.zos.zcoreDatasource)# dns_zone)
			LEFT JOIN #db.table("dns_ip", request.zos.zcoreDatasource)# dns_ip 
			ON dns_record.dns_ip_id = dns_ip.dns_ip_id 
			WHERE dns_zone.dns_zone_id= dns_record.dns_zone_id and 
			dns_zone.dns_group_id = #db.param(form.dns_group_id)# and 
			dns_zone.dns_zone_name = #db.param('default')# and 
			dns_zone_deleted = #db.param(0)# and 
			dns_record_deleted = #db.param(0)#   ";
			qDefaultRecords=db.execute("qDefaultRecords");
			if(qDefaultRecords.recordcount NEQ 0){
				arrDefault=[];
				for(record in qDefaultRecords){
					if(qZone["dns_zone_custom_"&record.dns_record_type] EQ 0){
						arrayAppend(arrDefault, '<tr ');
						if(i MOD 2 EQ 0){
							arrayAppend(arrDefault, 'class="row2"');
						}else{
							arrayAppend(arrDefault, 'class="row1"');
						}
						arrayAppend(arrDefault, '>
							<td>#formatDNSRecord(record)#</td>
							<td>&nbsp;</td>
						</tr>');
					}
					i++;
				}
				if(arrayLen(arrDefault)){
					echo('<tr>
						<td colspan="2">Records inherited from the <a href="/z/server-manager/admin/dns-record?dns_zone_id=#qDefaultRecords.dns_zone_id#">default zone</a>.  Add a record of the same type to override these values.</td>
					</tr>');
					echo(arrayToList(arrDefault, ""));
				}
			}
		}
		</cfscript>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
