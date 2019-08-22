<cfcomponent>
<cfoutput>
<cffunction name="getListing" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=arguments.ss;
	var imgid=0;
	var imgid2=0;
	</cfscript>
	<cfif ts.slideIndex NEQ 1 and ts.slideIndex MOD variables.qslideshow.slideshow_moved_tile_count EQ 1>
		</div>
		<div class="zslideshowslide#request.zos.tempobj.zSlideShowUniqueIdIndex#">
	</cfif>
	<cfscript>
	imgid="zslideshow-"&gettickcount()&'-'&ts.slideIndex;
	imgid2="zslideshow-"&gettickcount()&'-2-'&ts.slideIndex;
	</cfscript>
	<cfif variables.qslideshow.slideshow_large_image EQ 0>
		<cfsavecontent variable="theSlidePhoto"> <a id="#imgid2#" style="width:100%;" href="<cfif ts.arrLink[ts.slideIndex] EQ "">##<cfelse>#htmleditformat(ts.arrLink[ts.slideIndex])#</cfif>" target="_parent" title="<cfif variables.qslideshow.slideshow_tab_type_id EQ 2>#application.zcore.listingCom.getThumbnail(ts.arrImages[ts.slideIndex], ts.arrPhotoId[ts.slideIndex], 1, ts.slideshowConfig.imageWidth, ts.slideshowConfig.imageHeight, 1)#<cfelse>#arrImages[i]#</cfif>"><span style="display:block;position:relative; width:100%; height:#ts.slideshowConfig.imageHeight#px; text-align:center; float:left; z-index:1;"><img id="#imgid2#" src="/z/a/images/s.gif"  alt="#htmleditformat(ts.arrText[ts.slideIndex])#" /></span><span style="display:block; position:relative; z-index:3; font-size:16px; line-height:18px; text-align:center; width:100%; height:20px;color:##FFF; float:left; padding-top:10px; padding-bottom:10px; top:-45px;">#ts.arrFullText[ts.slideIndex]#</span><span style="display:block; position:relative; background-color:##000; width:100%; height:25px; float:left; top:-90px; z-index:2; padding-top:10px; padding-bottom:10px; opacity:0.7">&nbsp;</span></a>
		</cfsavecontent>
		<cfscript>
		arrayAppend(request.zos.tempObj.arrSlideshowSlide, theSlidePhoto);
		</cfscript>
		<div class="zslideshowitem#request.zos.tempobj.zSlideShowUniqueIdIndex# zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-1">
			<cfif ts.arrLink[ts.slideIndex] NEQ "">
				<div onclick="zSlideshowClickLink('#htmleditformat(ts.arrLink[ts.slideIndex])#');" class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-1">
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-4" style="float:left;width:#variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding#px; height:#variables.qslideshow.slideshow_thumb_height#px;"> #application.zcore.functions.zLoadAndCropImage({id:"#imgid#",width:variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding,height:variables.qslideshow.slideshow_thumb_height, url:ts.arrThumb[ts.slideIndex], style:"", canvasStyle:"", crop:true})# </div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-3"></div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-2">#ts.arrCity[ts.slideIndex]#</div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-40-1">#ts.arrPrice[ts.slideIndex]#</div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-41-1">
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-42">
							<cfif ts.arrBed[ts.slideIndex] NEQ "">
								#ts.arrBed[ts.slideIndex]# bed
							</cfif>
							<cfif ts.arrBed[ts.slideIndex] NEQ "" and ts.arrBath[ts.slideIndex] NEQ "">
								,
							</cfif>
							<cfif ts.arrBath[ts.slideIndex] NEQ "">
								#ts.arrBath[ts.slideIndex]# bath
							</cfif>
						</div>
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-43"><a id="#imgid#_link" target="_parent" href="#htmleditformat(ts.arrLink[ts.slideIndex])#"><img src="/z/a/images/slideshow/view.jpg" width="48" height="21" alt="View Listing" /></a></div>
					</div>
				</div>
			</cfif>
		</div>
	<cfelseif variables.qslideshow.slideshow_large_image EQ 2>
		<a href="#htmleditformat(arrLink[i])#" target="_parent" title="<cfif variables.qslideshow.slideshow_tab_type_id EQ 2>#application.zcore.listingCom.getThumbnail(ts.arrImages[ts.slideIndex], ts.arrPhotoId[ts.slideIndex], 1, ts.slideshowConfig.imageWidth, ts.slideshowConfig.imageHeight, 1)#<cfelse>#ts.arrImages[ts.slideIndex]#</cfif>">
		<div style="position:relative; width:100%; height:#variables.qslideshow.slideshow_height-25#px; float:left; z-index:1;"><img src="/z/a/images/s.gif"  alt="#htmleditformat(ts.arrText[ts.slideIndex])#" /></div>
		<div style="position:relative; z-index:3; font-size:130%; line-height:100%; text-align:center; width:100%; height:20px;color:##FFF; float:left; padding-top:10px; padding-bottom:10px; top:-45px;">#ts.arrFullText[ts.slideIndex]#</div>
		<div style="position:relative; background-color:##000; width:100%; height:25px; float:left; top:-90px; z-index:2; padding-top:10px; padding-bottom:10px; opacity:0.7"></div>
		</a>
	<cfelse>
		<div class="zslideshowitem#request.zos.tempobj.zSlideShowUniqueIdIndex# zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-1">
			<cfif ts.arrLink[ts.slideIndex] NEQ "">
				<div onclick="zSlideshowClickLink('#htmleditformat(ts.arrLink[ts.slideIndex])#');" class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-1">
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-4" style="float:left;width:#variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding#px; height:#variables.qslideshow.slideshow_thumb_height#px;"> #application.zcore.functions.zLoadAndCropImage({id:"#imgid#",width:variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding,height:variables.qslideshow.slideshow_thumb_height, url:ts.arrThumb[ts.slideIndex], style:"", canvasStyle:"", crop:true})# 
						</div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-3"></div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-2">#ts.arrCity[ts.slideIndex]#</div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-40-1">#ts.arrPrice[ts.slideIndex]#</div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-41-1">
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-42">
							<cfif ts.arrBed[ts.slideIndex] NEQ "">
								#ts.arrBed[ts.slideIndex]# bed
							</cfif>
							<cfif ts.arrBed[ts.slideIndex] NEQ "" and ts.arrBath[ts.slideIndex] NEQ "">
								,
							</cfif>
							<cfif ts.arrBath[ts.slideIndex] NEQ "">
								#ts.arrBath[ts.slideIndex]# bath
							</cfif>
						</div>
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-43"><a id="#imgid#_link" target="_parent" href="#htmleditformat(ts.arrLink[ts.slideIndex])#"><img src="/z/a/images/slideshow/view.jpg" width="48" height="21" alt="View Listing" /></a></div>
					</div>
				</div>
			</cfif>
		</div>
	</cfif>
</cffunction>

