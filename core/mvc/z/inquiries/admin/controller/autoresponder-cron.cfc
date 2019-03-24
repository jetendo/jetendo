<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
 	/*if(not request.zos.istestserver){
 		echo('Disabled on live server');abort;
 	}*/
	if ( NOT request.zos.isDeveloper AND NOT request.zos.isServer AND NOT request.zos.isTestServer ) {
		application.zcore.functions.z404( 'Can''t be executed except on test server or by server/developer ips.' );
	} 
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any">
    <cfscript>
	init(); 
	var db=request.zos.queryObject; 
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can access this url.");
	}  

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)#
	where site.site_id = inquiries_autoresponder_drip.site_id and 
	site_deleted = #db.param(0)# and 
	inquiries_autoresponder_drip_deleted = #db.param(0)# and 
	inquiries_autoresponder_drip_active = #db.param(1)# and 
	site.site_id <> #db.param(-1)# and 
	site_active=#db.param('1')# "; 
	if(not request.zos.istestserver){
		db.sql&=" and site_live=#db.param('1')#";
	}
	db.sql&=" GROUP BY site.site_id 
	ORDER BY site.site_id ASC ";
	if(request.zos.istestserver){
		db.sql&=" LIMIT #db.param(0)#, #db.param(1)# ";
	}
	qM=db.execute("qM");  
	if(qM.recordcount EQ 0){
		echo("No sites with drip autoresponders enabled<br />");
	}
	for(row in qM){
        // send email with zDownloadLink(); to run the alert on the correct domain
        link=row.site_domain&'/z/inquiries/admin/autoresponder-cron/processSiteAutoresponders'; 
        r1=application.zcore.functions.zDownloadLink(link);
	    if(request.zos.isTestServer){
	    	echo("Downloaded: "&link&"<br />");
	    	if(r1.success EQ false){
	    		writedump(r1);
	    	}else{
	            writeoutput(r1.cfhttp.FileContent&'<br /><br />');
				application.zcore.functions.zabort();
			}
	    }
	}
	writeoutput('Complete');
	abort;
	</cfscript>
</cffunction> 


