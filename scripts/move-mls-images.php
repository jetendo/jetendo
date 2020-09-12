<?php
require("library.php");
error_reporting(E_ALL);

echo "No longer used, aborting";
exit;

$runningFilePath=get_cfg_var("jetendo_scripts_path")."move-mls-images-running.txt";
if(file_exists($runningFilePath)){
	$d=filemtime($runningFilePath);
	if($d > strtotime("-1 hour")){	
		echo "/root/move-mls-images.php is already running.";
		exit;
	}else{
		echo "This task must have crashed - removing ".$runningFilePath." and continuing.";
		unlink($runningFilePath);
		//exit;
	}
}
$fRunningHandle=fopen($runningFilePath, "w");
fwrite($fRunningHandle, "1");
fclose($fRunningHandle);
/**/
$debug=false;
$time_start = microtime_float();
$minutesToDelayProcessing=3;
$host=`hostname`;

$testserver=zIsTestServer();
$mlsDatasource=get_cfg_var("jetendo_datasource");
$mlsDataDatasource=get_cfg_var("jetendo_datasource");
$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource"));

if($cmysql->error != ""){
	echo "Mysql error:".$cmysql."\n";
	exit;
}
$mysqldate = date("Y-m-d H:i:s");

$apache=false;
if(isset($_SERVER['SERVER_SOFTWARE'])){
	if(str_replace("Apache","",$_SERVER['SERVER_SOFTWARE']) != $_SERVER['SERVER_SOFTWARE']){
		$apache=true;
	}
}


set_time_limit(20000);
$mp="".get_cfg_var("jetendo_share_path")."mls-images-temp/";
$today=date("Y").'-'.date("m")."-".date("d");
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".."){
			if($entry != $today){
				$cmd="rm -rf ".escapeshellarg(get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/");
				//echo $cmd."\n";
				echo "deleting ".get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/\n";
				`$cmd`;
			}else{
				echo "NOT deleting ".get_cfg_var("jetendo_share_path")."mls-images-temp/".$entry."/\n";
			}
		}
    }

    closedir($handle);
}
if(microtime_float()-$time_start > 290){
	// take a break
	echo "Timeout reached\n";
	exit;
}

echo "before temp move\n";
$mp=get_cfg_var("jetendo_share_path")."mls-data/temp/";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && $entry != "mls-scripts"){
			if ($handle2 = opendir($mp.$entry)) {
				while (false !== ($entry2 = readdir($handle2))) {
					if($entry2 !="." && $entry2 !=".."){
						$ext=substr($entry2, strlen($entry2)-4,4);
						if(($ext != ".log" && $ext != ".tmp") && (strpos($entry2, "-sold-") === FALSE || $entry=="20")){
							$updatedDate = filemtime($mp.$entry."/".$entry2);
							$sixtySecondsAgo= strtotime('-'.$minutesToDelayProcessing.' minutes');
							// echo $entry2." | ".$updatedDate." < ".$sixtySecondsAgo."\n";
							if ($updatedDate < $sixtySecondsAgo || $entry=="26") {
								//$source="/home/remote-mls-data/".$entry."/".$entry2;
								$tempdest=$mp.$entry."/".$entry2;
								$dest="".get_cfg_var("jetendo_share_path")."mls-data/".$entry."/".$entry2;
								//echo file_exists($tempdest)." == ".false." || ".filesize($source)." != ".filesize($tempdest)." || ".filemtime($source)." != ".filemtime($tempdest)."\n";
								if(filesize($tempdest) == 0){// || file_exists($tempdest) == false || filesize($source) != filesize($tempdest)){// || filemtime($source) != filemtime($tempdest)){
									if(file_exists($tempdest)){
										echo "deleting: ".$tempdest."\n";
										@unlink($tempdest);
									} 
								}else{
								
									system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($tempdest));
									system("/bin/chmod 777 ".escapeshellarg($tempdest));
									$cmd="mv -f ".escapeshellarg($tempdest)." ".escapeshellarg($dest);
									echo $cmd."\n";
									`$cmd`;
									//@unlink($source);
								}
							}
						}
					}
				}
				closedir($handle2);
			}
		}
	}
    closedir($handle);
}

if(microtime_float()-$time_start > 290){
	// take a break
	echo "Timeout reached\n";
	exit;
}
echo "after temp move\n";






function processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN){
	global $cmysql, $debug, $mysqldate, $mlsDatasource, $lastMessage2;
	$sql="select mls_image_hash_mlsid, mls_image_hash_value FROM mls_image_hash 
	WHERE mls_image_hash_deleted = '0' and 
	mls_image_hash_mlsid IN ('".implode("','", $arrFID)."') ";//and mls_image_hash_datetime < '2012-10-19 15:00:00' ";
	
	$arrIdNew=array();
	$renameEnabled=false;
	if(is_array($arrSQL)){
		$renameEnabled=true;
		// get the 
		// echo "renaming\n";
		if(!$cmysql->select_db($arrSQL[1])){
			echo "failed to select db:".$arrSQL[1]."\n";
			$lastMessage2="failed to select db:".$arrSQL[1];
			return false;
		}
		$sql2=$arrSQL[0].implode("','", $arrFID2)."') ";
		// echo $sql2."\n";
		$r=$cmysql->query($sql2, MYSQLI_USE_RESULT);
		if($cmysql->error != ""){ 
			echo "db error:".$cmysql->error."\n";
			return false;
		}
		while($row=$r->fetch_array(MYSQLI_NUM)){
			$arrIdNew[$row[0]]=$row[1];
		}
		if(!$cmysql->select_db($mlsDatasource)){
			echo "failed to select db:".$mlsDatasource."\n";
			$lastMessage2="failed to select db:".$mlsDatasource;
			return false;
		}
	}else{
		// echo "not renaming\n";
	}
	$r=$cmysql->query($sql, MYSQLI_USE_RESULT);
	if($cmysql->error != ""){ 
		echo "db error:".$cmysql->error."\n";
		return false;
	}
	$arrNew=array();
	while($row=$r->fetch_array(MYSQLI_NUM)){
		$arrNew[$row[0]]=$row[1];
	}
	$c=count($arrF);
	$arrV=array();
	
	
	for($i=0;$i<$c;$i++){
		if($renameEnabled){
			if(!isset($arrIdNew[$arrFID2[$i]])){
				// record doesn't exist in database, leave it in the temporary folder
				continue;
			}
		}
		$filedestination=$arrFD[$i];
		$filesource=$arrF[$i];
		$newHash=@md5_file($filesource);
		if($newHash===FALSE){
			continue;
		}
		$crop=false;
		
		$temp=".".rand(1,100000);
				
		
		$rpos=strrpos($filedestination, "/")+1;
		$fname=substr($filedestination, $rpos);
		if($renameEnabled){
			if(substr_count($fname, "-") == 1){
				$fname=$arrIdNew[$arrFID2[$i]].substr($fname, strpos($fname, "-"));
				echo "Found id:".$fname."\n";
			}else{
				echo "Didn't find id\n";
			}
		}
		$md5name=md5($fname);
		$fpath=substr($filedestination, 0, $rpos).substr($md5name,0,2)."/".substr($md5name,2,1)."/";
		if(!is_dir($fpath)){
			mkdir($fpath, 0777, true);
		}
		$filedestination=$fpath.$fname;
		
		//substr($newHash,0,2)."/".substr($newHash,2,1)."/";
		if(isset($arrNew[$arrFID[$i]])){
			// we have an existing hash	
			$oldHash=$arrNew[$arrFID[$i]];
			if($oldHash != $newHash){
				// must update database and crop the new image.
				$crop=true;
				echo 'hash don\'t match, crop and store: '.$arrFID[$i]."\n";
			}else{
				if(file_exists($filedestination)){
					/*if(md5_file($filedestination) != $newHash){
						echo 'existed but has to crop and store again:'.$arrFID[$i]."\n";
						$crop=true;
					}else{*/
						echo "deleting from remote-images: ".$arrFID[$i]."\n";
						@unlink($filesource);
					//}
				}else{
					echo 'not exist - crop and store: '.$filedestination." | ".$arrFID[$i]."\n";
					$crop=true;
				}
			}
		}else{
			// new file, crop and store it!
			echo 'new file crop and store: '.$arrFID[$i]."\n";
			$crop=true;
		}
		//echo " | did i crop: ". $filesource."\noldHash:".$arrNew[$arrFID[$i]]."\nnewHash:".$newHash."\n";
		//var_dump($crop);
		//exit;
		/*if($arrFID[$i] == "4-cropme.jpg"){
			$crop=true;
		}*/
		if($crop){
			// read image, crop and store
			if(substr($filedestination, strlen($filedestination)-4, 4) == ".pdf"){
				echo "moving: ".$arrFID[$i]." to ".$filedestination."\n";
				$r=moveFile($filesource, $filedestination);
				if($r===FALSE){
					echo "non image copy failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination."\n";
					$lastMessage2="non image copy failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination;
					return false;
				}else{
					chmod($filedestination, 0777);
					system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($filedestination));
					array_push($arrV, "('".$arrFID[$i]."','".$newHash."', '".$mysqldate."')");
				}
				
			}else{
				echo "cropping: ".$arrFID[$i]." to ".$filedestination."\n";
				$r=cropWhiteEdgesFromImage($filesource, $filedestination);
				usleep(40000);
				if($r===FALSE){
					echo "process image failed - skipping\n";
					continue;
					/*echo "cropWhiteEdgesFromImage() failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination;
					$lastMessage2="cropWhiteEdgesFromImage() failed.  Source: ".$filesource." Source ID: ".$arrFID[$i]." Destination: ".$filedestination;
					return false;*/
				}else{
					array_push($arrV, "('".$arrFID[$i]."','".$newHash."', '".$mysqldate."', '".$mysqldate."')");
				}
			}
		}
	}
	if(count($arrV) != 0){
		$sql2="INSERT INTO mls_image_hash (mls_image_hash_mlsid, mls_image_hash_value, mls_image_hash_datetime, mls_image_hash_updated_datetime) 
		VALUES ".implode(", ", $arrV)." ON DUPLICATE KEY UPDATE 
		mls_image_hash_value=VALUES(mls_image_hash_value), 
		mls_image_hash_deleted=0,
		mls_image_hash_datetime=VALUES(mls_image_hash_datetime), 
		mls_image_hash_updated_datetime=VALUES(mls_image_hash_updated_datetime) ";
		$r=$cmysql->query($sql2);
		if($r===FALSE){
			echo "Critical mysql failure:".$cmysql->error;
			$lastMessage2="Critical mysql failure:".$cmysql->error;
			return false;
		}
	}
	return true;
}




