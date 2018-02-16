<?php

// force variable to exist, with optional forcing of number data type and default value.
// you'd have to call it like zo(@$fakeVar) to avoid undefined error
function zo($varName, $isNumber=false, $defaultValue=''){
	$tempVar = "";
	if($isNumber){
		if(isset($varName)){
			$tempVar = $varName;
			if(!is_numeric($tempVar)){
				return $tempVar;
			}else{
				if($defaultValue !== ""){
					return $defaultValue;
				}else{
					return 0;
				}
			}
		}else{
			if($defaultValue !== ""){
				return $defaultValue;
			}else{
				return 0;
			}
		}
	}else{
		if($varName){
			return $varName;
		}else{
			return $defaultValue;
		}
	}
}
/*
$realVar='te2st';
$v=zo(@$realVar, false, 'test');
echo $v."<br>";
$v=zo(@$fakeVar, true, '1');
echo $v."<br>";
exit;
*/

// force variable to exist, with optional forcing of number data type and default value.
function zso($obj, $varName, $isNumber=false, $defaultValue=''){
	$tempVar = "";
	if($isNumber){
		if(isset($obj[$varName])){
			$tempVar = $obj[$varName];
			if(!is_numeric($tempVar)){
				return $tempVar;
			}else{
				if($defaultValue !== ""){
					return $defaultValue;
				}else{
					return 0;
				}
			}
		}else{
			if($defaultValue !== ""){
				return $defaultValue;
			}else{
				return 0;
			}
		}
	}else{
		if(isset($obj, $varName)){
			return $obj[$varName];
		}else{
			return $defaultValue;
		}
	}
}

function zEmailErrorAndExit($subject, $message){
	$host=`hostname`;
	$to      = get_cfg_var('jetendo_developer_email_to');
	$subject = $subject.' on '.$host;
	$headers = 'From: ' .get_cfg_var('jetendo_developer_email_from'). "\r\n" .
		'Reply-To: '.get_cfg_var('jetendo_developer_email_from') . "\r\n" .
		'X-Mailer: PHP/' . phpversion();

	mail($to, $subject, $message, $headers);
	echo $subject."\n";
	echo "Execution aborted.";
	exit;
}
function zGetBackupPath(){
	if(zIsTestServer()){
		return get_cfg_var("jetendo_test_backup_path");
	}else{
		return get_cfg_var("jetendo_backup_path");
	}
}

// zEmail("", "")
function zEmail($subject, $message){
	$host=`hostname`;
	$to      = get_cfg_var('jetendo_developer_email_to');
	$subject = $subject.' on '.$host;
	$headers = 'From: ' .get_cfg_var('jetendo_developer_email_from'). "\r\n" .
		'Reply-To: '.get_cfg_var('jetendo_developer_email_from') . "\r\n" .
		'X-Mailer: PHP/' . phpversion();

	mail($to, $subject, $message, $headers);
}
function zCheckSSLCertificateExpiration($curPath){
	$rs=new stdClass();
	$rs->success=true;
	$cmd="/usr/bin/openssl x509 -noout -subject -in ".escapeshellarg($curPath);
	$crtResult=str_replace("\t", "", `$cmd`)."/";
	$cnPos2=strpos($crtResult, "/CN=");
	$cnPosEnd2=strpos($crtResult, "/", $cnPos2+1);
	$commonName="Unknown common name";
	$futureTime=time()-(60*60*24*15); // 15 day notice on SSL Expiration
	if($cnPos2 !== FALSE && $cnPosEnd2 !== FALSE){
		$commonName=substr($crtResult, $cnPos2+4, $cnPosEnd2-($cnPos2+4));
	}
	$cmd="/usr/bin/openssl x509 -in ".escapeshellarg($curPath)." -noout -enddate";
	$out=trim(`$cmd`);
	if($out === FALSE || $out == ""){
		$rs->success=false;
		$rs->errorMessage="Attention required:openssl certificate expiration check failed for ".$commonName." Path: ".$curPath.".";	
		return $rs;
	}else{
		if(strpos($out, "notAfter=") === FALSE){
			$rs->success=false;
			$rs->errorMessage="Unexpected output with OpenSSL certificate expiration date check ".$commonName." Path: ".$curPath." Output:".$out.".";
			return $rs;
		}else{
			$out=str_replace("notAfter=", "", $out);
			echo "SSL Expiration date compare: ".$commonName." | ".$out."\n".$futureTime." > ".strtotime($out)."\n\n";
			if($futureTime > strtotime($out)){
				$rs->success=false;
				$rs->errorMessage="SSL Certificate for ".$commonName."expires on ".$out." Path: ".$curPath;	
				return $rs;
			}
		}
	}
	return $rs;
}
function checkForSSLExpiration($arrError){
	echo "Checking Nginx SSL Certificates: ";
	$mp=get_cfg_var("jetendo_nginx_ssl_path");
	$handle2 = opendir($mp);
	if($handle2 !== FALSE) {
	    while (false !== ($entry = readdir($handle2))) {
			$curPath=$mp.$entry;
			if($entry =="." || $entry ==".." || is_dir($curPath)){
				$mp2=$mp.$entry."/";
				$handle3 = opendir($mp2);
				if($handle3 !== FALSE) {
				    while (false !== ($entry2 = readdir($handle3))) {
						$curPath2=$mp2.$entry2;
						if($entry2 =="." || $entry2 ==".." || is_dir($curPath2)){
							continue;
						}
						if(substr($curPath2, strlen($curPath2)-4, 4) == ".crt"){
							$result=zCheckSSLCertificateExpiration($curPath2);
							if(!$result->success){
								array_push($arrError, $result->errorMessage);
							}
						}

					}
				}

				continue;
			}
			if(substr($curPath, strlen($curPath)-4, 4) == ".crt"){
				$result=zCheckSSLCertificateExpiration($curPath);
				if(!$result->success){
					array_push($arrError, $result->errorMessage);
				}

			}
		}
		closedir($handle2);
	}
	echo "Done\n";
}
function zRemoveEmptyValuesFromArray($arr){
	$arrNew=array();
	for($n=0;$n<count($arr);$n++){
		if($arr[$n] != ""){
			array_push($arrNew, $arr[$n]);
		}
	}
	return $arrNew;
} 
function getRets18ByListingId(){
	global $mlsDataDatasource;
	return array("select rets18_media.rets18_mediasource as id, listing_id as listingid from listing_track, rets18_media WHERE rets18_mediatype='pic' and rets18_media.rets18_tableuid = listing_track_sysid and listing_id IN ('", $mlsDataDatasource);
} 
function getRetsNormalByListingId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE listing_track_sysid as imageid, listing_id as listingid from listing_track where listing_id IN ('", $mlsDataDatasource);
} 
 
