<?php
/*
// add these to crontab -e
1 3 * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-idx-3.php >/dev/null 2>&1
5 3 * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/import-idx-15.php >/dev/null 2>&1
*/
require(get_cfg_var("jetendo_scripts_path")."library.php");
error_reporting(E_ALL);
set_time_limit(160000); // kill after almost 2 hours
function SureRemoveDir($dir, $DeleteMe) {
    if(!$dh = @opendir($dir)) return;
    while (false !== ($obj = readdir($dh))) {
        if($obj=='.' || $obj=='..') continue;
        if (!@unlink($dir.'/'.$obj)) SureRemoveDir($dir.'/'.$obj, true);
    }
    if ($DeleteMe){
        closedir($dh);
        @rmdir($dir);
    }
}



function processFTP($importMLSID){
	global $arrRetsConfig;
	$config=false;
	foreach($arrRetsConfig as $mls_id=>$tempConfig){
		if($mls_id==$importMLSID && isset($tempConfig["ftpDownloadEnabled"]) && $tempConfig["ftpDownloadEnabled"]){
			$config=$tempConfig;
		}
	}
	if(!is_array($config)){
		echo "This idx not a ftp download enabled mls id:".$importMLSID;
		exit;
	}
	$ftp_server=$config["host"]; // i.e. idx.living.net 
	$ftp_user_name=$config["username"];
	$ftp_user_pass=$config["password"];
	$destination_file=$config["localFile"];
	$source_file=$config["remoteFile"];
	$unzipPath=$config["unzipPath"];
	$unique_id=$config["unique_id"];
	$unzipOnly=true;

	var_dump($config);

	if(!file_exists($unzipPath)){
		mkdir($unzipPath);
	}

	$dir = dirname($destination_file);
	$successFile=$dir.'/success'.$unique_id.'.txt';
	$now=date("F d Y");
	if (file_exists($successFile) && filesize($successFile) != 0) {
		$fp=fopen($successFile,'r');
		$filedate=fread($fp,filesize($successFile));
		fclose($fp);
		$destinationDate=date ("F d Y", @filemtime($destination_file));
		if($now == $filedate){
			echo 'mls data already downloaded and unzipped on '. $filedate."\n";
			exit();
		}
		if($destinationDate != $now){
			@unlink($destination_file);
		}
	}
	echo "1\n";
	$download=false;
	$remoteSize=false;
	if (!$download) { 
		$retries=10;
		$tries=0;
		while(!$download){		
			// set up basic connection
			$conn_id = @ftp_connect($ftp_server); 

			// login with username and password
			$login_result = @ftp_login($conn_id, $ftp_user_name, $ftp_user_pass); 

			// check connection
			if ((!$conn_id) || (!$login_result)) { 
			   echo "FTP connection has failed!";
			   echo "Attempted to connect to $ftp_server for user $ftp_user_name\n"; 

	            $emailbody="FTP connection failed when attempted to connect to $ftp_server for user $ftp_user_name to download $source_file";
				zEmail("IDX FTP connection failed for ".$source_file, $emailbody);
				echo $emailbody;
				exit; 
			} else {
			   echo "Connected to $ftp_server, for user $ftp_user_name\n";
			}
			ftp_set_option($conn_id, FTP_TIMEOUT_SEC, 5);

			// upload the file
			if(file_exists($destination_file)){
				$fs=filesize($destination_file);
			}else{
				$fs=0;
			}
			ftp_pasv($conn_id,true);
			$ret = @ftp_nb_get($conn_id, $destination_file, $source_file, FTP_BINARY, $fs);		
			$counter=0;
			if($ret == FTP_FAILED){
	            $emailbody="FTP download failed due to permissions when attempted to connect to $ftp_server for user $ftp_user_name\nto download $source_file\nto:$destination_file";
				zEmail("IDX FTP connection failed for ".$source_file, $emailbody);
				echo $emailbody;

			   exit; 
			}
			while ($ret == FTP_MOREDATA) {
			   
			   // Do whatever you want
			   if($counter==0){
				echo ".";
			   }
			   $counter++;
			   if($counter>200){
					$counter=0;
			   }

			   // Continue downloading...
			   $ret = ftp_nb_continue($conn_id);
			}
			if ($ret == FTP_FINISHED) {
				$download=true;
			}
			// close the FTP stream 
			ftp_close($conn_id); 

			// check how many tries were done
			$tries++;
			if(!$download && $tries>=$retries){
			   echo "FTP Download of $source_file failed 10 times - now aborting\n";
			   exit(1);
			}
		}
	}
	echo "Downloaded $source_file from $ftp_server to local file: $destination_file\n";

	echo "2\n";
	if($unzipOnly){
		$sh= '/usr/bin/7z e "'.$destination_file.'" -y -o"'.$unzipPath.'"';
		`$sh`;
		if($unique_id==1){
			@unlink($destination_file);
		}else if($unique_id==2){
			@unlink($destination_file);
		}
	}else{
		$path=$dir."/".$zip1;
		$sh= '/usr/bin/7z e "'.$path.'" -y -o"'.$unzipPath.'"';
		`$sh`;
		@unlink($path);
	}
	$fp=fopen($dir.'/success'.$unique_id.'.txt','w');
	fwrite($fp,$now);
	fclose($fp);

	system("/bin/chown ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($unzipPath.$config["finalFileName"]));
	system("/bin/chmod 777 ".escapeshellarg($unzipPath.$config["finalFileName"]));
	rename($unzipPath.$config["finalFileName"], $config["finalPath"].$config["finalFileName"]);
	echo "Files unzipped and success.txt updated!\n";
}
?> 