<cffunction name="getImage" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var imgid=0;
	var imgid2=0;
	var ts=arguments.ss;
	</cfscript>
	<cfif ts.slideIndex NEQ 1 and ts.slideIndex MOD variables.qslideshow.slideshow_moved_tile_count EQ 1>
		</div>
		<div class="zslideshowslide#request.zos.tempobj.zSlideShowUniqueIdIndex#">
	</cfif>
	<cfscript>
	imgid="zslideshow-"&gettickcount()&'-'&ts.slideIndex;
	imgid2="zslideshow-"&gettickcount()&'-2-'&ts.slideIndex;
	</cfscript>
	<cfif variables.qslideshow.slideshow_large_image EQ 0>
		<cfsavecontent variable="theSlidePhoto"> <a id="#imgid2#" style="width:100%;" href="<cfif ts.arrLink[ts.slideIndex] EQ "">##<cfelse>#htmleditformat(ts.arrLink[ts.slideIndex])#</cfif>" target="_parent" title="#ts.arrImages[ts.slideIndex]#"><span style="display:block;position:relative; width:100%; height:#ts.qss.slideshow_height-ts.qss.slideshow_thumbbar_margin-ts.qss.slideshow_thumb_height-ts.qss.slideshow_thumb_text_height-25#px; text-align:center; float:left; z-index:1;"><img id="#imgid2#" width="100%" height="100%" src="/z/a/images/s.gif" alt="#htmleditformat(ts.arrText[ts.slideIndex])#" /></span><span style="display:block; position:relative; z-index:3; font-size:16px; line-height:18px; text-align:center; width:100%; height:20px;color:##FFF; float:left; padding-top:10px; padding-bottom:10px; top:-45px; overflow:auto;">#ts.arrFullText[ts.slideIndex]#</span><span style="display:block; position:relative; background-color:##000; width:100%; height:25px; float:left; top:-90px; z-index:2; padding-top:10px; padding-bottom:10px; opacity:0.7">&nbsp;</span></a>
		<script type="text/javascript">/* <![CDATA[ */
document.getElementById("#imgid2#_img").onerror=function(){zImageOnError(this);};
/* ]]> */</script> 
		</cfsavecontent>
		<cfscript>
		arrayAppend(request.zos.tempObj.arrSlideshowSlide, theSlidePhoto);
		</cfscript>
		<div class="zslideshowitem#request.zos.tempobj.zSlideShowUniqueIdIndex# zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-1">
			<cfif ts.arrLink[ts.slideIndex] NEQ "">
				<div onclick="zSlideshowClickLink('#htmleditformat(ts.arrLink[ts.slideIndex])#');" class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-1">
					<div style="float:left;width:#variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding#px; height:#variables.qslideshow.slideshow_thumb_height#px;"><img id="#imgid#" src="#ts.arrThumb[ts.slideIndex]#" alt="#htmleditformat(ts.arrFullText[ts.slideIndex])#" />
					<script type="text/javascript">/* <![CDATA[ */
document.getElementById("#imgid#").onerror=function(){zImageOnError(this);};
/* ]]> */</script></div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-41-1-2">
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-43-2"><a id="#imgid#_link" target="_parent" href="#htmleditformat(ts.arrLink[ts.slideIndex])#"><img src="/z/a/images/slideshow/view.jpg" width="48" height="21" alt="View Listing" /></a></div>
#ts.arrFullText[ts.slideIndex]# 						</div>
				</div>
			</cfif>
		</div>
	<cfelseif variables.qslideshow.slideshow_large_image EQ 2>
		<a href="#htmleditformat(ts.arrLink[ts.slideIndex])#" target="_parent" title="#ts.arrImages[ts.slideIndex]#">
		<div style="position:relative; width:100%; height:#variables.qslideshow.slideshow_height-25#px; float:left; z-index:1;"><img src="/z/a/images/s.gif"  alt="#htmleditformat(ts.arrText[ts.slideIndex])#" /></div>
		<div style="position:relative; z-index:3; font-size:130%; line-height:100%; text-align:center; width:100%; height:20px;color:##FFF; float:left; padding-top:10px; padding-bottom:10px; top:-45px;">#ts.arrFullText[ts.slideIndex]#</div>
		<div style="position:relative; background-color:##000; width:100%; height:25px; float:left; top:-90px; z-index:2; padding-top:10px; padding-bottom:10px; opacity:0.7"></div>
		</a>
	<cfelse>
		<div class="zslideshowitem#request.zos.tempobj.zSlideShowUniqueIdIndex# zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-38-1">
			<cfif ts.arrLink[ts.slideIndex] NEQ "">
				<div onclick="zSlideshowClickLink('#htmleditformat(ts.arrLink[ts.slideIndex])#');" class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-39-1">
					<div style="float:left;width:#variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumb_padding#px; height:#variables.qslideshow.slideshow_thumb_height#px;"><img id="#imgid#" src="#ts.arrThumb[ts.slideIndex]#"  alt="#htmleditformat(ts.arrFullText[ts.slideIndex])#" />
					<script type="text/javascript">/* <![CDATA[ */
document.getElementById("#imgid#").onerror=function(){zImageOnError(this);};
/* ]]> */</script></div>
					<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-41-1-2">
						<div class="zslideshow#request.zos.tempobj.zSlideShowUniqueIdIndex#-43-2"><a id="#imgid#_link" target="_parent" href="#htmleditformat(ts.arrLink[ts.slideIndex])#"><img src="/z/a/images/slideshow/view.jpg" width="48" height="21" alt="View Listing" /></a></div>
#ts.arrFullText[ts.slideIndex]# 						</div>
				</div>
			</cfif>
		</div>
	</cfif>
</cffunction>

<cffunction name="getPhoto" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=arguments.ss;
	var imgid="zslideshow-"&gettickcount()&'-'&ts.slideIndex;
	</cfscript>
	<cfif ts.arrImages[ts.slideIndex] NEQ ""> 
		<a id="#imgid#" target="_parent" style="width:100%;" href="<cfif ts.arrLink[ts.slideIndex] EQ "">##<cfelse>#htmleditformat(ts.arrLink[ts.slideIndex])#</cfif>" title="<cfif variables.qslideshow.slideshow_tab_type_id EQ 2>#application.zcore.listingCom.getThumbnail(ts.arrImages[ts.slideIndex], ts.arrPhotoId[ts.slideIndex], 1, ts.slideshowConfig.imageWidth, ts.slideshowConfig.imageHeight, 1)#<cfelse>#ts.arrImages[ts.slideIndex]#</cfif>"> <span class="zSlideshowLargePhotoImg" style="display:block;position:relative; width:#ts.slideshowConfig.imageWidth#px; height:#ts.slideshowConfig.imageHeight#px; text-align:center; float:left; z-index:1; overflow:hidden;"> <img src="<cfif variables.qslideshow.slideshow_tab_type_id EQ 2>#application.zcore.listingCom.getThumbnail(ts.arrImages[ts.slideIndex], ts.arrPhotoId[ts.slideIndex], 1, ts.slideshowConfig.imageWidth, ts.slideshowConfig.imageHeight, 1)#<cfelse>#ts.arrImages[ts.slideIndex]#</cfif>"  id="#imgid#_img" alt="#htmleditformat(ts.arrText[ts.slideIndex])#" /></span>
		<cfif ts.arrFullText[ts.slideIndex] NEQ "">
			<span class="zSlideshowLargePhotoText" style="display:block; position:relative; z-index:3; font-size:16px; line-height:18px; text-align:center; width:#ts.slideshowConfig.imageWidth#px; height:20px;color:##FFF; float:left; padding-top:10px; padding-bottom:10px; overflow:auto; top:-40px;">#ts.arrFullText[ts.slideIndex]#</span><span class="zSlideshowLargePhotoTextBg" style="display:block; position:relative; background-color:##000; width:#ts.slideshowConfig.imageWidth#px; height:25px; float:left; top:-85px; z-index:2; padding-top:10px; padding-bottom:10px; opacity:0.7">&nbsp;</span>
		</cfif><script type="text/javascript">/* <![CDATA[ */
