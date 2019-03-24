<?php
/*
to generate linux timestamp: date +%s
usage: php /var/jetendo-server/jetendo/scripts/mysqlrestore.php skipDatabases=db1,db2 skipTables=table1,table2 newerThen=1417190936
*/
$debug=false;

set_time_limit(20000);
require("library.php");
$mp=zGetBackupPath().'mysql/backup';
$host=get_cfg_var("jetendo_mysql_default_host");
$user=get_cfg_var("jetendo_mysql_default_user");
$pw=get_cfg_var("jetendo_mysql_default_password");

if($pw==""){
	echo "database config is missing:\n";
	echo "path:".$mp."\n";
	echo "host:".$host."\n";
	echo "user:".$user."\n";
	echo "password:".$pw."\n";
	exit;	
}

parse_str(implode('&', array_slice($argv, 1)), $_GET);
$arrSkip2=array();
if(isset($_GET['skipDatabases'])){
	$a=explode(",", $_GET['skipDatabases']);
	for($i=0;$i<count($a);$i++){
		$arrSkip2[$a[$i]]=true;
	}
}
$arrSkip=array();
if(isset($_GET['skipTables'])){
	$a=explode(",", $_GET['skipTables']);
	for($i=0;$i<count($a);$i++){
		$arrSkip[$a[$i]]=true;
	}
}
if(isset($_GET['newerThen'])){
	$newerThen=$_GET['newerThen'];
}else{
	$newerThen=FALSE;
}

echo "Restoring all files in ".$mp."\n\n";
if ($handle = opendir($mp)) {
    while (false !== ($entry = readdir($handle))) {
		if($entry != "." && $entry != ".." && is_dir($mp."/".$entry) && $entry != "mysql"){
			if ($handle2 = opendir($mp."/".$entry)) {
	
				$db=$entry;
				if(isset($arrSkip2[$db])){
					continue;
				}
				if(!isset($_GET['skipDatabases'])){
					// this is safe, since it doesn't drop the user privileges
					$cmd="echo \"DROP DATABASE IF EXISTS \`".$db."\`;\"|mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)."";
					echo $cmd."\n\n";
					if(!$debug){
						$r=`$cmd`;
					}
					$cmd="echo \"CREATE DATABASE \`".$db."\`;\"|mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)."";
					echo $cmd."\n\n";
					if(!$debug){
						$r=`$cmd`;
					}
					$schema=$mp."/".$entry."/schema.sql";
					if(file_exists($schema)){
							$cmd="mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)." -D ".escapeshellarg($db)." < ".escapeshellarg($schema);
							echo $cmd."\n\n";
							if(!$debug){
								$r=`$cmd`;
							}
					}else{
						continue;
					}
				}
				while (false !== ($entry2 = readdir($handle2))) {
					echo $entry."/".$entry2."\n";
					if(strstr($entry2, ".sql") !== FALSE && $entry2 != "schema.sql"){
						if(isset($arrSkip[str_replace(".sql", "", $entry2)])){
							continue;
						}
						// sql file, do import:
						$r="";
						$f=$mp."/".$entry."/".$entry2;


						$currentFileMTime=filemtime($f);
						if($newerThen !== FALSE && $currentFileMTime < $newerThen){
							echo "Skipping unchanged table: ".$f."\n";
							continue;
						}
						if(isset($_GET['skipDatabases'])){
							$cmd="echo \"TRUNCATE TABLE \`".$db."\`.\`".str_replace(".sql", "", $entry2)."\`;\"|mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)."";
							echo $cmd."\n\n";
							if(!$debug){
								$r=`$cmd`;
							}
						}


						echo "------\n".$f."\n\n";
						$cmd="mysql -h ".escapeshellarg($host)." -u ".escapeshellarg($user)." --password=".escapeshellarg($pw)." -D ".escapeshellarg($db)." < ".escapeshellarg($f);
						echo $cmd."\n\n";
						if(!$debug){
							$r=`$cmd`;
						}
						echo "Restored: ".$entry."/".$entry2." | ".$r."\n\n";
						//@unlink($f);
					}
				}
				closedir($handle2);
			}
		}
	}
	closedir($handle);
}
?>