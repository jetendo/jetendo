<?php 
/*
// add these to crontab -e
3 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-rets-agent-31.php >/dev/null 2>&1

// we need to download agent, agent images and office for rets 31 nsb
Member is dataclass
MemberStatus A
AgentPhoto
*/

// TODO: maybe download rets25 sold someday, currently i removed them.

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

function zDownloadRetsAgentData($inputMLSID){
	global $arrRetsConnections, $arrRetsConfig, $imageRootPath; 

	// prevent multiple simultaneous executions
	$cmd="ps aux";
	$r=`$cmd`;
	$r=trim($r);
	$arrLine=explode("\n", $r);
	$count=0;
	foreach($arrLine as $line){
		if(strstr($line, "import-rets-agent-".$inputMLSID.".php") !== FALSE && strstr($line, "/bin/sh") === FALSE){
			$count++;
		}
	}
	if($count > 1){
		echo "Already running, please wait until current script completes.";
		exit;
	}
	$start_time = microtime(true);

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
		if(!isset($arrRetsConfig[$mls_id]["enableAgentDownload"]) || !$arrRetsConfig[$mls_id]["enableAgentDownload"]){
			continue;
		}
		$arrConfig=$arrRetsConfig[$mls_id];
 
		
		if(!isset($arrRetsConnections[$mls_id])){
			$arrRetsConnections[$mls_id] = new phRETS;
			$arrRetsConnections[$mls_id]->SetParam("use_post_method", true);
			// $arrRetsConnections[$mls_id]->SetParam("offset_support", false); // can't use offset_support because we need to handle 10 listings at a time
			$arrRetsConnections[$mls_id]->SetParam("compression_enabled", true);
			$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";
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

 
		//exit;

		$previous_start_time = "1980-01-01T00:00:00";
		//$previous_start_time = "2020-04-18T00:00:00"; // now to keep data small

		// $arrRetsConnections[$mls_id]->SetParam("dataTimestampField", $arrRetsConfig[$mls_id]["dataTimestampField"]);

		// only create directories if one is missing 
 		if(!is_dir($imageRootPath.$arrConfig["agentImagePath"]."/ff/f")){
			$arr=array(0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f");
			for($i=0;$i<count($arr);$i++){
				for($i2=0;$i2<count($arr);$i2++){
					for($i3=0;$i3<count($arr);$i3++){
						$fpath=$imageRootPath.$arrConfig["agentImagePath"]."/".$arr[$i].$arr[$i2]."/".$arr[$i3];
						// echo $fpath;exit;
						if(!is_dir($fpath)){
							mkdir($fpath, 0777, true);
						}
					}
				}
			} 
		}

		$dataClassIndex=0;
		$startOffset=1; 
		$dataClasses=array($arrRetsConfig[$mls_id]["officeClass"]);
		$dataFileNames=array($arrRetsConfig[$mls_id]["officeFileName"]);

		for($i=$dataClassIndex;$i<count($dataClasses);$i++){
			$file_name=$dataFileNames[$i];
			$class=$dataClasses[$i];

			echo "Downloading class: {$class}\n";
			// echo $dataPath.$file_name;exit;

			$maxrows = true;
			$offset = $startOffset;
			$limit = 30;
			$fields_order = array();
			if($offset==1){
				$fh = fopen($dataPath.$file_name.".tmp", "w"); // append to the file because we may need to resume. creates if doesn't exist.
			}else{
				$fh = fopen($dataPath.$file_name.".tmp", "a"); // append to the file because we may need to resume. creates if doesn't exist.
			} 
			while ($maxrows) { 

				// TODO: add field with the query to use for each class.
				$query = "";//({$arrRetsConfig[$mls_id]["dataTimestampField"]}={$previous_start_time}+)";
				if($arrRetsConfig[$mls_id]["officeQuery"]!=""){
					// $query.=",".$arrRetsConfig[$mls_id]["dataQuery"];
					$query.=$arrRetsConfig[$mls_id]["officeQuery"];
				}

				// run RETS search
				for($n6=0;$n6<=10;$n6++){
					echo "Query: {$query}  Limit: {$limit}  Offset: {$offset}\n";
					$search = $arrRetsConnections[$mls_id]->SearchQuery($arrConfig["officeResource"], $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => $arrRetsConfig[$mls_id]["dataFormat"], 'Count' => 1, 'QueryType' => 'DMQL2')); 
					$e=$arrRetsConnections[$mls_id]->Error();

					if($e !== false){
						var_dump($e);
						echo "SearchQuery failed ".($n6+1)." times. Records Found: ".$arrRetsConnections[$mls_id]->TotalRecordsFound().". Retrying in 150 seconds\n";
						sleep(150);
					}else{
						if($arrRetsConnections[$mls_id]->NumRows() != 0){
							break;
						}
						if($arrRetsConnections[$mls_id]->TotalRecordsFound()==0){
							echo "This class, ".$class.", has no records found right now.\n";
							break;
						}
					}
				}

				if($offset == 1){
					echo "Total found: {$arrRetsConnections[$mls_id]->TotalRecordsFound()}\n";
				}

				echo "Processing ".$arrRetsConnections[$mls_id]->NumRows()." rows | offset: ".$offset."\n";

				if ($arrRetsConnections[$mls_id]->NumRows() > 0) {

					if ($offset == 1) {
						// print filename headers as first line
						$fields_order = $arrRetsConnections[$mls_id]->SearchGetFields($search);
						fwrite($fh, implode("\t", $fields_order)."\n");
					}
 

					while ($record = $arrRetsConnections[$mls_id]->FetchRow($search)) {
						$this_record = array();
						foreach ($fields_order as $fo) { 
							$this_record[] = $record[$fo]; 
						} 
						fwrite($fh, str_replace("\r", " ", str_replace("\n", " ", implode("\t", $this_record)))."\n"); 

 					}
					$offset = ($offset + $arrRetsConnections[$mls_id]->NumRows()); 

					// for debugging
					// if($offset > 30){
					// 	break;
					// }
				}

				$maxrows = $arrRetsConnections[$mls_id]->IsMaxrowsReached();

				$arrRetsConnections[$mls_id]->FreeResult($search);

				// stop after the first one
				// break;
			}
			$startOffset=1; // reset the offset so other dataClasses start from the beginning.
			fclose($fh);
			// rename file to final name, so that it can be processed.  this is necessary because the image downloading takes too long.

			system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($dataPath.$file_name.".tmp"));
			system("/bin/chmod 777 ".escapeshellarg($dataPath.$file_name.".tmp"));
			rename($dataPath.$file_name.".tmp", $finalDataPath.$file_name);

			// echo "stop after one\n";			exit;
			// echo "  - done<br>\n";

			// break; // TODO: remove this when going live.
		} 
		$dataClasses=array($arrRetsConfig[$mls_id]["agentClass"]);
		$dataFileNames=array($arrRetsConfig[$mls_id]["agentFileName"]);

		for($i=$dataClassIndex;$i<count($dataClasses);$i++){
			$file_name=$dataFileNames[$i];
			$class=$dataClasses[$i];

			echo "Downloading class: {$class}\n";
			// echo $dataPath.$file_name;exit;

			$maxrows = true;
			$offset = $startOffset;
			$limit = 30;
			$fields_order = array();
			if($offset==1){
				$fh = fopen($dataPath.$file_name.".tmp", "w"); // append to the file because we may need to resume. creates if doesn't exist.
			}else{
				$fh = fopen($dataPath.$file_name.".tmp", "a"); // append to the file because we may need to resume. creates if doesn't exist.
			}

			$photoKeyFieldIndex=-1;
			$photoDateFieldIndex=-1;
			$totalRows=0;
			while ($maxrows) { 

				// TODO: add field with the query to use for each class.
				$query = "";//({$arrRetsConfig[$mls_id]["dataTimestampField"]}={$previous_start_time}+)";
				if($arrRetsConfig[$mls_id]["agentQuery"]!=""){
					// $query.=",".$arrRetsConfig[$mls_id]["dataQuery"];
					$query.=$arrRetsConfig[$mls_id]["agentQuery"];
				}

				// run RETS search
				for($n6=0;$n6<=10;$n6++){
					echo "Query: {$query}  Limit: {$limit}  Offset: {$offset}\n";
					$search = $arrRetsConnections[$mls_id]->SearchQuery($arrConfig["agentResource"], $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => $arrRetsConfig[$mls_id]["dataFormat"], 'Count' => 1, 'QueryType' => 'DMQL2'));
					$e=$arrRetsConnections[$mls_id]->Error();

					if($e !== false){
						var_dump($e);
						echo "SearchQuery failed ".($n6+1)." times. Records Found: ".$arrRetsConnections[$mls_id]->TotalRecordsFound().". Retrying in 150 seconds\n";
						sleep(150);
					}else{
						if($arrRetsConnections[$mls_id]->NumRows() != 0){
							break;
						}
						if($arrRetsConnections[$mls_id]->TotalRecordsFound()==0){
							echo "This class, ".$class.", has no records found right now.\n";
							break;
						}
					}
				}
				

				if($offset == 1){
					echo "Total found: {$arrRetsConnections[$mls_id]->TotalRecordsFound()}\n";
				}

				echo "Processing ".$arrRetsConnections[$mls_id]->NumRows()." rows | offset: ".$offset."\n";

				if ($arrRetsConnections[$mls_id]->NumRows() > 0) {

					if ($offset == 1) {
						// print filename headers as first line
						$fields_order = $arrRetsConnections[$mls_id]->SearchGetFields($search);
						fwrite($fh, implode("\t", $fields_order)."\n");
					}

					$arrListing=array(); 

					while ($record = $arrRetsConnections[$mls_id]->FetchRow($search)) {
						$totalRows++;
						$this_record = array();
						foreach ($fields_order as $fo) { 
							$this_record[] = $record[$fo]; 
						}
						$listing=array(
							"record"=>$record,
							"agentID"=>$record[$arrRetsConfig[$mls_id]["agentIDField"]],
							"photoKey"=>$record[$arrRetsConfig[$mls_id]["agentPhotoKeyField"]],
							"new"=>false,
							"update"=>false,
							"updatePhotos"=>false
						);
						fwrite($fh, str_replace("\r", " ", str_replace("\n", " ", implode("\t", $this_record)))."\n");
						array_push($arrListing, $listing);

 					}
					$offset = ($offset + $arrRetsConnections[$mls_id]->NumRows()); 

					// for debugging
					// if($offset > 30){
					// 	break;
					// }
 
					// stores the images with same hash path as the old method

					// note: it is safe to do new rets api call at any time, because each call returns the full response
 					for($n=0;$n<count($arrListing);$n++){
 						$listing=$arrListing[$n];

 						// break; // use to debug and disable image downloading to verifying offset is working.

 						if(isset($arrRetsConfig[$mls_id]["agentMediaField"])){
 							// only download agent images once per day to reduce processing time
							$filename=getImageHashPath($arrRetsConfig[$mls_id]["agentImagePath"], $listing["agentID"]."-1.jpeg");
							if(file_exists($filename)){
								$m=filemtime($filename);
								if(date("Y-m-d", $m) == date("Y-m-d", time())){
									continue; // skip downloading this image until tomorrow
								}
							}

							$arrPhoto=array();

							$locationEnabled=$arrRetsConfig[$mls_id]["locationEnabled"]; 

							if($locationEnabled){
								// location=1 only works with a "*" multipart request and I had to download them individually after that.
								for($n6=0;$n6<=10;$n6++){
									echo "GetObject: ".$arrRetsConfig[$mls_id]["agentMediaField"]." ID: ".$listing["photoKey"]." Attempt ".$n6."\n";
									$arrPhoto=$arrRetsConnections[$mls_id]->GetObject($arrRetsConfig[$mls_id]["agentResource"], $arrRetsConfig[$mls_id]["agentMediaField"], $listing["photoKey"], "*", $locationEnabled);
									if($arrPhoto==false){
										$e=$arrRetsConnections[$mls_id]->Error();
										var_dump($e);
										echo "GetObject failed ".($n6+1)." times. Retrying in 150 seconds\n";
										sleep(150);
									}else{
										break;
									}
								}
								
								$arrLine=explode("\n",$arrPhoto[0]["Data"]);
								$photoCountIndex=1;
 
								for($n2=0;$n2<count($arrLine);$n2++){
									$line=$arrLine[$n2];
									if(substr($line, 0, strlen("Location: ")) == "Location: "){
										$link=substr($line, strlen("Location: "));

										$filename=getImageHashPath($arrRetsConfig[$mls_id]["agentImagePath"], $listing["agentID"]."-".$photoCountIndex.".jpeg");
										$photoCountIndex++;
										echo "storing image: ".$filename." from ".$link."\n";
										$tryAgain=false;
										$r=@fopen($link, 'rb');
										if($r==false){
											$tryAgain=true;
										}
										$r=@file_put_contents($filename, $r);
										if($r==false){
											$tryAgain=true;
										}
										if($tryAgain){
											echo "Failed, trying again\n";
											sleep(1);
											$r=@fopen($link, 'rb');
											if($r==false){
												$tryAgain=true;
											}
											$r=@file_put_contents($filename, $r);
											if($r==false){
												$tryAgain=true;
											}
											if($tryAgain){
												echo "Failed, trying again\n";
												sleep(1);
												$r=@fopen($link, 'rb');
												if($r==false){
													$tryAgain=true;
												}
												$r=@file_put_contents($filename, $r);
												if($r==false){
													$tryAgain=true;
												}
											}
										}
										break; // only import first image
									}
								}
							}else{
								// when location is not enabled, we get the images one at a time.
								$arrPhoto=$arrRetsConnections[$mls_id]->GetObject($arrRetsConfig[$mls_id]["agentResource"], $arrRetsConfig[$mls_id]["agentMediaField"], $listing["photoKey"], 1, $locationEnabled);
									
								// if we request the same listing too fast, it will return no images, so we should skip a failure like that until the next import to avoid getting stuck, the listing will appear on the site with missing images in the meantime.
								if(substr($arrPhoto[0]["Data"], 0, 5) == "<RETS"){
									echo "Photo download error for listing id: ".$listing["agentID"]." : ".$arrPhoto[0]["Data"]."\n";
								}else{
									$filename=getImageHashPath($arrRetsConfig[$mls_id]["agentImagePath"], $listing["agentID"]."-1.jpeg");
									echo "storing image: ".$filename."\n";
									// var_dump($arrPhoto);exit;
									$fh2=fopen($filename, "wb");
									fwrite($fh2, $arrPhoto[0]["Data"]);
									fclose($fh2);
									// var_dump($arrPhoto[0]["Data"]);
									// exit;  
		  						}
			  				} 
						} 
					}
				}

				if($totalRows >= $arrRetsConnections[$mls_id]->TotalRecordsFound()){
					echo "All rows downloaded: ".$totalRows."\n";
					break;
				}
				// $maxrows = $arrRetsConnections[$mls_id]->IsMaxrowsReached();

				$arrRetsConnections[$mls_id]->FreeResult($search);

				// stop after the first one
				// break;
			}
			$startOffset=1; // reset the offset so other dataClasses start from the beginning.
			fclose($fh);
			// rename file to final name, so that it can be processed.  this is necessary because the image downloading takes too long.

			system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($dataPath.$file_name.".tmp"));
			system("/bin/chmod 777 ".escapeshellarg($dataPath.$file_name.".tmp"));
			rename($dataPath.$file_name.".tmp", $finalDataPath.$file_name);

			// echo "stop after one\n";			exit;
			// echo "  - done<br>\n";

			// break; // TODO: remove this when going live.
		} 
		$fh3=fopen($dataPath."download-agent-complete.log", "a");
		fwrite($fh3, date("Y-m-d H:i")."\n");
		fclose($fh3);
		// zEmail("MLS ID ".$mls_id." agent and office download completed.", "MLS ID ".$mls_id." agent and office download completed.");

	}
	return true;
}


function getImageHashPath($photoPath, $filename){
	global $imageRootPath;
	$md5name=md5($filename);
	return $imageRootPath.$photoPath."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/".$filename;
}
 
?>