/*document.getElementById("#imgid#_img").onerror=function(){zImageOnError(this);};*/
/* ]]> */</script>
		</a>
		
	</cfif>
</cffunction>

<cffunction name="updateSlideshowCSS" localmode="modern" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	curIndex=arguments.ss.index;
	qss=arguments.ss.qss;
	slideshowConfig=arguments.ss.slideshowConfig;
	savecontent variable="theHT22"{
		echo('.zslideshowslides_container#curIndex# {
#local.slideshowConfig.slideContainer#
	display:none;
    float:left;
}

.zslideshowslides_container#curIndex# .zslideshowslide#curIndex# {
	width:#slideshowConfig.slideContainerWidth#px;
	height:#slideshowConfig.slideContainerHeight#px;
	display:block;
}

.zslideshowitem#curIndex# {
	float:left;
	width:165px;
	height:165px;
	padding-right:10px;
}
.zslideshowpagination#curIndex# {
	display:none;
	list-style:none;
	margin:0;
	padding:0;
}

.zslideshowpagination#curIndex# .zslideshowcurrent#curIndex# a {
	color:red;
}
.zslideshow#curIndex#-30 {
	width:210px;
	color:##FFF;
	float:left;
	height:21px;
	font-weight:bold;
	font-size:19px;
	padding-left:10px;
	font-family:trajan-pro, ''Times New Roman'', Times, serif;
	line-height:18px;
	padding-top:4px;
}
.zslideshow#curIndex#-32 {
	color:##5397ff;
}
.zslideshow#curIndex#-38-1 {
	float:left;
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding#px;
	padding:#qss.slideshow_thumb_padding#px;
	cursor:pointer;
}
.zslideshow#curIndex#-38-2 {
	float:left;
	width:100%; text-align:left;
}
.zslideshow#curIndex#-39 {
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding#px;
	height:103px;
	cursor:pointer;
	color:##FFF;
	font-size:13px;
	text-transform:none;
	background-position:center;
	background-repeat:no-repeat;
}
.zslideshow#curIndex#-39-2 {
	position:relative;
	padding-left:8px;
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding-8#px;
	top:-52px;
	float:left;
	color:##FFF;
	overflow:hidden;
	font-size:12px;
	line-height:12px;
	height:24px;
	padding-bottom:4px;
}
.zslideshow#curIndex#-39-3 {
	background-color:##000;
	opacity:0.4;
	-ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=40)";
	filter:alpha(opacity=40);
	position:relative;
	top:-27px;
	float:left;
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding#px;
	height:28px;
}
.zslideshow#curIndex#-40-1 {
	color:##FFF;
	background-color:##666;
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding-10#px;
	padding:3px;
	padding-top:6px;
	padding-left:7px;
	height:20px;
	position:relative;
	top:-56px;
	float:left;
	font-size:14px;
	line-height:14px;
	font-weight:400;
}
.zslideshow#curIndex#-41-1, .zslideshow#curIndex#-41-1-2 {
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding#px;
	padding:1px;
	padding-right:0px;
	color:##9d9d9d;
	font-size:12px;
	line-height:14px;
	float:left;
	position:relative;
	top:-56px;
}
.zslideshow#curIndex#-41-1-2{ overflow:auto; height:#qss.slideshow_thumb_text_height#px; top:0px;}
.zslideshow#curIndex#-42 {
	width:#qss.slideshow_thumb_width-qss.slideshow_thumb_padding-56#px;
	height:21px;
	padding-top:3px;
	font-size:12px;
	line-height:14px;
	padding-left:7px;
	float:left;
}
.zslideshow#curIndex#-43, .zslideshow#curIndex#-43-2 {
	float:left;
	font-size:12px;
	line-height:14px;
	width:48px;
	height:21px;
}
.zslideshow#curIndex#-43-2{ margin-right:3px; margin-bottom:3px; }
.zlistingslidernext#curIndex#:link, .zlistingslidernext#curIndex#:visited, .zlistingslidernext#curIndex#:hover, .zlistingsliderprev#curIndex#:link, .zlistingsliderprev#curIndex#:visited, .zlistingsliderprev#curIndex#:hover {
	display:block;
	cursor:pointer;
	float:left;
	text-decoration:none;
	border:1px solid ##999;
	#slideshowConfig.thumbbarButtonMargin#
}

.zlistingslidernavlinks#curIndex#{  float:left;}
.zlistingslidernextimg#curIndex#{
	#slideshowConfig.thumbbarButtonNextImageCSS# width:#slideshowConfig.thumbbarButtonImgWidth#px; height:#slideshowConfig.thumbbarButtonImgHeight#px;display:block;  #slideshowConfig.thumbbarButtonImgMargin# 
}
.zlistingsliderprevimg#curIndex#{
	#slideshowConfig.thumbbarButtonPrevImageCSS# width:#slideshowConfig.thumbbarButtonImgWidth#px; height:#slideshowConfig.thumbbarButtonImgHeight#px;display:block;#slideshowConfig.thumbbarButtonImgMargin#
}
.zlistingsliderprev#curIndex#:hover {
	background-color:##000;
}
.zlistingslidernext#curIndex#:hover {
	background-color:##000;
}

##zslideshowslides#curIndex# .zslideshownext#curIndex#,##zslideshowslides#curIndex# .zslideshowprev#curIndex# {
	position:absolute;
	top:0px;
	left:0px;
	display:block;
	z-index:101;cursor:pointer;
}
##zslideshowslides#curIndex# .next{ width:17px;height:48px;  text-decoration:none;background-image:url(/z/a/images/slideshow/right.png); _background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
     src=''/z/a/images/slideshow/right.png'', sizingMethod=''scale''); background-repeat:no-repeat; }
##zslideshowslides#curIndex# .prev{ width:17px;  height:48px; text-decoration:none;  background-image:url(/z/a/images/slideshow/left.png); _background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
     src=''/z/a/images/slideshow/left.png'', sizingMethod=''scale''); background-repeat:no-repeat;}
  
  
