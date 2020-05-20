<?php
/*

once a day, run the full active import

every 5 minutes, run the incremental import which generates individual small files for the cfml idx incremental process.
	spawn cfml wget background tasks from this file like execute-process does.

make a cron job that loops to watch for a new txt.incremental file to exist
	call cfml idx import with the filename in url
	// rename before calling cfml so that it is not executed more then once.
	application.zcore.functions.zRenameFile(this.optionStruct.filePath, this.optionStruct.filePath&"-processing");
	this.optionStruct.filePath=this.optionStruct.filePath&"-processing";


// this is now for the modification timestamp search


*/
//  


/*
// TODO: make a script that can send email of the last line of download-complete.log for each MLS ID as a once a day report.

// this script runs for less then 60 minutes and stores the current data class and offset before exiting.

// to force download the images again, run a query to update listing_track set listing_track_external_photo_timestamp='' where listing_id like 'MLS_ID-%'


// add these to crontab -e
1 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-rets-25.php >/dev/null 2>&1
2 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-rets-26.php >/dev/null 2>&1
3 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-rets-27.php >/dev/null 2>&1
4 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-rets-31.php >/dev/null 2>&1
*/

// php /var/jetendo-server/jetendo/scripts/rets-download-data.php

// redownload all active each time it runs


// 31 doesn't work with timestamp search, but it works if i remove it, and the images are high resolution.

// flexmls requires you to download the images with the location=1 and url method instead of location=0
// https://sparkplatform.com/docs/rets/tutorials/hi_res

// this script downloads the tab delimited rets data, and also the images. 
// It places the images in the final hashed file path so they need no further processing.
// it also deletes any existing extra images whenever it updates the images
// it also verifies if the images exist on disk, and forces an image update if any are missing.

