<cfcomponent>
<!--- 
route by rental category
route by property info in the long inquiry form or the info in the inquiry POP
route by inquiry type
route future leads only
stop routing.
send a copy to (for each type)
in the future, i'll let them associate "content" and "rental" listings to an office id, so that leads to those leads go to the right office.   also match mls listings with the user so that those auto-assign direct to the listing agent.
TODO: zFindLeadRouteForInquiryId fails if search_mls EQ 1 and listing goes inactive, need to use listing_saved table and see why view inquiry does use listing_saved as well on carlos ring test site leads...
route by property type, cities or possibly entire Saved Search.
group agents by offices.   assign leads to an office based on location or zip codes and then allow separate routing per office.
enable round robin for users - need a new option to disable for staff.
 --->
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var hCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Routing");
	variables.queueSortStruct = StructNew();
	variables.queueSortStruct.tableName = "inquiries_routing";
	variables.queueSortStruct.sortFieldName = "inquiries_routing_sort";
	variables.queueSortStruct.primaryKeyName = "inquiries_routing_id";
	variables.queueSortStruct.where="site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and inquiries_routing_deleted='0' ";
	variables.queueSortStruct.datasource=request.zos.zcoreDatasource;
	variables.queueSortStruct.disableRedirect=true;
	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/inquiries/admin/routing/index';
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	if(structkeyexists(form, 'zQueueSort')){
		application.sitestruct[request.zos.globals.id].leadRoutingStruct=application.zcore.functions.zGetLeadRoutesStruct();	
		application.zcore.functions.zredirect("/z/inquiries/admin/routing/index?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
	}
	if(structkeyexists(form, 'zQueueSortAjax')){
		application.sitestruct[request.zos.globals.id].leadRoutingStruct=application.zcore.functions.zGetLeadRoutesStruct();	
		variables.queueSortCom.returnJson();
	}
	hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	variables.init();
	db.sql="SELECT * from #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing
	WHERE inquiries_routing_id = #db.param(form.inquiries_routing_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	inquiries_routing_deleted=#db.param(0)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Lead route no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/routing/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(application.zcore.app.siteHasApp("listing")){
			request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qcheck.mls_saved_search_id);
		} 
		db.sql="DELETE from #db.table("inquiries_routing", request.zos.zcoreDatasource)#  
		WHERE inquiries_routing_id = #db.param(form.inquiries_routing_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		inquiries_routing_deleted=#db.param(0)#  ";
		q=db.execute("q");
		variables.queueSortCom.sortAll();
		application.sitestruct[request.zos.globals.id].leadRoutingStruct=application.zcore.functions.zGetLeadRoutesStruct();	
		application.zcore.status.setStatus(Request.zsid, 'Lead route deleted');
		application.zcore.functions.zRedirect('/z/inquiries/admin/routing/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this lead route?<br />
			<br />
			<a href="/z/inquiries/admin/routing/delete?confirm=1&amp;inquiries_routing_id=#form.inquiries_routing_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/routing/index">No</a> </div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var qId=0;
	variables.init();
	form.site_id = request.zos.globals.id;
	if(form.inquiries_type_id CONTAINS "|"){
		form.inquiries_type_id_siteIDType=listgetat(form.inquiries_type_id,2,"|");
		form.inquiries_type_id=listgetat(form.inquiries_type_id,1,"|");
	}
	if(form.inquiries_routing_type_id EQ "2"){
		if(form.inquiries_routing_assign_to_user_id CONTAINS "|"){
			form.user_id_siteIDType=listgetat(form.inquiries_routing_assign_to_user_id,2,"|");
			form.inquiries_routing_assign_to_user_id=listgetat(form.inquiries_routing_assign_to_user_id,1,"|");
		}
	}
	if(application.zcore.app.siteHasApp("listing")){
		if(form.method NEQ 'insert') { 
			db.sql="SELECT mls_saved_search_id from #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing 
			WHERE inquiries_routing_id = #db.param(form.inquiries_routing_id)# and 
			site_id=#db.param(request.zOS.globals.id)#";
			qId=db.execute("qId");
			form.mls_saved_search_id=qid.mls_saved_search_id;
		}else{
			form.mls_saved_search_id="";
		}
		if(application.zcore.functions.zso(form, 'inquiries_routing_search_mls',false,0) and form.inquiries_routing_search_mls EQ 1) {
			form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, '', form);
		} else {
			form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.mls_saved_search_id);
		}
	}
	ts=StructNew();
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table='inquiries_routing';
	if(form.method EQ 'insert'){
		form.inquiries_routing_id = application.zcore.functions.zInsert(ts);
		if(form.inquiries_routing_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Lead routing rule is not unique. Please cancel and edit the existing rule for this lead type.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/routing/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Lead routing saved.');
		}
		
		variables.queueSortCom.sortAll();
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Lead routing failed to save.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/routing/edit?inquiries_routing_id=#form.inquiries_routing_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Lead routing saved.');
		}
		
	}
	application.sitestruct[request.zos.globals.id].leadRoutingStruct=application.zcore.functions.zGetLeadRoutesStruct();	
	application.zcore.functions.zRedirect('/z/inquiries/admin/routing/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var qAgents=0;
	var userGroupCom=0;
	var htmlEditor=0;
	var qType=0;
	var currentMethod=form.method;
	var qRoute=0;
	variables.init();
	if(application.zcore.functions.zso(form, 'inquiries_routing_id') EQ ''){
		form.inquiries_routing_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing 
	WHERE site_id =#db.param(request.zOS.globals.id)# and 
	inquiries_routing_id= #db.param(form.inquiries_routing_id)# and 
	inquiries_routing_deleted=#db.param(0)# ";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>Lead Routing Options</h2>
	<p>When typing E-Mail Address, you can separate multiple addresses with a comma. When entering in hours, you can specify a decimal such as 0.5 for 30 minutes.</p>
	<form class="zFormCheckDirty" action="/z/inquiries/admin/routing/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_routing_id=#form.inquiries_routing_id#" method="post">
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:1%;">Lead Type</th>
				<td><cfsavecontent variable="db.sql"> 
					SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("site_id"))# siteIDType 
					from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
					WHERE site_id IN (#db.param(0)#,#db.param(request.zOS.globals.id)#) and 
					inquiries_type_deleted = #db.param(0)#
					<cfif not application.zcore.app.siteHasApp("listing")>
						and inquiries_type_realestate = #db.param(0)#
					</cfif>
					<cfif not application.zcore.app.siteHasApp("rental")>
						and inquiries_type_rentals = #db.param(0)#
					</cfif>
					ORDER BY inquiries_type_name </cfsavecontent>
					<cfscript>
					qType=db.execute("qType");
					form.inquiries_type_id=form.inquiries_type_id&"|"&form.inquiries_type_id_siteIDType;
					selectStruct = StructNew();
					selectStruct.name = "inquiries_type_id";
					selectStruct.query=qType;
					selectStruct.queryParseValueVars=true;
					selectStruct.queryLabelField="inquiries_type_name";
					selectStruct.queryValueField="##inquiries_type_id##|##siteIdType##";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					(Optionally limit routing to just one lead type) </td>
			</tr>
			<!--- <tr>
				<th style="width:1%;">Enable<br />Autoresponder</th>
					<td><input type="radio" style="border:none; background:none;"  name="inquiries_routing_autoresponder_enabled"  value="1" <cfif form.inquiries_routing_autoresponder_enabled EQ '1'>checked="checked"</cfif>> yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" style="border:none; background:none;"  name="inquiries_routing_autoresponder_enabled" value="0" <cfif form.inquiries_routing_autoresponder_enabled EQ '0' or form.inquiries_routing_autoresponder_enabled EQ ''>checked="checked"</cfif>> no</td>
					</tr>
					
					<tr>
					<th style="width:1%;">Autoresponder<br /> HTML</th>
					<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_routing_autoresponder_html";
					htmlEditor.value			= form.inquiries_routing_autoresponder_html;
					htmlEditor.basePath		= '/';
					htmlEditor.width			= 640;
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript></td>
					</tr>
					<tr>
					<th style="width:1%;">Autoresponder<br />Plain Text</th>
					<td><textarea name="inquiries_routing_autoresponder_text" style="width:640px; height:200px;">#form.inquiries_routing_autoresponder_text#</textarea>
					</td>
				</tr> --->
			<cfscript>
			userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
			db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("site_id"))# siteIdType
			FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
			user_server_administrator=#db.param(0)# and 
			user_deleted = #db.param(0)#
			ORDER BY member_first_name ASC, member_last_name ASC ";
			qAgents=db.execute("qAgents", "", 10000, "query", false);
		    </cfscript>
			<script>
			/* <![CDATA[ */
			function disableBothAssign(num){
				var d1=document.getElementById("inquiries_routing_assign_to_email");
				d1.value="1";
				disableMemberAssign(d1);
				d1.value="";
				var d3=document.getElementById("inquiries_routing_type_id"+num);
				d3.checked=true;
			}
			function disableMemberAssign(n){
				if(n.value != ""){
					var d1=document.getElementById("inquiries_routing_assign_to_user_id");
					d1.selectedIndex=0;
					showAgentPhoto('');
					var d3=document.getElementById("inquiries_routing_type_id3");
					d3.checked=true;
				}
				
			}
			function showAgentPhoto(id){
				var d1=document.getElementById("agentPhotoDiv");
				if(id!="" && arrAgentPhoto[id]!=""){
					id=id.split("|")[0];
					d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
				}else{
					d1.innerHTML="";	
				}
				var d3=document.getElementById("inquiries_routing_assign_to_user_id");
				if(d3.selectedIndex==0) return;
				var d4=document.getElementById("inquiries_routing_assign_to_email");
				d4.value="";
				var d2=document.getElementById("inquiries_routing_type_id2");
				d2.checked=true;
			}
			
			
			function disableBothAssign2(num){
				var d1=document.getElementById("inquiries_routing_reassignment_to_email");
				d1.value="1";
				disableMemberAssign2(d1);
				d1.value="";
				var d3=document.getElementById("inquiries_routing_reassignment_type_id"+num);
				d3.checked=true;
			}
			function disableMemberAssign2(n){
				if(n.value != ""){
					var d1=document.getElementById("inquiries_routing_reassignment_to_user_id");
					d1.selectedIndex=0;
					showAgentPhoto2('');
					var d3=document.getElementById("inquiries_routing_reassignment_type_id3");
					d3.checked=true;
				}
				
			}
			function showAgentPhoto2(id){
				var d1=document.getElementById("agentPhotoDiv2");
				if(id!="" && arrAgentPhoto[id]!=""){
					d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
				}else{
					d1.innerHTML="";	
				}
				var d3=document.getElementById("inquiries_routing_reassignment_to_user_id");
				if(d3.selectedIndex==0) return;
				var d4=document.getElementById("inquiries_routing_reassignment_to_email");
				d4.value="";
				var d2=document.getElementById("inquiries_routing_reassignment_type_id2");
				d2.checked=true;
			}
			
			var arrAgentPhoto=new Array();
			<cfloop query="qAgents">
			arrAgentPhoto["#qAgents.user_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
			</cfloop>
			/* ]]> */
			</script>
			<tr>
				<th style="width:1%;">Routing Type</th>
				<td><table style="border-spacing:0px;">
						<tr>
							<td><input type="radio" name="inquiries_routing_type_id" id="inquiries_routing_type_id0" onclick="disableBothAssign(0);" value="0" <cfif form.inquiries_routing_type_id EQ 0 or form.inquiries_routing_type_id EQ "">checked="checked"</cfif> />
								Assign To Default Office Email (
								<cfif application.zcore.functions.zvarso('zofficeemail') EQ "">
									#request.zos.developeremailto#
									<cfelse>
									#application.zcore.functions.zvarso('zofficeemail')#
								</cfif>
								)&nbsp; <a href="/z/admin/site-options/index?jumptoanchor=soid_29" target="_blank">Click here to edit</a>&nbsp;</td>
						</tr>
						<!--- <tr>
						<td><input type="radio" name="inquiries_routing_type_id" id="inquiries_routing_type_id1" onclick="disableBothAssign(1);" value="1" <cfif form.inquiries_routing_type_id EQ 1>checked="checked"</cfif> /> Round Robin&nbsp; </td>
						</tr> --->
						<tr>
							<td><input type="radio" name="inquiries_routing_type_id" id="inquiries_routing_type_id2" value="2" <cfif form.inquiries_routing_type_id EQ 2>checked="checked"</cfif> />
								Assign To User&nbsp;<br />
								<div style="float:left; padding-left:5%;padding-top:10px;">
						           <div style="float:left; width:90px;">Search Users:</div> <input type="text" name="assignInputField" id="assignInputField" value="" style="width:240px; min-width:auto; max-width:auto; margin-bottom:5px;"><br />
									<div style="float:left; width:90px;">Select One:</div><br />
									<cfscript>
									form.inquiries_routing_assign_to_user_id=form.inquiries_routing_assign_to_user_id&"|"&form.user_id_siteIDType;
									selectStruct = StructNew();
									selectStruct.name = "inquiries_routing_assign_to_user_id";
									selectStruct.query = qAgents;
									selectStruct.size=5;
									selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
									selectStruct.onchange="showAgentPhoto(this.options[this.selectedIndex].value);";
									selectStruct.queryParseLabelVars = true;
									selectStruct.queryParseValueVars = true;
									selectStruct.queryValueField = '##user_id##|##siteIdType##';
									application.zcore.functions.zInputSelectBox(selectStruct);
	       							application.zcore.skin.addDeferredScript("  $('##inquiries_routing_assign_to_user_id').filterByText($('##assignInputField'), true); ");
									</cfscript>
									<br />
									<div id="agentPhotoDiv"></div>
								</div>
							</td>
						</tr>
						<tr>
							<td><input type="radio" name="inquiries_routing_type_id" id="inquiries_routing_type_id3" value="3" <cfif form.inquiries_routing_type_id EQ 3>checked="checked"</cfif> />
								Assign To Email Address(es)&nbsp;
								<input type="text" name="inquiries_routing_assign_to_email" id="inquiries_routing_assign_to_email" size="50" value="#htmleditformat(form.inquiries_routing_assign_to_email)#" onkeyup="disableMemberAssign(this);" /></td>
						</tr>
					</table>
					<script>
					/* <![CDATA[ */
					zArrDeferredFunctions.push(function(){
						d1=document.getElementById("inquiries_routing_assign_to_user_id");
						if(typeof d1.options != "undefined" && d1.selectedIndex != -1){ 
							showAgentPhoto(d1.options[d1.selectedIndex].value);
						}
					});
					/* ]]> */
					</script></td>
			</tr>
			<!--- <tr>
				<th style="width:1%;">User<br /> Auto-assign</th>
					<td>
					<p>If enabled, this will override the other options. Leads that match listings that are associated with a specific user to auto-assign to that user.<br /><input type="radio" style="border:none; background:none;"  name="inquiries_routing_member_auto_assign"  value="1" <cfif form.inquiries_routing_member_auto_assign EQ '1'>checked="checked"</cfif>> yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" style="border:none; background:none;"  name="inquiries_routing_member_auto_assign" value="0" <cfif form.inquiries_routing_member_auto_assign EQ '0' or form.inquiries_routing_member_auto_assign EQ ''>checked="checked"</cfif>> no</p></td>
						</tr>
						<tr>
						<th style="width:1%;">Office<br /> Auto-assign</th>
					<td>
					<p>If enabled, this will override the other options. Leads that match an office will limit the assignment system to only use users in that office.<br /><input type="radio" style="border:none; background:none;"  name="inquiries_routing_office_auto_assign"  value="1" <cfif form.inquiries_routing_office_auto_assign EQ '1'>checked="checked"</cfif>> yes&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" style="border:none; background:none;"  name="inquiries_routing_office_auto_assign" value="0" <cfif form.inquiries_routing_office_auto_assign EQ '0' or form.inquiries_routing_office_auto_assign EQ ''>checked="checked"</cfif>> no</p></td>
				</tr> --->
			<tr>
				<th style="width:1%;">Send BCC To&nbsp;</th>
				<td><p>On initial receipt, send blind copy to E-Mail(s):
						<input type="text" name="inquiries_routing_cc0" size="50" value="#htmleditformat(form.inquiries_routing_cc0)#" />
						<br />
						On status changes (i.e. reassignment/edits/notes/replies), send blind copy to E-Mail(s):
						<input type="text" name="inquiries_routing_cc2" size="50" value="#htmleditformat(form.inquiries_routing_cc2)#" />
						<br />
						<!--- <input type="checkbox" name="inquiries_routing_cc_type" value="3" <cfif find(",3,",","&form.inquiries_routing_cc_type&",") NEQ 0>checked="checked"</cfif> />When lead is inactive for <input type="text" name="inquiries_routing_cc_inactive_hours" value="#form.inquiries_routing_cc_inactive_hours#" /> hours, send copy to E-Mail(s): <input type="text" name="inquiries_routing_cc3" size="50" value="#htmleditformat(form.inquiries_routing_cc3)#" /><br />  ---></p></td>
			</tr>
			<!--- <tr>
				<th style="width:1%;">Follow-up<br />Reminders&nbsp;</th>
				<td>
				<p>Note: Reminders only work when the lead is assigned to a user who can login to the system.</p>
				<p><input type="radio" style="border:none; background:none;"  name="inquiries_routing_reminder_enabled"  value="1" <cfif form.inquiries_routing_reminder_enabled EQ '1'>checked="checked"</cfif>> Enable&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" style="border:none; background:none;"  name="inquiries_routing_reminder_enabled" value="0" <cfif form.inquiries_routing_reminder_enabled EQ '0' or form.inquiries_routing_reminder_enabled EQ ''>checked="checked"</cfif>> Disable</p>
				<p>Enter number of hours since last lead status change for reminders to be sent. Set to zero, "0", to disable.  The number of hours is always calculated from the last status change.  The 1st reminder should be a smaller number of hours then the other reminders and so on.</p>
				 <p><input type="text" name="inquiries_routing_reminder_hours1" value="#htmleditformat(application.zcore.functions.zso(form,'inquiries_routing_reminder_hours1',true))#" size="5" /> hours before 1st Reminder</p>
				<p><input type="text" name="inquiries_routing_reminder_hours2" value="#htmleditformat(application.zcore.functions.zso(form,'inquiries_routing_reminder_hours2',true))#" size="5" /> hours before 2nd Reminder</p>
				<p><input type="text" name="inquiries_routing_reminder_hours3" value="#htmleditformat(application.zcore.functions.zso(form,'inquiries_routing_reminder_hours3',true))#" size="5" /> hours before 3rd Reminder</p>
				<p><input type="text" name="inquiries_routing_reminder_hours_final" value="#htmleditformat(application.zcore.functions.zso(form,'inquiries_routing_reminder_hours_final',true))#" size="5" /> hours before reassignment</p>
				</td>
				</tr> ---> 
			
			<!---  <tr>
			<th style="width:1%;">Reassignment<br />Routing Type</th>
			<td>
			<table style="border-spacing:0px;">
		
			<tr>
			<td><input type="radio" name="inquiries_routing_reassignment_type_id" id="inquiries_routing_reassignment_type_id0" onclick="disableBothAssign2(0);" value="0" <cfif form.inquiries_routing_type_id EQ 0 or form.inquiries_routing_type_id EQ "">checked="checked"</cfif> /> Default Office Email (#application.zcore.functions.zvarso('zofficeemail')#)&nbsp; &nbsp;</td>
			</tr>
			<tr>
			<td><input type="radio" name="inquiries_routing_reassignment_type_id" id="inquiries_routing_reassignment_type_id1" onclick="disableBothAssign2(1);" value="1" <cfif form.inquiries_routing_type_id EQ 1>checked="checked"</cfif> /> Round Robin&nbsp; </td>
			</tr>
			<tr>
			<td><input type="radio" name="inquiries_routing_reassignment_type_id" id="inquiries_routing_reassignment_type_id2" value="2" <cfif form.inquiries_routing_type_id EQ 2>checked="checked"</cfif> /> Assign To User&nbsp; 
			 <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "inquiries_routing_reassignment_to_user_id";
				selectStruct.query = qAgents;
				selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
				selectStruct.onchange="showAgentPhoto2(this.options[this.selectedIndex].value);";
				selectStruct.queryParseLabelVars = true;
				selectStruct.queryValueField = 'user_id';
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript><br />
			<div id="agentPhotoDiv2"></div>
			
				 </td>
			</tr>
			<tr>
			<td><input type="radio" name="inquiries_routing_reassignment_type_id" id="inquiries_routing_reassignment_type_id3" value="3" <cfif form.inquiries_routing_type_id EQ 3>checked="checked"</cfif> /> Assign To Email Address(es)&nbsp;  <input type="text" name="inquiries_routing_reassignment_to_email" id="inquiries_routing_reassignment_to_email" size="50" value="#htmleditformat(form.inquiries_routing_reassignment_to_email)#" onkeyup="disableMemberAssign2(this);" /> </td>
			</tr>
			</table>
			<script>
			d1=document.getElementById("inquiries_routing_reassignment_to_user_id");
			showAgentPhoto2(d1.options[d1.selectedIndex].value);
			</script>
			</td></tr>
			 ---> 
			<!--- 
			<cfif application.zcore.app.siteHasApp("listing")>
			</table>
			<table style="width:100%; border-spacing:0px;">
			<tr> 
			<td style="vertical-align:top; "><strong>MLS Search Options</strong> | If you select Yes, only leads that match the search criteria will apply this route.<br/>
			<cfscript>
			request.zos.listing.functions.zMLSSearchOptions(mls_saved_search_id, "inquiries_routing_search_mls", form.inquiries_routing_search_mls);
			</cfscript>
			</td>
			</tr>
			</table>
			<table style="width:100%; border-spacing:0px;" class="table-list">
			</cfif>   --->
			
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save Routing</button>
					<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href = '/z/inquiries/admin/routing/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qRoutes=0;
	variables.init();
	application.zcore.functions.zStatusHandler(request.zsid);
	db.sql="SELECT * from #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries_type.inquiries_type_id = inquiries_routing.inquiries_type_id and 
	inquiries_type_deleted = #db.param(0)# and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_routing.inquiries_type_id_siteIDType"))# 
	WHERE inquiries_routing.site_id =#db.param(request.zOS.globals.id)# and 
	inquiries_routing_deleted = #db.param(0)# 
	ORDER BY inquiries_routing_sort ";
	qRoutes=db.execute("qRoutes");
	</cfscript>
	<h2 style="display:inline-block;">Lead Routing</h2> &nbsp;&nbsp;
	<a href="/z/inquiries/admin/routing/add" class="z-manager-search-button">Add</a>
	<br><br>
	<p>By default, leads go to the E-Mail Address(es) listed in the site option called: "<a href="/z/admin/site-options/index?return=1&amp;jumpto=soid_zofficeemail" title="Click to Edit">Office Email</a>".  To override this for specific lead types, click "Add Lead Route" or "Edit" the existing rules below.</p>
	<cfscript>
	if(application.zcore.app.siteHasApp("listing")){
		echo('<p>The lead routing configuration is overriden for listing inquiries when a listing''s agent id matches the "MLS Agent ID" field for the agent in the "manage users" section of the manager.  However, if someone inquiries on multiple properties in the same submission, then the normal lead routing rules apply.</p>');
	}
	</cfscript>
	<p>Note: A "Catch-all" route will be used for all forms that don't have an their own route added.</p> 
	<table id="sortRowTable" class="table-list">
		<thead>
		<tr>
			<th>Route ID</th>
			<th>Type</th> 
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="qRoutes">
			<tr #variables.queueSortCom.getRowHTML(qRoutes.inquiries_routing_id)# <cfif qRoutes.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
				<td>#qRoutes.inquiries_routing_id#</td>
				<td><cfif qRoutes.inquiries_type_id EQ 0>
					Catch-all
				<cfelse>
					#qRoutes.inquiries_type_name#
				</cfif></td> 
				<td class="z-manager-admin">
					<div class="z-manager-button-container">
						#variables.queueSortCom.getAjaxHandleButton(qRoutes.inquiries_routing_id)#
					</div>
					<div class="z-manager-button-container">
						<a href="/z/inquiries/admin/routing/edit?inquiries_routing_id=#qRoutes.inquiries_routing_id#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
					</div>
					<div class="z-manager-button-container">
						<a href="/z/inquiries/admin/routing/delete?inquiries_routing_id=#qRoutes.inquiries_routing_id#" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
					</div>
				</td>
			</tr>
		</cfloop>
		</tbody>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
