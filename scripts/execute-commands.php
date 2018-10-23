<?php
require("library.php");
set_time_limit(70);
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}

$debugQueue=true;
$debug=false; // never go live with this true, since it prevents multi-process execution.
$timeout=60; // seconds
$timeStart=microtimeFloat();
$completePath=get_cfg_var("jetendo_root_path")."execute/complete/";
$startPath=get_cfg_var("jetendo_root_path")."execute/start/";
$activePath=get_cfg_var("jetendo_root_path")."execute/active/";

$arrPath=array($completePath, $startPath, $activePath);
if(!is_dir($activePath)){
	mkdir($activePath, 0770);
}
// scale relative to cpu count
$processorCount=`/bin/cat /proc/cpuinfo | /bin/grep processor | /usr/bin/wc -l`;
$commandGroups=array();
$commandGroups["image"]=max(4, intval($processorCount));
$commandGroups["imageidentify"]=max(8, intval($processorCount)*3);
$commandGroups["login"]=max(4, intval($processorCount));
$commandGroups["http"]=max(8, intval($processorCount)*2);
$commandGroups["serveradministrator"]=max(4, intval(intval($processorCount)/2));

$commandQueue=array();
$commandActive=array();
$commandGroupActive=array();
$commandGroupActive["image"]=0;
$commandGroupActive["imageidentify"]=0;
$commandGroupActive["login"]=0;
$commandGroupActive["http"]=0;
$commandGroupActive["serveradministrator"]=0;

$commandTypeLookup=array();
$commandTypeLookup["convertHTMLTOPDF"]="image";
$commandTypeLookup["getDiskUsage"]="serveradministrator";
$commandTypeLookup["getFileMD5Sum"]="serveradministrator";
$commandTypeLookup["imageMagickConvertSVGtoPNG"]="image";
$commandTypeLookup["getImageMagickIdentify"]="imageidentify";
$commandTypeLookup["getImageMagickConvertResize"]="image";
$commandTypeLookup["getImageMagickConvertApplyMask"]="image";
$commandTypeLookup["getUserList"]="serveradministrator";
$commandTypeLookup["getScryptCheck"]="login";
$commandTypeLookup["getScryptEncrypt"]="login";
$commandTypeLookup["getSystemIpList"]="serveradministrator";
$commandTypeLookup["getNewerCoreMVCFiles"]="serveradministrator";
$commandTypeLookup["gzipFilePath"]="serveradministrator";
$commandTypeLookup["httpDownload"]="http";
$commandTypeLookup["httpJsonPost"]="http";
$commandTypeLookup["httpDownloadToFile"]="http";
$commandTypeLookup["importSite"]="serveradministrator";
$commandTypeLookup["importSiteUploads"]="serveradministrator";
$commandTypeLookup["installThemeToSite"]="serveradministrator";
$commandTypeLookup["mysqlDumpTable"]="serveradministrator";
$commandTypeLookup["mysqlRestoreTable"]="serveradministrator";
$commandTypeLookup["publishNginxSiteConfig"]="serveradministrator";
$commandTypeLookup["renameSite"]="serveradministrator";
$commandTypeLookup["sslDeleteCertificate"]="serveradministrator";
$commandTypeLookup["sslGenerateKeyAndCSR"]="serveradministrator";
$commandTypeLookup["sslInstallCertificate"]="serveradministrator";
$commandTypeLookup["sslSavePublicKeyCertificates"]="serveradministrator";
$commandTypeLookup["sslInstallLetsEncryptCertificate"]="serveradministrator";
$commandTypeLookup["tarZipFilePath"]="serveradministrator";
$commandTypeLookup["tarZipSitePath"]="serveradministrator";
$commandTypeLookup["tarZipSiteUploadPath"]="serveradministrator";
$commandTypeLookup["verifySitePaths"]="serveradministrator";
$commandTypeLookup["saveFaviconSet"]="image";
$commandTypeLookup["convertFileCharsetISO88591toUTF8"]="serveradministrator";
$commandTypeLookup["gitClone"]="serveradministrator";
$commandTypeLookup["installSublimeProjectFile"]="serveradministrator";



$runningThreads=0;

$script='/usr/bin/php "'.get_cfg_var("jetendo_scripts_path").'execute-commands-process.php" ';
if(!zIsTestServer()){
	$debug=false;
}
if($debug && !zIsTestServer()){
	$background=' 2>&1 ';
}else{
	$background=" > /dev/null 2>/dev/null &";
}
$arrEntry=array();


