<?php
// /z/index.php?_zuri=$uri&$args
if(isset($_GET['_zsa3_path'])){
	$a=array();
	foreach($_GET as $key=>$val){
		if($key != "method" && $key != "_zsa3_path" && $key != "zMaintenanceMode" && $key != "_zdebug"){
			array_push($a, $key."=".$val);
		}
	}
	if(count($a)==0){
		$cacheLink=$_GET['_zsa3_path'];
	}else{
		$cacheLink=$_GET['_zsa3_path']."?".implode("&", $a);
	}
	// echo $cacheLink."<br>";
	// echo md5($cacheLink);
	// exit;
	if(isset($_GET['_zdebug'])){
		echo('URL: '.$_GET['_zsa3_path'].'<br>');
		echo('X-Accel-Redirect: /zupload/statichtml/'.strtoupper(md5($cacheLink)).'.html');
		exit;	
	}
	header('X-Accel-Redirect: /zupload/statichtml/'.strtoupper(md5($cacheLink)).'.html');
	exit;
}else{
	if(!isset($_GET['method'])){
		$_GET['method']='';
	}
	$method=$_GET['method'];

 if($method=='host-time'){
		require("a/host-time.php");
	}else if($method=='secure-message'){
		require("a/secure-message.php");
	}else if($method=='size'){
		require("a/listing/size.php");
	}else if($method=='yelp'){
		require("a/content/yelp.php");
	}else if($method=='yelpp'){
		require("a/content/yelpp.php");
	}else{

		function zMicrotimeFloat(){
		    list($usec, $sec) = explode(" ", microtime());
		    return ((float)$usec + (float)$sec);
		}
		function zSecureCommand($command, $timeoutInSeconds){ 
			$secureHashDate=md5(rand(10000000, 90000000)."-php-".uniqid()); 
			$startPath=get_cfg_var("jetendo_root_path")."execute/start/".$secureHashDate.".txt";
			$activePath=get_cfg_var("jetendo_root_path")."execute/active/".$secureHashDate.".txt";
			$completePath=get_cfg_var("jetendo_root_path")."execute/complete/".$secureHashDate.".txt"; 
			$r=file_put_contents($startPath, $command);
			if($r===FALSE){
				return [false, "permission denied"];
			}
			$startTime=zMicrotimeFloat();
			$timeoutInSeconds*=1000000; 
			while(true){
				usleep(100000); 
				if(file_exists($completePath)){
					$contents=file_get_contents($completePath);
					@unlink($activePath);
					unlink($completePath);
					return [true, $contents];
				}else if(zMicrotimeFloat()-$startTime > $timeoutInSeconds){
					@unlink($startPath);
					@unlink($startPath.".running");
					@unlink($activePath);
					unlink($completePath);
					return [false, "secureCommand failed"];
				}
			}
		} 
		function zIsTestServer(){
			global $isTestServer;
			return $isTestServer;
		}
		$host=$_SERVER["HTTP_HOST"];
		$testDomain=get_cfg_var("jetendo_test_domain"); 
		if(strpos($host, $testDomain) !== FALSE){
			$isTestServer=true; 
			error_reporting(E_ALL ^ E_DEPRECATED);
			ini_set('display_errors', 1);
			$allowed=get_cfg_var("jetendo_test_allowed_php_script_list");
			$allowedMethods=get_cfg_var("jetendo_test_allowed_php_method_list");
		}else{
			$isTestServer=false; 
			$allowed=get_cfg_var("jetendo_allowed_php_script_list");
			$allowedMethods=get_cfg_var("jetendo_allowed_php_method_list");
		} 
		if($allowed != ""){
			$arrScript=explode("|", $allowed);
			$arrMethod=explode("|", $allowedMethods);
			for($i=0;$i<count($arrScript);$i++){ 
				if($method==$arrMethod[$i]){ 
					require($arrScript[$i]);
					exit;
				}
			}
		}
		header("HTTP/1.0 404 Not Found");
		exit;
	}
}
?>