<cffunction name="processSiteAutoresponders" localmode="modern" access="remote">
	<cfscript>
	var db = request.zos.queryObject;
	init();

	//application.zcore.template.setTemplate( 'root.templates.empty', true, true );

	// PER SITE_ID REQUEST

	autoresponderDripsCom = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder-drips' );

	// Get all active drip emails from the database for this site
	// Ordered by the autoresponder_id and then the drip_sort.
	// We don't need the autoresponders that don't have drip emails
	// because those one's send the initial email immediately.
	db.sql = 'SELECT inquiries_autoresponder_drip.*, inquiries_autoresponder.*
		FROM #db.table( 'inquiries_autoresponder_drip', request.zos.zcoreDatasource )# AS inquiries_autoresponder_drip, 
		#db.table( 'inquiries_autoresponder', request.zos.zcoreDatasource )# AS inquiries_autoresponder
		WHERE inquiries_autoresponder.inquiries_autoresponder_id = inquiries_autoresponder_drip.inquiries_autoresponder_id
		and inquiries_autoresponder.inquiries_autoresponder_active = #db.param( 1 )# and 
		inquiries_autoresponder_deleted=#db.param(0)# and 
		inquiries_autoresponder_drip_deleted=#db.param(0)# and 
		inquiries_autoresponder.site_id = inquiries_autoresponder_drip.site_id and 
		inquiries_autoresponder_drip.site_id = #db.param( request.zos.globals.id )# AND 
		inquiries_autoresponder_drip.inquiries_autoresponder_drip_active = #db.param( 1 )# 
		ORDER BY inquiries_autoresponder_drip.inquiries_autoresponder_id ASC,
			inquiries_autoresponder_drip.inquiries_autoresponder_drip_sort ASC';
	qAutoresponderDrip = db.execute( 'qAutoresponderDrip' ); 

	if ( qAutoresponderDrip.recordcount EQ 0 ) {
		// If no drips were found for this site, we don't need to do anything
		// because the initial autoresponder emails are sent immediately while
		// the drip emails are delayed after the initial email.
		throw( 'No drip emails found.' );
	} else {
		// Loop through the drip emails
			// Keep track of the current autoresponder_id
			// Keep track of the current drip_id
			// If the previous autoresponder_id does not match the current autoresponder_id
				// Then save the previous drip_id as the previous autoresponder_id's last_drip_id (before assigning new value to current drip_id)

		var autoresponders = {};
		var autoresponder_drips = {};
		var autoresponder_id = 0;

		var drip_id = 0;
		var first_drip_id = 0;
		var next_drip_ids = {};

		// Populate the autoresponder cache object.
		for ( drip in qAutoresponderDrip ) {
			if ( autoresponder_id NEQ drip.inquiries_autoresponder_id AND autoresponder_id NEQ 0 ) {
				// Previously saved autoresponder_id does not match the current autoresponder_id.
				// This means that the previous drip_id was the last drip_id of the previous autoresponder_id.

				// Append the previous autoresponder_id to the autoresponders object as this one is done being populated.
				autoresponders[ autoresponder_id ] = {
					'autoresponder_id': autoresponder_id,
					'inquiries_type_id': drip.inquiries_type_id,
					'inquiries_type_id_siteidtype': drip.inquiries_type_id_siteidtype,
					'first_drip_id': first_drip_id,
					'last_drip_id': drip_id,
					'next_drip_ids': next_drip_ids,
					'drips': autoresponder_drips
				};

				// Clear out the temporary variables to begin populating for the next autoresponder.
				autoresponder_drips = {};
				first_drip_id = 0;
				next_drip_ids = {};
			} else {
				if ( drip_id NEQ 0 ) {
					// Update the previous drip_id with the current drip_id as it's next.
					next_drip_ids[ drip_id ] = drip.inquiries_autoresponder_drip_id;
				}
			}

			if ( first_drip_id EQ 0 ) {
				first_drip_id = drip.inquiries_autoresponder_drip_id;
			}

			// Append the current drip to the temporary autoresponder_drips object.
			autoresponder_drips[ drip.inquiries_autoresponder_drip_id ] = drip;

			// Append the current drip_id to the next_drip_ids object.
			next_drip_ids[ drip.inquiries_autoresponder_drip_id ] = 0;

			// Keep track of the current autoresponder_id and drip_id to reference for the next loop.
			autoresponder_id = drip.inquiries_autoresponder_id;
			drip_id = drip.inquiries_autoresponder_drip_id;
		}

		// If there is still a drip email in the temporary autoresponder_drips object
		if ( arrayLen( autoresponder_drips ) GT 0 ) {
			// Append them to the autoresponders.
			autoresponders[ autoresponder_id ] = {
				'autoresponder_id': autoresponder_id,
				'inquiries_type_id': drip.inquiries_type_id,
				'inquiries_type_id_siteidtype': drip.inquiries_type_id_siteidtype,
				'first_drip_id': first_drip_id,
				'last_drip_id': drip_id,
				'next_drip_ids': next_drip_ids,
				'drips': autoresponder_drips
			};
		}

		// Now that we have the autoresponder object populated with their
		// respective drips, we can loop through the subscribers and
		// determine which drip email to send them now.
		haveSubscribers = true;
		subscriberOffset = 0;
		numberOfSubscribers = 30;
		sendCount=0;

		while ( haveSubscribers ) {
			// Get all subscribers for this site where the subscribers have not
			// completed an autoresponder drip list, that are still subscribed, and
			// not deleted. Also are not unsubscribed globally. 

 			// it's possible for multiple records to be returned for the user table, so we added a group by statement
			db.sql = 'SELECT inquiries_autoresponder_subscriber.*
			FROM #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#  
			LEFT JOIN #db.table( 'contact', request.zos.zcoreDatasource )# ON 
			contact.contact_deleted=#db.param(0)# and 
			contact.contact_email = inquiries_autoresponder_subscriber.inquiries_autoresponder_subscriber_email AND 
			contact.site_id = inquiries_autoresponder_subscriber.site_id AND 
			contact.contact_opt_out = #db.param(0)# 
			LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# ON 
			user_username=inquiries_autoresponder_subscriber.inquiries_autoresponder_subscriber_email and 
			user_deleted = #db.param(0)# and 
			(user.site_id=inquiries_autoresponder_subscriber.site_id or 
			user.site_id = #db.param(request.zos.globals.serverId)# ';
			if(request.zos.globals.parentId NEQ 0){
				db.sql&=" or user.site_id = #db.param(request.zos.globals.parentId)# ";
			} 
			db.sql&=' ) and 
			user_active=#db.param(1)# and 
			user_pref_email=#db.param(1)# 
			WHERE
			inquiries_autoresponder_subscriber_fail_count<#db.param(3)# and 
			inquiries_autoresponder_subscriber.site_id = #db.param( request.zos.globals.id )# and 
			inquiries_autoresponder_subscriber.inquiries_autoresponder_subscriber_completed = #db.param( 0 )# and 
			inquiries_autoresponder_subscriber.inquiries_autoresponder_subscriber_subscribed = #db.param( 1 )# and 
			inquiries_autoresponder_subscriber.inquiries_autoresponder_subscriber_deleted = #db.param( 0 )# and 
			( contact.contact_id <> #db.param('')# or user.user_id <> #db.param('')# ) 
			GROUP BY inquiries_autoresponder_subscriber_id
			LIMIT #db.param( subscriberOffset )#, #db.param( numberOfSubscribers )# ';
			qAutoresponderSubscriber = db.execute( 'qAutoresponderSubscriber' );  
 
			if ( qAutoresponderSubscriber.recordcount EQ 0 ) {
				haveSubscribers = false;
				break;
			} else {
				subscriberOffset = ( subscriberOffset + numberOfSubscribers ); 
				// Loop through subscribers
				for ( subscriber in qAutoresponderSubscriber ) {
					autoresponder = autoresponders[ subscriber.inquiries_autoresponder_id ];

					// Check to see what their last drip ID was
					// If their last_drip_id is not the last_drip_id of the autoresponder...
					send_drip_id = 0;

					if ( subscriber.inquiries_autoresponder_last_drip_id EQ 0 ) {
						// They have not been sent any drip emails yet so we need to send the first one.
						send_drip_id = autoresponder.first_drip_id;
					} else {
						if ( subscriber.inquiries_autoresponder_last_drip_id NEQ autoresponder.last_drip_id ) {
							// Get the next_drip_id for their last_drip_id
							send_drip_id = autoresponder.next_drip_ids[ subscriber.inquiries_autoresponder_last_drip_id ];
						}
					}

					// Check to see if we actually have a drip email to send.
					if ( send_drip_id NEQ 0 ) {
						sendDripEmail = autoresponder.drips[ send_drip_id ];

						// Make sure that the last_drip_id and the send_drip_id are not the same.
						// This could possibly happen if the last drip email is deactivated.
						// This prevents the same drip from being sent twice.
						if (subscriber.inquiries_autoresponder_last_drip_id EQ send_drip_id ) {
							// If so, update the subscriber and say they are completed, then continue.

							db.sql = 'UPDATE #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
								SET inquiries_autoresponder_subscriber_completed = #db.param( 1 )#, 
								inquiries_autoresponder_subscriber_updated_datetime=#db.param(request.zos.mysqlnow)# 
								WHERE inquiries_autoresponder_subscriber_id = #db.param( subscriber.inquiries_autoresponder_subscriber_id )# and 
								site_id =#db.param(request.zos.globals.id)# and 
								inquiries_autoresponder_subscriber_deleted=#db.param(0)# ';
							qAutoresponderSubscriberUpdate = db.execute( 'qAutoresponderSubscriberUpdate' ); 
							continue;
						}

						if (subscriber.inquiries_autoresponder_last_drip_datetime EQ '' ) {
							sendDate = request.zOS.mysqlnow;
						} else {
							sendDate = dateAdd( 'd', sendDripEmail.inquiries_autoresponder_drip_days_to_wait, subscriber.inquiries_autoresponder_last_drip_datetime );
						}

						// Will return -1 if not ready to send, otherwise will return 0 or 1 if now or in the past and ready to send.
						readyToSend = dateCompare( request.zOS.mysqlnow, sendDate );

						// Check to see if the alotted time has passed for the drip since the previous one.
						if ( readyToSend GTE 0 ) {
							// Prepare the drip email
							fromEmail = sendDripEmail.inquiries_autoresponder_drip_from;

							if ( fromEmail EQ '' ) {
								fromEmail = sendDripEmail.inquiries_autoresponder_from;
							}

							if ( fromEmail EQ '' ) {
								fromEmail = request.officeEmail;
							}

							dripEmailStruct = {
								// required
								inquiries_type_id: autoresponder.inquiries_type_id,
								inquiries_type_id_siteidtype: autoresponder.inquiries_type_id_siteidtype,
								inquiries_autoresponder_id: autoresponder.autoresponder_id,
								inquiries_autoresponder_drip_id: sendDripEmail.inquiries_autoresponder_drip_id,
								to: subscriber.inquiries_autoresponder_subscriber_email,
								from: fromEmail,
								dataStruct: {
									firstName: subscriber.inquiries_autoresponder_subscriber_first_name,
									lastName: subscriber.inquiries_autoresponder_subscriber_last_name,
									interestedInModel: subscriber.inquiries_autoresponder_subscriber_interested_in_model,
									officeId: subscriber.inquiries_autoresponder_subscriber_officeid,
									email: subscriber.inquiries_autoresponder_subscriber_email
								},
								layoutStruct: {
									headerHTML: autoresponderDripsCom.getHeaderHTML( sendDripEmail ),
									mainHTML: autoresponderDripsCom.getMainHTML( sendDripEmail ),
									footerHTML: autoresponderDripsCom.getFooterHTML( sendDripEmail ),
									footerTextHTML: autoresponderDripsCom.getFooterTextHTML( sendDripEmail )
								},
								preview: false
								// optional
								// cc: ''
							}; 

							sendCount++; 
							// Send the drip email.
							rs = autoresponderDripsCom.sendAutoresponderDrip( dripEmailStruct, sendDripEmail); 

							// Verify that the drip email was sent.
							if (rs.success EQ false ) {
								// If the email fails to send, we should just continue and not throw an error. 
								if(subscriber.inquiries_autoresponder_subscriber_fail_count+1 GTE 3){
									savecontent variable="out"{
										echo('There is a permanent error with this drip email. You must manually review the database and fix the record in the inquiries_autoresponder_subscriber table.');
										writedump(dripEmailStruct);
										writedump(rs);
									}
									ts={
										type:"Custom",
										errorHTML:out,
										scriptName:'/z/inquiries/admin/controller/autoresponder-cron/processSiteAutoresponders',
										url:request.zos.originalURL,
										exceptionMessage:'There is a permanent error with this drip email.',
										// optional
										lineNumber:'300'
									}
									application.zcore.functions.zLogError(ts);
								}

								logStruct = {
									'inquiries_type_id': dripEmailStruct.inquiries_type_id,
									'inquiries_autoresponder_id': dripEmailStruct.inquiries_autoresponder_id,
									'inquiries_autoresponder_drip_id': dripEmailStruct.inquiries_autoresponder_drip_id,
									'inquiries_autoresponder_drip_log_email': dripEmailStruct.to,
									'inquiries_autoresponder_drip_log_status': 'dripfailed'
								};

								logEmailStatus( logStruct ); 
 
								db.sql = 'UPDATE #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
								SET inquiries_autoresponder_subscriber_fail_count=#db.param(subscriber.inquiries_autoresponder_subscriber_fail_count+1)#,
								inquiries_autoresponder_subscriber_updated_datetime=#db.param(request.zos.mysqlnow)#
								WHERE site_id = #db.param( request.zos.globals.id )# and 
								inquiries_autoresponder_subscriber_id = #db.param( subscriber.inquiries_autoresponder_subscriber_id )# and 
								inquiries_autoresponder_subscriber_deleted=#db.param(0)# ';
								db.execute( 'qAutoresponderSubscriberUpdate' );  
								continue;
							} 

							if (send_drip_id EQ autoresponder.last_drip_id ) {
								// This drip is the last drip email for this autoresponder.
								// Consider the subscriber completed.  
								db.sql = 'UPDATE #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
									SET inquiries_autoresponder_last_drip_id = #db.param( send_drip_id )#,
										inquiries_autoresponder_subscriber_updated_datetime=#db.param(request.zos.mysqlnow)#, 
										inquiries_autoresponder_last_drip_datetime = #db.param( request.zOS.mysqlnow )#,
										inquiries_autoresponder_subscriber_completed = #db.param( 1 )#
									WHERE site_id = #db.param( request.zos.globals.id )#
										AND inquiries_autoresponder_subscriber_id = #db.param( subscriber.inquiries_autoresponder_subscriber_id )# and 
									inquiries_autoresponder_subscriber_deleted=#db.param(0)# ';
								db.execute( 'qAutoresponderSubscriberUpdate' );

								logStruct = {
									'inquiries_type_id': dripEmailStruct.inquiries_type_id,
									'inquiries_autoresponder_id': dripEmailStruct.inquiries_autoresponder_id,
									'inquiries_autoresponder_drip_id': dripEmailStruct.inquiries_autoresponder_drip_id,
									'inquiries_autoresponder_drip_log_email': dripEmailStruct.to,
									'inquiries_autoresponder_drip_log_status': 'complete'
								};

								logEmailStatus( logStruct ); 
							} else { 
								// Update the subscriber last_drip_id and last_drip_datetime
								// so that next time the cron runs, we send them the next drip
								// for this autoresponder.
								db.sql = 'UPDATE #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
									SET inquiries_autoresponder_last_drip_id = #db.param( send_drip_id )#,
										inquiries_autoresponder_last_drip_datetime = #db.param( request.zOS.mysqlnow )#, 
										inquiries_autoresponder_subscriber_updated_datetime=#db.param(request.zos.mysqlnow)# 
									WHERE inquiries_autoresponder_subscriber_id = #db.param( subscriber.inquiries_autoresponder_subscriber_id )# and 
									site_id=#db.param(request.zos.globals.id)# and 
									inquiries_autoresponder_subscriber_deleted=#db.param(0)# ';
								qAutoresponderSubscriberUpdate = db.execute( 'qAutoresponderSubscriberUpdate' );

								logStruct = {
									'inquiries_type_id': dripEmailStruct.inquiries_type_id,
									'inquiries_autoresponder_id': dripEmailStruct.inquiries_autoresponder_id,
									'inquiries_autoresponder_drip_id': dripEmailStruct.inquiries_autoresponder_drip_id,
									'inquiries_autoresponder_drip_log_email': dripEmailStruct.to,
									'inquiries_autoresponder_drip_log_status': 'dripsent'
								};

								logEmailStatus( logStruct );
							} 

						} // End if drip ready to send

					} // End if have drip to send

				} // End subscriber loop

			} // End if have subscriber rows

		} // End while haveSubscribers loop

	} // End if have autoresponder drips
	echo('#sendCount# sent | #qAutoresponderDrip.recordcount# total subscriptions');
	abort;
	</cfscript>
</cffunction>

<cffunction name="logEmailStatus" localmode="modern" access="private">
	<cfargument name="logStruct" type="struct" required="yes">
	<cfscript>
		logStruct = arguments.logStruct;

		if ( NOT structKeyExists( logStruct, 'inquiries_type_id' ) ) {
			throw( 'arguments.logStruct.inquiries_type_id is required' );
		}
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

		logStruct.site_id = request.zos.globals.id;
		logStruct.inquiries_autoresponder_drip_log_datetime = request.zOS.mysqlnow;

		ts = structNew();

		ts.table      = 'inquiries_autoresponder_drip_log';
		ts.datasource = request.zos.zcoreDatasource;
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct     = logStruct;

		rs = application.zcore.functions.zInsert( ts );

		if ( rs EQ false ) {
			throw( 'Failed to log ' & logStatus.inquiries_autoresponder_drip_log_status & ' status' );
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>