<cfcomponent output="yes">
	<cfoutput>
    <!--- 
	Kevin,

        Allow translating English to another version of English
        Add unlimited languages.
        Every field will have a global shared value between sites and the option to override to have a domain/site specific translation.
        Client will be able to edit all front-end text and eventually the back-end manager text.
        High performance - all data cached in ram or as static files.  For example, the text in javascript would be published as a static file to disk.
        Support automated translation of each field and/or prefill the translation field with data from Google Translate API - It might be possible to make it entirely automatic or just semi-automatic, which saves the developer from needing to constantly manage translations.
        Quality control/auditing system which allows some oversight of the translated information by different users so that automated translations are reviewed and/or rewritten to be accurate on a per field basis.
        Build a search report feature that makes it easy to find translations that are missing, not approved or need updating (i.e. when the English changes, it may need new translation across all languages).
        Research and implement SEO friendly URLs and options for best rankings/indexing.
        Create simple data structures, objects and conventions for using the translation system in all applications with some basic documentation.
        Create an interface for other developers to integrate the translation system with their plug-in so it can become part of the manager and caching systems.
        It may be possible to allow in-context editing or have a popup windows to edit the text for each language more easily.  This simplifies understanding when/where the text is displayed so that the translator can understand contextual meaning better.  For text that is rarely shown, such as error messages, and special conditions, these message will have to be edited on the back-end only and organized as best as they can be through categories which represent the name of the form and the action that has occurred, like frontend.member.update.errors.duplicateEmail = "There is already a user using this email address, please recover your password or use a different email address."  I may add filtering/navigation options for browsing this info as there may be hundreds or thousands of text strings eventually.
	
	
	original stays in original table or in original key lookup.
	new site translations and new global translations
	
	when translating (lookup/read) structkeyexists on application, then translation server, then global server  - this allows a cascading translation system - but it does take 3 lookups to find the data.
	if I store complete copy in application, then I waste a lot of memory for all site - inefficient.
	if i store only ID reference to the translated string in application for everything, that is less data at least.
	
	eliminate export complexity by using 2 tables so I don't have to use siteIDType everywhere.
	lang_script_global
		lang_script_global_id
		lang_script_global_name
		lang_script_global_string
		lang_culture_id int 
		lang_script_global_type char 1
		
		unique index on culture_code + name + string
	lang_script_site
		... same as lang_script_global, but:
		site_id
		
		unique index on site_id + culture_code + name + string
		add trigger code with primary key on site_id + lang_script_site_id
	
	# global permanent table
	lang_culture
		lang_culture_id
		lang_culture_code char 14 (for country specific support such as en-us or uz-UZ-Latn (worst case length))
		lang_culture_name varchar 255
		lang_culture_flag_icon varchar 255
		
		
	getTableKey will lookup the key as cultureCode + UUID instead of a long name.   The scripts that enforce global records will have to be able to retain the UUID unchanged between servers.  Do I just give every table a UUID in the future? Probably yes, but not as the main lookup/ way of searching.  It just lets me associate data to them more easily when it won't be performance sensitive.
	
	
	store the UUID value for a unique lang_table_site or lang_table_global reference in each table we're translating.  When opening the translation window, it will need to know the type of field to show (html editor, textarea or text input), dimensions of the editor, the UUID value and the culture code.
	I think translation should be done in a popup window so that it doesn't require editing existing manager scripts.

	When logged in as a developer, you can set the translation as Global: Yes | No.
	
	form.cfm fields such as select, labels, ajax lookup, and more need to translate internally as well as externally in order to integrate.  Each row is a separate function call.  Thus, there needs to be caching to avoid huge amount of getKey calls.
	
	#what if existing tables store a reference to lang_id instead of putting the table_id + table_primary_id + table_site_id in the lang table - this is even more complex with site option system and other many to many tables.
	no because we want people to change the english: ONLY when a language is added, will a lang_id be assign to the record in the table.
	should lang_id be a guid to reduce concerns over sync between servers?  how do 2 developers add translations of new string if the id is not unique?  All work would require central server if not.
		
	# store global translations for distribution
	lang_table_global
		lang_table_global_id
		lang_table_global_uuid char 36
		lang_table_global_full_string text
		
	# store site specific translations of site specific table records
	lang_table_site
		site_id
	
	
	javascript language files need to be stored as a CFML struct so they can be imported.  This also means that lang_script_global_type and lang_script_global_site_type must define whether it is CFML (0) or Javascript (1) or PHP (2)
	
	
	auditing fields needed in database but not in memory.
	
	 --->
	<cffunction name="index" localmode="modern" access="remote" returntype="string">
		<cfscript>
		var i=0;
		var c=0;
		var ts2=structnew();
		
		var ts3=structnew();
        application.zcore.template.setTag("title","Translate");
        application.zcore.template.setTag("pagetitle","Translate");
        request.zos.globals.defaultCultureCode="en-US";
        application.sitestruct[request.zos.globals.id].translateStruct=structnew();
        application.zcore.translateStruct=structnew();
		
		local.ts=structnew();
		local.ts["en-US"]=1;
		application.zcore.cultureCodeStruct=local.ts;
		
		if(structkeyexists(request.zos.requestData.headers,'accept-language') and request.zos.requestData.headers["accept-language"] CONTAINS ","){
			request.zos.currentCultureCode=listgetat(request.zos.requestData.headers["accept-language"], 1, ",");
			if(structkeyexists(application.zcore.cultureCodeStruct, request.zos.currentCultureCode)){
				request.zos.currentCultureCodeID=application.zcore.cultureCodeStruct[request.zos.currentCultureCode];
			}
		}else{
			request.zos.currentCultureCode=request.zos.globals.defaultCultureCode;
			request.zos.currentCultureCodeID=application.zcore.cultureCodeStruct[request.zos.currentCultureCode];
		}
		writeoutput('Current Culture Code:'&request.zos.currentCultureCode&'<br />');
		
        request.zos.translate=this;
		request.zos.translate.setCultureCode(request.zos.currentCultureCode);
		
        s=gettickcount();
        for(i=1;i LTE 1000;i++){
            c=request.zos.translate.getKey("myscript.shortstring", "Full string");
        }
        writeoutput(((gettickcount()-s)/1000)&' seconds - optimized translate function<br />');
        </cfscript>
    
	</cffunction>
    
        
    <cffunction name="setCultureCode" localmode="modern" output="no" returntype="any">
    	<cfargument name="cultureCode" type="string" required="yes">
        <cfscript>
		if(structkeyexists(application.sitestruct[request.zos.globals.id].translateStruct, arguments.cultureCode) EQ false){
			variables.appTranslateStruct=structnew();
		}else{ 
			variables.appTranslateStruct=application.sitestruct[request.zos.globals.id].translateStruct[arguments.cultureCode];
		}
		if(structkeyexists(application.zcore.translateStruct, arguments.cultureCode) EQ false){
			variables.serverTranslateStruct=structnew();
		}else{
			variables.serverTranslateStruct=application.zcore.translateStruct[arguments.cultureCode];
		}
		</cfscript>
    </cffunction>
    
	<!--- request.zos.translate.getKey(scriptKeyName, originalString); --->
    <cffunction name="getKey" localmode="modern" output="no" access="public" returntype="string">
        <cfargument name="scriptKeyName" type="string" required="yes">
        <cfargument name="originalString" type="string" required="yes">
        <cfscript>
        if(structkeyexists(variables.appTranslateStruct, arguments.scriptKeyName)){
            // site specific user language
            return variables.appTranslateStruct[arguments.scriptKeyName];
        }else if(structkeyexists(variables.serverTranslateStruct, arguments.scriptKeyName)){
            // global user language
            return variables.serverTranslateStruct[arguments.scriptKeyName];
        }else{
            // insert into database and structures here?
            
            // the untranslated string - this request doesn't use a different language so we can return early.
            return arguments.originalString;	
        }
        </cfscript>
    </cffunction>
    <!--- 
    <!--- request.zos.translate.getKey(cultureCode, scriptKeyName, translateKeyName, originalString); --->
    <cffunction name="getKey" localmode="modern" output="no" access="public" returntype="string">
    	<cfargument name="cultureCode" type="string" required="yes">
        <cfargument name="scriptKeyName" type="string" required="yes">
        <cfargument name="stringToTranslate" type="string" required="yes">
       	<cfscript>
		var as=application.sitestruct[request.zos.globals.id].translateStruct;
		var ss=application.zcore.translateStruct;
		var c=chr(10);
		var k=arguments.cultureCode&c&arguments.scriptKeyName&c&arguments.stringToTranslate;
		if(structkeyexists(as, k)){
			// site specific user language
			return as[k];
		}else if(structkeyexists(ss, k)){
			// global user language
			return ss[k];
		}else if(arguments.cultureCode EQ request.zos.globals.defaultCultureCode){
			// insert into database and structures here?
			
			// the untranslated string - this request doesn't use a different language so we can return early.
			return arguments.stringToTranslate;	
		}else if(structkeyexists(as, request.zos.globals.defaultCultureCode&c&arguments.scriptKeyName&c&arguments.stringToTranslate)){
			// site specific default language
			return as[request.zos.globals.defaultCultureCode&c&arguments.scriptKeyName&c&arguments.stringToTranslate];
		}else if(structkeyexists(ss, request.zos.globals.defaultCultureCode&c&arguments.scriptKeyName&c&arguments.stringToTranslate)){
			// global default language
			return ss[request.zos.globals.defaultCultureCode&c&arguments.scriptKeyName&c&arguments.stringToTranslate];
		}else{
			// insert into database and structures here?
			
			// the untranslated string
			return arguments.stringToTranslate;	
		}
		</cfscript>
    </cffunction> --->
     
     
     <cffunction name="manage" localmode="modern" access="remote" roles="member">
    	<cfif request.zos.istestserver EQ false>
        Coming soon.
        <cfelse>
        <cfscript>
		
        </cfscript>
        </cfif>
	</cffunction>
    
	</cfoutput>
</cfcomponent>