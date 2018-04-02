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
	header("HTTP/1.0 404 Not Found");
	exit;
}

?>