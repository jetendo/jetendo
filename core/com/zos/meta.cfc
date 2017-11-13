<cfcomponent>
<cfoutput>
<!--- 

register in zCoreCustomFunctions onSiteStart
store meta data in external table?  tableName-keyId i.e. office-12 with index on it.  varchar 100

if i store as tableName_meta_json longtext, then i don't need all the extra queries.  i just need to return the serialized string.

onSiteStart:
	
	// enforces current version and correct structure
	metaStruct=getMetaData("office", row.office_meta_json);
	dealerId=metaStruct.dealerId;



displayMetaForm("office", "", "first");
displayMetaForm("office", "", "last");
displayMetaForm("office", "Basic", "first");
displayMetaForm("office", "Basic", "last");
displayMetaForm("office", "Advanced", "last");
displayMetaForm("office", "Advanced", "last");

form=validateMetaForm("office", form);
ts.office_meta_json=saveMetaForm("office", form);

 --->

<!--- 
<cffunction name="onSiteStart" localmode="modern" access="public">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ss=arguments.sharedStruct;
	ts2={
		"office":{
			cfcPath:request.zRootCFCPath&"mvc.controller.officeMeta",
			field:"office_meta_json",
			version:1 // increment this if upgrading required a data format change that is incompatible with previous version | typically only needed for changes to existing fields.
		}
	};
	ss.metaCache=application.zcore.meta.register(ts2);
	</cfscript>
</cffunction>
 --->
<cffunction name="register" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		metaObjectCache:{},
		arrFieldCache:{},
	};
	for(metaForm in arguments.ss){
		metaStruct=arguments.ss[metaForm];
		metaCom=createObject("component", metaStruct.cfcPath);
		t2={}; 
		t2.cfcPath=metaStruct.cfcPath;
		t2.config=metaCom.getConfig(); 
		for(fieldStruct in t2.config.arrField){
			if(not structkeyexists(ts.arrFieldCache, fieldStruct.tab&"-"&fieldStruct.position)){
				ts.arrFieldCache[fieldStruct.tab&"-"&fieldStruct.position]=[];
			}
			arrayAppend(ts.arrFieldCache[fieldStruct.tab&"-"&fieldStruct.position], fieldStruct);
		}
		ts.metaObjectCache[metaForm]=t2;
	}
	return ts;
	</cfscript>	
</cffunction>

<!--- #application.zcore.meta.displayForm("office", "Basic", "first")# --->
<cffunction name="displayForm" localmode="modern" access="public">
	<cfargument name="formName" type="string" required="yes">
	<cfargument name="tabName" type="string" required="yes">
	<cfargument name="position" type="string" required="yes">
	<cfargument name="returnData" type="boolean" required="no" default="#false#">
	<cfscript>
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache')){
		return [];
	}
	ss=application.siteStruct[request.zos.globals.id].metaCache;
	cfcStruct={};
	if(not structkeyexists(ss.metaObjectCache, arguments.formName)){
		return [];
	} 
	tempCom=createObject("component", ss.metaObjectCache[arguments.formName].cfcPath);

	if(arguments.returnData){
		arrField=[];
		if(structkeyexists(ss.arrFieldCache, arguments.tabName&"-"&arguments.position)){ 
			for(fieldStruct in ss.arrFieldCache[arguments.tabName&"-"&arguments.position]){
				// render each field
				ts={
					label:fieldStruct.label,
					field:tempCom[fieldStruct.formRenderMethod](),
					required:false
				};
				if(structkeyexists(fieldStruct, 'required') and fieldStruct.required){
					ts.required=true;
				}
				arrayAppend(arrField, ts);
			}
		}
		return arrField;
	}else{
		arrField=[];
		if(structkeyexists(ss.arrFieldCache, arguments.tabName&"-"&arguments.position)){ 
			for(fieldStruct in ss.arrFieldCache[arguments.tabName&"-"&arguments.position]){
				// render each field
				arrayAppend(arrField, '<tr><th>'&fieldStruct.label&'</th><td>'&tempCom[fieldStruct.formRenderMethod]());
				if(structkeyexists(fieldStruct, 'required') and fieldStruct.required){
					arrayAppend(arrField, ' *');
				}
				arrayAppend(arrField, '</td></tr>');
			}
		}
		return arrayToList(arrField, chr(10));
	}
	</cfscript>
