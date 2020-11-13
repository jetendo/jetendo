<cfcomponent>
<cfoutput>
<!--- /z/_com/app/queue-pop/index --->

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();

	request.headerRoboTriggers = [
		{ 'key': 'Auto-Submitted', 'value': '' },
		{ 'key': 'Auto-Submitted', 'value': 'auto-replied' },
		{ 'key': 'Precedence',     'value': 'bulk' },
		{ 'key': 'Precedence',     'value': 'list' },
		{ 'key': 'Precedence',     'value': 'junk' },
		{ 'key': 'Return-Path',    'value': '<>' },
		{ 'key': 'X-Autoreply',    'value': 'yes' },
	];
	request.blacklistWordArray = [ "This isn't a scam", "Earn per week", "Mail in order form", "Easy terms", "Reverses aging", "$$$", "Eliminate bad credit", "Make $", "Risk free", "'Hidden' assets", "Eliminate debt", "Make money", "Rolex", "100% free", "Email harvest", "Round the world", "100% Satisfied", "Email marketing", "Expect to earn", "Safeguard notice", "50% off", "Explode your business", "Accept credit cards", "Extra income", "F r e e", "Meet singles", "Fantastic deal", "Fast cash", "Satisfaction guaranteed", "Act Now", "Fast Viagra delivery", "Save $", "Act Now!", "Financial freedom", "Save big money", "Act now! Don't hesitate!", "Financially independent", "Save up to", "For free", "Million dollars", "Score with babes", "Additional income", "For instant access", "Search engine listings", "Addresses on CD", "For just $", "MLM", "Affordable", "Section 301", "All natural", "For Only $", "Money back", "See for yourself", "Money making", "Sent in compliance", "Month trial offer", "Serious cash", "More Internet Traffic", "Serious only", "Apply now", "Free access", "Apply Online", "Free cell phone", "Shopping spree", "As seen on", "Multi level marketing", "Sign up free today", "Auto email removal", "Free consultation", "Multi-level marketing", "Social security number", "Free DVD", "Free gift", "Special promotion", "Bargain", "Free grant money", "New customers only", "Stainless steel", "Be amazed", "Free hosting", "New domain extensions", "Stock alert", "Be your own boss", "Free info", "Nigerian", "Stock disclaimer statement", "No age restrictions", "Stock pick", "Beneficiary", "Free Instant", "No catch", "Best price", "Free investment", "No claim forms", "Stop snoring", "Free leads", "No cost", "Strong buy", "Big bucks", "Free membership", "No credit check", "Free money", "No disappointment", "Subject to cash", "Billing address", "Free offer", "No experience", "Subject to credit", "Free preview", "Billion dollars", "Free priority mail", "No gimmick", "Free quote", "No hidden", "Supplies are limited", "Brand new pager", "Free sample", "No inventory", "Take action now", "Bulk email", "Free trial", "No investment", "Talks about hidden charges", "Free website", "No medical exams", "Talks about prizes", "Buy direct", "No middleman", "Buying judgements", "No obligation", "Buying judgments", "Full refund", "No purchase necessary", "Terms and conditions", "Cable converter", "No questions asked", "The best rates", "Get it now", "No selling", "The following form", "Call free", "Get out of debt", "No strings attached", "Get paid", "No-obligation", "They're just giving it away", "Calling creditors", "Get started now", "Not intended", "This isn't junk", "Cancel at any time", "Gift certificate", "Notspam", "This isn't spam", "Cannot be combined with any other offer", "Give it away", "This won't last", "Can't live without", "Giving away", "Now only", "Cards accepted", "Great offer", "Obligation", "Time limited", "Off shore", "Cash bonus", "Undisclosed recipient", "Have you been turned down?", "Offer expires", "University diplomas", "Once in lifetime", "One hundred percent free", "Unsecured credit", "Cell phone cancer scam", "One hundred percent guaranteed", "Unsecured credit/debt", "Cents on the dollar", "Hidden assets", "Unsecured debt", "Hidden charges", "One time mailing", "Unsolicited", "Online biz opportunity", "Unsubscribe", "Home based", "Online degree", "Home employment", "Online marketing", "US dollars", "Check or money order", "Homebased business", "Online pharmacy", "Human growth hormone", "Vacation offers", "If only it were that easy", "Valium", "Important information regarding", "Viagra", "In accordance with laws", "Viagra and other drugs", "Opt in", "Vicodin", "Income from home", "Visit our website", "Click below", "Increase sales", "Order now", "Wants credit card", "Increase traffic", "Click to remove", "Increase your sales", "We hate spam", "Incredible deal", "Order today", "We honor all", "Collect child support", "Orders shipped by", "Web traffic", "Information you requested", "Outstanding values", "Weekend getaway", "Weight loss", "Compete for your business", "Pennies a day", "What are you waiting for?", "Confidentially on all orders", "Internet market", "While supplies last", "Internet marketing", "While you sleep", "Consolidate debt and credit", "Who really wins?", "Consolidate your debt", "Investment decision", "Why pay more?", "Copy accurately", "It's effective", "Please read", "Copy DVDs", "It's effective", "Potential earnings", "Will not believe your eyes", "Join millions", "Pre-approved", "Join millions of Americans", "Credit bureaus", "Print form signature", "Credit card offers", "Print out and fax", "Cures baldness", "Priority mail", "Work at home", "Life Insurance", "Work from home", "Xanax", "limited time", "You are a winner!", "Dig up dirt on friends", "Limited time offer", "Produced and sent out", "You have been selected", "Direct email", "Limited time only", "You're a Winner!", "Direct marketing", "Promise you", "Your income", "Long distance phone offer", "Pure Profits", "You're a Winner!", "Do it today", "Don't delete", "Lose weight", "Don't hesitate", "Lower interest rate", "Refinance", "Double your", "Lower interest rates", "Double your income", "Lower monthly payment", "Drastically reduced", "Lower your mortgage rate", "Removal instructions", "Lowest insurance rates", "Earn $", "Lowest Price", "Removes wrinkles", "Earn extra cash", "Reserves the right"
	];
	request.subjectRoboTriggers = [
		'Auto Response',
		'Auto Reply',
		'AutoReply',
		'MAILER-DAEMON',
		'Out of Office',
		'Undelivered',
		'Vacation'
	];
	</cfscript>
