<?php
require("library.php");
$secureScript='/var/jetendo-server/custom-secure-scripts/custom-scheduled-tasks.php';

if(file_exists($secureScript)){
	require($secureScript);
}

// IMPORTANT: All logName values MUST be unique, or it will prevent the duplicates from running
function getTasks(){
	if(zIsTestServer()){
		$adminDomain=get_cfg_var("jetendo_test_admin_domain");
	}else{
		$adminDomain=get_cfg_var("jetendo_admin_domain");
	}
	$arrTask=array();
	if(function_exists('getCustomTasks')){
		$arrTask=getCustomTasks($arrTask);
	}
	$t=new stdClass();
	$t->logName="update-exchange-rate.html"; // this also verifies all sites are loaded on init.
	$t->interval="daily"; 
	$t->startTimeOffsetSeconds=1000; 
	$t->url=$adminDomain."/z/server-manager/tasks/update-exchange-rate/index";
	array_push($arrTask, $t); 


	$t=new stdClass();
	$t->logName="delete-old-site-backups.html"; // this also verifies all sites are loaded on init.
	$t->interval="daily"; 
	$t->startTimeOffsetSeconds=1000; 
	$t->url=$adminDomain."/z/server-manager/tasks/site-backup/deleteOldBackups";
	array_push($arrTask, $t); 

	$t=new stdClass();
	$t->logName="renew-lets-encrypt-ssl.html"; // this also verifies all sites are loaded on init.
	$t->interval="daily"; 
	$t->startTimeOffsetSeconds=1000; 
	$t->url=$adminDomain."/z/server-manager/tasks/renew-lets-encrypt-ssl/index";
	array_push($arrTask, $t); 

	$t=new stdClass();
	$t->logName="autoresponder-drip-cron.html"; // this also verifies all sites are loaded on init.
	$t->interval=3600;
	$t->startTimeOffsetSeconds=500;
	$t->url=$adminDomain."/z/inquiries/admin/autoresponder-cron/index";
	array_push($arrTask, $t); 

	$t=new stdClass();
	$t->logName="sync-sessions.html"; // this also verifies all sites are loaded on init.
	$t->interval=60;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/server-manager/tasks/sync-sessions/index";
	array_push($arrTask, $t); 

	$t=new stdClass();
	$t->logName="listing-generatedata.html";
	$t->type="every";
	$t->interval=7200;
	$t->startTimeOffsetSeconds=1020;
	$t->url=$adminDomain."/z/listing/tasks/generateData/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="listing-lookup-builder.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=1420;
	$t->url=$adminDomain."/z/listing/tasks/listingLookupBuilder/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="execute-http-queue.html";
	$t->interval=600;
	$t->startTimeOffsetSeconds=100;
	$t->url=$adminDomain."/z/server-manager/tasks/execute-http-queue/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->interval="daily";
	$t->logName="publish-missing.html";
	$t->startTimeOffsetSeconds=1000;
	$t->url=$adminDomain."/z/server-manager/tasks/publish-missing/index";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->interval="daily";
	$t->logName="project-events.html";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/event/tasks/project-events/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->interval=1800;
	$t->logName="call-tracking-metrics-import.html";
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/server-manager/tasks/call-tracking-metrics-import/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="delete-inactive-image-library.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=2420;
	$t->url=$adminDomain."/z/_com/app/image-library?method=deleteInactiveImageLibraries";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->logName="delete-inactive-grid.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=2820;
	$t->url=$adminDomain."/z/_com/grid/grid?method=deleteInactiveGrid";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="importMLSData.html";
	$t->interval=180;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/listing/tasks/importMLS/index";
	array_push($arrTask, $t);

	/*
doesn't work anymore
	$t=new stdClass();
	$t->logName="blog-pings.html";
	$t->interval=900;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/blog/admin/ping/index";
	array_push($arrTask, $t);
*/
	$t=new stdClass();
	$t->logName="site-map-xml-publish.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=1400;
	$t->url=$adminDomain."/z/server-manager/tasks/update-sitemap/index?force=1";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="resend-autoresponders.html";
	$t->interval=7200;
	$t->startTimeOffsetSeconds=1020;
	$t->url=$adminDomain."/z/server-manager/tasks/resend-autoresponders/index";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->logName="reservation-email-alert.html";
	$t->interval=7200;
	$t->startTimeOffsetSeconds=720;
	$t->url=$adminDomain."/z/reservation/tasks/reservation-email-alert/findReservationNeedingReminder";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="clear-old-skin-cache.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/_com/display/skin?method=deleteOldCache";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->logName="clear-old-temp-data.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/server-manager/tasks/verify-apps/clearOldTempData";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="publish-ssi-skin.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2400;
	$t->url=$adminDomain."/z/server-manager/tasks/publish-ssi-skin/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="reindex-all-site-content.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=1000;
	$t->url=$adminDomain."/z/server-manager/tasks/search-index/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="send-listing-email-alerts.html";
	$t->interval=60;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/listing/tasks/sendListingAlerts/index";
	array_push($arrTask, $t);
 
	$t=new stdClass();
	$t->logName="send-lead-reminders.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=1500;
	$t->url=$adminDomain."/z/server-manager/tasks/send-lead-reminders/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="send-mailing-list-alerts.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=500;
	$t->url=$adminDomain."/z/server-manager/tasks/send-mailing-list-alerts/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="listing-update-metadata.html";
	$t->interval=3600;
	$t->startTimeOffsetSeconds=100;
	$t->url=$adminDomain."/z/listing/tasks/update-metadata/index";
	array_push($arrTask, $t);

	$t=new stdClass();
	$t->logName="password-expiration.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2000;
	$t->url=$adminDomain."/z/server-manager/tasks/password-expiration/index";
	array_push($arrTask, $t);


	$t=new stdClass();
	$t->logName="verify-apps.html";
	$t->interval=60;
	$t->startTimeOffsetSeconds=0;
	$t->url=$adminDomain."/z/server-manager/tasks/verify-apps/index";
	array_push($arrTask, $t);
	return $arrTask;

	$t=new stdClass();
	$t->logName="execute-purge-old-files.html";
	$t->interval="daily";
	$t->startTimeOffsetSeconds=2300;
	$t->url=$adminDomain."/z/_com/zos/cloudFile?method=executePurgeOldFiles";
	array_push($arrTask, $t);
	
}