</cffunction>
	

<!--- 
arrError=application.zcore.meta.validate("office", form);
if(arrayLen(arrError)){
	for(e in arrError){
		application.zcore.status.setStatus(request.zsid, e, form, true);
	}
	application.zcore.functions.zRedirect("/redirect/to/form?zsid=#request.zsid#");
}
 --->
<cffunction name="validate" localmode="modern" returntype="array" access="public">
	<cfargument name="formName" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache')){
		return [];
	}
	ss=application.siteStruct[request.zos.globals.id].metaCache;
	arrError=[];
	if(not structkeyexists(ss.metaObjectCache, arguments.formName)){
		return arrError;
	}
	for(fieldStruct in ss.metaObjectCache[arguments.formName].config.arrField){
		if(structkeyexists(fieldStruct, 'required') and fieldStruct.required){
			if(not structkeyexists(ds, fieldStruct.name) or ds[fieldStruct.name] EQ ""){
				arrayAppend(arrError, fieldStruct.label&" is required");
			}
		}
	}
	if(arrayLen(arrError)){
		// return required field errors before full validation
		return arrError;
	}
	tempCom=createObject("component", ss.metaObjectCache[arguments.formName].cfcPath);
	arrError=tempCom.validateMeta(ds, arrError);
	return arrError;
	</cfscript>
</cffunction>

<cffunction name="getData" localmode="modern" access="public">
	<cfargument name="formName" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache')){
		return {};
	}
	ss=application.siteStruct[request.zos.globals.id].metaCache;
	if(not structkeyexists(ss.metaObjectCache, arguments.formName)){
		return {};
	}
	metaStruct=ss.metaObjectCache[arguments.formName];

	tempCom=createObject("component", metaStruct.cfcPath);
	ds[metaStruct.config.field]=application.zcore.functions.zso(ds, metaStruct.config.field);
	if(ds[metaStruct.config.field] EQ ""){
		return duplicate(metaStruct.config.defaultStruct);
	}
	jsonStruct=deserializeJson(ds[metaStruct.config.field]);
	if(metaStruct.config.version LT jsonStruct.version){
		throw("metaStruct.version was older then jsonStruct.version in database.  The source code must be updated to the latest version before running this again.");
	}else if(metaStruct.config.version NEQ jsonStruct.version){
		jsonStruct=tempCom.upgrade(tempCom, ds, jsonStruct);
		structappend(jsonStruct, variables.defaultStruct, false);
	}
	return jsonStruct.data;
	</cfscript>
</cffunction>

<!--- 
form.office_meta_json=application.zcore.meta.save("office", form);
 --->
<cffunction name="save" localmode="modern" access="public">
	<cfargument name="formName" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	formName=arguments.formName;
	ds=arguments.dataStruct;
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache')){
		return "";
	}
	ss=application.siteStruct[request.zos.globals.id].metaCache;
	if(not structkeyexists(ss.metaObjectCache, formName)){
		return "";
	}
	metaStruct=ss.metaObjectCache[formName];

	jsonStruct={
		version:metaStruct.config.version,
		data:getData(formName, ds)
	};
	tempCom=createObject("component", metaStruct.cfcPath);
	for(fieldStruct in ss.metaObjectCache[formName].config.arrField){
		if(structkeyexists(ds, fieldStruct.name)){
			// TODO: may need to skip file / image types later to avoid losing that data - for now, we only support string values.
			jsonStruct.data[fieldStruct.name]=ds[fieldStruct.name];
		}
	}
	ds[metaStruct.config.field]=serializeJson(jsonStruct);
	return ds[metaStruct.config.field];
	</cfscript>
</cffunction>


<cffunction name="delete" localmode="modern" access="public">
	<cfargument name="formName" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ds=arguments.dataStruct;
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache')){
		return {success:true};
	}
	ss=application.siteStruct[request.zos.globals.id].metaCache;
	if(not structkeyexists(ss.metaObjectCache, arguments.formName)){
		return {success:true};
	}
	metaStruct=ss.metaObjectCache[arguments.formName];

	tempCom=createObject("component", metaStruct.cfcPath);
	return tempCom.delete(ds);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>