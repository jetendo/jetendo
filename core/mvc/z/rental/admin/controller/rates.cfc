<cfcomponent>
<cfoutput>
<cffunction name="displayNavigation" localmode="modern" access="public" roles="member">
	<a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#" target="_blank">Public Rental Home Page</a> | 
	<strong>Manage:</strong> 
	<a href="/z/rental/admin/rates/index">Rentals</a> | 
	<a href="/z/rental/admin/rental-category/index">Categories</a> | 
	<a href="/z/rental/admin/rental-amenity/index">Amenities</a> |
	<cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1>
		<a href="/z/rental/admin/combined-availability/index">All Calendars</a> |
	</cfif>
	<cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
		<a href="/z/rental/admin/reservations/index">Reservations</a> |
	</cfif>
	<strong>Add: </strong>
	<cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
		<a href="/z/rental/admin/rates/add<cfif structkeyexists(form, 'rental_id')>?rental_id=#form.rental_id#</cfif>">Global Rate</a> |
	</cfif>
	<a href="/z/rental/admin/rates/addRental">Rental</a> | 
	<a href="/z/rental/admin/rental-category/add">Category</a> | 
	<a href="/z/rental/admin/rental-amenity/add">Amenity</a><br />
	<br />
</cffunction>

<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rentals");
	form.rental_tax=application.zcore.functions.zso(form, 'rental_tax',false,'0');
	form.start=application.zcore.functions.zso(form, 'start',false,'');
	
	if(not application.zcore.app.siteHasApp("rental")){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	
	if(structkeyexists(form, 'return') and structkeyexists(form, 'rental_id')){
		StructInsert(request.zsession, "rental_rates_return"&form.rental_id, request.zos.cgi.http_referer, true);		
	};
	variables.queueSortStruct = StructNew();
	variables.queueSortStruct.tableName = "rental";
	variables.queueSortStruct.sortFieldName = "rental_sort";
	variables.queueSortStruct.primaryKeyName = "rental_id";
	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/rental/admin/rates/#form.method#';
	variables.queueSortStruct.datasource = request.zos.zcoreDatasource;

	variables.queueSortStruct.where =" rental_active='1' and 
	rental.site_id = '#application.zcore.functions.zescape(request.zOS.globals.id)#' and 
	rental_deleted='0' ";
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	variables.queueSortCom.returnJson();
	application.zcore.functions.zRequireJquery();
	application.zcore.functions.zRequireJqueryUI();
	</cfscript> 
	<h2 style="display:inline;">Manage Rentals | </h2>
	<cfscript>
	this.displayNavigation();
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
	<script>
	/* <![CDATA[ */
	zArrDeferredFunctions.push(function(){
		//By default hide the tax field and the special rate dialog box
		$('##taxSubField').hide();
		$('##specialRateDialog').dialog({ 
			autoOpen: false,
			title: "Add special rate"
		});			
		//Logic for when a propery doesn't have the tax rate set yet
		$('##addTax').click(function() {
			$(this).hide();
			$('##taxSubField').fadeIn(300);return false;
		});
		//Logic for when a property already has a tax rate setup
		$('##editTax').click(function(){
			$(this).hide();
			$('##taxSubField').fadeIn(300);return false;
		});
		//Open the dialog box when you click on the link
		$('##addSpecial').click(function(){
			$('##specialRateDialog').dialog('open');
		});
		//As the user types the rate, auto-calculate and display the result
		$('##discountRate').keyup(function(){
			var currentVal = $(this).val();
			var rentalRate = jsRentalRate;
			var specialRate = jsRentalRate-currentVal;
		
			$('##discountDisplay').val(specialRate);
		});
	});	
	
	function updateDiscount(rateResult){
		$('##specialRateDialog').dialog('close');
		$('##discountRateField').val(rateResult);
	};
	function setDateOffset2(formName,field1,field2,period,quantity){
		sMon = document[formName][field1+"_month"];
		sDay = document[formName][field1+"_day"];
		sYear = document[formName][field1+"_year"];
		eMon = document[formName][field2+"_month"];
		eDay = document[formName][field2+"_day"];
		eYear = document[formName][field2+"_year"];
		if(sMon && sDay && sYear && eMon && eDay && eYear){
			myDate = new Date(sYear.options[sYear.selectedIndex].text, sMon.selectedIndex, parseInt(sDay.options[sDay.selectedIndex].text));
			
			if(period == "day"){
				myDate2 = new Date(sYear[sYear.selectedIndex].text, sMon.selectedIndex, parseInt(sDay[sDay.selectedIndex].text)+quantity);
			}else if(period == "year"){
				myDate2 = new Date(parseInt(sYear[sYear.selectedIndex].text)+quantity, sMon.selectedIndex, parseInt(sDay[sDay.selectedIndex].text));
			}else if(period == "month"){
				myDate2 = new Date(sYear[sYear.selectedIndex].text, parseInt(sMon.selectedIndex)+quantity, parseInt(sDay[sDay.selectedIndex].text));
			}
			eMon.selectedIndex = parseInt(myDate2.getMonth());
			eDay.options[parseInt(myDate2.getDate())-1].selected = true;
			for(i=0;i<eYear.options.length;i++){
				if(eYear.options[i] != undefined && parseInt(eYear.options[i].text) == myDate2.getFullYear()){
					eYear.selectedIndex = i;
				}
			}
			eMon.onchange();
		}
	}
	function updateOffset22(val,type){
		setDateOffset2("calSearch","search_start_date","search_end_date", "day",2);
	} /* ]]> */
	</script>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qProp=0;
	var ts=0;
	var rs=0;
	var arrImages=0;
	var i=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.1");
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="rental.rental_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql=" SELECT * #db.trustedSQL(rs.select)# FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	#db.trustedSQL(rs.leftJoin)# 
	WHERE rental.site_id = #db.param(request.zOS.globals.id)# and 
	rental_deleted = #db.param(0)# 
	GROUP BY rental.rental_id 
	order by rental_sort ASC, rental_name";
	qProp=db.execute("qProp");
	</cfscript>
	<p>To display promotional text for a rental, click "edit" and enter text in the "Special Message" field.</p>
	<table id="sortRowTable" class="table-list" style="border-spacing:0px; width:100%;">
		<thead>
		<tr>
			<th>ID</th>
			<th>Photo</th>
			<th>Rental Name</th>
			<th>Address</th>
			<th>BR/BA</th>
			<th>Regular Rate</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>
		<cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
			<tr style="background-color:##EFEFEF;">
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>All Properties</td>
				<td colspan="2">&nbsp;</td>
				<td><a href="/z/rental/admin/rates/add?rental_id=">Add Special Rate</a> | 
				<a href="/z/rental/admin/rates/rentalRates?rental_id=">Special Rates</a></td>
			</tr>
		</cfif>
		</thead>
		<tbody>
		<cfloop query="qProp">
		<tr #variables.queueSortCom.getRowHTML(qProp.rental_id)# <cfif qProp.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.rental_id#</td>
			<td style="vertical-align:top; width:100px; "><cfscript>
			ts=structnew();
			ts.image_library_id=qProp.rental_image_library_id;
			ts.output=false;
			ts.query=qProp;
			ts.row=qProp.currentrow;
			ts.size="100x70";
			ts.crop=0;
			ts.count = 1; // how many images to get
			//application.zcore.functions.zdump(ts);
			arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts); 
			for(i=1;i LTE arraylen(arrImages);i++){
				writeoutput('<img src="'&arrImages[i].link&'" />');
			}

			variables.queueSortCom.getRowStruct(qProp.rental_id);
			</cfscript></td>
			<td>#qProp.rental_name#</td>
			<td>#qProp.rental_internal_address#</td>
			<td><cfif qProp.rental_beds NEQ 0>
					#qProp.rental_beds#
				</cfif>
				/
				<cfif qProp.rental_bath NEQ 0>
					#qProp.rental_bath#
				</cfif>
			<td>#qProp.rental_rate#</td>
			<td>#variables.queueSortCom.getAjaxHandleButton(qProp.rental_id)#</td>
			<td><!--- #variables.queueSortCom.getLinks(qProp.recordcount, qProp.currentrow, '/z/rental/admin/rates/#form.method#?rental_id=#qProp.rental_id#', "vertical-arrows")#  --->
			<a href="#application.zcore.app.getAppCFC("rental").getRentalLink(qProp.rental_id,qProp.rental_name,qProp.rental_url)#" target="_blank">View</a> | 
			<a href="/z/rental/admin/rates/editRental?rental_id=#qProp.rental_id#">Edit</a> |
				<cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
					<a href="/z/rental/admin/rates/add?rental_id=#qProp.rental_id#">Add Special Rate</a> | <a href="/z/rental/admin/rates/rentalRates?rental_id=#qProp.rental_id#">Special Rates</a> |
				</cfif>
				<cfif qProp.rental_enable_calendar EQ 1 and application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1>
					<a href="/z/rental/admin/availability/select?rental_id=#qProp.rental_id#">Calendar</a> |
				</cfif>
				<cfif not application.zcore.functions.zIsForceDeleteEnabled(qProp.rental_url)>
					Delete disabled
				<cfelse>
					<a href="/z/rental/admin/rates/deleteRental?rental_id=#qProp.rental_id#">Delete</a> 
				</cfif></td>
		</tr>
		</cfloop>
		</tbody>
	</table>