function getRets18BySysId(){
	global $mlsDataDatasource;
	return array("select rets18_media.rets18_mediasource as id, listing_id as listingid from listing_track, rets18_media WHERE rets18_mediatype='pic' and rets18_media.rets18_tableuid = listing_track_sysid and listing_track_sysid IN ('", $mlsDataDatasource);
} 
function getRetsNormalBySysId(){
	global $mlsDataDatasource;
	return array("select SQL_NO_CACHE listing_track_sysid as imageid, listing_id as listingid from listing_track where listing_track_sysid IN ('", $mlsDataDatasource);
}
$arrQueryFunction=array();
$arrQueryFunction["12"]="getRetsNormalBySysId";
$arrQueryFunction["16"]="getRetsNormalBySysId";
//$arrQueryFunction["18"]="getRets18SysId";
$arrQueryFunction["20"]="getRetsNormalBySysId";
$arrQueryFunction["22"]="getRetsNormalBySysId";
$arrQueryFunction["24"]="getRetsNormalBySysId";
$arrQueryFunction["25"]="getRetsNormalBySysId";
$arrQueryFunction["29"]="getRetsNormalBySysId";
$arrQueryFunction["30"]="getRetsNormalBySysId";
$arrListingQueryFunction=array();
$arrListingQueryFunction["12"]="getRetsNormalByListingId";
$arrListingQueryFunction["16"]="getRetsNormalByListingId";
//$arrListingQueryFunction["18"]="getRets18SysId";
$arrListingQueryFunction["20"]="getRetsNormalByListingId";
$arrListingQueryFunction["22"]="getRetsNormalByListingId";
$arrListingQueryFunction["24"]="getRetsNormalByListingId";
$arrListingQueryFunction["25"]="getRetsNormalByListingId";
$arrListingQueryFunction["29"]="getRetsNormalByListingId";
$arrListingQueryFunction["30"]="getRetsNormalByListingId";

$retsConnections=array();

function getSysIdByListingId($listingId){
	global $arrListingQueryFunction;
	$arrId=explode("-", $listingId);
	$mls_id=$arrId[0];
	if(isset($arrListingQueryFunction[$mls_id])){
		$mlsDatasource=get_cfg_var("jetendo_datasource");
		$mlsDataDatasource=get_cfg_var("jetendo_datasource");
		$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource"));

		if($cmysql->error != ""){
			echo "Mysql error:".$cmysql."\n";
			exit;
		}
		$arrSQL=$arrListingQueryFunction[$mls_id]();
		$sql=$arrSQL[0].$listingId."')";

		$result=$cmysql->query($sql);
		$r=$cmysql->query($sql, MYSQLI_USE_RESULT);
		if($cmysql->error != ""){ 
			echo "db error:".$cmysql->error."\n";
			return false;
		}
		$id="";
		while($row=$r->fetch_array(MYSQLI_ASSOC)){
			$id=$row["imageid"];
		}
		if($id == ""){
			return false;
		}else{
			return $id;
		}
	}else{
		$a=explode("-", $listingId);
		return $a[1];
	}
}

