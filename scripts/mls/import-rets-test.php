<?php
/*
This script is for testing rets queries without writing any files or downloading any images.
Except for it downloads the metadata to the final location to help with initial development

example to download the active listing count for each data class
php /var/jetendo-server/jetendo/scripts/mls/import-rets-test.php 26 false '(LIST_15=|1AIZQHRI6I0R,1AIYOKAI49JJ,1AIYOKAIG4M4,1AIYOKAJ2HI5,1AIYOKAJBCZS,1AIYOIDSIWSE)' 1 0

example to download the active listing count, metadata, and output the data for 2 records
php /var/jetendo-server/jetendo/scripts/mls/import-rets-test.php 26 true '(LIST_15=|1AIZQHRI6I0R,1AIYOKAI49JJ,1AIYOKAIG4M4,1AIYOKAJ2HI5,1AIYOKAJBCZS,1AIYOIDSIWSE)' 2 1
*/
require(get_cfg_var("jetendo_scripts_path")."library.php");
$imageRootPath=get_cfg_var("jetendo_share_path")."mls-images/";
ini_set('memory_limit', '256M');
set_time_limit(2000000); 
error_reporting(E_ALL);
 
function zCheckRetsLogin($arrRetsConnections, $mls_id, $arrConfig){
	if(!$arrRetsConnections[$mls_id]->isLoggedIn()){
		$connect = $arrRetsConnections[$mls_id]->Connect($arrConfig["loginURL"], $arrConfig["username"], $arrConfig["password"]);

		if (!$connect) {
			echo "  + Not connected: mls_id: ".$mls_id." | loginURL: ".$arrConfig["loginURL"]."\n";
			print_r($arrRetsConnections[$mls_id]->Error());
			return false;
		}else{
			echo "Connected to mls_id=".$mls_id."\n";
			return true;
		}
	}else{
		return true;
	} 
}

