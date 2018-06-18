<!--- Below is an example of a CFC that is used for making a custom page, search result, and search index for a site_x_option_group_set record. --->
<cfcomponent>
<cfoutput>
<!--- 
request.defaultSubpageCom=createobject("component", "zcorerootmapping.com.display.defaultSubpage");
request.defaultSubpageCom.init(); // call this in template init function before including other stylesheets 
/*
The site option group structure must be exactly this to use this code:
	Section
		Name // text field, required
		URL // url field
		Application // select, optional - Give it list labels/values of Blog|Event|Job|Listing including only what the site needs
		Section Heading // text field, required
		Image (3840x800 for 4k or 1920x400 for 1080p) // image, optional
		Mobile Image (960 x 400) // image, optional
		Sub-group: Link
			Link Text // text field, required
			URL // url field, required
			Image (3840x800 for 4k or 1920x400 for 1080p) // image, optional
			Mobile Image (960 x 400) // image, optional
*/
 
// need a get current section function that returns the current section.
currentSection=request.defaultSubpageCom.getCurrentSection(application.zcore.siteOptionCom.optionGroupStruct("Section"));
 
// pass one section to this function instead:
ts={
	defaultSectionImage:"",
	defaultSectionMobileImage:"",
	currentSection:currentSection, // required
	bodyHTML:"Body", // optional, can be empty string
	sidebarEnabled:true, // set to false to turn off sidebar for certain pages
	sidebarTopHTML:"Top", // optional, can be empty string
	sidebarBottomHTML:"Bottom" // optional, can be empty string
	/*
	sectionHeaderEnabled:true,
	afterSectionHTML:"", 
	enableContentContainer:true
	*/
}
if(currentSection.success){
	ts.sectionHeading=currentSection.group["Section Heading"]; // optional, can be empty string
	ts.sidebarHeading=currentSection.group["Name"]; // optional, can be empty string
};
request.defaultSubpageCom.displaySubpage(ts); // run where you want it to output
 --->
<cffunction name="init" access="public" localmode="modern"> 
	<cfscript>
	if(not structkeyexists(request.zos, 'zDefaultSubpageDisplayed')){
		request.zos.zDefaultSubpageDisplayed=true; 
		application.zcore.skin.includeCSS("/z/stylesheets/zDefaultSubpage.css"); 
	}
	</cfscript>
</cffunction>

<cffunction name="processGroup" access="public" localmode="modern"> 
	<cfargument name="arrGroupData" type="array" required="yes">
	<cfscript>
	ts={
		sectionCache:{
			//1: []
		}, 
		applicationCache:{
		},
		linkCache:{
			//"appId-linkId":1
			//"/full-link":1
		}
	};
	validTypes={
		"blog":true,
		"job":true,
		"event":true,
		"listing":true
	};

	// the string parsing could be cached in a future version, so we could just do a structkeyexists instead
	for(i3=1;i3<=arraylen(arguments.arrGroupData);i3++){
		currentGroup=arguments.arrGroupData[i3]; 
		arrSubGroup=application.zcore.siteOptionCom.optionGroupStruct("Link", 0, request.zos.globals.id, currentGroup); 
		arrLink=listToArray(currentGroup.url, "-");
		linkId="-1";
		ts.sectionCache[i3]={section:currentGroup, arrLink:arrSubGroup};
		if(arraylen(arrLink) GTE 3){
			linkId=arrLink[arraylen(arrLink)-1]&"-"&arrLink[arraylen(arrLink)];
			ts.linkCache[linkId]=i3;
		}
		ts.linkCache[currentGroup.url]=i3;
		if(currentGroup.application NEQ ""){
			if(not structkeyexists(validTypes, currentGroup.application)){
				throw(currentGroup.application&" is not a valid application name. Only Blog, Event, Job or Listing are currently supported for the ""Application"" field.");
			}
			ts.applicationCache[i3]=currentGroup.application;
		} 
 
		for(i2=1;i2<=arraylen(arrSubGroup);i2++){ 
			arrLink=listToArray(arrSubGroup[i2].url, "-");
			linkId="-1";
			if(arraylen(arrLink) GTE 3){
				linkId=arrLink[arraylen(arrLink)-1]&"-"&arrLink[arraylen(arrLink)];
			}
			ts.sectionCache[i3]={section:currentGroup, arrLink:arrSubGroup};
			ts.linkCache[linkId]=i3; 
			ts.linkCache[arrSubGroup[i2].url]=i3; 
		} 
	}  
	request.zos.subpageLinkCacheStruct=ts;
	</cfscript>
