<?php
require("library.php");
require("compile-js-css.php");

$rootPath=get_cfg_var('jetendo_root_path');
$sitesPath=get_cfg_var("jetendo_sites_path");

// must grant the mysql user select and update permissions on jetendo main database.
// */1 * * * * /usr/bin/php /root/newsite.php >/dev/null 2>&1

$debug=false;
$timeout=60; // seconds
$host=`hostname`;
$isSharedTestServer=false;
if($host=="jetendodev.farbeyondcode.com"){
	$isSharedTestServer=true;
}

if((int)date("i") % 4 == 0){
	$avgLoad=explode(" ", `cat /proc/loadavg`);
	$cpuLimit=3;
	if($avgLoad[1] >$cpuLimit){ 
		$to      = get_cfg_var('jetendo_developer_email_to'); 
		$subject = 'CPU load is very high on '.$host;
			
		$headers = 'From: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
			'Reply-To: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
			'X-Mailer: PHP/' . phpversion();
		$topProcesses=`ps ax -o pid,%cpu,command | sort -rk 2 | head -n 6 | cut -c1-70`;

		$iostatLog=`/usr/sbin/iotop -abPo -n 3 | cut -c1-100`;

		$message = "Average load exceeded ".$cpuLimit.".\nCurrent load averages (minute, 5 minute, 15 minutes): \n".implode(", ", $avgLoad)."\nThe 6 processes with highest CPU usage:\n\n".$topProcesses."\n\nThe highest I/O processes over 3 seconds:\n\n".$iostatLog;

		// force file_get_contents to fail after 5 seconds
		ini_set('default_socket_timeout', 5);

		if(zIsTestServer()){
			$adminDomain=get_cfg_var("jetendo_test_admin_domain");
		}else{
			$adminDomain=get_cfg_var("jetendo_admin_domain");
		}
		// make request to server to log error of the current running requests and their runTimes.
		$contents=file_get_contents($adminDomain."/z/server-manager/tasks/memory-dump/logRecentRequestsError?returnResults=1");
		if($contents === FALSE){
			$message.="\n\nFailed to log recent requests";
		}else{
			$contents=trim($contents);
			if($contents!="Running Requests"){
				$message.="\n\n".$contents;
			}
		}

		mail($to, $subject, $message, $headers);

	}
}

$testDomain=get_cfg_var("jetendo_test_domain"); 
if(strpos($host, $testDomain) !== FALSE){
	$isTestServer=true;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_test_server_uses_samba");
	$adminDomain=str_replace("http://", "", str_replace("https://", "", get_cfg_var("jetendo_admin_domain")));
	$cmd="/bin/ping -c 1 ".$adminDomain.".";
	$r=`$cmd`;
	if(strpos($r, 'bytes from') === false){
		echo "restart networking because ping to ".$adminDomain." failed.\n";
		echo `/usr/bin/service networking stop`;
		echo `/usr/bin/service networking start`;
	}
}else{
	$isTestServer=false;
	$isInstalledOnSambaMount=get_cfg_var("jetendo_server_uses_samba");
}
$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
$sql="select * FROM site WHERE site_active='1' and 
site_deleted='0' ";

$arrSite=array();
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
$arrNew=array();
while($row=$r->fetch_assoc()){
	array_push($arrSite, $row);
}
	
$time_start = microtime_float();

if($isTestServer){
	$sql="select * FROM site WHERE (site_system_user_created='0' or site_system_user_modified ='1') and 
	site_active='1' and site_ip_address <>'' and site_short_domain <>'' and 
site_deleted='0'  ";
}else{
	$sql="select * FROM site WHERE (site_system_user_created='0' or site_system_user_modified ='1') and 
	site_active='1' and site_ip_address <>'' and site_short_domain <>'' and site_username <>'' and site_password<>'' and 
site_deleted='0' ";
}

