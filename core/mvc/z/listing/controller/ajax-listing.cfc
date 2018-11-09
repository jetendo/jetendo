 <cfcomponent>
<cfoutput> 
	
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript>
	//db=request.zos.queryObject;
	if(not application.zcore.app.siteHasApp("listing")){
		application.zcore.functions.z404("Site doesn't have listing app");
	}
	form.ssid=application.zcore.functions.zso(form, 'ssid');
	form.getMapSummary=application.zcore.functions.zso(form, 'getMapSummary', true, 0);
	ss=application.zcore.listingStruct.functions.zMLSSearchOptionsDisplay(form.ssid);
	rs={
		success:true,
		listingOutput:ss.output
	};
	if(form.getMapSummary){
		rs.mapSummaryOutput=displaySummaryAndMap(ss);
	}
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
	
</cffunction>


<cffunction name="displaySummaryAndMap" localmode="modern" access="private"> 
	<cfargument name="returnPropertyDisplayStruct" type="struct" required="yes">
	<cfscript>
	returnPropertyDisplayStruct=arguments.returnPropertyDisplayStruct; 
	//application.zcore.template.appendTag('scripts', '<div id="zMapOverlayDivV3" style="position:absolute; left:0px; top:0px; display:none; z-index:1000;"></div>'); 
	ts = StructNew();
	ts.offset =0;
	ts.perpage = 1;
	ts.distance = 30; // in miles
	ts.zReturnSimpleQuery=true;
	ts.onlyCount=true;
	//ts.debug=true;
	ts.zselect=" min(listing.listing_price) minprice, max(listing.listing_price) maxprice, count(listing.listing_id) count";
	rs4 = returnPropertyDisplayStruct.propertyDataCom.getProperties(ts);
	ts.zselect=" min(listing.listing_square_feet) minsqft, max(listing.listing_square_feet) maxsqft";
	ts.zwhere=" and listing.listing_square_feet <> '' and listing.listing_square_feet <>'0'";
	rs4_2 = returnPropertyDisplayStruct.propertyDataCom.getProperties(ts);
	ts.zselect=" min(listing.listing_beds) minbed, min(listing.listing_beds) maxbed";
	ts.zwhere=" and listing.listing_beds <> '' and listing.listing_beds<>'0'";
	rs4_3 = returnPropertyDisplayStruct.propertyDataCom.getProperties(ts);
	ts.zselect=" min(listing.listing_baths) minbath, max(listing.listing_baths) maxbath";
	ts.zwhere=" and listing.listing_baths <> '' and listing.listing_baths<>'0'";
	rs4_4 = returnPropertyDisplayStruct.propertyDataCom.getProperties(ts);
	ts.zselect=" min(listing.listing_year_built) minyear, max(listing.listing_year_built) maxyear";
	ts.zwhere=" and listing.listing_year_built <> '' and listing.listing_year_built<>'0'";
	rs4_5 = returnPropertyDisplayStruct.propertyDataCom.getProperties(ts);
	out="";
	if(rs4.count NEQ 0){
		savecontent variable="out"{
			if(rs4.count NEQ 0){
				echo('<div style="font-weight:bold; font-size:120%; padding-bottom:10px;"> #numberformat(rs4.count)# listings</div>');
			}
			echo('<div style="font-weight:bold;">Listing Summary:</div>');
			if(rs4.minprice NEQ "" and rs4.minprice NEQ 0){
				echo('$#numberformat(rs4.minprice)# ');
				if(rs4.minprice NEQ rs4.maxprice){
					echo('to $#numberformat(rs4.maxprice)#<br />');
				}
			}
			if(rs4_2.minsqft NEQ "" and rs4_2.minsqft NEQ 0){
				echo(numberformat((rs4_2.minsqft)));
				if(rs4_2.minsqft NEQ rs4_2.maxsqft){
					echo(' to #numberformat((rs4_2.maxsqft))#');
				}
				echo(' square feet (living area)<br />');
			}
			if(rs4_3.minbed NEQ "" and rs4_3.minbed NEQ 0){
				echo(rs4_3.minbed);
				if(rs4_3.minbed NEQ rs4_3.maxbed){
					echo(rs4_3.maxbed);
				}
				echo(' Bedrooms<br />');
			}
			if(rs4_4.minbath NEQ "" and rs4_4.minbath NEQ 0){
				echo(rs4_4.minbath);
				if(rs4_4.minbath NEQ rs4_4.maxbath){
					echo(' to #(rs4_4.maxbath)#');
				}
				echo(' Bathrooms<br />');
			}
			if(rs4_5.minyear NEQ "" and rs4_5.minyear NEQ 0){
				echo('Built ');
				if(rs4_5.minyear NEQ rs4_5.maxyear){
					echo(' between #(rs4_5.minyear)# &amp; #(rs4_5.maxyear)#');
				}else{
					echo(' in #(rs4_5.minyear)#');
				}
				echo('<br />');
			}
			echo('<br /> <div style="font-weight:bold; font-size:120%;"><a href="##zbeginlistings">View Listings</a></div>');
		}
	}
	return out;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>