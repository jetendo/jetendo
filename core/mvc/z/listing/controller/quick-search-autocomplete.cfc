<cfcomponent>
<cfoutput>
<cffunction name="index"  localmode="modern" access="remote" roles="member">
<!DOCTYPE html>
<html class="" lang="en-US">
<head>
    <meta charset="utf-8">
	<script src="https://code.jquery.com/jquery-1.12.1.min.js"></script>
	<style type="text/css" title="bt-theme-customizations">
		.arrowDown {
 		    position: relative;
    		top: -13px;
    		left: 95px;
    		width: 0;
    		height: 20;
    		z-index: 100;
    		border-left: 10px solid ##444444;
    		border-right: 10px solid ##444444;
    		border-top: 10px solid ##FFFFFF;
    		margin: auto;
		}
		.search-link {
			display: block;
			color: ##4A4A4A;
			font-size: 16px;
			padding: 5px 10px;
    		text-decoration: none;
    		cursor: pointer;
    		display: list-item;
    		text-align: -webkit-match-parent;    		
    	}
		.search-link:hover {
    		color: ##87161a;
    	}
		button {
			border: 2px solid ##FFFFFF;
			background: ##444444;
			color:##FFFFFF;
			width: 225px;
			height: 25px;
			border-radius: 6px;
			text-align: center;
			position: relative
	    	font-size: 12px;
	    	text-transform: uppercase;
		}
    </style>
</head>
<body>
<div style="float:left; width:1200px;padding-top:50px; padding-bottom:50px;">
	<div style="float:left; width:400px;">
    <button type="button" id="btn-searchby-trigger" onclick="$('##div-searchby-list').toggle();">Search By <div class="arrowDown"> </div></button>
    <div id="div-searchby-list" style="display:none;">
    <ul class="search_menu_list">
		<li><a href="##" class="search-link" data-type="nearby" data-placeholder="Grabbing your location">Nearby Me</a></li>
		<li><a href="##" class="search-link" data-type="all" data-placeholder="Type any Area, Address, ZIP, School, etc">SEARCH: All</a></li>
        <li><a href="##" class="search-link" data-type="city" data-placeholder="Type any City">Cities</a></li>
		<li><a href="##" class="search-link" data-type="neighborhood" data-placeholder="Type Any Neighborhood">Neighborhoods</a></li>
        <li><a href="##" class="search-link" data-type="address" data-placeholder="Type any Address">Address</a></li>
        <li><a href="##" class="search-link" data-type="listingmls" data-placeholder="Type any MLS##">MLS##</a></li>
		<li><a href="##" class="search-link" data-type="school" data-placeholder="Type any School">Schools</a></li>
		<li><a href="##" class="search-link" data-type="postalcode" data-placeholder="Type any Zip Code">Zip Code</a></li>
        <li><a href="##" class="search-link" data-type="county" data-placeholder="Type any County">County</a></li>
        <li><a href="##" class="search-link" data-type="keyword" data-placeholder="Type any Keyword">Keyword</a></li>
        <li><a href="##" class="search-link" data-type="feature" data-placeholder="Type any Feature">Feature</a></li>
	</ul>
    </div>
  </div>
	<div style="float:left; width:400px;">
	  	<input type="text" name="query" id="query" onkeyup="getQueryResult(this, event);" placeholder="Type any Area, Address, ZIP, School, etc" title="Search an area, address, zip code, school, etcetera" autocomplete="off">
		<br>
	  	<div id="div-searched-list" style="display:none; height:250px; overflow:auto;">
	  	</div>
	</div>