</cffunction>

<!--- <cffunction name="fixCustom" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;
	db.sql="SELECT site_id, inquiries_id, inquiries_custom_json FROM #db.table("inquiries", request.zos.zcoreDatasource)# WHERE (site_id >= #db.param(862)# AND site_id <= #db.param(873)#) or site_id = #db.param(553)# ";
	qInquiry=db.execute("qInquiry");
	for(row in qInquiry){
		js={arrCustom:[]};
		oldjs=deserializeJson(row.inquiries_custom_json);
		if(isstruct(oldjs.arrCustom)){
			for(i in oldjs.arrCustom){
				arrayAppend(js.arrCustom, oldjs.arrCustom[i]);
			}
			// writedump(oldjs);
			c=serializeJson(js);
			// writedump(c);abort;
			db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
			SET inquiries_custom_json=#db.param(c)# 
			where site_id = #db.param(row.site_id)# and 
			inquiries_id=#db.param(row.inquiries_id)# ";
			db.execute("qUpdate");
		}
	}
	</cfscript>	
	fixed<cfabort>
</cffunction>  --->

<cffunction name="cancel" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;

	application.queuePopCancel=true;
	</cfscript>	
	Cancelling<cfabort>
</cffunction>

<!--- 
/z/_com/app/queue-pop?method=index&force=1
 --->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	var db = request.zos.queryObject;
	setting requesttimeout="100";
 

	numberOfQueuePops = 5; // process X emails at a time. 
 	request.contactCom = createObject( 'component', 'zcorerootmapping.com.app.contact' ); 
	/*
	// 1.U15.123123123.123213123
	rs=request.contactCom.getFromAddressForUser(15, 298, 16318); 
	writedump(rs);
	abort;*/
	// inquiries_id is 16318
	/*rs=request.contactCom.getFromAddressForUser(15, 298, "16318"); 
	writedump(rs);
	abort;*/
	processCount=0;
	startTime=gettickcount();
	if(structkeyexists(application, 'queuePopCancel') or structkeyexists(form, 'force')){
		structdelete(application, 'queuePopCancel');
		structdelete(application, 'queuePopRunning');
	}
	if(structkeyexists(application, 'queuePopRunning')){
		echo('queue-pop is already running, please wait or <a href="/z/_com/app/queue-pop?method=index&force=1">Force</a>');
		abort;
	}
	application.queuePopRunning=true;
	try{
		while ( true ) {
			if(structkeyexists(application, 'queuePopCancel')){
				echo('queuePopCancelled');
				structdelete(application, 'queuePopCancel');
				break;
			}
			if(gettickcount()-startTime GT 55){
				break;
			}
			nowDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
			// only process ones that were scheduled in the past, this avoids the use of LIMIT statement as long as we ALWAYS mark them with a new scheduled date if there is a failure.
			// process emails for all sites at once based on scheduling
			db.sql = 'SELECT *
			FROM #db.table( 'queue_pop', request.zos.zcoreDatasource )#
			WHERE site_id <> #db.param(-1)#	and 
			queue_pop_deleted = #db.param( 0 )# and 
			queue_pop_process_fail_count < #db.param(3)# and 
			queue_pop_scheduled_processing_datetime < #db.param(nowDate)# 
			ORDER BY queue_pop_scheduled_processing_datetime ASC 
			LIMIT #db.param(0)#, #db.param( numberOfQueuePops )#';
			qQueuePop = db.execute( 'qQueuePop' );  
			if ( qQueuePop.recordcount EQ 0 ) { 
				break;
			} else {  
				for ( row in qQueuePop ) {
					nowDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
					// Get email message JSON
					jsonStruct = deserializeJSON( row.queue_pop_message_json );
					// writedump(row);
					// writedump(jsonStruct);
					//abort;


					// the xss filter can run here, but not file attachment and certain tag removal
					jsonStruct.html=application.zcore.email.makeHTMLSafe(jsonStruct.html);
					jsonStruct.html = reReplaceNoCase(jsonStruct.html, 'target="([^"]*)"', 'target="_top"', 'all' );

					jsonStruct.version=1; // this is the first version, version helps us identify data format compatibility problems later.
					// bounce / non-human detection can run here
					jsonStruct.humanReplyStruct=isHumanReply(jsonStruct); 
 
					// to debug, this is a valid plusId with des limit 16 applied and a real inquiries_id on test site
					// jsonStruct.plusId="1.C15.0B0D3C80B74E4B0E.16318";
					rs=processPlusId(row, jsonStruct);
					if(not rs.success){
						if(row.queue_pop_process_retry_interval_seconds EQ 0){
							// prevent 0
							row.queue_pop_process_retry_interval_seconds=60;
						}
						scheduledDatetime=dateAdd("s", row.queue_pop_process_retry_interval_seconds, nowDate);
						scheduledDatetime=dateformat(scheduledDatetime, 'yyyy-mm-dd')&' '&timeformat(scheduledDatetime, 'HH:mm:ss'); 
						// the from address was tampered with, may be spam.
						echo('reschedule queue_pop:#row.queue_pop_id#<br>');
						
						db.sql = 'UPDATE #db.table( 'queue_pop', request.zos.zcoreDatasource )# 
						SET queue_pop_scheduled_processing_datetime = #db.param(scheduledDatetime)#, 
						queue_pop_process_fail_count=#db.param(row.queue_pop_process_fail_count+1)#, 
						queue_pop_updated_datetime=#db.param(nowDate)# 
						WHERE site_id = #db.param(row.site_id)# and 
						queue_pop_deleted = #db.param( 0 )# and 
						queue_pop_scheduled_processing_datetime < #db.param(nowDate)# ';
						db.execute( 'qUpdate' );
					}else{
						// echo('delete queue_pop:#row.queue_pop_id#<br>');
						
						// This message was successfully processed, and we can safely delete the queue_pop record now.
						db.sql="delete from #db.table( 'queue_pop', request.zos.zcoreDatasource )#  
						WHERE site_id = #db.param(row.site_id)# and 
						queue_pop_deleted = #db.param( 0 )# and 
						queue_pop_id = #db.param(row.queue_pop_id)# ";
						db.execute( 'qDelete' );

						
					} 
					// echo('<hr>only processed first queue_pop<br>');
					// writedump(rs);
					// abort;
					processCount++;

				}  
				// uncomment break; for debugging only - because we aren't running real delete / update above, we have to force a break at the end of the loop
				break;
			}
		}
	}catch(Any e){
		structdelete(application, 'queuePopRunning'); 
		savecontent variable="out"{
			writedump(e);
		}
		throw(out);
	}
	structdelete(application, 'queuePopRunning');
	echo('Processed #processCount# emails.');
	abort;
	</cfscript>
