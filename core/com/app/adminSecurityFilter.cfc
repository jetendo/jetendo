<cfcomponent>
<cfoutput>
<cffunction name="getFeatureMap" localmode="modern" returntype="struct">
	<cfargument name="ss" type="struct" required="true">
	<cfscript>
	ss=arguments.ss;

	ms=structnew("linked");
	if(application.zcore.app.structHasApp(ss, "blog")){
		ms["Blog"]={ parent:'',value:'Blog', label:"Blog" };
		ms["Blog Articles"]={ parent:'Manage Blog',value:'Blog Articles', label:chr(9)&"Blog Articles"};
		ms["Blog Categories"]={ parent:'Manage Blog',value:'Blog Categories', label:chr(9)&"Blog Categories"};
		ms["Blog Tags"]={ parent:'Manage Blog',value:'Blog Tags', label:chr(9)&"Blog Tags"};
	}
	ms["Content Manager"]={ parent:'',value:'Content Manager', label:"Content Manager"};
	if(application.zcore.app.structHasApp(ss, "content")){
		ms["Pages"]={ parent:'Content Manager',value:'Pages', label:chr(9)&"Pages"};
		//ms["Content Permissions"]={ parent:'Content Manager',value:'Content Permissions', label:chr(9)&"Content Permissions"};
	}	 
	ms["Files & Images"]={ parent:'Content Manager',value:'Files & Images', label:chr(9)&"Files & Images"};
	ms["Menus"]={ parent:'Content Manager',value:'Menus', label:chr(9)&"Menus"};
	//ms["Problem Link Report"]={ parent:'Content Manager',value:'Problem Link Report', label:	chr(9)&"Problem Link Report"};
	ms["Slideshows"]={ parent:'Content Manager',value:'Slideshows', label:chr(9)&"Slideshows"};
	ms["Site Options"]={ parent:'Content Manager',value:'Site Options', label:chr(9)&"Site Options"};
	if(request.zos.isTestServer){
		ms["Features"]={ parent:'Content Manager',value:'Features', label:chr(9)&"Features"};
		ms["Layouts"]={ parent:'Content Manager',value:'Layouts', label:chr(9)&"Layouts"};
		ms["Landing Pages"]={ parent:'Content Manager',value:'Landing Pages', label:chr(9)&"Landing Pages"};
		ms["Sections"]={ parent:'Content Manager',value:'Sections', label:chr(9)&"Sections"};
		ms["Theme Options"]={ parent:'Content Manager',value:'Theme Options', label:chr(9)&"Theme Options"};
		ms["Design & Layout"]={ parent:'Content Manager',value:'Design & Layout', label:chr(9)&"Design & Layout"};

		ms["Ecommerce"]={ parent:'',value:'Ecommerce', label:"Ecommerce"};


	}
	/*if(application.zcore.functions.zso(request.zos.globals, 'lockTheme', true, 1) EQ 0){
		ms["Themes"]={ parent:'Content Manager',value:'', label:chr(9)&"Themes"};
	}*/
	ms["Video Library"]={ parent:'Content Manager',value:'Short Links', label:chr(9)&"Short Links"};
	ms["Video Library"]={ parent:'Content Manager',value:'Video Library', label:chr(9)&"Video Library"};
	ms["Settings"]={ parent:'Content Manager',value:'Settings', label:chr(9)&"Settings"};


	application.zcore.siteOptionCom.setFeatureMap(ms);


	ms["Manage Leads"]={ parent:'',value:'Leads', label:"Leads"};
	ms["Leads"]={ parent:'Manage Leads',value:'Leads', label:chr(9)&"Leads"};
	ms["Lead Types"]={ parent:'Manage Leads',value:'Lead Types', label:chr(9)&"Lead Types"};
	ms["Lead Source Report"]={ parent:'Manage Leads',value:'Lead Source Report', label:chr(9)&"Lead Source Report"};
	ms["Lead Templates"]={ parent:'Manage Leads',value:'Lead Templates', label:chr(9)&"Lead Templates"};
	ms["Lead Reports"]={ parent:'Manage Leads',value:'Lead Reports', label:chr(9)&"Lead Reports"};
	ms["Lead Export"]={ parent:'Manage Leads',value:'Lead Export', label:chr(9)&"Lead Export"};
	ms["Mailing List Export"]={ parent:'Manage Leads',value:'Mailing List Export', label:chr(9)&"Mailing List Export"};
	ms["Lead Routing"]={ parent:'Manage Leads',value:'Lead Routing', label:chr(9)&"Lead Routing"}; 
	ms["Lead Autoresponders"]={ parent:'Manage Leads',value:'Lead Autoresponders', label:chr(9)&"Lead Autoresponders"};


	if(application.zcore.app.structHasApp(ss, "listing")){
		ms["Manage Listings"]={ parent:'',value:'Listings', label:"Listings"};
		ms["Listings"]={ parent:'Manage Listings',value:'Listings', label:chr(9)&"Listings"};
		ms["Listing Research Tool"]={ parent:'Manage Listings',value:'Listing Research Tool', label:chr(9)&"Listing Research Tool"};
		ms["Saved Listing Searches"]={ parent:'Manage Listings',value:'Saved Listing Searches', label:chr(9)&"Saved Listing Searches"};
		ms["Listing Search Filter"]={ parent:'Manage Listings',value:'Listing Search Filter', label:chr(9)&"Listing Search Filter"};
		ms["Real Estate Widgets and Links"]={ parent:'Manage Listings',value:'Real Estate Widgets and Links', label:chr(9)&"Real Estate Widgets and Links"};
	} 
	if(application.zcore.app.structHasApp(ss, "job")){
		ms["Manage Jobs"]={ parent:'',value:'Jobs', label:"Jobs"};
		ms["Jobs"]={ parent:'Manage Jobs',value:'Jobs', label:chr(9)&"Jobs"}; 
		ms["Job Import"]={ parent:'Manage Jobs',value:'Job Import', label:chr(9)&"Job Import"}; 
	}
	if(application.zcore.app.structHasApp(ss, "rental")){
		ms["Manage Rentals"]={ parent:'',value:'Rentals', label:"Rentals"};
		ms["Rentals"]={ parent:'Manage Rentals',value:'Rentals', label:chr(9)&"Rentals"};
		ms["Rental Amenities"]={ parent:'Manage Rentals',value:'Rental Amenities', label:chr(9)&"Rental Amenities"};
		ms["Rental Categories"]={ parent:'Manage Rentals',value:'Rental Categories', label:chr(9)&"Rental Categories"};
		ms["Rental Calendars"]={ parent:'Manage Rentals',value:'Rental Calendars', label:	chr(9)&"Rental Calendars"};
		ms["Rental Reservations"]={parent:'Manage Rentals',value:'Rental Reservations', label: chr(9)&"Rental Reservations"};
	}
	if(application.zcore.app.structHasApp(ss, "ecommerce")){
		ms["Manage Ecommerce"]={ parent:'',value:'Ecommerce', label:"Ecommerce"};
		ms["Orders"]={ parent:'Manage Ecommerce',value:'Orders', label:chr(9)&"Orders"};
		ms["Subscriptions"]={ parent:'Manage Ecommerce',value:'Subscriptions', label:chr(9)&"Subscriptions"};
		ms["Coupons"]={ parent:'Manage Ecommerce',value:'Coupons', label:chr(9)&"Coupons"};
		ms["Products"]={ parent:'Manage Ecommerce',value:'Products', label:chr(9)&"Products"};
		ms["Product Categories"]={ parent:'Manage Ecommerce', value:'Product Categories', label:chr(9)&"Product Categories"};
		ms["Customers"]={parent:'Manage Ecommerce',value:'Customers', label: chr(9)&"Customers"};
	}
	if(application.zcore.app.structHasApp(ss, "reservation")){
		ms["Manage Reservations"]={ parent:'',value:'Reservations', label:"Reservations"};
		ms["Reservations"]={ parent:'Manage Reservations',value:'Reservations', label:chr(9)&"Reservations"};
		ms["Reservation Types"]={ parent:'Manage Reservation',value:'Reservations Types', label:chr(9)&"Reservation Types"};
	}
	if(application.zcore.app.structHasApp(ss, "event")){
		ms["Manage Events"]={ parent:'',value:'Events', label:"Events"};
		ms["Events"]={ parent:'Manage Events',value:'Events', label:chr(9)&"Events"};
		ms["Event Calendars"]={ parent:'Manage Events',value:'Event Calendars', label:chr(9)&"Event Calendars"};
		ms["Event Categories"]={ parent:'Manage Events',value:'Event Categories', label:chr(9)&"Event Categories"};
		ms["Event Widgets"]={ parent:'Manage Events',value:'Event Widgets', label:chr(9)&"Event Widgets"};
	}

	ms["Manage Users"]={ parent:'', value:'Users', label:"Users"};
	ms["Users"]={ parent:'Manage Users', value:'Users', label:chr(9)&"Users"};
	ms["Offices"]={ parent:'Manage Users', value:'Offices', label:chr(9)&"Offices"};

	return ms;
	</cfscript>