.zslideshowtablink#curIndex#, .zslideshowtablink#curIndex#:link, .zslideshowtablink#curIndex#:visited {
	background-color:###qss.slideshow_tabbgcolor#;
	color:###qss.slideshow_tabtextcolor#;
	text-decoration:none;
	display:block; float:left;
	padding:#qss.slideshow_tabpadding#px;
    font-size:12px; line-height:15px;
	border-right:1px solid ##999;
}
.zslideshowtablink#curIndex#:hover {
	background-color:###qss.slideshow_taboverbgcolor#;
	color:###qss.slideshow_tabovertextcolor#;
}
##zslideshowhomeslidenav#curIndex#{
	width:100%; margin-bottom:#qss.slideshow_thumbbar_margin#px;
}
##zUniqueSlideshowContainerId#curIndex#{
	width:#qss.slideshow_width#px;
	height:#qss.slideshow_height#px;
	
}
##zUniqueSlideshowLargeId#curIndex#{
width:#slideshowConfig.imageWidth#px;height:#slideshowConfig.imageHeight#px; float:left;overflow:hidden;
}
##zUniqueSlideshowId#curIndex#{
width:#slideshowConfig.thumbbarWidth#px;height:#slideshowConfig.thumbbarHeight#px; float:left; overflow:hidden;
}');
	}
	ts=structnew();
	ts.uniquePhrase="zSlideshowCSS#qss.slideshow_id#";
	ts.code=theHT22;
	ts.site_id=arguments.ss.site_id;
	application.zcore.functions.zPublishCss(ts);
	 db.sql="update #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	 set slideshow_hash = #db.param(arguments.ss.slideshowHash)#,
	 slideshow_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE slideshow_id = #db.param(qss.slideshow_id)# and 
	slideshow_deleted = #db.param(0)# and 
	site_id =#db.param(arguments.ss.site_id)#";
	db.execute("q");
	</cfscript>
</cffunction>

