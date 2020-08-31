<?php
require("library.php");
error_reporting(E_ALL);
set_time_limit(82800);
$timeStart = microtime(true);

$fastDebug=false;
$enableDelete=true;
$mlsDatasource=zGetDatasource();
$mlsDataDatasource=zGetDatasource();
$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), $mlsDatasource);
$mysqldate = date("Y-m-d H:i:s");
$daysOld=10;
$oldDate=mktime(0, 0, 0, date("m"),date("d")-$daysOld,date("Y")); // only delete images more then $daysOld
$deleteCount=0;
$fileCount=0;
$queryCount=0;
$totalCount=0;
$skipCount=0;

function deleteMissingListingId($arrId, $arrFile){
	global $cmysql, $deleteCount, $queryCount, $enableDelete;
	if(count($arrId) == 0){
		return;
	}
	$sql="select listing_id as id from `listing_track` WHERE listing_id IN ('".implode("','", $arrId)."') and listing_track_deleted='0'";
	//echo $sql."\n";
	$result=$cmysql->query($sql, MYSQLI_USE_RESULT);
	if($cmysql->error != ""){
		echo "Failed to run query in listing-image-cleanup.php\n".$cmysql->error."\n\n".$sql;
		zEmailErrorAndExit("Failed to run query in listing-image-cleanup.php", 
			"Failed to run query in listing-image-cleanup.php\n".$cmysql->error."\n\n".$sql);
	}
	$arrNewId=array();
	while($row=$result->fetch_array(MYSQLI_NUM)){
		$queryCount++;
		$arrNewId[$row[0]]=true;	
	}
	for($i=0;$i<count($arrId);$i++){
		$k=$arrId[$i];
		if(!isset($arrNewId[$k])){
			$c=$arrFile[$k];
			echo "Deleting images for listing_id: ".$k."\n";
			for($n=0;$n<count($c);$n++){
				$file=$c[$n];
				$deleteCount++;
				if($enableDelete){
					@unlink($file);
					@unlink(str_replace(".jpeg", "-large.jpeg", $file));
					@unlink(str_replace(".jpeg", "-medium.jpeg", $file));
					@unlink(str_replace(".jpeg", "-small.jpeg", $file));
				}
			}
		}
	}

	usleep(10000);
}

// the mls ids with images
$arrPhoto=array(25, 26, 27, 30, 31, 32);

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
						$totalCount++;
						if($totalCount % 1000 == 0){
							echo "Total ".$totalCount.", mls".$key.", Deleted ".$deleteCount.", Skipped ".$skipCount.", Found ".$queryCount."\n";
						}
						if($entry !="." && $entry !=".."){
							$fileCount++;
							$curFile=$curPath.$entry;
							$ext=substr($entry, strlen($entry)-4);
							if($ext == "jpeg" || $ext == ".pdf" || $ext == ".jpg"){
								if(filemtime($curFile) > $oldDate){
									$skipCount++;
									//echo "Skipping ".$curFile." because its less then ".$daysOld." days old.\n";
									continue;
								}
								$arrId9=explode("-", $entry);
								if(count($arrId9) == 3){
									$listing_id=$arrId9[0]."-".$arrId9[1];
								}else if(count($arrId9) == 2){
									$listing_id=$key."-".$arrId9[0];
								}else{
									echo "Deleting invalid file: ".$curFile."\n";
									$deleteCount++;
									if($enableDelete){
										unlink($curFile);
									}
									continue;
								}
								if(!isset($arrFile[$listing_id])){
									array_push($arrId, $listing_id);
									$arrFile[$listing_id]=array();
								}
								array_push($arrFile[$listing_id], $curFile);

								if(count($arrId) >= 29){
									deleteMissingListingId($arrId, $arrFile);
									$arrId=array();
									$arrFile=array();
								}
							}else{
								echo "Delete invalid: ".$curFile."\n";
								if($enableDelete){
									unlink($curFile);
								}
								$deleteCount++;
								usleep(20000);
							}
						}
					}
					closedir($handle);
					deleteMissingListingId($arrId, $arrFile);
					$arrId=array();
					$arrFile=array();
				}
			}
		}
	}
}
echo "Delete count:".$deleteCount." out of ".$totalCount." files | ".$queryCount." found in database | ".$skipCount." skipped.\n";
exit;
?>