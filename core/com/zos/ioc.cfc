<!--- 
TODO: I added extends recursion, but I'm not sure it is accurate for the init / contructor.  It was only added for properties.
	it looked good at a glance!
	
I should improve this by adding the ability to create all of the CFCs (without depencies injection) onApplicationStart and onSiteStart, so that I can just duplicate() for specific requests.  Singletons should not be running duplicate however.
 --->
<cfcomponent>	<cfproperty name="serverScope" type="struct">
	<cfproperty name="applicationScope" type="struct">
	<cfproperty name="requestScope" type="struct">
<cfoutput>
    
    <cffunction name="init" localmode="modern" access="public" returntype="ioc">
    	<cfargument name="serverScope" type="struct" required="yes">
    	<cfargument name="applicationScope" type="struct" required="yes">
    	<cfargument name="requestScope" type="struct" required="yes">
    	<cfscript>
		variables.singletonCacheStruct=structnew();
		variables.serverScope=arguments.serverScope;
		variables.serverScope.metadataCacheStruct=structnew();
		// move to application.cfc functions
		if(structkeyexists(arguments.serverScope, 'singletonCacheStruct') EQ false){
			arguments.serverScope.singletonCacheStruct=structnew();
		}
		if(structkeyexists(arguments.applicationScope, 'singletonCacheStruct') EQ false){
			arguments.applicationScope.singletonCacheStruct=structnew();
		}
		if(structkeyexists(arguments.requestScope, 'singletonCacheStruct') EQ false){
			arguments.requestScope.singletonCacheStruct=structnew();
		}
		variables.singletonCacheStruct.variables=structnew();
		variables.singletonCacheStruct.server=arguments.serverScope.singletonCacheStruct;
		variables.singletonCacheStruct.application=arguments.applicationScope.singletonCacheStruct;
		variables.singletonCacheStruct.request=arguments.requestScope.singletonCacheStruct;
		return this;
		</cfscript>
    </cffunction>
    
	<cffunction name="resolve" localmode="modern" access="public" returntype="any">
		<cfargument name="class" type="string" required="yes">
		<cfargument name="argumentsCollection" type="struct" required="no" default="#structnew()#" hint="Each key is a class name with a nested structure with named parameters for the init function.">
		<cfargument name="uniqueInjectStruct" type="struct" required="no" default="#structnew()#" hint="we don't want to repeat injection if the constructor already has done it!">
        <cfscript>
		
		//local.actemp=structcount(arguments.uniqueInjectStruct);
		if(structkeyexists(variables.serverScope.metadataCacheStruct, arguments.class)){
			local.md=variables.serverScope.metadataCacheStruct[arguments.class];
		}else{
			local.md=getcomponentmetadata(arguments.class);
		}
		if(structkeyexists(arguments.uniqueInjectStruct, arguments.class)){
			return arguments.uniqueInjectStruct[arguments.class];	
		}
		local.uniqueInjectStruct=structnew();
		local.singleton="z:ioc:singleton";
		local.saveSingleton=false;
		if(structkeyexists(local.md, local.singleton)){
			if(structkeyexists(variables.singletonCacheStruct, local.md[local.singleton])){
				local.s=variables.singletonCacheStruct[local.md[local.singleton]];
				if(structkeyexists(local.s, arguments.class)){
					return local.s[arguments.class];
				}else{
					local.newObject=createobject("component", arguments.class);
					local.saveSingleton=true;
				}
			}else{
				application.zcore.functions.zError('Invalid scope for IOC singleton storage, "'&local.md[local.singleton]&'".  Only variables, request, application or server can be used.');
			}
		}else{
			local.newObject=createobject("component", arguments.class);
		}
		local.initFunction="";
		arguments.uniqueInjectStruct[arguments.class]=local.newObject;
		for(local.i2=1;local.i2 LTE arraylen(local.md.functions);local.i2++){
			if(structkeyexists(local.md.functions[local.i2], 'z:ioc:init')){//.name EQ "init"){
				local.initFunction=local.md.functions[local.i2].name;
				// find any dependent parameters "z:ioc:class" and add them to the argumentsCollection
				for(local.i=1;local.i LTE arraylen(local.md.functions[local.i2].parameters);local.i++){
					if(structkeyexists(local.md.functions[local.i2].parameters[local.i], "z:ioc:class")){
						local.curName=local.md.functions[local.i2].parameters[local.i].name;
						local.curClass=local.md.functions[local.i2].parameters[local.i]["z:ioc:class"];
						local.t9=this.resolve(local.curClass, arguments.argumentsCollection);
						if(structkeyexists(arguments.argumentsCollection,arguments.class) EQ false){
							arguments.argumentsCollection[arguments.class]=structnew();
						}
						arguments.argumentsCollection[arguments.class][local.curName]=local.t9;
						arguments.uniqueInjectStruct[local.curClass]=local.t9;
						local.uniqueInjectStruct[local.curClass]=local.t9;
					}
				}
			}
		}
		if(len(local.initFunction)){
			if(structkeyexists(arguments.argumentsCollection, arguments.class) EQ false){
				local.newObject[local.initFunction]();
			}else{
				local.newObject[local.initFunction](argumentCollection=arguments.argumentsCollection[arguments.class]);
			}
		}
		for(local.i=1;local.i LTE arraylen(local.md.properties);local.i++){
			if(structkeyexists(local.md.properties[local.i], "z:ioc:class") and structkeyexists(local.uniqueInjectStruct, local.md.properties[local.i]["z:ioc:class"]) EQ false){
				// recurse to create all the nested dependencies and return the object and set the current property to it.
				local.newObject["set"&local.md.properties[local.i].name](this.resolve(local.md.properties[local.i]["z:ioc:class"], arguments.argumentsCollection, arguments.uniqueInjectStruct));
				local.uniqueInjectStruct[local.md.properties[local.i]["z:ioc:class"]]=local.newObject["set"&local.md.properties[local.i].name];
			}
		}
		
		
		if(structkeyexists(local.md, 'extends')){
			this.checkBaseComponent(local.md.extends, local.newObject, arguments.class, arguments.argumentsCollection, arguments.uniqueInjectStruct);
		}
		if(local.saveSingleton){
			local.s[arguments.class]=local.newObject;
		}
		/*if(arguments.class EQ request.zRootCFCPath&"di-ioc.vehicles.controller.vehicle" and local.actemp EQ 0){
			writedump(local.newObject);
			local.newObject.dumpSuper();
			application.zcore.functions.zabort();
		}*/
		return local.newObject;
		</cfscript>
	</cffunction>
    
    <cffunction name="checkBaseComponent" localmode="modern" returntype="any" access="private">
		<cfargument name="baseComponentMetaData" type="struct" required="yes">
		<cfargument name="baseComponentObject" type="any" required="yes">
		<cfargument name="class" type="string" required="yes">
		<cfargument name="argumentsCollection" type="struct" required="no" default="#structnew()#" hint="Each key is a class name with a nested structure with named parameters for the init function.">
		<cfargument name="uniqueInjectStruct" type="struct" required="no" default="#structnew()#" hint="we don't want to repeat injection if the constructor already has done it!">
        <cfscript>
		
		local.md=arguments.baseComponentMetaData;
		local.newObject=arguments.baseComponentObject;
		//writedump(local.md.extends.properties);
		for(local.i=1;local.i LTE arraylen(local.md.properties);local.i++){
			if(structkeyexists(local.md.properties[local.i], "z:ioc:class")){// and structkeyexists(local.uniqueInjectStruct, local.md.properties[local.i]["z:ioc:class"]) EQ false){
				//writeoutput('hm?:'&local.md.properties[local.i]["z:ioc:class"]&'<br />');
				// recurse to create all the nested dependencies and return the object and set the current property to it.
				local.newObject["set"&local.md.properties[local.i].name](this.resolve(local.md.properties[local.i]["z:ioc:class"], arguments.argumentsCollection, arguments.uniqueInjectStruct));
				local.uniqueInjectStruct[local.md.properties[local.i]["z:ioc:class"]]=local.newObject["set"&local.md.properties[local.i].name];
			}
		}
		if(structkeyexists(local.md, 'extends')){
			this.checkBaseComponent(local.md.extends, local.newObject, arguments.class, arguments.argumentsCollection, arguments.uniqueInjectStruct);
		}
		</cfscript>
    </cffunction>
    </cfoutput>
</cfcomponent>