<?php
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

?>