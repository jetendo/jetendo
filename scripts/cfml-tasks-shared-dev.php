<?php
require("library.php");

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
	$t->logName="renew-lets-encrypt-ssl.html"; // this also verifies all sites are loaded on init.
	$t->interval=7200; 
	$t->startTimeOffsetSeconds=550; 
	$t->url=$adminDomain."/z/server-manager/tasks/renew-lets-encrypt-ssl/index";
	array_push($arrTask, $t); 
	
 	return $arrTask;
}

set_time_limit(70);

$isTestServer=zIsTestServer();
 

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

/* 
TODO: track if script is still running before running another - there was a duplicate problem at one point.




*/


$script='/usr/bin/php "'.get_cfg_var("jetendo_scripts_path").'cfml-task-execute.php" ';
$background=" > /dev/null 2>/dev/null &";

for($i=0;$i<count($arrRun);$i++){
	$task=$arrRun[$i];
	echo "Running task: ".$task->url."\n";
	$phpCmd=$script.escapeshellarg($task->url)." ".escapeshellarg($task->logName).$background; 
	`$phpCmd`;
}

?>