// we need to download agent, agent images and office for rets 31 nsb
/*
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

function zDownloadRetsData($inputMLSID, $incremental=false){
	global $arrRetsConnections, $arrRetsConfig, $imageRootPath; 

	// prevent multiple simultaneous executions
	$cmd="ps aux";
	$r=`$cmd`;
	$r=trim($r);
	$arrLine=explode("\n", $r);
	$count=0;
	foreach($arrLine as $line){
		if(strstr($line, "import-rets-".$inputMLSID.".php") !== FALSE && strstr($line, "/bin/sh") === FALSE){
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
		if(!isset($arrRetsConfig[$mls_id]["enableDataDownload"]) || !$arrRetsConfig[$mls_id]["enableDataDownload"]){
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

 

		$arrRetsConnections[$mls_id]->SetParam("dataTimestampField", $arrRetsConfig[$mls_id]["dataTimestampField"]);

		// only create directories if one is missing
 		// if(!is_dir($imageRootPath.$mls_id."/ff/f")){
		if(!$incremental){
			$arr=array(0,1,2,3,4,5,6,7,8,9,"a","b","c","d","e","f");
			for($i=0;$i<count($arr);$i++){
				for($i2=0;$i2<count($arr);$i2++){
					for($i3=0;$i3<count($arr);$i3++){
						$fpath=$imageRootPath.$mls_id."/".$arr[$i].$arr[$i2]."/".$arr[$i3];
						// echo $fpath;exit;
						if(!is_dir($fpath)){
							mkdir($fpath, 0777, true);
						}
					}
				}
			} 
		}
		// }

		$dataClassIndex=0;
		$startOffset=1;
		if(!$incremental){
			if(file_exists($dataPath."download-rets-".$mls_id.".log")){
				$c=file_get_contents($dataPath."download-rets-".$mls_id.".log");
				$arrLog=unserialize($c);
				if(is_array($arrLog) and isset($arrLog["dataClassIndex"])){
					$dataClassIndex=$arrLog["dataClassIndex"];
					$startOffset=$arrLog["offset"];
				}
			}else{
				// do this on the first request only.
				$arrRetsConnections[$mls_id]->GetMetadataXMLAsFile($finalDataPath."metadata.1.xml");
				system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($finalDataPath."metadata.1.xml"));
				system("/bin/chmod 777 ".escapeshellarg($finalDataPath."metadata.1.xml"));
				echo "metadata xml saved\n";
			}
		}
		$lastTimestampFile=$dataPath."download-rets-".$mls_id."-last-timestamp.log";

		$previousStartTime = "1980-01-01T00:00:00".date("P");
		$nextStartTime=date("Y-m-d")."T".date("H:i:sP");
		if($incremental){
			if(file_exists($lastTimestampFile)){
				$lastDate=file_get_contents($lastTimestampFile);
				if(strtotime($lastDate)!=FALSE){
					$previousStartTime=$lastDate;
				}
			}
		}
		for($i=$dataClassIndex;$i<count($arrRetsConfig[$mls_id]["dataClasses"]);$i++){
			$file_name=$arrRetsConfig[$mls_id]["dataFileNames"][$i];
			$class=$arrRetsConfig[$mls_id]["dataClasses"][$i];

			if($incremental){
				$file_name.="-".date("Y-m-d")."-".date("H-i-s")."-incremental";
				$listingCount=0;
			}

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
			while ($maxrows) {
				if(!$incremental){
					// store current position in download for fast resume
					$arrLog=array(
						"dataClassIndex"=>$i,
						"offset"=>$offset
					);
					file_put_contents($dataPath."download-rets-".$mls_id.".log", serialize($arrLog));
				}
				// stop after 50 minutes to avoid overlapping next execution time
				// now runs forever, but prevents simultaneous runs, because some of the rets server are too slow
				// if(microtime(true)-$start_time > 60*50){
				// 	// store current dataClass $i, and $offset
				// 	echo "Stopped after 50 minutes of execution\n";
				// 	exit;
				// }

				// TODO: add field with the query to use for each class.

				if($incremental){
					$query="(".$arrRetsConfig[$mls_id]["dataTimestampField"]."=".$previousStartTime."+)";
				}else{
					$query = "";
				}
				if($arrRetsConfig[$mls_id]["dataQuery"]!=""){
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
						fwrite($fh, implode("\t", $fields_order)."\n");
					}

					$arrListing=array(); 

					while ($record = $arrRetsConnections[$mls_id]->FetchRow($search)) {
						$this_record = array();
						foreach ($fields_order as $fo) { 
							$this_record[] = $record[$fo]; 
						}
						if($incremental){
							$listingCount++;
						}
						$listing=array(
							"record"=>$record,
							"timestamp"=>$record[$arrRetsConfig[$mls_id]["photoTimestampField"]],
							"photoTimestamp"=>$record[$arrRetsConfig[$mls_id]["photoKeyField"]],
							"listingID"=>$record[$arrRetsConfig[$mls_id]["listingIDField"]],
							"photoKey"=>$record[$arrRetsConfig[$mls_id]["photoKeyField"]],
							"photoCount"=>$record[$arrRetsConfig[$mls_id]["photoCountField"]],
							"photoVerifiedCount"=>0,
							"new"=>false,
							"update"=>false,
							"updatePhotos"=>false
						);
						$sql="select * from listing_track where listing_id = '".$db->real_escape_string($mls_id."-".$listing["listingID"])."'";
						$r=$db->query($sql);
						if($r->num_rows==0){
							$listing["new"]=true; // not used for anything yet
							$listing["update"]=true; // not used for anything yet
							$listing["updatePhotos"]=true;
						}else{
							$row=$r->fetch_array(MYSQLI_ASSOC);
							if($listing["timestamp"] != $row["listing_track_external_timestamp"]){
								$listing["update"]=true; // not used for anything yet
							}
							if($listing["photoTimestamp"] != $row["listing_track_external_photo_timestamp"]){
								$listing["updatePhotos"]=true;
							}
							if($row["listing_track_external_photo_timestamp"] == ""){
								for($g=1;$g<=$listing["photoCount"];$g++){
			 						if(file_exists(getImageHashPath($mls_id, $listing["listingID"]."-".$g.".jpeg"))){
			 							$listing["photoVerifiedCount"]++;
			 						}
			 					}
			 					if($listing["photoVerifiedCount"]!=$listing["photoCount"]){
			 						$listing["updatePhotos"]=true;
			 					}else{
			 						$listing["updatePhotos"]=false; // for the first time, let's assume we have all the images?  
									$sql="update listing_track set listing_track_external_photo_timestamp = '".$listing["photoTimestamp"]."' where listing_id = '".$db->real_escape_string($mls_id."-".$listing["listingID"])."' and listing_track_deleted='0'";
									$r2=$db->query($sql);
								}
							}
						}
						// if($listing["new"]){
						// 	// insert listing
						// }else if($listing["update"]){
						// 	// update listing
						// }
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

 						if(is_numeric($listing["photoCount"]) && $listing["photoCount"] > 0){
	 						if($listing["updatePhotos"]){
								$arrPhoto=array();

								$locationEnabled=$arrRetsConfig[$mls_id]["locationEnabled"]; 

								if($locationEnabled){
									// location=1 only works with a "*" multipart request and I had to download them individually after that.
									$arrPhoto=$arrRetsConnections[$mls_id]->GetObject("Property", $arrRetsConfig[$mls_id]["listingMediaField"], $listing["photoKey"], "*", $locationEnabled);
									$arrLine=explode("\n",$arrPhoto[0]["Data"]);
									$photoCountIndex=1;

									// TODO: consider doing curl multi parallel download to speed it up: https://www.askapache.com/php/curl-multi-downloads/
									for($n2=0;$n2<count($arrLine);$n2++){
										$line=$arrLine[$n2];
										if(substr($line, 0, strlen("Location: ")) == "Location: "){
											$link=substr($line, strlen("Location: "));
 
											$filename=getImageHashPath($mls_id, $listing["listingID"]."-".$photoCountIndex.".jpeg");
											$photoCountIndex++;
											echo "storing image: ".$filename." from ".$link."\n";
											$tryAgain=false;
											$r=@fopen($link, 'rb');
											if($r==false){
												$tryAgain=true;
												echo "fopen failed\n";
												var_dump($http_response_header);
											}
											$r=@file_put_contents($filename, $r);
											if($r==false){
												$tryAgain=true;
												echo "file_put_contents failed\n";
												var_dump($http_response_header);
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
										}
									}
								}else{
									// when location is not enabled, we get the images one at a time.
									for($n2=1;$n2<=$listing["photoCount"];$n2++){
										$arrPhoto=$arrRetsConnections[$mls_id]->GetObject("Property", $arrRetsConfig[$mls_id]["listingMediaField"], $listing["photoKey"], $n2, $locationEnabled);
										
										// if we request the same listing too fast, it will return no images, so we should skip a failure like that until the next import to avoid getting stuck, the listing will appear on the site with missing images in the meantime.
										if(substr($arrPhoto[0]["Data"], 0, 5) == "<RETS"){
											echo "Photo download error for listing id: ".$listing["listingID"]." : ".$arrPhoto[0]["Data"]."\n";
										}else{
											$filename=getImageHashPath($mls_id, $listing["listingID"]."-".$n2.".jpeg");
											echo "storing image: ".$filename."\n";
											// var_dump($arrPhoto);exit;
											$fh2=fopen($filename, "wb");
											fwrite($fh2, $arrPhoto[0]["Data"]);
											fclose($fh2);
											// var_dump($arrPhoto[0]["Data"]);
											// exit; 


											// not using anymore: always writes to the same file.  this limits us to processing images for 1 listing at a time.
											// $filename=get_cfg_var("jetendo_share_path")."tempretsphotodownload.txt"; 
											// multipart works, but we're not using it, since the individual requests above was easier and didn't need the complex parsing.
											// $fh2=fopen($filename, "wb");
											// fwrite($fh2, trim($arrPhoto[0]["Data"]));
											// fclose($fh2); 
											// exit;

											// // silently remove any old images first to avoid wasting space
											// for($f=1;$f<=50;$f++){
											// 	@unlink(getImageHashPath($mls_id, $listing["listingID"]."-".$f.".jpeg"));
											// }
											// // put the images with the final file name in the final destination
											// $fh2=fopen($filename, "rb");
											// $parser=new HttpMultipartFileParser();
											// $parser->parse_multipart($fh2, null, true, $mls_id, $listing["listingID"]);
											// // fclose($fh2); // don't need it
				  							// unlink($filename);
				  						}
				  					}
				  				}
			  					// delete any images that exceed the current photo count to avoid waste
			  					for($f=$listing["photoCount"]+1;$f<=80;$f++){
									@unlink(getImageHashPath($mls_id, $listing["listingID"]."-".$f.".jpeg"));
								}
								$listing["photoVerifiedCount"]=0;
			 					for($g=1;$g<=$listing["photoCount"];$g++){
			 						if(file_exists(getImageHashPath($mls_id, $listing["listingID"]."-".$g.".jpeg"))){
			 							$listing["photoVerifiedCount"]++;
			 						}
			 					}
								// update the photo timestamp - its ok to ignore that some listings can't be verified due to corrupt data, we want it faster.
								$sql="update listing_track set listing_track_external_photo_timestamp = '".$listing["photoTimestamp"]."' where listing_id = '".$db->real_escape_string($mls_id."-".$listing["listingID"])."' and listing_track_deleted='0'";
								$r=$db->query($sql);
			 					if($listing["photoVerifiedCount"]==$listing["photoCount"]){ 
									echo "Photos downloaded and verified for listing id: ".$listing["listingID"]."\n";
								}else{
									echo "Photo download completed, but verification failed for listing id: ".$listing["listingID"]."\n";
								}
							}else{
								echo "Photos up to date for listing id: ".$listing["listingID"]."\n";
							}
						}
					}
				}

				$maxrows = $arrRetsConnections[$mls_id]->IsMaxrowsReached();

				$arrRetsConnections[$mls_id]->FreeResult($search);

				// stop after the first one
				// break;
			}
			$startOffset=1; // reset the offset so other dataClasses start from the beginning.
			fclose($fh);
			// rename file to final name, so that it can be processed.  this is necessary because the image downloading takes too long.

			// only process file if there were matching listings
			if($listingCount > 0){
				system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($dataPath.$file_name.".tmp"));
				system("/bin/chmod 777 ".escapeshellarg($dataPath.$file_name.".tmp"));
				rename($dataPath.$file_name.".tmp", $finalDataPath.$file_name);
			}else{
				unlink($dataPath.$file_name.".tmp");
			}

			// echo "stop after one\n";			exit;
			// echo "  - done<br>\n";

			// break; // TODO: remove this when going live.
		} 
		if($incremental){
			file_put_contents($lastTimestampFile, date("Y-m-d")."T".date("H:i:s"));
		}else{
			@unlink($dataPath."download-rets-".$mls_id.".log");
			$fh3=fopen($dataPath."download-complete.log", "a");
			fwrite($fh3, date("Y-m-d H:i")."\n");
			fclose($fh3);
		}
		// zEmail("MLS ID ".$mls_id." download completed.", "MLS ID ".$mls_id." download completed.");

	}
	return true;
}


function getImageHashPath($mls_id, $filename){
	global $imageRootPath;
	$md5name=md5($mls_id."-".$filename);
	return $imageRootPath.$mls_id."/".substr($md5name,0,2)."/".substr($md5name,2,1)."/".$mls_id."-".$filename;
}
 
?>