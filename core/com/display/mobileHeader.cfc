<!--- Below is an example of a CFC that is used for making a custom page, search result, and search index for a site_x_option_group_set record. --->
<cfcomponent>
<cfoutput>
<!--- 
ts={
	fixedPosition:true, // true will keep header at top when scrolling down.
	alwaysShow:false, // true will enable 3 line menu button on desktop
	menuOnLeft:false, // true will put menu icon on left
	menuTopHTML:'', 
	menuBottomHTML:'',  
	logoHTML:'<div class="z-float"><a href="/"><img src="/images/logo.png" alt="#htmleditformat('')#" class="z-fluid"></a></div><a class="z-show-at-479 zPhoneLink z-mobile-header-mobile-phone-link">123-123-1234</a>',
	tabletSideHTML:'<div class="z-hide-at-479 z-mt-10 z-pr-10"><a class="zPhoneLink z-mobile-header-tablet-phone-link">123-123-1234</a></div>', // if not an empty string, the logo will be centered.
	arrLink:[{
		label:"Link",
		link:"##",
		// closed: true, // set to true if you want to allow menu to expand/collapse for this link
		arrLink:[{
			label:"Sub-link",
			link:"##"
		}]
	}]
};
request.mobileHeaderCom=createobject("component", "zcorerootmapping.com.display.mobileHeader");
request.mobileHeaderCom.init(); // call this in template init function before including other stylesheets
request.mobileHeaderCom.displayMobileMenu(ts); // run where you want it to output
 --->
<cffunction name="init" access="public" localmode="modern"> 
	<cfscript>
	if(not structkeyexists(request.zos, 'zMobileMenuDisplayed')){
		request.zos.zMobileMenuDisplayed=true; 
		application.zcore.skin.includeCSS("/z/javascript/zMobileHeader.css");
		application.zcore.skin.includeJS("/z/javascript/zMobileHeader.js");
	}
	</cfscript>
</cffunction>


<cffunction name="displayMobileMenuButton" access="public" localmode="modern">
	<cfscript>
	</cfscript>
	<div class="z-mobile-menu-icon" style="z-index:10000; position:relative;">
		<span></span>
		<span></span>
		<span></span>
	</div>
</cffunction>

<cffunction name="displayMobileMenu" access="public" localmode="modern"> 
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=arguments.ss;
	ss.fixedPosition=ss.fixedPosition?:false;
	ss.menuOnLeft=ss.menuOnLeft?:false;
	ss.tabletSideHTML=ss.tabletSideHTML?:"";
	ss.menuTopHTML=ss.menuTopHTML?:"";
	ss.menuBottomHTML=ss.menuBottomHTML?:"";
	if(not structkeyexists(ss, 'arrCustomButtonContainerIds')){
		ss.arrCustomButtonContainerIds=[];
	}
	if(not structkeyexists(ss, 'logoHTML')){
		throw("ss.logoHTML is required");
	}
	if(not structkeyexists(ss, 'tabletSideHTML')){
		throw("ss.tabletSideHTML is required");
	}
	if(not structkeyexists(ss, 'arrLink') or arraylen(ss.arrLink) EQ 0){
		throw("ss.arrLink is required with one or more links with this structure: { label:'Label', link:'##' } ");
	} 
	</cfscript>   
	
	<div class="z-mobile-header <cfif ss.menuOnLeft>z-mobile-header-left</cfif> <cfif ss.fixedPosition>z-mobile-allow-fixed</cfif> z-float">
		<div class="z-mobile-header-spacer <cfif not ss.alwaysShow>z-show-at-992</cfif>">
			<cfif ss.menuOnLeft>
				<div class="z-mobile-menu-icon">
					<span></span>
					<span></span>
					<span></span>
				</div>
				<div class="z-mobile-header-logo <cfif ss.tabletSideHTML NEQ "">z-mobile-header-logo-center</cfif>">
					#ss.logoHTML#
				</div> 
				<cfif ss.tabletSideHTML NEQ "">
					<div class="z-mobile-header-side">
						#ss.tabletSideHTML#
					</div> 
				</cfif>
			<cfelse>
				<cfif ss.tabletSideHTML NEQ "">
					<div class="z-mobile-header-side">
						#ss.tabletSideHTML#
					</div> 
				</cfif>
				<div class="z-mobile-header-logo <cfif ss.tabletSideHTML NEQ "">z-mobile-header-logo-center</cfif>">
					#ss.logoHTML#
				</div> 
				<div class="z-mobile-menu-icon">
					<span></span>
					<span></span>
					<span></span>
				</div>
			</cfif>
		</div>

		<nav class="z-mobile-menu">
			<div class="z-mobile-menu-spacer">
				<cfif ss.menuTopHTML NEQ "">
					<div class="z-mobile-menu-top">
						#ss.menuTopHTML#
					</div>
				</cfif>
				<ul>
					<cfscript>
					for(i=1;i<=arraylen(ss.arrLink);i++){
						link=ss.arrLink[i];
						echo('<li');
						if(link.closed?:false){
							echo(' class="closed"');
						}
						echo('><a href="#link.link#"');
						if(structkeyexists(link, 'target') and link.target NEQ ""){
							echo(' target="'&link.target&'"');
						}
						if(structkeyexists(link, 'onclick') and link.onclick NEQ ""){
							echo(' onclick="'&link.onclick&'"');
						}
						echo('>#link.label#</a>');
						if(structkeyexists(link, 'arrLink') and arrayLen(link.arrLink)){
							echo('<ul>');
							for(n=1;n<=arraylen(link.arrLink);n++){
								sublink=link.arrLink[n];
								echo('<li><a href="#sublink.link#"');
								if(structkeyexists(sublink, 'target') and sublink.target NEQ ""){
									echo(' target="'&sublink.target&'"');
								}
								if(structkeyexists(sublink, 'onclick') and sublink.onclick NEQ ""){
									echo(' onclick="'&sublink.onclick&'"');
								}
								echo('>#sublink.label#</a>');
								/*
								// third tier not possible with current javascript
								if(structkeyexists(sublink, 'arrLink') and arrayLen(sublink.arrLink)){
									echo('<ul>');
									for(n2=1;n2<=arraylen(sublink.arrLink);n2++){
										sublink2=sublink.arrLink[n2];
										echo('<li><a href="#sublink2.link#"');
										if(structkeyexists(sublink, 'target') and sublink2.target NEQ ""){
											echo(' target="'&sublink2.target&'"');
										}
										if(structkeyexists(sublink, 'onclick') and sublink2.onclick NEQ ""){
											echo(' onclick="'&sublink2.onclick&'"');
										}
										echo('>#sublink2.label#</a></li>');
									}
									echo('</ul>');
								}
								*/
								echo('</li>');
							}
							echo('</ul>');
						}
						echo('</li>');
					}
					</cfscript>
				</ul>
				<cfif ss.menuBottomHTML NEQ "">
					<div class="z-mobile-menu-bottom">
						#ss.menuBottomHTML#
					</div>
				</cfif>
			</div>
		</nav>
		<div class="z-mobile-header-overlay"></div>
	</div>

</cffunction> 

 
</cfoutput>
</cfcomponent>