function getRetsImageType($mls_id){
	if($mls_id == "4"){
		return "HQPhoto";
	}else if($mls_id == "12"){
		return "Photo";
	}else if($mls_id == "16"){
		return "Photo";
	}else if($mls_id == "20"){
		return "LargePhoto";
	}else if($mls_id == "19"){
		return "Photo";
	}else if($mls_id == "22"){
		return "Photo";
	}else if($mls_id == "24"){
		return "HiRes";
	}else if($mls_id == "25"){
		return "LargePhoto";
	}else if($mls_id == "28"){
		return "HQPhoto";
	}else if($mls_id == "30"){
		return "HighRes";
	}else{
		return false;
	}
}

$arrRetsConnections=array();
$configPath=get_cfg_var("jetendo_rets_config_file");
if(!file_exists($configPath)){
	echo "configPath is missing: ".$configPath."\n";
	exit;
}
require_once($configPath);
require_once("phrets.php");
function zDownloadRetsImages($listingId, $sysId, $photoIndex){
	global $arrRetsConnections, $arrRetsConfig;

	$arrId=explode("-", $listingId);
	$mls_id=$arrId[0];


	if(!isset($arrRetsConfig[$mls_id])){
		echo "rets config is missing for mls_id = ".$mls_id."\n";
		return false;
	}
	$arrConfig=$arrRetsConfig[$mls_id];

	$type=getRetsImageType($mls_id);
	if($type === false){
		echo "getRetsImageType returned false for mls_id = ".$mls_id."\n";
		return false;
	} 
	if($photoIndex == 0){
		$photoIndex="*";
	}else{
		$photoIndex--; // decrease because photo index starts at zero.
	}
	if($sysId == "" || $sysId == 0){
		$sysId=getSysIdByListingId($listingId);
		if($sysId === false){
			echo "getSysIdByListingId returned false for listingId = ".$listingId."\n";
			return false;
		}
	}
	if(!isset($arrRetsConnections[$mls_id])){
		$arrRetsConnections[$mls_id] = new phRETS;
		$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";
		//$arrRetsConnections[$mls_id]->SetParam("debug_mode", true);
		//$arrRetsConnections[$mls_id]->SetParam("debug_file", $taskLogPath."retsImageDownloadLog.txt");
		$arrRetsConnections[$mls_id]->AddHeader("RETS-Version", "RETS/1.7.2");
		$arrRetsConnections[$mls_id]->AddHeader("User-Agent", "RETSConnector/1.0");
	}

	if(!$arrRetsConnections[$mls_id]->isLoggedIn()){
		$connect = $arrRetsConnections[$mls_id]->Connect($arrConfig["loginURL"], $arrConfig["username"], $arrConfig["password"]);

		if (!$connect) {
			echo "  + Not connected: mls_id: ".$mls_id." | loginURL: ".$arrConfig["loginURL"]."<br>\n";
			print_r($arrRetsConnections[$mls_id]->Error());
			return false;
		}else{
			echo "Connected to mls_id=".$mls_id."\n";
		}
	}else{
		echo "Trying to re-use existing connection to mls_id=".$mls_id."\n";
	}
	// download binary images, instead of urls because some servers disable url access.
	$photos = $arrRetsConnections[$mls_id]->GetObject("Property", $type, $sysId, $photoIndex, 0); 
	if($photos === false){
		unset($arrRetsConnections[$mls_id]); // force a new login session
		return false;
	}
	$i=0;
	$p=dirname(__FILE__)."/";

	$a=explode("-", $listingId);
	$pid=$a[1];
	$destinationPath=get_cfg_var("jetendo_share_path")."mls-images/";
	foreach ($photos as $arrPhoto) {
		if(!$arrPhoto['Success']){
			continue;
		}
		$i++;
		$fname=$mls_id."-".$pid."-".($arrPhoto['Object-ID']+1).".jpeg";
		$md5name=md5($fname);
		$fpath=$destinationPath.$mls_id."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/";
		if(!is_dir($fpath)){
			mkdir($fpath, 0777, true);
		}
		$filedestination=$fpath.$fname;
		echo "Saving image to: ".$filedestination."\n";
		if(file_exists($filedestination)){
			unlink($filedestination);
		}
		file_put_contents($filedestination.".temp", $arrPhoto['Data']);
		cropWhiteEdgesFromImage($filedestination.".temp", $filedestination);
		
	}
	return true;
}
if(!isset($debug)){
	$debug=false;
}

