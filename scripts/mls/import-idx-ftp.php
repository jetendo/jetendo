<?php
error_reporting(E_ALL);
set_time_limit(7000); // kill after almost 2 hours
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
$ftp_server=$argv[1]; // i.e. idx.living.net 
$ftp_user_name=$argv[2];
$ftp_user_pass=str_replace("percent", "%",str_replace("amperstand","&",$argv[3]));
$destination_file=$argv[4]; //  C:\ServerData\mls-data\13\data\flagler_data.zip 
$source_file=$argv[5]; // /idx_fl_ftp_down/idx_flagler_dn/flagler_data.zip 
$unzipPath=$argv[6]; // C:\ServerData\mls-data\13\data\
$unique_id=$argv[7]; // 1
$unzipOnly=true;

if(!file_exists($unzipPath)){
	mkdir($unzipPath);
}

$dir = dirname($destination_file);
$successFile=$dir.'\success'.$unique_id.'.txt';
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
			mail("bruce@fbc.com","IDX FTP connection failed for ".$source_file, $emailbody, "From: \"Coldfusion Error\" <bruce@s4.farbeyondcode.com>\nX-Mailer: php" );
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
			mail("bruce@fbc.com","IDX FTP connection failed for ".$source_file, $emailbody, "From: \"Coldfusion Error\" <bruce@s4.farbeyondcode.com>\nX-Mailer: php" );
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
	$sh= '"C:\Program Files\7-Zip\7z.exe" e "'.$destination_file.'" -y -o"'.$unzipPath.'"';
	`$sh`;
	if($unique_id==1){
		@unlink($destination_file);
	}else if($unique_id==2){
		@unlink($destination_file);
	}
}else{
	$path=$dir."\\".$zip1;
	$sh= '"C:\Program Files\7-Zip\7z.exe" e "'.$path.'" -y -o"'.$unzipPath.'"';
	`$sh`;
	@unlink($path);
}
$fp=fopen($dir.'\success'.$unique_id.'.txt','w');
fwrite($fp,$now);
fclose($fp);
echo "Files unzipped and success.txt updated!\n";
?> 