echo "\ndelete runningFilePath before image processing:".$runningFilePath."\n";
@unlink($runningFilePath);

//exit;

echo "start image processing\n";

$mp="".get_cfg_var("jetendo_share_path")."mls-images/temp/";
$destinationPath="".get_cfg_var("jetendo_share_path")."mls-images/";
chdir($mp);
if($debug) echo "Moving mls-images from windows to linux local\n\n";
$iCount1=0;
$arrFID=array();
$arrFID2=array();
$arrF=array();
$arrFD=array();
$arrFN=array();
$stopProcessing=false;

$lastMessage2="";
$lastMessage="";
//$oneMinuteAgo=mktime(date("H"), date("i")-1, date("s"), date("m"),date("d"),date("Y"));
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".."){
			$mp2=$mp.$entry."/";
			if(isset($arrQueryFunction[$entry])){
				$arrSQL=$arrQueryFunction[$entry]();
			}else{
				$arrSQL="";
			}
			echo "process:".$mp2."\n";
			if ($handle2 = opendir($mp2)) {
				while (false !== ($entry2 = readdir($handle2))) {
					if(substr($entry2, strlen($entry2)-4,4) == ".txt"){
						$cur=$mp.$entry."/".$entry2;
						$cur2=$destinationPath.$entry."/".$entry2;
						$fiveMinuteAgo=mktime(date("H"), date("i")-$minutesToDelayProcessing, date("s"), date("m"),date("d"),date("Y"));
						$cmtime=@filemtime($cur); 
						if($cmtime === FALSE || $cmtime < $fiveMinuteAgo){
							if(file_exists($cur2)){
								unlink($cur2);
							}
							rename($cur, $cur2);
						}

					}else if(substr($entry2, strlen($entry2)-5,5) == ".jpeg" || substr($entry2, strlen($entry2)-4,4) == ".jpg" || substr($entry2, strlen($entry2)-4,4) == ".pdf"){// !="." && $entry2 !=".."){
						$pos=strpos($entry2, "-");
						$cur=$mp.$entry."/".$entry2;
						$idname=$entry."-".$entry2;
						$idonlyname=substr($entry2, 0, $pos);
						if($idonlyname == ""){
							echo "empty idonlyname: ".$cur."\n";
							continue;
						}
						// uncomment to debug file path
						//echo $cur."\n";
						if($iCount1 % 100 == 0){
							if($iCount1 !=0){
								echo "process ".$iCount1." | last: ".$cur."\n";
								$r=processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN);
								if($r===FALSE){
									$stopProcessing=true;
									break;
								}
							}
							$arrFID=array();
							$arrFID2=array();
							$arrF=array();
							$arrFD=array();
							$arrFN=array();
							$fiveMinuteAgo=mktime(date("H"), date("i")-$minutesToDelayProcessing, date("s"), date("m"),date("d"),date("Y"));
							if(microtime_float()-$time_start > 290){
								// take a break
								echo "Timeout reached\n";
								exit;
							}
						}
						$cmtime=@filemtime($cur);
						if($cmtime !== FALSE && $cmtime < $fiveMinuteAgo){
							$csize=@filesize($cur);
							if($csize !== FALSE && $csize != 0){
								$iCount1++;
								// add
								array_push($arrFID2, $idonlyname);
								array_push($arrFID, $idname);
								array_push($arrF, $cur);
								array_push($arrFD, $destinationPath.$entry."/".$entry2);
								array_push($arrFN, $entry2);
							}
						}
					}
				}
				closedir($handle2);
			}
			if($stopProcessing){
				break;
			}
		}
    }
	if($stopProcessing){
		
		$to      = get_cfg_var('jetendo_developer_email_to');
		$subject = 'PHP move-mls-images.php stopped processing on '.$host;
		$headers = 'From: ' .get_cfg_var('jetendo_developer_email_from'). "\r\n" .
			'Reply-To: '.get_cfg_var('jetendo_developer_email_from') . "\r\n" .
			'X-Mailer: PHP/' . phpversion();
		$message = 'PHP move-mls-images.php stopped processing'."\nLast Image Message:".$lastMessage."\nLast Process Files Message:".$lastMessage2;

		mail($to, $subject, $message, $headers);
	}else if(count($arrF) != 0){
		processFiles($arrSQL, $arrF, $arrFID, $arrFID2, $arrFD, $arrFN);
	}
    closedir($handle);
}

echo "\ndelete:".$runningFilePath."\n";
@unlink($runningFilePath);

?>