</cffunction>


<cffunction name="getFormField" localmode="modern">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	ms=getFeatureMap(application.siteStruct[request.zos.globals.id]);
	arrValue=[];
	arrLabel=[];
	for(i in ms){ 
		arrayAppend(arrLabel, replace(ms[i].label, chr(9), "__", "all"));
		arrayAppend(arrValue, ms[i].value);
	} 


	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.css");
	application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.filter.css");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.js", '', 2);
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.filter.js", '', 2);
	application.zcore.skin.addDeferredScript('
		$("###arguments.fieldName#").multiselect().multiselectfilter();
	');
	selectStruct = StructNew();
	selectStruct.multiple=true;
	selectStruct.size=10;
	selectStruct.name = arguments.fieldName;
	selectStruct.listLabelsDelimiter = ",";
	selectStruct.listValuesDelimiter = ",";
	selectStruct.listLabels=arrayToList(arrLabel, ",");
	selectStruct.listValues=arrayToList(arrValue, ",");
	application.zcore.functions.zInputSelectBox(selectStruct);

	</cfscript><br />By default, a user has access to all features for the group they are assigned to. Selecting one or more options here will limit them to the selected options only.  All other existing and future features will be hidden. To allow user to access custom site option groups, you must select "site options" and each one of the custom forms. The user will have access to all site option groups, but their manager menu will only show the ones you have selected.
</cffunction>

<cffunction name="validateFeatureAccessList" localmode="modern" returntype="string">
	<cfargument name="featureList" type="string" required="yes">
	<cfscript>
	arrFeature=listToArray(arguments.featureList, ",");
	fs={};
	for(i=1;i LTE arraylen(arrFeature);i++){
		if(not structkeyexists(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct, arrFeature[i])){
			throw(arrFeature[i]&" is not a valid admin feature name. Please review/modify the features in adminSecurityFilter.cfc.");
		}
		fs[arrFeature[i]]=true;
		currentFeature=application.siteStruct[request.zos.globals.id].adminFeatureMapStruct[arrFeature[i]];
		if(currentFeature.parent NEQ ""){
			fs[currentFeature.parent]=true;
		}
	}
	return structkeylist(fs, ",");
	</cfscript>
</cffunction>


<cffunction name="auditFeatureAccess" localmode="modern" returntype="any">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="requiresWriteAccess" type="boolean" required="no" default="#false#">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>

	if(arguments.requiresWriteAccess or request.zos.auditTrackReadOnlyRequests){
		ts={
			table:"audit",
			datasource:request.zos.zcoreDatasource,
			struct:{
				audit_description:"",
				site_id:request.zos.globals.id,
				audit_url:request.zos.originalURL&"?"&request.zos.cgi.query_string,
				audit_updated_datetime:request.zos.mysqlnow,
				audit_security_feature:arguments.featureName,
				audit_ip:request.zos.cgi.remote_addr,
				audit_user_agent:request.zos.cgi.http_user_agent
			}
		}
		if(arguments.requiresWriteAccess){
			ts.struct.audit_security_action_write=1;
		}
		if(isdefined('request.zsession.user.id')){
			ts.struct.user_id=request.zsession.user.id;
			ts.struct.user_id_siteidtype=application.zcore.user.getSiteIdTypeFromLoggedOnUser();
		}
		application.zcore.functions.zInsert(ts);
	}
	</cfscript>
</cffunction>

<cffunction name="requireFeatureAccess" localmode="modern" returntype="any">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="requiresWriteAccess" type="boolean" required="no" default="#false#">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess(arguments.featureName, false, arguments.site_id)){  
		application.zcore.status.setStatus(request.zsid, "You don't have permission to use the feature: #arguments.featureName#.", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	// check for write access
	if(arguments.requiresWriteAccess){

		if(request.zos.globals.enableDemoMode EQ 1 and not application.zcore.user.checkServerAccess()){
			application.zcore.status.setStatus(request.zsid, "You don't have write access for the #arguments.featureName# feature because this web site is in demo mode.", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}else if(structkeyexists(application, 'zReadOnlyModeEnabled') and application.zReadOnlyModeEnabled){
			application.zcore.status.setStatus(request.zsid, "The server is undergoing maintenance at this time, and the manager is set in read-only mode.  Please try again later.", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
	}
	auditFeatureAccess(arguments.featureName, arguments.requiresWriteAccess, arguments.site_id);
	</cfscript>
</cffunction>

<cffunction name="checkFeatureWriteAccess" localmode="modern" returntype="boolean">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess(arguments.featureName, false, arguments.site_id)){ 
		return false;
	}
	if(request.zos.globals.enableDemoMode EQ 1 and not application.zcore.user.checkServerAccess()){
		return false;
	}else if(structkeyexists(application, 'zReadOnlyModeEnabled') and application.zReadOnlyModeEnabled){
		return false;
	}
	return true;
	</cfscript>
</cffunction>
	

<cffunction name="checkFeatureAccess" localmode="modern" returntype="boolean">
	<cfargument name="featureName" type="string" required="yes">
	<cfargument name="requiresWriteAccess" type="boolean" required="no" default="#false#">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	userSiteId='user';
	if(arguments.site_id NEQ request.zos.globals.id){
		userSiteId='user'&arguments.site_id;
	} 
	if(arguments.requiresWriteAccess){
		if(not checkFeatureWriteAccess(arguments.featureName, arguments.site_id)){
			return false;
		}
	}
	if(structkeyexists(request.zsession,userSiteId)){
		if(not structkeyexists(request.zsession[userSiteId], 'limitManagerFeatureStruct') or structcount(request.zsession[userSiteId].limitManagerFeatureStruct) EQ 0){
			return true;
		}else{
			arrFeature=listToArray(arguments.featureName, ",");
			for(i=1;i LTE arraylen(arrFeature);i++){
				if(not structkeyexists(application.siteStruct[arguments.site_id].adminFeatureMapStruct, arrFeature[i])){
					return false;
					//throw(arrFeature[i]&" is not a valid admin feature name. Please review/modify the features in adminSecurityFilter.cfc.");
				}
				if(not structkeyexists(request.zsession[userSiteId].limitManagerFeatureStruct, arrFeature[i])){
					currentFeature=application.siteStruct[arguments.site_id].adminFeatureMapStruct[arrFeature[i]];
					return false;
				}
			}
			return true;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>
</cfoutput>

</cfcomponent>