</cffunction>


<cffunction name="getCurrentSection" access="public" localmode="modern"> 
	<cfargument name="arrGroupData" type="array" required="yes">
	<cfscript> 
	rs={success:false};  
	if(not structkeyexists(request.zos, 'subpageLinkCacheStruct')){
		processGroup(arguments.arrGroupData);
	}


	cs=request.zos.subpageLinkCacheStruct;
	if(structkeyexists(cs.linkCache, request.zos.originalURL)){
		rs.section=cs.sectionCache[cs.linkCache[request.zos.originalURL]].section;
		rs.arrLink=cs.sectionCache[cs.linkCache[request.zos.originalURL]].arrLink;
		rs.success=true;
	}else{ 
		linkId2="-2";
		arrLink=listToArray(request.zos.originalURL, "-");
		if(arraylen(arrLink) GTE 3){
			linkId2=arrLink[arraylen(arrLink)-1]&"-"&arrLink[arraylen(arrLink)];
		}
		if(structkeyexists(cs.linkCache, linkId2)){
			rs.section=cs.sectionCache[cs.linkCache[linkId2]].section;
			rs.arrLink=cs.sectionCache[cs.linkCache[linkId2]].arrLink;
			rs.success=true;
		}else{
			for(i in cs.applicationCache){ 
				app=cs.applicationCache[i];
				if(application.zcore.app.siteHasApp(app) and application.zcore.app.getAppCFC(app)["isCurrentPageIn"&app]()){ 
					rs.section=cs.sectionCache[i].section;
					rs.arrLink=cs.sectionCache[i].arrLink;
					rs.success=true;
					break;
				}
			}
		}
	} 
	return rs; 
	</cfscript>
</cffunction>


