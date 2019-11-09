<!--- 
TODO: 

this post shows how you can use php stream functions to output a video stream securely with flowplayer - maybe others can do it too.  flowplayer falls back to html 5 on iOS already
	$videofilename = 'testVideo.mov';    
	$hash = md5('1234');
	$timestamp = time();
	$videoPath = $hash.'/'.$timestamp.'/'.$videofilename;
	echo '
	<object width="667" height="375" type="application/x-shockwave-flash" data="http://releases.flowplayer.org/swf/flowplayer-3.2.8.swf">
		<param name="wmode" value="transparent"/>
		<param name="movie" value="../swf/flowplayer.securestreaming-3.2.8.swf" />
		<param name="allowfullscreen" value="true" />
		<param name="timestamp" value="'.$timestamp.'" />
		<param name="token" value="'.$hash.'" />    
		<param name="streamName" value="'.$videofilename.'" />      
	
		<param name="flashvars" value=\'config={
			"playlist":[
				{"url": "'.$videoPath.'", "baseUrl": "http://www.mydomain.com/videos", "autoPlay":false,"autoBuffering":true,"bufferLength":5}
				]
	
			}\' />
	</object>';

http://stackoverflow.com/questions/9860868/flowplayer-secure-streaming-with-apache
	RewriteEngine on
	 RewriteRule ^(.*)/(.*)/(.*)$ http://www.mydomain.com/vidoeos/video.php?h=$1&t=$2&v=$3
	 RewriteRule ^$ - [F]
	 RewriteRule ^[^/]+\.(mov|mp4)$ - [F]

	<?php
	session_start();
	
	$hash = $_GET['h'];
	$streamname = $_GET['v'];
	$originaltimestamp = $_GET['t'];
	
	header('Content-Description: File Transfer');
	header('Content-type: video/quicktime');
	header("Content-length: " . filesize($streamname));
	header("Expires: 0");
	header("Content-Transfer-Encoding: binary");
	
	$file = fopen($streamname, 'r');
	echo stream_get_contents($file);    
	fclose($file);
	?>

 ---><cfcomponent>
 <cfoutput>
