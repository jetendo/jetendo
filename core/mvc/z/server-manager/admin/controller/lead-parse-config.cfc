<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript> 
	if ( structKeyExists( form, 'zid' ) EQ false ) {
		form.zid = application.zcore.status.getNewId();
		if ( structKeyExists( form, 'sid' ) ) {
			application.zcore.status.setField( form.zid, 'site_id', form.sid );
		}
	}
	form.sid = application.zcore.status.getField( form.zid, 'site_id' );
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);
	if(form.sid EQ 0){
		application.zcore.status.setStatus(request.zsid, "Please select a site.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/site-select/index?sid=");
	}
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	var db = request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

	db.sql = 'SELECT *
		FROM #db.table( 'inquiries_parse_config', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( form.sid )#
			AND inquiries_parse_config_id = #db.param( application.zcore.functions.zso( form, 'inquiries_parse_config_id' ) )#
			AND inquiries_parse_config_deleted = #db.param( 0 )#';
	qCheck = db.execute( 'qCheck' );

	if ( qCheck.recordcount EQ 0 ) {
		application.zcore.status.setStatus( request.zsid, 'IMAP Account no longer exists', false, true );
		application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/index?zsid=#request.zsid#&zid=#form.zid#&sid=#form.sid#' );
	}
	</cfscript>
	<cfif structKeyExists( form, 'confirm' )>
		<cfscript>
		db.sql = 'DELETE FROM #db.table( 'inquiries_parse_config', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( form.sid )#
				AND inquiries_parse_config_id = #db.param( application.zcore.functions.zso( form, 'inquiries_parse_config_id' ) )#
				AND inquiries_parse_config_deleted = #db.param( 0 )#';
		q = db.execute( 'q' );

		application.zcore.status.setStatus( request.zsid, 'IMAP Account deleted' );
		application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/index?zsid=#request.zsid#&zid=#form.zid#&sid=#form.sid#' );
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Lead Import Parse Config?<br />
			<br />
			#qCheck.inquiries_parse_config_name#<br />
			#qCheck.inquiries_parse_config_email#<br />
			<br />
			<a href="/z/server-manager/admin/lead-parse-config/delete?confirm=1&amp;inquiries_parse_config_id=#form.inquiries_parse_config_id#&amp;zid=#form.zid#&amp;sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/lead-parse-config/index?zid=#form.zid#&amp;sid=#form.sid#">No</a> 
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
	init();
	var db = request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

	var ts = {};
	var result = 0;

	if ( form.method EQ 'insert' ) {
		form.inquiries_parse_config_id = '';
	}
 
	var errors = false;

	ts.inquiries_parse_config_name.required = true;
	ts.inquiries_parse_config_email.required = true;
	form.site_id=form.sid;

	result = application.zcore.functions.zValidateStruct( form, ts, request.zsid, true );

	arrType=listToArray(form.inquiries_type_id, "|");
	if(arrayLen(arrType) NEQ 2){
		// required
		result=true;
		application.zcore.status.setStatus(request.zsid, "Lead Type is required.", form, true);
	}else{
		form.inquiries_parse_config_inquiries_type_id=arrType[1];
		form.inquiries_parse_config_inquiries_type_id_siteidtype=arrType[2];
	}

	if ( result ) {
		application.zcore.status.setStatus( request.zsid, false, form, true );
		if ( form.method EQ 'insert' ) {
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/add?zsid=#request.zsid#&zid=#form.zid#&sid=#form.sid#' );
		} else {
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/edit?inquiries_parse_config_id=#form.inquiries_parse_config_id#&zsid=#request.zsid#&zid=#form.zid#&sid=#form.sid#' );
		}
	}

	form.site_id=form.sid;

	ts = StructNew();
	ts.table = 'inquiries_parse_config';
	ts.datasource = request.zos.zcoreDatasource;
	ts.struct = form;

	if ( form.method EQ 'insert' ) {
		form.inquiries_parse_config_id = application.zcore.functions.zInsert( ts );
		if ( form.inquiries_parse_config_id EQ false ) {
			application.zcore.status.setStatus( request.zsid, 'Failed to save Lead Import Parse Config. Name and Email must be unique', form, true );
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/add?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#' );
		} else {
			application.zcore.status.setStatus( request.zsid, 'Lead Import Parse Config saved.' );
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#' );
		}
	} else {
		if ( application.zcore.functions.zUpdate( ts ) EQ false ) {
			application.zcore.status.setStatus( request.zsid, 'Failed to Save Lead Import Parse Config.', form, true );
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/edit?inquiries_parse_config_id=#form.inquiries_parse_config_id#&zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#' );
		} else {
			application.zcore.status.setStatus(request.zsid, 'Lead Import Parse Config updated.');
			application.zcore.functions.zRedirect( '/z/server-manager/admin/lead-parse-config/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#' );
		}
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
		this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	var db = request.zos.queryObject;
	var currentMethod = form.method;

	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess( 'Server Manager' );

	if ( application.zcore.functions.zso( form, 'inquiries_parse_config_id' ) EQ '' ) {
		form.inquiries_parse_config_id = -1;
	}

	db.sql = 'SELECT *
		FROM #db.table( 'inquiries_parse_config', request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( form.sid )#
			AND inquiries_parse_config_id = #db.param( application.zcore.functions.zso( form, 'inquiries_parse_config_id' ) )#
			AND inquiries_parse_config_deleted = #db.param( 0 )#';
	qParse = db.execute( 'qParse' );

	application.zcore.functions.zQueryToStruct( qParse, form, 'inquiries_parse_config_id' );

	if ( currentMethod EQ 'add' ) {
		form.inquiries_parse_config_id = '';
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}
	application.zcore.functions.zStatusHandler( request.zsid, true );

	echo( '<h2>' );

	action = '/z/server-manager/admin/lead-parse-config/';
	if ( currentMethod EQ 'add' ) {
		action &= 'insert?zid=#form.zid#&sid=#form.sid#';
		echo( 'Add' );
	} else {
		action &= 'update?inquiries_parse_config_id=#form.inquiries_parse_config_id#&zid=#form.zid#&sid=#form.sid#';
		echo ( 'Edit' );
	}
	echo ( ' Lead Import Parse Config</h2>' );
	</cfscript>
	<p>* Denotes required field.</p>
	<form class="zFormCheckDirty" action="#action#" method="post" enctype="multipart/form-data">
		<table style="width: 100%;" class="table-list">
			<tr>
				<th style="width: 1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/server-manager/admin/lead-parse-config/index?zid=#form.zid#&amp;sid=#form.sid#';">Cancel</button>
				</td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="inquiries_parse_config_name" style="width:40%;" value="#htmlEditFormat( form.inquiries_parse_config_name )#" /> *</td>
			</tr>
			<tr>
				<th>Email</th>
				<td><input type="text" name="inquiries_parse_config_email" style="width:40%;" value="#htmlEditFormat( form.inquiries_parse_config_email )#" /> *</td>
			</tr>  
			<tr>
				<th>Lead Type</th>
				<td>
					<cfscript>
					db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("site_id"))# siteIDType 
					from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
					WHERE site_id IN (#db.param(0)#,#db.param(form.sid)#) and 
					inquiries_type_deleted = #db.param(0)#";
					if(not application.zcore.app.siteHasApp("listing")){
						db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
					}
					if(not application.zcore.app.siteHasApp("rental")){
						db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
					}
					db.sql&=" ORDER BY inquiries_type_name ";
					qType=db.execute("qType");
					form.inquiries_type_id=form.inquiries_parse_config_inquiries_type_id&"|"&form.inquiries_parse_config_inquiries_type_id_siteIDType;
					selectStruct = StructNew();
					selectStruct.name = "inquiries_type_id";
					selectStruct.query=qType;
					selectStruct.queryParseValueVars=true;
					selectStruct.queryLabelField="inquiries_type_name";
					selectStruct.queryValueField="##inquiries_type_id##|##siteIdType##";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript> *
				</td>
			</tr>
			<tr>
				<th>Subject Text Exclude</th>
				<td><textarea name="inquiries_parse_config_subject_exclude" style="width:40%; height:300px;">#htmlEditFormat( form.inquiries_parse_config_subject_exclude )#</textarea><br>
				Optionally add one phrase per line to exclude emails with the subject containing these phrases.</td>
			</tr> 
			<tr>
				<th>Body Text Exclude</th>
				<td><textarea name="inquiries_parse_config_body_exclude" style="width:40%; height:300px;">#htmlEditFormat( form.inquiries_parse_config_body_exclude )#</textarea><br>
				Optionally add one phrase per line to exclude emails with the body text containing these phrases.</td>
			</tr> 
			<tr>
				<th style="width: 1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href='/z/server-manager/admin/lead-parse-config/index?zid=#form.zid#&amp;sid=#form.sid#';">Cancel</button>
				</td>
			</tr>
		</table>
	</form>

</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db = request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	init();
	//application.zcore.functions.zSetPageHelpId("8.1.1.9.1");
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript> 
	<h2>Manage Lead Import Parse Config</h2>
	<cfscript>
	db.sql="SELECT * FROM #db.table("inquiries_parse_config", request.zos.zcoreDatasource)# 
	WHERE inquiries_parse_config_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)#
	ORDER BY inquiries_parse_config_name asc";
	qParse=db.execute("qParse");
	</cfscript>

	<p><a href="/z/server-manager/admin/lead-parse-config/add?zid=#form.zid#&amp;sid=#form.sid#">Add Lead Import Parse Config</a></p>

	<cfif qParse.recordcount EQ 0>
		<p>There are no lead import parse config records added to this site.</p>
	<cfelse>
		<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Name</th>
			<th>Email</th>
			<th>Last Updated</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qParse"> 
			<tr>
				<td>#qParse.inquiries_parse_config_name#</td>
				<td>#qParse.inquiries_parse_config_email#</td>
				<td>#application.zcore.functions.zGetLastUpdatedDescription( qParse.inquiries_parse_config_updated_datetime )#</td>
				<td>
					<a href="/z/server-manager/admin/lead-parse-config/edit?zid=#form.zid#&amp;sid=#form.sid#&amp;inquiries_parse_config_id=#qParse.inquiries_parse_config_id#">Edit</a> | 
					<a href="/z/server-manager/admin/lead-parse-config/delete?zid=#form.zid#&amp;sid=#form.sid#&amp;inquiries_parse_config_id=#qParse.inquiries_parse_config_id#">Delete</a>
				</td>
			</tr>
		</cfloop>
		</table>
	</cfif>

</cffunction>
</cfoutput>
</cfcomponent>
