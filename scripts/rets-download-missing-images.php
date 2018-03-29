<?php
// Add this task to crontab manually if you want the server to download missing rets images automatically.  This will run it every 5 minutes
// 5 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/rets-download-missing-images.php >/dev/null 2>&1
require("library.php");


// zDownloadRetsImages("25-O5317775", "160634400", 0);exit;
error_reporting(E_ALL);

$debug=false;
$time_start = microtime_float();
ini_set("memory_limit","256M");
$timeoutInSeconds=3200; 
set_time_limit($timeoutInSeconds+250);

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
$mysqlMidnightDate=date("Y-m-d")." 00:00:00";

$perloop=50;
$destinationPath=get_cfg_var("jetendo_share_path")."mls-images/";
$result2=$cmysql->query("SELECT * FROM mls WHERE 
mls_status = '1' and 
mls_deleted='0' and 
mls_provider LIKE 'rets%' 
and mls_id NOT IN ('12', '19', '20', '16')
ORDER BY mls_update_date desc", MYSQLI_STORE_RESULT);
// errors:
// 12 = User Agent not registered or denied.
// 19 = password is not working yet - need to test when it does
// 20 = Authorization failed - need to test in the morning hours in case that it is why.

// 28-nsb rets server is broken and doesn't support downloading images with an offset, so we have to stupidly download all of the images again anytime they are missing, and we often need to do this because they don't have a proper field to download images with since date photo is wrong, and date change is not on all tables.
$forceDownloadAll=array(
	"28"=>true
);

$count1=0;
$downloadCount=0;
$errorCount=0;
$arrError=array();
while($mlsRow=$result2->fetch_array(MYSQLI_ASSOC)){
	$offset=0;
	$type=getRetsImageType($mlsRow["mls_id"]);
	echo "mls_id:".$mlsRow["mls_id"]."\n";
	if(!isset($arrRetsConfig[$mlsRow["mls_id"]]) || $arrRetsConfig[$mlsRow["mls_id"]]['username'] == ""){
		echo "Skipping mls_id=".$mlsRow["mls_id"]." because there is no login information specified.\n";
		continue;
	}
	if($type==false){
		echo "Skipping mls_id=".$mlsRow["mls_id"]." because we don't store images for this RETS server yet.\n";
		continue;
	}
	while(true){
		$result=$cmysql->query("select listing_id, listing_photocount, listing_liststatus from `listing` listing where 
		listing_photocount<> '0' and 
		listing_deleted='0' and 
		listing_images_verified_datetime < '".$mysqlMidnightDate."' and  
		listing_id like '".$mlsRow["mls_id"]."-%' LIMIT ".$offset.", ".$perloop." ", MYSQLI_STORE_RESULT);

		if($result->num_rows == 0){
			break;
		}
		while($row=$result->fetch_array(MYSQLI_ASSOC)){
			// verify existence of all images.
			if($row['listing_liststatus'] != 1){
				$c=1;
			}else{
				$c=$row['listing_photocount'];
			}
			$arrId=explode("-", $row["listing_id"]);
			$mls_id=$arrId[0];
			for($i=1;$i<=$c;$i++){
				$count1++;
				$fname=$row["listing_id"]."-".$i.".jpeg";
				$md5name=md5($fname);
				$fpath=$destinationPath.$mls_id."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/"; 
				if(!file_exists($fpath.$fname)){ // || $row["listing_id"] =='28-1036138' || $row["listing_id"] =='25-O5559132'
					ob_start();
					if(isset($forceDownloadAll[$mls_id])){
						$r=zDownloadRetsImages($row["listing_id"], "", 0);
						$c=0; 
					}else{
						$r=zDownloadRetsImages($row["listing_id"], "", $i);
					}
					$out=ob_get_clean();
					echo $out;
					if($r===false){
						$errorCount++;
						/*
						echo "Failed to download rets images for listing_id=".$row["listing_id"]."\n\nLast messages output:\n".$out;
						array_push($arrError, "Failed to download rets images for listing_id=".$row["listing_id"]."\n\nLast messages output:\n".$out);
						if(count($arrError) > 10){
							zEmailErrorAndExit("Failed to download rets images more then 10 times.", implode("\n\n", $arrError));
						}*/
					}else{
						$downloadCount++;
					}
				}else{
					if($count1 % 300 == 0){
						echo "Processed ".$count1." images | mls_id = ".$mls_id." | Downloaded ".$downloadCount." missing images\n";
					}
				}
			} 
			$mysqldate = date("Y-m-d H:i:s");
			$cmysql->query("UPDATE listing SET listing_images_verified_datetime='".$mysqldate."' WHERE listing_id = '".$row["listing_id"]."' and listing_deleted = '0'");
			usleep(20000);
		}
		if(microtime_float() - $time_start > $timeoutInSeconds){
			echo "Timeout reached - aborting\n";
			exit;
		}
		$offset+=$perloop;
	}
}
if($downloadCount || $errorCount){
	$logText="";
	$errorLogText="";
	$mysqldate = date("Y-m-d H:i:s");
	if($downloadCount){
		$logText="Downloaded ".$downloadCount." missing rets images";
	}
	if($errorCount){
		$errorLogText="Download failure count: ".$errorCount;
	}
	$sql="INSERT INTO rets_download_log SET 
	rets_download_log_text = '".$cmysql->real_escape_string($logText)."', 
	rets_download_log_error_text = '".$cmysql->real_escape_string($errorLogText)."', 
	rets_download_log_updated_datetime = '".$cmysql->real_escape_string($mysqldate)."' ";
	$cmysql->query($sql);
}else{
	echo "No missing images found\n";
}
?>