<cffunction name="init" localmode="modern" returntype="any" output="no">
</cffunction>
    
    
    
    
<!--- /z/_com/app/video-library?method=videoprocessform roles="member" --->
<cffunction name="videoprocessform" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var t="";
	var ext="";
	var fileName="";
	var tPath="";
	var qDir="";
	var arrE="";
	var videoPath="";
	var offset="";
	var n2="";
	var arrList="";
	var currentDir="";
	var videoCount=0;
	var queue_id=0;
	var arrOut=arraynew(1);
	var ts=structnew();
	setting requesttimeout="18000";
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library", true);
	if(structkeyexists(form, 'video_file') EQ false){
		writeoutput('{"arrVideos":[{"success":false,"message":"A video must be uploaded."}]}');
		application.zcore.functions.zabort();
	}
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="queue";
	ts.struct=structnew();
	application.zcore.functions.zcreatedirectory(request.zos.globals.privatehomedir&'zupload/video/');
	ts.struct.queue_original_file=request.zos.globals.privatehomedir&'zupload/video/'&application.zcore.functions.zUploadFile("video_file", request.zos.globals.privatehomedir&'zupload/video/');
	ts.struct.queue_original_file=replace(ts.struct.queue_original_file, request.zos.installPath, "");
	ext=application.zcore.functions.zGetFileExt(ts.struct.queue_original_file);
	if(form.video_width EQ 0 or form.video_height EQ 0 or isnumeric(form.video_width) EQ false or isnumeric(form.video_height) EQ false){
		writeoutput('{"arrVideos":[{"success":false,"message":"You must enter a width and height before uploading the video."}]}');
		application.zcore.functions.zabort();
	}
	if("*.3g2;*.3gp;*.asf;*.asx;*.avi;*.flv;*.mov;*.mp4;*.mpg;*.swf;*.vob;*.wmv;*.divx;*.f4v;*.m2p;*.m4v;*.mkv;*.mpeg;*.ogv;*.webm;*.xvid;" CONTAINS "."&ext&";"){
		ts.struct.site_id=request.zos.globals.id;
		ts.struct.queue_cancelled=0;
		ts.struct.queue_deleted=0;
		ts.struct.queue_progress=0;
		ts.struct.queue_created_datetime=request.zos.mysqlnow;
		ts.struct.queue_updated_datetime=request.zos.mysqlnow;
		ts.struct.queue_file_type="video";
		queue_id=application.zcore.functions.zInsert(ts);
		if(queue_id EQ false){
			writeoutput('{"arrVideos":[{"success":false,"message":"Video failed to save."}]}');
		}
		if(isDefined('request.zsession.user.id')){
			ts.struct.user_id=request.zsession.user.id;
		}
		ts.struct.queue_id=queue_id;
		ts.struct.queue_status=0;
		ts.struct.queue_hash=hash(queue_id&"-"&ts.struct.queue_created_datetime);
		ts.struct.queue_file=queue_id&"-"&ts.struct.queue_hash&".mp4";
		ts.struct.queue_width=form.video_width;
		ts.struct.queue_height=form.video_height; 
		ts.struct.site_id=request.zos.globals.id;
		application.zcore.functions.zUpdate(ts);
		writeoutput('{"arrVideos":[{"success":true,"message":"Video uploaded and queued.","queue_id":"#queue_id#","video_file":"#getfilefrompath(ts.struct.queue_original_file)#","width":#form.video_width#,"height":#form.video_height#}]}');
	}else{
		writeoutput('{"arrVideos":[{"success":false,"message":"Invalid Video File Type."}]}');
	}
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
    
    
<cffunction name="videoencodeprogress" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library");
	local.arrQueue=listtoarray(application.zcore.functions.zescape(form.queue_id_list),",",false);
	local.arrQueue2=arraynew(1);
	local.arrQueue3=arraynew(1);
	local.result="";
	for(local.i=1;local.i LTE arraylen(local.arrQueue);local.i++){
		if(isnumeric(local.arrQueue[local.i])){
			arrayappend(local.arrQueue2, local.arrQueue[local.i]);
		}
	}
	if(arraylen(local.arrQueue2) NEQ 0){
		 db.sql="select * from #db.table("queue", request.zos.zcoreDatasource)# queue 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		queue_deleted = #db.param(0)#  and 
		queue_id IN ("&db.trustedSQL(arraytolist(local.arrQueue2,","))&")";
		local.q=db.execute("q");
		for(local.i=1;local.i LTE local.q.recordcount;local.i++){
			if(fileexists(request.zos.globals.privatehomedir&"zupload/video/"&local.q.queue_file[local.i]&"-00001.jpg")){
				local.previewImage=true;
			}else{
				local.previewImage=false;
			}
			arrayappend(arrQueue3, '{"queue_id":'&local.q.queue_id[local.i]&',"status":'&local.q.queue_status[local.i]&', "errorMessage": "'&jsstringformat(local.q.queue_error[local.i])&'", "percent":'&min(100,local.q.queue_progress[local.i])&',"filename":"'&jsstringformat(local.q.queue_file[local.i])&'","previewImage":#local.previewImage#}');

		}
	}
	writeoutput('{"arrVideos":['&arraytolist(arrQueue3,", ")&']}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
    
<cffunction name="videoencodecancel" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	local.arrQueue=listtoarray(application.zcore.functions.zescape(form.queue_id_list),",",false);
	local.arrQueue2=arraynew(1);
	local.arrQueue3=arraynew(1);
	local.result="";
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library");
	if(arraylen(local.arrQueue) NEQ 0){
			
		for(local.i=1;local.i LTE arraylen(local.arrQueue);local.i++){
			arrayappend(local.arrQueue2, "#db.param(local.arrQueue[local.i])#");
		} 
		db.sql="update #db.table("queue", request.zos.zcoreDatasource)# queue 
		set queue_cancelled=#db.param(1)# ,
		queue_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		queue_deleted = #db.param(0)# and 
		queue_id IN ("&db.trustedSQL(arraytolist(local.arrQueue2,","))&")";
		q=db.execute("q");
	}
	writeoutput('{"success":true}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
    
<cffunction name="videokeepsessionactive" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	writeoutput('{"success":true}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
        
        
        
<cffunction name="saveQueueToVideo" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	var qR=0;
	var q=0;
	local.result="";
	local.ts=structnew();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library", true);
	
	db.sql="select * from #db.table("queue", request.zos.zcoreDatasource)# queue 
	WHERE queue_id = #db.param(form.queue_id)# and 
	queue_deleted = #db.param(0)#  and 
	site_id = #db.param(request.zos.globals.id)#";
	qR=db.execute("qR"); 
	if(qR.recordcount EQ 0){
		writeoutput('{"success":false}');
		header name="x_ajax_id" value="#form.x_ajax_id#";
		application.zcore.functions.zabort();
	}
	for(local.row in qR){
		form.video_seconds_length=local.row.queue_seconds_length;
		form.video_thumb_count=local.row.queue_thumb_count;
		form.video_width=local.row.queue_width;
		form.video_height=local.row.queue_height;
		form.video_file=local.row.queue_file;
		form.video_original_file=local.row.queue_original_file;
		form.video_hash=local.row.queue_hash;
		form.video_title=getFileFromPath(local.row.queue_original_file);
		form.video_queue_id=local.row.queue_id;
		form.video_datetime=request.zos.mysqlnow;
		form.site_id=request.zos.globals.id;
		local.ts.table="video";
		local.ts.struct=form;
		local.ts.datasource=request.zos.zcoreDatasource;
		local.video_id=application.zcore.functions.zInsert(local.ts);
		if(local.video_id EQ false){
			writeoutput('{"success":false}');
			header name="x_ajax_id" value="#form.x_ajax_id#";
			application.zcore.functions.zabort();
		}
	}
	db.sql="update #db.table("queue", request.zos.zcoreDatasource)#  SET
	queue_deleted = #db.param(1)#, 
	queue_updated_datetime = #db.param(request.zos.mysqlnow)#
	WHERE queue_id = #db.param(local.row.queue_id)# and 
	queue_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	q=db.execute("q");
	writeoutput('{"success":true,"video_id":#local.video_id#,"queue_id":#form.queue_id#, "video_width":#form.video_width#, "video_height":#form.video_height#}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
    
    
    
<cffunction name="deleteVideo" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	
	var qd=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library", true);
	db.sql="select * from #db.table("video", request.zos.zcoreDatasource)# video 
	WHERE video_id = #db.param(form.video_id)# and 
	video_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	local.q=db.execute("q"); 
	if(local.q.recordcount EQ 0){
		writeoutput('{"success":true,"video_id":"#jsstringformat(form.video_id)#","libraryId":"#jsstringformat(form.libraryId)#"}');
		header name="x_ajax_id" value="#form.x_ajax_id#";
		application.zcore.functions.zabort();
	}else{
		try{
			directory action="list" directory="#request.zos.globals.privatehomedir#zupload/video/" filter="#local.q.video_file[1]#-*.jpg" name="qd";
			for(local.row in qd){
				file action="delete" file="#request.zos.globals.privatehomedir#zupload/video/#local.row.name#";
			}
			if(fileexists("#request.zos.globals.privatehomedir#zupload/video/#local.q.video_file[1]#")){
				file action="delete" file="#request.zos.globals.privatehomedir#zupload/video/#local.q.video_file[1]#";
			}
			if(fileexists(request.zos.installPath&local.q.video_original_file[1])){
				application.zcore.functions.zdeletefile(request.zos.installPath&local.q.video_original_file[1]);
			}
		}catch(any local.e){
			
		}
	}
	db.sql="delete from #db.table("video", request.zos.zcoreDatasource)#  
	WHERE video_id = #db.param(form.video_id)# and 
	video_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	writeoutput('{"success":true,"video_id":"#jsstringformat(form.video_id)#","libraryId":"#jsstringformat(form.libraryId)#"}');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
    
    
<!--- /z/_com/app/video-library?method=videoform --->
<cffunction name="videoform" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	var qVideos=0;
	
	var theMeta=0;
	var vname=0;
	var embedCode=0;
	var ts=0;
	var qF=0;
	application.zcore.functions.zSetPageHelpId("2.8");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Video Library");

	var db=request.zos.queryObject;
	request.zos.inMemberArea=true;
	application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
	
	application.zcore.functions.zRequireJquery();
	application.zcore.functions.zRequireJqueryUI();
	
	application.zcore.template.setTag("title","Video Library");
	</cfscript>
	<cfsavecontent variable="theMeta">
	<script>
	/* <![CDATA[ */
	var zVideoJSDomain="#request.zos.currentHostName#";
	// this could be done with zGetCookie 
	
	zArrDeferredFunctions.push(function(){
		//setupSWFUpload(); 
		setInterval(keepSessionActive,5000);
		if(debugVideoLibrary){
			document.getElementById("forvideodata").style.display="block";
		}
     });
	
	/* ]]> */
	</script>
	#application.zcore.skin.includeJS("/z/javascript/flowplayer/flowplayer-3.2.8.min.js", "", 1)&application.zcore.skin.includeJS("/z/javascript/flowplayer/ipad-plugin.js", "", 2)#
	
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("meta",theMeta);
	</cfscript>
	<cfif request.zos.isdeveloper>
		<p>Note: upload videos is only enabled for developers now.</p>
		<h2>Upload Videos</h2> 
		<p>Note: If your video upload takes more then 5 hours to upload, it may fail to upload. Please contact the webmaster if this happens.</p>
		
		<form id="uploadForm1" action="" enctype="multipart/form-data" method="post">
			<table class="table-list">
				<tr><td>Width:</td>
				<td><input name="video_width" id="video_width" value="#request.zos.globals.maximagewidth#" /></td>
			</tr><tr>
				<td>Height:</td>
				<td><input name="video_height" id="video_height" value="#round(request.zos.globals.maximagewidth*0.5625)#" /></td>
			</tr><tr>
				<td>Video:</td>
				<td><input name="video_file" id="fileUpload1" accept=".3g2, .3gp, .asf, .asx, .avi, .flv, .mov, .mp4, .mpg, .swf, .vob, .wmv, .divx, .f4v, .m2p, .m4v, .mkv, .mpeg, .ogv, .webm, .xvid" type="file" /></td>
			</tr><tr>
				<td>&nbsp;</td>
				<td><input type="button" id="uploadButton1" value="Upload" class="z-manager-search-button" /> 
				<input type="button" name="cancel1" id="cancelButton" class="z-manager-search-button" value="Cancel" onclick="window.location.href=window.location.href; " /></td>
			</tr><tr>
				<td>&nbsp;</td>
				<td><progress id="progressBar1" style="display:none;" value="0" max="100"></progress></td></tr>
			</table>
		</form>  
	</cfif>
	<h2>Video Library</h2>
	<p>Please use <a href="http://youtube.com" target="_blank">youtube.com</a> or <a href="http://vimeo.com" target="_blank">vimeo.com</a> to host videos in the future. If you have special requirements and need to host the video on this web site, send the web developer an email.</p>
<!--- 

	<form id="form1" action="#request.cgi_script_name#?method=videoform" enctype="multipart/form-data" method="post">
	Width: <input name="video_width" id="video_width" value="#request.zos.globals.maximagewidth#" /> Height: <input name="video_height" id="video_height" value="#round(request.zos.globals.maximagewidth*0.5625)#" /> <input type="button" name="submit192" value="Update Size" onclick="cancelEncoding();swfu.cancelQueue(); swfu.destroy(); setupSWFUpload();" style="cursor:pointer;" /> | Note: Changing the video size will cancel any uploads in progress.<br /><br />
	Current Encoding Resolution: <span id="encodingRes"></span><br /><br />
					<div class="swfupload-fieldset swfupload-flash" id="fsUploadProgress" style="display:none;">
			<span class="swfupload-legend">Upload Queue</span>
			</div>
		<div id="divStatus" style="display:none;">0 Files Uploaded</div>
				<span id="spanButtonPlaceHolder2"><span id="spanButtonPlaceHolder"></span></span>
				<input id="swfupload_btnCancel" type="button" value="Cancel All Uploads" onclick=" cancelEncoding();swfu.cancelQueue();" style="cursor:pointer; margin-left: 5px; padding:7px; font-size: 11px; height: 28px;" />
	</form></td>
	</tr>
	</table> --->
	<cfsavecontent variable="theMETA">
	<style>
	/* <![CDATA[ */ 

	.videoLibraryThumbnails{list-style:none;margin: 0px;
	padding: 0px;
	margin-top: 20px;}
	.videoLibraryThumbnails li{ float:left; width:100%; margin-bottom:20px;} /* ]]> */
	</style>
	<script>
	/* <![CDATA[ */ 

	function progressHandlingFunction(e){
	    if(e.lengthComputable){
	        $('##progressBar1').attr({value:e.loaded,max:e.total});
	    }
	}
	function beforeSendHandler (e){
		var ext = $('##fileUpload1').val().split('.').pop().toLowerCase();
		if($.inArray(ext, ['3g2', '3gp', 'asf', 'asx', 'avi', 'flv', 'mov', 'mp4', 'mpg', 'swf', 'vob', 'wmv', 'divx', 'f4v', 'm2p', 'm4v', 'mkv', 'mpeg', 'ogv', 'webm', 'xvid']) == -1) {
		    alert("The file extension, \""+ext+"\", is not supported.\nPlease use a web ready video format.");
		    return false;
		}
		//currentVideoId=myUploadStart2();
		$("##uploadButton1").hide();
		$("##progressBar1").show();
	}
	var currentVideoId=0;
	function resetUploadForm(){
		$("##uploadButton1").show();
		$("##progressBar1").hide();
	}
	function completeHandler(e){
		// reload page
		resetUploadForm();
		window.location.href=window.location.href;
		return;
		myUploadSuccess({}, e);
	}
	function errorHandler(e){
		// reload page
		alert("Failed to upload video");
		if(typeof console != "undefined"){
			console.log(e);
		}
		resetUploadForm();
	}
	zArrDeferredFunctions.push(function(){
		$('##fileUpload1').change(function(){
			var file = this.files[0];
			var name = file.name;
			var size = file.size;
			var type = file.type;
		});

	    var xhr, provider;

	    xhr = jQuery.ajaxSettings.xhr();
	    if (xhr.upload) {
			xhr.upload.addEventListener('progress',progressHandlingFunction, false); 
	    }   
	    provider = function () {
	        return xhr;
	    }; 

		$('##uploadButton1').click(function(){
			var formData = new FormData($('##uploadForm1')[0]);
			$.ajax({
				url: "/z/_com/app/video-library?method=videoprocessform&zFPE=1", 
				type: 'POST',
				xhr: provider,
				//Ajax events
				beforeSend: beforeSendHandler,
				success: completeHandler,
				error: errorHandler,
				// Form data
				data: formData,
				//Options to tell jQuery not to process data or worry about content-type.
				cache: false,
				contentType: false,
				processData: false
			});
		});
	});
	/* ]]> */
	</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.prependTag("meta",theMETA);
	</cfscript>
	<ul id="sortable" class="videoLibraryThumbnails"></ul>

	<cfscript>
	db.sql="SELECT * FROM #db.table("queue", request.zos.zcoreDatasource)# queue 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	queue_deleted = #db.param(0)# ";
	qF=db.execute("qF");
	</cfscript>
	<cfloop query="qF"> 
	<script>
		/* <![CDATA[ */
		function zInitVideoLibrary#qF.currentrow#(){
			var t=new Object();
			<cfscript>
			vname=right(qF.queue_original_file, find("/",reverse(qF.queue_original_file))-1);
			</cfscript>
			
			t.name="#jsstringformat(vname)#";
			t.id="queueexisting#qF.currentrow#";
			var d=document.getElementById("sortable");
			t.NewLI = document.createElement("LI");
			t.NewLI.id='div'+t.id;
			var progressWidth=(#qF.queue_progress#/100)*100;
			var tprogmes="";
			if(#qF.queue_status# == "2"){
				tprogmes='';//There was an error encoding the video, please try again or contact the webmaster for assistance.';
				tprogmes2='';
			}else if(#qF.queue_progress# == 100){
				tprogmes='<cfif fileexists(request.zos.globals.privatehomedir&'zupload/video/#qF.queue_file#-00001.jpg')><img src="/zupload/video/#qF.queue_file#-00001.jpg" width="100" alt="Video" /><cfelse>Complete - Image Preview Not Available</cfif>';
				tprogmes2='';
			}else{
				tprogmes2='Encoding | Progress: #qF.queue_progress#% | Seconds remaining: Calculating';
			}
			
			t.NewLI.innerHTML = '<div id="divprogress'+t.id+'" style="width:110px; float:left;">'+tprogmes+'<\/div><div id="divprogressname'+t.id+'" class="videodivclass" style="width:80%; float:left;">'+t.name+'<br /><span  id="divprogress2_'+t.id+'">'+tprogmes2+'</span><\/div><div id="divvideoerror'+t.id+'" style="width:80%; float:left;"></div><div id="divprogressbar'+t.id+'" style="border:1px solid ##999; width:100px; float:left; height:10px;"><div id="divprogressbg'+t.id+'" style="background-color:##EEE; width:100px; height:10px;"><\/div>	<div id="divprogressbg2'+t.id+'" style="background-color:##090; margin-top:-5px; width:'+progressWidth+'px; height:5px;"><\/div><\/div>		';
			//t.width=#qF.queue_width#;
			//t.height=#qF.queue_height#;
			t.queue_id=#qF.queue_id#;
			t.startUploadDate=new Date();
			d.appendChild(t.NewLI);
			t.div=document.getElementById('div'+t.id);
			t.divProgressName=document.getElementById('divprogressname'+t.id);
			t.divProgress=document.getElementById('divprogress'+t.id);
			t.divProgressBar=document.getElementById('divprogressbar'+t.id);
			t.divProgressBg=document.getElementById('divprogressbg'+t.id);
			t.divProgressBg2=document.getElementById('divprogressbg2'+t.id);
			if(#qF.queue_status# == "2"){
				t.divProgressBar.style.display='none'; 
			}
			t.startEncodeDate=new Date();
			arrProgressVideo.push(#qF.queue_id#);
			arrQueueVideoMap[#qF.queue_id#]=t.id;
			arrVideoLibrary[t.id]=t;
			arrCurVideo.push(t.id);
			
			<cfif qF.currentrow EQ qF.recordcount>
			zVideoLibraryIntervalId=setInterval('zAjaxEncodeProgress();',1000);
			</cfif>
		}
		
		zArrDeferredFunctions.push(zInitVideoLibrary#qF.currentrow#);
		 /* ]]> */
		</script>
	</cfloop>

	<cfscript>
	db.sql="SELECT * FROM #db.table("video", request.zos.zcoreDatasource)# video 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	video_deleted = #db.param(0)#
	ORDER BY video_id DESC ";
	qF=db.execute("qF");
	</cfscript>
	<script>
	/* <![CDATA[ */ 
	var arrVideoLibraryComplete={};
	 /* ]]> */
	 </script>
	<cfloop query="qF"> 
	<script>
		/* <![CDATA[ */
		function zInitVideoLibrary2_#qF.currentrow#(){
			var t=new Object();
			<cfscript>
			vname=right(qF.video_original_file, find("/",reverse(qF.video_original_file))-1);
			</cfscript>
			
			t.name="#jsstringformat(vname)#";
			t.id="queuecomplete#qF.currentrow#";
			var d=document.getElementById("sortable");
			t.NewLI = document.createElement("LI");
			t.NewLI.id='div'+t.id;
			tprogmes='<cfif fileexists(request.zos.globals.privatehomedir&'zupload/video/#qF.video_file#-00001.jpg')><img src="/zupload/video/#qF.video_file#-00001.jpg" width="100" alt="Video" /><cfelse>Complete - Image Preview Not Available</cfif>';
			
			
			t.NewLI.innerHTML = '<div id="divprogress'+t.id+'" style="width:110px; float:left;">'+tprogmes+'<\/div> <div id="divprogressname'+t.id+'" class="videodivclass" style="width:80%; float:left;padding-top:5px;">'+t.name+' | <a href="##" onclick="showEmbedOptions(\'queuecomplete#qF.currentrow#\'); return false;">Embed</a> | <a href="##" onclick="zDeleteVideo(\'queuecomplete#qF.currentrow#\'); return false;">Delete</a><br />Uploaded on #dateformat(qF.video_datetime, "m/d/yy")# at #timeformat(qF.video_datetime, "h:mm tt")#<\/div>';
			t.videoFile='/zupload/video/#qF.video_file#';
			<cfif fileexists(request.zos.globals.privatehomedir&'zupload/video/#qF.video_file#-00001.jpg')>
				t.posterImage='/zupload/video/#qF.video_file#-00001.jpg';
			<cfelse>
				t.posterImage=false;
			</cfif>
			t.width=#qF.video_width#;
			t.video_id=#qF.video_id#;
			t.height=#qF.video_height#; 
			d.appendChild(t.NewLI);
			t.div=document.getElementById('div'+t.id);
			t.divProgressName=document.getElementById('divprogressname'+t.id);
			t.divProgress=document.getElementById('divprogress'+t.id);
			t.divProgressBg=document.getElementById('divprogressbg'+t.id);
			t.divProgressBg2=document.getElementById('divprogressbg2'+t.id);
			t.startEncodeDate=new Date();
			arrVideoLibraryComplete[t.id]=t;
		}
		zArrDeferredFunctions.push(zInitVideoLibrary2_#qF.currentrow#);
		 /* ]]> */
		</script>
	</cfloop>
	<cfsavecontent variable="embedCode">
		<form action="" method="post" onSubmit="generateEmbedCode();">
		<h2>Embed Options</h2>
		
		<input type="hidden" name="video_embed_id" id="video_embed_id" value="" />
		<table style="border-spacing:0px; padding:5px;">
		<tr><td>Name:</td><td><div id="embedMenuDivTitle"></div></td></tr>
		<tr><td>
		Width:</td><td> <input type="text" name="video_embed_width" id="video_embed_width" value="" />
		</td></tr>
		<tr><td>
		Height:</td><td> <input type="text" name="video_embed_height" id="video_embed_height" value="" />
		</td></tr>
		<tr><td>
		Autoplay:</td><td><cfscript>
			form.video_embed_autoplay=application.zcore.functions.zso(form, 'video_embed_autoplay',true);
			</cfscript>
			<input type="radio" name="video_embed_autoplay" id="video_embed_autoplay1" onclick="var s=this; setTimeout(function(){if(!s.checked){s.checked=true;}else{ this.checked=false;} }, 10);" value="1" /> <label for="video_embed_autoplay1">Yes</label> 
			<input type="radio" name="video_embed_autoplay" id="video_embed_autoplay2" onclick="var s=this; setTimeout(function(){if(!s.checked){s.checked=true;}else{ this.checked=false;} }, 10);" value="0" checked="checked" /> <label for="video_embed_autoplay2">No</label> 
		</td></tr>
		<tr><td>
		Viewing Method:</td><td> <cfscript>
			form.video_embed_viewing_method=application.zcore.functions.zso(form, 'video_embed_viewing_method',true);
		ts = StructNew();
		ts.name = "video_embed_viewing_method";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Play In Place";
		ts.listValues="0";
		//ts.listLabels="Lightbox Popup|Play In Place";
		//ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
			</cfscript>
		</td></tr>
		<tr><td>&nbsp;</td><td><input type="button" name="submit1" value="Generate Embed Code" onclick="generateEmbedCode();" style="cursor:pointer;" /> <input type="button" name="cancel1" value="Cancel"  onclick="zCloseModal();" style="cursor:pointer;" />
		</td></tr>
		</table>
		</form>
		
		<a id="jumpembed"></a>
		<div id="embedCodeTr" style="display:none; clear:both; width:100%;">
		<h2>HTML Source Code</h2>
		<p>You can copy and paste this code into the HTML source code on other pages of the web site.</p>
		<textarea name="embedTextarea" id="embedTextarea" cols="100" rows="10" onClick="this.select();"></textarea>
		<h2>The video will appear like this:</h2>
		<div id="embedVideoDiv"></div>
		<div style="width:100%; float:left;">&nbsp;</div>
		</div>
		
	</cfsavecontent>
	<script>
	/* <![CDATA[ */
	var embedCode="#replace(jsstringformat(embedCode),"</","<\/","all")#";
	/* ]]> */
	</script>
	<br style="clear:both;" />
	<textarea name="forvideodata" id="forvideodata" style="display:none; width:800px; height:400px;"></textarea><br /><br />

</cffunction>
 </cfoutput>
</cfcomponent>