</cffunction>

<cffunction name="rentalRates" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qProp=0;
	var qRates=0;
	variables.init();
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_active = #db.param(1)# and 
	rental_id = #db.param(form.rental_id)# and 
	rental.site_id = #db.param(request.zOS.globals.id)#";
	qProp=db.execute("qProp");
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rate", request.zos.zcoreDatasource)# rate 
	WHERE rental_id = #db.param(form.rental_id)# and 
	rate.site_id = #db.param(request.zOS.globals.id)# and 
	rate_deleted = #db.param(0)#
	ORDER BY rate_period DESC, rate_sort ASC ";
	qRates=db.execute("qRates");
	</cfscript>
	<h2>Special Rates for #qprop.rental_name#</h2>
	<p>Rates that appear closer to the top are applied first. You can click edit and type a sort number to change their order.</p>
	<table style="margin-left:auto; margin-right:auto; border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th>name</th>
				<th>start</th>
				<th>end</th>
				<th>rate</th>
				<th>min ## of nights</th>
				<th>Special</th>
				<th>coupon code</th>
				<th>Admin</th>
			</tr>
			<cfloop query = "qRates">
			<tr>
				<td>#qRates.rate_event_summary#</td>
				<td>#DateFormat(qRates.rate_start_date,'mm-dd-yyyy')#</td>
				<td>#DateFormat(qRates.rate_end_date,'mm-dd-yyyy')#</td>
				<td>#qRates.rate_rate#</td>
				<td>#qRates.rate_period#</td>
				<td><cfif qRates.rate_coupon_type EQ 1>
						#round(qRates.rate_coupon)# free night(s)
					<cfelseif qRates.rate_coupon_type EQ 2>
						#qRates.rate_coupon#% off
					<cfelse>
						N/A
					</cfif></td>
				<td><cfif qRates.rate_coupon_code neq "xxxxx">
						#qRates.rate_coupon_code#
					<cfelse>
						none
					</cfif></td>
				<td><a href="/z/rental/admin/rates/edit?rental_id=#qRates.rental_id#&amp;rental_id=#qRates.rental_id#">Edit</a> | 
				<a href="/z/rental/admin/rates/delete?rental_id=#qRates.rental_id#&amp;rental_id=#qRates.rental_id#">Delete</a></td>
			</tr>
			</cfloop>
	</table>
</cffunction>