$lastMessage="";
function cropWhiteEdgesFromImage($filesource, $filedestination){
	global $debug, $lastMessage; 
	$d=getimagesize($filesource);
	if($d===FALSE){
		echo "Deleting invalid image."; 
		@unlink($filesource);
		$lastMessage="Deleting invalid image";
		return false;
	}  
	$source = @imagecreatefromjpeg($filesource);
	if($source===FALSE){ 
		$source=@imagecreatefrombmp($filesource); 
		if($source===FALSE){
			echo "Deleting invalid image.";

			@unlink($filesource);
			$lastMessage="Deleting invalid image";
			return false;
		}
	}
	if($source===FALSE){
		echo "Failed without exception, deleting source image.";
		@unlink($filesource);
		return false;
	}
	$temp=".".rand(1,100000);
	
	
	$width=imagesx($source);
	if($source===FALSE && $width===FALSE){
		// don't bother cropping this file - it's not going to work well
		$temp=".".rand(1,100000);
		// imagejpeg($newImage, $filedestination.$temp,80);
		if($debug) echo "file copied instead of cropped\n";
		
		if(file_exists($filedestination)){
			unlink($filedestination);
		}
		$r=copy($filesource, $filedestination.$temp);
		if($r===FALSE){
			echo "file copied failed\n";
			$lastMessage="file copied failed";
			return false;
		}else{
			$r=moveFile($filedestination.$temp, $filedestination);
			chmod($filedestination, 0777);
			system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
			if(file_exists($filesource)){
				unlink($filesource);
			}
			return true;
		}
	}
	$height=imagesy($source);
	if($width===FALSE){
		$r2=getimagesize($filesource);
		if($r2===FALSE){
			if($debug) echo "invalid image:".$filesource."\n";
			unlink($filesource);
		}
		list($width, $height)=$r2;
		if($debug) echo "fixed width:".$width."x".$height."\n";
	}
	
	$xCheck1=round($width/5);
	$yCheck1=round($height/5);
	
	if($debug) echo "\nx & y check 1:".$xCheck1."x".$yCheck1."\n";
	$xcrop=0;
	$xcrop2=0;
	$ycrop=0;
	$ycrop2=0;

	// get 
	$xmiddle=round($width/2);
	$ymiddle=round($height/2);
	if($debug) echo "\ntop search\n";
	$inc=3;
	for($i=0;$i<=$height;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $xmiddle, $i);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb3=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $i);
		
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $xmiddle, $i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$ycrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "ycrop:".$ycrop."\n";
	if($debug) echo "\nleft search\n";
	$inc=3;
	for($i=0;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $i, $ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb3=@imagecolorat($source, $i, min($height,$ymiddle+$yCheck1));
		$rgb4=@imagecolorat($source, $i, max(1,$ymiddle-$yCheck1));
		$rgb5=@imagecolorat($source, $i,min($height,$ymiddle+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop=$i+6;
			$newi=$i;
			$i=max(0,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $i, $ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$xcrop=$i+6;
					break;
				}
			}
			break;
		}
	}
	
	if($debug) echo "xcrop:".$xcrop."\n";
	
	if($debug) echo "\nbottom search\n";
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
		//if($debug) echo "finding y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, max(1,($width-$xmiddle)-$xCheck1), $height-$i);
		$rgb3=@imagecolorat($source, min($width,($width-$xmiddle)+$xCheck1), $height-$i);
		$rgb4=@imagecolorat($source, max(1,$xmiddle-$xCheck1), $height-$i);
		$rgb5=@imagecolorat($source, min($width,$xmiddle+$xCheck1), $height-$i);
		if($debug) echo "finding y: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$ycrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<$newi;$i++){
				if($debug) echo $i." | refining y: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $width-$xmiddle, $height-$i);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$ycrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "ycrop2:".$ycrop2."\n";
	
	if($debug) echo "\nright search\n";
	$inc=3;
	for($i=1;$i<=$width;$i+=$inc){
		if($i==3) $inc=10;
		$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		//if($debug) echo "finding x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
		$rgb2=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb3=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		$rgb4=@imagecolorat($source, $width-$i, max(1,($height-$ymiddle)-$yCheck1));
		$rgb5=@imagecolorat($source, $width-$i, min($height,($height-$ymiddle)+$yCheck1));
		if($debug) echo "finding x: ".$rgb." | ".$rgb2." | ".$rgb3." | ".$rgb4." | ".$rgb5."\n";
		if(($rgb+$rgb2+$rgb3+$rgb4+$rgb5)/5 < 16400000){
		//if($rgb<16600000 || $rgb2<16600000 || $rgb3<16600000 || $rgb4<16600000 || $rgb5<16600000){
			$xcrop2=$i+6;
			$newi=$i;
			$i=max(1,$i-9);
			for($i;$i<=$newi;$i++){
				if($debug) echo $i." | refining x: ".$rgb." | ".dechex ($rgb)." | red: $r | green: $g | blue: $b\n";
				$rgb=@imagecolorat($source, $width-$i, $height-$ymiddle);
				if($rgb<16600000){
					if($debug) echo "final i:".$i."\n";
					$xcrop2=$i+6;
					break;
				}
			}
			break;
		}
	}
	if($debug) echo "xcrop2:".$xcrop2."\n";
	if($debug) echo "Crop coordinates: left:".$xcrop." top:".$ycrop." right:".$xcrop2." bottom:".$ycrop2."\n";
	
	
	$originalheight=$height;
	$originalwidth=$width;
	if($debug) echo "original size:".$width."x".$height."\n";
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
			
			if($debug) echo "width is wrong:".$width."x".$height."\n";
			if($debug) echo $filedestination.$temp.":".file_exists($filedestination.$temp)."\n";
			
			$r3=imagejpeg($source, $filedestination.$temp,80);
			
			$r=moveFile($filedestination.$temp, $filedestination);
			if($r===FALSE){
				echo "r3:".$r3."\nexists:".file_exists($filedestination.$temp)."\n";
				echo "unable to copy file even without cropping it\n";
				$lastMessage="unable to copy file even without cropping it";
				return false;
			}else{
				chmod($filedestination, 0777);
				system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
				if(file_exists($filesource)){
					unlink($filesource);
				}
				return true;
			}
		}
			
	}
	if($debug) echo "cropped original size:".$width."x".$height."\n";
		
	$newImage= imagecreatetruecolor($width, $height);
	
	imagecopy ( $newImage , $source, 0,0, $xcrop, $ycrop, $width , $height );
	
	imagejpeg($newImage, $filedestination.$temp,80);
	
	$r=moveFile($filedestination.$temp, $filedestination);
	if($r===FALSE){
		$lastMessage="unable to move file";
		return false;
	}else{
		chmod($filedestination, 0777);
		system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
		if(file_exists($filesource)){
			@unlink($filesource);
		}
		return true;
	}
}
function moveFile($source, $destination){
	if(file_exists($destination)){
		@unlink($destination);
	}
	return rename($source, $destination);
}


