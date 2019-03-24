<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="remote">
	<cfscript>
		if ( NOT structKeyExists( form, 'email' ) ) {
			echo( 'Email address required.' );
			abort;
		}
		if ( NOT structKeyExists( form, 'autoresponder_id' ) ) {
			echo( 'Autoresponder ID required.' );
			abort;
		} 
		application.zcore.skin.disableGlobalHTMLHeadCode();
		application.zcore.template.setTemplate( 'root.templates.empty', true, true );
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	</cfscript>
	<div class="z-float z-pv-40 z-text-center">
		<h2>Unsubscribe From Future Emails</h2>
		<p>&nbsp;</p>
		<h3><a href="/z/inquiries/autoresponder-unsubscribe/confirm?email=#urlencodedformat(form.email)#&amp;autoresponder_id=#form.autoresponder_id#" style="text-decoration: underline;">Click here to unsubscribe from this list.</a></h3>
		<p>&nbsp;</p>
		<h3><a href="/z/inquiries/autoresponder-unsubscribe/confirm?email=#urlencodedformat(form.email)#&amp;autoresponder_id=#form.autoresponder_id#&amp;otherEmails=1" style="text-decoration: underline;">or Click here to unsubscribe from all lists sent from this website.</a></h3>
		<p>&nbsp;</p>
		<p>Note: You may continue to receive other emails from us if you subscribed to one of our other lists.</p>
		<p>If you wish to unsubscribe from another email, please be sure to click the unsubscribe link in that email to be removed.</p> 		
	</div>
</cffunction>

<cffunction name="confirm" localmode="modern" access="remote">
	<cfscript>
		init();
		var db = request.zos.queryObject;
		form.otherEmails=application.zcore.functions.zso(form, 'otherEmails', true, 0);

		if(form.otherEmails EQ 1){
			db.sql = 'UPDATE #db.table( 'contact', request.zos.zcoreDatasource )#
			SET contact_opt_out = #db.param( 1 )#,
			contact_updated_datetime = #db.param( request.zOS.mysqlnow )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
			AND contact_email = #db.param( form.email )#
			AND contact_deleted = #db.param( 0 )#';
			db.execute( 'qMailUser' ); 

			db.sql = 'UPDATE #db.table( 'user', request.zos.zcoreDatasource )#
			SET user_pref_email = #db.param( 0 )#,
			user_updated_datetime = #db.param( request.zOS.mysqlnow )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
			AND user_username = #db.param( form.email )#
			AND user_deleted = #db.param( 0 )#';
			db.execute( 'qMailUser' ); 
		} 
		db.sql = 'DELETE FROM #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )# 
		WHERE site_id = #db.param( request.zOS.globals.id )#
		AND inquiries_autoresponder_subscriber_email = #db.param( form.email )# ';

		if(form.otherEmails EQ 0){
			db.sql&=' AND inquiries_autoresponder_id = #db.param( form.autoresponder_id )# ';
		}
		db.sql&=' AND inquiries_autoresponder_subscriber_deleted = #db.param( 0 )#';
		db.execute( 'qAutoresponderSubscriber' );

		logStruct = {
			'inquiries_autoresponder_id': form.autoresponder_id,
			'inquiries_autoresponder_drip_id': 0,
			'inquiries_autoresponder_drip_log_email': form.email,
			'inquiries_autoresponder_drip_log_status': 'unsubscribed'
		};

		logEmailStatus( logStruct );
	</cfscript>

	<div class="z-float z-pv-40 z-text-center">
		<h2>You have been unsubscribed</h2>
		
		<p><a href="/" style="text-decoration: underline;">Visit Our Home Page</a></p>
	</div>
</cffunction>

<cffunction name="logEmailStatus" localmode="modern" access="private">
	<cfargument name="logStruct" type="struct" required="yes">
	<cfscript>
		logStruct = arguments.logStruct;

		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_email' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_email is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_status' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_status is required' );
		}

		logStruct.inquiries_autoresponder_drip_log_id = "0";
		logStruct.site_id = request.zos.globals.id;
		logStruct.inquiries_autoresponder_drip_log_datetime = request.zOS.mysqlnow;

		ts = structNew();

		ts.table      = 'inquiries_autoresponder_drip_log'; 
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct     = logStruct;

		rs = application.zcore.functions.zInsert( ts );

		if ( rs EQ false ) {
			throw( 'Failed to log ' & logStruct.inquiries_autoresponder_drip_log_status & ' status' );
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>