<cffunction name="getData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	 
	var arr1=arraynew(1);
	var arr2=arraynew(1);
	var arr3=arraynew(1);
	var arr4=arraynew(1); 
	var db=request.zos.queryObject;
	if(structkeyexists(form, 'x_ajax_id')){
		application.zcore.functions.zheader("x_ajax_id", form.x_ajax_id);	
	}
	form.action=application.zcore.functions.zso(form, 'action',false,'json');
	form.uniqueIdIndex=application.zcore.functions.zso(form, 'uniqueIdIndex',false,application.zcore.functions.zso(form, 'slideshow_id',true));
	request.zos.tempobj.zSlideShowUniqueIdIndex=form.uniqueIdIndex;
	local.slideshowConfig=structnew();
	
	form.offset=application.zcore.functions.zso(form, 'offset',true);
	if(form.offset LT 0){
		application.zcore.functions.z404("form.offset must be zero or greater.");	
	}
	if(structkeyexists(form, 'slideshow_id') EQ false){
		writeoutput('success=0&errorMessage='&urlencodedformat('Slideshow ID not defined.'));
		abort;
	}
	local.curtab="";
	if(structkeyexists(form,'tab') EQ false){
		db.sql="select slideshow_tab_id FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab 
		WHERE slideshow_id = #db.param(form.slideshow_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		slideshow_tab_deleted = #db.param(0)#
		ORDER BY slideshow_tab_sort ASC";
		qT=db.execute("qT"); 
		if(qT.recordcount NEQ 0){
			local.curtab=qT.slideshow_tab_id;
		}
	}else{
		local.curtab=form.tab;
		db.sql="select slideshow_tab_id FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab 
		WHERE slideshow_tab_id = #db.param(local.curtab)# and 
		slideshow_id = #db.param(form.slideshow_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		slideshow_tab_deleted = #db.param(0)#";
		qT=db.execute("qT"); 
		if(qT.recordcount EQ 0){
			 db.sql="select slideshow_tab_id FROM #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab 
			WHERE slideshow_id = #db.param(form.slideshow_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			slideshow_tab_deleted = #db.param(0)#
			ORDER BY slideshow_tab_sort ASC";
			qT=db.execute("qT");
			if(qT.recordcount NEQ 0){
				tab=qT.slideshow_tab_id;
			}
		}
	}
	 db.sql="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow, 
	 #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab 
	WHERE slideshow.site_id = slideshow_tab.site_id and 
	slideshow.slideshow_id = slideshow_tab.slideshow_id and 
	slideshow_tab.slideshow_tab_id = #db.param(local.curtab)# and 
	slideshow.slideshow_id=#db.param(form.slideshow_id)#  and 
	slideshow.site_id = #db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)# and 
	slideshow_tab_deleted = #db.param(0)# ";
	variables.qslideshow=db.execute("qslideshow");
	if(variables.qslideshow.recordcount EQ 0){ 
		writeoutput('success=0&errorMessage='&urlencodedformat('Slideshow record is missing.'));
		abort;
	}

	sqlT="select * from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	LEFT JOIN #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab ON 
	slideshow_tab.slideshow_id = slideshow.slideshow_id and 
	slideshow_tab.slideshow_tab_id = #db.param(local.curtab)# and 
	slideshow_tab.site_id = slideshow.site_id and 
	slideshow_tab_deleted = #db.param(0)#
	LEFT JOIN #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image ON 
	slideshow.slideshow_id = slideshow_image.slideshow_id and 
	slideshow_image.site_id = slideshow.site_id and 
	slideshow_image_deleted = #db.param(0)# 
	WHERE  slideshow.slideshow_id=#db.param(form.slideshow_id)# and 
	slideshow.site_id=#db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)# 
	ORDER BY slideshow_image_sort ASC ";
	if(variables.qslideshow.slideshow_tab_ajax_enabled EQ 1){
	   sqlT&="LIMIT #db.param(form.offset)#,#db.param(variables.qslideshow.slideshow_moved_tile_count)#";
	}
	db.sql=sqlT;
	qss=db.execute("qss");
	if(variables.qslideshow.slideshow_tab_type_id EQ 1){
		sqlTCount="select count(slideshow_image_id) count 
		from #db.table("slideshow_image", request.zos.zcoreDatasource)# slideshow_image 
		WHERE slideshow_tab_id = #db.param(local.curtab)# and 
		slideshow_id=#db.param(form.slideshow_id)#  and 
		slideshow_image_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		db.sql=sqlTCount;
		qssCount=db.execute("qssCount");
	}
	dirpath="/zupload/slideshow/#form.slideshow_id#/";
	// this is to preserve case sensitivity for flash
	arrKeys=["resizeImage","resizeImageBottom","imageFadeDuration","xDuration","yDuration","autoSlideDelay","tabs","slideDirection","activeTab","backImage","forwardImage","tabimages","tablinks","links","fulldesc","success","tab","images","thumbnails","desc2","thumbPadding","thumbAreaPadding","thumbWidth","thumbHeight","thumbTextHeight","movedTileCount","tab","ajaxEnabled","offset","count","backgroundImage","hideLargeImage","thumbMarginLeft","thumbMarginTop","thumbbarMargin","tabcaptions","tabclicklinks","tabPadding","tabSidePadding","tabBgColor","tabTextColor","tabOverBgColor","tabOverTextColor","tabIsText","thumbDisplayCount","hideThumbnails","city","price","bed","bath","listingid","condoname", "address", "listingType"];
	keyStruct=structnew();
	for(i=1;i LTE arraylen(arrKeys);i++){
		keyStruct[arrKeys[i]]=arrKeys[i];
	}
	thumbDisplayCount=variables.qslideshow.slideshow_thumb_display_count;
	flashOut=StructNew();
	flashOut.movedTileCount=variables.qslideshow.slideshow_moved_tile_count;
	firstTileCount=flashOut.movedTileCount;
	if(1 EQ 1 or (structkeyexists(form, 'firsttime') and form.firsttime EQ 1) or form.action EQ "json"){
		flashOut.thumbPadding=variables.qslideshow.slideshow_thumb_padding;
		flashOut.thumbAreaPadding=variables.qslideshow.slideshow_thumb_area_padding;
		flashOut.thumbWidth=variables.qslideshow.slideshow_thumb_width;
		flashOut.thumbHeight=variables.qslideshow.slideshow_thumb_height;
		flashOut.thumbTextHeight=variables.qslideshow.slideshow_thumb_text_height;
		flashOut.thumbbarMargin=variables.qslideshow.slideshow_thumbbar_margin;
		if(variables.qslideshow.slideshow_resize_image EQ 1){
			flashOut.resizeImage=true;
		}else{
			flashOut.resizeImage=false;
		}
		if(variables.qslideshow.slideshow_resize_image_bottom EQ 1){
			flashOut.resizeImageBottom=true;
		}else{
			flashOut.resizeImageBottom=false;
		}
		if(variables.qslideshow.slideshow_background_image NEQ ""){
			flashOut.backgroundImage=dirpath&variables.qslideshow.slideshow_background_image;
		}
		flashOut.thumbMarginLeft=variables.qslideshow.slideshow_thumb_margin_left;
		flashOut.thumbMarginTop=variables.qslideshow.slideshow_thumb_margin_top;
		flashOut.imageFadeDuration=variables.qslideshow.slideshow_image_fade_duration;
		flashOut.xDuration=variables.qslideshow.slideshow_x_duration;
		flashOut.yDuration=variables.qslideshow.slideshow_y_duration;
		if(variables.qslideshow.slideshow_large_image EQ 2){
			flashOut.hideThumbnails=true;
		}else{
			flashOut.hideThumbnails=false;	
		}
		if(variables.qslideshow.slideshow_large_image EQ 1){
			flashOut.hideLargeImage=true;
		}else{
			flashOut.hideLargeImage=false;
		}
		flashOut.autoSlideDelay=variables.qslideshow.slideshow_auto_slide_delay;
		flashOut.slideDirection=variables.qslideshow.slideshow_slide_direction;
		if(variables.qslideshow.slideshow_tabistext EQ 1){
			flashOut.tabIsText=true;
			flashOut.tabBgColor="0x"&variables.qslideshow.slideshow_tabbgcolor;
			flashOut.tabTextColor="0x"&variables.qslideshow.slideshow_tabtextcolor;
			flashOut.tabOverBgColor="0x"&variables.qslideshow.slideshow_taboverbgcolor;
			flashOut.tabOverTextColor="0x"&variables.qslideshow.slideshow_tabovertextcolor;
			flashOut.tabPadding=variables.qslideshow.slideshow_tabpadding;
			flashOut.tabSidePadding=variables.qslideshow.slideshow_tabsidepadding;
		}else{
			flashOut.tabIsText=false;
			flashOut.backImage=dirpath&variables.qslideshow.slideshow_back_image;
			flashOut.forwardImage=dirpath&variables.qslideshow.slideshow_forward_image;
				
		}
		 db.sql="select * from #db.table("slideshow_tab", request.zos.zcoreDatasource)# slideshow_tab 
		WHERE slideshow_id=#db.param(form.slideshow_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		slideshow_tab_deleted = #db.param(0)# 
		ORDER BY slideshow_tab_sort ASC";
		qss2=db.execute("qss2");
		arr1=arraynew(1);
		arr2=arraynew(1);
		arr3=arraynew(1);
		arr4=arraynew(1);
		for(i=1;i LTE qss2.recordcount;i++){
			arrayappend(arr4,qss2.slideshow_tab_caption[i]);
			arrayappend(arr3,qss2.slideshow_tab_link[i]);
			if(variables.qslideshow.slideshow_tabistext EQ 1){
				arrayappend(arr1,"");
			}else{
				arrayappend(arr1,dirpath&"tabs/"&qss2.slideshow_tab_url[i]);
			}
			if(form.action EQ 'json'){
				arrayappend(arr2,"/z/misc/slideshow/index?slideshow_id=#form.slideshow_id#&action=json&tab=#qss2.slideshow_tab_id[i]#&uniqueIdIndex=#form.uniqueIdIndex#");
			}else{
				arrayappend(arr2,"/z/misc/slideshow/index?slideshow_id=#form.slideshow_id#&action=flash&tab=#qss2.slideshow_tab_id[i]#&uniqueIdIndex=#form.uniqueIdIndex#");
			}
		}
		flashOut.tabimages=arraytolist(arr1,chr(9));
		flashOut.tablinks=arraytolist(arr2,chr(9));
		flashOut.tabclicklinks=arraytolist(arr3,chr(9));
		flashOut.tabcaptions=arraytolist(arr4,chr(9));
		firstTileCount=variables.qslideshow.slideshow_thumb_display_count;
		flashOut.thumbDisplayCount=variables.qslideshow.slideshow_thumb_display_count;
	}
	if(form.offset EQ 0){
		firstTileCount=variables.qslideshow.slideshow_thumb_display_count;
	}
	if(variables.qslideshow.slideshow_tab_ajax_enabled EQ 1){
		flashOut.ajaxEnabled=true;
	}else{
		flashOut.ajaxEnabled=false;
	}
	flashOut.tab=local.curtab;
	flashOut.success="1";
	flashOut.offset=application.zcore.functions.zso(form, 'offset',false,0);
	if(variables.qSlideshow.slideshow_tab_type_id EQ 1){
		arrImages=ArrayNew(1);
		arrThumb=ArrayNew(1);
		arrText=ArrayNew(1);
		arrFullText=ArrayNew(1);
		arrPhotoId=arraynew(1);
		arrCity=arraynew(1);
		arrAddress=arraynew(1);
		arrRemarks=arraynew(1);
		arrPhotoId=arraynew(1);
		arrListingType=arraynew(1);
		arrBed=arraynew(1);
		arrBath=arraynew(1);
		arrPrice=arraynew(1);
		arrLink=ArrayNew(1);
		if(qssCount.recordcount NEQ 0){
			flashOut.count=qssCount.count;
		}else{
			flashOut.count=0;	
		}
		loop query="qss"{
			arrayappend(arrText,replace(replace(qss.slideshow_image_caption,chr(13),'','ALL'),chr(9),' ','ALL'));
			arrayappend(arrFullText,replace(replace(qss.slideshow_image_thumb_caption,chr(13),'','ALL'),chr(9),' ','ALL'));
			if(qss.slideshow_image_link NEQ ""){
				arrayappend(arrLink,qss.slideshow_image_link);
			}else{
				arrayappend(arrLink,"");
			}
			arrayappend(arrImages, dirpath&qss.slideshow_image_url);
			arrayappend(arrThumb,dirpath&qss.slideshow_image_thumbnail_url);
			arrayappend(arrPhotoId,'0-'&qss.slideshow_id&'-'&qss.slideshow_image_id);
			arrayappend(arrRemarks,'');
			arrayappend(arrCity,'');
			arrayappend(arrAddress,'');
			arrayappend(arrBath,'');
			arrayappend(arrBed,'');
			arrayappend(arrListingType,'');
			arrayappend(arrPrice,'');
		}
		flashOut.listingType=arraytolist(arrListingType,chr(9)); 
		flashOut.links=arraytolist(arrLink,chr(9));
		flashOut.fulldesc=arraytolist(arrFullText,chr(9));
		flashOut.images=arraytolist(arrImages,chr(9));
		flashOut.desc2=arraytolist(arrText,chr(9));
		flashOut.thumbnails=arraytolist(arrThumb,chr(9));
		//zdump(flashOut);
	}else if(variables.qSlideshow.slideshow_tab_type_id EQ 2){
		ts=structnew();
		ts.returnQueryOnly=true;
		ts.forceSimpleLimit=true;
		ts.offset=form.offset;
		ts.disableCount=false;
		ts.search_with_photos=1;
		if(variables.qslideshow.slideshow_enable_ajax EQ 1){
			ts.perpage=variables.qslideshow.slideshow_moved_tile_count;	
		}else if(structkeyexists(arguments.ss,'displayAllResults') and arguments.ss.displayAllResults){
			ts.perpage=300;
		}else if(variables.qslideshow.slideshow_format EQ 1 or variables.qslideshow.slideshow_large_image EQ 0){
			ts.perpage=variables.qslideshow.slideshow_moved_tile_count*5;	
		}else if(variables.qslideshow.slideshow_large_image EQ 2){
			ts.perpage=15;	
		}else{
			ts.perpage=firstTileCount;
		}
		flashOut.count=ts.perpage;	
		ts.forcePerPage=true;
		ts.disableInstantSearch=true;
		request.forceHighOffset=true;
		returnStruct=request.zos.listing.functions.zMLSSearchOptionsDisplay(variables.qslideshow.mls_saved_search_id, ts); 
		flashOut.count=returnStruct.count;
		

		arrImages=ArrayNew(1);
		arrThumb=ArrayNew(1);
		arrText=ArrayNew(1);
		arrFullText=ArrayNew(1);
		arrLink=ArrayNew(1);
		arrCondo=ArrayNew(1);
		arrRemarks=arraynew(1);
		arrPhotoId=arraynew(1);
		arrListingId=arraynew(1);
		arrListingType=arraynew(1);
		arrBed=arraynew(1);
		arrBath=arraynew(1);
		arrPrice=arraynew(1);
		arrCity=arraynew(1);
		arrAddress=arraynew(1);
		/*k222=structcount(returnStruct.orderStruct);
		for(i=1;i LTE k222;i++){
			arrText[i]="";
			arrLink[i]="";
			arrImages[i]="";
			arrThumb[i]="";
			arrFullText[i]="";
			arrListingId[i]="";
			arrBed[i]="";
			arrBath[i]="";
			arrPrice[i]="";
			arrListingType[i]="";
			arrCity[i]="";
			arrAddress[i]="";
			arrRemarks[i]="";
			arrPhotoId[i]="";
			arrCondo[i]="";
		}*/
		for(g2=1;g2 LTE min(returnStruct.perpage, arraylen(returnStruct.arrData));g2++){
			row=returnStruct.arrData[g2];  
			i=g2;
			mls_id=listgetat(row.listing_id,1,"-");
			mls_pid=listgetat(row.listing_id,2,"-");
			structappend(variables, request.zos.listingMlsComObjects[mls_id].getDetails(row, i), true);
			variables.listing_id=row.listing_id;
			titleStruct = request.zos.listing.functions.zListinggetTitle(variables);
			propertyLink = '/#titleStruct.urlTitle#-#variables.urlMlsId#-#variables.urlMLSPId#.html';
			
			request.lastPhotoId=row.listing_id;
			if(structkeyexists(variables,'sysidfield')){
				photoURL=request.zos.listingMlsComObjects[mls_id].getPhoto(mls_pid, 1, variables.sysidfield, variables.sysidfield2);
			}else{
				photoURL=request.zos.listingMlsComObjects[mls_id].getPhoto(mls_pid, 1);
			}
			if(photoURL EQ ""){
				photo1="/z/a/listing/images/image-not-available.jpg";
			}else{
				photo1=photoURL;
			}
			arrT=arraynew(1);
			bedbath="";
			if(isDefined('row.listing_beds') and row.listing_beds neq '' and row.listing_beds NEQ 0){
				arrBed[i]='#row.listing_beds#';
				arrayappend(arrT,'#row.listing_beds#BR, ');
			}else{
				arrBed[i]='';
			}
			arrCity[i]=variables.cityName;
			arrAddress[i]=row.listing_data_address;
			
			arrayappend(arrT,'#titleStruct.propertyType#, ');
			
			if(isDefined('row.listing_halfbaths') and row.listing_halfbaths neq '' and row.listing_halfbaths neq '0' and isDefined('row.listing_baths') and row.listing_baths neq '' and row.listing_baths neq '0'){
				arrBath[i]='#(row.listing_halfbaths / 2) + row.listing_baths#';
				arrayappend(arrT,'#(row.listing_halfbaths / 2) + row.listing_baths#BA, ');
			}else if(isDefined('row.listing_baths') and row.listing_baths neq '' and row.listing_baths neq '0'){
				arrBath[i]='#row.listing_baths#';
				arrayappend(arrT,'#row.listing_baths#BA, ');
			}else{
				arrBath[i]='';
			}
			
			if(row.listing_price NEQ '0') {
				arrayappend(arrT,'$#numberformat(row.listing_price)#');
				arrPrice[i]="$"&numberformat(row.listing_price);
			}else{
				arrPrice[i]= '';
			}
			arrayappend(arrT,chr(10)&'Read More');
			arrRemarks[i]=row.listing_data_remarks;
			arrCondo[i]=row.listing_condoname;
			arrFullText[i]=replace(replace(arraytolist(arrT,''),chr(13),'','ALL'),chr(9),' ','ALL');
			arrText[i]=arrFullText[i];
			arrLink[i]=propertyLink;
			arrListingId[i]=row.listing_id;
			arrListingType[i]=titleStruct.propertyType;
			arrImages[i]=photo1;
			arrThumb[i]=photo1;
			arrPhotoId[i]=request.lastPhotoId;
		 
		}
		flashOut.links=arraytolist(arrLink,chr(9));
		flashOut.fulldesc=arraytolist(arrFullText,chr(9));
		flashOut.images=arraytolist(arrImages,chr(9));
		flashOut.desc2=arraytolist(arrText,chr(9));
		flashOut.listingid=arraytolist(arrListingId,chr(9));
		flashOut.listingtype=arraytolist(arrListingType,chr(9));
		flashOut.thumbnails=arraytolist(arrThumb,chr(9));
		flashOut.price=arraytolist(arrPrice,chr(9));
		flashOut.address=arraytolist(arrAddress,chr(9));
		flashOut.city=arraytolist(arrCity,chr(9));
		flashOut.condoname=arraytolist(arrCondo,chr(9));
		flashOut.bed=arraytolist(arrBed,chr(9));
		flashOut.bath=arraytolist(arrBath,chr(9));
		//zdump(flashOut);
		
	}
	//zdump(flashOut);
	arrO=arraynew(1);
	for(i in flashOut){
		i2=keyStruct[i];
		if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
			arrayappend(arrO,keyStruct[i]&"="&flashOut[i]);	
		}else if(form.action EQ 'json'){
			arrayappend(arrO,keyStruct[i]&'="'&jsstringformat(flashOut[i])&'"');	
		}else{
			arrayappend(arrO,keyStruct[i]&"="&urlencodedformat(flashOut[i]));	
		}
	}
	if(variables.qslideshow.slideshow_large_image EQ 0){
		request.zos.tempObj.arrSlideshowSlide=arraynew(1);
	}
	local.slideshowConfig.arrTab=listtoarray(flashout.tablinks,chr(9));
	local.slideshowConfig.arrTabCaptions=listtoarray(flashout.tabcaptions,chr(9));
	if(variables.qslideshow.slideshow_slide_direction EQ "y"){
		if(arraylen(local.slideshowConfig.arrTab) GT 1){
			// vertical with tabs, large image and thumbs
			if(variables.qslideshow.slideshow_large_image EQ 0){
				local.slideshowConfig.thumbbarButtonImgWidth=12;
				local.slideshowConfig.thumbbarButtonImgHeight=7;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width-variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumbbar_margin;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-40;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarButtonWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonHeight=10;
				local.slideshowConfig.slideContainer="height:"&(variables.qslideshow.slideshow_height-66)&"px;";
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_height-34;
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonMargin=" margin-left:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prevtop.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prevtop.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/nextbottom.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/nextbottom.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-left:#int((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px; margin-right:#ceiling((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px;";
			}else if(variables.qslideshow.slideshow_large_image EQ 2){
				// vertical with tabs and large image
				local.slideshowConfig.thumbbarButtonImgWidth=0;
				local.slideshowConfig.thumbbarButtonImgHeight=0;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-40;
				local.slideshowConfig.thumbbarWidth=0;
				local.slideshowConfig.thumbbarHeight=0;
				local.slideshowConfig.thumbbarButtonWidth=0;
				local.slideshowConfig.thumbbarButtonHeight=0;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width)&"px;";
				local.slideshowConfig.slideContainerWidth=0;
				local.slideshowConfig.slideContainerHeight=0;
				local.slideshowConfig.thumbbarButtonMargin=" ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="";
				local.slideshowConfig.thumbbarButtonNextImageCSS="";
				local.slideshowConfig.thumbbarButtonImgMargin="";
			}else if(variables.qslideshow.slideshow_large_image EQ 1){
				// vertical with tabs and thumbs
				local.slideshowConfig.thumbbarButtonImgWidth=12;
				local.slideshowConfig.thumbbarButtonImgHeight=7;
				local.slideshowConfig.imageWidth=0;
				local.slideshowConfig.imageHeight=0;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarButtonWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonHeight=10;
				local.slideshowConfig.slideContainer="height:"&(variables.qslideshow.slideshow_height-66)&"px;";
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_height-34;
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonMargin=" margin-left:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prevtop.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prevtop.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/nextbottom.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/nextbottom.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-left:#int((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px; margin-right:#ceiling((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px;";
			}
				
		}else{
			if(variables.qslideshow.slideshow_large_image EQ 0){
				// both thumbs and large with no tab
				local.slideshowConfig.thumbbarButtonImgWidth=12;
				local.slideshowConfig.thumbbarButtonImgHeight=7;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width-variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumbbar_margin;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarButtonWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonHeight=10;
				local.slideshowConfig.slideContainer="height:"&(variables.qslideshow.slideshow_height-26)&"px;";
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_height-34;
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonMargin=" margin-left:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prevtop.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prevtop.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/nextbottom.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/nextbottom.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-left:#int((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px; margin-right:#ceiling((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px;";
			}else if(variables.qslideshow.slideshow_large_image EQ 2){
				local.slideshowConfig.thumbbarButtonImgWidth=12;
				local.slideshowConfig.thumbbarButtonImgHeight=7;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarWidth=0;
				local.slideshowConfig.thumbbarHeight=0;
				local.slideshowConfig.thumbbarButtonWidth=0;
				local.slideshowConfig.thumbbarButtonHeight=0;
				local.slideshowConfig.slideContainer="height:"&(0)&"px;";
				local.slideshowConfig.slideContainerHeight=0;
				local.slideshowConfig.slideContainerWidth=0;
				local.slideshowConfig.thumbbarButtonMargin=" margin-left:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prevtop.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prevtop.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/nextbottom.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/nextbottom.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-left:#int((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px; margin-right:#ceiling((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px;";
			}else{
				// just thumbs
				local.slideshowConfig.thumbbarButtonImgWidth=12;
				local.slideshowConfig.thumbbarButtonImgHeight=7;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width-variables.qslideshow.slideshow_thumb_width-variables.qslideshow.slideshow_thumbbar_margin;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarButtonWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonHeight=10;
				local.slideshowConfig.slideContainer="height:"&(variables.qslideshow.slideshow_height-26)&"px;";
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_height-34;
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_thumb_width;
				local.slideshowConfig.thumbbarButtonMargin=" margin-left:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prevtop.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prevtop.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/nextbottom.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/nextbottom.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-left:#int((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px; margin-right:#ceiling((local.slideshowConfig.thumbbarButtonWidth-variables.qslideshow.slideshow_thumbbar_margin-12)/2)-1#px;";
					
			}
		}
	}else{
		if(arraylen(local.slideshowConfig.arrTab) GT 1){
			if(variables.qslideshow.slideshow_large_image EQ 0){
				// tabs and horizontal and large image
				local.slideshowConfig.thumbbarButtonImgWidth=7;
				local.slideshowConfig.thumbbarButtonImgHeight=12;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-variables.qslideshow.slideshow_thumb_height-variables.qslideshow.slideshow_thumb_text_height-variables.qslideshow.slideshow_thumbbar_margin-34;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height+40;
				local.slideshowConfig.thumbbarButtonWidth=10;
				local.slideshowConfig.thumbbarButtonHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width-34)&"px;";
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_width-20;
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
					local.slideshowConfig.thumbbarButtonMargin=" margin-top:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prev.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prev.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/next.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
		 src='/z/a/images/slideshow/next.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-top:#int((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px; margin-bottom:#ceiling((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px;";
			}else if(variables.qslideshow.slideshow_large_image EQ 2){
				// tabs with large image
				local.slideshowConfig.thumbbarButtonImgWidth=7;
				local.slideshowConfig.thumbbarButtonImgHeight=12;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-34;
				local.slideshowConfig.thumbbarWidth=0;
				local.slideshowConfig.thumbbarHeight=0;
				local.slideshowConfig.thumbbarButtonWidth=0;
				local.slideshowConfig.thumbbarButtonHeight=0;
				local.slideshowConfig.slideContainer="width:"&(0)&"px;";
				local.slideshowConfig.slideContainerWidth=0;
				local.slideshowConfig.slideContainerHeight=0;
					local.slideshowConfig.thumbbarButtonMargin=" margin-top:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prev.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prev.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/next.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
		 src='/z/a/images/slideshow/next.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-top:#int((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px; margin-bottom:#ceiling((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px;";
			}else{
				// tabs with thumbs
				local.slideshowConfig.thumbbarButtonImgWidth=7;
				local.slideshowConfig.thumbbarButtonImgHeight=12;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-variables.qslideshow.slideshow_thumb_height-variables.qslideshow.slideshow_thumb_text_height-variables.qslideshow.slideshow_thumbbar_margin-34;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height+40;
				local.slideshowConfig.thumbbarButtonWidth=10;
				local.slideshowConfig.thumbbarButtonHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width-44)&"px;";
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_width-20;
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.thumbbarButtonMargin=" margin-top:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prev.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prev.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/next.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
		 src='/z/a/images/slideshow/next.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-top:#int((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px; margin-bottom:#ceiling((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px;";
				
			}
		}else{
			if(variables.qslideshow.slideshow_large_image EQ 0){
				// no tabs and horizontal large image + thumbs
				// tabs with thumbs
				local.slideshowConfig.thumbbarButtonImgWidth=7;
				local.slideshowConfig.thumbbarButtonImgHeight=12;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height-variables.qslideshow.slideshow_thumb_height-variables.qslideshow.slideshow_thumb_text_height-variables.qslideshow.slideshow_thumbbar_margin-14;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height+10;
				local.slideshowConfig.thumbbarButtonWidth=10;
				local.slideshowConfig.thumbbarButtonHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width-34)&"px;";
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_width-20;
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.thumbbarButtonMargin=" margin-top:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prev.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prev.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/next.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
		 src='/z/a/images/slideshow/next.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-top:#int((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px; margin-bottom:#ceiling((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px;";
			}else if(variables.qslideshow.slideshow_large_image EQ 2){
				// no tabs and horizontal large image
				local.slideshowConfig.thumbbarButtonImgWidth=0;
				local.slideshowConfig.thumbbarButtonImgHeight=0;
				local.slideshowConfig.imageWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.imageHeight=variables.qslideshow.slideshow_height;
				local.slideshowConfig.thumbbarWidth=0;
				local.slideshowConfig.thumbbarHeight=0;
				local.slideshowConfig.thumbbarButtonWidth=0;
				local.slideshowConfig.thumbbarButtonHeight=0;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width)&"px;";
				local.slideshowConfig.slideContainerWidth=0;
				local.slideshowConfig.slideContainerHeight=0;
				local.slideshowConfig.thumbbarButtonMargin=" ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="";
				local.slideshowConfig.thumbbarButtonNextImageCSS="";
				local.slideshowConfig.thumbbarButtonImgMargin="";
			}else if(variables.qslideshow.slideshow_large_image EQ 1){
				// no tabs and horizontal thumbs
				local.slideshowConfig.thumbbarButtonImgWidth=7;
				local.slideshowConfig.thumbbarButtonImgHeight=12;
				local.slideshowConfig.imageWidth=0;
				local.slideshowConfig.imageHeight=0;
				local.slideshowConfig.thumbbarWidth=variables.qslideshow.slideshow_width;
				local.slideshowConfig.thumbbarHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height+10;
				local.slideshowConfig.thumbbarButtonWidth=10;
				local.slideshowConfig.thumbbarButtonHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.slideContainer="width:"&(variables.qslideshow.slideshow_width-39)&"px;";
				local.slideshowConfig.slideContainerWidth=variables.qslideshow.slideshow_width-20;
				local.slideshowConfig.slideContainerHeight=variables.qslideshow.slideshow_thumb_height+variables.qslideshow.slideshow_thumb_text_height;
				local.slideshowConfig.thumbbarButtonMargin=" margin-top:"&variables.qslideshow.slideshow_thumbbar_margin&"px; ";
				local.slideshowConfig.thumbbarButtonPrevImageCSS="background-image:url(/z/a/images/slideshow/prev.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
	 src='/z/a/images/slideshow/prev.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonNextImageCSS="background-image:url(/z/a/images/slideshow/next.png);_background-image:none; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(
		 src='/z/a/images/slideshow/next.png', sizingMethod='scale'); background-repeat:no-repeat;";
				local.slideshowConfig.thumbbarButtonImgMargin="margin:2px; margin-top:#int((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px; margin-bottom:#ceiling((local.slideshowConfig.thumbbarButtonHeight-12)/2)-1#px;";
			}
				
		}
	}
	if(form.action EQ "json"){
		if(variables.qslideshow.slideshow_custom_include EQ "" and request.cgi_SCRIPT_NAME EQ '/z/misc/slideshow/index'){
			if(variables.qslideshow.slideshow_large_image EQ 0){
				for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
					this.getPhoto(local);
				}
				writeoutput('~~~');
				if(variables.qslideshow.slideshow_tab_type_id EQ 2){
					for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
						this.getListing(local);
					}
				}else{
					for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
						this.getImage(local);
					}
				}
			}else if(variables.qslideshow.slideshow_large_image EQ 1){
				if(variables.qslideshow.slideshow_tab_type_id EQ 2){
					for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
						this.getListing(local);
					}
				}else{
					for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
						this.getImage(local);
					}
				}
			}else if(variables.qslideshow.slideshow_large_image EQ 2){
				for(slideIndex=1;slideIndex LTE arraylen(arrImages);slideIndex++){
					this.getPhoto(local);
				}
			}
			application.zcore.functions.zabort();
		}else{
			if(variables.qslideshow.slideshow_custom_include NEQ ""){
				if(request.cgi_script_name EQ "/z/misc/slideshow/index"){
					request.znotemplate=1;
				}
				if(right(variables.qslideshow.slideshow_custom_include,4) NEQ ".cfm"){
					if(left(variables.qslideshow.slideshow_custom_include,5) EQ "root."){
						variables.qslideshow.slideshow_custom_include=replace(variables.qslideshow.slideshow_custom_include, "root.", request.zRootCFCPath);
					}
					local.tempCom=application.zcore.functions.zcreateobject("component", variables.qslideshow.slideshow_custom_include);
					
					t9={
						"arrImages": "image",
						"arrThumb": "thumb",
						"arrText": "text",
						"arrFullText": "fullText",
						"arrLink": "link",
						"arrCondo": "condo",
						"arrRemarks": "remarks",
						"arrPhotoId": "photoId",
						"arrListingId": "listingId",
						"arrListingType": "listingType",
						"arrBed": "bed",
						"arrBath": "bath",
						"arrPrice": "price",
						"arrCity": "city",
						"arrAddress": "address"
					}
					row2={};
					for(row in variables.qSlideshow){
						row2=row;
					}
					for(i=1;i LTE arraylen(arrImages);i++){ 
						ts={};
						for(n in t9){
							ts[t9[n]]= local[n][i];
						}
						local.tempCom.render(ts, {config:row, currentRow:i, recordcount:arraylen(arrImages)}); // must pass a struct to the function which represents current row
					}
				}else{ 
					for(i=1;i LTE arraylen(arrImages);i++){
						if(left(variables.qslideshow.slideshow_custom_include,18) EQ "/zcorerootmapping/"){
							cfinclude(template="#variables.qslideshow.slideshow_custom_include#");
						}else{
							cfinclude(template="#request.zRootPath##removechars(variables.qslideshow.slideshow_custom_include,1,1)#");
						}
					} 
				}
			}
		}
	}else{
		if(structkeyexists(form, 'decode')){
			writeoutput("ztv=1&"&urldecode(arraytolist(arrO,"&"))&"&ztv2=1");
		}else{
			writeoutput("ztv=1&"&arraytolist(arrO,"&")&"&ztv2=1");
		}
		application.zcore.tracking.backOneHit();application.zcore.functions.zabort();
		
	}
	local.qss=variables.qslideshow;
	return local;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
