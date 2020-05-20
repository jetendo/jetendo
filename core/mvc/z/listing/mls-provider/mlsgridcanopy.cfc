<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.base">
<cfoutput>
	<cfscript>
	// this.retsVersion="1.7";
	
	this.mls_id=32;
	this.mls_provider="mlsgridcanopy";
	if(request.zos.istestserver){
		this.hqPhotoPath="#request.zos.sharedPath#mls-images/32/";
	}else{
		this.hqPhotoPath="#request.zos.sharedPath#mls-images/32/";
	}
	// this.useRetsFieldName="system";
 
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="32";
	// this.sysidfield="";
	// variables.resourceStruct=structnew();
	// variables.resourceStruct["property"]=structnew();
	// variables.resourceStruct["property"].resource="property";
	// variables.resourceStruct["property"].id="mlsnumber";
	// variables.resourceStruct["office"]=structnew();
	// variables.resourceStruct["office"].resource="office";
	// variables.resourceStruct["office"].id="mlsid";
	// variables.resourceStruct["agent"]=structnew();
	// variables.resourceStruct["agent"].resource="agent";
	// variables.resourceStruct["agent"].id="mlsid";
	// this.emptyStruct=structnew();
	
	
	
	// variables.tableLookup=structnew();
   	// variables.tableLookup["RNT"]="Rent";  
    // variables.tableLookup["SFR"]="Resi";  
    // variables.tableLookup["MUL"]="MF";  
    // variables.tableLookup["LND"]="Land";  
    // variables.tableLookup["COM"]="Comm";  
    // variables.tableLookup["CND"]="Resi";  
	//variables.tableLookup["listing"]="1"; 
	// variables.t5=structnew();

	// this.remapFieldStruct=variables.t5;

	
	</cfscript> 
    

    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript> 
		</cfscript>
    </cffunction>

    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript> 
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails); 
		t99=gettickcount();
		idx["features"]="";
		t44444=0;
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		js={};
		if(len(idx.listing_data_json) GT 0){
			js=deserializeJson(idx.listing_data_json);
		}
		request.lastPhotoId=""; 
		if(arguments.ss.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			for(i=1;i LTE idx.listing_photocount;i++){
				fNameTemp1=this.mls_id&"-"&idx.urlMlsPid&"-"&i&".jpeg";
				fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.retsPhotoPath&this.mls_id&'/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
			}
			// if(structkeyexists(js, "arrPhoto")){
			// 	for(i=1;i<=arraylen(js.arrPhoto);i++){
			// 		idx["photo#i#"]=js.arrPhoto[i];
			// 	}
			// 	request.lastPhotoId=idx.listing_id&"-1";
			// }
		} 
		idx["agentName"]="";//arguments.ss["rets32_listagentfullname"];
		idx["agentPhone"]="";//arguments.ss["RETS32_LISTAGENTDIRECTWORKPHONE"];
		//idx["agentEmail"]=arguments.ss["rets32_listagentemail"];
		idx["officeName"]=idx.listing_office_name;//arguments.ss["rets32_listofficename"];
		idx["officePhone"]="";//arguments.ss["RETS32_LISTOFFICEPHONE"];
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(js, "VirtualTourURLUnbranded");//application.zcore.functions.zso(arguments.ss, "rets32_virtualtoururlunbranded");
		idx["zipcode"]=idx.listing_data_zip;//application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_postalcode");
		// if(application.zcore.functions.zso(arguments.ss, "rets32_associationfee") NEQ ""){
		// 	idx["maintfees"]=arguments.ss["rets32_associationfee"]; 
			
		// }else{
			idx["maintfees"]=0;
		// }
		
		
		</cfscript>
        <cfsavecontent variable="details">
        <table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
        </table>
        </cfsavecontent>
        <cfscript>
		idx.details=details;
		
		return idx;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
        <cfargument name="sysid" type="string" required="no" default="0">
    	<cfscript>
		db=request.zos.queryObject;  

		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		return request.zos.retsPhotoPath&this.mls_id&'/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		


		// db.sql="select *
		// from 
		// #db.table("mlsgrid_media", request.zos.zcoreDatasource)# 
		// WHERE listing_id=#db.param(this.mls_id&"-"&arguments.mls_pid)# and 
		// mlsgrid_media_url<>#db.param('')# and 
		// mlsgrid_media_order=#db.param(arguments.num-1)# and 
		// mlsgrid_media_deleted=#db.param(0)# 
		// limit #db.param(0)#,#db.param(1)#";
		// qPhoto=db.execute("qPhoto"); 
		// request.lastPhotoId="";
		// for(row in qPhoto){
		// 	request.lastPhotoId=row.listing_id&"-1"; 
		// 	if(row.mlsgrid_media_url CONTAINS "/zimageproxy/"){
		// 		link=row.mlsgrid_media_url;
		// 	}else{
		// 		link="/zimageproxy/"&replace(replace(row.mlsgrid_media_url,"http://",""),"https://","");
		// 	}
		// 	return link;
		// }
		// return ""; 
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>  

		return {arrSQL:[], cityCreated:false, arrError:[]};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>