function installJetendoCronTabs($debug){
	$isTestServer=zIsTestServer();
	$rootCronPath="/var/spool/cron/crontabs/root";
	$scriptsPath=get_cfg_var("jetendo_scripts_path");
	echo("Installing crontab\n");
$crontabs="#every minute
*/1 * * * * /usr/bin/php ".$scriptsPath."newsite.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."execute-commands.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."zqueue/queue.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."zqueue/queue-check-running.php >/dev/null 2>&1
*/1 * * * * /usr/bin/php ".$scriptsPath."cfml-tasks.php >/dev/null 2>&1

# every hour at :00
0 * * * * /usr/bin/php ".$scriptsPath."verify-sites.php >/dev/null 2>&1
";
if(!$isTestServer){
$crontabs.="

#every 5 minutes
0-59/20 * * * * /usr/bin/php ".$scriptsPath."move-mls-images.php > /dev/null 2>&1

# every day at 12:15am
15 0 * * * /usr/bin/perl ".$scriptsPath."rsync_backup.pl >/dev/null 2>&1

# every day at 1:15am
15 1 * * * /usr/bin/php ".$scriptsPath."spf-validation.php >/dev/null 2>&1

# every day at 1:30am
30 1 * * * /usr/bin/php ".$scriptsPath."mysql-backup/backup_dbs.php >/dev/null 2>&1

# every day at 12:20am
20 0 * * * /usr/bin/php ".$scriptsPath."listing-image-cleanup.php > /dev/null 2>&1";
}
	$contents="";
	if(file_exists($rootCronPath)){
		$arr1=explode("\n", file_get_contents($rootCronPath));
		for($i=0;$i<count($arr1);$i++){
			if(trim($arr1[$i]) == "" || substr($arr1[$i], 0, 1) != "#"){
				$arr1=array_slice($arr1, $i);
				break;
			}
		}
		$contents=implode("\n", $arr1);
	}
	$beginString="\n#jetendo-root-crontabs-begin\n";
	$endString="\n#jetendo-root-crontabs-end\n";
	$begin=strpos($contents, $beginString);
	if($begin===FALSE){
		$contents.=$beginString;
		$begin=strpos($contents, $beginString);
	}
	$end=strpos($contents, $endString, $begin);
	if($end===FALSE){
		$contents.=$endString;
		$end=strpos($contents, $endString);
	}
	$fileBeginContents=substr($contents, 0, $begin+strlen($beginString));
	$fileContentsHosts=trim(substr($contents, $begin+strlen($beginString), $end-($begin+strlen($beginString))));
	$fileEndContents=substr($contents, $end);
	
	$newFileContents=str_replace("\r", "", $fileBeginContents.$crontabs.$fileEndContents);
	if(!$debug){
		$fp=fopen($rootCronPath, "w");
		fwrite($fp, $newFileContents);
		fclose($fp);
		chown($rootCronPath, "root");
		chgrp($rootCronPath, "crontab");
		chmod($rootCronPath, 0600);
		// update cron with the new file
		`/usr/bin/crontab /var/spool/cron/crontabs/root`;
	}
	echo("Crontab install complete\n");

}

