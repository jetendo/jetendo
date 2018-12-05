<cfcomponent extends="zcorerootmapping.functions.fileAndDirectory">
<cfoutput>
<cffunction name="zSetupLightBox" access="public" localmode="modern">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="className" type="string" required="no" default="">
	<cfscript>
	</cfscript>
	<cfsavecontent variable="topMeta">
		<style type="text/css">
		/* <![CDATA[ */ 
		###arguments.id# .mfp-gallery{z-index:20001;}
		###arguments.id# .mfp-bg{z-index:20000;}
		###arguments.id# .mfp-with-zoom .mfp-container,
		###arguments.id# .mfp-with-zoom.mfp-bg {
		  opacity: 0;
		  -webkit-backface-visibility: hidden;
		  /* ideally, transition speed should match zoom duration */
		  -webkit-transition: all 0.3s ease-out; 
		  -moz-transition: all 0.3s ease-out; 
		  -o-transition: all 0.3s ease-out; 
		  transition: all 0.3s ease-out;
		}

		###arguments.id# .mfp-with-zoom.mfp-ready .mfp-container {
		    opacity: 1;
		}
		###arguments.id# .mfp-with-zoom.mfp-ready.mfp-bg {
		    opacity: 0.8;
		}

		###arguments.id# .mfp-with-zoom.mfp-removing .mfp-container, 
		###arguments.id# .mfp-with-zoom.mfp-removing.mfp-bg {
		  opacity: 0;
		}

		 /* ]]> */
		</style>
		<script type="text/javascript">
		/* <![CDATA[ */ 
		zArrDeferredFunctions.push(function(){

			$('###arguments.id#').magnificPopup({
				delegate: 'a',
				type: 'image',
				tLoading: 'Loading image ##%curr%...',
				mainClass: 'mfp-no-margins mfp-with-zoom mfp-fade #arguments.className# zThumbnailLightboxPopupDiv',
				closeBtnInside: false,
				fixedContentPos: true,
				/*retina:{
					ratio:2,
					replaceSrc: function(item, ratio) {
						return item.el.attr("data-2x-image");
				      //return item.src.replace(/\.\w+$/, function(m) { return '@2x' + m; });
				    } // function that changes image source
				    
				},*/
				gallery: {
					enabled: true,
					navigateByImgClick: true,
					preload: [0,1] // Will preload 0 - before current, and 1 after the current image
				},
				image: {
					//verticalFit:false,
					tError: '<a href="%url%">The image ##%curr%</a> could not be loaded.',
					titleSrc: function(item) {
						return item.el.attr('title');
					}
				},
				zoom: {
					enabled: true, // By default it's false, so don't forget to enable it

					duration: 300, // duration of the effect, in milliseconds
					easing: 'ease-in-out', // CSS transition easing function 

					// The "opener" function should return the element from which popup will be zoomed in
					// and to which popup will be scaled down
					// By defailt it looks for an image tag:
					opener: function(openerElement) {
						// openerElement is the element on which popup was initialized, in this case its <a> tag
						// you don't need to add "opener" option if this code matches your needs, it's defailt one.
						return openerElement.is('img') ? openerElement : openerElement.find('img');
					} 
				}
			});
			(function() { 
				var magnificPopup = $.magnificPopup.instance;
 
				$('###arguments.id# a').click(function(e) {

					setTimeout(function() { 
						$(".mfp-container").swipe( {
							swipeLeft:function(event, direction, distance, duration, fingerCount) {
								console.log("swipe right");
								magnificPopup.next();
							},

							swipeRight:function(event, direction, distance, duration, fingerCount) {
								console.log("swipe left");
								magnificPopup.prev();
							}
						});
					}, 500);
				});

			}).call(this);
		}); /* ]]> */
		</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.touchSwipe.min.js");
	application.zcore.skin.includeJS("/z/javascript/Magnific-Popup/jquery.magnific-popup.min.js");
	application.zcore.skin.includeCSS("/z/javascript/Magnific-Popup/magnific-popup.css");
	application.zcore.template.appendTag("meta",topMeta);
	</cfscript>
</cffunction>
<cffunction name="zGetImageCSSCode" localmode="modern" access="public">
	<cfargument name="absolutePath" type="string" required="yes">
	<cfargument name="relativePath" type="string" required="yes">
	<cfscript>
	arrOutput=[];
	imageFileExt={ "jpeg":true, "jpg":true, "gif":true, "png":true };
	directory action="list" directory="#arguments.absolutePath#" name="qDir";
	for(row in qDir){
		fileExt=application.zcore.functions.zGetFileExt(row.name);
		if(structkeyexists(imageFileExt, fileExt)){
			s=imageinfo(row.directory&"/"&row.name);
			arrayAppend(arrOutput, '<img width="#s.width#" height="#s.height#" src="#arguments.relativePath##row.Name#" alt="#htmleditformat(application.zcore.functions.zgetfilename(row.name))#" />');
		}
	}
	for(row in qDir){
		fileExt=application.zcore.functions.zGetFileExt(row.name);
		if(structkeyexists(imageFileExt, fileExt)){
			s=imageinfo(row.directory&"/"&row.name);
			arrayAppend(arrOutput, '<div style=" width:#s.width#px; height:#s.height#px; float:left; background-image:url(#arguments.relativePath##row.Name#); background-repeat:no-repeat;"></div>');
		}
	}
	return arrayToList(arrOutput, chr(10));
	</cfscript>
</cffunction>


<!--- <cffunction name="zDisableContentTransition" localmode="modern" output="no" returntype="any">
	<cfscript>
	request.zos.tempObj.zDisableContentTransition=true;
	</cfscript>
</cffunction>
 --->

<!--- 
inputstruct=structnew();
inputstruct.arrIgnoreURLs=arraynew(1);
// arrayappend(inputstruct.arrIgnoreURLs,"/");
inputstruct.arrIgnoreURLContains=arraynew(1);
//arrayappend(inputstruct.arrIgnoreURLContains,"partial-url");
application.zcore.functions.zEnableContentTransition(inputstruct);
or
application.zcore.functions.zEnableContentTransition(); --->
<cffunction name="zEnableContentTransition" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	request.zos.enableContentTransitionStruct=arguments.ss;
	</cfscript>