// remove dead files
$twoHoursAgo=mktime(date("H")-2, date("i"), date("s"), date("m"),date("d"),date("Y"));
foreach($arrPath as $key=>$path){
	$handle=opendir($path);
	if($handle){
		while (false !== ($entry = readdir($handle))) {
			if($entry=="." || $entry==".." || is_dir($path.$entry)){
				continue;
			}
			$fileTime=filemtime($path.$entry);
			if($fileTime!==FALSE && $fileTime<$twoHoursAgo){
				if($debugQueue){
					echo("unlink:".$path.$entry."\n");
				}
				unlink($path.$entry);
			}
		}
		closedir($handle);
	}
}

// TODO: reload all the active commands from disk
$activeHandle=opendir($activePath);
if($activeHandle){
	while (false !== ($entry = readdir($activeHandle))) {
		if(substr($entry, strlen($entry)-4, 4) !=".txt"){
			// invalid file type
			continue;
		}
		if(file_exists($startPath.$entry.".running")){
			$type=file_get_contents($activePath.$entry);
			if($type !== FALSE){
				$commandActive[$entry]=$type;
				$commandGroupActive[$type]++;
				$runningThreads++;
			}
		}else{
			unlink($activePath.$entry);
		}
	}
	closedir($activeHandle);
}

if($debugQueue){
	echo("running threads: ".$runningThreads."\n"); 
	var_dump($commandActive);
	var_dump($commandGroupActive);
}
// possibly put image resizing outside CFML, by using php securecommand and nginx internal redirect to return early

// debug the active count, to see if we successfully throttled by group.


while(true){
	if($debugQueue){
		//echo("running threads: ".$runningThreads."\n");
	}
	$newCommandActive=array();
	foreach($commandActive as $entry=>$type){
		$activeExists=file_exists($activePath.$entry);
		if(!file_exists($startPath.$entry.".running")){
			if($activeExists){
				unlink($activePath.$entry);
			}
			// task must have finished
			// remove from active and decrease count
			if($debugQueue){
				echo("command completed:".$entry." type: ".$type."\n");
			}
			$commandGroupActive[$type]--;
			$runningThreads--;
			if($debugQueue){
				echo("running threads: ".$runningThreads."\n");
			}
			if($runningThreads<0){
				$runningThreads=0;
			}
			if($commandGroupActive[$type]<0){
				$commandGroupActive[$type]=0;
			}
		}else{
			$newCommandActive[$entry]=$type;
		}
	}
	$commandActive=$newCommandActive;
	$handle=opendir($startPath);
	if($handle){
		while (false !== ($entry = readdir($handle))) {
			if(array_key_exists($entry, $arrEntry)){
				// it's already active
				continue;
			}
			if(substr($entry, strlen($entry)-4, 4) !=".txt"){
				// invalid file type
				continue;
			}
			if(isset($commandQueue[$entry])){
				$type=$commandQueue[$entry];
				$groupLimit=$commandGroups[$type];
				if($debugQueue){
				//	echo("command in queue:".$entry." type: ".$type."\n");
				}
			}else{
				//$phpCmd=$script.escapeshellarg($entry).$background;

				$c=file_get_contents($startPath.$entry);
				echo($script." $'".str_replace("\t", "\\t", $c)."' 'debug'\n\n"); 
				$parts=explode("\t", $c);
				if(isset($commandTypeLookup[$parts[0]])){
					$type=$commandTypeLookup[$parts[0]];
				}else{
					echo("Command missing in commandTypeLookup: ". $parts[0]."\n");
					unlink($startPath.$entry);
					continue;
				}
				$commandQueue[$entry]=$type;
				$groupLimit=$commandGroups[$type];
				if($debugQueue){
					echo("command queued:".$entry." type: ".$type."\n");
				}
			}
			if($commandGroupActive[$type]>=$groupLimit){
				// delay execution
				// if($debugQueue){
				// 	echo("command execution delayed:".$entry." type: ".$type."\n");
				// }
				continue;
			} 
			// this is useful for debugging background output as separate files instead of having to run the commands
			$background=" > /var/jetendo-server/jetendo/execute/complete/output.".$entry.".temp 2>/var/jetendo-server/jetendo/execute/complete/error.".$entry.".temp &";

			$phpCmd=$script.escapeshellarg($entry).$background;
			rename($startPath.$entry, $startPath.$entry.".running");
			if(file_exists($startPath.$entry.".running")){
				file_put_contents($activePath.$entry, $type);
			}
			echo `$phpCmd`;
			$commandGroupActive[$type]++;
			$runningThreads++;
			if($debugQueue){
				echo("running threads: ".$runningThreads."\n");
			}
			$commandActive[$entry]=$commandQueue[$entry];
			unset($commandQueue[$entry]);
			if($debugQueue){
				echo("command activated:".$entry." type: ".$type."\n");
			}
			$arrEntry[$entry]=true;
		}
		closedir($handle);
	}
	usleep(30000); // wait 30 milliseconds

	if(microtimeFloat() - $timeStart > $timeout){
		echo "Timeout reached";
		exit;
	}
}
?>