</div>
<script type='text/javascript'>
	var _dataType = "";
	$(document).ready(function() {
	    $(".search-link").each(function () {
    	    var that = this;
            $(that).click(function (e) {
      	        var $elem 	= $(this);
    			_dataType  	= $elem.attr("data-type");
    			$("##btn-searchby-trigger").html($elem.text() + "<div class=\"arrowDown\"></div>");
				$('##div-searchby-list').toggle();
			});
		});
	});
	function getQueryResult(ctrl,e){
		var whatCharIsIt = e.keyCode ? e.keyCode : e.charCode;
		if(whatCharIsIt == 27 || whatCharIsIt == 13)
			return;
		if(_dataType == ""){
		 	alert("Select a Search Category");
		 	$("##btn-searchby-trigger")[0].focus();
		 	return;
		}
		$('##div-searched-list').html("");
		if(ctrl.value.length > 3 && _dataType != ""){
			var obj={
				id:"getterDATA",
				method:"post",
				postObj:{ sData: ctrl.value, sSearchBy:_dataType },
				callback:function(r){
					try{
						var r = JSON.parse(r);
						var sHTML = "";
						if(r){
							for(var obj in r){
								switch(_dataType){
									case "postalcode":
										sHTML += "<p onclick=\"$('##query').val($(this).text());\">" + r[obj].city + " " + r[obj].state + " " + r[obj].zip + "</p>";
										break;
									case "county":
										sHTML += "<p onclick=\"$('##query').val($(this).text());\">" + r[obj].county + "</p>";
										break;
									case "city":
										sHTML += "<p onclick=\"$('##query').val($(this).text());\">" + r[obj].city + "</p>";
										break;
									case "address":
										sHTML += "<p onclick=\"$('##query').val($(this).text());\">" + r[obj].address + "</p>";
										break;
								}
							}
							$('##div-searched-list').html(sHTML);
							$('##div-searched-list').show();
						}
					}
					catch(e){
						alert(e);
					}
				},
				errorCallback:function(xmtp){ 
					alert(xmtp);
				},
				url:"/z/listing/quick-search-autocomplete/getQueryData"
			}; 
			zAjax(obj);
		}
	}
	
</script>
</body>
</html>
</cffunction>
<cffunction name="getQueryData" localmode="modern" access="remote" returntype="string">
	<cfscript>
	db=request.zos.queryObject;

	//application.zcore.listingCom.something();
	//application.zcore.listingStruct.functions.something();
	/*db.sql ="SELECT * FROM #db.table("listing_lookup", request.zos.zcoreDatasource)# 
	 ";
	q=db.execute("q");*/

/*
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts = StructNew();
	ts.offset = 0;
	ts.perpage = 1;
	ts.distance = 30; // in miles
	ts.disableCount=true;
	tempId = application.zcore.status.getNewId();
	ts9={
		search_mls_number_list:form.zmlsnum
	};
	propertyDataCom.setSearchCriteria(ts9);
	returnStruct = propertyDataCom.getProperties(ts);*/
	</cfscript>

 

	<!--- 
 <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
    <cfif qType.idlist NEQ "">
    <cfsavecontent variable="db.sql">
    select city_x_mls.city_name label, city_x_mls.city_id value 
	from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
	WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#)and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
	city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)  and 
	city_x_mls_deleted = #db.param(0)#
          
    </cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
    <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
    </cfif>
    <!--- put the primary cities at top and repeat further down too --->
    <cfsavecontent variable="db.sql">
    select city.city_name label, city.city_id value 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city 
	WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) and 
	city_deleted=#db.param(0)# 
	ORDER BY label 
    </cfsavecontent><cfscript>qCity10=db.execute("qCity10");
	arrK2=arraynew(1);
	arrK3=arraynew(1);
	if(qCity10.recordcount NEQ 0){
		for(i=1;i LTE qCity10.recordcount;i++){
			sOut[qCity10.label[i]]=true;
			arrayappend(arrK2,qCity10.label[i]);
			arrayappend(arrK3,qCity10.value[i]);
		}
		preLabels=arraytolist(arrK2,chr(9))&chr(9)&"-----------";
		preValues=arraytolist(arrK3,chr(9))&chr(9)&"-----------";
	}
	</cfscript>
	 --->
	<cfscript>
		if(form.sSearchBy EQ "county"){
			getCountyData(form.sData);
			return;
		} else if(form.sSearchBy EQ "city"){
			getCityData(form.sData);
			return;
		} else if(form.sSearchBy EQ "address"){
			getAddressData(form.sData);
			return;
		}
		var db = request.zos.queryObject; 
		db.sql = "SELECT DISTINCT city_name, state_abbr, zipcode_zip
		 	FROM #db.table("zipCode", request.zos.zcoreDatasource)# 
		 	WHERE zipcode_deleted  = #db.param(0)# AND city_type = #db.param('D')# ";
		if(form.sSearchBy EQ "all" OR form.sSearchBy EQ "city"){
			db.sql &= " AND city_name LIKE #db.param("%" & form.sData &"%")#  ORDER BY city_name ASC";
		} else if(form.sSearchBy EQ "postalcode") {
			db.sql &= " AND zipcode_zip LIKE #db.param("%" & form.sData & "%")# ORDER BY zipcode_zip ASC";
		} else {
			db.sql &= " LIMIT #db.param(5)#";
		}
		qZip = db.execute("qZip");
		arrRec = [];
		if(qZip.recordCount GT 0){
			for(rec in qZip){
				rs={
					city: "#qZip.city_name#",
					state: "#qZip.state_abbr#",
					zip: "#qZip.zipcode_zip#"
				};
				arrayAppend(arrRec,rs);
			}
		}	
		application.zcore.functions.zReturnJson(arrRec);
	</cfscript>