</cffunction>

	
<cffunction name="zProcessContentTransition" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	return;
	/*
	
	skipUrl=structnew(); 


	if(request.zos.cgi.http_user_agent CONTAINS "MSIE 7.0" or request.zos.cgi.http_user_agent CONTAINS "MSIE 8.0" or request.zos.cgi.http_user_agent CONTAINS "MSIE 9.0" or request.zos.cgi.http_user_agent CONTAINS "MSIE 6.0"){
		return;	
	}
	if(structkeyexists(request.zos.globals,'enableInstantLoad') and request.zos.globals.enableInstantLoad EQ 0){
		return;	
	}
	if(request.zos.inMemberArea){
		return;	
	}
	if(structkeyexists(arguments.ss, 'allowHomePage') EQ false or arguments.ss.allowHomePage EQ false){
		skipUrl["/index.cfm"]=true;
		skipUrl["/content/index.cfm"]=true;
	}
	skipUrl["/z/listing/search-js/index"]=true; 
	if(structkeyexists(skipUrl, request.cgi_script_name)){
		return;	
	}
	metaAppend="";
	if(structKeyExists(request.zos.tempObj, 'zEnableContentTransitionLoaded')){
		return;
	}
	if(application.zcore.app.siteHasApp("listing")){
		application.zcore.functions.zRequireGoogleMaps();
	}
	request.zos.tempObj.zEnableContentTransitionLoaded=true;
    application.zcore.functions.zRequireJquery();
	 
	if(structkeyexists(arguments.ss, 'arrIgnoreURLs')){
		for(i=1;i LTE arraylen(arguments.ss.arrIgnoreURLs);i++){
			metaAppend&='zContentTransition.arrIgnoreURLs.push("'&arguments.ss.arrIgnoreURLs[i]&'");';
		}
	}
	if(structkeyexists(arguments.ss, 'arrIgnoreURLContains')){
		for(i=1;i LTE arraylen(arguments.ss.arrIgnoreURLContains);i++){
			if(arguments.ss.arrIgnoreURLContains[i] EQ "/z/misc/system/redirect"){
				arguments.ss.arrIgnoreURLContains[i]="/z/misc/system/ext";
			}
			metaAppend&='zContentTransition.arrIgnoreURLContains.push("'&arguments.ss.arrIgnoreURLContains[i]&'");';
		}
	} 
    application.zcore.template.prependTag("pagenav",'<span id="zContentTransitionPageNavSpan">', true);
    application.zcore.template.appendTag("pagenav",'</span>');
    application.zcore.template.prependTag("pagetitle",'<span id="zContentTransitionTitleSpan">', true);
    application.zcore.template.appendTag("pagetitle",'</span>');
    application.zcore.template.prependTag("content",'<div id="zContentTransitionContentDiv">', true);
    application.zcore.template.appendTag("content",'</div>');
    </cfscript>
    <cfsavecontent variable="scriptHTML">
            
	    <cfif cgi.HTTP_USER_AGENT CONTAINS "MSIE 7.0" or cgi.HTTP_USER_AGENT CONTAINS "MSIE 8.0" or cgi.HTTP_USER_AGENT CONTAINS "MSIE 9.0" or cgi.HTTP_USER_AGENT CONTAINS "MSIE 6.0"> 
	    <cfelse>
	    #application.zcore.skin.includeJS("/z/javascript/jquery/balupton-history/scripts/bundled/html5/jquery.history.js", "", 2)#
	    </cfif>
    <script type="text/javascript"> 
    var zContentTransitionEnabled=true;
    var zLocalDomains=["#request.zos.globals.domain#","#replace(request.zos.globals.domain,"www.","")#"<cfif request.zos.globals.securedomain NEQ "">,"#request.zos.globals.securedomain#","#replace(request.zos.globals.securedomain,"www.","")#"</cfif><cfscript>
    if(request.zos.globals.domainAliases NEQ ""){
    	if(not structkeyexists(request.zos, 'arrDomainAliases')){
	    	request.zos.arrDomainAliases=listtoarray(request.zos.globals.domainaliases,",");
	    }
        for(i=1;i LTE arraylen(request.zos.arrDomainAliases);i++){
            writeoutput(', "http://'&request.zos.arrDomainAliases[i]&'"');	
        }
    }
    </cfscript>];
	zArrDeferredFunctions.push(function(){#metaAppend# zContentTransition.checkLoad(); }); 
    </script>
    </cfsavecontent>
    <cfscript>
	application.zcore.template.appendTag("scripts",scriptHTML);
	*/
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGetLinkClasses(); --->
<cffunction name="zGetLinkClasses" localmode="modern" output="no" returntype="any">
	<cfscript>
	if(structKeyExists(request.zos.tempObj, 'zEnableContentTransitionLoaded')){
		return "zContentTransition ";	
	}else{
		return "";
	}
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zEmbedSlideShow(slideshow_id); --->
<cffunction name="zEmbedSlideShow" localmode="modern" output="yes" returntype="any">
    <cfargument name="slideshow_id" type="any" required="yes">
	<cfscript>
	var qs="";
	
	var db=request.zos.queryObject;
	</cfscript>
    <cfsavecontent variable="db.sql">
    select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	WHERE slideshow_id = #db.param(arguments.slideshow_id)# and 
	slideshow_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qS=db.execute("qS");</cfscript>
    <cfif qS.recordcount NEQ 0>
    <iframe class="zEmbeddedSlideshow" src="#request.zos.currentHostName#/z/misc/slideshow/embed?action=slideshow&amp;slideshow_id=#arguments.slideshow_id#" width="#qs.slideshow_width#" height="#qs.slideshow_height#" style="margin:0 auto; border:none; overflow:auto;" seamless="seamless"></iframe>
    </cfif>
</cffunction>

<!--- 

ts=structnew();
ts.slideshow_codename="";
// or
ts.slideshow_id="";
zSlideShow(ts);
 --->
