<cfcomponent>
<cfoutput>
<cffunction name="spellCheck" localmode="modern" access="remote" roles="member">
	<cfscript>
	</cfscript>
	<div style="max-width:992px;float:left; font-size:18px; line-height:30px;"> 
	<h1>Add advanced spell checking &amp; grammar support</h1>
	<p>Your web site is often the first impression your visitors have with your company.  Not all of us are blessed with perfect spelling and grammar as we work throughout the day.  That's why using tools to help support you is important.</p>
	<p>The text fields throughout the web site manager now support your browser's native spell checking if it is available & enabled.  However, if you want something more robust, we have found a better solution.</p>
	<p>We are recommending you install the free browser extension "<strong>Grammarly Lite</strong>" to have a spell check and grammar correction tool that works anywhere you manage content on the web.</p>
	<h2 style="font-size:24px; line-height:30px;">You can install Grammarly Lite for <a href="http://www.grammarly.com/download/chrome" target="_blank">Chrome</a>, 
	<a href="http://www.grammarly.com/download/firefox" target="_blank">Firefox</a> or
	<a href="http://www.grammarly.com/download/safari">Safari</a>.</h2>
	<p>Grammarly Lite is free software enjoyed by over 3 million people across the world.  It shouldn't cause annoying ads or additional costs for you over time for its free features.</p>
	<p>Grammarly Lite is not available for Internet Explorer.  It is highly recommended you install <a href="http://www.google.com/chrome/‎" target="_blank">Chrome</a> or 
	<a href="http://www.firefox.com/" target="_blank">Firefox</a> when managing your web site as these browsers are better supported and provide superior features.</p>
	<p>If you have trouble with any of these links, let your web developer know.</p>
	<h2 style="font-size:24px; line-height:30px;">Want the most advanced plagiarism and proofreading tool?<br />
	<a href="#request.zos.grammarlyTrackingURL#" target="_blank">Upgrade to Grammarly Pro</a></h2>
	<ul>
	<li>Grammarly Pro features grammar, punctuation and style correction features that can catch more errors then Microsoft&reg; Word and other word processors.</li>
	<li>You can purchase an individual subscription for grammarly and it works pretty much anywhere you write in text boxes throughout the web.</li>
	<li>Learn to write better English on your other online accounts such as webmail, Facebook, Twitter.</li>
	 <li>Avoid plagiarism and choose better words via the thesaurus features.</li>
	 </ul>
	<p>Interested in Grammarly Pro? Signup for the 7 day free trial at <a href="#request.zos.grammarlyTrackingURL#" target="_blank">http://www.grammarly.com/</a> to help you decide if it is worth the price to improve the professionalism of your communications.</p> 
	</div>
