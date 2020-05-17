<?php 
// php /var/jetendo-server/jetendo/scripts/rets-download-data.php

require("library.php");
class HttpMultipartFileParser
{
	public function parse_multipart($stream, $boundary = null, $alwaysFile=false, $fileName)
	{
		$return = array('variables' => array(), 'files' => array());

		$partInfo = null;
		$fileIndex=1;

		while(($lineN = fgets($stream)) !== false)
		{
			if(strpos($lineN, '--') === 0)
			{
				if(!isSet($boundary) || $boundary == null)
				{
					$boundary = rtrim($lineN);
					echo $boundary."\n\n";
				}
				continue;
			}

			$line = rtrim($lineN);

			if($line == '')
			{
				if($alwaysFile || !empty($partInfo['Content-Disposition']['filename']))
				{
					$this->parse_file($stream, $boundary, $partInfo, $return['files'], $fileName."-".$fileIndex.".jpg");
					$fileIndex++;
				}
				elseif(!$partInfo != null)
				{
					$this->parse_variable($stream, $boundary, $partInfo['Content-Disposition']['name'], $return['variables']);
				}
				$partInfo = null;
				continue;
			}

			$delim = strpos($line, ':');

			$headerKey = substr($line, 0, $delim);
			$headerVal = ltrim($line, $delim + 1);

			$partInfo[$headerKey] = $this->parse_header_value($headerVal, $headerKey);
		}

		fclose($stream);
		return $return;
	}

	public function parse_header_value($line, $header = '')
	{
		$retval = array();
		$regex  = '/(^|;)\s*(?P<name>[^=:,;\s"]*):?(=("(?P<quotedValue>[^"]*(\\.[^"]*)*)")|(\s*(?P<value>[^=,;\s"]*)))?/mx';

		$matches = null;
		preg_match_all($regex, $line, $matches, PREG_SET_ORDER);

		for($i = 0; $i < count($matches); $i++)
		{
			$match = $matches[$i];
			$name = $match['name'];
			$quotedValue = $match['quotedValue'];
			if(empty($quotedValue))
			{
				$value = $match['value'];
			}
			else {
				$value = stripcslashes($quotedValue);
			}
			if($name == $header && $i == 0)
			{
				$name = 'value';
			}
			$retval[$name] = $value;
		}
		return $retval;
	}
	public function parse_variable_string($arrLine, $lineIndex, $boundary, $name, &$array)
	{
		$fullValue = '';
		$lastLine = null;
		for($lineIndex++;$lineIndex<count($arrLine);$lineIndex++){ 
			$lineN=$arrLine[$lineIndex];
			if(strpos($lineN, $boundary) !== 0){
				if($lastLine != null)
				{
					$fullValue .= $lastLine;
				}
				$lastLine = $lineN;
			}
		}

		if($lastLine != null)
		{
			$fullValue .= rtrim($lastLine, '\r\n');
		}
		$array[$name] = $fullValue;
		return $lineIndex;
	}

	public function parse_variable($stream, $boundary, $name, &$array)
	{
		$fullValue = '';
		$lastLine = null;
		while(($lineN = fgets($stream)) !== false && strpos($lineN, $boundary) !== 0)
		{
			if($lastLine != null)
			{
				$fullValue .= $lastLine;
			}
			$lastLine = $lineN;
		}

		if($lastLine != null)
		{
			$fullValue .= rtrim($lastLine, '\r\n');
		}
		$array[$name] = $fullValue;

	}