/*
$result=`cat /proc/sys/net/ipv4/tcp_syncookies`;
if(trim($result) != "1"){
	//`echo 1 > /proc/sys/net/ipv4/tcp_syncookies`;
	$to      = get_cfg_var('jetendo_developer_email_to');
	$subject = 'PHP newsite.php syncookies reenabled on '.$host;
		
	$headers = 'From: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
		'Reply-To: '.get_cfg_var('jetendo_developer_email_from')."\r\n" .
		'X-Mailer: PHP/' . phpversion();
	$message = 'PHP newsite.php syncookies were re-enabled because they were found to be disabled with "cat /proc/sys/net/ipv4/tcp_syncookies"';

	mail($to, $subject, $message, $headers);
}
*/
$sharePath=get_cfg_var("jetendo_share_path");

for($i4=0;$i4 < 62;$i4++){
	if($isSharedTestServer || !$isTestServer){
		$wwwUser=get_cfg_var("jetendo_www_user");
		if(file_exists($sharePath."__zdeploy-core-complete.txt")){ 
			@unlink($sharePath."__zdeploy-core-complete.txt");
			$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_root_path")."core/", $wwwUser, $wwwUser, "440", "550", true, false, array(), $isTestServer);
			$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_root_path")."database-upgrade/", $wwwUser, $wwwUser, "440", "550", true, false, array(), $isTestServer);
			$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_root_path")."public/", $wwwUser, $wwwUser, "440", "550", true, false, array(), $isTestServer);
			$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_share_path")."database/", $wwwUser, $wwwUser, "660", "770", true, false, array(), $isTestServer);
			$result=zCheckDirectoryPermissions(get_cfg_var("jetendo_scripts_path"), "root", "root", "440", "550", true, false, array(), $isTestServer);
		}
	}
	
	if($isTestServer && file_exists($sharePath."__zdeploy-core-executed.txt")){ 
		$deploy_server_group=file_get_contents($sharePath."__zdeploy-core-executed.txt");
		unlink($sharePath."__zdeploy-core-executed.txt");
		@unlink($sharePath."__zdeploy-core-failed.txt");



		$isCompiled=compileAllPackages();
		if(!$isCompiled){
			$handle=fopen($sharePath."__zdeploy-core-failed.txt", "w");
			fwrite($handle, "Javascript compileAllPackages compilation error.  See log: ".get_cfg_var("jetendo_log_path")."deploy/compile-js-css-log.txt");
			fclose($handle); 
		}else{
			$sql2="select * from deploy_server where deploy_server_deploy_enabled='1' and 
			deploy_server_deleted = 0 and 
			deploy_server_group='".$cmysql->real_escape_string($deploy_server_group)."' "; 

			$r=$cmysql->query($sql2, MYSQLI_STORE_RESULT); 
			$handle=fopen($sharePath."__zdeploy-core-complete-temp.txt", "w");
			fwrite($handle, "1");
			fclose($handle); 
			echo "wrote file: ".$sharePath."__zdeploy-core-complete-temp.txt\n";

			$preview="0";
			if(file_exists($sharePath."__zdeploy-core-preview.txt")){ 
				$preview="1";
				unlink($sharePath."__zdeploy-core-preview.txt"); 
			}
			$failed=false;
			while($row2=$r->fetch_assoc()){ 
				$privateKeyPath=$row2["deploy_server_private_key_path"];
				$remoteUsername=$row2["deploy_server_ssh_username"];
				$remoteHost=$row2["deploy_server_ssh_host"];
				$remotePort=$row2["deploy_server_ssh_port"];

				$sshCommand=zGetSSHConnectCommand($remoteHost, $privateKeyPath, $remotePort);
				if($sshCommand===FALSE){
					$handle=fopen($sharePath."__zdeploy-core-failed.txt", "w");
					fwrite($handle, "zGetSSHConnectCommand failed.  The remote host and private key may not be defined yet.");
					fclose($handle); 
					$failed=true;
					break;
				}
				if(is_dir($rootPath."core/.git")){
					/*
					// not important yet
					// git status -uno to get status on local and remote server - output is nothing if they match.
					$cmd="/usr/bin/git -C ".escapeshellarg($siteInstallPath)." status -uno";
					$r=`$cmd`;
					if($r!=""){

					}
					*/
					// git check if there is * master
					$cmd="/usr/bin/git -C ".escapeshellarg($rootPath."/core/")." branch";
					$r=`$cmd`; 
					if($r!=""){
						$isMasterBranch=false;
						$arrBranch=explode("\n", $r);
						for($i=0;$i<=count($arrBranch);$i++){
							$c=$arrBranch[$i];
							if($c=="* master"){
								$isMasterBranch=true;
								break;
							}
						}
						if(!$isMasterBranch){
							$handle=fopen($sharePath."__zdeploy-core-failed.txt", "w");
							fwrite($handle, "The current git branch is not master.  You can only deploy to production when git is on the master branch.");
							fclose($handle);
							$failed=true;
							break;
						}
					}
				}
				$sourceOnlyList="";
				$appendString="";
				if($preview=="1"){
					$sourceOnlyList.=" --itemize-changes --dry-run ";
					$appendString=" 2>&1";
				}
				//-avz --chmod=Do=,Fo=,Du=rwx,Dg=rwx,Fu=rw,Fg=rw
				$cmd='rsync -rtLvz '.$sourceOnlyList.' --exclude=\'share/database/backup/\' --exclude=\'share/database/jetendo-schema-current.json\' --include=\'share/database/\' --exclude=\'.DS_Store\' --exclude=\'.git*\' --exclude=\'settings.xml\' --exclude=\'.project\' --exclude=\'*.sublime-*\' --exclude=\'lost+found/\' --exclude=sites-writable --exclude=\'sites-writable/\' --exclude=\'sites/\' --exclude=\'share/*\' --exclude=\'logs/\' --exclude=\'execute/\' --exclude=\'phptemp/\' --exclude=\'luceevhosts/\' --exclude=\'railovhosts/\' --exclude=\'compile/\' --exclude=\'rsync-publish.bat/\' --exclude=\'.git/\' --exclude=_notes --exclude=\'*/_notes\' --delay-updates --delete -e "'.$sshCommand.'" '.$rootPath.' '.$remoteUsername.'@'.$remoteHost.':'.$rootPath.$appendString; 
				echo $cmd."\n";
				$result=$cmd."\n".`$cmd`;

				$cmd='rsync -e "'.$sshCommand.'" '.$sharePath.'__zdeploy-core-complete-temp.txt '.$remoteUsername.'@'.$remoteHost.':'.$sharePath.'__zdeploy-core-complete.txt'; 
				echo $cmd."\n";
				$result=$result."\n".$cmd."\n".`$cmd`;

				echo $result;

				$handle=fopen($sharePath."__zdeploy-core-changes.txt", "w");
				fwrite($handle, $result);
				fclose($handle);
				
			}
			if(!$failed){
				rename($sharePath."__zdeploy-core-complete-temp.txt", $sharePath."__zdeploy-core-complete.txt");
			}
		}
	}
	
	
	for($i=0;$i<count($arrSite);$i++){
		$row=$arrSite[$i];
		$siteInstallPath=zGetDomainInstallPath($row["site_short_domain"]);
		$siteWritableInstallPath=zGetDomainWritableInstallPath($row["site_short_domain"]);
		// only run on test
		if($isTestServer){
			if(file_exists($siteWritableInstallPath."__zdeploy-executed.txt")){ 
				$deploy_server_group=file_get_contents($siteWritableInstallPath."__zdeploy-executed.txt");
				unlink($siteWritableInstallPath."__zdeploy-executed.txt"); 
				@unlink($siteWritableInstallPath."__zdeploy-complete.txt.temp"); 
				@unlink($siteWritableInstallPath."__zdeploy-complete.txt"); 
				@unlink($siteWritableInstallPath."__zdeploy-error.txt"); 
				
				$preview="0";
				if(file_exists($siteWritableInstallPath."__zdeploy-preview.txt")){ 
					$preview="1";
					unlink($siteWritableInstallPath."__zdeploy-preview.txt"); 
				}
				$siteId=$row["site_id"];
				$arrDebugCompile=array();
				$isCompiled=compileSiteFiles($row, $arrDebugCompile);
				if(!$isCompiled){
					$handle=fopen($siteWritableInstallPath."__zdeploy-error.txt", "w"); 
					fwrite($handle, "Javascript compileSiteFiles compilation error.  See log: ".get_cfg_var("jetendo_log_path")."deploy/compile-md5-site-".$row["site_short_domain"].".txt"); 
					fclose($handle); 
				}else{
					//$siteId=4000; 
					$sql2="select * from site_x_deploy_server, deploy_server 
					WHERE deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
					deploy_server_deploy_enabled='1'  and 
					site_x_deploy_server.site_id = '".$siteId."' and 
					deploy_server_deleted = 0 and 
					site_x_deploy_server_deleted = 0  and 
					deploy_server_group='".$cmysql->real_escape_string($deploy_server_group)."' ";
					$mysqlResult1=$cmysql->query($sql2, MYSQLI_STORE_RESULT); 
					while($row2=$mysqlResult1->fetch_assoc()){ 
						$privateKeyPath=$row2["deploy_server_private_key_path"];
						$remoteUsername=$row2["deploy_server_ssh_username"];
						$remoteHost=$row2["deploy_server_ssh_host"];
						$remotePath=$row2["site_x_deploy_server_remote_path"];
						$remoteSourceOnly=$row2["site_x_deploy_server_source_only"];
						$remotePort=$row2["deploy_server_ssh_port"];
						
						$sshCommand=zGetSSHConnectCommand($remoteHost, $privateKeyPath, $remotePort);
						if($sshCommand===FALSE){
							$handle=fopen($siteWritableInstallPath."__zdeploy-error.txt", "w");
							fwrite($handle, "zGetSSHConnectCommand failed.  The remote host and private key may not be defined yet.");
							fclose($handle); 
							$failed=true;
							break;
						}
						$fail=false;
						if(strpos($remotePath, " ") !== FALSE){
							$fail=true;
						}
						if($fail){
							echo "Deploy server remote path, \"$remotePath\", is configured incorrectly. 
							It must be an absolute path to the sites/* folder of a site on that server. 
							I.e. ".get_cfg_var("jetendo_sites_path")."host_com/";
							break;
						} 
						$arrExclude=explode("\n", $row["site_deploy_excluded_paths"]);
						$arrExcludeNew=array();
						for($n=0;$n < count($arrExclude);$n++){
							$arrExclude[$n]=trim($arrExclude[$n]);
							if($arrExclude[$n] != ""){
								array_push($arrExcludeNew, escapeshellarg($arrExclude[$n]));
							}
						}
						$excludeString="";
						if(count($arrExcludeNew)){
							$excludeString=" --exclude=".implode(" --exclude=", $arrExcludeNew);
						}
						$sourceOnlyList='';
						if($remoteSourceOnly == '1'){
							$arrAllowed=array(
								"cfc",
								"js",
								"cfm",
								"css"
							);
							$sourceOnlyList=" --include='*/' --include=*.".implode(" --include=*.", $arrAllowed)." --exclude='*' ";
						}
						$appendString="";
						if($preview=="1"){
							$sourceOnlyList.=" --itemize-changes --dry-run ";
							$appendString=" 2>&1";
						} 

						if(is_dir($siteInstallPath.".git")){
							/*
							// not important yet
							// git status -uno to get status on local and remote server - output is nothing if they match.
							$cmd="/usr/bin/git -C ".escapeshellarg($siteInstallPath)." status -uno";
							$r=`$cmd`;
							if($r!=""){

							}
							*/
							// git check if there is * master
							$cmd="/usr/bin/git -C ".escapeshellarg($siteInstallPath)." branch";
							$r=`$cmd`; 
							if($r!=""){
								$isMasterBranch=false;
								$arrBranch=explode("\n", $r);
								for($i=0;$i<=count($arrBranch);$i++){
									$c=$arrBranch[$i];
									if($c=="* master"){
										$isMasterBranch=true;
										break;
									}
								}
								if(!$isMasterBranch){
									$handle=fopen($siteWritableInstallPath."__zdeploy-error.txt", "w");
									fwrite($handle, "The current git branch is not master.  You can only deploy to production when git is on the master branch.");
									fclose($handle);
									break;
								}
							}
						}
						// --chmod=Do=,Fo=,Du=rwx,Dg=rwx,Fu=rw,Fg=rw
						$cmd='rsync -rtLvz '.$sourceOnlyList.$excludeString.' --exclude=\'.git\' --exclude=\'.DS_Store\' --exclude=\'*/.git\' --exclude=\'.git*\' --exclude=\'*/.git*\' --exclude=\'WEB-INF\' --exclude=\'_notes\' --exclude=\'*/_notes\' --delay-updates --delete -e "'.$sshCommand.'" '.$siteInstallPath.' '.$remoteUsername.'@'.$remoteHost.':'.$remotePath.$appendString; 
						echo $cmd."\n";
						$result=`$cmd`;
						$handle=fopen($siteWritableInstallPath."__zdeploy-changes.txt", "w");
						fwrite($handle, $result);
						fclose($handle);
						$handle=fopen($siteWritableInstallPath."__zdeploy-complete.txt.temp", "w");
						fwrite($handle, "1");
						fclose($handle); 
						echo "wrote file: ".$siteWritableInstallPath."__zdeploy-complete.txt.temp\n";
						$cmd='rsync -e "'.$sshCommand.'" '.$siteWritableInstallPath.'__zdeploy-complete.txt.temp '.$remoteUsername.'@'.$remoteHost.':'.$remotePath.'__zdeploy-complete.txt';
						echo $cmd."\n";
						`$cmd`; 
						rename($siteWritableInstallPath."__zdeploy-complete.txt.temp", $siteWritableInstallPath."__zdeploy-complete.txt");
					}
				}
			}
		}else{
		}
		// only run on remote
		if(($isSharedTestServer || !$isTestServer) && file_exists($siteInstallPath."__zdeploy-complete.txt")){
			// fix file chown and chmod permissions
			$preview=false;
			$arrError=array();
			$result=zCheckDirectoryPermissions($siteInstallPath, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "440", "550", true, $preview, $arrError, $isTestServer);
			$result=zCheckDirectoryPermissions($siteWritableInstallPath, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			$result=zCheckDirectoryPermissions($siteWritableInstallPath."zcache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			$result=zCheckDirectoryPermissions($siteWritableInstallPath."_cache/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			$result=zCheckDirectoryPermissions($siteWritableInstallPath."zupload/", get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", false, $preview, $arrError, $isTestServer);
			$result=zCheckDirectoryPermissions($siteWritableInstallPath, get_cfg_var("jetendo_www_user"), get_cfg_var("jetendo_www_user"), "660", "770", true, $preview, $arrError, $isTestServer);
			
			@unlink($siteInstallPath."__zdeploy-complete.txt"); 
		}
	} 
	
	$sharePath=get_cfg_var("jetendo_share_path");
	if(file_exists($sharePath."hostmap-execute-reload.txt")){
		@unlink($sharePath."hostmap-execute-complete.txt.temp");
		@unlink($sharePath."hostmap-execute-complete.txt");

		$cmysql2=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
		if($cmysql2->error != ""){ 
			$rs->success=false;
			$rs->errorMessage="db connect error:".$cmysql2->error;
			echo($rs->errorMessage."\n");
			return json_encode($rs);
		}
		$r=$cmysql2->query("select site_id from site where 
		site_active = '0' and 
		site_deleted='0' ");
		if($cmysql2->error != ""){ 
			$rs->success=false;
			$rs->errorMessage="db error:".$cmysql2->error;
			echo($rs->errorMessage."\n");
			return json_encode($rs);
		}
		$nginxSitesPath=get_cfg_var("jetendo_nginx_sites_config_path");
		while($row=$r->fetch_array(MYSQLI_ASSOC)){
			$outPath=$nginxSitesPath.$row["site_id"].".conf";
			if(file_exists($outPath)){
				unlink($outPath);
			}
		}

		$result=`/usr/sbin/service nginx configtest 2>&1`;

		echo "result:".$result.":endresult\n"; 
		if(strpos($result, "successful") !== FALSE){
			`/usr/sbin/service nginx reload 2>&1`;
			$result=`/usr/sbin/service nginx status 2>&1`;
			if(strpos($result, "nginx found running") !== FALSE){ 
				@unlink($sharePath.'hostmap.conf.backup');
				$message="The hostmap.conf file was published, and nginx was reloaded successfully.";
			}else{
				if(file_exists($sharePath.'hostmap.conf.backup')){
					@unlink($sharePath.'hostmap.conf');
					rename($sharePath.'hostmap.conf.backup', $sharePath.'hostmap.conf');
					`/usr/sbin/service nginx reload 2>&1`;
					$message="The hostmap.conf file was published, but nginx failed to reload.  The previous hostmap has been restored. Error: ".$result;
				}else{
					$message="The hostmap.conf file was published, but nginx failed to reload.  The configuration must be manually repaired. Run service nginx configtest to see what is wrong. Error: ".$result; 
				}
			}
		}else{
			if(file_exists($sharePath.'hostmap.conf.backup')){
				@unlink($sharePath.'hostmap.conf');
				rename($sharePath.'hostmap.conf.backup', $sharePath.'hostmap.conf');
				$message= "The hostmap.conf file was published, but nginx configtest failed.  The previous hostmap has been restored. Error: ".$result;
			}else{
				$message="The hostmap.conf file was published, but nginx failed to reload.  The configuration must be manually repaired. Run service nginx configtest to see what is wrong. Error: ".$result; 
			}
		} 
		@unlink($sharePath."hostmap-execute-reload.txt"); 
		$handle=fopen($sharePath."hostmap-execute-complete.txt.temp", "w");
		fwrite($handle, $message);
		fclose($handle);
		rename($sharePath."hostmap-execute-complete.txt.temp", $sharePath."hostmap-execute-complete.txt");
		chown($sharePath."hostmap-execute-complete.txt", get_cfg_var("jetendo_www_user"));
	}
		
	$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);
	
	
	$arrNew=array();
	while($row=$r->fetch_assoc()){
		
		$thedomainip=$row["site_ip_address"];
		$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $row["site_short_domain"]));
		$thedomain=$row["site_short_domain"];
		$theusername=$row["site_username"];
		$theoldusername=$row["site_username_previous"];
		$thepassword=$row["site_password"];
		$theoldpassword=$row["site_password_previous"];
		$theoldshortdomain=$row["site_short_domain_previous"];
		$theolddomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $row["site_short_domain_previous"]));
		$thecurrentdomain=str_replace("http://", "", str_replace("https://", "", $row["site_domain"]));
				
		$p=escapeshellarg($theoldusername);
		$theoldusernameEscaped=substr($p,1,strlen($p)-2);
		$p=escapeshellarg($theusername);
		$theusernameEscaped=substr($p,1,strlen($p)-2);
		$p=escapeshellarg($thepassword);
		$thepasswordEscaped=substr($p,1,strlen($p)-2);
		
		if($isTestServer){
			// setup git repo on test server
			$currentPath=$rootPath."sites/".str_replace(".","_",$thedomainpath)."/";
			if(!is_dir($currentPath.".git/")){
				$cmd="cp ".$rootPath."scripts/git-ignore-template.txt ".$currentPath.".gitignore";
				`$cmd`;
				echo $cmd."\n";
				
				$chResult=chdir($currentPath."/");
				if($chResult===TRUE){
					echo `/usr/bin/git init`;
					echo `/usr/bin/git add .`;
					echo `/usr/bin/git commit -m 'First commit'`;
				}else{
					echo "Failed to chdir to ".$currentPath." to create git repo.\n";
				}
			}
		}else{
			if($theoldshortdomain != "" && $theoldshortdomain != $thedomain){
				$cmd="/bin/mv -f $sitesPath".str_replace(".","_",$theolddomainpath)." $sitesPath".str_replace(".","_",$thedomainpath);
				echo $cmd."\n";
				$r2=`$cmd`;
				if(!is_dir("$sitesPath".str_replace(".","_",$thedomainpath))){
					echo "Failed to move directory.";
					break;
				}
			}
		} 
		$dir=$sitesPath.str_replace(".","_",$thedomainpath)."/";
		if(!is_dir($dir)){
			mkdir($dir, 0550);
		}
		$cmd="/bin/chown -R ".get_cfg_var("jetendo_www_user").":".get_cfg_var("jetendo_www_user")." ".escapeshellarg($dir);
		echo $cmd."\n";
		`$cmd`;
		$cmd="/bin/chmod -R g+s ".escapeshellarg($dir);
		echo $cmd."\n";
		`$cmd`;
		$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");
		$dir=$sitesWritablePath.str_replace(".","_",$thedomainpath)."/";
		if(!is_dir($dir)){
			mkdir($dir, 0660);
		}
		$cmd="/bin/chmod -R g+s ".escapeshellarg($dir);
		echo $cmd."\n";
		`$cmd`;
		
		if(!$isTestServer){
			$cmd="/bin/cat /etc/hosts";
			$d=`$cmd`;
			$arrD=explode("\n", $d);
			$saveHosts=true;
			$foundDomain=false;
			$arrD2=array();
			for($i=0;$i<count($arrD);$i++){
				if(trim($arrD[$i]) == "") continue;
				if(substr($arrD[$i],0,1) == "#"){
					array_push($arrD2, $arrD[$i]);
				}else{
					$arrD1=explode(" ",str_replace("\t"," ",$arrD[$i]));
					$c1=trim($arrD1[0]);
					if(count($arrD1) == 2){
						$c2=trim($arrD1[1]);
						if($c2 == $thedomain){
							$foundDomain=true;
							if($c1 != $thedomainip){
								$saveHosts=true;
								array_push($arrD2, $thedomainip." ".$c2);
							}else{
								$saveHosts=false;
								array_push($arrD2, $c1." ".$c2);
							}
						}else{ 
							array_push($arrD2, $c1." ".$c2);	
						}
					}else{
						array_push($arrD2, $arrD[$i]);
					}
				}
			}
			if($foundDomain == false){
				array_push($arrD2, $thedomainip." ".$thecurrentdomain);
			}
			if($saveHosts){
				$r1="/etc/hostsTemp".rand();
				$fp=fopen($r1, "w");
				fwrite($fp, implode("\n", $arrD2)."\n");
				fclose($fp);
				rename($r1, "/etc/hosts");
				`/bin/cp -f /etc/hosts /var/jetendo-server/jetendo/share/hosts`;
			}
		} 
		
		$dnsMasqPath=`/usr/bin/which dnsmasq`;
		$servicePath=trim(`/usr/bin/which service`);
		if(trim($dnsMasqPath) != ""){
			$cmd=$servicePath." dnsmasq restart";
			echo $cmd."\n";
			`$cmd`;
		}
		// make new connection because above connection is not buffered.
		$cmysql2=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource());
		$mysqldate = date("Y-m-d H:i:s");
		$cmysql2->query("update site set site_system_user_created='1', 
			site_system_user_modified='0', 
			site_short_domain_previous='', 
			site_username_previous='', 
			site_password_previous='',
			site_updated_datetime='".$mysqldate."' where 
			site_id='".$row["site_id"]."'");
	}
	sleep(1);
	if(microtime_float() - $time_start > $timeout-3){
		echo "Timeout reached";
		exit;
	}
}
?>