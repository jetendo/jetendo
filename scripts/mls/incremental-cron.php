<?php
// */1 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mls/incremental-cron.php >/dev/null 2>&1
require(get_cfg_var("jetendo_scripts_path")."library.php");
set_time_limit(50);

if(zIsTestServer()){ 
     $domain=get_cfg_var("jetendo_test_admin_domain"); 
}else{ 
     $domain=get_cfg_var("jetendo_admin_domain"); 
} 
$debug=false;
if($debug && !zIsTestServer()){
	$background=' 2>&1 ';
}else{
	$background=" > /dev/null 2>/dev/null &";
}
// run only once
// open dir on mls-data
foreach($arrRetsConfig as $mls_id=>$config){
	if(isset($config["enableDataDownload"]) && $config["enableDataDownload"]){
		$path=get_cfg_var("jetendo_share_path")."mls-data/".$mls_id."/";
		$handle=opendir($path);
		if($handle){
			while (false !== ($entry = readdir($handle))) {
				if(strstr($entry, "-incremental") != FALSE){
					// rename and execute
					$newPath=str_replace("-incremental", "-processing", $entry);
					rename($path.$entry, $path.$newPath);
					$link=$domain."/z/listing/idx-incremental/index?mls_id=".$mls_id."&filename=".urlencode($newPath);
					$cmd="/usr/bin/wget -O /dev/null -o /dev/null ".escapeshellarg($link).$debug;
					echo $cmd."\n";
					`$cmd`;
					fwrite($logFile, date("Y-m-d H:i:s")."\t".$cmd."\n"); 
				}
			}
			closedir($handle);
		}
	}
}

?>