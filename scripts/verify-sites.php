<?php
require('library.php');

function exitWithLogNotification(){
	global $arrError, $logDir, $preview;
	$host=`hostname`;
	$serverSecurePath=get_cfg_var("jetendo_root_private_path"); 
	if(count($arrError)){
		$arrNewError=array();
		if($serverSecurePath !=""){
			if(substr($serverSecurePath, strlen($serverSecurePath)-1, 1) != "/"){
				$serverSecurePath.="/";
			}
			if(file_exists($serverSecurePath."verifySitesLog.txt")){
				$contents=file_get_contents($serverSecurePath."verifySitesLog.txt");
				$arrCurrentLog=explode("\n", trim($contents));
				for($i=0;$i<count($arrError);$i++){
					$found=false;
					for($i2=0;$i2<count($arrCurrentLog);$i2++){
						if(trim($arrCurrentLog[$i2]) == trim($arrError[$i])){
							$found=true;
							break;
						}
					}
					if(!$found){
						array_push($arrNewError, $arrError[$i]);
					}
				}
			}else{
				$arrNewError=$arrError;
			}
			$fp=fopen($serverSecurePath.'verifySitesLog.txt', "w");
			fwrite($fp, implode("\n", $arrError));
			fclose($fp);
			chown($serverSecurePath.'verifySitesLog.txt', get_cfg_var("jetendo_www_user"));
			chgrp($serverSecurePath.'verifySitesLog.txt', get_cfg_var("jetendo_www_user"));
			chmod($serverSecurePath.'verifySitesLog.txt', 0660);
		}
		if(count($arrNewError)){

			$to      = get_cfg_var('jetendo_developer_email_to');
			$subject = 'Verify sites had new errors on '.$host;

			$headers = 'From: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
				'Reply-To: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
				'X-Mailer: PHP/' . phpversion();
			$message = "Errors found when running the verify sites task.\n\nPlease note that items with \"seal-healing notice\" require no further action, but items with \"Attention required\" must be reviewed and fixed manually.\n\n".implode("\n", $arrNewError);

			mail($to, $subject, $message, $headers);
		}
		echo count($arrNewError)." new errors.\n\n";
		for($i=0;$i<count($arrError);$i++){
			echo($arrError[$i]."\n");
		}
	}else{
		if($serverSecurePath != ""){
			@unlink($serverSecurePath.'verifySitesLog.txt');
		}
		echo('No errors found');	
	} 
	exit;
}
function getAvailableUpgradePackages(){
	`/usr/bin/apt-get update`;
	$arrPackage=array();
	$arrPackage['results']=`/usr/bin/apt-get -s upgrade`;
	if(strpos($arrPackage['results'], "\n0 upgraded") !== FALSE){
		$arrPackage['available']=false;
	}else{
		$arrPackage['available']=true;
	}
	return $arrPackage;
}
function is_dir_empty($dir) {
  if (!is_readable($dir)) return NULL; 
  return (count(scandir($dir)) == 2);
}
function verifySite($row){
	global $cmysql2, $forcePermissions, $userStruct, $preview, $verifyHomePage, $userUnusedStruct, $isTestServer, $pathStruct, $checkDNS, $dnsServer, $dnsServer2, $wwwUser, $sitesPath, $ftpEnabled;
	$siteHomedir=zGetDomainInstallPath($row["site_short_domain"]);
	$siteHomedirWritable=zGetDomainWritableInstallPath($row["site_short_domain"]);
	$siteHasError=false;
	$found=false;
	$arrError=array();
	$debug=false;
	if($row["site_active"] == 1){ 
		$time_start = microtime_float();
		echo "Verifying: ".$siteHomedir.": ";
		unset($pathStruct[$siteHomedir]);
		if(zIsTestServer()){
			$found=true; // always found on test server
			if(is_dir($siteHomedir)){
				if(is_dir_empty($siteHomedir)){
					echo("\nremoving empty site dir: ".$siteHomedir."\n");
					rmdir($siteHomedir);
				}
			}
		}else{ 
			if(substr($siteHomedir, 0, strlen($sitesPath)) != $sitesPath){
				$siteHasError=true;
				array_push($arrError, $siteHomedir." is not inside the installPath: ".$sitesPath." and it must be.");	
			}else if(!is_dir($siteHomedir)){
				$siteHasError=true;
				array_push($arrError, "Self-healing notice: ".$siteHomedir." didn't exist, and was created now. ");	
				if(!$preview){
					mkdir($siteHomedir);
				}
			}else{
				$found=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedir, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "440", "550", true, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable."zcache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable."_cache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable."zupload/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable."zuploadsecure/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
			$result=zCheckDirectoryPermissions($siteHomedirWritable, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", true, $preview, $arrError, $isTestServer);
			if(!$result){
				$siteHasError=true;
			}
		} 
	}else{
		if(is_dir($siteHomedir)){
			array_push($arrError, "Attention required: ".$siteHomedir." exists, but site is inactive. You should remove these files from the server.");	
		}
		if(is_dir($siteHomedirWritable)){
			array_push($arrError, "Attention required: ".$siteHomedirWritable." exists, but site is inactive. You should remove these files from the server.");	
		}
	}
	if($debug) echo (microtime_float()-$time_start)." seconds for directory structure\n"; $time_start=microtime_float();
	$domain=str_replace("https://", "", str_replace("http://", "", $row["site_domain"]));
	$curDomain=str_replace("www.", "", $domain);
	if($checkDNS && $row["site_disable_dns_monitor"] == "0"){
		if($row["site_ip_address"] == ""){
			$siteHasError=true;
			array_push($arrError, "Attention required: IP address not set for ".$row["site_short_domain"]." in the server manager.  Please set it now for DNS monitoring to function correctly.");	
		}else if($found){
			$cmd="/usr/bin/dig a +short $dnsServer $curDomain";
			$output1=trim(`$cmd`);
			$dnsLookupFailed=false;
			if($output1 == ""){
				sleep(3); // retry after 3 seconds because dns server FREQUENTLY failed to return a reply.
				$cmd="/usr/bin/dig a +short $dnsServer2 $curDomain";
				$output1=trim(`$cmd`);
				if($output1 == ""){
					$siteHasError=true;
					array_push($arrError, "Attention required: DNS for ".$row["site_short_domain"]." is missing.");	
					$dnsLookupFailed=true;
				}
			}
			if(!$dnsLookupFailed){
				$arrTemp=explode("\n", $output1);
				$ipmatch=false;
				for($i=0;$i<count($arrTemp);$i++){
					if(substr($arrTemp[$i], strlen($arrTemp[$i])-1, 1) == "."){
						// cname is ok - ignore it
					}else if($arrTemp[$i] == $row["site_ip_address"]){
						// ip matches - ignore it
						$ipmatch=true;
					}else if(strpos(strtolower($output1), 'connection timed out') !== false){
						continue; // skip timeout
					}else{
						$siteHasError=true;
						array_push($arrError, "Attention required: DNS for ".$curDomain." didn't match with the site's assigned IP address or had additional records, ".$row["site_ip_address"].".  Full response:".$output1."<br />");
						break;
					}
				}
			}
			$output2="";
			if(strpos($domain, "www.") !== FALSE){

				$cmd="/usr/bin/dig a +short $dnsServer2 $domain";
				$output2=trim(`$cmd`);
				$dnsLookupFailed=false;
				if($output2 == ""){
					sleep(3); // retry after 3 seconds because dns server FREQUENTLY failed to return a reply.
					$cmd="/usr/bin/dig a +short $dnsServer $domain";
					$output2=trim(`$cmd`);
					if($output2 == ""){
						$siteHasError=true;
						array_push($arrError, "Attention required: DNS for ".$domain." is missing.");	
						$dnsLookupFailed=true;
					}
				}
				if(!$dnsLookupFailed){
					$arrTemp=explode("\n", $output2);
					$ipmatch=false;
					for($i=0;$i<count($arrTemp);$i++){
						if($arrTemp[$i] == $curDomain."."){
							// cname is ok, ignore it
						}else if($arrTemp[$i] == $row["site_ip_address"]){
							// ip matches, ignore it
							$ipmatch=true;
						}else if(strpos(strtolower($output2), 'connection timed out') !== false){
							continue; // skip timeout
						}else{
							$siteHasError=true;
							array_push($arrError, "Attention required: DNS for ".$curDomain." didn't match with the site's assigned IP address or had additional records, ".$row["site_ip_address"].".  Full response:".$output2."<br />");
							break;
						}
					}
				}
			}
		}
	}
	if($debug) echo (microtime_float()-$time_start)." seconds for dns\n"; $time_start=microtime_float();
	if($debug) echo (microtime_float()-$time_start)." seconds for permissions\n"; $time_start=microtime_float();
	/*
	// TODO: this code wasn't good enough since it didn't verify the content or http response code so i disabled it.
	if($verifyHomePage){
		if($found){
			$rs=file_get_contents($row["site_domain"]."/");
			if($rs === FALSE){
				if(substr($row["site_domain"], 0, 5) == "https"){
					$rs=file_get_contents(str_replace("http:", "https:", $row["site_domain"])."/");
					if($rs === FALSE){
						array_push($arrError, "Requires attention: Failed to download home page: ".$row["site_domain"]."/");
						$siteHasError=true;
					}
				}
			}
			if($debug) echo (microtime_float()-$time_start)." seconds for home page download\n"; $time_start=microtime_float();
		}
	}*/
	if($siteHasError){
		echo "invalid\n";
		for($i=0;$i<count($arrError);$i++){
			echo $arrError[$i]."\n";
		}
		echo "\n";
	}else{
		if(!$preview){
			$cmysql2->query("update site set 
			site_verified_datetime=now(),
			site_updated_datetime=now()
			WHERE 
			site_id = '".$cmysql2->real_escape_string($row["site_id"])."'");
		}
		echo "valid\n";
	}
	return $arrError;
}


function checkFilesystem(){
	global $arrError, $wwwUser, $isTestServer, $preview;

	$dir=get_cfg_var("jetendo_root_path");
	if(is_dir("/zbackup/mysql")){
		$result=zCheckDirectoryPermissions("/zbackup/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup/backup/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup/jetendo/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup/mysql/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup/site-backup/", "root", "root", "660", "770", false, $preview, $arrError, $isTestServer);
	}
	if(is_dir("/zbackup2/mysql")){
		$result=zCheckDirectoryPermissions("/zbackup2/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup2/backup/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup2/jetendo/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup2/mysql/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
		$result=zCheckDirectoryPermissions("/zbackup2/site-backup/", "root", "root", "660", "770", false, $preview, $arrError, $isTestServer);
	}
	$result=zCheckDirectoryPermissions($dir, "root", "root", "755", "755", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."core/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."database-upgrade/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."public/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/start/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."execute/complete/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."luceevhosts/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	//$result=zCheckDirectoryPermissions($dir."railovhosts/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."themes/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."phptemp/", $wwwUser, $wwwUser, "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."scripts/", $wwwUser, $wwwUser, "440", "550", true, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_sites_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_sites_writable_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$sharePath=get_cfg_var("jetendo_share_path");
	$result=zCheckDirectoryPermissions($sharePath, $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-images/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-images-temp/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-scripts/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."task-log/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($sharePath."mls-data/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$logDir=get_cfg_var("jetendo_log_path");
	$result=zCheckDirectoryPermissions($logDir, "root", "root", "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."deploy/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."mysql-backup/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."zqueue/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."ids/", "root", "root", "660", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($logDir."sites/", $wwwUser, "root", "660", "770", true, $preview, $arrError, $isTestServer);

	// search for 777 directories/files and other world-writable files later and report them...

	$dir=zGetBackupPath();
	$result=zCheckDirectoryPermissions($dir, $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions($dir."jetendo/", $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_nginx_sites_config_path"), "root", "root", "640", "770", true, $preview, $arrError, $isTestServer);
	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_nginx_ssl_path"), "root", "root", "400", "400", false, $preview, $arrError, $isTestServer);

	$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_root_private_path"), $wwwUser, $wwwUser, "660", "770", false, $preview, $arrError, $isTestServer);
	return true;
}

ini_set('default_socket_timeout', 5);
$arrError=array();

// when debugging, enable preview to prevent any permanent changes.
$preview=false;



set_time_limit(2000);
$host=`hostname`;
echo "Checking PHP's jetendo.ini configuration: ";
if(!zCheckJetendoIniConfig($arrError)){
	// prevent more checks until corrected...
	exitWithLogNotification();
}else{
	echo "valid\n";
}

checkForSSLExpiration($arrError);


$wwwUser=get_cfg_var("jetendo_www_user");

$testDomain=get_cfg_var("jetendo_test_domain"); 
if(strpos($host, $testDomain) !== FALSE){
	$isTestServer=true;
	$checkDNS=false;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_test_server_uses_samba");
}else{
	$isTestServer=false;
	$checkDNS=true;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_server_uses_samba");
}


echo "Checking MySQL Privileges: ";
if(!checkMySQLPrivileges()){
	array_push($arrError, "You must correct mysql privileges and re-run this installation script");
	exitWithLogNotification();
}else{
	echo "valid\n";
}

$ftpEnabled=zIsFtpEnabled();
echo "Checking filesystem: ";
$result=checkFilesystem();
if(!$result){
	// prevent more checks until corrected...
	exitWithLogNotification();
}else{
	echo "valid\n";
}

$sitesPath=get_cfg_var("jetendo_sites_path");

/*
echo "Running apt-get update to check for new packages: ";
$arrPackage=getAvailableUpgradePackages();
if($arrPackage['available']){
	echo "New packages available.\n".$arrPackage['results'];
	// temporarily commented to avoid emails
	//array_push($arrError, "Packages are available to be installed with apt-get.\nPackages\n".$arrPackage['results']);
}else{
	echo "No new packages are available. Response: ".$arrPackage['results']."\n";
}
*/
$forcePermissions=false; 
$userUnusedStruct=array();
$pathStruct=array();
if($forcePermissions==false){
} 
$handle = opendir($sitesPath);
if($handle !== FALSE) {
    while (false !== ($entry = readdir($handle))) {
		if($entry !="." && $entry !=".." && is_dir($sitesPath.$entry)){
			$pathStruct[$sitesPath.$entry."/"]=true;
		}
    }
	closedir($handle);
}
$dnsServer=""; // use local dns
$dnsServer2=""; // use local dns
if($isTestServer){
	$d=get_cfg_var("jetendo_test_dns_server");
	if($d !=""){
		$dnsServer="@".$d; 
	}
	$d=get_cfg_var("jetendo_test_dns_server2");
	if($d !=""){
		$dnsServer2="@".$d; 
	}
}else{
	$d=get_cfg_var("jetendo_dns_server");
	if($d !=""){
		$dnsServer="@".$d; 
	}
	$d=get_cfg_var("jetendo_dns_server2");
	if($d !=""){
		$dnsServer2="@".$d; 
	}
}
$cmd="/bin/cat /etc/passwd";
$result=trim(`$cmd`);
$arrPasswd=explode("\n", $result);
$userStruct=array();
for($i=0;$i<count($arrPasswd);$i++){
	$arrTemp=explode(":", $arrPasswd[$i]);
	$userStruct[$arrTemp[0]]=$arrTemp;
	if(count($arrTemp) < 6){
		array_push($arrError, "Failed to read one or more users from system.");
		break;
	}else if(substr($arrTemp[5], 0, strlen($sitesPath)-1) != $sitesPath){
		$userUnusedStruct[$arrTemp[0]]=true;
	}
}

$fail=false;
$cmysql2=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
if($cmysql2->error != ""){ 
	$fail=true;
	array_push($arrError, "db connect error:".$cmysql2->error);	
}
if(!$fail){
	$r=$cmysql2->query("select * from site where site_active='1' and site_deleted='0' ORDER BY site_verified_datetime ASC, site_short_domain asc");
	if($cmysql2->error != ""){ 
		$fail=true;
		array_push($arrError, "db error:".$cmysql2->error);	
	}
	if(!$fail){
		$arrRow=array();
		while($row=$r->fetch_array(MYSQLI_ASSOC)){
			$arrError2=verifySite($row);
			for($i=0;$i<count($arrError2);$i++){
				array_push($arrError, $arrError2[$i]);
			}
			array_push($arrRow, $row);
		}

		$uniqueHost=array();
		if(!$isTestServer){
			// fix /etc/hosts
			$arrHosts=array();
			for($i=0;$i<count($arrRow);$i++){
				$row=$arrRow[$i];
				if($row["site_ip_address"] == ""){
					continue;
				}
				if($row['site_live'] == '1' && $row['site_track_users'] == '1'){
					$r2=$cmysql2->query("select * from site_option, site_x_option where 
						site_option.site_option_id = site_x_option.site_option_id and 
						site_option.site_option_name = 'Visitor Tracking Code' and 
						site_x_option.site_id = '".$row["site_id"]."' and 
						site_x_option_deleted='0' and 
						site_option.site_option_deleted='0' and 
						site_option.site_id = '0' ");
					if($cmysql2->error != ""){ 
						$fail=true;
						array_push($arrError, "db error:".$cmysql2->error);	
					}
					$hasTracking=false;
					while($row2=$r2->fetch_array(MYSQLI_ASSOC)){
						if(trim($row2['site_x_option_value']) != ""){
							$hasTracking=true;
						}
					}
					if(!$hasTracking){
						$r2=$cmysql2->query("select * from site_option, site_x_option where 
							site_option.site_option_id = site_x_option.site_option_id and 
							site_option.site_option_name = 'Global HTML Head Source Code' and 
							site_x_option.site_id = '".$row["site_id"]."' and 
							site_x_option_deleted='0' and 
							site_option.site_option_deleted='0' and 
							site_option.site_id = '0' ");
						if($cmysql2->error != ""){ 
							$fail=true;
							array_push($arrError, "db error:".$cmysql2->error);	
						} 
						while($row2=$r2->fetch_array(MYSQLI_ASSOC)){
							if(trim($row2['site_x_option_value']) != ""){
								$hasTracking=true;
							}
						}
					}
					if(!$hasTracking){
						array_push($arrError, $row["site_short_domain"]." doesn't have tracking code installed.");
					}
				}
				$domain=str_replace(".".get_cfg_var("jetendo_test_domain"), "", $row["site_short_domain"]);
				$shortDomain=$domain;
				$c=substr_count($domain, ".");
				if($c==1){
					$domain="www.".$domain;
				}

				if($shortDomain != $domain){
					array_push($arrHosts, $row["site_ip_address"]." ".$shortDomain);
					$uniqueHost[$shortDomain]=true;
				}
				array_push($arrHosts, $row["site_ip_address"]." ".$domain);
				$uniqueHost[$domain]=true;

			}
			$hostContents=implode("\n", $arrHosts);
			$cmd="/bin/cat /etc/hosts";
			$contents=`$cmd`;
			$beginString="\n#jetendo-begin-hosts\n";
			$endString="\n#jetendo-end-hosts\n";
			$begin=strpos($contents, $beginString);
			if($begin===FALSE){
				$contents.=$beginString;
				$begin=strpos($contents, $beginString);
			}
			$end=strpos($contents, $endString, $begin);
			if($end===FALSE){
				$contents.=$endString;
				$end=strpos($contents, $endString);
			}
			$fileBeginContents=substr($contents, 0, $begin+strlen($beginString));
			$fileContentsHosts=trim(substr($contents, $begin+strlen($beginString)+1, $end-($begin+strlen($beginString)+1)));
			$fileEndContents=substr($contents, $end);

			$arrLine=explode("\n", $fileBeginContents);
			$arrNew=array();
			for($i=0;$i<count($arrLine);$i++){
				$arrLine2=explode(" ",trim(str_replace("\t", " ", $arrLine[$i])));
				if(count($arrLine2)){
					$d=$arrLine2[count($arrLine2)-1];
					if(isset($uniqueHost[$d])){
						//echo('Skipping '.$d."\n");
						continue;
					}else{
						$uniqueHost[$d]=true;
					}
				}
				array_push($arrNew, trim($arrLine[$i]));
			}
			$fileBeginContents=implode("\n", $arrNew);
			$arrLine=explode("\n", $fileEndContents);
			$arrNew=array();
			for($i=0;$i<count($arrLine);$i++){
				$arrLine2=explode(" ",trim(str_replace("\t", " ", $arrLine[$i])));
				if(count($arrLine2)){
					$d=$arrLine2[count($arrLine2)-1];
					if(isset($uniqueHost[$d])){
						//echo('Skipping '.$d."\n");
						continue;
					}else{
						$uniqueHost[$d]=true;
					}
				}
				array_push($arrNew, trim($arrLine[$i]));
			}
			$fileEndContents=implode("\n", $arrNew);

			if($fileContentsHosts != $hostContents){
				$newFileContents=$fileBeginContents.$hostContents.$fileEndContents;

				if(!$preview){
					@unlink("/etc/hostsTemp");
					$r1="/etc/hostsTemp";
					$fp=fopen($r1, "w");
					fwrite($fp, $newFileContents);
					fclose($fp);
					chmod("/etc/hostsTemp", 644);
					@unlink("/etc/hosts");
					rename($r1, "/etc/hosts");
					`/bin/cp -f /etc/hosts /var/jetendo-server/jetendo/share/hosts`;

					$dnsMasqPath=`/usr/bin/which dnsmasq`;
					$servicePath=`/usr/bin/which service`;
					if(trim($dnsMasqPath) != ""){
						$cmd=$servicePath." dnsmasq restart";
						echo $cmd."\n";
						`$cmd`;
					}
				}
				array_push($arrError, "/etc/hosts was automatically corrected.");
			}
		}
	}
}

if(date('H') == '00'){
	// daily verification
	if(file_exists('/var/run/reboot-required')){
		$c=`/bin/cat /var/run/reboot-required.pkgs`;
		array_push($arrError, "System reboot required.  The following packages haven't been updated yet because they were in use:\n".$c);	
	}
}
// EXTRA paths in $sitesPath
unset($pathStruct[get_cfg_var("jetendo_root_path")."themes/"]);
unset($pathStruct[$sitesPath.'WEB-INF/']);
foreach($pathStruct as $key=>$val){
	array_push($arrError, "Requires attention: Extra directory in installPath: ".$key.". It is recommended you remove these files from the server or add this site using the server manager.");
}
if(!$isTestServer){
	// detect EXTRA users in /etc/passwd
	
	$arrValidUsers=array('root', 'daemon', 'bin', 'sys', 'sync', 'games', 'man', 'lp', 'mail', 'news', 'uucp', 'proxy', 'www-data', 'backup', 'list', 'irc', 'gnats', 'nobody', 'libuuid', 'syslog', 'messagebus', 'whoopsie', 'landscape', 'sshd', 'postfix', 'dnsmasq', 'nginx', 'mysql', 'ftp', 'zftpsecure', 'pulse', 'usbmux', 'rtkit', 'libvirt-qemu', 'libvirt-dnsmasq', 'ntp');
	for($i=0;$i<count($arrValidUsers);$i++){
		unset($userUnusedStruct[$arrValidUsers[$i]]);
	}
	foreach($userUnusedStruct as $key=>$val){
		array_push($arrError, "Requires attention: Extra user in /etc/passwd: ".$key.". You should delete unused linux users.");	
	}
}
exitWithLogNotification();
?>