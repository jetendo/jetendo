<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
</cffunction>
<cffunction name="slideshow" localmode="modern" access="remote" output="yes">
</cffunction>

<cffunction name="video" localmode="modern" access="remote" output="yes">
	<cfargument name="vid" type="string" required="no" default="">
	<cfscript>
	var db=request.zos.queryObject;
	var arrVid=0;
	var c=0;
	var qV=0;
	var theMeta=0;
	var autoplay=0;
	var displayType=0;
	Request.zOS.debuggerEnabled=false;
	if(structkeyexists(form, 'vid')){
		arguments.vid=form.vid;	
	}
	arrVid=listtoarray(arguments.vid,"-",true);
	c=arraylen(arrVid);
	if(c LT 9){
	writeoutput("Invalid video.");
	application.zcore.functions.zabort();
	}
	local.video_id=arrVid[1];
	local.video_hash=arrVid[2];
	if(isnumeric(arrVid[3]) EQ false){
		arrVid[3]=320;	
	}
	if(isnumeric(arrVid[4]) EQ false){
		arrVid[4]=240;	
	}
	local.video_embed_width=max(100,min(1920,arrVid[3]));
	local.video_embed_height=max(100,min(1080,arrVid[4]));
	
	autoplay=false;
	if(arrVid[5] EQ 1){
		autoplay=true;
	}
	displayType=0;
	if(arrVid[6] EQ 1){
		displayType=1; 
	}
	db.sql="select * from #request.zos.queryObject.table("video", request.zos.zcoreDatasource)# video 
	WHERE video_id = #db.param(local.video_id)# and 
	video_hash = #db.param(local.video_hash)# and 
	site_id =#db.param(request.zos.globals.id)# and 
	video_deleted=#db.param(0)#";
	qV=db.execute("qV");
	if(qV.recordcount EQ 0){
		writeoutput("Video no longer available.");
		application.zcore.functions.zabort();
	}
	
	application.zcore.template.setTemplate("zcorerootmapping.templates.simple",true,true); 

	if(structkeyexists(form, 'forceFlash')){
		forceFlash=" || 1 ==1";
	}else{
		forceFlash="";
	}
	</cfscript>
	<cfsavecontent variable="theMeta">
	<style>
	/* <![CDATA[ */ 
	body{margin:0px; overflow:hidden;}
	h1{display:none;} 
	/* ]]> */
	</style>
   	<script>
	function scaleToFill(videoTag) {  
		var $video = $(videoTag);
		var windowWidth=$(window).width();
		var windowHeight=$(window).height();
		var videoRatio =windowWidth/videoTag.videoWidth;// videoTag.videoHeight/videoTag.videoWidth;
		var newHeight=videoRatio*videoTag.videoHeight;
		$video.css("max-width", #video_embed_width#+"px");
		$video.css("max-height", #video_embed_height#+"px");
		if(newHeight > windowHeight){ 
			$video.width('auto');
			$video.height(windowHeight);
		}else{ 
			$video.width(windowWidth);
			$video.height('auto');
		} 
	}
	function resizeFlashPlayer(){
		if(typeof $ == "undefined"){
			setTimeout(resizeFlashPlayer, 100);
			return;
		}
		$("##customFlashPlayer").height($(window).height());
		$("##customFlashPlayerEmbed").height($(window).height());
	}
	function loadFlashPlayer(){
		var videoDiv=document.getElementById('embedVideoDiv');
		videoDiv.style.display='block';
		videoDiv.innerHTML='<object width="100%" height="100" id="customFlashPlayer"><param name="allowFullScreen" value="true"><param name="allowScriptAccess" value="always"><param name="movie" value="/z/javascript/osflvplayer/OSplayer.swf?movie=/zupload/video/#qV.video_file#&amp;btncolor=0x333333&amp;accentcolor=0x31b8e9&amp;txtcolor=0xffffff&amp;volume=30&amp;autoload=on&amp;autoplay=<cfif autoplay>on<cfelse>off</cfif>&amp;vTitle=&amp;showTitle=no"><embed id="customFlashPlayerEmbed"  src="/z/javascript/osflvplayer/OSplayer.swf?movie=/zupload/video/#qV.video_file#&amp;btncolor=0x333333&amp;accentcolor=0x31b8e9&amp;txtcolor=0xffffff&amp;volume=30&amp;autoload=on&amp;autoplay=<cfif autoplay>on<cfelse>off</cfif>&amp;vTitle=&amp;showTitle=no" width="100%" height="100" allowFullScreen="true" type="application/x-shockwave-flash" allowScriptAccess="always"></object> ';
		if(typeof zArrResizeFunctions != "undefined"){
			zArrResizeFunctions.push(resizeFlashPlayer);
		}else{
			zArrDeferredFunctions.push(function(){
				zArrResizeFunctions.push(resizeFlashPlayer);
			});
		}
		resizeFlashPlayer();
		setTimeout(resizeFlashPlayer, 100);
	}
	zArrDeferredFunctions.push(function(){
		var hasVideoTagSupport=!!document.createElement('video').canPlayType;
		var videoDiv=$("##embedVideoDiv").show();

		if(!hasVideoTagSupport){
			loadFlashPlayer();
		}else{ 
			if(document.getElementById("embedVideoTag")){
				videoDiv.bind("click", function(e){
					e.preventDefault();
					$(this).trigger("play");
				}); 
				zArrResizeFunctions.push(function(){
					$("##embedVideoTag").height($(window).height());
					$("##embedVideoTag").width($(window).width());
					scaleToFill(document.getElementById("embedVideoTag"));
				});
				$("##embedVideoTag").height($(window).height());
				$("##embedVideoTag").width($(window).width());
				scaleToFill(document.getElementById("embedVideoTag"));
			}
			
		}
	});
	</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("meta",theMeta);
	if(not structkeyexists(form, 'poster')){
		if(fileexists(request.zos.globals.privatehomedir&"zupload/video/"&qV.video_file&"-00001.jpg")){
			form.poster="/zupload/video/"&qV.video_file&"-00001.jpg";
		}else{
			form.poster="";
		}
	}
	</cfscript>
	<div id="embedVideoDiv" style="display:none;">
		<video id="embedVideoTag"  controls="controls" onerror="loadFlashPlayer();" onclick="this.play();" style="cursor:pointer;" <cfif autoplay>autoplay="autoplay"</cfif> <cfif form.poster NEQ "">poster="#form.poster#"</cfif>>
			<source type="video/mp4" src="/zupload/video/#qV.video_file#" />
		</video>
	</div> 
</cffunction>
</cfoutput>
</cfcomponent>