<cffunction name="displaySubpage" access="public" localmode="modern"> 
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript> 
	
	ss=arguments.ss; 
	ts={
		defaultSectionImage:"",
		defaultSectionMobileImage:"",
		sectionHeaderEnabled:true,
		sectionHeading:"", 
		sidebarHeading:"", 
		sidebarTopHTML:"", 
		sidebarBottomHTML:"",
		bodyHTML:"",
		afterSectionHTML:"",
		sidebarEnabled:true,
		enableContentContainer:true
	};
	structappend(ss, ts, false);
	for(i in ss){
		if(isSimpleValue(ss[i])){
			ss[i]=trim(ss[i]);
		}
	} 
 
	if(not structkeyexists(ss, 'currentSection')){
		throw("ss.currentSection is required");
	}    
	arrSide=[]; 
	overrideSectionImage="";
	overrideSectionMobileImage="";
	if(structkeyexists(ss.currentSection, 'arrLink')){
		for(i=1;i<=arraylen(ss.currentSection.arrLink);i++){
			link=ss.currentSection.arrLink[i];  
			a=('<li ');
			if(link.url EQ request.zos.originalURL){ 
				a&=(' class="active" ');
				if(structkeyexists(link, 'Image') and link.image NEQ ""){
					overrideSectionImage=link.image;
				}
				if(structkeyexists(link, 'Mobile Image') and link["Mobile Image"] NEQ ""){
					overrideSectionMobileImage=link["Mobile Image"];
				}
			}
			a&=('><a  href="#link["URL"]#">#link["Link Text"]#</a></li>');
			arrayAppend(arrSide, a);
		}   
	} 
	if(not structkeyexists(ss.currentSection, 'section')){
		ss.currentSection.section={
			"Image":"",
			"Mobile Image":"",
			"Section Heading":"",
			"Name":"",
			"URL":""
		};
	}
	if(ss.sectionHeading NEQ ""){
		ss.currentSection.section["Section Heading"]=ss.sectionHeading;
	}
	section=ss.currentSection.section;
	sectionImage=ss.defaultSectionImage;
	sectionMobileImage=ss.defaultSectionMobileImage;
	if(overrideSectionImage NEQ ""){
		sectionImage=overrideSectionImage;
	}else if(section["Image"] NEQ ""){
		sectionImage=section["Image"];
	}
	if(overrideSectionMobileImage NEQ ""){
		sectionMobileImage=overrideSectionMobileImage;
	}else if(section["Mobile Image"] NEQ ""){
		sectionMobileImage=section["Mobile Image"];
	} 
	</cfscript>  
	<cfif ss.sectionHeaderEnabled>
		<div class="z-default-subpage-header z-hide-at-992" style="<cfif sectionImage NEQ "">background-image:url(#sectionImage#);</cfif>">
			<div class="z-container">
				<div class="z-default-subpage-title">#section["Section Heading"]#</div>
			</div>
		</div>  
		 <div class="z-default-subpage-header z-show-at-992" style="<cfif sectionMobileImage NEQ "">background-image:url(#sectionMobileImage#);</cfif>">
			<div class="z-container">
				<div class="z-default-subpage-title">#section["Section Heading"]#</div>
			</div>
		</div>  
	</cfif>
	<cfif ss.afterSectionHTML NEQ "">
		#ss.afterSectionHTML#
	</cfif>
	
	<cfif ss.sidebarEnabled and arraylen(arrSide) NEQ 0 or ss.sidebarTopHTML NEQ "" or ss.sidebarBottomHTML NEQ ""> 
		<div class="z-default-subpage-body-full has-sidebar">
			<div class="z-container"> 
				<div class="z-default-subpage-subpage">
					<div class="z-default-subpage-row">
						<div class="z-default-subpage-right-panel">
							<div class="z-default-subpage-subcontent">
								#ss.bodyHTML#
							</div>
						</div>
						<div class="z-default-subpage-left-panel">
							<cfif ss.sidebarHeading NEQ "">
								<div class="z-default-subpage-left-panel-heading">
									#ss.sidebarHeading#
								</div>
							</cfif>
							<cfif ss.sidebarTopHTML NEQ "">
								<div class="z-default-subpage-left-panel-top">
									#ss.sidebarTopHTML#
								</div>
							</cfif> 
							<cfif arrayLen(arrSide) NEQ 0>
								<div class="z-default-subpage-left-panel-menu">
									<ul> 
										<cfscript> 
										echo(arrayToList(arrSide, ''));
										</cfscript>  
									</ul>  
								</div>
							</cfif>
							<cfif ss.sidebarBottomHTML NEQ "">
								<div class="z-default-subpage-left-panel-bottom">
									#ss.sidebarBottomHTML#
								</div>
							</cfif> 
						</div> 
					</div>
				</div>
			</div> 
		</div>
	<cfelse>  
		<cfif ss.enableContentContainer>
			<div class="z-default-subpage-body-full">
				<div class="z-container">
					<div class="z-default-subpage-subpage float_l">
						<div class="z-default-subpage-subcontent z-default-subpage-subcontent-full"> 
							<div class="z-default-subpage-subcontent-spacer">
			</cfif>
							#ss.bodyHTML#
			<cfif ss.enableContentContainer>
						</div>
					</div>
				</div>
			</div>
		</div>
		</cfif>
	</cfif> 
</cffunction>  
</cfoutput>
</cfcomponent>