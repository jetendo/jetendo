<cfcomponent>
<cfoutput>
<cffunction name="status" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	echo("<h2>Let's Renew Status</h2>");
	echo(application.zcore.functions.zso(application, 'letsRenewRenewStatus'));

	echo('<br><br><a href="/z/server-manager/tasks/renew-lets-encrypt-ssl/cancelRenew" target="_blank">Cancel</a>');
	</cfscript>
</cffunction>

<cffunction name="cancelRenew" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	
	application.cancelLetsRenewRenew=true;
	echo("Cancelling renew");
	abort;
	</cfscript>
</cffunction>

<!--- /z/server-manager/tasks/renew-lets-encrypt-ssl/index --->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="5000";
	form.sid=application.zcore.functions.zso(form, 'sid', true);
	request.ignoreSlowScript=true;

	futureDate=dateadd("d", 35, now());
	// for quickly debugging forced renewal
	if(structkeyexists(form, 'forceRenewAll')){
		futureDate=dateadd("d", 91, now());
		throw("disabled for now, but this works if you uncomment this throw");
	}
	futureDate=dateformat(futureDate, "yyyy-mm-dd")&" "&timeformat(futureDate, "HH:mm:ss");
	reloadNginx=false;
	db.sql="select * from 
	#db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("ssl", request.zos.zcoreDatasource)# 
	where ssl.site_id=site.site_id and
	ssl_active=#db.param('1')# and 
	site.site_active=#db.param('1')# and 
	site_deleted=#db.param('0')# and 
	ssl_letsencrypt=#db.param(1)# AND 
	ssl_expiration_datetime >=#db.param(request.zos.mysqlnow)# and
	ssl_expiration_datetime <=#db.param(futureDate)# and
	ssl_deleted=#db.param('0')# ";
	if(form.sid NEQ 0){
		db.sql&=" and site.site_id = #db.param(form.sid)# ";
	}
	db.sql&=" ORDER BY ssl_expiration_datetime ASC ";
	qSSL=db.execute("qSSL");

	//writedump(qSSL);	abort;
	// run query
	// loop sites
	renewCount=0;
	arrRenew=[];
	 try{
		for(row in qSSL){   
			if(structkeyexists(application, 'cancelLetsRenewRenew')){
				structdelete(application, 'letsRenewRenewStatus');
				structdelete(application, 'cancelLetsRenewRenew');
				echo("Cancelled");
				abort;
			}
			application.letsRenewRenewStatus="Publishing Nginx Site Config Before New Certificate | Renewing "&row.ssl_common_name;
			
			result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&row.site_id, 30); 
			if(result EQ ""){
				throw("Unknown failure when publishing Nginx configuration");
			}else{
				js=deserializeJson(result);
				if(not js.success){
					throw("Nginx site config publish failed: "&js.errorMessage);
				}
			}

			resultStruct={};
			js={};
			ts={};
			result="";
			row.ssl_domain_list=replace(replace(replace(replace(row.ssl_domain_list, "/", "", "all"), "\", "", "all"), chr(10), ",", "all"), chr(13), "", "all");

			if(row.ssl_domain_list EQ "" or row.ssl_common_name EQ "" or row.site_short_domain EQ "" or row.ssl_hash EQ ""){
				throw("Invalid ssl configuration for this record:; SELECT * FROM ssl WHERE ssl_id=#row.ssl_id# and site_id=#row.site_id#;");
			}
			js={
				domainList:row.ssl_domain_list,
				shortDomain:row.site_short_domain,
				commonName:row.ssl_common_name,
				ssl_hash:row.ssl_hash,
				site_id:row.site_id
			}

			if(left(js.shortDomain, 4) EQ "www."){
				js.shortDomain=removeChars(js.shortDomain, 1, 4);
			}   
			jsonOutput=serializeJson(js); 
			
			echo("Renewing #row.ssl_common_name# | SAN Domain List: #row.ssl_domain_list#<br>");
	 
			application.letsRenewRenewStatus="Running sslInstallLetsEncryptCertificate | Renewing "&row.ssl_common_name;
			result=application.zcore.functions.zSecureCommand("sslInstallLetsEncryptCertificate"&chr(9)&jsonOutput, 60);
			if(result EQ ""){
				throw("Install Lets Encrypt Secure Certificate command failed: #row.ssl_hash#");
			}else{
				resultStruct=deserializeJson(result); 
				if(request.zos.isTestServer and resultStruct.ssl_public_key EQ "public_key_test"){
					savecontent variable="out"{
						if(structkeyexists(resultStruct, 'output') and isArray(resultStruct.output)){
							arrayToList(resultStruct.output, "<hr>");
						}
						writedump(js);
						writedump(resultStruct);
					}
					throw("Auto-renew Lets Encrypt Secure Certificate Can't Be Run on the Test Environment. Debugging info for testing purposes: "&out);
				}
				if(not resultStruct.success){
					savecontent variable="out"{
						echo('<h2>Auto-renew Lets Encrypt Secure Certificate Failed:</h2>');
						echo("Renewing #row.ssl_common_name# | SAN Domain List: #row.ssl_domain_list#<br>");
						if(structkeyexists(resultStruct, 'output') and isArray(resultStruct.output)){
							arrayToList(resultStruct.output, "<hr>");
						}
						writedump(resultStruct);
					} 
					ts={
						type:"Custom",
						errorHTML:out,
						scriptName:'/z/server-manager/tasks/renew-lets-encrypt-ssl',
						url:request.zos.globals.domain&request.zos.originalURL,
						exceptionMessage:"Domain failed authentication for secure certificate",
						// optional
						lineNumber:'1'
					}
					application.zcore.functions.zLogError(ts);
					sleep(5000);
					continue;
				}
				d=resultStruct.ssl_expiration_datetime;
				form.ssl_expiration_datetime=createdatetime(d.year, d.month, d.day, d.hour, d.minute, d.second);
				form.ssl_expiration_datetime=dateformat(form.ssl_expiration_datetime, "yyyy-mm-dd")&" "&timeformat(form.ssl_expiration_datetime, "HH:mm:ss");
				nowDate=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
				ts={
					table:"ssl",
					datasource:request.zos.zcoreDatasource,
					struct:{
						ssl_display_name:row.site_short_domain&"-"&dateformat(now(), "yyyy-mm-dd"),
						ssl_public_key:resultStruct.ssl_public_key,
						ssl_intermediate_certificate:resultStruct.ssl_intermediate_certificate,
						ssl_ca_certificate:resultStruct.ssl_ca_certificate,
						ssl_csr:resultStruct.ssl_csr,
						ssl_private_key:resultStruct.ssl_private_key,
						ssl_active:1,
						ssl_common_name:resultStruct.csrData.cn,
						ssl_email:resultStruct.ssl_email,
						ssl_id:row.ssl_id,
						site_id:row.site_id,
						ssl_deleted:0,
						ssl_updated_datetime:nowDate,
						ssl_expiration_datetime:form.ssl_expiration_datetime
					}
				} 
				arrayAppend(arrRenew, row.ssl_common_name&" Let's Encrypt secure certificate renewed");
				renewCount++;
				application.zcore.functions.zUpdate(ts);
				
				application.letsRenewRenewStatus="Publishing Nginx Site Config After New Certificate | Renewing "&row.ssl_common_name;

				result=application.zcore.functions.zSecureCommand("publishNginxSiteConfig"&chr(9)&row.site_id, 30); 
				if(result EQ ""){
					throw("Unknown failure when publishing Nginx configuration");
				}else{
					js=deserializeJson(result);
					if(not js.success){
						throw("Nginx site config publish failed: "&js.errorMessage);
					}
				}
			}  
			sleep(5000);
		} 
	}catch(Any e){

		application.letsRenewRenewStatus="On Last Run: Renew process had errors.";
		savecontent variable="out"{
			echo('<h2>Original Error Thrown</h2>');
			writedump(e);
			echo('<h2>Input to sslInstallLetsEncryptCertificate</h2>');
			writedump(js);
			echo('<h2>sslInstallLetsEncryptCertificate resultStruct</h2>');
			writedump(resultStruct);
			echo('<h2>Update SSL record input</h2>');
			writedump(ts);
			echo('<h2>Nginx publish site config result</h2>');
			writedump(result);
		}
		throw(out); 
	}
	if(renewCount NEQ 0){
		ts={
			from:request.zos.developerEmailFrom,
			to:request.zos.developerEmailTo,
			subject:"LetsEncrypt.org Certificate(s) Renewed",
			text:"The following certificates were renewed"&chr(10)&chr(10)&arrayToList(arrRenew, chr(10))
		};
		application.zcore.email.send(ts);
	}

	application.letsRenewRenewStatus="On Last Run: Renewed #renewCount# LetsEncrypt.org Certificates<br><br>"&arrayToList(arrRenew, "<br>");
	echo("Renewed #renewCount# LetsEncrypt.org Certificates<br><br>"&arrayToList(arrRenew, "<br>"));
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>