<cffunction name="deleteRental" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rentals", true);
    form.rental_id=application.zcore.functions.zso(form, 'rental_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id = #db.param(form.rental_id)# and 
	rental.site_id = #db.param(request.zOS.globals.id)# and 
	rental_deleted=#db.param(0)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Rental ###form.rental_id# doesn't exist.");
        application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.rental_image_library_id);
        db.sql="DELETE FROM #request.zos.queryObject.table("rate", request.zos.zcoreDatasource)#  
		WHERE  rental_id=#db.param(form.rental_id)# and 
		rate.site_id = #db.param(request.zOS.globals.id)# and 
		rate_deleted=#db.param(0)#";
		result = db.execute("result");
        db.sql="DELETE FROM #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)#  
		WHERE  rental_id=#db.param(form.rental_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_x_category_deleted=#db.param(0)#";
		result = db.execute("result");
        db.sql="DELETE FROM #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)#  
		WHERE  rental_id=#db.param(form.rental_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_x_amenity_deleted=#db.param(0)#";
		result = db.execute("result");
        db.sql="DELETE FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)#  
		 WHERE rental_id=#db.param(form.rental_id)# and 
		 rental.site_id = #db.param(request.zOS.globals.id)# and 
		rental_deleted=#db.param(0)#";
		result = db.execute("result");
		
		application.zcore.app.getAppCFC("rental").searchIndexDeleteRental(form.rental_id, false);
		variables.queueSortCom.sortAll();

		application.zcore.app.getAppCFC("rental").updateRewriteRules();	
        application.zcore.status.setStatus(request.zsid, "Rental deleted successfully.");
        application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid="&request.zsid);
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this rental?<br />
		<br />
		#qCheck.rental_name#<br />
		<br />
		<a href="/z/rental/admin/rates/deleteRental?confirm=1&amp;rental_id=#form.rental_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/rental/admin/rates/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var result=0;
	var qCheck=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rentals", true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rate", request.zos.zcoreDatasource)# rate 
	LEFT JOIN #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental ON 
	rental.rental_id = rate.rental_id and 
	rental.site_id = #db.param(request.zOS.globals.id)# and 
	rental_deleted = #db.param(0)#
	WHERE rate.rental_id = #db.param(form.rental_id)# and 
	rate_deleted = #db.param(0)# and 
	rate.site_id = #db.param(request.zOS.globals.id)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Rental missing");
        application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
        db.sql="DELETE FROM #request.zos.queryObject.table("rate", request.zos.zcoreDatasource)#  
		WHERE  rental_id=#db.param(form.rental_id)# and
		 rate.site_id = #db.param(request.zOS.globals.id)#";
		result = db.execute("result");
        application.zcore.status.setStatus(request.zsid, "Special rate deleted successfully.");
        application.zcore.functions.zRedirect("/z/rental/admin/rates/rentalRates?rental_id="&application.zcore.functions.zso(form, 'rental_id')&"&zsid="&request.zsid);
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this special rate?<br />
			<br />
			<cfloop query = "qCheck">
				<cfif qCheck.rental_name NEQ "">
					Rental: #qCheck.rental_name#
				</cfif>
				<table  style="margin-left:auto; margin-right:auto; border-spacing:0px; width:100%;"  class="table-list">
					<tr>
						<th>name</th>
						<th>start</th>
						<th>end</th>
						<th>rate</th>
						<th>min ## of nights</th>
						<th>Special</th>
						<th>coupon code</th>
						<th>Admin</th>
					</tr>
					<tr>
						<td>#qCheck.rate_event_summary#</td>
						<td>#DateFormat(qCheck.rate_start_date,'mm-dd-yyyy')#</td>
						<td>#DateFormat(qCheck.rate_end_date,'mm-dd-yyyy')#</td>
						<td>#qCheck.rate_rate#</td>
						<td>#qCheck.rate_period#</td>
						<td><cfif qCheck.rate_coupon_type EQ 1>
								#round(qCheck.rate_coupon)# free night(s)
							<cfelseif qCheck.rate_coupon_type EQ 2>
								#qCheck.rate_coupon#% off
							<cfelse>
								N/A
							</cfif></td>
						<td><cfif qCheck.rate_coupon_code neq "xxxxx">
								#qCheck.rate_coupon_code#
							<cfelse>
								none
							</cfif></td>
						<td></td>
					</tr>
				</table>
				<br />
			</cfloop>
			<a href="/z/rental/admin/rates/delete?confirm=1&amp;rental_id=#form.rental_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/rental/admin/rates/index">No</a> </h2>
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
	var myForm={};
	var error=0;
	var qCheck=0;
	var ts=0;
	var errors=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rentals", true);
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_id = #db.param(form.rental_id)# and 
		rental.site_id = #db.param(request.zOS.globals.id)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Rental missing");
			application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid="&request.zsid);
		}
	}
	error = false;
	form.rate_day=',#application.zcore.functions.zso(form,'rate_day')#,';
	form.rate_property=',#application.zcore.functions.zso(form,'rate_property')#,';
	if(form.rate_coupon_type EQ 0){
		myForm.rate_period.required = true;
		myForm.rate_period.friendlyName = "Period";
		myForm.rate_rate.required = true;
		myForm.rate_rate.friendlyName = "Rate";
	}
	form.rate_start_date = application.zcore.functions.zGetDateSelect("rate_start_date", "yyyy-mm-dd");
	form.rate_end_date = application.zcore.functions.zGetDateSelect("rate_end_date", "yyyy-mm-dd");
	if((form.rate_start_date EQ false or form.rate_end_date EQ false) and application.zcore.functions.zso(form, 'rate_event_hide',true) EQ 0 and (form.method EQ "insert" or qCheck.rate_event_hide NEQ 1)){	
		application.zcore.status.setStatus(request.zsid, "Dates are incorrectly formatted.",form,true);
		if(form.method EQ "insert"){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/add?rental_id=#form.rental_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/rental/admin/rates/edit?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
	}
	if(datecompare(form.rate_start_date, form.rate_end_date) GT 0){	
		application.zcore.status.setStatus(request.zsid, "Start date must be before the end date.",form,true);
		if(form.method EQ "insert"){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/add?rental_id=#form.rental_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/rental/admin/rates/edit?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
	}
	
	
	myForm.rate_rate.number = true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	form.site_id=request.zos.globals.id;
	if(form.rate_coupon_type EQ 1){
		form.rate_coupon=form.rate_coupon_number1;
		form.rate_day=",mon,tue,wed,thu,fri,sat,sun,";
	}else if(form.rate_coupon_type EQ 2){
		form.rate_coupon=form.rate_coupon_number2;
	}else{
		form.rate_coupon=0;
	}
	if(form.method EQ "insert"){
		if(errors){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/add?zsid=#request.zsid#");
		}
		if(error){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/add?zsid="&request.zsid);
		}
		ts=StructNew();
		ts.table="rate";
		ts.struct=form;
		ts.datasource=request.zos.zcoreDatasource;
		form.rental_id = application.zcore.functions.zInsert(ts);
		if(form.rental_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Rate couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/add?zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Rate added successfully.");
			application.zcore.functions.zRedirect("/z/rental/admin/rates/rentalRates?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
	
	}else{
		if(errors){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/edit?rental_id=#form.rental_id#&zsid=#request.zsid#");
		}
		if(application.zcore.functions.zso(form,'rental_id') EQ ""){
			application.zcore.status.setStatus(request.zsid, "Rate ID is required.",form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/rentalRates?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
		if(error){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/edit?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
		ts=StructNew();
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="rate";
		ts.struct=form;
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Rate failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/edit?rental_id=#form.rental_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Rate updated successfully.");
			application.zcore.functions.zRedirect("/z/rental/admin/rates/rentalRates?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="insertRental" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateRental();
	</cfscript>
</cffunction>

<cffunction name="updateRental" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var uniqueChanged=0;
	var qCheck=0;
	var error=0;
	var errors=0;
	var arrCatId=0;
	var ts=0;
	var q=0;
	var redirecturl=0;
	var i=0;
	var newSort=0;
	var qC=0;
	var arrD=0;
	var tempLink=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rentals", true);
	form.rental_id=application.zcore.functions.zso(form, 'rental_id');
	uniqueChanged=false;
	if(form.method EQ 'insertRental' and application.zcore.functions.zso(form, 'rental_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ "updateRental"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_id = #db.param(form.rental_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_deleted=#db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Rental is missing");
			application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid="&request.zsid);
		}
		if(structkeyexists(form, 'rental_url') and qcheck.rental_url NEQ form.rental_url){
			uniqueChanged=true;	
		}
	}else{
		db.sql=" SELECT max(rental_sort) sort 
		FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE  site_id = #db.param(request.zOS.globals.id)# and 
		rental_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0 or qCheck.sort EQ ""){
			form.rental_sort=1;
		}else{
			form.rental_sort=qCheck.sort+1;
		}
	}
	error=false;
	errors=false;
	
	if(application.zcore.functions.zso(form,'rental_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'rental_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}
	if(form.method EQ "insertRental"){
		if(errors){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/addRental?zsid=#request.zsid#");
		}
		if(error){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/addRental?zsid="&request.zsid);
		}
	}else{
		if(errors){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rates/editRental?rental_id=#form.rental_id#&zsid=#request.zsid#");
		}
		if(error){
			application.zcore.functions.zRedirect("/z/rental/admin/rates/editRental?rental_id=#form.rental_id#&zsid="&request.zsid);
		}
	}
	if(form.rental_available_start_date NEQ "" and isDate(form.rental_available_start_date)){
		form.rental_available_start_date=dateformat(form.rental_available_start_date,'yyyy-mm-dd');	
	}else{
		form.rental_available_start_date=now();
	}
	form.rental_updated_datetime=request.zos.mysqlnow;
	arrCatId=listtoarray(application.zcore.functions.zso(form, 'rental_category_id_list'),",",false);
	form.rental_category_id_list=","&application.zcore.functions.zso(form, 'rental_category_id_list')&",";
	
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="rental";
	if(form.method EQ "insertRental"){
		form.rental_id = application.zcore.functions.zInsert(ts);
		if(form.rental_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rates/addRental?zsid="&request.zsid);
		}else{
			redirecturl=("/z/rental/admin/rates/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental failed to update.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rates/editRental?rental_id=#form.rental_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Rental updated successfully.");
			redirecturl=("/z/rental/admin/rates/index?zsid="&request.zsid);
		}
	}
	
	db.sql="update #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category 
	set rental_x_category_updating=#db.param('1')#,
	rental_x_category_updated_datetime=#db.param(request.zos.mysqlnow)#  
	where rental_id = #db.param(form.rental_id)# and 
	rental_x_category_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	q=db.execute("q");
	for(i=1;i LTE arraylen(arrCatId);i++){
		db.sql="select max(rental_x_category_sort) s 
		from #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category 
		where rental_category_id = #db.param(arrCatId[i])# and 
		rental_x_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qC=db.execute("qC");
		newSort=1;
		if(qC.recordcount NEQ 0 and qC.s NEQ ""){
			newSort=qC.s+1;
		}
		db.sql="insert into #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)#  
		set rental_x_category_sort=#db.param(newSort)#, 
		rental_x_category_updating=#db.param('0')#, 
		rental_category_id = #db.param(arrCatId[i])#, 
		rental_id = #db.param(form.rental_id)#, 
		rental_x_category_updated_datetime=#db.param(request.zos.mysqlnow)#,
		rental_x_category_deleted=#db.param(0)#, 
		site_id = #db.param(request.zos.globals.id)#
		 on duplicate key update rental_x_category_updating=#db.param('0')#";
		db.execute("q");
		
	} 
	db.sql="delete from #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)#  
	where rental_x_category_updating=#db.param('1')# and 
	rental_id = #db.param(form.rental_id)# and 
	rental_x_category_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	q=db.execute("q");
	
	arrD=arraynew(1);
	for(i=1;i LTE 100;i++){
		if(structkeyexists(form, 'rental_amenity_id_list'&i) and right(form['rental_amenity_id_list'&i],2) EQ "_1"){
			arrayappend(arrD,mid(form['rental_amenity_id_list'&i],1,len(form['rental_amenity_id_list'&i])-2));
		}
	}
	db.sql="update #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)# rental_x_amenity 
	set rental_x_amenity_updating=#db.param('1')#,
	rental_x_amenity_updated_datetime=#db.param(request.zos.mysqlnow)#  
	where rental_id=#db.param(form.rental_id)# and 
	rental_x_amenity_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)#";
	q=db.execute("q");
	for(i=1;i lte arraylen(arrD);i++){ 
		db.sql="insert into #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)#  
		set site_id=#db.param(request.zos.globals.id)#, 
		rental_x_amenity_updating=#db.param('0')#, 
		rental_id=#db.param(form.rental_id)#, 
		rental_x_amenity_updated_datetime=#db.param(request.zos.mysqlnow)#,
		rental_x_amenity_deleted=#db.param(0)#, 
		rental_amenity_id=#db.param(arrD[i])#	";
		db.execute("q");
	} 
	db.sql="delete from #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)#  
	where rental_x_amenity_updating=#db.param('1')# and 
	rental_x_amenity_deleted = #db.param(0)# and 
	rental_id=#db.param(form.rental_id)# and 
	site_id =#db.param(request.zos.globals.id)#";
	q=db.execute("q");
	
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'rental_image_library_id'));
	
	application.zcore.app.getAppCFC("rental").searchReIndexRental(form.rental_id, false);
	if(uniqueChanged){
		res=application.zcore.app.getAppCFC("rental").updateRewriteRules();	
		if(res EQ false){
			application.zcore.template.fail("Failed to process rewrite URLs for rental_category_id = #db.param(form.rental_category_id)# and rental_category_url = #db.param(application.zcore.functions.zso(form, 'rental_category_url'))#.");
		}
	}	
	
	if(structkeyexists(request.zsession, "rental_rates_return"&form.rental_id)){
		tempLink=request.zsession["rental_rates_return"&form.rental_id];
		structdelete(request.zsession,"rental_rates_return"&form.rental_id);
		application.zcore.functions.z301Redirect(tempLink);
	}else{
		application.zcore.functions.zredirect(redirecturl);
	}
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
	var qCat=0;
	var qRate=0;
	var thisYear=0;
	var qProperties=0;
	var selectStruct=0;
	var currentMethod=form.method;
	variables.init();
	form.rental_id=application.zcore.functions.zso(form, 'rental_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rate", request.zos.zcoreDatasource)# rate 
	WHERE rental_id = #db.param(form.rental_id)# and 
	rate_deleted = #db.param(0)# and 
	rate.site_id = #db.param(request.zOS.globals.id)# ";
	qRate=db.execute("qRate");
	application.zcore.functions.zQueryToStruct(qRate,form,'rental_id');
	thisYear = year(now()); // used for dateSelect
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
		<cfelse>
			Add
		</cfif>
		Rate</h2>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/rental/admin/rates/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?rental_id=#form.rental_id#" method="post" style="margin:0px; padding:0px;">
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Select Rental","member.rental.edit rental_id")#</th>
				<td><cfscript>
				if(form.rental_id EQ ''){
					form.rental_id = application.zcore.functions.zso(form, 'rental_id');
				} 
				db.sql="SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
				WHERE rental_active = #db.param(1)# and 
				rental_deleted = #db.param(0)# and 
				rental.site_id = #db.param(request.zOS.globals.id)# 
				ORDER BY rental_name ";
				qProperties=db.execute("qProperties");
				selectStruct = StructNew();
				selectStruct.name = "rental_id";
				selectStruct.query = qProperties;
				selectStruct.queryLabelField = "rental_name";
				selectStruct.queryValueField = "rental_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<script>
			/* <![CDATA[ */
			function changeDiscount(val){
				var ofs=document.getElementById("otherFields");
				var ofs2=document.getElementById("otherFields2");
				if(val != 0){
					ofs.style.display="none";
					if(val == 1){
						ofs2.style.display="none";	
					}else{
						ofs2.style.display="block";
					}
				}else{
					ofs.style.display="block";
					ofs2.style.display="block";
				}
			}
			/* ]]> */
			</script>
			<tr>
				<th style="vertical-align:top;white-space:nowrap;>#application.zcore.functions.zOutputHelpToolTip("Event Name","member.rental.edit rate_event_summary")#</th>
			<td colspan="2"><input name="rate_event_summary" size="40" type="text" value="#form.rate_event_summary#" maxlength="100" size="8" />
					<br />
					(i.e. Bike Week/Christmas/Memorial Day/Summer Rate)
					</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Start Date","member.rental.edit rate_start_date")#</th>
				<td colspan="2"><cfscript>
				writeoutput(application.zcore.functions.zDateSelect("rate_start_date", "rate_start_date", thisYear, thisYear+1));
				</cfscript></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("End Date","member.rental.edit rate_end_date")#</th>
				<td colspan="2"><cfscript>
				writeoutput(application.zcore.functions.zDateSelect("rate_end_date", "rate_end_date", thisYear, thisYear+1));
				</cfscript></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Minimum<br />## of Nights","member.rental.edit rate_period")#</th>
				<td colspan="2"><input name="rate_period" type="text" value="#application.zcore.functions.zso(form, 'rate_period',true,1)#" size="8" />
					<span class="highlight">Required</span></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Discount","member.rental.edit discount")#</th>
				<td colspan="2">#application.zcore.functions.zOutputHelpToolTip("Choose one of the following three options:","member.rental.edit rate_coupon_type")# <br />
					<input type="radio" name="rate_coupon_type" <cfif application.zcore.functions.zso(form, 'rate_coupon_type',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" onclick="changeDiscount(1);">
## of free nights:
					<input name="rate_coupon_number1" type="text" value="<cfif form.rate_coupon_type EQ 1>#round(form.rate_coupon)#</cfif>" size="8" />
					<br />
					<input type="radio" name="rate_coupon_type" <cfif application.zcore.functions.zso(form, 'rate_coupon_type',true) EQ 2>checked="checked"</cfif> value="2" style="border:none; background:none;" onclick="changeDiscount(2);">
					percent off:
					<input name="rate_coupon_number2" size="5" type="text" value="<cfif form.rate_coupon_type EQ 2>#form.rate_coupon#</cfif>" size="8" />
					% (Enter a number between 0 and 100)<br />
					<input type="radio" name="rate_coupon_type" value="0" <cfif application.zcore.functions.zso(form, 'rate_coupon_type',true) EQ 0>checked="checked"</cfif> size="3" style="border:none; background:none;" onclick="changeDiscount(0);">
					no discount </td>
			</tr>
			<cfif form.rental_id EQ 0>
				<tr>
					<th width="100" style="vertical-align:top;"> #application.zcore.functions.zOutputHelpToolTip("Excluding","member.rental.edit select_rental_id")# </th>
					<td style="vertical-align:top; ">
						<cfscript>
						db.sql=" select *
						from #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental
						where  rental_active=#db.param(1)# and 
						rental_deleted = #db.param(0)# and 
						rental.site_id = #db.param(request.zOS.globals.id)# 
						ORDER BY rental_name ";
						qCat=db.execute("qCat");
						if(qcat.recordcount EQ 0){
							application.zcore.status.setStatus(request.zsid,"You must add at least one rental before adding articles.");
							application.zcore.functions.zRedirect("/z/rental/admin/rates/index?zsid=#request.zsid#");
						}
						selectStruct = StructNew();
						selectStruct.name = "select_rental_id";
						selectStruct.query = qCat;
						//selectStruct.style="monoMenu";
						selectStruct.queryLabelField = "rental_name";
						selectStruct.queryValueField = "rental_id";
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript>
						<input type="button" name="addCat" onclick="setCatBlock(true);" value="Add" />
						Select a rental and click add.  You can associate this article to multiple categories.<br />
						<br />
						<div id="rentalBlock"></div>
						<script>
						/* <![CDATA[ */
						var arrBlock=new Array();
						var arrBlockId=new Array();
						<cfif len(form.rate_property) NEQ 0>
							<cfset rate_property=mid(form.rate_property,2,len(form.rate_property)-2)>
						</cfif>
						<cfif form.rate_property NEQ "">
							<cfscript>
							sql="#db.param(replace(application.zcore.functions.zescape(form.rate_property),",","','","ALL"))#";
							db.sql="
							SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
							WHERE rental_id IN (#db.param(sql)#) and 
							rental_deleted = #db.param(0)# and 
							rental.site_id = #db.param(request.zOS.globals.id)#";
							qCat=db.execute("qCat");</cfscript>
							<cfloop query="qCat">arrBlockId.push(#qCat.rental_id#);arrBlock.push("#jsstringformat(qCat.rental_name)#");</cfloop>
						</cfif>
						function removeCat(id){
							var ab=new Array();
							var ab2=new Array();
							for(i=0;i<arrBlock.length;i++){
								if(id!=i){ ab.push(arrBlock[i]); ab2.push(arrBlockId[i]); }
							}
							arrBlock=ab;
							arrBlockId=ab2;
							setCatBlock(false);
						}
						function setCatBlock(checkField){
							if(checkField){
								var cid=parseInt(document.myForm.select_rental_id.options[document.myForm.select_rental_id.selectedIndex].value);
								var cname=document.myForm.select_rental_id.options[document.myForm.select_rental_id.selectedIndex].text;
								if(isNaN(cid)){
									alert('Please select a rental before clicking the add button.');
									return;
								}
								for(var i=0;i<arrBlockId.length;i++){
									if(arrBlockId[i] == cid){
										alert('This rental is already excluded from this rate.');
										return;
									}
								}
								arrBlockId.push(cid);
								arrBlock.push(cname);
							}
							var cb=document.getElementById("rentalBlock");
							arrBlock2=new Array();
							arrBlock2.push('<table style="border-spacing:0px;border:1px solid ##CCCCCC;">');
							for(var i=0;i<arrBlock.length;i++){
								var s='style="background-color:##F2F2F2;"';
								if(i%2==0){
									s="";
								}
								arrBlock2.push('<tr '+s+'><td>'+arrBlock[i]+'</td><td><a href="##" onclick="removeCat('+(arrBlock2.length-1)+'); return false;" title="Click to remove association to this rental.">Remove<\/a><\/td><\/tr>');
							}
							arrBlock2.push('<\/table>');
							arrBlock2.push('<input type="hidden" name="rate_property" value="'+arrBlockId.join(",")+'" />');
							cb.innerHTML=arrBlock2.join('');
							if(arrBlock2.length==0){
								cb.style.display="inline";
							}else{
								cb.style.display="block";
							}
						}
						setCatBlock(false);
						/* ]]> */
						</script></td>
				</tr>
			<cfelse>
				<input type="hidden" name="rate_property" value="" />
			</cfif>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Override<br />Holiday Rate","member.rental.edit rate_override_holiday")#</th>
				<td colspan="2"><input type="radio" name="rate_override_holiday" <cfif application.zcore.functions.zso(form, 'rate_override_holiday',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="rate_override_holiday" <cfif application.zcore.functions.zso(form, 'rate_override_holiday',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Sort ##","member.rental.edit rate_sort")#</th>
				<td  style="white-space:nowrap;"><input name="rate_sort" type="text" value="<cfif form.rate_sort NEQ 0>#form.rate_sort#</cfif>" size="10"></td>
			</tr>
		</table>
		<table style="width:100%; border-spacing:0px;" class="table-list" id="otherFields2">
			<tr>
				<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Days of Week","member.rental.edit rate_day")#</th>
				<td colspan="2"><input type="checkbox" name="rate_day" value="mon" <cfif form.rate_day contains ",mon,">checked="checked"</cfif> style="border:none; background:none;" />
					Monday <br />
					<input type="checkbox" name="rate_day" value="tue" <cfif form.rate_day contains ",tue,">checked="checked"</cfif> style="border:none; background:none;" />
					Tuesday<br />
					<input type="checkbox" name="rate_day" value="wed" <cfif form.rate_day contains ",wed,">checked="checked"</cfif> style="border:none; background:none;" />
					Wednesday <br />
					<input type="checkbox" name="rate_day" value="thu" <cfif form.rate_day contains ",thu,">checked="checked"</cfif> style="border:none; background:none;" />
					Thursday <br />
					<input type="checkbox" name="rate_day" value="fri" <cfif form.rate_day contains ",fri,">checked="checked"</cfif> style="border:none; background:none;" />
					Friday <br />
					<input type="checkbox" name="rate_day" value="sat" <cfif form.rate_day contains ",sat,">checked="checked"</cfif> style="border:none; background:none;" />
					Saturday <br />
					<input type="checkbox" name="rate_day" value="sun" <cfif form.rate_day contains ",sun,">checked="checked"</cfif> style="border:none; background:none;" />
					Sunday <br /></td>
			</tr>
		</table>
		<table style="width:100%; border-spacing:0px;" class="table-list" id="otherFields">
			<tr>
				<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Rate","member.rental.edit rate_rate")#</th>
				<td colspan="2" style="white-space:nowrap;"><input name="rate_rate" type="text" value="#application.zcore.functions.zso(form, 'rate_rate',true)#" size="8">
					<span class="highlight">Required</span></td>
			</tr>
			</tr>
			
			<cfscript>
			if(form.rate_day EQ ''){
				form.rate_day=',mon,tue,wed,thu,fri,sat,sun,';
			}
			</cfscript>
		</table>
		<br />
		<table style="width:100%; border-spacing:0px;" class="table-list" id="otherFields">
			<tr>
				<th style="width:100px;">&nbsp;</th>
				<td colspan="2"><button type="submit" class="table-shadow" value="submitForm">
					<cfif currentMethod EQ "edit">
						Update
					<cfelse>
						Add
					</cfif>
					Rate</button>
					<button type="button" class="table-shadow" name="cancel" value="Cancel" onclick="document.location = '/z/rental/admin/rates/rentalRates?rental_id=#form.rental_id#';">Cancel</button></td>
			</tr>
		</table>
	</form>
	<script>
	/* <![CDATA[ */changeDiscount(#application.zcore.functions.zso(form, 'rate_coupon_type',true)#);/* ]]> */
	</script>
</cffunction>

<cffunction name="addRental" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	this.editRental();
	</cfscript>
</cffunction>

<cffunction name="editRental" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	var htmlEditor=0;
	var tempMeta=0;
	var qCC=0;
	var childStruct=0;
	var ts=0;
	var i=0;
	var qProp2=0;
	var tabCom=0;
	var cancelUrl=0;
	var qProp=0;
	var thisYear=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.2");
	form.rental_id=application.zcore.functions.zso(form, 'rental_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id = #db.param(form.rental_id)# and 
	rental.site_id = #db.param(request.zOS.globals.id)# and 
	rental_deleted=#db.param(0)#";
	qProp=db.execute("qProp");
	application.zcore.functions.zQueryToStruct(qProp,form,"site_id");
	thisYear = year(now()); // used for dateSelect
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "editRental">
			Edit
		<cfelse>
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		</cfif>
		#form.rental_name# Rental</h2>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/rental/admin/rates/<cfif currentMethod EQ "editRental">updateRental<cfelse>insertRental</cfif>?rental_id=#form.rental_id#" method="post" style="margin:0px; padding:0px;">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-rentals-edit");
		cancelURL="/z/rental/admin/rates/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()#
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list" id="otherFields">
			<tr>
				<th style="width:1%; white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Category","member.rental.editRental rental_category_id_list")#</th>
				<td style="white-space:nowrap;">
					<cfscript>
					db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
					WHERE rental_category_parent_id = #db.param(0)# and 
					site_id = #db.param(request.zOS.globals.id)# and 
					rental_category_deleted = #db.param(0)#
					order by rental_category_sort ASC, rental_category_name ASC";
					qProp2=db.execute("qProp2");
					childStruct=application.zcore.app.getAppCFC("rental").getAllCategory(qProp2,0,0);
					for(i=1;i LTE arraylen(childStruct.arrCategoryId);i++){
						writeoutput('<input type="checkbox" name="rental_category_id_list" value="#childStruct.arrCategoryId[i]#" ');
						if(find(",#childStruct.arrCategoryId[i]#,",form.rental_category_id_list) NEQ 0){ writeoutput('checked'); }
						writeoutput(' style="border:none; background:none;" /> #replace(childStruct.arrCategoryName[i],"_","&nbsp;&nbsp;","ALL")#<br />');
					}
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;">#application.zcore.functions.zOutputHelpToolTip("Title","member.rental.editRental rental_name")#</th>
				<td style="white-space:nowrap;"><input name="rental_name" type="text" value="#htmleditformat(form.rental_name)#" size="50"></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;">#application.zcore.functions.zOutputHelpToolTip("Internal Address","member.rental.editRental rental_internal_address")#</th>
				<td style="white-space:nowrap;"><input name="rental_internal_address" type="text" value="#htmleditformat(form.rental_internal_address)#" size="50"><br /> (Hidden from public)</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.rental.editRental rental_image_library_id")#</th>
				<td colspan="2"><cfscript>
				ts=structnew();
				ts.name="rental_image_library_id";
				ts.value=form.rental_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Summary Text","member.rental.editRental rental_description")#</th>
				<td style="vertical-align:top; "><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "rental_description";
				htmlEditor.value			= form.rental_description;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 200;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Full Text","member.rental.editRental rental_text")#</th>
				<td style="vertical-align:top; "><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "rental_text";
				htmlEditor.value			= form.rental_text;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 400;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("City","member.rental.editRental rental_city")#</th>
				<td colspan="2"  style="white-space:nowrap;"><input name="rental_city" type="text" value="#htmleditformat(form.rental_city)#" size="50"></td>
			</tr>
			<tr>
				<th>Searchable Amenities:</th>
				<td>Check the box for each amenity this rental has:<br />
					<table style="border-spacing:0px;">
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Pool","member.rental.editRental rental_pool")#</td>
							<td colspan="2"><input type="radio" name="rental_pool" <cfif application.zcore.functions.zso(form, 'rental_pool',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_pool" <cfif application.zcore.functions.zso(form, 'rental_pool',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Gameroom","member.rental.editRental rental_gameroom")#</td>
							<td colspan="2"><input type="radio" name="rental_gameroom" <cfif application.zcore.functions.zso(form, 'rental_gameroom',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_gameroom" <cfif application.zcore.functions.zso(form, 'rental_gameroom',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Mountain View","member.rental.editRental rental_mountainview")#</td>
							<td colspan="2"><input type="radio" name="rental_mountainview" <cfif application.zcore.functions.zso(form, 'rental_mountainview',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_mountainview" <cfif application.zcore.functions.zso(form, 'rental_mountainview',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Water View","member.rental.editRental rental_waterview")#</td>
							<td colspan="2"><input type="radio" name="rental_waterview" <cfif application.zcore.functions.zso(form, 'rental_waterview',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_waterview" <cfif application.zcore.functions.zso(form, 'rental_waterview',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Hot Tub","member.rental.editRental rental_hottub")#</td>
							<td colspan="2"><input type="radio" name="rental_hottub" <cfif application.zcore.functions.zso(form, 'rental_hottub',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_hottub" <cfif application.zcore.functions.zso(form, 'rental_hottub',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Fireplace","member.rental.editRental rental_fireplace")#</td>
							<td colspan="2"><input type="radio" name="rental_fireplace" <cfif application.zcore.functions.zso(form, 'rental_fireplace',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_fireplace" <cfif application.zcore.functions.zso(form, 'rental_fireplace',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("High Speed Internet","member.rental.editRental rental_highspeedinternet")#</td>
							<td colspan="2"><input type="radio" name="rental_highspeedinternet" <cfif application.zcore.functions.zso(form, 'rental_highspeedinternet',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_highspeedinternet" <cfif application.zcore.functions.zso(form, 'rental_highspeedinternet',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Cable TV","member.rental.editRental rental_cabletv")#</td>
							<td colspan="2"><input type="radio" name="rental_cabletv" <cfif application.zcore.functions.zso(form, 'rental_cabletv',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_cabletv" <cfif application.zcore.functions.zso(form, 'rental_cabletv',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Ocean View","member.rental.editRental rental_oceanview")#</td>
							<td colspan="2"><input type="radio" name="rental_oceanview" <cfif application.zcore.functions.zso(form, 'rental_oceanview',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_oceanview" <cfif application.zcore.functions.zso(form, 'rental_oceanview',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("River View","member.rental.editRental rental_riverview")#</td>
							<td colspan="2"><input type="radio" name="rental_riverview" <cfif application.zcore.functions.zso(form, 'rental_riverview',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_riverview" <cfif application.zcore.functions.zso(form, 'rental_riverview',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<tr>
							<td>#application.zcore.functions.zOutputHelpToolTip("Pet Friendly","member.rental.editRental rental_petfriendly")#</td>
							<td colspan="2"><input type="radio" name="rental_petfriendly" <cfif application.zcore.functions.zso(form, 'rental_petfriendly',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_petfriendly" <cfif application.zcore.functions.zso(form, 'rental_petfriendly',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
								No </td>
						</tr>
						<cfscript>
						db.sql=" SELECT *, if(rental_x_amenity_id IS NULL,#db.param(0)#,#db.param(1)#) checked 
						FROM #request.zos.queryObject.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
						LEFT JOIN #request.zos.queryObject.table("rental_x_amenity", request.zos.zcoreDatasource)# rental_x_amenity ON 
						rental_id = #db.param(form.rental_id)# and 
						rental_x_amenity.rental_amenity_id = rental_amenity.rental_amenity_id and 
						rental_x_amenity.site_id = rental_amenity.site_id and 
						rental_x_amenity_deleted = #db.param(0)#
						where rental_amenity.site_id = #db.param(request.zOS.globals.id)#  and 
						rental_amenity_deleted = #db.param(0)#
						ORDER BY rental_amenity_name ASC ";
						qCC=db.execute("qCC");
						</cfscript>
						<cfloop query="qCC">
						<tr>
							<td>#qCC.rental_amenity_name#:</td>
							<td colspan="2"><input type="radio" name="rental_amenity_id_list#qCC.currentrow#" <cfif qCC.checked EQ 1>checked="checked"</cfif> value="#qCC.rental_amenity_id#_1" style="border:none; background:none;" />
								Yes
								<input type="radio" name="rental_amenity_id_list#qCC.currentrow#" <cfif qCC.checked EQ 0>checked="checked"</cfif> value="#qCC.rental_amenity_id#_0" style="border:none; background:none;" />
								No </td>
						</tr>
						</cfloop>
					</table></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Amenity Description","member.rental.editRental rental_amenities_text")#</th>
				<td style="vertical-align:top; "><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "rental_amenities_text";
				htmlEditor.value			= form.rental_amenities_text;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 300;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Bedrooms","member.rental.editRental rental_beds")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_beds";
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Bathrooms","member.rental.editRental rental_bath")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_bath";
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript></td>
			</tr>
			<tr>
			
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Nightly Rates","member.rental.editRental nightlyRates")#</th>
			<td colspan="1" style="white-space:nowrap;"><table style="border-spacing:0px; padding:0px;">
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Regular Rate","member.rental.editRental rental_rate")#</th>
						<td colspan="1" style="white-space:nowrap;"> $
							<input name="rental_rate" type="text" value="#application.zcore.functions.zso(form, 'rental_rate',true)#" size="8"><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Holiday Rate","member.rental.editRental rental_rate_holiday")#</th>
						<td colspan="2" style="white-space:nowrap;">$
							<input name="rental_rate_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_rate_holiday',true)#" size="8"><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Highest Regular Rate","member.rental.editRental rental_display_regular")#</th>
						<td colspan="2" style="white-space:nowrap;">$
							<input name="rental_display_regular" type="text" value="#application.zcore.functions.zso(form, 'rental_display_regular',true)#" size="8"><br />
							(For display purposes only to show a discount)</td>
					</tr>
					</tr>
					
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Highest Holiday Rate","member.rental.editRental rental_display_holiday")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_display_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_display_holiday',true)#" size="8"><br />
							(For display purposes only to show a discount)</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Cleaning Fee","member.rental.editRental rental_rate_cleaning")#</th>
						<td colspan="2">$
							<input name="rental_rate_cleaning" type="text" value="#form.rental_rate_cleaning#" size="8"></td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest Rate","member.rental.editRental rental_rate_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_rate_addl_guests" value="#form.rental_rate_addl_guests#" class="small" size="10"><br />
							per person</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest<br />Cleaning Rate","member.rental.editRental rental_rate_cleaning_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_rate_cleaning_addl_guests" value="#form.rental_rate_cleaning_addl_guests#" class="small" size="10"><br />
							per person (Additional cleaning charge per guest beyond the max guest limit)</td>
					</tr>
				</table></td>
			</tr>
			
			<tr>
			
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Weekly Rates","member.rental.editRental weeklyRates")#</th>
			<td colspan="1"  style="white-space:nowrap;"><table style="border-spacing:0px; padding:0px;">
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Regular Rate","member.rental.editRental rental_weekly_rate")#</th>
						<td colspan="1"  style="white-space:nowrap;"> $
							<input name="rental_weekly_rate" type="text" value="#application.zcore.functions.zso(form, 'rental_weekly_rate',true)#" size="8"><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Holiday Rate","member.rental.editRental rental_weekly_rate_holiday")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_weekly_rate_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_weekly_rate_holiday',true)#" size="8"><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Highest Regular Rate","member.rental.editRental rental_weekly_display_regular")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_weekly_display_regular" type="text" value="#application.zcore.functions.zso(form, 'rental_weekly_display_regular',true)#" size="8"><br />
							(For display purposes only to show a discount)</td>
					</tr>
					</tr>
					
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Highest Holiday Rate","member.rental.editRental rental_weekly_display_holiday")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_weekly_display_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_weekly_display_holiday',true)#" size="8"><br />
							(For display purposes only to show a discount)</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Cleaning Fee","member.rental.editRental rental_weekly_rate_cleaning")#</th>
						<td colspan="2">$
							<input name="rental_weekly_rate_cleaning" type="text" value="#form.rental_weekly_rate_cleaning#" size="8"></td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest Rate","member.rental.editRental rental_weekly_rate_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_weekly_rate_addl_guests" value="#form.rental_weekly_rate_addl_guests#" class="small" size="10"><br />
							per person</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest<br />Cleaning Rate","member.rental.editRental rental_weekly_rate_cleaning_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_weekly_rate_cleaning_addl_guests" value="#form.rental_weekly_rate_cleaning_addl_guests#" class="small" size="10"><br />
							per person (Additional cleaning charge per guest beyond the max guest limit)</td>
					</tr>
				</table></td>
			</tr>
			
			<tr>
			
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Monthly Rates","member.rental.editRental monthlyRates")#</th>
			<td colspan="1"  style="white-space:nowrap;"><table style="border-spacing:0px; padding:0px;">
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Regular Rate","member.rental.editRental rental_monthly_rate")#</th>
						<td colspan="1"  style="white-space:nowrap;"> $
							<input name="rental_monthly_rate" type="text" value="#application.zcore.functions.zso(form, 'rental_monthly_rate',true)#" size="8" /><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Holiday Rate","member.rental.editRental rental_monthly_rate_holiday")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_monthly_rate_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_monthly_rate_holiday',true)#" size="8" /><br />
							<span class="highlight">Required</span></td>
					</tr>
					<tr>
						<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Highest Regular Rate","member.rental.editRental rental_monthly_display_regular")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_monthly_display_regular" type="text" value="#application.zcore.functions.zso(form, 'rental_monthly_display_regular',true)#" size="8" /><br />
							(For display purposes only to show a discount)</td>
					</tr>
					</tr>
					
					<tr>
						<th style="width:100px;">#application.zcore.functions.zOutputHelpToolTip("Highest Holiday Rate","member.rental.editRental rental_monthly_display_holiday")#</th>
						<td colspan="2"  style="white-space:nowrap;">$
							<input name="rental_monthly_display_holiday" type="text" value="#application.zcore.functions.zso(form, 'rental_monthly_display_holiday',true)#" size="8" /><br />
							(For display purposes only to show a discount)</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Cleaning Fee","member.rental.editRental rental_monthly_rate_cleaning")#</th>
						<td colspan="2">$
							<input name="rental_monthly_rate_cleaning" type="text" value="#form.rental_monthly_rate_cleaning#" size="8" /></td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest Rate","member.rental.editRental rental_monthly_rate_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_monthly_rate_addl_guests" value="#form.rental_monthly_rate_addl_guests#" class="small" size="10" /><br />
							per person</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest<br />Cleaning Rate","member.rental.editRental rental_monthly_rate_cleaning_addl_guests")#</th>
						<td>$
							<input type="text" name="rental_monthly_rate_cleaning_addl_guests" value="#form.rental_monthly_rate_cleaning_addl_guests#" class="small" size="10" /><br />
							per person (Additional cleaning charge per guest beyond the max guest limit)</td>
					</tr>
				</table></td>
			</tr>
			
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Max Guest","member.rental.editRental rental_max_guest")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_max_guest";
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript>
					(The most guests included in the base rates)</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Active?","member.rental.editRental rental_active")#</th>
				<td colspan="2"><input type="radio" name="rental_active" <cfif form.rental_active EQ 1 or form.rental_active EQ "">checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="rental_active" <cfif form.rental_active EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Special Message","member.rental.editRental rental_special")#</th>
				<td colspan="2" style="white-space:nowrap;"><input name="rental_special" type="text" value="#htmleditformat(form.rental_special)#" size="50" /><br />
					(This is a highlighted message to be more visible)</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Flashing special","member.rental.editRental rental_special_flash")#</th>
				<td colspan="2"><input type="radio" name="rental_special_flash" <cfif application.zcore.functions.zso(form, 'rental_special_flash',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes (Blink the above message)
					<input type="radio" name="rental_special_flash" <cfif application.zcore.functions.zso(form, 'rental_special_flash',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
			<cfsavecontent variable="tempMeta"> 
				<script>
				/* <![CDATA[ */ 	
				zArrDeferredFunctions.push(function(){
					var dates = $( "##rental_available_start_date" ).datepicker({
						minDate: 0, 
						maxDate: "+2Y",
						changeMonth: true,
						changeYear: true
					});
				}); 
				/* ]]> */
				</script> 
			</cfsavecontent>
			<cfscript>
			application.zcore.functions.zRequireJquery();
			application.zcore.functions.zRequireJqueryUI();
			application.zcore.template.appendTag("meta",tempMeta);
			</cfscript>
			<tr>
				<th style="white-space:nowrap; width:1%;">#application.zcore.functions.zOutputHelpToolTip("Not Availabile Until","member.rental.editRental rental_available_start_date")#</th>
				<td><input name="rental_available_start_date" id="rental_available_start_date" type="text" size="30" maxlength="50" value="#dateformat(form.rental_available_start_date,'mm/dd/yyyy')#" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Addl Guest Count","member.rental.editRental rental_addl_guest_count")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_addl_guest_count";
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript><br />
					(This allows you to charge extra for each additional guest beyond the max guest limit.)</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Enable Calendar?","member.rental.editRental rental_enable_calendar")#</th>
				<td colspan="2"><input type="radio" name="rental_enable_calendar" <cfif form.rental_enable_calendar EQ 1 or form.rental_enable_calendar EQ "">checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="rental_enable_calendar" <cfif form.rental_enable_calendar EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Lodgix Property Id","member.rental.editRental rental_lodgix_property_id")#</th>
				<td colspan="2"><input type="text" name="rental_lodgix_property_id" value="#htmleditformat(form.rental_lodgix_property_id)#" /></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Rate Description","member.rental.editRental rental_rate_text")#</th>
				<td style="vertical-align:top; "><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "rental_rate_text";
				htmlEditor.value			= form.rental_rate_text;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
				htmlEditor.height		= 300;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Minimum stay?","member.rental.editRental rental_min_stay")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_min_stay";
					selectStruct.hideSelect=true;
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript><br />
					Days (No shorter booking will be allowed.)</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Reserved Days Before","member.rental.editRental rental_reserved_before")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_reserved_before";
					selectStruct.hideSelect=true;
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript><br />
					Days (There must be this number of unreserved days before a booking.)</td>
			</tr>
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Reserved Days After","member.rental.editRental rental_reserved_after")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_reserved_after";
					selectStruct.hideSelect=true;
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript><br />
					Days (There must be this number of unreserved days after a booking.)</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Pet Fee","member.rental.editRental rental_petfriendly_fee")#</th>
				<td>$
					<input type="text" name="rental_petfriendly_fee" value="#form.rental_petfriendly_fee#" class="small" size="10"></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Pet Rate Type","member.rental.editRental rental_petfriendly_type")#</th>
				<td><input type="radio" name="rental_petfriendly_type" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_type',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No Pets Allowed<br />
					<input type="radio" name="rental_petfriendly_type" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_type',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Per Pet Per Day<br />
					<input type="radio" name="rental_petfriendly_type" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_type',true) EQ 2>checked="checked"</cfif> value="2" style="border:none; background:none;" />
					Flat Rate Per Pet<br />
					<input type="radio" name="rental_petfriendly_type" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_type',true) EQ 3>checked="checked"</cfif> value="3" style="border:none; background:none;" />
					Flat Rate</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Pet Cleaning Fee","member.rental.editRental rental_petfriendly_cleaningfee")#</th>
				<td>$
					<input type="text" name="rental_petfriendly_cleaningfee" value="#form.rental_petfriendly_cleaningfee#" class="small" size="10"></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Taxes","member.rental.editRental rental_tax")#</th>
				<td><cfif (form.rental_tax EQ 0)>
						<div id="addTax">Add Tax (click to edit)</div>
					<cfelseif (form.rental_tax GT 0)>
						<div id="editTax">#form.rental_tax#% (click to edit)</div>
					</cfif>
					<span id="taxSubField">
					<input type="text" name="rental_tax" value="#form.rental_tax#" class="small" size="10">
					%</span></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Pet Cleaning<br />Rate Type","member.rental.editRental rental_petfriendly_cleaningtype")#</th>
				<td><input type="radio" name="rental_petfriendly_cleaningtype" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_cleaningtype',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No Pets Allowed<br />
					<input type="radio" name="rental_petfriendly_cleaningtype" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_cleaningtype',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Per Pet Per Day<br />
					<input type="radio" name="rental_petfriendly_cleaningtype" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_cleaningtype',true) EQ 2>checked="checked"</cfif> value="2" style="border:none; background:none;" />
					Flat Rate Per Pet<br />
					<input type="radio" name="rental_petfriendly_cleaningtype" <cfif application.zcore.functions.zso(form, 'rental_petfriendly_cleaningtype',true) EQ 3>checked="checked"</cfif> value="3" style="border:none; background:none;" />
					Flat Rate</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Max Pets","member.rental.editRental rental_max_pets")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_max_pets";
					selectStruct.hideSelect=true;
					selectStruct.size = 1; // more for multiple select
					selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25";
					selectStruct.listValuesDelimiter = ",";	
					application.zcore.functions.zInputSelectBox(selectStruct);
					 </cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Featured Listing","member.rental.editRental rental_home_featured")#</th>
				<td colspan="2"><input type="radio" name="rental_home_featured" <cfif application.zcore.functions.zso(form, 'rental_home_featured',true) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="rental_home_featured" <cfif application.zcore.functions.zso(form, 'rental_home_featured',true) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Override URL","member.rental.editRental rental_url")#</th>
				<td colspan="2"  style="white-space:nowrap;">
					<cfif form.method EQ "addRental">
						#application.zcore.functions.zInputUniqueUrl("rental_url", true)#
					<cfelse>
						#application.zcore.functions.zInputUniqueUrl("rental_url")#
					</cfif>
				</td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
