<cfcomponent>
<cfoutput>
<cffunction name="extendSession" access="remote" localmode="modern">
	<cfscript>
	if(application.zcore.user.checkGroupAccess("user")){
		ts={success:true};
	}else{
		ts={success:false};
	}
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	if(not application.zcore.user.checkGroupAccess("user")){
		application.zcore.functions.zRedirect("/z/user/preference/index");
	} 
	form.redirectOnLogin=application.zcore.functions.zso(form, 'redirectOnLogin');
	if(form.redirectOnLogin NEQ "" and form.redirectOnLogin DOES NOT CONTAIN "redirectOnLogin"){
		application.zcore.functions.zRedirect(form.redirectOnLogin);
	}
	application.zcore.template.setTag("title","User Dashboard");
	application.zcore.template.setTag("pagetitle","User Dashboard");
	application.zcore.functions.zStatusHandler(request.zsid);

	ws=application.zcore.app.getWhitelabelStruct();
	</cfscript>
	<style>
	.zPublicDashboardButton:link, .zPublicDashboardButton:visited{ width:150px;text-decoration:none; color:##000;padding:1%;display:block; border:1px solid ##CCC; margin-right:2%; margin-bottom:2%; background-color:##F3F3F3; border-radius:10px; text-align:center; float:left; }
	.zPublicDashboardButton:hover{background-color:##FFF; border:1px solid ##666;display:block; color:##666;}
	.zPublicDashboardButtonImage{width:100%; height:64px; float:left;margin-bottom:5px;display:block;}
	.zPublicDashboardButtonTitle{width:100%; float:left;margin-bottom:5px; font-size:115%; display:block;font-weight:bold;}
	.zPublicDashboardButtonSummary{width:100%; float:left;}
	</style>
	<div style="margin-bottom:20px; width:100%; float:left;">#ws.whitelabel_public_dashboard_header_html#</div>
	<div style="margin-bottom:20px; width:100%; float:left;">
	
		<cfscript>
		if(application.zcore.app.siteHasApp("content")){
			ts=structnew();
			ts.content_unique_name='/z/user/home/index';
			ts.disableContentMeta=true; 
			ts.disableLinks=true;
			r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
			if(r1 EQ false){
				inquiryTextMissing=true;
			}else{
				inquiryTextMissing=false;	
			}
		}
		siteOptionCom=createobject("component", "zcorerootmapping.com.app.site-option");
		siteOptionCom.userDashboardAdmin();

		if(structkeyexists(application.siteStruct[request.zos.globals.id].zcoreCustomFunctions, 'memberDashboard')){
			echo(application.siteStruct[request.zos.globals.id].zcoreCustomFunctions.memberDashboard());
			//echo('<hr />');
		}
			// TODO: add stuff for listing / rentals here someday like saved searches, inquiries, etc.


		</cfscript>
			<cfscript> 
			if(structkeyexists(ws, 'arrPublicButton')){
				echo('<div style="width:100%; float:left;margin-top:20px;">');
				for(i=1;i LTE arraylen(ws.arrPublicButton);i++){
					bs=ws.arrPublicButton[i];
					if(bs.whitelabel_button_builtin EQ ""){
						link=bs.whitelabel_button_url;
					}else{
						link=bs.whitelabel_button_builtin;
					}
					echo('<a href="#link#" target="#bs.whitelabel_button_target#" class="zPublicDashboardButton"><span class="zPublicDashboardButtonImage">');
					if(bs.whitelabel_button_image64 NEQ ""){
						echo('<img src="#ws.imagePath&bs.whitelabel_button_image64#" alt="#htmleditformat(bs.whitelabel_button_label)#" />');
					}
					echo('</span><span class="zPublicDashboardButtonTitle">#bs.whitelabel_button_label#</span>
						<span class="zPublicDashboardButtonSummary">#bs.whitelabel_button_summary#</span></a>');

				}
				echo('</div>');
			}
			</cfscript>
		<hr />
		<div class="zUserDashboardDefaultLinks">
		<ul style="line-height:150%; font-size:120%;">
		<cfif application.zcore.user.checkGroupAccess("member")>
			<li><a href="/z/admin/admin-home/index">Site Manager</a></li>
		</cfif>
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserTicketLogin', true, 0) EQ 1>
			<li><a href="/z/inquiries/admin/manage-user-inquiries/userIndex">Ticket Manager</a></li>
		</cfif>
		<cfscript>
		hasUserManagerAccess=false;
		if(request.zsession.user.site_id EQ request.zos.globals.id){ 
			db.sql="select * from #db.table("user_group", request.zos.zcoreDatasource)# WHERE 
			user_group_id=#db.param(request.zsession.user.group_id)# and 
			user_group_deleted=#db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)# ";
			qGroup=db.execute("qGroup");   
			if(qGroup.recordcount EQ 0){
				throw("Invalid user group id for user: #request.zsession.user.id# group id: #request.zsession.user.group_id#");
			}
			if(qGroup.user_group_manage_full_subuser_group_id_list NEQ "" or qGroup.user_group_manage_partial_subuser_group_id_list NEQ ""){
				hasUserManagerAccess=true;
			}
		}
		</cfscript>
		<cfif hasUserManagerAccess>
			<li><a href="/z/user/user-manage/index">Manage Users</a></li>
		</cfif>
		<li class="zUserDashboardEditProfileLink"><a  href="/z/user/preference/form">Edit Profile</a></li>
		<cfif application.zcore.app.siteHasApp("listing")>
			<li><a href="/z/listing/property/your-saved-searches">Your Saved Searches</a></li>
			<li><a href="/z/listing/sl/view">Your Saved Listings</a></li>
		</cfif>
		<li><a href="/z/user/preference/index?zlogout=1">Logout</a></li>
		</ul>
		</div>
	</div>
	<div style="margin-top:20px; width:100%; float:left;">#ws.whitelabel_public_dashboard_footer_html#</div>
</cffunction>
</cfoutput>
</cfcomponent>