<cffunction name="zSlideShow" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	
	var g="";
	var rs=0;
	var db=request.zos.queryObject;
	var theBigSlideshowOutput="";
	var t9=0;
	var slideshowCom=0;
	var theSlideshowResultHTML=0;
	var theBigSlideshowOutput=0;
	var backupaction=0;
	var td22=dateformat(now(),'yyyymmdd');
	var ts=structnew();
	ts.site_id = request.zos.globals.id;
	var i=0;
	structappend(arguments.ss,ts,false); 

	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.cycle2.js");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.cycle2.swipe.min.js", '', 2);
	application.zcore.skin.includeJS("/z/javascript/jquery/Slides/source/slides.jquery-new.js");
	// application.zcore.functions.zRequireSlideshowJS();
	// if(structkeyexists(application.sitestruct, arguments.ss.site_id)){
	// 	if(structkeyexists(arguments.ss,'slideshow_codename')){
	// 		if(structkeyexists(application.sitestruct[arguments.ss.site_id].slideshowNameCacheStruct, arguments.ss.slideshow_codename)){
	// 			t9=application.sitestruct[arguments.ss.site_id].slideshowIdCacheStruct[application.sitestruct[arguments.ss.site_id].slideshowNameCacheStruct[arguments.ss.slideshow_codename]];
	// 			if(t9.lastUpdated EQ td22){
	// 				echo(t9.javascriptOutput);
	// 				if(structkeyexists(t9,'zMLSSearchOptionsDisplaySearchId')){
	// 					request.zMLSSearchOptionsDisplaySearchId=t9.zMLSSearchOptionsDisplaySearchId;
	// 				}
	// 				writeoutput(t9.output);
	// 				return t9;
	// 			}
	// 		}
	// 	}else if(structkeyexists(arguments.ss,'slideshow_id')){
	// 		if(structkeyexists(application.sitestruct[arguments.ss.site_id].slideshowIdCacheStruct, arguments.ss.slideshow_id)){
	// 			t9=application.sitestruct[arguments.ss.site_id].slideshowIdCacheStruct[arguments.ss.slideshow_id];
	// 			if(t9.lastUpdated EQ td22){
	// 				echo(t9.javascriptOutput);
	// 				if(structkeyexists(t9,'zMLSSearchOptionsDisplaySearchId')){
	// 					request.zMLSSearchOptionsDisplaySearchId=t9.zMLSSearchOptionsDisplaySearchId;
	// 				}
	// 				writeoutput(t9.output);
	// 				return  t9;
	// 			}
	// 		}
	// 	}
	// }
	if(structkeyexists(arguments.ss,'slideshow_codename')){
		db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
		WHERE slideshow_codename=#db.param(arguments.ss.slideshow_codename)# and 
		slideshow_deleted = #db.param(0)# and
		site_id =#db.param(arguments.ss.site_id)# ";
		qss=db.execute("qss", "", 10000, "query", false);
		if(qss.recordcount EQ 0){
			writeoutput('<p>Slideshow, "#arguments.ss.slideshow_codename#", is missing</p>');
			return {flashout:{tablinks:"",tabcaptions:""}};
		}
		arguments.ss.width=qss.slideshow_width;
		arguments.ss.height=qss.slideshow_height;
		arguments.ss.dataurl="/z/misc/slideshow/index?action=json&slideshow_id=#URLEncodedFormat(qss.slideshow_id)#";

	}else if(structkeyexists(arguments.ss,'slideshow_id')){
		db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
		WHERE slideshow_id=#db.param(arguments.ss.slideshow_id)# and 
		slideshow_deleted = #db.param(0)# and
		site_id =#db.param(arguments.ss.site_id)# ";
		qss=db.execute("qss", "", 10000, "query", false);
		if(qss.recordcount EQ 0){
			return {flashout:{tablinks:"",tabcaptions:""}};
		}
		arguments.ss.width=qss.slideshow_width;
		arguments.ss.height=qss.slideshow_height;
		arguments.ss.dataurl="/z/misc/slideshow/index?action=json&slideshow_id=#URLEncodedFormat(arguments.ss.slideshow_id)#";
	}else if(structkeyexists(arguments.ss,'dataurl') EQ false){
		application.zcore.template.fail("arguments.ss.dataurl or arguments.ss.slideshow_id is required");
	}else{
		if(structkeyexists(arguments.ss,'width') EQ false){
			application.zcore.template.fail("arguments.ss.width is required");
		}
		if(structkeyexists(arguments.ss,'height') EQ false){
			application.zcore.template.fail("arguments.ss.height is required");
		}
	}
	request.zos.tempObj.zSlideShowUniqueIdIndex=qss.slideshow_id;
	form.uniqueIdIndex=request.zos.tempobj.zSlideShowUniqueIdIndex;// or 1 EQ 1
	form.slideshow_id=qss.slideshow_id;
	useNewFormat=true;
	slideshowConfig={ arrTab:[] };
	slideshowCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.slideshow");
	savecontent variable="theBigSlideshowOutput"{
		if(useNewFormat or qss.slideshow_format EQ 1){
			backupaction=application.zcore.functions.zso(form, 'action');
			form.action="json";
			form.slideshow_id=qss.slideshow_id;
			savecontent variable="theSlideshowResultHTML"{
				rs=slideshowCom.getData(arguments.ss);
				structappend(local, rs, true);
			}
			if(qss.slideshow_format EQ 1 and qss.slideshow_custom_include NEQ ""){
				echo(theSlideshowResultHTML);
			}
			form.action=backupaction;
		}else{
			application.zcore.template.fail("Flash slideshow was permanently disabled");
		}
		if(useNewFormat and structkeyexists(local, 'qss') and qss.slideshow_custom_include EQ ""){
		
			g="";
			for(i in slideshowConfig){
				if(isSimpleValue(slideshowConfig[i])){
					g&=slideshowConfig[i];	
				}
			}
			g&=qss.slideshow_updated_datetime;
			g=hash(g);
		}
		if(structkeyexists(slideshowConfig, 'slideContainer') and (qss.slideshow_hash NEQ g or structkeyexists(form,'resetSlideshowCSS') or request.zos.zreset EQ "site")){
			ts={
				slideshowHash:g,
				site_id:arguments.ss.site_id,
				index:request.zos.tempobj.zSlideShowUniqueIdIndex,
				qss:qss,
				slideshowConfig:slideshowConfig
			};
			slideshowCom.updateSlideshowCSS(ts);
		}
		if(qss.slideshow_custom_include EQ ""){
			echo('<script type="text/javascript">/* <![CDATA[ */
			zArrDeferredFunctions.push(function(){
				zArrSlideshowIds.push({rotateGroupIndex:0,rotateIndex:0,id:#request.zos.tempObj.zSlideShowUniqueIdIndex#, layout:#qss.slideshow_large_image#, slideDirection:"#qss.slideshow_slide_direction#", slideDelay:#qss.slideshow_auto_slide_delay#, movedTileCount:#qss.slideshow_moved_tile_count#});
			});
			/* ]]> */</script> ');
			if(qss.slideshow_large_image EQ 0){
				echo('<div id="zUniqueSlideshowContainerId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
				if(qss.slideshow_slide_direction EQ "y" and arraylen(slideshowConfig.arrTab) GT 1){
					echo('<div id="zslideshowhomeslidenav#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
					for(i=1;i LTE arraylen(slideshowConfig.arrTab);i++){
						echo('<a href="##" onclick="zUpdateListingSlides(#request.zos.tempobj.zSlideShowUniqueIdIndex#, ''#htmleditformat(slideshowConfig.arrTab[i])#''); return false;" class="zslideshowtablink#request.zos.tempobj.zSlideShowUniqueIdIndex#">#slideshowConfig.arrTabCaptions[i]#</a>');
					}
				}
				echo('</div>');
				echo('<div id="zUniqueSlideshowLargeId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
				for(slideIndex=1;slideIndex LTE arrayLen(arrImages);slideIndex++){
					slideshowCom.getPhoto(local);
				}
				echo('</div>');
				echo('<div id="zUniqueSlideshowId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
				if(qss.slideshow_slide_direction EQ "x" and arraylen(slideshowConfig.arrTab) GT 1){
					echo('<div id="zslideshowhomeslidenav#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
					for(i=1;i LTE arraylen(slideshowConfig.arrTab);i++){
						echo('<a href="##" onclick="zUpdateListingSlides(#request.zos.tempobj.zSlideShowUniqueIdIndex#, ''#htmleditformat(slideshowConfig.arrTab[i])#''); return false;" class="zslideshowtablink#request.zos.tempobj.zSlideShowUniqueIdIndex#">#slideshowConfig.arrTabCaptions[i]#</a>');
					}
					echo('</div>');
				}
				echo('
				<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-2">
					<div class="zlistingslidernavlinks#request.zos.tempobj.zSlideShowUniqueIdIndex#"><a href="##" class="zlistingsliderprev#request.zos.tempobj.zSlideShowUniqueIdIndex#"><span class="zlistingsliderprevimg#request.zos.tempobj.zSlideShowUniqueIdIndex#">&nbsp;</span></a></div>
					<div id="zslideshowslides#request.zos.tempobj.zSlideShowUniqueIdIndex#">
						<div class="zslideshowslides_container#request.zos.tempobj.zSlideShowUniqueIdIndex#">
							<div class="zslideshowslide#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
							if(qss.slideshow_tab_type_id EQ 2){
								for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
									slideshowCom.getListing(local);
								}
							}else{
								for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
									slideshowCom.getImage(local);
								}
							}
							echo('
							</div>
						</div>
					</div>
					<div class="zlistingslidernavlinks#request.zos.tempobj.zSlideShowUniqueIdIndex#"><a href="##" class="zlistingslidernext#request.zos.tempobj.zSlideShowUniqueIdIndex#"><span class="zlistingslidernextimg#request.zos.tempobj.zSlideShowUniqueIdIndex#">&nbsp;</span></a></div>
					</div>
					</div>
				</div>');
			}else if(qss.slideshow_large_image EQ 1){
				echo('
				<div id="zUniqueSlideshowContainerId#request.zos.tempobj.zSlideShowUniqueIdIndex#">
					<div id="zUniqueSlideshowId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
						if(arraylen(slideshowConfig.arrTab) GT 1 ){
							echo('<div id="zslideshowhomeslidenav#request.zos.tempobj.zSlideShowUniqueIdIndex#"> ');
							for(i=1;i LTE arraylen(slideshowConfig.arrTab);i++){
								echo('<a href="##" onclick="zUpdateListingSlides(#request.zos.tempobj.zSlideShowUniqueIdIndex#, ''#htmleditformat(slideshowConfig.arrTab[i])#''); return false;" class="zslideshowtablink#request.zos.tempobj.zSlideShowUniqueIdIndex#">#slideshowConfig.arrTabCaptions[i]#</a>');
							}
							echo('</div>');
						}
						echo('<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-2">
							<a href="##" class="zlistingsliderprev#request.zos.tempobj.zSlideShowUniqueIdIndex#"><span class="zlistingsliderprevimg#request.zos.tempobj.zSlideShowUniqueIdIndex#">&nbsp;</span></a>
							<div id="zslideshowslides#request.zos.tempobj.zSlideShowUniqueIdIndex#">
								<div class="zslideshowslides_container#request.zos.tempobj.zSlideShowUniqueIdIndex#">
									<div class="zslideshowslide#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
										if(qss.slideshow_tab_type_id EQ 2){
											for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
												slideshowCom.getListing(local);
											}
										}else{
											for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
												slideshowCom.getImage(local);
											}
										}
									echo('
									</div>
								</div>
							</div>
							<a href="##" class="zlistingslidernext#request.zos.tempobj.zSlideShowUniqueIdIndex#"><span class="zlistingslidernextimg#request.zos.tempobj.zSlideShowUniqueIdIndex#">&nbsp;</span></a>
						</div>
					</div>
				</div>');
			}else if(qss.slideshow_large_image EQ 2){
				echo('<div id="zUniqueSlideshowContainerId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
				if(arraylen(slideshowConfig.arrTab) GT 1){
					echo('<div id="zslideshowhomeslidenav#request.zos.tempobj.zSlideShowUniqueIdIndex#"> ');
					for(i=1;i LTE arraylen(slideshowConfig.arrTab);i++){
						echo('<a href="##" onclick="zUpdateListingSlides(#request.zos.tempobj.zSlideShowUniqueIdIndex#, ''#htmleditformat(slideshowConfig.arrTab[i])#''); return false;" class="zslideshowtablink#request.zos.tempobj.zSlideShowUniqueIdIndex#">#slideshowConfig.arrTabCaptions[i]#</a>');
					}
					echo('</div>');
				}
				echo('<div id="zUniqueSlideshowLargeId#request.zos.tempobj.zSlideShowUniqueIdIndex#">');
				for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
					slideshowCom.getPhoto(local);
				}
				echo('</div>
				</div>');writedump(qss);abort;
			}
		}
	}
	rsBackup=rs;
	rs=structnew();
	rs.output=application.zcore.functions.zRemoveHostName(theBigSlideshowOutput);
	rs.javascriptoutput="";
	rs.lastUpdated=td22;
	rs.codename=qss.slideshow_codename;
	if(structkeyexists(request,'zMLSSearchOptionsDisplaySearchId')){
		rs.zMLSSearchOptionsDisplaySearchId=request.zMLSSearchOptionsDisplaySearchId;
	}
	
	rs.flashout=rsBackup.flashout;
	application.sitestruct[arguments.ss.site_id].slideshowNameCacheStruct[qss.slideshow_codename]=qss.slideshow_id;
	application.sitestruct[arguments.ss.site_id].slideshowIdCacheStruct[qss.slideshow_id]=rs;
	
	writeoutput(rs.output);
	if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
		echo(theSlideshowResultHTML);
	}
	return rs;
	</cfscript>
</cffunction>


<cffunction name="zSlideshowClearCache" localmode="modern" returntype="any" output="no">
	<cfargument name="nameOrId" type="string" required="yes">
	<cfscript>
	if(arguments.nameOrId EQ 0){
		application.sitestruct[request.zos.globals.id].slideshowIdCacheStruct=structnew();
		application.sitestruct[request.zos.globals.id].slideshowNameCacheStruct=structnew();
	}else{
		if(structkeyexists(application.sitestruct[request.zos.globals.id].slideshowIdCacheStruct, arguments.nameOrId)){			
			structdelete(application.sitestruct[request.zos.globals.id].slideshowNameCacheStruct, application.sitestruct[request.zos.globals.id].slideshowIdCacheStruct[arguments.nameOrId].codename);
			structdelete(application.sitestruct[request.zos.globals.id].slideshowIdCacheStruct, arguments.nameOrId);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="zRequireSlideshowJS" localmode="modern" output="no" returntype="any">
	<cfscript>
	var theJS="";
	</cfscript>
	<cfif structkeyexists(request,'zRequiredSlideshowJSCalled') EQ false> 
		<cfscript>
		request.zRequiredSlideshowJSCalled=true;
		application.zcore.functions.zRequireJquery();
		if(request.zos.globals.enableMinCat EQ 0 or structkeyexists(request.zos.tempObj,'disableMinCat')){
			application.zcore.skin.includeJS("/z/javascript/jquery/jquery.cycle.all.js");
			application.zcore.skin.includeJS("/z/javascript/jquery/Slides/source/slides.jquery-new.js");
		} 
		</cfscript>
	</cfif>
</cffunction>

<!--- 
ts=StructNew();
ts.dataURL=""; // if not blank, then its used instead of the other variables.
ts.x_direction='asc';
ts.y_direction='asc';
ts.x_label='';
ts.y_label='';
ts.arrYLabels=ArrayNew(1);
ts.arrXLabels=ArrayNew(1);
ts.arrYValues=ArrayNew(1);
ts.arrXValues=ArrayNew(1);
ArrayAppend(ts.arrYLabels,);
ArrayAppend(ts.arrYValues,);
ArrayAppend(ts.arrXLabels,);
ArrayAppend(ts.arrXValues,);
ts.arrLines=ArrayNew(1);
t2=StructNew();
t2.label='Google';
t2.arrX=ArrayNew(1);
ArrayAppend(t2.arrX,);
t2.arrY=ArrayNew(1);
ArrayAppend(t2.arrY,);
ArrayAppend(ts.arrLines,t2);
zChart(ts);
 ---->
<cffunction name="zChart" localmode="modern" output="true">
	<cfargument type="struct" name="ss" required="yes">
	<cfscript>
	var i=0;
	var arrLineQS="";
	var ts=StructNew();
	var chart="";
	var qs="";
	var js="";
	var v="";
	ts.width=400;
	ts.height=300;
	ts.legendHeight=50;
	ts.x_direction='asc';
	ts.debug=false;
	ts.y_direction='asc';
	ts.complete=true;
	ts.dataURL="";
	
	ts.arrLines=ArrayNew(1);
	StructAppend(ss,ts,false);
	arrLineQS=ArrayNew(1);
	for(i=1;i LTE ArrayLen(ss.arrLines);i=i+1){
		ArrayAppend(arrLineQS,'line#i#_label='&URLEncodedFormat(ss.arrLines[i].label)&'&line#i#_x='&URLEncodedFormat(arrayToList(ss.arrLines[i].arrX))&'&line#i#_y='&URLEncodedFormat(arrayToList(ss.arrLines[i].arrY)));
	}
	if(isDefined('request.zos.zChartDataId') EQ false){
		request.zos.zChartDataId=0;
		//output the header
		writeoutput('<script type="text/javascript" src="#request.zos.globals.serverDomain#/scripts/flash.js"></script>');
		writeoutput('<script type="text/javascript">/* <![CDATA[ */
		zArrChartData=new Array();function zChartGetData(id){var c=document.getElementById("zchart"+id);if(typeof(c)=="object"){c.setData(zArrChartData[id]);}}/* ]]> */</script>');
	}else{
		request.zos.zChartDataId=request.zos.zChartDataId+1;
	}
	qs='dataId=#request.zos.zChartDataId#&chartWidth=#ss.width#&chartHeight=#ss.height#&chartLegendHeight=#ss.legendHeight#';
	v="y_labels=#URLEncodedFormat(arraytolist(ss.arrYLabels))#&y_values=#URLEncodedFormat(arraytolist(ss.arrYValues))#&x_values=#URLEncodedFormat(arraytolist(ss.arrXValues))#&x_labels=#URLEncodedFormat(arraytolist(ss.arrXLabels))#&x_label=#URLEncodedFormat(ss.x_label)#&y_label=#URLEncodedFormat(ss.y_label)#&x_direction=#ss.x_direction#&y_direction=#ss.y_direction#&#arrayToList(arrLineQS,'&')#&chartWidth=#ss.width#&chartHeight=#ss.height#&chartLegendHeight=#ss.legendHeight#&complete=#ss.complete#";
	js='<script type="text/javascript">/* <![CDATA[ */zArrChartData[#request.zos.zChartDataId#]="'&JSStringFormat(v)&'";/* ]]> */</script>';
	chart=js&'<script type="text/javascript">zswf(''<object zSWF="off" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab##version=8,0,0,0" width="#ss.width#" height="#ss.height#" id="zchart#request.zos.zChartDataId#"><param name="allowScriptAccess" value="sameDomain" /><param name="movie" value="#request.zos.globals.serverdomain#/images/chart.swf?#qs#" /><param name="quality" value="high" /><param name="bgcolor" value="##ffffff" /><embed src="#request.zos.globals.serverdomain#/images/chart.swf?#qs#" quality="high" bgcolor="##ffffff" width="#ss.width#" height="#ss.height#" name="zchart#request.zos.zChartDataId#" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" /><\/object>'');</script>';
	writeoutput(chart);
	if(ss.debug){
		writeoutput("<br />"&replace(urldecode(qs),"&","<br />","ALL"));
	}
	</cfscript>
</cffunction>	


<!--- 
<cfscript>
// create input structure
inputStruct = StructNew();
// required
inputStruct.currentRow = currentRow;
inputStruct.style = "table-white";
inputStruct.style2 = "table-bright";
inputStruct.styleOver = "table-error";
// optional
if(this row is selected){
	inputStruct.selected = true; // set 
}
inputStruct.isChildMenu = false;
inputStruct.rollOverMessage = "Custom Message";
inputStruct.rollOverMessageStyle = "table-highlight";
inputStruct.rollOverMessageXOffset = 20;
inputStruct.rollOverMessageYOffset = 35;
inputStruct.rollOverMessagePadding = 5;
inputStruct.rollOverMessageWidth = 200;
inputStruct.styleSelected = "table-selected";
inputStruct.output = false;
inputStruct.name = "row1"; // must follow variable naming conventions
// run function
rollOverCode = zStyleRollOver(inputStruct);
</cfscript>
 --->
<cffunction name="zStyleRollOver" localmode="modern" returntype="any" output="true">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	var js = "";
	var out="";
	var ss="";
	var iStruct="";
	var tempStruct = StructNew();
	tempStruct.name = "";
	tempStruct.output = true;
	tempStruct.selected = false;
	tempStruct.isChildMenu = false;
	tempStruct.returnStruct = false;
	tempStruct.rollOverMessageXOffset = 20;
	tempStruct.rollOverMessageYOffset = 35;
	tempStruct.rollOverMessagePadding = 5;
	tempStruct.rollOverMessageWidth = 200;
	StructAppend(arguments.inputStruct, tempStruct, false);
	ss = arguments.inputStruct; // less typing
	application.zcore.functions.zGetSharedRollOverJS();
	</cfscript>
	<cfsilent>
	<cfif isDefined('ss.currentRow') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zStyleRollOver: inputStruct.currentRow is required">
	</cfif>
	<cfif isDefined('ss.style') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zStyleRollOver: inputStruct.style is required">
	</cfif>
	<cfif isDefined('ss.style2') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zStyleRollOver: inputStruct.style2 is required">
	</cfif>
	<cfif isDefined('ss.styleOver') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zStyleRollOver: inputStruct.styleOver is required">
	</cfif>
	<cfif ss.selected and isDefined('ss.styleSelected') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zStyleRollOver: inputStruct.styleSelected is required when ss.selected equals true.">
	</cfif>
	<cfif isDefined('Request.zStyleROInit#ss.name#') EQ false>
		<cfscript>
		StructInsert(request, "zStyleROInit#ss.name#", true, true);
		</cfscript>
		<cfsavecontent variable="js">
		<script type="text/javascript">
		/* <![CDATA[ */
		var zRollOverTimer=false;
		var zStyleRO#ss.name#style=false;
		var zStyleRO#ss.name#index = false;
		var zStyleRO#ss.name#tr = false;
		var zStyleRO#ss.name#outx=0;
		var zStyleRO#ss.name#outy=0; 
		var zStyleRODistanceFlag#ss.name# = false;
		function zStyleRollOver#ss.name#(tr,index){
			if(tr.className != undefined){
				tr.className = "#ss.styleOver#";
				var arrLinks = document.getElementsByName("zStyleROLink#ss.name#"+index);
				for(var i=0;i<arrLinks.length;i++){
					arrLinks.item(i).className = "#ss.styleOver#";
				}
				zStyleRO#ss.name#outx = event.clientX + zScrollLeft;
				zStyleRO#ss.name#outy = event.clientY + zScrollTop;
			}
		}
		function zStyleRollOut#ss.name#(tr, originalStyle, index,isChildMenu){
			if(tr.className != undefined){
			/*if(zROMessageForceHold==true && isChildMenu != true){
				var tempObj = new Object();
				tempObj.func = zStyleRollOut#ss.name#;
				tempObj.tr = tr;
				tempObj.originalStyle = originalStyle;
				tempObj.index = index;
				tempObj.groupName = groupName;
				arrStyleRollOutHolding.push(tempObj);
				return true;
			}*/
				var arrLinks = document.getElementsByName("zStyleROLink#ss.name#"+index);
				if(originalStyle != undefined){
					<cfif isDefined('ss.styleSelected')>if(originalStyle == 2){
						tr.className = "#ss.styleSelected#";
						for(var i=0;i<arrLinks.length;i++){
							arrLinks.item(i).className = "#ss.styleSelected#";
						}
					}else </cfif>if(originalStyle == 1){
						tr.className = "#ss.style#";
						for(var i=0;i<arrLinks.length;i++){
							arrLinks.item(i).className = "#ss.style#";
						}
					}else{
						tr.className = "#ss.style2#";
						for(var i=0;i<arrLinks.length;i++){
							arrLinks.item(i).className = "#ss.style2#";
						}
					}
				}
			}
		}
		/* ]]> */
		</script>
		</cfsavecontent>
		<cfscript>
		application.zcore.template.prependContent(js);
		</cfscript>
	</cfif>
	<cfif isDefined('ss.rollOverMessage') and isDefined('ss.rollOverMessageStyle')>
		<cfscript>
		iStruct = StructNew();
		iStruct.message = ss.rollOverMessage;
		iStruct.style = ss.rollOverMessageStyle;
		iStruct.xOffset = ss.rollOverMessageXOffset;
		iStruct.yOffset = ss.rollOverMessageYOffset;
		iStruct.padding = ss.rollOverMessagePadding;
		iStruct.width = ss.rollOverMessageWidth;
		iStruct.output = false;
		iStruct.returnStruct = true;
		roMessageStruct = zRollOverMessage(iStruct);		
		</cfscript>
		<cfsavecontent variable="out">onMouseMove="#roMessageStruct.onMouseMove#" onMouseOver="zStyleRollOver#ss.name#(this, #ss.currentRow#);#roMessageStruct.onMouseOver#" onMouseOut="zStyleRollOut#ss.name#(this, <cfif ss.selected>2<cfelseif ss.currentRow MOD 2 EQ 0>1<cfelse>0</cfif>, #ss.currentRow#, #ss.isChildMenu#);#roMessageStruct.onMouseOut#" class="<cfif ss.selected>#ss.styleSelected#<cfelseif ss.currentRow MOD 2 EQ 0>#ss.style#<cfelse>#ss.style2#</cfif>" id="zStyleROLink#ss.name##ss.currentRow#" </cfsavecontent>
	<cfelse>
		<cfsavecontent variable="out"> onMouseOver="zStyleRollOver#ss.name#(this, #ss.currentRow#);" onMouseOut="zStyleRollOut#ss.name#(this, <cfif ss.selected>2<cfelseif ss.currentRow MOD 2 EQ 0>1<cfelse>0</cfif>, #ss.currentRow#, #ss.isChildMenu#);" class="<cfif ss.selected>#ss.styleSelected#<cfelseif ss.currentRow MOD 2 EQ 0>#ss.style#<cfelse>#ss.style2#</cfif>" id="zStyleROLink#ss.name##ss.currentRow#"  </cfsavecontent> 
	</cfif>
	</cfsilent>
	<cfscript>
	if(ss.output){
		writeoutput(out);
	}else{
		return out;
	}
	</cfscript>
</cffunction>

















<cffunction name="zGetSharedRollOverJS" localmode="modern" returntype="any" output="false">
<Cfscript>
var js="";
if(isDefined('Request.zSharedJSInit') EQ false){
	Request.zSharedJSInit = true;
}else{
	return true;
}
</Cfscript>
<cfsavecontent variable="js">
<script type="text/javascript">
/* <![CDATA[ */
var zStyleROGroupName = "";
var arrStyleRollOutHolding = new Array();
var zScrollLeft=document.body.scrollLeft;
var zScrollTop=document.body.scrollTop;
var zROCheckDistance=false;
var zROMessageForceHold=false;
var IE = document.all?true:false;
if (!IE) document.captureEvents(Event.MOUSEMOVE)
document.onmousemove = getMouseXY;
var tempX = 0;
var tempY = 0;
document.onscroll = getScrollPosition;
function getScrollPosition(){
	zScrollLeft=document.body.scrollLeft;
	zScrollTop=document.body.scrollTop;
}
function zGetRollOverXPosition (img) { 
	var x = 0;
	if (!document.layers) {
		var onWindows = navigator.platform ? navigator.platform == "Win32" : false;
		var macIE45 = document.all && !onWindows && getExplorerVersion() == 4.5;
		var par = img;
		var lastOffset = 0;
		while(par){
			if( par.leftMargin && ! onWindows ) x += parseInt(par.leftMargin);
			if( (par.offsetLeft != lastOffset) && par.offsetLeft ) x += parseInt(par.offsetLeft);
			if( par.offsetLeft != 0 ) lastOffset = par.offsetLeft;
			par = macIE45 ? par.parentElement : par.offsetParent;
		}
	} else if (img.x) x += img.x;
	return x;
}
function getExplorerVersion() {
	var ieVers = parseFloat(navigator.appVersion);
	if( navigator.appName != 'Microsoft Internet Explorer' ) return ieVers;
	var tempVers = navigator.appVersion;
	var i = tempVers.indexOf( 'MSIE ' );
	if( i >= 0 ) {
		tempVers = tempVers.substring( i+5 );
		ieVers = parseFloat( tempVers ); 
	}
	return ieVers;
}

function zGetRollOverYPosition (img) {
	var y = 0;
	if(!document.layers) {
		var onWindows = navigator.platform ? navigator.platform == "Win32" : false;
		var macIE45 = document.all && !onWindows && getExplorerVersion() == 4.5;
		var par = img;
		var lastOffset = 0;
		while(par){
			if( par.topMargin && !onWindows ) y += parseInt(par.topMargin);
			if( (par.offsetTop != lastOffset) && par.offsetTop ) y += parseInt(par.offsetTop);
			if( par.offsetTop != 0 ) lastOffset = par.offsetTop;
			par = macIE45 ? par.parentElement : par.offsetParent;
		}		
	} else if (img.y >= 0) y += img.y;
	return y;
}
function getMouseXY(e){
	if(IE){ // grab the x-y pos.s if browser is IE
		tempX = event.clientX + zScrollLeft;
		tempY = event.clientY + zScrollTop;
	}else{
		tempX = e.pageX;
		tempY = e.pageY;
	}  
	if (tempX < 0){tempX = 0;}
	if (tempY < 0){tempY = 0;}  
	if(zROMessageForceHold==false && zROCheckDistance==true){
		if(Math.abs(zShowRollOverMessageoutx - tempX) > 0 || Math.abs(zShowRollOverMessageouty - tempY) > 0){
		 	zROCheckDistance = false;
			zStopRollOverMessage();
			for(var n=0;n<arrStyleRollOutHolding.length;n++){
				arrStyleRollOutHolding[n].func(arrStyleRollOutHolding[n].tr, arrStyleRollOutHolding[n].originalStyle, arrStyleRollOutHolding[n].index);
			}
			arrStyleRollOutHolding = new Array();
		}
	}
	return true;
}
/* ]]> */
</script>
</cfsavecontent>
<cfscript>
application.zcore.template.prependContent(js);
</cfscript>
</cffunction>
		
<!--- 
<cfscript>
inputStruct = StructNew();
inputStruct.message = "";
inputStruct.style = "table-highlight";
inputStruct.output = false;
// optional
inputStruct.xOffset = 20;
inputStruct.yOffset = 35;
inputStruct.padding = 5;
inputStruct.width = 220;
inputStruct.returnStruct = false; // set to true to return js code in a struct: returnStruct.onMouseOver and returnStruct.onMouseOut
roMessageCode = zRollOverMessage(inputStruct);
</cfscript>
 --->
<cffunction name="zRollOverMessage" localmode="modern" returntype="any" output="false">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	var js = "";
	var out="";
	var ss="";
	var tempStruct = StructNew();
	tempStruct.message = "";
	tempStruct.output = true;
	tempStruct.xOffset = 20;
	tempStruct.yOffset = 35;
	tempStruct.padding = 5;
	tempStruct.width = 220;
	tempStruct.style = false;
	tempStruct.returnStruct = false;
	StructAppend(arguments.inputStruct, tempStruct, false);
	ss = arguments.inputStruct; // less typing 
	zGetSharedRollOverJS();
	</cfscript>
	<cfif isDefined('Request.zROMessageInit') EQ false>
		<cfscript>
		StructInsert(request, "zROMessageInit", true, true);
		</cfscript>
		<cfsavecontent variable="js">
<script type="text/javascript">
/* <![CDATA[ */
var zShowRollOverMessageoutx;
var zShowRollOverMessageouty;
var zROMessageText = "";
var arrROMessageText = new Array();
function zShowRollOverMessage(obj, message, style,xOffset,yOffset,padding,width){
	zROCheckDistance = false;
	if(arrROMessageText[message] != zROMessageText || window.document.all.zRollOverMessage.style.visibility !='visible' ){
		var content = '<table style="border-spacing:'+padding+'px;" class="'+style+'"><tr><td>'+arrROMessageText[message]+'<\/td><\/tr><\/table>';
		window.document.all.zRollOverMessage.innerHTML = content;
		zROMessageText = arrROMessageText[message];
		window.document.all.zRollOverMessage.style.visibility ='visible';
		window.document.all.zRollOverMessage.style.width = width;
		window.document.all.zRollOverMessage.style.left = zGetRollOverXPosition(obj)+xOffset;
		window.document.all.zRollOverMessage.style.top = zGetRollOverYPosition(obj)+yOffset;
	} 
}
function zHideRollOverMessage(force){
	if(window.document.all.zRollOverMessage.style.visibility == "visible" || force == true){
		zShowRollOverMessageoutx = event.clientX + zScrollLeft;
		zShowRollOverMessageouty = event.clientY + zScrollTop;
		zROMessageForceHold=false;
		zROCheckDistance=true;
	}
}
function zHoldRollOverMessage(){
	zROMessageForceHold=true;
}
function zReleaseRollOverMessage(){
	zROMessageForceHold=false;
}
function zStopRollOverMessage(){
	zROCheckDistance=false;
	zShowRollOverMessageoutx = 0;
	zShowRollOverMessageouty = 0;
	zROMessageText = "";
	document.all.zRollOverMessage.style.visibility = "hidden";
}
/* ]]> */
</script>		  
<div id="zRollOverMessage" name="zRollOverMessage" onMouseMove="zHoldRollOverMessage();" onMouseOut="zReleaseRollOverMessage();" style="position:absolute; left:1px; top:1px; width:220px; height:10px; z-index:100; visibility: visible;">
</div>
		</cfsavecontent>
		<cfscript>
		application.zcore.template.prependContent(js);
		</cfscript>
	</cfif>
	<cfscript>
	request.zROMessageCount = application.zcore.functions.zso(Request, 'zROMessageCount',true)+1;
	application.zcore.template.prependContent('<script type="text/javascript">/* <![CDATA[ */arrROMessageText[#request.zROMessageCount#]= ''#JSStringFormat(ss.message)#'';/* ]]> */</script>');
	</cfscript>
	<cfif ss.returnStruct>
		<cfscript>
		returnStruct = StructNew();
		returnStruct.onMouseMove = " zHoldRollOverMessage(); "; 
		returnStruct.onMouseOver = " zShowRollOverMessage(this,#request.zROMessageCount#, '#ss.style#',#ss.xOffset#,#ss.yOffset#,#ss.padding#,#ss.width#); ";
		returnStruct.onMouseOut = ' zHideRollOverMessage(); ';
		return returnStruct;
		</cfscript>
	<cfelse>
		<cfsavecontent variable="out">  onMouseMove="zHoldRollOverMessage();" onMouseOver="zShowRollOverMessage(this,#request.zROMessageCount#, '#ss.style#',#ss.xOffset#,#ss.yOffset#,#ss.padding#,#ss.width#);" onMouseOut="zHideRollOverMessage();" </cfsavecontent>
		<cfscript>
		if(ss.output){
			writeoutput(out);
		}else{
			return out;
		}
		</cfscript>
	</cfif>
</cffunction>


</cfoutput>
</cfcomponent>