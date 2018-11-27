<cfcomponent>
<cfoutput>
<cffunction name="init" access="remote" localmode="modern"> 
	<cfscript>
	if(application.zcore.user.checkGroupAccess("administrator")){
		// ignore
	}else{
		// same user auth as manage-inquiries userIndex, etc.
	}
	request.fieldMap={
		"First Name":"inquiries_first_name",
		"Last Name":"inquiries_last_name",
		"Email":"inquiries_email",
		"Phone":"inquiries_phone1",
		"Cell Phone":"Cell Phone",
		"Home Phone":"Home Phone",
		"Company":"inquiries_company",
		"Address":"inquiries_address",
		"Address 2":"inquiries_address2",
		"City":"inquiries_city",
		"State":"inquiries_state",
		"Country":"inquiries_country",
		"Postal Code":"inquiries_zip",
		"Interested In Model":"inquiries_interested_in_model",
		"Interested In Category":"inquiries_interested_in_category"
	};
	</cfscript>
</cffunction>

<cffunction name="userIndex" access="remote" localmode="modern" roles="user">  
	<cfscript>
	index();
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern" roles="administrator">  
	<cfscript>
	init();
	db=request.zos.queryObject;
	variables.init();
	application.zcore.template.setTag("title", "Import Leads");
	// application.zcore.functions.zSetPageHelpId("2.7.1.1"); 
	// all options except for html separator 
	application.zcore.functions.zStatusHandler(request.zsid);
	arrRequired=["First Name", "Last Name", "Email", "Phone"];
	arrOptional=["Cell Phone", "Home Phone", "Address", "Address 2", "City", "State", "Country", "Postal Code", "Interested In Model", "Interested In Category"];
	// a site might need to allow custom json field import, via some callback mechanism.
	</cfscript>
	<h3>Import Leads</h3>
	<p>You must follow the instructions below.</h3> 
	<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish. You must include the required field columns even if they will be empty.  You must save the spreadsheet as a tab delimited .csv format.  Typically an option when you use the "Save as" feature of your spreadsheet software.  The file must have no fields with line breaks.  Any fields that are too long may be cut off at the end to fit the allowed size in the database.</p>
	<p>If a value doesn't match the system, it will be left blank when imported.</p> 
	<p>If you upload an invalid format, it will tell you and not import any data.</p>
	<p>You can't undo an import once it is submitted. Make sure you are uploading the correct information and not causing duplicates.</p>
	<p>To protect our system, we import the leads on a first come first served in the background.  You will receive an email when the import is complete.  Please don't submit the same data twice.</p>
	<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(arrRequired, chr(9))#</textarea></p>
	<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(arrOptional, chr(9))#</textarea></p>

	<!--- make this an ajax form that posts to /z/inquiries/admin/import-leads/import
	validate with both javascript and server.
	 --->
	<form id="importLeadForm" class="zFormCheckDirty" action="" enctype="multipart/form-data" method="post">
		<h2>Your Notification Email</h2>
		<p>We will notify you at this email address when the leads are done importing and only for that purpose.</p>
		<p>Email: <input type="email name="importEmail" style="width:250px; max-width:100%;" value="#htmleditformat(request.zsession.user.email)#" /></p>
		<p>&nbsp;</p>
		<h2>Select Lead Type</h2>
		<!--- drop down of all lead types --->
		<p><select name="inquiries_type_id" size="1">
			<option value="">Inquiry</option>
		</select></p>
		<p>&nbsp;</p>

		<h2>Select Autoresponder</h2>
		<!--- only the ones that are enabled for user import as regular user, otherwise all of them when administrator --->
		<p><select name="inquiries_autoresponder_id" size="1">
			<option value="">No Autoresponder</option>
		</select></p>
		<p>&nbsp;</p>

		<h2>Select Assignment</h2>
		<p>If you need more then one assignment, you must import separate files.</p>
		<!--- office and user --->
		<h3>Select Office</h3>
		<p><select name="office_id" size="1">
			<option value="">No office assignment</option>
		</select></p>
		<p>&nbsp;</p>
		<!--- need javascript method --->
		<h3>Select User</h3>
		<p><select name="uid" size="1">
			<option value="">No user assignment</option>
		</select></p>
		<p>&nbsp;</p>

		<h3>Select Tab Delimited CSV File</h3>

		<p><input type="file" name="filepath" value="" /></p>
		<p>&nbsp;</p>
		<cfif request.zos.isDeveloper>
			<h3>Specify optional CFC filter.</h3>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["column1"] EQ "bad value"){
				arguments.struct["column1"]="correct value";
			}
			return true; /* return false if you do not want to import this record. */
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		<p>&nbsp;</p>
		 <p><input type="submit" name="submit1" value="Import CSV" style="padding:10px; border-radius:5px;" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div></p>
	</form>
