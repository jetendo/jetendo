<?php
ini_set("memory_limit","256M");
function processImage($filesource, $filedestination){
	global $debug, $testserver;
	try{
	$source = @imagecreatefromjpeg($filesource);
	}catch(Exception $e){
		if(strpos($e->getMessage(), "starts with 0x42 0x4d") !== FALSE){
			try{
				$source=imagecreatefrombmp($filesource);
			}catch(Exception $e2){
				echo "imagecreatefrombmp() failed.".$e2->getMessage();
				return false;
			}
		}else{
			$r=rename($filesource, $filedestination);
			if($r===FALSE){
				return false;
			}else{
				if(!$testserver){
					//chown($filedestination, "sambauser1");
					chmod($filedestination, 0777);
				}
				return true;
			}
			//echo "imagecreatefromjpeg() failed.";
			//return false;
		}
	}
	$width=@imagesx($source);
	$height=@imagesy($source);
	
	if($source===FALSE || $width === FALSE ){
		$r=rename($filesource, $filedestination);
		if($r===FALSE){
			return false;
		}else{
			if(!$testserver){
				//chown($filedestination, "sambauser1");
				chmod($filedestination, 0777);
			}
			return true;
		}
		if($debug) echo "file is invalid\n";
		return false;
	}
	$xCheck1=round($width/5);
	$yCheck1=round($height/5);
	
	if($debug) echo "<br>x & y check 1:".$xCheck1."x".$yCheck1."<br>";
	$xcrop=0;
	$xcrop2=0;
	$ycrop=0;
	$ycrop2=0;

	// get 
	$xmiddle=round($width/2);
	$ymiddle=round($height/2);
	if($debug) echo "<br>top search<br>";
	$inc=3;
	for($i=0;$i<=$height;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $xmiddle, $i);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
		$rgb2=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb3=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."<br />";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
				$rgb=@imagecolorat($source, $xmiddle, $i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."<br />";
					$ycrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "ycrop:".$ycrop."<br>";
	if($debug) echo "<br>left search<br>";
	$inc=3;
	for($i=0;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $i, $ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
		$rgb2=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb3=@imagecolorat($source, $i, min($height,$ymiddle+$yCheck1));
		$rgb4=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb5=@imagecolorat($source, $i,min($height,$ymiddle+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."<br />";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
				$rgb=@imagecolorat($source, $i, $ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."<br />";
					$xcrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "xcrop:".$xcrop."<br>";
	
	if($debug) echo "<br>bottom search<br>";
	$inc=3;
	$i=1;
	/*if($ycrop > 50){
		$i=50;
		$inc=10;	
	}*/
	for(;$i<=$height;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $width-$xmiddle, $height-$i);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
		$rgb2=@imagecolorat($source, max(1,($width-$xmiddle)-$xCheck1), $height-$i);
		$rgb3=@imagecolorat($source, min($width,($width-$xmiddle)+$xCheck1), $height-$i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $height-$i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $height-$i);
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."<br />";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
				$rgb=@imagecolorat($source, $width-$xmiddle, $height-$i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."<br />";
					$ycrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "ycrop2:".$ycrop2."<br>";
	
	if($debug) echo "<br>right search<br>";
	$inc=3;
	for($i=1;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
		$rgb2=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb3=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		$rgb4=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb5=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."<br />";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b<br />";
				$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."<br />";
					$xcrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "xcrop2:".$xcrop2."<br>";
	if($debug) echo "Crop coordinates: left:".$xcrop." top:".$ycrop." right:".$xcrop2." bottom:".$ycrop2."<br />";
	
	
	$originalheight=$height;
	$originalwidth=$width;
	if($debug) echo "original size:".$width."x".$height."<br />";
	$width=$width-$xcrop-$xcrop2;
	$height=$height-$ycrop-$ycrop2;
	if($height < 10 || $width < 10){
		// prevent mistakes
		if(abs($xcrop-$xcrop2) > 50){
			$xcrop=min($xcrop, $xcrop2);
		}else{
			$xcrop=max($xcrop, $xcrop2);
		}
		if(abs($ycrop-$ycrop2) > 50){
			$ycrop=min($ycrop, $ycrop2);
		}else{
			$ycrop=max($ycrop, $ycrop2);
		}
		$width=($originalwidth-($xcrop*2));
		$height=($originalheight-($ycrop*2));
		if($width < 10 || $height < 10){
			// don't bother cropping this file - it's not going to work well
			$temp=".".rand(1,100000);
			
			if(file_exists($filedestination)){
				unlink($filedestination);
			}
			imagejpeg($source, $filedestination.$temp,80);
			$rpos=strrpos($filedestination, "/")+1;
			$fname=substr($filedestination, $rpos);
			$md5name=md5($fname);
			$fpath=substr($filedestination, 0, $rpos).substr($md5name,0,2)."/".substr($md5name,2,1)."/";
			if(!is_dir($fpath)){
				@mkdir($fpath, 0777, true);
			}
			if($debug) echo "new path:".$filedestination.$temp." to ".$fpath.$fname."<br>";
			rename($filedestination.$temp, $fpath.$fname);
			if(!$testserver){
				//chown($fpath.$fname, "sambauser1");
				chmod($fpath.$fname, 0777);
			}
			//rename($filedestination.$temp, $filedestination);
			return true;	
		}
			
	}
	if($debug) echo "cropped original size:".$width."x".$height."<br />";
		
	$newImage= imagecreatetruecolor($width, $height);
	
	imagecopy ( $newImage , $source, 0,0, $xcrop, $ycrop, $width , $height );
	
	$temp=".".rand(1,100000);
	if(file_exists($filedestination)){
		@unlink($filedestination);
	}
	if($debug) echo "output to destination:".$filedestination."<br />";
	imagejpeg($newImage, $filedestination.$temp,80);
	$r=rename($filedestination.$temp, $filedestination);
	if($r===FALSE){
		return false;
	}else{
		if(!$testserver){
			//chown($filedestination, "sambauser1");
			chmod($filedestination, 0777);
		}
		return true;
	}
}
if(strpos($_SERVER['HTTP_HOST'], ".".get_cfg_var("jetendo_test_domain")) !== FALSE){
	$testserver=true;
}else{
	$testserver=false;
}
$apache=false;
if(isset($_SERVER['SERVER_SOFTWARE'])){
	if(str_replace("Apache","",$_SERVER['SERVER_SOFTWARE']) != $_SERVER['SERVER_SOFTWARE']){
		$apache=true;
	}
}

function zXSendFile($p){
	global $apache;
	if(isset($_GET['my444'])){
		echo $p;
		exit;	
	}
	header('Content-Type: image/jpeg');
	if($apache){
		header("X-Sendfile: ".$p);
	}else{
		header("X-Accel-Redirect: ".$p);
	}	
	exit;
}

header('Cache-Control: max-age='.(60*60*8));
//echo "serversoftware:".$_SERVER['SERVER_SOFTWARE'].":".$apache.":<br>";
function z404(){
	global $apache, $debug;
	if(!isset($debug) || !$debug){
		if($apache){
			zXSendFile(get_cfg_var("jetendo_root_path")."public/a/listing/images/image-not-available.jpg");
		}else{
			zXSendFile("/z/a/listing/images/image-not-available.jpg");
		}
		exit;
	}else{
		//header("HTTP/1.0 404 Not Found");
		echo "<h1>404 Not Found</h1>";
		exit;	
	}
}

if(!isset($_COOKIE['zenable']) && !isset($_COOKIE['ZENABLE'])){
	echo "<h1>404 Not Found</h1>";
	exit;	
}  
date_default_timezone_set('America/New_York');
function microtime_float()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}

$time_start = microtime_float();
// File and new size
$debug=false;
if(isset($_GET['d'])){
	$debug=$_GET['d'];
}
if(!isset($_GET['f']) || !isset($_GET['w']) || !isset($_GET['h']) || !isset($_GET['m'])){
	if($debug){
		if(!isset($_GET['f']) && !isset($_GET['p'])){
			echo "f is required";
		}
		if(!isset($_GET['w'])){
			echo "w is required";
		}
		if(!isset($_GET['h'])){
			echo "h is required";
		}
		if(!isset($_GET['m'])){
			echo "m is required";
		}
		exit;	
	}
	z404();
}


/*
if(isset($_GET['m']) == "7"){
	var_dump($_GET);
	exit;	
}*/
if($debug) echo "<h1>Thumbnail generator that removes white margins in MLS listing photos</h1><p>Scroll to the bottom to see the images.</p><h2>Debugging Output</h2>";
$serverRootPath=get_cfg_var("jetendo_share_path")."mls-images/";
$newwidth=$_GET['w'];//230;
$newheight=$_GET['h'];//230;
if(isset($_GET['a']) && $_GET['a']=='1'){
	$autocrop=1;//true;
	$_GET['a']=1;
}else{
	$autocrop=0;
	$_GET['a']=0;
}
$photourl="";
if(isset($_GET['p']) && $_GET['p'] != "" && $_GET['p'] != "0"){
	$photourl=$_GET['p'];
	if(preg_match ("/image-not-available/", $photourl)==1){
		z404();
		exit;
	}
}else{
	$_GET['p']="";
} 
$h=md5($_GET['m']."-".$_GET['f']);
if(!is_numeric($_GET['m']) || !is_dir($serverRootPath.$_GET['m']."/")){
	z404();
	exit;
}
$filename=$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1)."/".$_GET['m']."-".$_GET['f'];
if($debug) echo "new path: ".$serverRootPath.$filename."<br />";
if(!file_exists($serverRootPath.$filename)){
	if($debug) echo "fail<br />";
	$h=md5($_GET['f']);
	$filename=$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1)."/".$_GET['f'];// /4/'resizetest/1.jpg';
	if($debug) echo "old path: ".$serverRootPath.$filename." | exists: ".file_exists($serverRootPath.$filename)."<br />";
}
$f2=str_replace("/../","",str_replace("/./","",$filename));
if($f2 != $filename){
	if($debug){
		echo $serverRootPath.$filename." security violation - illegal path.";
		exit;	
	}
	z404();	
}
$dir=dirname($serverRootPath.$filename);
@mkdir($dir, 0770, true);

$ext=substr($filename, strlen($filename)-5, 5);
$filenamenoext=substr($filename, 0,strlen($filename)-5);
if($debug) echo "filenamenoext: ".$filenamenoext." | ext: ".$ext."<br />";
// substr($filename, strlen($filename)-4, 4) != ".jpg" && 
if($ext != ".jpeg"){
	if($debug){
		echo $serverRootPath.$filename." is not a jpg file.";
		exit;	
	}
	z404();	
}
	$newpath=get_cfg_var("jetendo_share_path").'mls-images-temp/'.date("Y").'-'.date("m")."-".date("d").'/'.$newwidth.'x'.$newheight.'/'.$autocrop.'/';
	
	if(!is_dir($serverRootPath.'/'.$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1))){
		@mkdir($serverRootPath.'/'.$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1), 0777, true);
	}
	if(!is_dir($newpath.$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1))){
		@mkdir($newpath.$_GET['m']."/".substr($h,0,2)."/".substr($h, 2, 1), 0777, true);
	}
	$displaypath="/z/index.php?method=size&w=".urlencode($_GET['w'])."&h=".urlencode($_GET['h'])."&p=".urlencode($_GET['p'])."&m=".$_GET['m']."&f=".urlencode($_GET['f'])."&a=".urlencode($_GET['a']);
	$outputpath=$newpath.$filenamenoext.'.jpeg';
	if($debug) echo "displaypath:".$displaypath."<br>";
	if($debug) echo "outputpath:".$outputpath."<br>";
	if($debug) echo("first outputpath:".$outputpath."<br>");
$imageFound2=false;
if(file_exists($outputpath)){
	$imageFound2=true;
	if(filesize($outputpath) == 0){
		@unlink($outputpath);	
		$imageFound2=false;
	}
}
	if($_GET['w']=='10000' && $_GET['h']=='10000'){
		$outputpath=$serverRootPath.$filename;
	}
	if($debug) echo "outputpath:".$outputpath."<br>";
	//exit;
	// set it up here
//}
	if($debug) echo("second outputpath:".$outputpath."<br>");

$imageFound=true;
if(!file_exists($serverRootPath.$filename)){
	$imageFound=false;
	if($photourl == ""){
		if($debug){
			echo $serverRootPath.$filename." doesn't exist.";
			exit;	
		}
		z404();	
	}
}else{
	if(filesize($serverRootPath.$filename) == 0){
		//@unlink($serverRootPath.$filename);	
		$imageFound=false;
	}
}
//$imageFound=false;
try {
	if($photourl != ""){
		$yesterday=mktime(0, 0, 0, date("m"),date("d")-1,date("Y"));
		if($imageFound){
			$m1233=@filemtime($serverRootPath.$filename);
			if($m1233 < 1341339357){
				$imageFound=false;	
			}
		}
		if(!$imageFound || !$imageFound2 || @$m1233 < $yesterday || isset($_GET['d'])){
			if(strpos($photourl, "image-not-") !== FALSE){
				if($debug){
					echo "doesn't exist.1";
					exit;	
				}
				z404();	
			}
			if($debug) echo 'Downloading photourl:'.$photourl.'<br />';
			if(!is_dir($serverRootPath.'/'.$_GET['m'])){
				@mkdir($serverRootPath.'/'.$_GET['m']);
			}
			$ch = curl_init();
			if(substr($photourl,0,4) != "http"){
				$p9="http";
				if($_SERVER['SERVER_PORT'] == '443'){
					$p9.="s";
				}
				$photourl=$p9."://".$_SERVER['HTTP_HOST'].$photourl;	
				if($debug) echo 'photourl corrected: '.$photourl.'<br />';
			}else{
				if($debug) echo 'using photourl: '.$photourl.'<br />';
			}
			curl_setopt($ch, CURLOPT_URL, $photourl);
			curl_setopt($ch, CURLOPT_HEADER, FALSE);
			curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
			curl_setopt($ch, CURLOPT_FAILONERROR, TRUE);
			curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
			curl_setopt($ch, CURLOPT_TIMEOUT, 15);
			
			
			$a = curl_exec($ch);
			if($a===FALSE){
				if($debug){
					echo "curl failed2<br />";
					echo "url: ".$photourl."<br />";
					echo curl_error($ch);
					exit;
				}else{
					z404();	
				}
			}else{
				$cer=curl_error($ch);
				if($cer != ""){
					if($debug){
						echo "curl failed2<br />";
						echo $cer;
						exit;
					}else{
						z404();	
					}
				}else{
					if($_GET['m'] == '21' && md5($a)=='50a9952321ed5cd3d164dafacdabe999'){
						if($debug){
							echo "crmls 404 image<br />";
							exit;
						}else{
							z404();
						}
					}
					if($debug) echo "NO DOWNLOAD ERROR<br>";
				}
				$temp=".".rand(1,100000);
				if($_GET['w']=='10000' && $_GET['h']=='10000'){
					// ignore further processing if no resize is needed
					header('Content-type: image/jpeg');
					echo $a;
					exit;
				}
				$r=file_put_contents($serverRootPath.$filename.$temp, $a);
				if($r === FALSE || filesize($serverRootPath.$filename.$temp) == 0){
					if($debug){
						echo "fail:".$serverRootPath.$filename.$temp."<br />";
						echo "failed to write image3<br />";
						exit;
					}else{
						z404();	
					}
				}else{
					processImage($serverRootPath.$filename.$temp, $serverRootPath.$filename);
					//$outputpath=$serverRootPath.$filename;
					//$imageFound=true;

					if(file_exists($serverRootPath.$filename.$temp)){
						@unlink($serverRootPath.$filename.$temp);
					}
					/*$imageFound2=
					if($imageFound2){
						@unlink($serverRootPath.$filename.$temp);
						$imageFound2=false;
					}*/
					//rename($serverRootPath.$filename.$temp, $serverRootPath.$filename);
					//$imageFound2=true;
				}
			}
			curl_close($ch);
		}
	}
	if($debug) echo "current timestamp:".time()."<br>";
 
	if($imageFound2 && $imageFound){
		$outputmtime=filemtime($outputpath);
		if((filemtime($serverRootPath.$filename)) > $outputmtime){
			if($debug){
				echo "Image expired - creating a new version.<br />";
			}
		}else{
			if($debug){
				echo "Already published.<br />Absolute Path:".$outputpath."<br />";
				echo '<img src="'.$displaypath.'" style="border:2px solid #000;" /><br />';
				exit;
			}else{
				//header("HTTP/1.1 301 Moved Permanently"); 
				//header("Location: ".$displaypath); 
				
				if($apache){
					zXSendFile($outputpath);
				}else{
					if($outputpath==$serverRootPath.$filename){
						zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images/","/zretsphotos/", $outputpath));	
					}else{
						zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images-temp/","/zretsphotos-resized/", $outputpath));	
					}
				}
				/*
				header('Content-type: image/jpeg');
				//header("Cache-Control: maxage=".(60*60));
				
				if(!isset($outputmtime)){
					$outputmtime=filemtime($outputpath);
				}
				header('Last-modified: '.gmdate("D, d M Y H:i:s", $outputmtime). " GMT");
				readfile($outputpath);
				*/
				/*header('Content-type: image/jpeg');
				header("Cache-Control: maxage=".(60*60));
				header('Last-modified: '.gmdate("D, d M Y H:i:s", $outputmtime). " GMT");
				readfile($outputpath);*/
				exit;
			}
		}
	}
	// http://photos.neg.ctimls.com/neg/photos/large/7/7/201177a.jpg
	
	//$percent = 0.2;
	
	// Content type
	//header('Content-Type: image/jpeg');
	
	// Get new sizes
	// Load
	$source = @imagecreatefromjpeg($serverRootPath.$filename);
	if($source===FALSE){
		
		if($debug){
			//echo 'file timestamp:'.filemtime($outputpath)."<br />";
			 echo '<h2>Original Photo</h2><p><img src="/zretsphotos/'.$filename.'" style="border:2px solid #000;" /></p>';
			 echo '<h2>Cropped Photo</h2><p><img src="'.$displaypath.'" style="border:2px solid #000;" /></p>';
			$time_end = microtime_float();
			$time = $time_end - $time_start;
			
			echo "$time seconds\n";
				exit;
		}else{
			if($apache){
				zXSendFile($serverRootPath.$filename);
			}else{
				zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images/","/zretsphotos/", $serverRootPath.$filename));	
			}	
		}
	}
	/*$r=getimagesize($serverRootPath.$filename);
	if($source===FALSE){
		//unlink($serverRootPath.$filename);
		z404();
	}else{
		list($width, $height) = $r;
	}*/
	$width=imagesx($source);
	$height=imagesy($source);
	
	if($width < $newwidth && $height < $newheight){
		if($debug){
			echo 'file timestamp:'.filemtime($serverRootPath.$filename)."<br />";
			 echo '<h2>Original Photo</h2><p><img src="/zretsphotos/'.$filename.'" style="border:2px solid #000;" /></p>';
			 echo '<h2>Cropped Photo</h2><p><img src="'.$displaypath.'" style="border:2px solid #000;" /></p>';
			$time_end = microtime_float();
			$time = $time_end - $time_start;
			
			echo "$time seconds\n";
		}else{
	
			if($apache){
				zXSendFile($serverRootPath.$filename);
			}else{
				zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images/","/zretsphotos/", $serverRootPath.$filename));	
			}
		}
		/*
		$outputmtime=filemtime($serverRootPath.$filename);
		header('Last-modified: '.gmdate("D, d M Y H:i:s", $outputmtime). " GMT");
		header('Content-type: image/jpeg');
		readfile($serverRootPath.$filename);
		exit;
		*/
	}

}catch(Exception $e){
	if($debug){
		echo "Failed to load image<br />";
		var_dump($e);
		exit;
	}
	z404();	
}
if(!file_exists($serverRootPath.$filename) || filesize($serverRootPath.$filename) == 0){
				if($debug){
					echo "doesn't exist.5";
					exit;	
				}
	z404();
}

$originalheight=$height;
$originalwidth=$width;


$cwidth=$width;
$cheight=$height;

$xoffset=0;//$xcrop;
$yoffset=0;//$ycrop;
if($width < $newwidth && $height < $newheight){
	$newheight=$height;
	$newwidth=$width;	
}

if(!function_exists("imagecreatefrombmp")){
	function imagecreatefrombmp($filename)
	{
	 //Ouverture du fichier en mode binaire
	   if (! $f1 = fopen($filename,"rb")) return FALSE;

	 //1 : Chargement des ent�tes FICHIER
	   $FILE = unpack("vfile_type/Vfile_size/Vreserved/Vbitmap_offset", fread($f1,14));
	   if ($FILE['file_type'] != 19778) return FALSE;

	 //2 : Chargement des ent�tes BMP
	   $BMP = unpack('Vheader_size/Vwidth/Vheight/vplanes/vbits_per_pixel'.
	                 '/Vcompression/Vsize_bitmap/Vhoriz_resolution'.
	                 '/Vvert_resolution/Vcolors_used/Vcolors_important', fread($f1,40));
	   $BMP['colors'] = pow(2,$BMP['bits_per_pixel']);
	   if ($BMP['size_bitmap'] == 0) $BMP['size_bitmap'] = $FILE['file_size'] - $FILE['bitmap_offset'];
	   $BMP['bytes_per_pixel'] = $BMP['bits_per_pixel']/8;
	   $BMP['bytes_per_pixel2'] = ceil($BMP['bytes_per_pixel']);
	   $BMP['decal'] = ($BMP['width']*$BMP['bytes_per_pixel']/4);
	   $BMP['decal'] -= floor($BMP['width']*$BMP['bytes_per_pixel']/4);
	   $BMP['decal'] = 4-(4*$BMP['decal']);
	   if ($BMP['decal'] == 4) $BMP['decal'] = 0;

	 //3 : Chargement des couleurs de la palette
	   $PALETTE = array();
	   if ($BMP['colors'] < 16777216)
	   {
	    $PALETTE = unpack('V'.$BMP['colors'], fread($f1,$BMP['colors']*4));
	   }

	 //4 : Cr�ation de l'image
	   $IMG = fread($f1,$BMP['size_bitmap']);
	   $VIDE = chr(0);

	   $res = imagecreatetruecolor($BMP['width'],$BMP['height']);
	   $P = 0;
	   $Y = $BMP['height']-1;
	   while ($Y >= 0)
	   {
	    $X=0;
	    while ($X < $BMP['width'])
	    {
	     if ($BMP['bits_per_pixel'] == 24)
	        $COLOR = unpack("V",substr($IMG,$P,3).$VIDE);
	     elseif ($BMP['bits_per_pixel'] == 16)
	     {  
	        $COLOR = unpack("n",substr($IMG,$P,2));
	        $COLOR[1] = $PALETTE[$COLOR[1]+1];
	     }
	     elseif ($BMP['bits_per_pixel'] == 8)
	     {  
	        $COLOR = unpack("n",$VIDE.substr($IMG,$P,1));
	        $COLOR[1] = $PALETTE[$COLOR[1]+1];
	     }
	     elseif ($BMP['bits_per_pixel'] == 4)
	     {
	        $COLOR = unpack("n",$VIDE.substr($IMG,floor($P),1));
	        if (($P*2)%2 == 0) $COLOR[1] = ($COLOR[1] >> 4) ; else $COLOR[1] = ($COLOR[1] & 0x0F);
	        $COLOR[1] = $PALETTE[$COLOR[1]+1];
	     }
	     elseif ($BMP['bits_per_pixel'] == 1)
	     {
	        $COLOR = unpack("n",$VIDE.substr($IMG,floor($P),1));
	        if     (($P*8)%8 == 0) $COLOR[1] =  $COLOR[1]        >>7;
	        elseif (($P*8)%8 == 1) $COLOR[1] = ($COLOR[1] & 0x40)>>6;
	        elseif (($P*8)%8 == 2) $COLOR[1] = ($COLOR[1] & 0x20)>>5;
	        elseif (($P*8)%8 == 3) $COLOR[1] = ($COLOR[1] & 0x10)>>4;
	        elseif (($P*8)%8 == 4) $COLOR[1] = ($COLOR[1] & 0x8)>>3;
	        elseif (($P*8)%8 == 5) $COLOR[1] = ($COLOR[1] & 0x4)>>2;
	        elseif (($P*8)%8 == 6) $COLOR[1] = ($COLOR[1] & 0x2)>>1;
	        elseif (($P*8)%8 == 7) $COLOR[1] = ($COLOR[1] & 0x1);
	        $COLOR[1] = $PALETTE[$COLOR[1]+1];
	     }
	     else
	        return FALSE;
	     imagesetpixel($res,$X,$Y,$COLOR[1]);
	     $X++;
	     $P += $BMP['bytes_per_pixel'];
	    }
	    $Y--;
	    $P+=$BMP['decal'];
	   }

	 //Fermeture du fichier
	   fclose($f1);

	 return $res;
	}
}
if($debug) echo "original resize:".$newwidth."x".$newheight."<br />";

if($autocrop != 1){
	if($debug) echo 'autocrop disabled<br />';

	$ratio=$cwidth/$newwidth;
	$newwidth1=$newwidth;
	$newheight1=round($newheight*$ratio);	
		$newwidth1=$newwidth;
		$newheight1=round($cheight/$ratio);	
	if($newheight1 > $cheight){
		$newwidth1=$newwidth;
		$newheight1=round($cheight/$ratio);	
	}
	if($newheight1 > $newheight){
		$ratio=$newheight/$newheight1;
		$newheight1=$newheight;
		$newwidth1=round($newwidth*$ratio);	
	}
	$newwidth=$newwidth1;
	$newheight=$newheight1;
	
	
}else{
	if($debug) echo 'autocrop enabled<br />';
	// the offset and width / height must be modified to be a smaller box within that when resized fix the newwidth / newheight perfectly
	if($width < $newwidth && $height < $newheight){
		//$newwidth=$width;
		if($debug) echo 'cannot resize<br />';
		//$height=$newheight;
		//$width=$newwidth;
		$xoffset=round(($originalwidth-$width)/2);
		$yoffset=(($originalheight-$height)/2);
	}else{
		//if($width / $height > 4/3){
			// very horizontal	
			// assume fixed height - and cropped left/right.
			
			$ratio=$height/$newheight;
			// the size is greater instead of less
			
			$yextracrop=0;
			$xextracrop=0;
			if($debug) echo "iam1 ratio:".$ratio."<br />";
			$tempwidth=round($ratio*$newwidth);
			if($tempwidth > $newwidth){
			if($debug) echo "iam2<br />";
				$ratio=$width/$newwidth;
				$tempheight=round($ratio*$newheight);
				if($tempheight > $height){
					if($debug) echo "iam4<br />";
					// all sides must be cropped more.
					//$yextracrop=round(($height-$tempheight)/2);
					//$xextracrop=round(($width-$tempwidth)/2);
					//$height=$tempheight;
					$width=$tempwidth;
				}else{
					$height=$tempheight;	
				}
			}else{
			if($debug) echo "iam3<br />";
				$width=$tempwidth;
			}
			// upscale the url $newheight size to the $height
			$xoffset=round(abs($originalwidth-$width)/2)+$xextracrop;
			$yoffset=round(abs($originalheight-$height)/2)+$yextracrop;
		//}
		/*
		if($width < $newwidth){
			$width=$originalwidth;
		}*/
	}
	if($debug) echo "NOT FIX: offset:".$xoffset."x".$yoffset." | before resize source:".$width."x".$height." | final resize values: ".$newwidth."x".$newheight."<br />";
	// this is what is needed for the perfect crop
	/*$width=298;
	$height=220;
	$xoffset=140;
	$yoffset=106;
	$newwidth=222;
	$newheight=165;*/
}


if($debug) echo "original crop in url:".$_GET['w']."x".$_GET['h']."<br />";

$thumb = imagecreatetruecolor($newwidth, $newheight);
if($debug) echo "AFTER FIX: offset:".$xoffset."x".$yoffset." |  before resize source:".$width."x".$height." | final resize values: ".$newwidth."x".$newheight."<br />";
if($debug) echo "x and y offset:".$xoffset."x".$yoffset."<br />";


imagecopyresampled($thumb, $source, 0,0, round($xoffset+3), round($yoffset+3), $newwidth, $newheight, $width-6, $height-6);
//imagecopyresized($thumb, $source, 0, 0, round($xoffset+1), round($yoffset+1), $newwidth, $newheight, $width-3, $height-3);

if($debug){ 
	echo "Output path: ".$outputpath."<br />";
	echo "Display path: ".$displaypath."<br />";
}

// 95 looks good for thumbnail, but large images need to be 80 quality to be smaller.

$rpos=strrpos($outputpath, "/")+1;
$fpath=substr($outputpath, 0, $rpos);
if(isset($_GET['d'])){
	//var_dump(is_dir($fpath));
	//var_dump(mkdir($fpath, 0777, true));
}
if(!is_dir($fpath)){
	@mkdir($fpath, 0777, true);
}

$temp=".".rand(1,100000);
$f=imagejpeg($thumb, $outputpath.$temp,80);
if($f===FALSE){
	$to      = get_cfg_var("jetendo_developer_email_to");
	$subject = 'PHP size.php failed to write image';
	$headers = 'From: '.get_cfg_var("jetendo_developer_email_from") . "\r\n" .
	$message = 'PHP size.php failed to write image: '.$outputpath.$temp;
		'Reply-To: '.get_cfg_var("jetendo_developer_email_from") . "\r\n" .
		'X-Mailer: PHP/' . phpversion();

	mail($to, $subject, $message, $headers);
	z404();
}
@unlink($outputpath);	
rename($outputpath.$temp, $outputpath);
if(!$testserver){
	//chown($outputpath, "sambauser1");
	@chmod($outputpath, 0777);
}
if($debug){
	echo 'file timestamp:'.filemtime($outputpath)."<br />";
	 echo '<h2>Original Photo</h2><p><img src="/zretsphotos/'.$filename.'" style="border:2px solid #000;" /></p>';
	 echo '<h2>Cropped Photo</h2><p><img src="'.$displaypath.'" style="border:2px solid #000;" /></p>';
	$time_end = microtime_float();
	$time = $time_end - $time_start;
	
	echo "$time seconds\n";
}else{
	//echo $outputpath;
//exit;
	//$outputmtime=filemtime($outputpath);
	//header("HTTP/1.1 301 Moved Permanently"); 
	//header("Location: ".$displaypath); 
	
	if($apache){
		zXSendFile($outputpath);
	}else{
		if($outputpath==$serverRootPath.$filename){
			zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images/","/zretsphotos/", $outputpath));	
		}else{
			zXSendFile(str_replace(get_cfg_var("jetendo_share_path")."mls-images-temp/","/zretsphotos-resized/", $outputpath));	
		}
	}
	
	/*
	header('Content-type: image/jpeg');
	//header("Cache-Control: maxage=".(60*60));
	if(!isset($outputmtime)){
		$outputmtime=filemtime($outputpath);
	}
	header('Last-modified: '.gmdate("D, d M Y H:i:s", $outputmtime). " GMT");
	readfile($outputpath);
	exit;
	*/
	//echo $displaypath.' done<br />';
}
?>