<?php
// run every 60 minutes for up to 60 minutes in crontab.  
// 15 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/listing-image-resize2.php >/dev/null 2>&1
// 15 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/listing-image-resize3.php >/dev/null 2>&1
// 15 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/listing-image-resize4.php >/dev/null 2>&1
require("library.php");
error_reporting(E_ALL);
set_time_limit(3600);
$time_start=microtime_float();
$timeout=3580; 

$fastDebug=false; // loops images in just 00/0 when set to true
$resizeCount=0;
$totalCount=0;
$skipCount=0;
 
// the mls ids with images, 25 is last because its too big
//$arrPhoto=array(32, 27, 26, 31, 30, 25);
if(!isset($arrPhoto)){
	echo "You can't run this script directly";
	exit;
}

$mp=get_cfg_var("jetendo_share_path")."mls-images/";
$arrHex=array(0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f");
for($g=0;$g<count($arrPhoto);$g++){
	$key=$arrPhoto[$g];
	for($i7=0;$i7<16;$i7++){
		if($fastDebug && $i7 != 0){
			continue;
		}
		for($i8=0;$i8<16;$i8++){
			if($fastDebug && $i8 != 0){
				continue;
			} 
			// if($key==25 && ($i7*10)+$i8 <=145){
			// 	continue;
			// }
			for($i9=0;$i9<16;$i9++){
				if($fastDebug && $i9 != 0){
					continue;
				}
				$curPath=$mp.$key."/".$arrHex[$i7].$arrHex[$i8]."/".$arrHex[$i9]."/";
				if (is_dir($curPath) && $handle = opendir($curPath)) {
					echo $curPath."\n";
					$arrId=array();
					$arrFile=array();
					while (false !== ($entry = readdir($handle))) {
						if($totalCount % 50 == 0){
							echo "Resized ".$resizeCount." out of ".$totalCount." mls images, ".$skipCount." already resized.\n";
							if(microtime_float() - $time_start > $timeout-3){
								echo "Timeout reached";
								exit;
							}
						}

						if($entry =="." || $entry ==".."){
							continue;
						}
						$curFile=$curPath.$entry;
						$ext=substr($entry, strlen($entry)-4);
						if($ext == "jpeg"){
							if(strstr($entry, "-large") != false || strstr($entry, "-medium") != false || strstr($entry, "-small") != false){
								continue;
							}
							$totalCount++;
							if(is_dir($curPath.$entry)){
								@rmdir($curPath.$entry);
								continue;
							}
	  						if(!file_exists(str_replace(".jpeg", "-large.jpeg", $curPath.$entry))){
	  							$resizeCount++;
	  							zIDXImageResize($curPath, $entry);
	  							// echo $curPath.$entry."\n";
	  							// echo "stopped\n";
	  							// exit;
	  						}else{
								// check if the original filemtime is newer then the resized image filemtime
								if(filemtime($curPath.$entry) > filemtime(str_replace(".jpeg", "-large.jpeg", $curPath.$entry))){
									echo "New image, resizing again: ".$curPath.$entry."\n";
	  								zIDXImageResize($curPath, $entry);
								}else{
									$skipCount++;
								}
	  						}
						}
					}
					closedir($handle);
				}
			}
		}
	}
}
echo "Resized ".$resizeCount." out of ".$totalCount." mls images, ".$skipCount." already resized.\n";
exit;
?>