</cffunction>


	

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("1");
	application.zcore.functions.zstatushandler(request.zsid);

	ws=application.zcore.app.getWhitelabelStruct();
	</cfscript>
	<div class="zDashboardContainerPad">
		<div class="zDashboardContainer"> 
			<h2>First time user?</h2>
			<p><a href="/z/admin/help/quickStart" class="z-manager-search-button">Quick Start Guide</a> <a href="/z/admin/video-training/index" class="z-manager-search-button">Video Training</a></p>

			<cfscript>
			
			if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
				ms={};
				ms=application.zcore.siteOptionCom.getAdminLinks(ms);
				ms=application.zcore.featureCom.getAdminLinks(ms);
				count=0;
				savecontent variable="out"{ 
					linkStruct={};
					for(key in ms){
						if(structkeyexists(ms[key], 'children')){
							links=ms[key].children;
							for(key2 in links){
								link=links[key2]; 
								if(application.zcore.adminSecurityFilter.checkFeatureAccess(link.featureName)){
									linkStruct[count]=link;
									count++;
								}
							}
						}
					}
					arrSort=structsort(linkStruct, "text", "asc", "featureName");
					for(key in arrSort){
						link=linkStruct[key];
						echo('<a href="#link.link#" class="z-button z-manager-search-button">#replace(link.featureName, "Custom:", "")#</a>');
					}
				}
				if(count){
					echo('<h2>Custom Features</h2>
					<p>In addition to our software''s built-in features, your web site also has these custom-made editing features.</p>');
					echo('<div class="z-float z-t-16">'&out&'</div>');
				}
			}
			</cfscript>

			<cfif ws.whitelabel_dashboard_header_html NEQ "">
				<div class="zDashboardHeader">
					#ws.whitelabel_dashboard_header_html#
				</div>
			</cfif>
			
			<div class="zDashboardMainContainer">
				<div class="zDashboardMain z-equal-heights">
					<cfscript> 
					if(structkeyexists(ws, 'arrAdminButton')){
						for(i=1;i LTE arraylen(ws.arrAdminButton);i++){
							bs=ws.arrAdminButton[i];
							if(bs.whitelabel_button_builtin EQ ""){
								link=bs.whitelabel_button_url;
							}else{
								link=bs.whitelabel_button_builtin;
							}
							echo('<a href="#link#" target="#bs.whitelabel_button_target#" class="zDashboardButton">');
							if(bs.whitelabel_button_image64 NEQ ""){
								echo('<span class="zDashboardButtonImage"><img src="#ws.imagePath&bs.whitelabel_button_image64#" alt="#htmleditformat(bs.whitelabel_button_label)#" /></span>');
							}
							echo('<span class="zDashboardButtonTitle">#bs.whitelabel_button_label#</span>');
							if(bs.whitelabel_button_summary NEQ ''){
								echo('<span class="zDashboardButtonSummary">#bs.whitelabel_button_summary#</span>');
							}
							echo('</a>');

						}
					}
					</cfscript>
				</div>
				<cfif ws.whitelabel_dashboard_sidebar_html NEQ "">
					<div class="zDashboardSidebar">
						#ws.whitelabel_dashboard_sidebar_html#
					</div>
				</cfif>
			</div>

			<div style="width:100%; float:left; margin-top:10px;">
				<div style="width:45%; padding-right:5%; float:left;">
				<cfscript>
				sevenDaysAgo=dateadd("d", -7, now());
				thirtyDaysAgo=dateadd("d", -30, now());
				oneYearAgo=dateadd("yyyy", -1, now());
				db.sql="select count(inquiries_id) c from #db.table("inquiries", request.zos.zcoreDatasource)# 
				WHERE inquiries_datetime>=#db.param(dateformat(sevenDaysAgo, "yyyy-mm-dd")&" "&timeformat(sevenDaysAgo, "HH:mm:ss"))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				inquiries_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<h2>Form lead summary</h2>');
				echo('<p>'&qInquiry1.c&" leads in the last 7 days</p>");

				db.sql="select count(inquiries_id) c from #db.table("inquiries", request.zos.zcoreDatasource)# 
				WHERE inquiries_datetime>=#db.param(dateformat(thirtyDaysAgo, "yyyy-mm-dd")&" "&timeformat(thirtyDaysAgo, "HH:mm:ss"))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				inquiries_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<p>'&qInquiry1.c&" leads in the last 30 days</p>");

				db.sql="select count(inquiries_id) c from #db.table("inquiries", request.zos.zcoreDatasource)# 
				WHERE inquiries_datetime>=#db.param(dateformat(oneYearAgo, "yyyy-mm-dd")&" "&timeformat(oneYearAgo, "HH:mm:ss"))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				inquiries_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<p>'&qInquiry1.c&" leads in the last year</p>");
				echo('<p><a href="#request.zos.currentHostName#/z/inquiries/admin/manage-inquiries/index" class="z-manager-search-button">Manage leads</a></p>');

				echo('</div><div style="width:45%; padding-right:5%; float:left;">');

				sevenDaysAgo=dateadd("d", -7, now());
				thirtyDaysAgo=dateadd("d", -30, now());
				oneYearAgo=dateadd("yyyy", -1, now());
				db.sql="select count(contact_id) c from #db.table("contact", request.zos.zcoreDatasource)# 
				WHERE contact_datetime>=#db.param(dateformat(sevenDaysAgo, "yyyy-mm-dd")&" "&timeformat(sevenDaysAgo, "HH:mm:ss"))# and 
				contact_opt_in = #db.param(1)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				contact_parent_id=#db.param(0)# and 
				contact_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<h2>Mailing list activity</h2>');
				echo('<p>'&qInquiry1.c&" new subscribers in the last 7 days</p>");

				db.sql="select count(contact_id) c from #db.table("contact", request.zos.zcoreDatasource)# 
				WHERE contact_datetime>=#db.param(dateformat(thirtyDaysAgo, "yyyy-mm-dd")&" "&timeformat(thirtyDaysAgo, "HH:mm:ss"))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				contact_parent_id=#db.param(0)# and 
				contact_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<p>'&qInquiry1.c&" new subscribers in the last 30 days</p>");

				db.sql="select count(contact_id) c from #db.table("contact", request.zos.zcoreDatasource)# 
				WHERE contact_datetime>=#db.param(dateformat(oneYearAgo, "yyyy-mm-dd")&" "&timeformat(oneYearAgo, "HH:mm:ss"))# and 
				site_id = #db.param(request.zos.globals.id)# and 
				contact_parent_id=#db.param(0)# and 
				contact_deleted=#db.param(0)#";
				qInquiry1=db.execute("qInquiry1");
				echo('<p>'&qInquiry1.c&" total subscribers</p>");
				echo('<p><a href="#request.zos.currentHostName#/z/admin/mailing-list-export/index" class="z-manager-search-button">Export</a></p>');
				</cfscript>
				</div>
			</div>
 
			<cfif ws.whitelabel_dashboard_footer_html NEQ "">
				<div class="zDashboardFooter">
					#ws.whitelabel_dashboard_footer_html#
				</div>
			</cfif>
		</div>
	</div>
</cffunction>
</cfoutput>
</cfcomponent>