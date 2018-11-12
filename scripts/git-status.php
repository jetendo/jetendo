<?php
// this is executed from cfml-tasks.php once per hour on the test server only.
// php /var/jetendo-server/jetendo/scripts/git-status.php

echo "i disabled this so we don't need password in configuration";
exit;
$debug=false; // set to true to only check 3 git repos and var_dump the result
set_time_limit(1000);
$sshKey=get_cfg_var("jetendo_git_ssh_key_path");
$postObj=array(); 
$postObj["zusername"]=get_cfg_var("jetendo_admin_username");
$postObj["zpassword"]=get_cfg_var("jetendo_admin_password");

// this is admin username so that developers can have more then one computer posting data
$email=get_cfg_var("jetendo_admin_username");
$postObj["email"]=$email;

if($postObj["zusername"] =='' || $sshKey == '' || !is_file($sshKey) || $postObj["zpassword"] ==''){
	echo('jetendo_git_ssh_key_path, jetendo_admin_username and jetendo_admin_password are required to this to work.');
	exit;
}

echo "Checking for internet connection (ping yahoo)\n";
$cmd=`/bin/ping -c 1 yahoo.com 2>&1`;
if(strstr(trim($cmd), "0 received") !== FALSE){
	echo "Internet not available.\n";
	exit;
}
$arrSites=array();
$g=0;
$mp=get_cfg_var("jetendo_sites_path");
$handle2 = opendir($mp);
if($handle2 !== FALSE) {
    while (false !== ($entry = readdir($handle2))) {
		$curPath=$mp.$entry;
		if($entry =="." || $entry ==".." || !is_dir($curPath)){
			continue;
		}
		if(!is_dir($curPath."/.git")){
			array_push($arrSites, $entry.' has no .git directory yet.');
		}else{
			chdir($curPath);
			echo $entry."\n";
			// -C ".escapeshellarg($curPath)."
			$cmd="/usr/bin/git status -s";
			$s=`$cmd`;
			$filesChanged=false;
			$synced=false;
			if($s!=''){
				$filesChanged=true;
			}else{
				// -C ".escapeshellarg($curPath)."
				$cmd="/usr/bin/git push --dry-run origin master";
				$sshCMD="/usr/bin/ssh-agent bash -c '/usr/bin/ssh-add $sshKey; ".$cmd."'";
				$s2=`$sshCMD 2>&1`; 
				if(strstr(trim($s2), "Everything up-to-date") !== FALSE){
					$synced=true;
				}
			}
			if($filesChanged){
				array_push($arrSites, $entry.' has modifications.');
			}else if(!$synced){
				array_push($arrSites, $entry.' changes have been commited, but not synced.');
			}
			if($debug && $g >=3){
				break;
			}
		}
		$g++;
	}
}
$domain=get_cfg_var("jetendo_admin_domain");
// do curl post
$url="$domain/z/server-manager/api/git-status/storeGitStatus";
$postObj["data"]=implode("\n", $arrSites);

$arrFields=array();
foreach($postObj as $key=>$value){
	array_push($arrFields, $key."=".urlencode($value));
}

//open connection
$ch = curl_init();

//set the url, number of POST vars, POST data
curl_setopt($ch,CURLOPT_URL, $url);
curl_setopt($ch,CURLOPT_POST, count($arrFields));
curl_setopt($ch,CURLOPT_POSTFIELDS, implode("&", $arrFields));
curl_setopt($ch,CURLOPT_RETURNTRANSFER, true);
//execute post
$result = curl_exec($ch);
if(trim($result) != "1"){
	echo("Server manager login didn't work or API has changed.\n");
	exit;
}
//close connection
curl_close($ch);

if($debug){
	var_dump($url);
	var_dump($postObj);
}else{
	echo('done');
}
?>