	public function parse_file($stream, $boundary, $info, &$array, $fileName)
	{
		$tempdir = sys_get_temp_dir();

		$name = "temp".microtime();//$info['Content-Disposition']['name'];
		// $fileStruct['name'] = $info['Content-Disposition']['filename'];
		$fileStruct['type'] = $info['Content-Type']['value'];

		$array[$name] = &$fileStruct;

		if(empty($tempdir))
		{
			$fileStruct['error'] = UPLOAD_ERR_NO_TMP_DIR;
			return;
		}

		$tempname = $fileName;//tempnam($tempdir, 'php_upl');
		$outFP = fopen($tempname, 'wb');
		if($outFP === false)
		{
			$fileStruct['error'] = UPLOAD_ERR_CANT_WRITE;
			return;
		}

		$lastLine = null;
		while(($lineN = fgets($stream, 4096)) !== false)
		{
			if($lastLine != null)
			{
				if(strpos($lineN, $boundary) === 0) break;
				if(fwrite($outFP, $lastLine) === false)
				{
					$fileStruct = UPLOAD_ERR_CANT_WRITE;
					return;
				}
			}
			$lastLine = $lineN;
		}

		if($lastLine != null)
		{
			if(fwrite($outFP, rtrim($lastLine, '\r\n')) === false)
			{
				$fileStruct['error'] = UPLOAD_ERR_CANT_WRITE;
				return;
			}
		}
		$fileStruct['error'] = UPLOAD_ERR_OK;
		$fileStruct['size'] = filesize($tempname);
		$fileStruct['tmp_name'] = $tempname;
	}
}
function zCheckRetsLogin($arrRetsConnections, $mls_id, $arrConfig){
	if(!$arrRetsConnections[$mls_id]->isLoggedIn()){
		$connect = $arrRetsConnections[$mls_id]->Connect($arrConfig["loginURL"], $arrConfig["username"], $arrConfig["password"]);

		if (!$connect) {
			echo "  + Not connected: mls_id: ".$mls_id." | loginURL: ".$arrConfig["loginURL"]."<br>\n";
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
	global $arrRetsConnections, $arrRetsConfig; 

	foreach ($arrRetsConfig as $mls_id=>$retsConfig) {
		if(!isset($arrRetsConfig[$mls_id]["enableDataDownload"]) || !$arrRetsConfig[$mls_id]["enableDataDownload"]){
			continue;
		}
		$arrConfig=$arrRetsConfig[$mls_id];
 
		
		if(!isset($arrRetsConnections[$mls_id])){
			$arrRetsConnections[$mls_id] = new phRETS;
			$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";
			// $arrRetsConnections[$mls_id]->SetParam("debug_mode", true);
			// $arrRetsConnections[$mls_id]->SetParam("debug_file", "/var/jetendo-server/jetendo/sites/retsDataDownloadLog.txt");
			$arrRetsConnections[$mls_id]->AddHeader("RETS-Version", "RETS/1.7.2");
			$arrRetsConnections[$mls_id]->AddHeader("User-Agent", "RETSConnector/1.0");
		}
		// if($mls_id != 27){
		// 	continue;
		// }

		//var_dump($arrRetsConnections);exit;

		if(!zCheckRetsLogin($arrRetsConnections, $mls_id, $arrConfig)){
			echo "Failed to connect to ".$mls_id."\n";
			continue;
		}
		if(!$arrRetsConnections[$mls_id]->isLoggedIn()){
			$connect = $arrRetsConnections[$mls_id]->Connect($arrConfig["loginURL"], $arrConfig["username"], $arrConfig["password"]);

			if (!$connect) {
				echo "  + Not connected: mls_id: ".$mls_id." | loginURL: ".$arrConfig["loginURL"]."<br>\n";
				print_r($arrRetsConnections[$mls_id]->Error());
				zEmailErrorAndExit("MLS ID ".$mls_id." connection failed", "RETS connection failed in rets download data script.", true);
				return false;
			}else{
				echo "Connected to mls_id=".$mls_id."\n";
			}
		}else{
			echo "Trying to re-use existing connection to mls_id=".$mls_id."\n";
		} 
		$dataPath=get_cfg_var("jetendo_share_path")."mls-data/temprets/".$mls_id."/";
		if(!is_dir($dataPath)){
			mkdir($dataPath, 0777);
		}

		// dont delete this works for all 4 data feeds.
		// $resource="Property";
		// $type=$arrRetsConfig[$mls_id]["listingMediaField"];
		// // $send_id="1060818"; // can be comma separated, then you'd have to analyze the Content-ID
		// $send_id="1000107"; // 27 |  can be comma separated, then you'd have to analyze the Content-ID
		// // $send_id="1075137"; //  31 | can be comma separated, then you'd have to analyze the Content-ID
		// // $send_id="4453489"; // 25 | can be comma separated, then you'd have to analyze the Content-ID
		// $location=$arrRetsConfig[$mls_id]["locationEnabled"]; 
		// $photos=$arrRetsConnections[$mls_id]->GetObject("Property", $arrRetsConfig[$mls_id]["listingMediaField"], $send_id, '*', $location);
		// // $photos = $arrRetsConnections[$mls_id]->GetObject("Property", $arrRetsConfig[$mls_id]["listingMediaField"], getSysIdByListingId("26-1060818"), 1, 0); 
		// $fh=fopen($dataPath."photos.txt", "w");
		// fwrite($fh, json_encode($photos));
		// fclose($fh);
		// echo "saved photos\n";
		// exit;

		// do this once a day only
		//$arrRetsConnections[$mls_id]->GetMetadataXMLAsFile($dataPath."metadata.1.xml");
		//echo "metadata xml saved\n";
		//exit;

		$previous_start_time = "1980-01-01T00:00:00";
		//$previous_start_time = "2020-04-18T00:00:00"; // now to keep data small

		$arrRetsConnections[$mls_id]->SetParam("dataTimestampField", $arrRetsConfig[$mls_id]["dataTimestampField"]);


		for($i=0;$i<count($arrRetsConfig[$mls_id]["dataClasses"]);$i++){
			$file_name=$arrRetsConfig[$mls_id]["dataFileNames"][$i];
			$class=$arrRetsConfig[$mls_id]["dataClasses"][$i];

			echo "+ Property:{$class}<br>\n";
			$fh = fopen($dataPath.$file_name, "w");

			$maxrows = true;
			$offset = 1;
			$limit = 10;
			$fields_order = array();

			$photoKeyFieldIndex=-1;
			$photoDateFieldIndex=-1;
			while ($maxrows) {

				// TODO: add field with the query to use for each class.
				$query = "({$arrRetsConfig[$mls_id]["dataTimestampField"]}={$previous_start_time}+)";
				if($arrRetsConfig[$mls_id]["dataQuery"]!=""){
					$query.=",".$arrRetsConfig[$mls_id]["dataQuery"];
				}
				$query.="";

				// run RETS search
				echo "   + Query: {$query}  Limit: {$limit}  Offset: {$offset}\n";
				$search = $arrRetsConnections[$mls_id]->SearchQuery("Property", $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => $arrRetsConfig[$mls_id]["dataFormat"], 'Count' => 1, 'QueryType' => 'DMQL2'));

				if ($arrRetsConnections[$mls_id]->NumRows() > 0) {

					if ($offset == 1) {
						// print filename headers as first line
						$fields_order = $arrRetsConnections[$mls_id]->SearchGetFields($search);

						// array_push($fields_order, "photo_url"); // maybe other fields too
 
						fwrite($fh, implode("\t", $fields_order)."\n");

					}

					$arrListing=array(); 

					while ($record = $arrRetsConnections[$mls_id]->FetchRow($search)) {
						$this_record = array();
						foreach ($fields_order as $fo) { 
							// if($val != "photo_url"){
								$this_record[] = $record[$fo]; 
							// }
						}
						// $this_record[] = ""; // add blank for last column which is the photo_url field
						// var_dump($this_record);
 

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
							$listing["new"]=true;
							$listing["update"]=true;
							$listing["updatePhotos"]=true;
						}else{
							$row=$db->fetch_array(MYSQLI_ASSOC);
							if($listing["timestamp"] != $row["listing_track_external_timestamp"]){
								// update data
								array_push($arrListing, $listing["listingID"]);
							}
							if($listing["timestamp"] != $row["listing_track_external_photo_timestamp"]){
								// update images
								array_push($arrPhotoKey, $listing["photoKey"]);
							}
						}
						if($listing["new"]){
							// insert listing
						}else if($listing["update"]){
							// update listing
						}
						array_push($arrListing, $listing);

 					}
					$offset = ($offset + $arrRetsConnections[$mls_id]->NumRows());
 					// get photos if needed

 					// for debugging only
 					// $arrListing=array(array(
						// 	"record"=>array(),
						// 	"timestamp"=>"",
						// 	"photoTimestamp"=>"",
						// 	"listingID"=>"1001119",
						// 	"photoKey"=>"1001119",
						// 	"photoCount"=>30,
						// 	"photoVerifiedCount"=>0,
						// 	"new"=>true,
						// 	"update"=>true,
						// 	"updatePhotos"=>true
 					// ));

					// need to store the images with same hash path, or change how the front references them.  also impacts the delete script.

 					$imageRootPath="/var/jetendo-server/jetendo/sites-writable/sa_farbeyondcode_com/mls-images/";
					// it is safe to do new rets api call at any time, because each call returns the full data.
 					for($n=0;$n<count($arrListing);$n++){
 						$listing=$arrListing[$n];

 						if(is_numeric($listing["photoCount"]) && $listing["photoCount"] > 0){
		 					for($g=1;$g<$listing["photoCount"];$g++){
		 						if(file_exists($imageRootPath.$listing["listingID"]."-"-$g.".jpg")){
		 							$listing["photoVerifiedCount"]++;
		 						}
		 					}
		 					if($listing["photoVerifiedCount"]!=$listing["photoCount"]){
		 						$listing["updatePhotos"]=true;
		 					}

	 						if($listing["updatePhotos"]){
								$arrPhoto=array();

								$locationEnabled=$arrRetsConfig[$mls_id]["locationEnabled"]; 

								$filename="/var/jetendo-server/jetendo/sites-writable/sa_farbeyondcode_com/aphoto.txt";
								$locationEnabled=0; // temporarily force binary download to see how to store the files.
								$arrPhoto=$arrRetsConnections[$mls_id]->GetObject("Property", $arrRetsConfig[$mls_id]["listingMediaField"], $listing["photoKey"]);//, '*', $locationEnabled);
								$fh2=fopen($filename, "wb");
								// if we request the same listing too fast, it will return no images, so we should skip this until later.
								if($arrPhoto[0]["Length"] > 150){
									fwrite($fh2, trim($arrPhoto[0]["Data"]));
									echo("done4");
									exit;


									// silently remove any old images first to avoid wasting space
									for($f=1;$f<=50;$f++){
										@unlink($imageRootPath.$listing["listingID"]."-".$f.".jpg");
									}
									// put the images with the final file name in the final destination
									$fh2=fopen($filename, "rb");
									$parser=new HttpMultipartFileParser();
									$parser->parse_multipart($fh2, null, true, $imageRootPath.$listing["listingID"]);
		  						}
							}
						}
						fwrite($fh, implode("\t", $this_record)."\n");
					}
				}

				$maxrows = $arrRetsConnections[$mls_id]->IsMaxrowsReached();
				echo "    + Total found: {$arrRetsConnections[$mls_id]->TotalRecordsFound()}<br>\n";

				$arrRetsConnections[$mls_id]->FreeResult($search);
				break;
			}

			fclose($fh);

			// echo "stop after one\n";			exit;
			echo "  - done<br>\n";
		} 

	}
	return true;
}

function getImageHashPath(){
	// /zretsphotos/26/54/a/26-1070438-1.jpeg
}
zDownloadRetsData();
 
?>