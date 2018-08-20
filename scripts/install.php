<?php
require("library.php");
$debug=false; // set to true to allow non-destructive debugging of this script


$dir=__DIR__;
if(get_cfg_var("jetendo_scripts_path") == ""){
	echo("Error: You must create a symbolic link using this command: /bin/ln -sf /var/jetendo-server/system/php/jetendo.ini /etc/php/7.2/mods-available/jetendo.ini\n");
	exit;
}
$arrLog=array();

if(!zCheckJetendoIniConfig($arrLog)){
	var_dump($arrLog);
	echo 'Error: you must configure and install jetendo.ini before running this script.\n';
	exit;
}


$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"));

// verify existence of the database

$sql="SHOW DATABASES LIKE '".zGetDatasource()."'";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
if($r->num_rows == 0){
	$sql="CREATE DATABASE `".zGetDatasource()."`";
	$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);

	$sql="SHOW DATABASES LIKE '".zGetDatasource()."'";
	$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
	if($r->num_rows == 0){
		echo 'Unable to create database, "'.zGetDatasource().'", make sure the user, "'.get_cfg_var("jetendo_mysql_default_user").
		'" has permission to create the database or create it manually and re-run this script.';
	}
}
 
// source code install & integrity checks

if(zIsTestServer()){
	$gitIntegrityCheck=get_cfg_var("jetendo_git_integrity_enabled");
}else{
	$gitIntegrityCheck=get_cfg_var("jetendo_test_git_integrity_enabled");
}
echo("Check git status\n");
$gitThemeCloneURL=get_cfg_var("jetendo_git_clone_theme_url");
$gitThemeBranch=get_cfg_var("jetendo_git_theme_branch");
$gitCloneURL=get_cfg_var("jetendo_git_clone_url");
$gitBranch=get_cfg_var("jetendo_git_branch");
$rootPath=get_cfg_var("jetendo_root_path");
chdir(get_cfg_var("jetendo_root_path"));
if(count($argv) < 2 || $argv[1] =="disableGitIntegration"){
	$status=`/usr/bin/git status`;
	if(!is_dir($rootPath."core") || strpos($status, "fatal: Not a git repository") !== FALSE){
		echo("Git repo doesn't exist. Running git clone.\n");
		if(!$debug){
			$r=`/usr/bin/git clone $gitCloneURL $rootPath`;
			$r=`/usr/bin/git checkout $gitBranch`;
		}
		$status=`/usr/bin/git status`;
	}else{
		if(!$debug){
			$r=`/usr/bin/git checkout $gitBranch`;
			$r=`/usr/bin/git remote add origin $gitCloneURL`;
		}
	}
	if(strpos($status, "nothing to commit") !== FALSE){
		echo("Git repo is clean. All files match the branch: \"".$gitBranch."\" at ".$gitCloneURL.".\n");
	}else{
		if(count($argv) >=2 && $argv[1] == "ignoreIntegrityCheck"){
			echo "Igoring unclean git repo\n";
		}else{
			echo("Git repo is not clean.\n");
			if(!$debug && $gitIntegrityCheck == "1"){
				$r=`/usr/bin/git reset --hard origin/$gitBranch`;
				$r=`/usr/bin/git pull origin $gitBranch`;
				$r=`/usr/bin/git gc`;
				echo("Current directory was hard reset back to the git origin (".$gitCloneURL.") branch: ".$gitBranch.".\n");
			}else{
				echo "\nINSTALL CANCELLED.\n";
				echo "To force installation with an unclean copy of the source code, please run this script again with the following command arguments:\n\n";
				echo "php ".get_cfg_var("jetendo_scripts_path")."install.php ignoreIntegrityCheck\n\n";
				exit;
			}
		}
	}
}
@mkdir(get_cfg_var("jetendo_root_path")."sites/", 0770);
$cmd='/bin/chown -R '.get_cfg_var("jetendo_www_user").':'.get_cfg_var("jetendo_www_user")." ".get_cfg_var("jetendo_root_path")."sites/";
`$cmd`;
@mkdir(get_cfg_var("jetendo_root_path")."sites-writable/", 0770);
$cmd='/bin/chown -R '.get_cfg_var("jetendo_www_user").':'.get_cfg_var("jetendo_www_user")." ".get_cfg_var("jetendo_root_path")."sites-writable/";
`$cmd`;
@mkdir(get_cfg_var("jetendo_root_path")."logs/", 0770);
@mkdir(get_cfg_var("jetendo_root_path")."plugins/", 0770);
@mkdir(get_cfg_var("jetendo_root_path")."execute/", 0770);
@mkdir(get_cfg_var("jetendo_root_path")."execute/start", 0770);
@mkdir(get_cfg_var("jetendo_root_path")."execute/complete", 0770);
$cmd='/bin/chown -R '.get_cfg_var("jetendo_www_user").':'.get_cfg_var("jetendo_www_user")." ".get_cfg_var("jetendo_root_path")."execute/";
`$cmd`;
@mkdir(get_cfg_var("jetendo_root_path")."themes/jetendo-default-theme", 0550);
@mkdir(get_cfg_var("jetendo_root_path")."themes/", 0550);
@mkdir(get_cfg_var("jetendo_root_path")."themes/jetendo-default-theme", 0550);
chdir(get_cfg_var("jetendo_root_path")."themes/jetendo-default-theme");
$themePath=get_cfg_var("jetendo_root_path")."themes/jetendo-default-theme";
if(count($argv) < 2 || $argv[1] == "disableGitIntegration"){
	$status=`/usr/bin/git status`;
	if(!is_dir($themePath."/templates") || strpos($status, "fatal: Not a git repository") !== FALSE){
		echo("Git repo doesn't exist. Running git clone.\n");
		if(!$debug){
			$r=`/usr/bin/git clone $gitThemeCloneURL $themePath`;
			$r=`/usr/bin/git checkout $gitThemeBranch`;
		}
		$status=`/usr/bin/git status`;
	}else{
		if(!$debug){
			$r=`/usr/bin/git checkout $gitThemeBranch`;
			$r=`/usr/bin/git remote add origin $gitThemeCloneURL`;
		}
	}
	if(strpos($status, "nothing to commit") !== FALSE){
		echo("Git repo is clean. All files match the branch: \"".$gitThemeBranch."\" at ".$gitThemeCloneURL.".\n");
	}else{
		if(count($argv) >=2 && $argv[1] == "ignoreIntegrityCheck"){
			echo "Igoring unclean git repo\n";
		}else{
			echo("Git repo is not clean.\n");
			if(!$debug && $gitIntegrityCheck == "1"){
				$r=`/usr/bin/git reset --hard origin/$gitThemeBranch`;
				$r=`/usr/bin/git pull origin $gitThemeBranch`;
				$r=`/usr/bin/git gc`;
				echo("Current directory was hard reset back to the git origin (".$gitThemeCloneURL.") branch: ".$gitThemeBranch.".\n");
			}else{
				echo "\nINSTALL CANCELLED.\n";
				echo "To force installation with an unclean copy of the source code, please run this script again with the following command arguments:\n\n";
				echo "php ".get_cfg_var("jetendo_scripts_path")."install.php ignoreIntegrityCheck\n\n";
				exit;
			}
		}
	}
}
$cmd='/bin/chown -R '.get_cfg_var("jetendo_www_user").':'.get_cfg_var("jetendo_www_user")." ".get_cfg_var("jetendo_root_path")."themes/";
`$cmd`;

if(!checkMySQLPrivileges()){
	echo "You must correct mysql privileges and re-run this installation script.\n";
	exit;
}

installJetendoCronTabs($debug);

if(zIsTestServer()){
	$adminDomain=get_cfg_var("jetendo_test_admin_domain");
}else{
	$adminDomain=get_cfg_var("jetendo_admin_domain");
}
echo "Pre-installation complete.\n\nVisit the following URL in your browser to complete installation:\n\n".
$adminDomain.":8888/zcorerootmapping/index.cfm?_zsa3_path=/&zreset=app&zforce=1\n\n";

?>