<cfcomponent>
<cfoutput>
<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="10000";
	request.ignoreSlowScript=true;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	application.zcore.functions.zSendMailUserAutoresponder();
	application.zcore.functions.zSendUserAutoresponder();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	request.ignoreSlowScript=true;
	setting requesttimeout="10000"; 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted = #db.param(0)# and 
	site_send_confirm_opt_in = #db.param(1)#";
	qSite=db.execute("qSite"); 
	for(row in qSite){
		link=row.site_domain&"/z/server-manager/tasks/resend-autoresponders/send";
		rs=application.zcore.functions.zdownloadlink(link, 1000, true);
		if(not rs.success){
			savecontent variable="out"{
				echo('Failed to complete http request: #link#');
				writedump(rs);
			}
			throw(out);
		}
	}
	</cfscript>
	done
</cffunction>
</cfoutput>
</cfcomponent>