</cffunction>	
<cffunction name="getCountyData" localmode="modern" access="remote" returntype="string">
	<cfargument name="sData" type="string" required="true" />
    <cfscript>
		db 		= request.zos.queryObject;
	</cfscript>	
    <cfsavecontent variable="db.sql">
	    SELECT cast(group_concat(distinct listing_county SEPARATOR #db.param(',')#) AS CHAR) idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE listing_deleted = #db.param(0)# AND 
	    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# AND 
    	listing_county not in (#db.param('')#) 
    	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> 
    		and listing_status LIKE #db.param('%,7,%')# 
    	</cfif>
    	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> 
    		#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# 
    	</cfif>
    </cfsavecontent>
    <cfscript>
		qType 	= db.execute("qType");
    	arrD	= listtoarray(qType.idlist);
		arrRec 	= [];
    	for(i=1;i LTE arraylen(arrD);i++){
			var sCounty = "#application.zcore.listingCom.listingLookupValue("county",arrD[i])#";
			if(Find(LCase(arguments.sData), LCase(sCounty),1) GT 0){		
				rs={
					county : sCounty
				};
				arrayAppend(arrRec,rs);
			}
		}	
		application.zcore.functions.zReturnJson(arrRec);
	</cfscript>
</cffunction>	
<cffunction name="getCityData" localmode="modern" access="remote" returntype="string">
	<cfargument name="sData" type="string" required="true" />
    <cfscript>
		db 		= request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE listing_deleted = #db.param(0)# and 
	    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
    	listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1>
			AND listing_status LIKE #db.param('%,7,%')# 
    	</cfif>
		<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')>
			#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# 
		</cfif>
    </cfsavecontent>
    <cfscript>
		qType=db.execute("qType");
	</cfscript>
    <cfif qType.idlist NEQ "">
	    <cfsavecontent variable="db.sql">
		    select city_x_mls.city_name label, city_x_mls.city_id value 
			from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
			WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#)and 
			#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
			city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)  and 
			city_x_mls_deleted = #db.param(0)#
	    </cfsavecontent>
	    <cfscript>
			qCity=db.execute("qCity");
		</cfscript>
	    <cfloop query="qCity">
	    	<cfscript>
				arrRec 	= [];
				cityUnq	= {};
	    		if(structkeyexists(cityUnq,qCity.label) EQ false){
	    			cityUnq[qCity.label] = qCity.value;
					//if(Find(LCase(arguments.sData), LCase(qCity.label),1) GT 0){
						rs={
							city : qCity.label
						};
						arrayAppend(arrRec,rs);
					//}
	    		}
	    	</cfscript>
	   	</cfloop>
    </cfif>
   	<cfscript>
		application.zcore.functions.zReturnJson(arrRec);
	</cfscript>
</cffunction>	
<cffunction name="getAddressData" localmode="modern" access="remote" returntype="string">
	<cfargument name="sData" type="string" required="true" />
    <cfscript>
		db 		= request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	    SELECT DISTINCT listing_address idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE listing_deleted = #db.param(0)# and 
	    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
    	listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1>
			AND listing_status LIKE #db.param('%,7,%')# 
    	</cfif>
		<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')>
			#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# 
		</cfif>
    </cfsavecontent>
    <cfscript>
		qType=db.execute("qType");
	</cfscript>
    <cfif qType.idlist NEQ "">
	    <cfloop query="qType">
	    	<cfscript>
				arrRec 	= [];
				//if(Find(LCase(arguments.sData), LCase(qType.idlist),1) GT 0){
					rs={
						address : qType.idlist
					};
					arrayAppend(arrRec,rs);
				//}
	    	</cfscript>
	   	</cfloop>
    </cfif>
   	<cfscript>
   		writeDump(qType);
   		abort;
		application.zcore.functions.zReturnJson(arrRec);
	</cfscript>
</cffunction>	
</cfoutput>
</cfcomponent>
