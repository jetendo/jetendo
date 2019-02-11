<cfcomponent>
	<!--- 
	TODO:	add openid support for: twitter, aol, linkedin, windows live
	add support for startssl to enable smart card login: http://www.startssl.com/?app=14
	add logos for each provider
	
	when working, run this query on both servers: UPDATE `site` SET site_disable_openid=#db.param(0)# 
WHERE site_id <>'16'
	flush cache and zreset=server afterwards
	 ---> 
	<cfoutput>
    <cfscript>
	variables.userExisted=false; 
	variables.disableDeveloperLinks=false;
	variables.registrationLoginLinks=false;
    variables.arrOpenIdProvider=[
		/*{
			url:"https://www.google.com/accounts/o8/ud", 
			name:"Google", 
			icon:"/z/images/icons/google-icon.png",
			providerId:1
		},*/
		{
			url:"https://open.login.yahooapis.com/openid/op/auth", 
			name:"Yahoo", 
			icon:"/z/images/icons/yahoo-icon.png",
			providerId:2
		},
		{
			url:"https://api.screenname.aol.com/auth/openidServer", 
			name:"AOL", 
			icon:"/z/images/icons/aol-icon.png",
			providerId:4
		},
		
		{
			url:"", 
			name:"Custom", 
			icon:"/z/images/icons/openid-icon.png",
			providerId:3
		}
			
	];
	variables.providerStruct[0]="None";
	variables.providerStruct[1]="Google";
	variables.providerStruct[2]="Yahoo";
	variables.providerStruct[3]="Custom";
	variables.providerStruct[4]="AOL";
	</cfscript>
    
    <cffunction name="userExisted" localmode="modern" output="no" returntype="boolean">
    	<cfscript>
		return variables.userExisted;
		</cfscript>
    </cffunction>
    
	<cffunction name="displayProviderLinksForUser" localmode="modern" access="private" returntype="string">
    	<cfargument name="user_id" type="string" required="yes">
    	<cfargument name="site_id" type="string" required="yes">
		<cfscript>
		
		var theOutput="";
		var ts=structnew();
		var i=0;
		var n=0;
		var arrURL=arraynew(1);
		if(arguments.user_id EQ "" or arguments.site_id EQ ""){
			return "";
		}
        // facebook authentication has a javascript sdk using oauth 2, which requires an app id for each domain: http://developers.facebook.com/docs/guides/web/
        
        
        // coldfusion openid app had a url discovery feature, but I just use the endpoints directly below: 
        
        // aol can't verify and breaks after already logged in - i might have to build the url discovery feature like this says: http://stackoverflow.com/questions/7529013/aol-openid-website-verification
        
        // all provider urls: http://www.digitalenginesoftware.com/blog/archives/24-OpenID-Provider-URL-Formatting.html
        //"https://api.screenname.aol.com/auth/openidServer");//http://openid.aol.com/skyflare21"
        // "AOL/AIM"
        /*
        arrayappend(arrOpenId,'http://api.myspace.com/openid');
        Yahoo:	http://yahoo.com/ *	good
        MyOpenId:	http://username.myopenid.com	good
        LiveJournal:	http://username.livejournal.com	good
        AOL:	http://openid.aol.com/username	good
        WordPress:	http://username.wordpress.com	good
        Blogspot:	http://username.blogspot.com	must use blog url, blogspot = blogger
        Verisign:	http://username.pip.verisignlabs.com
        MySpace:	http://myspace.com/username
        */
        
		if(application.zcore.user.checkGroupAccess("member") EQ false){
			local.returnToURL=request.zos.currentHostName&"/z/user/preference/form";
		}else{
			local.returnToURL=request.zos.currentHostName&"/z/admin/member/edit?user_id="&arguments.user_id;
		}
		if(arguments.site_id EQ request.zos.globals.id){
			if(arguments.site_id EQ request.zos.globals.serverid){
				local.returnToURL=request.zos.currentHostName&'/z/server-manager/admin/user/editUser?sid='&request.zos.globals.serverid&'&user_id='&arguments.user_id;
			}
		}else if(arguments.site_id EQ request.zos.globals.parentid){
			return 'You must login to the parent site first. <a href="'&application.zcore.functions.zvar("domain", request.zos.globals.parentid)&"/z/admin/member/edit?user_id="&arguments.user_id&'" target="_blank">Click here</a>';
		}else if(application.zcore.user.checkServerAccess()){
			return 'You must login to the server manager to connect an account. <a href="'&request.zos.globals.serverdomain&'/z/server-manager/admin/user/editUser?sid='&request.zos.globals.serverid&'&user_id='&arguments.user_id&'" target="_blank">Click here</a>';
		}else{
			application.zcore.functions.zError("Invalid site_id, #arguments.site_id#, for user_id = #arguments.user_id#.");
		}
		writeoutput(this.displayProviderLinks(local.returnToURL));
		</cfscript>
    </cffunction>
    
    <cffunction name="enableRegistrationLoginLinks" localmode="modern" access="public" returntype="void">
    	<cfset variables.registrationLoginLinks=true>
    </cffunction>
    
	<cffunction name="displayProviderLinks" localmode="modern" access="public" returntype="string">
    	<cfargument name="returnToURL" type="string" required="yes">
		<cfscript>
		
		var theOutput="";
		var ts=structnew();
		var i=0;
		var n=0;
		var arrURL=arraynew(1);
		
        ts["openid.ns"]="http://specs.openid.net/auth/2.0";
        ts["openid.mode"]="checkid_setup";
        ts["openid.claimed_id"]="http://specs.openid.net/auth/2.0/identifier_select";
        ts["openid.identity"]="http://specs.openid.net/auth/2.0/identifier_select";
        ts["openid.ax.mode"]="fetch_request";
        ts["openid.assoc_handle"]="";
		/*ts["openid.ext1.type.email"]="http://axschema.org/contact/email";
		ts["openid.ext1.type.firstname"]="http://axschema.org/namePerson/first";
		ts["openid.ext1.type.lastname"]="http://axschema.org/namePerson/last";
		ts["openid.ext1.type.fullname"]="http://axschema.org/namePerson";
		ts["openid.ext1.type.country"]="http://axschema.org/contact/country/home";
		ts["openid.ext1.type.language"]="http://axschema.org/pref/language";
        ts["openid.ext1.type.dob"]="http://axschema.org/birthDate";
        ts["openid.ext1.type.timezone"]="http://axschema.org/timezone";
		ts["openid.ext1.type.postcode"]="http://axschema.org/contact/postalcode/home";
		ts["openid.ext1.required"]="email";
		ts["openid.ext1.optional"]="firstname,lastname,dob,country,language";*/ 
        ts["openid.ax.required"]="email,country,firstname,lastname,language";
		//ts["openid.ax.optional"]="dob,gender,postcode,timezone";
        ts["openid.ax.type.email"]="http://axschema.org/contact/email";
        //ts["openid.ax.type.fullname"]="http://axschema.org/namePerson"; 
        ts["openid.ax.type.country"]="http://axschema.org/contact/country/home";
        //ts["openid.ax.type.dob"]="http://axschema.org/birthDate"; 
		//ts["openid.ax.type.postcode"]="http://axschema.org/contact/postalcode/home";
       	ts["openid.ax.type.firstname"]="http://axschema.org/namePerson/first";
       	ts["openid.ax.type.lastname"]="http://axschema.org/namePerson/last";
		ts["openid.ax.type.language"]="http://axschema.org/pref/language";
        ts["openid.ns.ax"]="http://openid.net/srv/ax/1.0";
        ts["openid.ns.sreg"]="http://openid.net/extensions/sreg/1.1";
        ts["openid.sreg.required"]="email,country,firstname,lastname,language";
		ts["openid.sreg.optional"]="dob,gender,postcode,timezone";
        for(i in ts){
            arrayAppend(arrURL,i&'='&urlencodedformat(ts[i]));
        }
        local.arrDev=arraynew(1);
        </cfscript>
        <cfsavecontent variable="theOutput">
		<cfscript>
		if(structkeyexists(cookie,'zopenidprovider') and structkeyexists(variables.providerStruct, cookie.zopenidprovider)){
			writeoutput('<div class="zmember-openid-subheader">You last logged in with '&variables.providerStruct[cookie.zopenidprovider]&'.</div>');
		}
		</cfscript>
        <cfloop from="1" to="#arraylen(variables.arrOpenIdProvider)#" index="n">
			<cfscript>
            local.curReturnTo=application.zcore.functions.zURLAppend(arguments.returnToURL,"providerId="&variables.arrOpenIdProvider[n].providerId);
            if(variables.registrationLoginLinks){
                local.curReturnTo=application.zcore.functions.zURLAppend(local.curReturnTo,"zRegisterAccount=1");
            }
            </cfscript>
			<cfif variables.arrOpenIdProvider[n].name EQ "Custom">
            	<div class="zmember-openid-subheader">Or enter another OpenID Provider URL</div>
            	<div class="zmember-openid-buttons" style="width:95%;"><input type="text" name="openidurl" id="openidurl" value="<cfif isDefined('cookie.zopenidurl')>#htmleditformat(urldecode(cookie.zopenidurl))#</cfif>" /></div>
                <div class="zmember-openid-buttons"><button type="button" name="openidsubmit" onclick="<cfif structkeyexists(request.zos, 'inMemberArea') and request.zos.inMemberArea and application.zcore.user.checkGroupAccess("user")>zLogin.zOpenidLogin(false);<cfelse>openidAutoConfirm(false);</cfif>" value="">Login with <cfif variables.arrOpenIdProvider[n].icon NEQ ""><img src="#variables.arrOpenIdProvider[n].icon#" alt="Login with OpenID" width="80" style="vertical-align:middle;margin-top:-3px;" /></cfif></button> 
                
                <input type="hidden" name="openidhiddenurl" id="openidhiddenurl" value="?openid.return_to=#urlencodedformat(local.curReturnTo)#&amp;#arraytolist(arrURL,"&amp;")#&amp;openid.realm=#urlencodedformat(request.zos.currentHostName&"/")#" />
                </div>
                <!--- <cfif request.zos.isdeveloper and request.zos.globals.id NEQ request.zos.globals.serverid and (request.zos.inMemberArea EQ false or application.zcore.user.checkGroupAccess("user") EQ false) and variables.disableDeveloperLinks EQ false>
                    <cfscript>
                    local.curReturnTo=request.zos.globals.serverDomain&"/?zOpenIdDomain="&urlencodedformat(local.curReturnTo);
                    </cfscript> 
                    <cfsavecontent variable="local.devContent">
                <div class="zmember-openid-buttons">
                    <input type="hidden" name="openidhiddenurl2" id="openidhiddenurl2" value="?openid.return_to=#urlencodedformat(local.curReturnTo)#&amp;#arraytolist(arrURL,"&amp;")#&amp;openid.realm=#urlencodedformat(request.zos.globals.serverdomain&"/")#" />
                    <button type="button" name="openidsubmit2" onclick="zLogin.openidAutoConfirm(true);" style="height:39px !important;"><cfif variables.arrOpenIdProvider[n].icon NEQ ""><img src="#variables.arrOpenIdProvider[n].icon#" alt="Login with OpenID" width="80" style="vertical-align:middle;margin-top:-3px;" /></cfif> Global</button>
                    </div>
                    </cfsavecontent>
                    <cfscript>
					arrayAppend(local.arrDev, local.devContent);
					</cfscript>
                </cfif> --->
                
            <cfelse>
				<cfscript>
				local.curLink="#variables.arrOpenIdProvider[n].url#?openid.return_to=#urlencodedformat(local.curReturnTo)#&amp;#arraytolist(arrURL,"&amp;")#&amp;openid.realm=#urlencodedformat(request.zos.currentHostName&"/")#";
                </cfscript>
                <div class="zmember-openid-buttons"><a href="##" <cfif isDefined('cookie.zopenidprovider') and structkeyexists(variables.providerStruct, cookie.zopenidprovider) and variables.providerStruct[cookie.zopenidprovider] EQ variables.arrOpenIdProvider[n].name>style="padding:3px;border:2px solid ##900;"</cfif> onclick="<cfif structkeyexists(request.zos, 'inMemberArea') and (request.zos.inMemberArea and application.zcore.user.checkGroupAccess("user"))>zLogin.zOpenidLogin3('#local.curLink#');<cfelse>zLogin.openidAutoConfirm2('#local.curLink#');</cfif>return false;"><cfif variables.arrOpenIdProvider[n].icon NEQ ""><img src="#variables.arrOpenIdProvider[n].icon#" alt="Login with #variables.arrOpenIdProvider[n].name#" width="30" style="vertical-align:middle;" /></cfif> #variables.arrOpenIdProvider[n].name#</a>
                </div>
                <!--- <cfif request.zos.isdeveloper and request.zos.globals.id NEQ request.zos.globals.serverid and (request.zos.inMemberArea EQ false or application.zcore.user.checkGroupAccess("user") EQ false) and variables.disableDeveloperLinks EQ false>
                    <cfscript>
                    local.curReturnTo=request.zos.globals.serverDomain&"/?zOpenIdDomain="&urlencodedformat(local.curReturnTo);
                    </cfscript> 
                    <cfsavecontent variable="local.devContent">
                <div class="zmember-openid-buttons">
                     <a href="##" <cfif isDefined('cookie.zopenidprovider') and structkeyexists(variables.providerStruct, cookie.zopenidprovider) and variables.providerStruct[cookie.zopenidprovider] EQ variables.arrOpenIdProvider[n].name>style="padding:3px;border:2px solid ##900;"</cfif> onclick="zLogin.openidAutoConfirm2('#variables.arrOpenIdProvider[n].url#?openid.return_to=#urlencodedformat(local.curReturnTo)#&amp;#arraytolist(arrURL,"&amp;")#&amp;openid.realm=#urlencodedformat(request.zos.globals.serverdomain&"/")#');return false;"><cfif variables.arrOpenIdProvider[n].icon NEQ ""><img src="#variables.arrOpenIdProvider[n].icon#" alt="Login with #variables.arrOpenIdProvider[n].name#" width="30" style="vertical-align:middle;" /></cfif> #variables.arrOpenIdProvider[n].name#</a></div>
                     </cfsavecontent>
                     <cfscript>
                     arrayAppend(local.arrDev, local.devContent);
					 </cfscript>
                </cfif> --->
            </cfif>
        </cfloop>
        <!--- <cfif arraylen(local.arrDev) NEQ 0>
        <br style="clear:both;" />
        	<h3>Global Developer OpenID Login</h3>
        	#arraytolist(local.arrDev,"")#
        </cfif> --->
        </cfsavecontent>
        <cfreturn theOutput>
	</cffunction>
    
    
    <cffunction name="disableDeveloperLoginLinks" localmode="modern" access="public" output="no" returntype="any">
    	<cfscript>
		variables.disableDeveloperLinks=true;
		</cfscript>
    </cffunction>
    
    <cffunction name="verifyOpenIdLogin" localmode="modern" access="public" output="no" returntype="any">
    	<cfscript>
		
		var theOutput="";
		var inputStruct=0;
		var rs=0;
		var parentIdSQL=0;
		var ts=0;
		var db=request.zos.queryObject;
		var cfhttp="";
		var local.emailIdentity=false;
		</cfscript>
    	<cfsavecontent variable="theOutput">
		<cfif structkeyexists(form,'providerId') and structkeyexists(form,'openid.mode') and structkeyexists(form,'openid.op_endpoint')>
            <cfhttp url="#form["openid.op_endpoint"]#" method="post" throwonerror="no" timeout="10">
                <cfscript>
				// the return_to url must be identical to the original request or it will fail.  Because form variables automatically have the current host name removed from them, we must recreate the return_to url here.
				if(structkeyexists(form, 'zOpenIdGlobalLogin')){
					form["openid.return_to"]=request.zos.globals.serverdomain&"/?zOpenIdDomain="&urlencodedformat(form.zOpenIdDomainOriginal);
				}else{
					if(left(form["openid.return_to"], 4) NEQ "http"){
						form["openid.return_to"]=request.zos.currentHostName&form["openid.return_to"];
					}
				}
				local.arrUrlKeys=structkeyarray(form);
                local.formNew=structnew();
                </cfscript>
                <cfloop from="1" to="#arraylen(local.arrUrlKeys)#" index="local.i">
                    <cfif local.arrUrlKeys[local.i] EQ "openid.mode">
                        <cfhttpparam type="formfield" name="#local.arrUrlKeys[local.i]#" value="check_authentication">
                        <cfscript>
                        local.formNew[local.arrUrlKeys[local.i]]=form[local.arrUrlKeys[local.i]];
                        </cfscript>
                    <cfelseif left(local.arrUrlKeys[local.i],7) EQ "openid." and isstruct(form[local.arrUrlKeys[local.i]]) EQ false>
                        <cfhttpparam type="formfield" name="#local.arrUrlKeys[local.i]#" value="#form[local.arrUrlKeys[local.i]]#">
                        <cfscript>
                        local.formNew[local.arrUrlKeys[local.i]]=form[local.arrUrlKeys[local.i]];
                        </cfscript>
                    </cfif>
                </cfloop>
            </cfhttp>
            <cfif isDefined('cfhttp.status_code') and cfhttp.status_code EQ "200" and cfhttp.FileContent CONTAINS "is_valid:true">
                <cfscript>
				if(request.zos.globals.parentid NEQ 0){
					parentIdSQL=" or site_id ='#request.zos.globals.parentid#' ";
				}else{
					parentIdSQL="";
				}
				 db.sql="select user_id, user_username, user_password 
				 FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_openid_provider=#db.param(form.providerId)# and 
				user_deleted = #db.param(0)# and
				user_openid_id=#db.param(form["openid.identity"])# and 
				user_active= #db.param(1)# and 
				(site_id =#db.param(request.zos.globals.id)# or 
				site_id =#db.param(request.zos.globals.serverid)# "&db.trustedSQL(parentIdSQL)&")";
				local.qUser=db.execute("qUser");
				
				if(local.qUser.recordcount NEQ 0){
					form.zusername=local.qUser.user_username;
					form.zpassword=local.qUser.user_password;
					inputStruct = StructNew();
					/*if(application.zcore.functions.zso(form, 'zIsMemberArea') EQ 1){
						inputStruct.user_group_name = "member";
					}else{*/
						inputStruct.user_group_name = "user";
					//}
					inputStruct.noLoginForm=true;
					inputStruct.secureLogin=true;
					inputStruct.openIdEnabled=true;
					inputStruct.disableSecurePassword=true;
					inputStruct.site_id = request.zos.globals.id;
					rs=application.zcore.user.checkLogin(inputStruct); 
					if(rs.success){
						local.ts9=structnew();
						local.ts9.name="zopenidprovider";
						local.ts9.value=form["providerId"];
						local.ts9.expires="never";
						application.zcore.functions.zcookie(local.ts9);
						if(structkeyexists(cookie,'zautologin') and compare(cookie.zautologin,"1") EQ 0){
							application.zcore.user.createToken(); // set permanent login cookie
						}
						local.isDeveloper=0;
						if(request.zos.userSession.site_id EQ request.zos.globals.serverID and application.zcore.user.checkServerAccess()){
							local.isDeveloper="1";
						}
						local.ts9=structnew();
						local.ts9.name="zdeveloper";
						local.ts9.value=local.isDeveloper;
						local.ts9.expires="never";
						application.zcore.functions.zcookie(local.ts9);
						if(structkeyexists(form,'zOpenIdDomain')){
							application.zcore.functions.zRedirect(replace(replace(form.zOpenIdDomain,"?providerId="&form.providerId,""),"&providerId="&form.providerId,""));
						}else if(structkeyexists(form, 'disableOpenIDLoginRedirect') EQ false){
							application.zcore.functions.zRedirect(replace(replace(form["openid.return_to"],"?providerId="&form.providerId,""),"&providerId="&form.providerId,""));
						}else{
							variables.userExisted=true;
							return "";
						}
					}else{
						writeoutput('<h2>This login has been disabled.  Contact the webmaster for assistance.</h2>');
					}
				}else{
					if(structkeyexists(form, 'zRegisterAccount')){
						// must have email address to continue
						
						inputStruct = structNew();
						if(structkeyexists(form, 'openid.ext1.value.email')){
							inputStruct.user_username=form["openid.ext1.value.email"];
						}else if(structkeyexists(form, 'openid.ax.value.email')){
							inputStruct.user_username=form["openid.ax.value.email"];
						}else if(structkeyexists(form, 'openid.sreg.email')){
		                    inputStruct.user_username=form["openid.sreg.email"];
                        }else{
							inputStruct.user_username="";
						}
						if(structkeyexists(form, 'openid.ext1.value.firstName')){
							inputStruct.user_first_name=form["openid.ext1.value.firstName"];
						}else if(structkeyexists(form, 'openid.ax.value.firstName')){
							inputStruct.user_first_name=form["openid.ax.value.firstName"];
						}else if(structkeyexists(form, 'openid.sreg.firstName')){
		                    inputStruct.user_first_name=form["openid.sreg.firstName"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.lastName')){
							inputStruct.user_last_name=form["openid.ext1.value.lastName"];
						}else if(structkeyexists(form, 'openid.ax.value.lastName')){
							inputStruct.user_last_name=form["openid.ax.value.lastName"];
						}else if(structkeyexists(form, 'openid.sreg.lastName')){
		                    inputStruct.user_last_name=form["openid.sreg.lastName"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.dob')){
							inputStruct.user_birthday=form["openid.ext1.value.dob"];
						}else if(structkeyexists(form, 'openid.ax.value.dob')){
							inputStruct.user_birthday=form["openid.ax.value.dob"];
						}else if(structkeyexists(form, 'openid.sreg.dob')){
		                    inputStruct.user_birthday=form["openid.sreg.dob"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.gender')){
							inputStruct.user_gender=form["openid.ext1.value.gender"];
						}else if(structkeyexists(form, 'openid.ax.value.gender')){
							inputStruct.user_gender=form["openid.ax.value.gender"];
						}else if(structkeyexists(form, 'openid.sreg.gender')){ 
		                    inputStruct.user_gender=form["openid.sreg.gender"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.postcode')){
							inputStruct.user_zip=form["openid.ext1.value.postcode"];
						}else if(structkeyexists(form, 'openid.ax.value.postcode')){
							inputStruct.user_zip=form["openid.ax.value.postcode"];
						}else if(structkeyexists(form, 'openid.sreg.postcode')){
		                    inputStruct.user_zip=form["openid.sreg.postcode"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.timezone')){
							inputStruct.user_timezone=form["openid.ext1.value.timezone"];
						}else if(structkeyexists(form, 'openid.ax.value.timezone')){
							inputStruct.user_timezone=form["openid.ax.value.timezone"];
						}else if(structkeyexists(form, 'openid.sreg.timezone')){
		                    inputStruct.user_timezone=form["openid.sreg.timezone"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.country')){
							inputStruct.user_country=form["openid.ext1.value.country"];
						}else if(structkeyexists(form, 'openid.ax.value.country')){
							inputStruct.user_country=form["openid.ax.value.country"];
						}else if(structkeyexists(form, 'openid.sreg.country')){
		                    inputStruct.user_country=form["openid.sreg.country"];
                        }
						if(structkeyexists(form, 'openid.ext1.value.fullName')){
							local.arrTemp=listtoarray(form["openid.ext1.value.fullName"]," ");
							if(arraylen(local.arrTemp) EQ 1){
								inputStruct.user_first_name=form["openid.ext1.value.fullName"];
								inputStruct.user_last_name=".";
							}else{
								inputStruct.user_first_name=local.arrTemp[1];
								arraydeleteat(local.arrTemp, 1);
								inputStruct.user_last_name=arraytolist(local.arrTemp," ");
							}
						}else if(structkeyexists(form, 'openid.ax.value.fullName')){
							local.arrTemp=listtoarray(form["openid.ax.value.fullName"]," ");
							if(arraylen(local.arrTemp) EQ 1){
								inputStruct.user_first_name=form["openid.ax.value.fullName"];
								inputStruct.user_last_name=".";
							}else{
								inputStruct.user_first_name=local.arrTemp[1];
								arraydeleteat(local.arrTemp, 1);
								inputStruct.user_last_name=arraytolist(local.arrTemp," ");
							}
						}else if(structkeyexists(form, 'openid.sreg.fullName')){
							local.arrTemp=listtoarray(form["openid.sreg.fullName"]," ");
							if(arraylen(local.arrTemp) EQ 1){
								inputStruct.user_first_name=form["openid.sreg.fullName"];
								inputStruct.user_last_name=".";
							}else{
								inputStruct.user_first_name=local.arrTemp[1];
								arraydeleteat(local.arrTemp, 1);
								inputStruct.user_last_name=arraytolist(local.arrTemp," ");
							}
                        }
						if(trim(inputStruct.user_username) EQ "" or application.zcore.functions.zemailValidate(inputStruct.user_username) EQ false){
							writeoutput('<h2>The OpenID login was successful, but no email address was sent back to us.</h2><p>We only accept OpenID providers that are configured to pass the associated email address back to us.</p>');
						}else{
							local.ts9=structnew();
							local.ts9.name="zopenidprovider";
							local.ts9.value=form["providerId"];
							local.ts9.expires="never";
							application.zcore.functions.zcookie(local.ts9);
							inputStruct.user_openid_id=form["openid.identity"];
							inputStruct.user_openid_provider=form["providerId"];
							inputStruct.user_openid_email=inputStruct.user_username;
							inputStruct.user_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
							inputStruct.user_password=application.zcore.functions.zGenerateStrongPassword(200,200);
							
							inputStruct.user_active=1;
							inputStruct.user_key=hash(inputStruct.user_salt, "sha");
							if(request.zos.globals.plainTextPassword EQ 0){
								inputStruct.user_password_version = request.zos.defaultPasswordVersion;
								inputStruct.user_password=application.zcore.user.convertPlainTextToSecurePassword(inputStruct.user_password, inputStruct.user_salt, request.zos.defaultPasswordVersion, false);
							}else{
								inputStruct.user_password_version=0;
								inputStruct.user_salt="";	
							}
							form.zpassword=inputStruct.user_password;
							form.zusername=inputStruct.user_username; // make same as email to use email as login
							inputStruct.site_id = request.zos.globals.id; 
							inputStruct.user_email = inputStruct.user_username;
							inputStruct.member_email = inputStruct.user_username;
							
							local.userGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
							inputStruct.user_group_id=local.userGroupCom.getGroupId("user");
							inputStruct.user_pref_list=1; // set to 0 to opt out of mailing list
							inputStruct.autologin=true;
							inputStruct.createPassword=true;
							local.userAdminCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_admin");
							
							user_id = local.userAdminCom.add(inputStruct);
							if(user_id EQ false){
								// duplicate entry
								writeoutput('<h2>A user with this email address already exists.</h2><p>Please try to login or use a different account.</p>');
							}else{
								// successful
								return "";
								/*
								if(structkeyexists(form,'zOpenIdDomain')){
									application.zcore.functions.zRedirect(replace(replace(form.zOpenIdDomain,"?providerId="&form.providerId&"&zRegisterAccount=1",""),"&providerId="&form.providerId&"&zRegisterAccount=1",""));
								}else{
									application.zcore.functions.zRedirect(replace(replace(form["openid.return_to"],"?providerId="&form.providerId&"&zRegisterAccount=1",""),"&providerId="&form.providerId&"&zRegisterAccount=1",""));
								}*/
							}
						}
					}else{
						local.body="Please setup OpenID for my account at "&request.zos.currentHostName&". My OpenID Identity is: """&form["openid.identity"]&""" without quotes. My CMS Email Username is: ";
						local.webdeveloperemail=request.zos.developerEmailTo;
						if(request.zos.globals.parentId NEQ 0){
							 db.sql="select site_developer_email 
							 FROM #db.table("site", request.zos.zcoreDatasource)# site 
							WHERE site_id=#db.param(request.zos.globals.parentId)# and 
							site_deleted = #db.param(0)# ";
							local.qSiteTemp=db.execute("qSiteTemp");
							if(local.qSiteTemp.recordcount NEQ 0 and local.qSiteTemp.site_developer_email NEQ ""){
								local.webdeveloperemail=local.qSiteTemp.site_developer_email;
							}
						}
						local.mailtoLink="mailto:#local.webdeveloperemail#?subject=#urlEncodedFormat("Please setup OpenID for me")#&body=#local.body#";
						writeoutput('<h2>No account is associated with your '&variables.providerStruct[form.providerId]&' account.</h2>
						<p>Your OpenID Identity is: '&form["openid.identity"]&'</p><h2><a href="#htmleditformat(local.mailtoLink)#" style="text-decoration:underline;">Click here to email the web developer requesting OpenID setup assistance</a></h2>');
					}
				}
				</cfscript>
            <cfelse>
                <h2>Your login failed. Please try again. If the problem persists, please contact the developer.</h2>
                <cfif request.zos.isdeveloper>
                	<h2>Debugging information for developers</h2>
                    <cfdump var="#local.formNew#">
                    <cfdump var="#cfhttp#">
                </cfif>
            </cfif>
        </cfif>
        </cfsavecontent>
        <cfif trim(theOutput) NEQ "">
        	<cfreturn '<div style="width:100%; float:left;">'&theOutput&'</div>'>
        <cfelse>
	        <cfreturn "">
        </cfif>
    </cffunction>
    
    <cffunction name="registerOpenIdWithUser" localmode="modern" access="private" output="no" returntype="any">
    	<cfargument name="user_id" type="string" required="yes">
    	<cfargument name="site_id" type="string" required="yes">
    	<cfscript>
		
		var theOutput="";
		var db=request.zos.queryObject;
		var cfhttp="";
		</cfscript>
    	<cfsavecontent variable="theOutput">
		<cfif structkeyexists(form,'providerId') and structkeyexists(form,'openid.mode') and structkeyexists(form,'openid.op_endpoint')>
            <cfhttp url="#form["openid.op_endpoint"]#" method="post" throwonerror="no" timeout="10">
                <cfscript>
				// the return_to url must be identical to the original request or it will fail.  Because form variables automatically have the current host name removed from them, we must recreate the return_to url here.
				if(arguments.site_id EQ request.zos.globals.serverId){
					form["openid.return_to"]=request.zos.currentHostName&'/z/server-manager/admin/user/editUser?sid='&arguments.site_id&'&user_id='&arguments.user_id&"&providerId="&form.providerId;
				}else if(application.zcore.user.checkGroupAccess("member") EQ false){
					form["openid.return_to"]=request.zos.currentHostName&"/z/user/home/index?providerId="&form.providerId;
				}else{
					form["openid.return_to"]=request.zos.currentHostName&"/z/admin/member/edit?user_id="&arguments.user_id&"&providerId="&form.providerId;
				}
				local.arrUrlKeys=structkeyarray(form);
                local.formNew=structnew();
                </cfscript>
                <cfloop from="1" to="#arraylen(local.arrUrlKeys)#" index="local.i">
                    <cfif local.arrUrlKeys[local.i] EQ "openid.mode">
                        <cfhttpparam type="formfield" name="#local.arrUrlKeys[local.i]#" value="check_authentication">
                        <cfscript>
                        local.formNew[local.arrUrlKeys[local.i]]=form[local.arrUrlKeys[local.i]];
                        </cfscript>
                    <cfelseif left(local.arrUrlKeys[local.i],7) EQ "openid." and isstruct(form[local.arrUrlKeys[local.i]]) EQ false>
                        <cfhttpparam type="formfield" name="#local.arrUrlKeys[local.i]#" value="#form[local.arrUrlKeys[local.i]]#">
                        <cfscript>
                        local.formNew[local.arrUrlKeys[local.i]]=form[local.arrUrlKeys[local.i]];
                        </cfscript>
                    </cfif>
                </cfloop>
            </cfhttp>
            <cfif isDefined('cfhttp.status_code') and cfhttp.status_code EQ "200" and cfhttp.FileContent CONTAINS "is_valid:true">
                <cfscript>
				if(structkeyexists(form,"openid.sreg.email")){
					form["openid.ext1.value.email"]=form["openid.sreg.email"];
				}
				if(structkeyexists(form,"openid.ext1.value.email") EQ false){
					form["openid.ext1.value.email"]='';
				}
				request.zsession.secureLogin=true;
				 db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
				 set user_openid_email=#db.param(form["openid.ext1.value.email"])#, 
				 user_openid_provider=#db.param(form.providerId)#, 
				 user_openid_id=#db.param(form["openid.identity"])#,
				 user_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE user_id=#db.param(arguments.user_id)# and 
				user_deleted = #db.param(0)# and 
				site_id = #db.param(arguments.site_id)#";
				db.execute("q");
				</cfscript>
            <cfelse>
                <h2>Your login failed. Please try again.</h2>
                <cfif request.zos.isdeveloper>
                    <cfdump var="#local.formNew#">
                    <cfdump var="#cfhttp#">
                </cfif>
            
            </cfif>
        </cfif>
        </cfsavecontent>
        <cfreturn theOutput>
    </cffunction>
    
    <cffunction name="isAdminChangeAllowed" localmode="modern" access="public" output="no" returntype="boolean">
    	<cfscript>
		if(request.zos.globals.requireSecureLogin EQ "0" or (isDefined('request.zsession.secureLogin') and request.zsession.secureLogin)){
			return true;
		}else{
			return false;
		}
		</cfscript>
    </cffunction>
    
    <cffunction name="removeOpenIdForUser" localmode="modern" access="private" output="no" returntype="any">
    	<cfargument name="user_id" type="string" required="yes">
    	<cfargument name="site_id" type="string" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		if(this.isAdminChangeAllowed()){
			 db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
			 set user_openid_email=#db.param('')#, 
			 user_openid_provider=#db.param(0)#,
			  user_openid_id=#db.param('')#,
			  user_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE user_id=#db.param(arguments.user_id)# and 
			user_deleted = #db.param(0)# and 
			site_id = #db.param(arguments.site_id)#";
			db.execute("q");
			return '<h2>External Account Removed.</h2>';
		} 
		</cfscript>
    </cffunction>
    
    <!--- <cffunction name="displayOpenIdProviderForUser" localmode="modern" output="no" returntype="any">
    	<cfargument name="user_id" type="string" required="yes">
    	<cfargument name="site_id" type="string" required="yes">
        <cfscript>
		
		var selectStruct=0;
		var db=request.zos.queryObject;
		</cfscript>
        <cfsavecontent variable="local.out">
        <cfscript>
		if(structkeyexists(form, 'removeOpenId')){
			this.removeOpenIdForUser(arguments.user_id, arguments.site_id);	
		}
		if(structkeyexists(form,'openid.mode')){
			writeoutput(this.registerOpenIdWithUser(arguments.user_id, arguments.site_id));	
		}
		 db.sql="select user_id, site_id, user_openid_provider, user_openid_id, user_openid_email, user_openid_required 
		 FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_id=#db.param(arguments.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		local.qUser=db.execute("qUser");
		</cfscript>
		<cfif local.qUser.recordcount NEQ 0 and (local.qUser.user_openid_provider NEQ 0 or request.zos.globals.id EQ request.zos.globals.serverId)>
			<cfif this.isAdminChangeAllowed()>
				<cfif local.qUser.user_openid_provider>
					<p>This account is connected with a #variables.providerStruct[local.qUser.user_openid_provider]# account.  
					
					<cfscript>
					if(request.zos.globals.serverID EQ request.zos.globals.id){
						local.curURL=request.zos.currentHostName&'/z/server-manager/admin/user/editUser?sid='&arguments.user_id&'&removeOpenId=1&user_id='&arguments.user_id;
					}else if(application.zcore.user.checkGroupAccess("member") EQ false){
						local.curURL=request.zos.currentHostName&"/z/user/preference/form?removeOpenId=1";
					}else{
						local.curURL=request.zos.currentHostName&"/z/admin/member/edit?removeOpenId=1&user_id="&arguments.user_id;
					}
					</cfscript>
					<a href="#local.curURL#">Disconnect account</a>
					
					</p>
				</cfif>
			
			<p>OpenID Identity: <cfif request.zos.isdeveloper or application.zcore.user.checkGroupAccess("member")>
			
			<cfif request.zos.globals.id EQ request.zos.globals.serverId>
			<cfscript>
			form.user_openid_provider=local.qUser.user_openid_provider;
			selectStruct = StructNew();
			selectStruct.name = "user_openid_provider";
			selectStruct.hideSelect=true;
			// options for query data
			selectStruct.listLabels="None,AOL,Google,Yahoo,Open ID URL";
			selectStruct.listValues="0,4,1,2,3";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> 
			
			ID: <input name="user_openid_id" id="user_openid_id" type="text" size="30" value="#local.qUser.user_openid_id#" />
			Email: <input name="user_openid_email" id="user_openid_email" type="text" size="30" value="#local.qUser.user_openid_email#" />
			<cfelse>
			#variables.providerStruct[local.qUser.user_openid_provider]# | #local.qUser.user_openid_id# | #local.qUser.user_openid_email#
			</cfif></p>
			<p>
			<input type="checkbox" name="user_openid_required" value="1" <cfif local.qUser.user_openid_required EQ 1>checked="checked"</cfif> /> Make OpenID Login Required?
			<cfelse>#local.qUser.user_openid_id#</p></cfif>
		    
		    <cfelse>
		    <h3>Login with your OpenID Identity</h3>
		    
		    #this.displayProviderLinksForUser(local.qUser.user_id, local.qUser.site_id)#
		    </cfif>
		<cfelse>
		    <h2>Login with your OpenID Identity.</h2>
			<!--- <p>By associating one of the login service providers below with this member account, the member will be automatically logged into this web site when they are logged into the third party service.</p> --->
			<p>No external account is currently connected to this account.</p>
		    #this.displayProviderLinksForUser(arguments.user_id, arguments.site_id)#
		</cfif>
        </cfsavecontent>
        <cfreturn local.out>
    </cffunction> --->
    </cfoutput>
</cfcomponent>