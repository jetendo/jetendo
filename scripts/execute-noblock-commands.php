<?php
require("library.php");
set_time_limit(70);
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
}

$debug=false; // never go live with this true, since it prevents multi-process execution.
$timeout=60; // seconds
$timeStart=microtimeFloat();
$completePath=get_cfg_var("jetendo_root_path")."execute/complete/";
$startPath=get_cfg_var("jetendo_root_path")."execute/start/";

//$processorCount=`/bin/cat /proc/cpuinfo | /bin/grep processor | /usr/bin/wc -l`;

$runningThreads=0;

/*
$commandGroups=array();
$commandGroups["image"]=8;
$commandGroups["login"]=8;
$commandGroups["http"]=16;
$commandGroups["serveradministrator"]=4;

$commandTypeLookup=array();
$commandTypeLookup["convertHTMLTOPDF"]="image";
$commandTypeLookup["getDiskUsage"]="serveradministrator";
$commandTypeLookup["getFileMD5Sum"]="serveradministrator";
$commandTypeLookup["imageMagickConvertSVGtoPNG"]="image";
$commandTypeLookup["getImageMagickIdentify"]="image";
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



$descriptorspec = array(
   0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
   1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
   2 => array("pipe", "r") // stderr is a file to write to
   //2 => array("file", "/tmp/error-output.txt", "a") // stderr is a file to write to
);

$cwd = '/tmp';
$env = array('some_option' => 'aeiou');

$process = proc_open('php', $descriptorspec, $pipes, $cwd, $env);

if (is_resource($process)) {
    // $pipes now looks like this:
    // 0 => writeable handle connected to child stdin
    // 1 => readable handle connected to child stdout
    // Any error output will be appended to /tmp/error-output.txt

    fwrite($pipes[0], '<?php print_r($_ENV); ?>');
    fclose($pipes[0]);

// loop them when blocking is off OR try the select method: http://php.net/manual/en/function.stream-select.php
stream_set_blocking($pipes[1], false);


    echo stream_get_contents($pipes[1]);
    fclose($pipes[1]);

    // It is important that you close any pipes before calling
    // proc_close in order to avoid a deadlock
    $return_value = proc_close($process);

    echo "command returned $return_value\n";
}

background, but track how many per command.
put a limit on how many simultaneous in command types
*/

$script='/usr/local/bin/identify /var/jetendo-server/jetendo/sites/out.png';
if($debug && !zIsTestServer()){
	$background=' 2>&1 ';
}else{
	$background=" > /dev/null 2>/dev/null &";
}
// $arrEntry=array();
// while(true){
// 	$handle=opendir($startPath);
// 	if($handle){
// 		while (false !== ($entry = readdir($handle))) {
// 			if(array_key_exists($entry, $arrEntry)){
// 				continue;
// 			}
// 			if(substr($entry, strlen($entry)-4, 4) !=".txt"){
// 				continue;
// 			}
// 			$phpCmd=$script.escapeshellarg($entry).$background;
// 			if($debug){
// 				$c=file_get_contents($startPath.$entry);
// 				echo($script." $'".str_replace("\t", "\\t", $c)."' 'debug'\n\n"); 
// 			}
// 			echo `$phpCmd`;
// 			$arrEntry[$entry]=true;
// 		}
// 		closedir($handle);
// 	}
// 	usleep(30000); // wait 30 milliseconds

// 	if(microtimeFloat() - $timeStart > $timeout){
// 		echo "Timeout reached";
// 		exit;
// 	}
// }
?>