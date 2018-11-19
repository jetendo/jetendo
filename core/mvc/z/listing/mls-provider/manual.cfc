<cfcomponent extends="base">
	<cfoutput><cfscript>
	this.mls_provider="manual_listing";
	</cfscript>
    <cffunction name="init" localmode="modern" access="public" returntype="string">
    	<cfscript>
		
		/*if(request.zos.istestserver){
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/0/";
		}else{
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/0/";
		}*/
		//this.getDataObject();
		</cfscript>
    </cffunction>
     
    <cffunction name="setColumns" localmode="modern">
    	<cfargument name="arrColumns" type="array" required="yes">
        <cfscript>
	/*
		request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns="manual_listing_"&replace(arraytolist(arguments.arrColumns),",",",manual_listing_","ALL");
		request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns=listtoarray(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxColumns);
		*/
		</cfscript>
    </cffunction>
    
    
    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		
		var qz=0;
		var i=0;
		if(arguments.resource NEQ "property"){
			application.zcore.template.fail("Invalid resource, ""#arguments.resource#"".");
		}
		/*
		arguments.sharedStruct.lookupStruct.table="manual_listing";
		arguments.sharedStruct.lookupStruct.primaryKey="manual_listing_listnum";
		arguments.sharedStruct.lookupStruct.idColumnOffset=0;
		for(i=1;i LTE arraylen(arguments.sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.sharedStruct.lookupStruct.arrColumns[i] EQ 'manual_listing_listnum'){
				arguments.sharedStruct.lookupStruct.idColumnOffset=i;
			}
		}
		arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
		</cfscript>
        <cfsavecontent variable="db.sql">
        select city_name, state_abbr, zipcode_zip 
		from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
		where zipcode_zip IN 	#db.trustedSQL("('30540','28906','28904','30546','30512','30560','30582','28909','30513','37326','28902','28781','20909','28905','28901', 
		'30175','30559','30734','30572','30522','30536','37391','28771','30705','30541','30143','30114','30555','37317','28903','30548','30571', 
		'28692','37307','30539','30527','28907','30528','30533','30107','29650','37333','30545','35013','30149','30139','28096','30115','30517', 
		'11111','30514','30148','30703','50559','30576','30852','30577','30620','30506','30534','35040','37369','30183','20582','32560','28703', 
		'30184','30606','39546','31512','30552','30525','30563','28734','30028','30584','30707','30450','30701','31523','28890','30635','37362', 
		'30103','30530','37325','30151','30728','30732','28914','30812','30189','37393','30177','30736','30518','30629','30449','28871','30735','30311')")# and 
		zipcode_deleted = #db.param(0)#
        </cfsavecontent><cfscript>qZ=db.execute("qZ");</cfscript>
        <cfloop query="qZ">
            <cfscript>arguments.sharedStruct.lookupStruct.cityRenameStruct[qZ.zipcode_zip]=qZ.city_name&"|"&qZ.state_abbr;
	    </cfscript>
        </cfloop>
	    */
	    </cfscript>
    </cffunction>
    
    <cffunction name="deleteListings" localmode="modern" output="no" returntype="any">
    	<cfargument name="idlist" type="string" required="yes">
    	<cfscript>
	</cfscript>
    </cffunction>
    
    
    <cffunction name="getDataObject" localmode="modern" output="no">
    	<cfscript>
	throw("not implemented");
	/*
		if(structkeyexists(variables, 'mlsDataCom') EQ false){
			variables.mlsDataCom=createobject("component", "zcorerootmapping.mvc.z.listing.mls-provider.north-georgiadata");
		}
		return variables.mlsDataCom;
		*/
		</cfscript>
    </cffunction>
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var address=0;
		var curLat=0;
		var curLong=0;
		var values=0;
		var dataCom=0;
		
		var rs=structnew();
		var ts=arguments.ss;
		ts.manual_listing_address=application.zcore.functions.zfirstlettercaps(ts.manual_listing_address);
		address=lcase(ts.manual_listing_address);
		curLat="";
		curLong="";
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts.manual_listing_state,ts.manual_listing_zipcode, arguments.ss.listing_id);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		
		/*
		dataCom=this.getDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		*/
		rs.listing_id=ts.manual_listing_id;
		rs.listing_acreage=ts.manual_listing_acreage;
		rs.listing_baths=ts.manual_listing_baths;
		rs.listing_halfbaths=ts.manual_listing_halfbaths;
		rs.listing_beds=ts.manual_listing_beds;
		rs.listing_city=ts.manual_listing_city;
		rs.listing_county=ts.manual_listing_county;
		rs.listing_frontage=","&ts.manual_listing_frontage&",";
		rs.listing_frontage_name=ts.manual_listing_frontage_name;
		rs.listing_price=ts.manual_listing_price;
		rs.listing_status=","&ts.manual_listing_status&",";
		rs.listing_state=ts.manual_listing_state;
		rs.listing_type_id=ts.manual_listing_type_id;
		rs.listing_sub_type_id=","&ts.manual_listing_sub_type_id&",";
		rs.listing_style=","&ts.manual_listing_style&",";
		rs.listing_view=","&ts.manual_listing_view&",";
		rs.listing_lot_square_feet=ts.manual_listing_lot_square_feet;
		rs.listing_square_feet=ts.manual_listing_square_feet;
		rs.listing_subdivision=ts.manual_listing_subdivision;
		rs.listing_year_built=ts.manual_listing_year_built;
		rs.listing_office=ts.manual_listing_office;
		rs.listing_agent=ts.manual_listing_agent;
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=ts.manual_listing_pool;
		rs.listing_photocount=ts.manual_listing_photocount;
		rs.listing_coded_features="";
		rs.listing_updated_datetime=ts.manual_listing_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id="0";
		rs.listing_address=trim(address);
		rs.listing_zip=ts.manual_listing_zip;
		rs.listing_data_address=trim(address);
		rs.listing_data_remarks=ts.manual_listing_remarks;
		rs.listing_data_zip=ts.manual_listing_zip;
		rs.listing_condition=ts.manual_listing_condition;
		rs.listing_parking=ts.manual_listing_parking;
		rs.listing_region=ts.manual_listing_region;
		rs.listing_tenure=ts.manual_listing_tenure;
		rs.listing_liststatus=ts.manual_listing_liststatus;
		
		return {
			listingData:rs
		};
		</cfscript>
    </cffunction>
    
    <cffunction name="getJoinSQL" localmode="modern" output="yes" returntype="any">
    	<cfargument name="joinType" type="string" required="no" default="INNER">
		<cfscript>
		var db=request.zos.queryObject;
		var idList="";
		// zero padding the site_id allows 100000 sites with 100000 listings each when listing_id = varchar(15)
		if(request.zos.globals.parentId NEQ 0){
			idList="'#request.zos.globals.parentId#','#request.zos.globals.id#'";
			//local.sql=" (concat(manual_listing.manual_listing_id, '#numberFormat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString)#') = listing.listing_id or 
			//concat(manual_listing.manual_listing_id, '#numberFormat(request.zos.globals.parentId, application.zcore.listingStruct.zeroPadString)#') = listing.listing_id ) ";
		}else{
			idList="'#request.zos.globals.id#'";
			//local.sql=" concat(manual_listing.manual_listing_id, '#numberFormat(request.zos.globals.id, application.zcore.listingStruct.zeroPadString)#') = listing.listing_id "; 
		}
		return "#arguments.joinType# JOIN #db.table("manual_listing", request.zos.zcoreDatasource)# manual_listing ON manual_listing.manual_listing_id = listing.listing_id and manual_listing.site_id IN (#idList#) and manual_listing_deleted=0 ";
		</cfscript>
    </cffunction>
    <cffunction name="getPropertyListingIdSQL" localmode="modern" output="yes" returntype="any">
    	<cfreturn "manual_listing.manual_listing_id">
    </cffunction>
    <cffunction name="getListingIdField" localmode="modern" output="yes" returntype="any">
    	<cfreturn "manual_listing_id">
    </cffunction>
    
    
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		var ts=application.zcore.listingCom.parseListingId(arguments.ss.listing_id);
		var a2=listtoarray(lcase(arguments.ss.columnlist));
		var i=0;
		var value=0;
		var features=0;
		var details=0;
		var column=0;
		for(i=1;i LTE arraylen(a2);i++){
			column=a2[i];
			value=arguments.ss[column];
			if(value NEQ ""){
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		features="";
		
		// should images be generated as mls size and stored with manual_listing_id in normal directory when they change?
		idx.listingSource=request.zos.globals.shortDomain;
		request.lastPhotoId=arguments.ss.listing_id;
		if(arguments.ss.manual_listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{	
			for(i=1;i LTE arguments.ss.manual_listing_photocount;i++){
				idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
			}
		}
		// get office and agent name from the mls-provider = arguments.ss.manual_listing_mls_id
		idx["officeName"]=arguments.ss.manual_listing_office;
		idx["agentName"]=arguments.ss.manual_listing_agent;
		idx["features"]="";
		idx["virtualtoururl"]=arguments.ss.manual_listing_virtual_tour;
		
		idx["virtualtoururl"]=replace(idx["virtualtoururl"],"htttp:","http:");
		if(idx["virtualtoururl"] NEQ "" and find("http://",idx["virtualtoururl"]) EQ 0 and (find(".",idx["virtualtoururl"]) NEQ 0 and find("/",idx["virtualtoururl"]) NEQ 0)){
			idx["virtualtoururl"]&="http://"&idx["virtualtoururl"];
		}
		idx["zipcode"]=arguments.ss.manual_listing_zip;
		idx["maintfees"]="";
		details="";
		</cfscript>
		<cfif arguments.fulldetails>
		<cfsavecontent variable="details"><table class="ztablepropertyinfo">
		#idx.listing_data_detailcache1#
		#idx.listing_data_detailcache2#
		#idx.listing_data_detailcache3#
			</table></cfsavecontent>
		</cfif>
		<cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		// local folder... needs to be accessible from multiple domains or prepend the domain, etc.
		var photo='';
		return photo;
		</cfscript>
    </cffunction>
    
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var db=request.zos.queryObject;
		var dS=0;
		var arrD=0;
		var pos=0;
		var countyName=0;
		var arrD=0;
		var ds2=0;
		var arrT=0;
		

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>