set_time_limit(70);

$isTestServer=zIsTestServer();

if($isTestServer){
	echo "This is a test server - none of the tasks will actually be executed.\n";
}

$taskLogPath=get_cfg_var("jetendo_share_path")."task-log/";
$taskLogPathScheduler=get_cfg_var("jetendo_share_path")."task-log/scheduler.txt";

@mkdir($taskLogPath, 0700);
$arrTask=getTasks();
$arrSchedule=array();
$arrScheduleMap=array();
if(file_exists($taskLogPathScheduler)){
	$arrSchedule=explode("\n", trim(file_get_contents($taskLogPathScheduler)));
	for($i=0;$i<count($arrSchedule);$i++){
		$arr1=explode("\t", $arrSchedule[$i]);
		if(count($arr1) >= 2){
			$arrScheduleMap[$arr1[0]]=$arr1[1];
		}
	}
}

$midnight = mktime(0, 0, 0);
$date = new DateTime(null);
$now=$date->getTimestamp();
$startOfTheHour = mktime(date("H"), 0, 0);
$arrRun=array();
$arrS=array();
for($i=0;$i<count($arrTask);$i++){
	$task=$arrTask[$i];
	$run=false;
	if($task->interval == "daily"){
		if(array_key_exists($task->logName, $arrScheduleMap)){
			$nextTime=$arrScheduleMap[$task->logName];
			if($nextTime <= $now){
				$run=true;
				$nextTime=$midnight + $task->startTimeOffsetSeconds + 86400;
			}
		}else{
			if($now-$midnight >= $task->startTimeOffsetSeconds){
				$run=true;
				$nextTime=$now + $task->interval;
			}else{
				$nextTime=$midnight + $task->startTimeOffsetSeconds + 86400;
			}
		}
	}else{
		if(array_key_exists($task->logName, $arrScheduleMap)){
			$nextTime=$arrScheduleMap[$task->logName];
			if($nextTime <= $now){
				$run=true;
				$nextTime=$now + $task->interval;
			}
		}else{
			if($now-$midnight >= $task->startTimeOffsetSeconds){
				$run=true;
				$nextTime=$now + $task->interval;
			}else{
				$nextTime=$midnight + $task->startTimeOffsetSeconds;
			}
		}
	}
	array_push($arrS, $task->logName."\t".$nextTime."\t".date('l jS \of F Y h:i:s A', $nextTime));
	if($run){
		array_push($arrRun, $task);
	}
}
if(count($arrRun) == 0){
	echo("No tasks needed to run, exiting.\n");
	exit;
}
$scheduleOutput=implode("\n", $arrS);
if(file_exists($taskLogPathScheduler)){
	unlink($taskLogPathScheduler);
}
file_put_contents($taskLogPathScheduler, $scheduleOutput);

$script='/usr/bin/php "'.get_cfg_var("jetendo_scripts_path").'cfml-task-execute.php" ';
$background=" > /dev/null 2>/dev/null &";

for($i=0;$i<count($arrRun);$i++){
	$task=$arrRun[$i];
	echo "Running task: ".$task->url."\n";
	
	if($isTestServer){
		echo " this is test server, skipping task\n";
	}else{
		$phpCmd=$script.escapeshellarg($task->url)." ".escapeshellarg($task->logName).$background;
		`$phpCmd`;
	}
}

?>