</cffunction>

<cffunction name="processPlusId" localmode="modern" access="public">
	<cfargument name="messageStruct" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	var db = request.zos.queryObject;
	jsonStruct=arguments.jsonStruct;
	rs={
		success:true,
		debug:false,
		inquiries_id:"",
		privateMessage:false,
		enableCopyToSelf:false,
		messageStruct:arguments.messageStruct,
		jsonStruct:arguments.jsonStruct,
		filterContacts:{},
		parseRow:{}
	}; 
	// process and route based on jsonStruct.plusId
	if(jsonStruct.plusId EQ ""){
		// this will be routed to default location instead
		return request.contactCom.processMessage(rs); 
	}else{
		arrPlus=listToArray(jsonStruct.plusId, ".");

		if(arrPlus[1] EQ "1"){
			// this is probably an reply to a jetendo lead email
			request.contactCom = createObject( 'component', 'zcorerootmapping.com.app.contact' );
 
			if(arraylen(arrPlus) NEQ 4){
				return {success:false, errorMessage:"Plus address must have 4 parts for appId=1."};
			}
			rs.inquiries_id=arrPlus[4];
			// route to inquiries_feedback
			if(len(arrPlus[2]) EQ 0){
				// invalid message
				return {success:false, errorMessage:"Contact/user id was empty"};
			}
			if(left(arrPlus[2], 1) EQ "C"){
				// contact
				rs.contact_id=removeChars(arrPlus[2],1,1);
				rs.contact_des_key=arrPlus[3];

				// we store the validation boolean and let the application decide whether to continue routing the message or not
				rs.validHash=request.contactCom.verifyDESLimit16FromAddressForContact(rs.contact_id, rs.messageStruct.site_id, arrPlus[4], arrPlus[3]);
  
			}else{
				return {success:false, errorMessage:"Expected contact/user id to start with C or U"};
			}  
			return request.contactCom.processMessage(rs); 
		}else{
			// here we can import this as a new lead.

			// determine if one of the to or cc addresses match our site lead parse configuration, hardcoded for now
			if(not structkeyexists(request, "parseEmailStruct")){
				request.parseEmailStruct={};
				db.sql="SELECT * FROM #db.table("inquiries_parse_config", request.zos.zcoreDatasource)# WHERE 
				inquiries_parse_config_deleted=#db.param(0)# and 
				site_id <> #db.param(-1)#";
				qParse=db.execute("qParse");
				for(row in qParse){
					request.parseEmailStruct[row.inquiries_parse_config_email]=row;
				}
			}
			for(emailStruct in rs.jsonStruct.to){
				if(structkeyexists(request.parseEmailStruct, emailStruct.originalEmail)){
					rs.parseRow=request.parseEmailStruct[emailStruct.originalEmail];
					break;
				}
			}
			if(structcount(rs.parseRow) EQ 0){
				for(emailStruct in rs.jsonStruct.cc){
					if(structkeyexists(request.parseEmailStruct, emailStruct.originalEmail)){
						rs.parseRow=request.parseEmailStruct[emailStruct.originalEmail];
						break;
					}
				}
			} 
			if(structkeyexists(rs.jsonStruct["headers"]["parsed"], "Delivered-To")){
				if(structkeyexists(request.parseEmailStruct, rs.jsonStruct["headers"]["parsed"]["Delivered-To"])){
					rs.parseRow=request.parseEmailStruct[rs.jsonStruct["headers"]["parsed"]["Delivered-To"]];
				}
			}
			if(structcount(rs.parseRow) NEQ 0){
				return parseEmailToLead(rs);
			}else{
				// The email did not match any plus address, and it will be deleted from queue on purpose.
				// TODO: someday, we might want some kind of catch all option, but this is probably just spam and replies we don't need to process.
				return {success:true};
			}
		}
	}
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="parseEmailToLead" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db = request.zos.queryObject;
	

	html=ss.jsonStruct.html;

	request.fieldLookup={
		"first_name": "inquiries_first_name",
		"last_name": "inquiries_last_name",
		"first name": "inquiries_first_name",
		"last name": "inquiries_last_name",
		"full name": "inquiries_first_name",
		"name": "inquiries_first_name",
		"email": "inquiries_email",
		"email address": "inquiries_email",
		"email_address": "inquiries_email",
		"phone": "inquiries_phone1",
		"phone number": "inquiries_phone1",
		"phone_number": "inquiries_phone1",
		"comments": "inquiries_comments",
		"message": "inquiries_comments",
		"notes": "inquiries_comments",
		"details": "inquiries_comments",
	};

	// remove html elements
	var badTagList="style|script|embed|base|input|textarea|button|object|iframe|form";
	html=rereplacenocase(html,"<(#badTagList#).*?</\1>", " ", 'ALL');
	html=rereplacenocase(html,"<([A-Za-z]*) (^[>]*)>", "<$1>", 'ALL');
	html=replace(html, chr(13), chr(10), "all");
	html=replace(html, chr(9), " ", "all");

	arrSubjectExclude=listToArray(replace(ss.parseRow.inquiries_parse_config_subject_exclude, chr(13), chr(10), "all"), chr(10), false);
	arrBodyExclude=listToArray(replace(ss.parseRow.inquiries_parse_config_body_exclude, chr(13), chr(10), "all"), chr(10), false); 
	for(phrase in arrSubjectExclude){
		phrase=trim(phrase);
		if(phrase NEQ "" and ss.jsonStruct.subject CONTAINS phrase){
			return {success:true};
		}
	}
	for(phrase in arrBodyExclude){
		phrase=trim(phrase);
		if(phrase NEQ "" and ss.jsonStruct.html CONTAINS phrase){
			return {success:true};
		}
		if(phrase NEQ "" and ss.jsonStruct.text CONTAINS phrase){
			return {success:true};
		}
	}
	
	
	html=rereplacenocase(html,"<br([^>]*)>", chr(10)&chr(9)&"StartRow#chr(9)#", 'ALL');

	if(html CONTAINS "<table"){
		// detect table rows with this format: <tr><td>Field</td><td>Value</td></tr>
		html=rereplacenocase(html,"<tr", chr(10)&chr(9)&"StartRow#chr(9)#<tr", 'ALL');
		html=rereplacenocase(html,"<th", "#chr(9)#StartField#chr(9)#<th", 'ALL');
		html=rereplacenocase(html,"</th>", "#chr(9)#EndField#chr(9)#", 'ALL');
		html=rereplacenocase(html,"<td", "#chr(9)#StartField#chr(9)#<td", 'ALL');
		html=rereplacenocase(html,"</td>", "#chr(9)#EndField#chr(9)#", 'ALL');
		html=rereplacenocase(html,"</tr>", "#chr(9)#EndRow#chr(9)#"&chr(10), 'ALL');
	}
	// for debugging force some p tags
	// html&='<p>ParagraphColonField: Value1</p>  <p>ParagraphColonField2 : Value2</p> <p>ParagraphEqualField= Value3</p> <p>ParagraphEqualField = Value4</p>';

	if(html CONTAINS "</p>"){
		html=rereplacenocase(html,"<p", chr(10)&"#chr(9)#StartParagraphRow#chr(9)#<p", 'ALL');
		html=rereplacenocase(html,"</p>", "#chr(9)#EndParagraphRow#chr(9)#</p>"&chr(10), 'ALL');
	}

	html=rereplacenocase(html,"(</|<)[^>]*>", " ", 'ALL');
	html=replacenocase(html,"&nbsp;", " ", 'ALL'); 
	arrLine=listToArray(html, chr(10));
	// writedump(html);
	// arrLineNew=[];
	// for(i=1;i<=arraylen(arrLine);i++){
	// 	arrLine[i]=trim(arrLine[i]);
	// 	if(arrLine[i] NEQ ""){
	// 		arrayAppend(arrLineNew, arrLine[i]);
	// 	}
	// }
	// html=arrayToList(arrLineNew, chr(10));
	for(i=1;i LTE 10;i++){
		html=replacenocase(html,"  ", " ", 'ALL'); 
	}
	// stored as an array to preserve the original order of any custom fields
	arrExtractedFields=[];
	// this is temporary for debugging this parsing
	forceTextDebug=false;
	// ss.jsonStruct.text='TextField: Value#chr(10)#TextField2= Value2#chr(10)#TextField3: Value3#chr(10)#';
	if(forceTextDebug or (html EQ "" and ss.jsonStruct.text NEQ "")){
		// split the lines
		arrLine=listToArray(replace(ss.jsonStruct.text, chr(13), chr(10), "all"), chr(10));
		for(line in arrLine){
			matchLine=false;
			// detect plain text like Field: Value on each line
			if(line CONTAINS ":"){
				arrLine=listToArray(line, ":");
				if(arrayLen(arrLine) EQ 2){
					arrayAppend(arrExtractedFields, {label:trim(arrLine[1]), value:trim(arrLine[2])});
					matchLine=true;
				}
			}
			// detect plain text like Field= Value on each line
			if(line CONTAINS "=" and not matchLine){
				arrLine=listToArray(line, "=");
				if(arrayLen(arrLine) EQ 2){
					arrayAppend(arrExtractedFields, {label:trim(arrLine[1]), value:trim(arrLine[2])});
				}
			}

		}
	}
	html=replace(html, chr(10), " ", "all");
	arrData=listToArray(html, chr(9), true);
	inStartRow=false;
	inField=false;
	firstField=true;
	fieldLabel="";
	fieldValue="";
	inStartParagraphRow=false;
	// writedump(arrData);
	for(i=1;i<=arrayLen(arrData);i++){
		value=trim(arrData[i]);
		if(value CONTAINS ":"){
			arrLabel=listToArray(value, ":");
			if(arrayLen(arrLabel) EQ 2 and trim(arrLabel[1]) NEQ "" and trim(arrLabel[2]) NEQ ""){
				arrayAppend(arrExtractedFields, {label:trim(arrLabel[1]), value:trim(arrLabel[2])});
				continue;
			}
		}
		if(inStartRow){
			if(value EQ "EndRow"){
				arrayAppend(arrExtractedFields, {label:trim(fieldLabel), value:trim(fieldValue)});
				fieldLabel="";
				fieldValue="";
				inStartRow=false;
				firstField=true;
				inField=false;
			}
			// ignore p tags in a table row:
			if(value EQ "StartParagraphRow" or value EQ "EndParagraphRow"){
				continue;
			}
			if(value EQ "StartRow"){
				// invalid format, continue to next row before parsing more data
				inStartRow=false;
				firstField=true;
				inField=false;
				continue;
			}
			if(inField){
				if(value EQ "StartField"){
					// invalid format, continue to next row before parsing more data
					inStartRow=false;
					continue;
				}
				if(value EQ "EndField"){
					inField=false;
					firstField=false;
				}else if(firstField){
					fieldLabel&=value;
					// echo("label: "&value&"<br>");
				}else{
					// echo("value: "&value&"<br>");
					fieldValue&=value; 
				}
			}else{
				if(value EQ "StartField"){
					inField=true;
				}
			}
		}else if(inStartParagraphRow){
			// also detect invalid format words like above

			if(value EQ "StartRow"){
				// skip extra line
				continue;
			}

			if(value EQ "EndParagraphRow"){
				// split on : or = here and store field and value
				matchColon=false;
				// detect this format like <p>Field: Value</p> with optional spaces
				if(fieldLabel CONTAINS ":"){
					arrLabel=listToArray(fieldLabel, ":");
					if(arrayLen(arrLabel) EQ 2){
						arrayAppend(arrExtractedFields, {label:trim(arrLabel[1]), value:trim(arrLabel[2])});
						matchColon=true;
					}
				}
				// detect this format like <p>Field= Value</p> with optional spaces
				if(not matchColon and fieldLabel CONTAINS "="){
					arrLabel=listToArray(fieldLabel, "=");
					if(arrayLen(arrLabel) EQ 2){
						arrayAppend(arrExtractedFields, {label:trim(arrLabel[1]), value:trim(arrLabel[2])});
					}
				}
				fieldLabel="";
				fieldValue="";
				inStartParagraphRow=false;
			}else{
				fieldLabel&=value;
			}
		}else{ 
			if(value EQ "StartRow"){ 
				inStartRow=true;
				firstField=true;
				inField=false;
				inStartParagraphRow=false;
				// detect correct format: lookahead for 2 fields and an endrow
			}else if(value EQ "StartParagraphRow"){
				inStartParagraphRow=true;
				firstField=true;
				// detect correct format: lookahead for 2 fields and an endrow
			}
		}
	}
	// writedump(arrExtractedFields);abort;
	// echo(ss.jsonStruct.html);
	// echo('<p><textarea style="width:100%; height:350px;">#html#</textarea></p>');

	// remap field names to built in names if there is a match
	js={arrCustom:[]};
	ds={};
	for(i=1;i<=arrayLen(arrExtractedFields);i++){
		fs=arrExtractedFields[i];
		if(structkeyexists(request.fieldLookup, fs.label)){
			// map to built in field
			ds[request.fieldLookup[fs.label]]=fs.value;
		}else{
			// add to custom field array
			arrayAppend(js.arrCustom, {label:fs.label, value:fs.value});
		}
	}
	ds.inquiries_custom_json=serializeJson(js);
	ds.site_id=ss.parseRow.site_id; // TODO: need to get the site_id somehow
	ds.inquiries_updated_datetime=request.zos.mysqlnow;
	ds.inquiries_datetime=ss.jsonStruct.date; 
	ds.inquiries_type_id=ss.parseRow.inquiries_parse_config_inquiries_type_id; 
	ds.inquiries_type_id_siteIDType=ss.parseRow.inquiries_parse_config_inquiries_type_id_siteidtype;
	ds.inquiries_status_id=1;
	ds.inquiries_deleted=0;
	ds.inquiries_external_id="externalemail: "&ss.messageStruct.queue_pop_message_uid; // TODO: find uid variable in the arguments
	// refer to import calltrackingmetric code for more ideas.

	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_deleted=#db.param(0)# and 
	inquiries_external_id = #db.param(ds.inquiries_external_id)# and 
	inquiries_type_id = #db.param(ds.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(ds.inquiries_type_id_siteIDType)# and 
	site_id = #db.param(ds.site_id)# ";
	qId=db.execute("qId", "", 10000, "query", false);
	// backup form scope to avoid bleeding data between leads
	formBackup=duplicate(form);
	structclear(form);
	for(row in qId){
		structappend(form, row, false);
	}

	// writedump(arrExtractedFields);
	// writedump(ss);
	// writedump(ds);abort;
	structappend(form, ds , true);
	if(qId.recordcount){
		form.inquiries_id=qId.inquiries_id;
		structdelete(form, 'inquiries_status_id'); 
		application.zcore.functions.zUpdateLead(form);
	}else{ 
		application.zcore.functions.zImportLead(form);
	}
	// restore original form scope
	structappend(form, formBackup, true);
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="isHumanReply" localmode="modern" access="public">
	<cfargument name="message" type="struct" required="yes">
	<cfscript>
	var message = arguments.message;
	var rs = {
		isHumanReply: false,
		score:0,
		roboScore: 0,
		roboTriggers: [],
		humanScore: 0,
		humanTriggers: []
	};

	// Strip out line endings
	var tempMessageHTML = message.html;
	tempMessageHTML=replace(tempMessageHTML, '"emailAttachShortURL"', '', 'all');
	tempMessageHTML = replace( tempMessageHTML, chr(13), ' ', 'ALL' );
	tempMessageHTML = replace( tempMessageHTML, chr(10), ' ', 'ALL' );
 

	// Message contains certain headers - pretty much guarentees a non-human reply
	var headerRoboTriggered = false;

	for ( headerRoboTrigger in request.headerRoboTriggers ) {
		if ( structKeyExists( message.headers.parsed, headerRoboTrigger.key ) ) {
			if ( message.headers.parsed[ headerRoboTrigger.key ] EQ headerRoboTrigger.value ) {
				arrayAppend( rs.roboTriggers, '-100: header found - key: "' & headerRoboTrigger.key & '" value: "' & headerRoboTrigger.value & '"' );
				headerRoboTriggered = true;
				rs.roboScore=100;
				rs.score=-100;
				return rs;
			}
		}
	}

	// Check if the subject line contains any of the following strings.
	var subjectRoboTriggered = false;

	for ( subjectRoboTrigger in request.subjectRoboTriggers ) {
		if ( message.subject CONTAINS subjectRoboTrigger ) {
			arrayAppend( rs.roboTriggers, '-100: subject - ' & subjectRoboTrigger );
			subjectRoboTriggered = true;
			rs.roboScore=100;
			rs.score=-100;
			return rs;
		}
	}

	// writedump(message);
	// check for pass or neutral spf 
	if(structkeyexists(message.headers.parsed, 'Authentication-Results')){
		var spf=message.headers.parsed["Authentication-Results"];
		if(spf CONTAINS "=pass"){
			arrayAppend( rs.humanTriggers, '5: SPF/DKIM/ARC Pass' );
			rs.humanScore+=5;
		}else if(spf CONTAINS "=neutral"){
			arrayAppend( rs.humanTriggers, '0: SPF/DKIM/ARC neutral' ); 
			// no score

		}else{
			arrayAppend( rs.roboTriggers, '-30: SPF/DKIM/ARC Fail' );
			rs.roboScore+=30;
		}
	}else{
		arrayAppend( rs.roboTriggers, '-20: SPF/DKIM/ARC Missing' );
		rs.roboScore+=20;
	}


	// check for pass or neutral dkim


	if (not headerRoboTriggered ) { 
		// If the headers didn't robo trigger, likely it is more human reply.
		arrayAppend( rs.humanTriggers, '1: headers check was ok' );
		rs.humanScore++;
	}

	// Message was sent a long time ago, just received it.

	// Message was sent within a minute of our reply
		// Need to get our message they replied to
		// Test the send date of our message
		// Compare the send date of the reply message
	var oldMessageDayThreshold = 60; // # of days
	var days = dateDiff( 'd', message.date, now() );

	if ( days GT oldMessageDayThreshold ) {
		arrayAppend( rs.roboTriggers, '-20: old message check failed (' & days & ' days old - max is ' & oldMessageDayThreshold & ')' );
		rs.roboScore+=20;
	} else {
		arrayAppend( rs.humanTriggers, '1: old message check was ok (' & days & ' days old - max is ' & oldMessageDayThreshold & ')' );
		rs.humanScore++;
	}



	// Message contains a lot of HTML elements