function checkMySQLPrivileges(){
	$cmysql2=@new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), "mysql");
	if($cmysql2->connect_error != ""){ 
		echo "Connect error: ".$cmysql2->connect_error."\n";
		echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and ".
		"global SUPER privilege to enable restoring triggers.";
		return false;
	}
	$r=$cmysql2->query("SELECT * FROM mysql.user WHERE Super_priv = 'Y' and User = '".get_cfg_var("jetendo_mysql_default_user")."'");
	if($cmysql2->error != ""){ 
		echo "MySQL Error: ".$cmysql2->error."\n";
		echo "The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have access to SELECT on the \"mysql\" database and global SUPER privilege to enable restoring triggers.";
		return false;
	}
	if($r->num_rows == 0){
		echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").". The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have SUPER privilege to enable restoring triggers.";
		return false;
	}
	$db=zGetDatasource();
	// check for global privileges for user
	$r=$cmysql2->query("select * from mysql.user WHERE 
	User = '".$cmysql2->real_escape_string(get_cfg_var("jetendo_mysql_default_user"))."' and 
	Select_priv='Y' and  Insert_priv='Y' and  Update_priv='Y' and  Delete_priv='Y' and  
	Create_priv='Y' and  Drop_priv  ='Y' and  Grant_priv ='Y' and  References_priv       ='Y' and  
	Index_priv ='Y' and  Alter_priv ='Y' and  Create_tmp_table_priv ='Y' and  
	Lock_tables_priv      ='Y' and  Create_view_priv      ='Y' and  Show_view_priv        ='Y' and  
	Create_routine_priv   ='Y' and  Alter_routine_priv    ='Y' and  Execute_priv          ='Y' and  
	Event_priv ='Y' and  Trigger_priv     ='Y' ");
	if($cmysql2->error != ""){ 
		echo "MySQL Error: ".$cmysql2->error."\n";
		echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").".The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have ALL PRIVILEGES GRANTED for database, \"".$db."\" or GLOBAL PRIVILEGES to all databases.";
		return false;
	}
	if($r->num_rows == 0){
		// check db privileges
		$r=$cmysql2->query("select * from mysql.db WHERE 
		Db='".$cmysql2->real_escape_string($db)."' and 
		User = '".$cmysql2->real_escape_string(get_cfg_var("jetendo_mysql_default_user"))."' and 
		Select_priv='Y' and  Insert_priv='Y' and  Update_priv='Y' and  Delete_priv='Y' and  
		Create_priv='Y' and  Drop_priv  ='Y' and  Grant_priv ='Y' and  References_priv       ='Y' and  
		Index_priv ='Y' and  Alter_priv ='Y' and  Create_tmp_table_priv ='Y' and  
		Lock_tables_priv      ='Y' and  Create_view_priv      ='Y' and  Show_view_priv        ='Y' and  
		Create_routine_priv   ='Y' and  Alter_routine_priv    ='Y' and  Execute_priv          ='Y' and  
		Event_priv ='Y' and  Trigger_priv     ='Y' ");
		if($cmysql2->error != ""){ 
			echo "MySQL Error: ".$cmysql2->error."\n";
			echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").".The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have ALL PRIVILEGES GRANTED for database, \"".$db."\" or GLOBAL PRIVILEGES to all databases.";
			return false;
		}
		if($r->num_rows == 0){
			echo "User not found: ".get_cfg_var("jetendo_mysql_default_user").".The mysql user, \"".get_cfg_var("jetendo_mysql_default_user")."\" must have ALL PRIVILEGES GRANTED for database, \"".$db."\" or GLOBAL PRIVILEGES to all databases.";
			return false;
		}
	}
	return true;
}

function zGetSSHConnectCommand($remoteHost, $privateKeyPath, $remotePort){
	$cmd='/usr/bin/ssh -O check -S "/root/.ssh/ctl/%L-%r@%h:%p" -p '.escapeshellarg($remotePort).' '.$remoteHost." 2>&1";
	echo "\n\n\n\n".$cmd."\n";
	$result=`$cmd`;
	echo "Result: ".$result."\n";
	$p=strpos($result, "Master running");
	if($p === FALSE){
		if(file_exists($privateKeyPath)){
			echo "Switching to private key path for ssh connection\n";
			$sshCommand='ssh -p '.escapeshellarg($remotePort).' -i '.escapeshellarg($privateKeyPath);
		}else{
			echo "No private key or ssh connection exists\n";
			return false;
		}
	}else{
		echo "Reusing master ssh connection\n";
		$sshCommand='ssh -p '.escapeshellarg($remotePort).' -o "ControlPath=/root/.ssh/ctl/%L-%r@%h:%p"';
	}
	return $sshCommand;
}

function zGetDatasource(){
	if(zIsTestServer()){
		return get_cfg_var("jetendo_test_datasource");
	}else{
		return get_cfg_var("jetendo_datasource");
	}
}

$host=`hostname`;
$testDomain=get_cfg_var("jetendo_test_domain"); 
if(strpos($host, $testDomain) !== FALSE){
	$isTestServer=true;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_test_server_uses_samba");
}else{
	$isTestServer=false;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_server_uses_samba");
}

function zIsTestServer(){
	global $isTestServer;
	return $isTestServer;
}
function zIsFtpEnabled(){
	$r=`/usr/sbin/service vsftpd status`;
	echo $r;
	if(strpos($r, 'unrecognized') !== FALSE || strpos($r, 'stop') !== FALSE){
		return false;
	}else{
		return true;
	}
}
function zCheckJetendoIniConfig($arrLog){
	$arrVar=array(
		"upload_max_filesize", 
		"max_input_time", 
		"post_max_size", 
		"jetendo_developer_email_from", 
		"jetendo_developer_email_to", 
		"jetendo_test_domain", 
		"jetendo_mysql_default_host", 
		"jetendo_mysql_default_user", 
		"jetendo_mysql_default_password", 
		"jetendo_datasource", 
		"jetendo_test_datasource", 
		"jetendo_test_server_uses_samba", 
		"jetendo_server_uses_samba", 
		"jetendo_admin_domain", 
		"jetendo_test_admin_domain", 
		"jetendo_sites_path", 
		"jetendo_sites_writable_path", 
		"jetendo_log_path", 
		"jetendo_root_path", 
		"jetendo_root_private_path", 
		"jetendo_share_path", 
		"jetendo_scripts_path", 
		"jetendo_backup_path", 
		"jetendo_nginx_ssl_path", 
		"jetendo_nginx_sites_config_path",
		"jetendo_www_user");
	$correct=true;
	for($i=0;$i<count($arrVar);$i++){
		$v=get_cfg_var($arrVar[$i]);
		if($v == ""){
			$correct=false;
			echo $arrVar[$i]." missing \n";
			array_push($arrLog, "PHP configuration is missing ".$arrVar[$i].".  
			You must install the jetendo scripts directory and configure jetendo.ini to the php conf.d directory.");
		}
	}
	return $correct;
}

function zCheckDirectoryPermissions($dir, $user, $group, $fileChmodWithNoZeroPrefix, $dirChmodWithNoZeroPrefix, $recursive, $preview, $arrLog=array(), $isTestServer){
	if($dir === ""){
		array_push($arrLog, "dir variable was not defined, and it is required.");
		return false;
	}
	if(substr($dir, strlen($dir)-1, 1) != "/"){
		$dir.="/";
	}
	echo "Checking ".$dir."\n";
	if(!is_dir($dir)){
		array_push($arrLog, "Self-healing notice: missing directory was created: ".$dir);
		if(!$preview){
			mkdir($dir, "0".$dirChmodWithNoZeroPrefix, true);
		}
	}
	$correct=true;
	if($recursive){
		if(!$isTestServer){
			$r=system("find ".escapeshellarg($dir)." -type f \! -perm 0".$fileChmodWithNoZeroPrefix." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: chmod permissions reset to ".$fileChmodWithNoZeroPrefix." for files in ".$dir);
				if(!$preview){
					system("find ".escapeshellarg($dir)." -type f -exec chmod ".$fileChmodWithNoZeroPrefix." {} +");
				}
				$correct=false;
			}
			$r=system("find ".escapeshellarg($dir)." -type d \! -perm 2".$dirChmodWithNoZeroPrefix." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: chmod permissions reset to ".$dirChmodWithNoZeroPrefix." for directories in ".$dir);
				if(!$preview){
					system("find ".escapeshellarg($dir)." -type d -exec chmod 2".$dirChmodWithNoZeroPrefix." {} +");
				}
				$correct=false;
			}
			$r=system("find ".escapeshellarg($dir)." \! -user ".$user." -print -quit");
			if($r!==""){
				array_push($arrLog, "Self-healing notice: ownership reset recursively to ".$user.":".$group." for: ".$dir);
				if(!$preview){
					system("/bin/chown -R ".$user.":".$group." ".escapeshellarg($dir));
				}
				$correct=false;
			}else{
				$r=system("find ".escapeshellarg($dir)." \! -group ".$group." -print -quit");
				if($r!==""){
					array_push($arrLog, "Self-healing notice: ownership reset recursively to ".$user.":".$group." for: ".$dir);
					if(!$preview){
						system("/bin/chown -R ".$user.":".$group." ".escapeshellarg($dir));
					}
					$correct=false;
				}
			}
		}
	}else{
		if(!$isTestServer){
			if(fileperms($dir) != "2".$dirChmodWithNoZeroPrefix){
				array_push($arrLog, "Self-healing notice: permissions reset to ".$dirChmodWithNoZeroPrefix." for: ".$dir);
				if(!$preview){
					chmod($dir, octdec("2".$dirChmodWithNoZeroPrefix));
				}
			}
			if(filegroup($dir) != $group){
				array_push($arrLog, "Self-healing notice: ownership reset to group: ".$group." for: ".$dir);
				if(!$preview){
					chgrp($dir, $group);
				}
			}
			if(fileowner($dir) != $user){
				array_push($arrLog, "Self-healing notice: ownership reset to user: ".$user." for: ".$dir);
				if(!$preview){
					chown($dir, $user);
				}
			}
		}

	}
	return $correct;
}
function zGetDomainInstallPath($p){
	$testDomain=get_cfg_var("jetendo_test_domain");
	return get_cfg_var("jetendo_sites_path").str_replace(".", "_", str_replace("www.", "", str_replace(".".$testDomain, "", str_replace("/", "", str_replace("\\", "", $p)))))."/";
}
function zGetDomainWritableInstallPath($p){
	$testDomain=get_cfg_var("jetendo_test_domain");
	return get_cfg_var("jetendo_sites_writable_path").str_replace(".", "_", str_replace("www.", "", str_replace(".".$testDomain, "", str_replace("/", "", str_replace("\\", "", $p)))))."/";
}
function zGenerateStrongPassword($minLength, $maxLength){
	$d='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@##$%^&*()[]{}|;:,.<>/?`~ \'"+-';
	$d1=strlen($d);
	$plen=rand(1, $maxLength-$minLength)+$minLength;
	$i=0;
	$p=""; 
	for($i=0;$i<$plen;$i++){
		$p.=substr($d, rand(0, $d1-1),1);
	}
	return $p;
}
function getFilesInDirectoryAsArray($directory, $recursive, $arrFilter=array()) {
    $arrItems = array();
	if(substr($directory, strlen($directory)-1, 1) != "/"){
		$directory.="/";
	}
	if(count($arrFilter)){
		$filterMap=array();
		for($i=0;$i<count($arrFilter);$i++){
			$filterMap[$arrFilter[$i]]=true;
		}
		recurseDirectoryWithFilter($arrItems, $directory, $recursive, $filterMap);
	}else{
		recurseDirectory($arrItems, $directory, $recursive);
	}
    return $arrItems;
}
function recurseDirectory(&$arrItems, $directory, $recursive) {
	if ($handle = opendir($directory)) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				if(is_dir($directory.$file)) {
					if($recursive){
						recurseDirectory($arrItems, $directory.$file."/", $recursive);
					}
				}else{
					$arrItems[] = $directory . $file;
				}
			}
		}
		closedir($handle);
	}
    return $arrItems;
}
function recurseDirectoryWithFilter(&$arrItems, $directory, $recursive, &$filterMap) {
	if ($handle = opendir($directory)) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				if(is_dir($directory.$file)) {
					if($recursive){
						recurseDirectoryWithFilter($arrItems, $directory.$file."/", $recursive, $filterMap);
					}
				}else{
					if(isset($filterMap[getFileExt($file)])){
						$arrItems[] = $directory . $file;
					}
				}
			}
		}
		closedir($handle);
	}
    return $arrItems;
}
function getFileExt($path){
	$pos=strrpos($path, ".");
	if($pos===FALSE){
		return "";
	}else{
		return substr($path, $pos+1);
	}
}
function microtime_float(){
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}
function getAbsolutePath($path) {
	$path = str_replace(array('/', '\\'), DIRECTORY_SEPARATOR, $path);
	$parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), 'strlen');
	$absolutes = array();
	foreach ($parts as $part) {
		if ('.' == $part) continue;
		if ('..' == $part) {
			array_pop($absolutes);
		} else {
			$absolutes[] = $part;
		}
	}
	$result=implode(DIRECTORY_SEPARATOR, $absolutes);
	if(DIRECTORY_SEPARATOR == "/"){
		return "/".$result;
	}else{
		return $result;
	}
}
?>