</cffunction>


<cffunction name="userImport" access="remote" localmode="modern" roles="user">  
	<cfscript>
	import();
	</cfscript>
</cffunction>


<cffunction name="scheduleImport" access="remote" localmode="modern" roles="administrator"> 
	<cfscript> 
	db=request.zos.queryObject;
	form.filename=application.zcore.functions.zso(form, 'filename');
	form.cfcPath=application.zcore.functions.zso(form, 'cfcPath');
	form.cfcMethod=application.zcore.functions.zso(form, 'cfcMethod');
	// store file reference and initial data in inquiries_import_log and return instantly.

	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction>

<cffunction name="import" access="remote" localmode="modern"> 
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	// must guarantee only one is ever running.  It may need to be able to resume to achieve that, with small 1 to 5 minute runtimes.

	setting requesttimeout="5000";
	db=request.zos.queryObject;
	// read from inquiries_import_log table for status =0
	form.filename=application.zcore.functions.zso(form, 'filename');
	form.cfcPath=application.zcore.functions.zso(form, 'cfcPath');
	form.cfcMethod=application.zcore.functions.zso(form, 'cfcMethod');

	leadAssigned=0;
	db=request.zos.queryObject; 
	path=request.zos.globals.privateHomeDir&"inquiries-import-backup/";
	application.zcore.functions.zCreateDirectory(path);
	filepath=path&"import-#dateformat(now(), "yyyy-mm-dd")&"-"&timeformat(now(), "HH-mm-ss")#.txt";
	debug=false;

	throw("Mark inquiries record with the file that was used during import to make it easier to remove mistakes.");
	throw("need to implement inquiries_autoresponder_allow_user_import");
	// this was the discover boating import below.  Need to make it a background process instead, and make it general based on the file upload.

	// need a table that tracks the imports per user, so we can display a global and user specific log status, and recover from mistakes.

	// need to store the inquiries_import_file_id in this table.
  
	arrDealer=application.zcore.siteOptionCom.optionGroupStruct("Dealer");
	dealerStateLookup={};
	montereyDealer={};
	for(dealer in arrDealer){ 
		if(dealer["state/province"] NEQ ""){
			if(not structkeyexists(dealerStateLookup, dealer["state/province"])){
				dealerStateLookup[dealer["state/province"]]=[];
			}
			arrayAppend(dealerStateLookup[dealer["state/province"]], dealer);
		}
	}
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	dealerGroupId = userGroupCom.getGroupId('Dealer_Manager',request.zos.globals.id); 

	dealerCom=createobject("component", request.zRootCFCPath&"mvc.controller.dealer");
	leadCount=0;
	if(structkeyexists(x.processsaleslead.dataarea, 'salesLead')){
		xs=x.processsaleslead.dataarea.salesLead;
		for(i=1;i<=arraylen(xs);i++){
			lead=xs[i];
			d=replace(left(lead.header.documentDateTime.xmltext, len(lead.header.documentDateTime.xmltext)-6), "T", " ");  
			d=parseDatetime(d);  
			ps=lead.header.IndividualProspect;
			
			ts={
				inquiries_external_id:"lead-import-"&lead.header.documentId.xmltext,
				inquiries_datetime:dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"),
				inquiries_first_name:ps.personname.givenName.xmltext,
				inquiries_last_name:ps.personname.familyName.xmltext,
				site_id:request.zos.globals.id,
				inquiries_primary:1,
				inquiries_status_id:1,
				inquiries_type_id:20, // this is discoverboating id - better as a function call
				inquiries_type_id_siteidtype:1,
				inquiries_deleted:0,
				inquiries_updated_datetime:request.zos.mysqlnow,
				inquiries_session_id:createUUID()
			};

			inquiryStruct=application.zcore.functions.zGetInquiryByExternalId(ts.inquiries_external_id);
			leadExists=false;
			if(structcount(inquiryStruct) NEQ 0){
				// skip lead already imported.
				leadExists=true;
				continue;
			} 
			//throw("test discover boating import");		abort;

			assignStruct=structnew();
			// assignStruct.assignUserId=481;
			// assignStruct.assignUserIdSiteIdType=1; 
			if(ps.marketingMailInd EQ 1){
				ts["inquiries_optin"]=1;
			}
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'addressLine')){
				if(arraylen(ps.address.addressLine) GTE 1){
					ts.inquiries_address=ps.address.addressLine[1].xmltext;
				}
				arrayDeleteAt(ps.address.addressLine, 1);
				if(structkeyexists(ps.address, 'addressLine') and arraylen(ps.address.addressLine) GTE 1){
					arrAddress=[];
					for(n in ps.address.addressLine){
						arrayAppend(arrAddress, n.xmltext);
					}
					ts.inquiries_address2=arrayToList(arrAddress, ", ");
				}
			}
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'city')){
				ts.inquiries_city=ps.address.city.xmltext;
			}
			ts.inquiries_state="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'StateOrProvince')){
				ts.inquiries_state=ps.address.StateOrProvince.xmltext;
			}
			ts.inquiries_zip="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'PostalCode')){
				ts.inquiries_zip=ps.address.PostalCode.xmltext;
			}
			ts2={};
			office_id="";
			form.dealer="";
			arrOffice=[];
			findDealer=false;

			request.autoresponderDealerName="";
			request.autoresponderDealerFullInfo="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'Country')){
				ts.inquiries_country=ps.address.Country.xmltext;
				findRandomStateDealer=false;
				if(ts.inquiries_country EQ "US" or ts.inquiries_country EQ "CA"){
					if(structkeyexists(ps.address, 'PostalCode')){
						// find dealer based on zip code distance - server side.
						findDealer=true;
						request.international=false;
						form.query=ts.inquiries_zip;
						form.lat="";
						form.lng="";
						form.country=ts.inquiries_country;
						form.quote_model=""; 
					}else{
						findDealer=true;
						findRandomStateDealer=true;
					}
				}else{
					request.international=true;
					findDealer=true;
					form.query=ts.inquiries_country;
					form.lat="";
					form.lng="";
					form.country=ts.inquiries_country;
					form.quote_model="";
				}
				if(findDealer){
					if(ts.inquiries_state NEQ "" and findRandomStateDealer and structkeyexists(dealerStateLookup, ts.inquiries_state)){
						tempDealer=dealerStateLookup[ts.inquiries_state][randrange(1, arraylen(dealerStateLookup[ts.inquiries_state]))];
						data={dealers:[ { data: tempDealer }] };
						echo('forced random state dealer<br>');
					}else{
						data=dealerCom.getDealerData();

						if(arrayLen(data.dealers) EQ 0 and structcount(montereyDealer) NEQ 0){
							data={dealers:[ { data: montereyDealer }] };
							echo('forced monterey dealer<br>');
						}
					} 
					if(arrayLen(data.dealers) GTE 1){
						form.dealer=data.dealers[1].data.__setId;
						struct=application.zcore.siteOptionCom.getOptionGroupSetById(["Dealer"],form["Dealer"]); 
						if(structcount(struct)){
							ts2["Dealer ID"]=struct.__setID;

							ts2["Dealer Info"]="#struct["name"]#<br/>
							#struct["address"]#, #struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>
							#struct["phone"]#";
							request.autoresponderDealerName=struct.name;
							request.autoresponderDealerFullInfo="#struct["name"]#<br>#struct["address"]#<br>#struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>#struct["phone"]#";
							 

							ts4={
								"DealerID":{value:form.dealer, listDelimiter:","}
							};
							application.zcore.functions.zSetOfficeIdForAutoresponder(form.dealer);
							arrOffice=application.zcore.user.searchOfficesByStruct(ts4);
							if(arrayLen(arrOffice) NEQ 0){
								ts.office_id=arrOffice[1].office_id;
								office_id=ts.office_id;

								// how to get the user for this dealer?
								db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
								concat(#db.param(',')#, office_id, #db.param(',')#) LIKE #db.param("%,"&ts.office_id&",%")# and 
								user_username=#db.param(struct["ARI Email"])# and 
								user_active=#db.param(1)# and 
								site_id = #db.param(request.zos.globals.id)# and 
								user_deleted=#db.param(0)# and 
								user_group_id=#db.param(dealerGroupId)# 
								LIMIT #db.param(0)#, #db.param(1)#";
								// we are only pulling the first dealer manager.  if there is more then one, it could be a problem, but we are ignoring this problem for now.
								// we would need a way to set the "primary" user in a group to fix
								qUser=db.execute("qUser");  
								if(qUser.recordcount NEQ 0){
									// assign should be here
									structdelete(assignStruct, 'assignEmail');
									assignStruct.assignUserId=qUser.user_id;
									assignStruct.assignUserIdSiteIDType=1;  
								} 
							} 
							request.autoresponderDealerName=struct.name;
							request.autoresponderDealerFullInfo="#struct["name"]#<br>#struct["address"]#<br>#struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>#struct["phone"]#";
						}
					}
				}
			}  


			if(structkeyexists(ps, 'contact') and structkeyexists(ps.contact, 'telephone')){
				ts.inquiries_phone1=ps.contact.telephone.xmltext;
				ts.inquiries_phone1_formatted=application.zcore.functions.zFormatInquiryPhone(ts.inquiries_phone1);
			}
			if(structkeyexists(ps, 'contact') and structkeyexists(ps.contact, 'emailAddress')){
				ts.inquiries_email=ps.contact.emailAddress.xmltext;
			}

			// convert into custom fields
			if(structkeyexists(ps, 'purchaseEarliestDate')){
				ts2["Purchase Earliest Date"]=ps.purchaseEarliestDate.xmltext;
			}
			if(structkeyexists(ps, 'ownedVehicle') and structkeyexists(ps.ownedVehicle, 'ownedType')){
				ts2["Owned Vehicle Type"]=ps.ownedVehicle.ownedType.xmltext;
			}
			if(structkeyexists(ps, 'ownedVehicle') and structkeyexists(ps.ownedVehicle, 'ModelDescription')){
				ts2["Owned Vehicle Description"]=ps.ownedVehicle.ModelDescription.xmltext;
			} 
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'SalesVehicle') and structkeyexists(ps.Detail.SalesVehicle, 'ModelDescription')){
				ts2["Interested In Category"]=ps.Detail.SalesVehicle.ModelDescription.xmltext;
			}
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'LeadRequestType')){
				ts2["Lead Request Type"]=ps.Detail.LeadRequestType.xmltext;
			}
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'LeadIndustryType')){
				ts2["Lead Industry Type"]=ps.Detail.LeadIndustryType.xmltext;
			}

			ts.inquiries_custom_json=application.zcore.functions.zSetInquiryCustomJsonFromStruct(ts2); 
			if(findDealer){
				// TODO: maybe set the customer_id later too
				if(office_id EQ "" or office_id EQ "0"){
					savecontent variable="out"{
						echo('<h2>lead with external id: #ts.inquiries_external_id# will be missing office_id</h2>');
						writedump("office_id:"&office_id);
						writedump("leadExists:"&leadExists);
						writedump("dealer: "&form.dealer);
						writedump(ts);
						writedump(arrOffice);
						writedump(ps);
					}
					throw(out);
				} 
			}
			if(not leadExists){
				leadCount++;
				form.inquiries_id=application.zcore.functions.zImportLead(ts);   
			}else{
				form.inquiries_id=inquiryStruct.inquiries_id;
			}   

			if(findDealer){
				assignStruct.office_id=office_id;
				assignStruct.forceAssign=true;
			}
			assignStruct.inquiries_id=form.inquiries_id;
			assignStruct.subject="New Lead on #request.zos.globals.shortdomain#"; 
			leadAssigned++;
			rs=application.zcore.functions.zAssignAndEmailLead(assignStruct);
			if(findDealer){
	    		application.zcore.functions.zSetOfficeIdForInquiryId(form.inquiries_id, office_id);
	    	}

    		db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# where inquiries_id = #db.param(form.inquiries_id)# and site_id =#db.param(request.zos.globals.id)# and inquiries_deleted=#db.param(0)#";
    		qCheck=db.execute("qCheck");
    		if(qCheck.recordcount NEQ 0){
				if(findDealer){
	    			if(qCheck.office_id EQ 0){
	    				throw("discoverboating - zAssignAndEmailLead or zSetOfficeIdForInquiryId failed to set office_id to #office_id# for inquiries_id=#form.inquiries_id#");
	    			}
	    		}
    		}
			if(rs.success EQ false){
				// failed to assign/email lead
				//zdump(local.rs);
			}   
		}
	}
	echo('Imported #leadCount# leads | assigned #leadAssigned# leads');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>