/*
// not using yet
	var htmlCountThreshold = 20;
	var htmlCountThresholdRoboTriggered = false;

	var messageHtmlElements = REFindNoCase( '<([^>]*)>', tempMessageHTML );

	writedump( messageHtmlElements );
	abort;
*/

	// Message contains blacklisted words.
	var blacklistWordRoboTriggered = false;

	m=message.html&" "&message.subject;
	for ( blacklistWord in request.blacklistWordArray ) {
		if ( m CONTAINS blacklistWord ) {
			arrayAppend( rs.roboTriggers, '-0.5: blacklisted word found: ' & blacklistWord );
			blacklistWordRoboTriggered = true;
			rs.roboScore+=0.5;
		}
	}

	if ( NOT blacklistWordRoboTriggered ) {
		arrayAppend( rs.humanTriggers, '1: blacklisted word check was ok' );
		rs.humanScore++;
	}


	// Message contains a lot of to recipients.
	var toCountThreshold = 15;
	var toCount = arrayLen( message.to );
	if ( toCount GTE toCountThreshold ) {
		arrayAppend( rs.roboTriggers, '-10: to recipients check failed (' & toCount & ' of max ' & toCountThreshold & ')' );
		rs.roboScore+=10;
	} else {
		arrayAppend( rs.humanTriggers, '1: to recipients check was ok (' & toCount & ' of max ' & toCountThreshold & ')' );
		rs.humanScore++;
	}


	// Message contains a lot of CC recipients.
	var ccCountThreshold = 15;
	var ccCount = arrayLen( message.cc );
	if(ccCount NEQ 0){
		if ( ccCount GTE ccCountThreshold ) {
			arrayAppend( rs.roboTriggers, '-10: cc recipients check failed (' & ccCount & ' of max ' & toCountThreshold & ')' );
			rs.roboScore+=10;
		} else {
			arrayAppend( rs.humanTriggers, '1: cc recipients check was ok (' & ccCount & ' of max ' & toCountThreshold & ')' );
			rs.humanScore++;
		}
	}

	// Message contains a lot of images (3 or more)
	var imageCountThreshold = 5;
	var imageCountThresholdRoboTriggered = false;

	var messageImages = listToArray( application.zcore.functions.zExtractImagesFromHTML( tempMessageHTML ), chr(9) );
	var totalMessageImages = arrayLen( messageImages );

	if ( totalMessageImages GTE imageCountThreshold ) {
		arrayAppend( rs.roboTriggers, '-5: image count check failed (' & totalMessageImages & ' of max ' & imageCountThreshold & ')' );
		imageCountThresholdRoboTriggered = true;
		rs.roboScore+=5;
	} else {
		arrayAppend( rs.humanTriggers, '1: image count check ok (' & totalMessageImages & ' of max ' & imageCountThreshold & ')' );
		rs.humanScore++;
	}


	// Message contains a lot of links (3 or more)
	var linkCountThreshold = 5;
	var linkCountThresholdRoboTriggered = false;

	var messageLinks = listToArray( application.zcore.functions.zExtractLinksFromHTML( tempMessageHTML ), chr(9) );
	var totalMessageLinks = arrayLen( messageLinks );

	if ( totalMessageLinks GTE linkCountThreshold ) {
		arrayAppend( rs.roboTriggers, '-5: link count check failed (' & totalMessageLinks & ' of max ' & linkCountThreshold & ')' );
		linkCountThresholdRoboTriggered = true;
		rs.roboScore++;
	} else {
		arrayAppend( rs.humanTriggers, '1: link count check ok (' & totalMessageLinks & ' of max ' & linkCountThreshold & ')' );
		rs.humanScore++;
	}


	// If we have both too many images and too many links, probably not human.
	if ( imageCountThresholdRoboTriggered && linkCountThresholdRoboTriggered ) {
		arrayAppend( rs.roboTriggers, '-100: image and link count check both failed' );
		rs.roboScore=100;
		rs.score=-100;
		return rs;
	}


 
/*
	echo( '<h1>rs.RoboScore</h1>' );
	writedump( rs.roboScore );
	writedump( rs.roboTriggers );
	echo( '<h1>rs.HumanScore</h1>' );
	writedump( rs.humanScore );
	writedump( rs.humanTriggers );
	abort;
*/

	// calculate combined score
	rs.score=rs.humanScore-rs.roboScore;


	if ( rs.roboScore > 8 ) {
		// Might be robo-reply
		return rs;
	}

	rs.isHumanReply = true;

	return rs;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