function zDownloadRetsData(){
	global $arrRetsConnections, $arrRetsConfig, $imageRootPath, $argv; 
 	$inputMLSID=$argv[1];
 	$downloadMetaData=$argv[2];
 	$customQuery=$argv[3];
 	$dataLimit=$argv[4];
 	$dumpRecords=$argv[5];
	$db=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"),get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource"));

	if($db->error != ""){
		echo "Mysql error:".$db->error."\n";
		exit;
	}

	foreach ($arrRetsConfig as $mls_id=>$retsConfig) {
		if($mls_id != $inputMLSID){
			echo "debug: skipping mls_id: ".$mls_id."\n";
			continue;
		}
		if(!isset($arrRetsConfig[$mls_id]["enableDataDownload"]) || !$arrRetsConfig[$mls_id]["enableDataDownload"]){
			continue;
		}
		$arrConfig=$arrRetsConfig[$mls_id];
  
		if(!isset($arrRetsConnections[$mls_id])){
			$arrRetsConnections[$mls_id] = new phRETS;
			$arrRetsConnections[$mls_id]->SetParam("use_post_method", true);
			// $arrRetsConnections[$mls_id]->SetParam("offset_support", false); // can't use offset_support because we need to handle 10 listings at a time
			$arrRetsConnections[$mls_id]->SetParam("compression_enabled", true); 
			// $arrRetsConnections[$mls_id]->SetParam("debug_mode", true);
			// $arrRetsConnections[$mls_id]->SetParam("debug_file", get_cfg_var("jetendo_share_path")."retsDataDownloadLog.txt");
			$arrRetsConnections[$mls_id]->AddHeader("RETS-Version", "RETS/1.7.2");
			$arrRetsConnections[$mls_id]->AddHeader("User-Agent", "RETSConnector/1.0");
		} 
		//var_dump($arrRetsConnections);exit;

		if(!zCheckRetsLogin($arrRetsConnections, $mls_id, $arrConfig)){
			echo "Failed to connect to ".$mls_id."\n";
			continue;
		}
		if(!$arrRetsConnections[$mls_id]->isLoggedIn()){
			$connect = $arrRetsConnections[$mls_id]->Connect($arrConfig["loginURL"], $arrConfig["username"], $arrConfig["password"]);

			if (!$connect) {
				echo "Not connected: mls_id: ".$mls_id." | loginURL: ".$arrConfig["loginURL"]."\n";
				print_r($arrRetsConnections[$mls_id]->Error());
				zEmailErrorAndExit("MLS ID ".$mls_id." connection failed", "RETS connection failed in rets download data script.", true); 
			}else{
				echo "Connected to mls_id=".$mls_id."\n";
			}
		}else{
			echo "Trying to re-use existing connection to mls_id=".$mls_id."\n";
		} 
		// store in the same location as the previous method
		$dataPath=get_cfg_var("jetendo_share_path")."mls-data/temp/".$mls_id."/";
		$finalDataPath=get_cfg_var("jetendo_share_path")."mls-data/".$mls_id."/";
		if(!is_dir($dataPath)){
			mkdir($dataPath, 0777);
		}
		if(!is_dir($finalDataPath)){
			mkdir($finalDataPath, 0777);
		} 
		$arrRetsConnections[$mls_id]->SetParam("dataTimestampField", $arrRetsConfig[$mls_id]["dataTimestampField"]);
 

		$dataClassIndex=0;
		$startOffset=1;
		// do this on the first request only.
		if($downloadMetaData == "true"){
			$arrRetsConnections[$mls_id]->GetMetadataXMLAsFile($finalDataPath."metadata.1.xml");
			system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($finalDataPath."metadata.1.xml"));
			system("/bin/chmod 777 ".escapeshellarg($finalDataPath."metadata.1.xml"));
			echo "metadata xml saved\n";
		} 
		for($i=$dataClassIndex;$i<count($arrRetsConfig[$mls_id]["dataClasses"]);$i++){
			$file_name=$arrRetsConfig[$mls_id]["dataFileNames"][$i];
			$class=$arrRetsConfig[$mls_id]["dataClasses"][$i];

			$listingCount=0; 
			echo "Downloading class: {$class}\n";
			// echo $dataPath.$file_name;exit;

			$maxrows = true;
			$offset = $startOffset;
			$limit = $dataLimit;
			$fields_order = array();
			// if($offset==1){
			// 	$fh = fopen($dataPath.$file_name.".tmp", "w"); // append to the file because we may need to resume. creates if doesn't exist.
			// }else{
			// 	$fh = fopen($dataPath.$file_name.".tmp", "a"); // append to the file because we may need to resume. creates if doesn't exist.
			// }

			$photoKeyFieldIndex=-1;
			$photoDateFieldIndex=-1;
			while ($maxrows) { 

				$query = "";
				if($customQuery != ""){
					if($query!=""){
						$query.=",";
					}
					$query.=$customQuery;
				}else if($arrRetsConfig[$mls_id]["dataQuery"]!=""){
					if($query!=""){
						$query.=",";
					}
					$query.=$arrRetsConfig[$mls_id]["dataQuery"];
				}

				// run RETS search
				// echo "Query: {$query}  Limit: {$limit}  Offset: {$offset}\n";
				$search = $arrRetsConnections[$mls_id]->SearchQuery("Property", $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => $arrRetsConfig[$mls_id]["dataFormat"], 'Count' => 1, 'QueryType' => 'DMQL2'));

				if($offset == 1){
					echo "Total found: {$arrRetsConnections[$mls_id]->TotalRecordsFound()}\n";
				}

				echo "Processing ".$arrRetsConnections[$mls_id]->NumRows()." rows | offset: ".$offset."\n";

				if ($arrRetsConnections[$mls_id]->NumRows() > 0) {

					if ($offset == 1) {
						// print filename headers as first line
						$fields_order = $arrRetsConnections[$mls_id]->SearchGetFields($search);
						if($dumpRecords == "1"){
							echo implode("\t", $fields_order)."\n";
						}
						// fwrite($fh, implode("\t", $fields_order)."\n");
					}

					$arrListing=array(); 

					while ($record = $arrRetsConnections[$mls_id]->FetchRow($search)) {
						$this_record = array();
						foreach ($fields_order as $fo) { 
							$this_record[] = $record[$fo]; 
						}
						$listingCount++;
						// $listing=array(
						// 	"record"=>$record,
						// 	"timestamp"=>$record[$arrRetsConfig[$mls_id]["photoTimestampField"]],
						// 	"photoTimestamp"=>$record[$arrRetsConfig[$mls_id]["photoKeyField"]],
						// 	"listingID"=>$record[$arrRetsConfig[$mls_id]["listingIDField"]],
						// 	"photoKey"=>$record[$arrRetsConfig[$mls_id]["photoKeyField"]],
						// 	"photoCount"=>$record[$arrRetsConfig[$mls_id]["photoCountField"]],
						// 	"photoVerifiedCount"=>0,
						// 	"new"=>false,
						// 	"update"=>false,
						// 	"updatePhotos"=>false
						// ); 
						// fwrite($fh, str_replace("\r", " ", str_replace("\n", " ", implode("\t", $this_record)))."\n");
						// array_push($arrListing, $listing);

						if($dumpRecords == "1"){
							echo str_replace("\r", " ", str_replace("\n", " ", implode("\t", $this_record)))."\n";
						}
 					}
					$offset = ($offset + $arrRetsConnections[$mls_id]->NumRows()); 
 				}

				$maxrows = $arrRetsConnections[$mls_id]->IsMaxrowsReached();

				$arrRetsConnections[$mls_id]->FreeResult($search);

				if($listingCount==$dataLimit){
					break;
				}
				// stop after the first one
				// break;
			}
			$startOffset=1; // reset the offset so other dataClasses start from the beginning.
			// fclose($fh); 
 
		}  
	}
	echo "listing count: ".$listingCount."\n";
	return true;
}


zDownloadRetsData();
 
?>