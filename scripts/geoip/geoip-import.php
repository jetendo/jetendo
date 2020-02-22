<?php
// this should be a cronjob that runs once a day or week or whenever
// php /var/jetendo-server/jetendo/scripts/geoip/geoip-import.php
// the main import only takes 3 to 10 minutes to run, but then the prefix optimization at the end takes about 30 minutes to finish
// crontab is: 
// 5 6 * * Sat /usr/bin/php /var/jetendo-server/jetendo/scripts/geoip/geoip-import.php >/dev/null 2>&1

require(get_cfg_var("jetendo_scripts_path")."library.php");
set_time_limit(5000);

$maxMindLicense=get_cfg_var("jetendo_maxmind_license");
if($maxMindLicense == ""){
	echo("jetendo_maxmind_license php info configuration variable must be defined.");
	exit;
}

$mysqlUser=get_cfg_var("jetendo_mysql_default_username");
$mysqlPass=get_cfg_var("jetendo_mysql_default_password");

$mysqlDatabase=zGetDatasource() ;
// jetendo_mysql_default_host
$path=get_cfg_var("jetendo_share_path")."geoip-data/";
if(!is_dir($path)){	
	mkdir($path, 0700);
}
chdir($path);

$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), zGetDatasource() );  
echo "Drop geoip_block_safe\n";
$sql="DROP TABLE IF EXISTS `geoip_block_safe` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Drop geoip_location_safe\n";
$sql="DROP TABLE IF EXISTS `geoip_location_safe` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT);  
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE IF NOT EXISTS `geoip_block` (
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) unsigned NOT NULL,
  `geoip_block_registered_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_represented_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_postal_code` varchar(45) NOT NULL,
  `geoip_block_latitude` float NOT NULL,
  `geoip_block_longitude` float NOT NULL,
  `geoip_block_prefix` int(10) unsigned NOT NULL DEFAULT '0',
  `geoip_block_network` int(10) unsigned NOT NULL,
  `geoip_block_broadcast` int(10) unsigned NOT NULL,
   `geoip_block_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`geoip_block_id`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`),
  KEY `newindex2` (`geoip_block_prefix`,`geoip_block_network`,`geoip_block_broadcast`)
) ENGINE=InnoDB AUTO_INCREMENT=2942433 DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
echo "Create geoip_block\n";
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE IF NOT EXISTS `geoip_location` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_name` varchar(2) DEFAULT NULL,
  `geoip_location_country_iso_code` varchar(2) DEFAULT NULL,
  `geoip_location_country_name` varchar(45) DEFAULT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) DEFAULT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) DEFAULT NULL,
  `geoip_location_city_name` varchar(1000) DEFAULT NULL,
  `geoip_location_metro_code` int(11) DEFAULT NULL,
  `geoip_location_postalCode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
echo "Create geoip_location\n";
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE `geoip_block_safe` (
  `geoip_block_network_cidr` varchar(32) NOT NULL DEFAULT '',
  `geoip_location_id` int(11) unsigned NOT NULL,
  `geoip_block_registered_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_represented_country_geoname_id` int(11) unsigned NOT NULL,
  `geoip_block_is_anonymous_proxy` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_is_satellite_provider` varchar(1) NOT NULL DEFAULT '0',
  `geoip_block_postal_code` varchar(45) NOT NULL,
  `geoip_block_latitude` float NOT NULL,
  `geoip_block_longitude` float NOT NULL,
  `geoip_block_prefix` int(10) unsigned NOT NULL DEFAULT '0',
  `geoip_block_network` int(10) unsigned NOT NULL,
  `geoip_block_broadcast` int(10) unsigned NOT NULL,
  `geoip_block_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`geoip_block_id`),
  KEY `newindex1` (`geoip_block_network`,`geoip_block_broadcast`),
  KEY `newindex2` (`geoip_block_prefix`,`geoip_block_network`,`geoip_block_broadcast`)
) ENGINE=InnoDB AUTO_INCREMENT=2942433 DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

$sql="CREATE TABLE `geoip_location_safe` (
  `geoip_location_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `geoip_location_locale_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_code` varchar(2) DEFAULT NULL,
  `geoip_location_continent_name` varchar(2) DEFAULT NULL,
  `geoip_location_country_iso_code` varchar(2) DEFAULT NULL,
  `geoip_location_country_name` varchar(45) DEFAULT NULL,
  `geoip_location_subdivision_1_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_1_name` varchar(1000) DEFAULT NULL,
  `geoip_location_subdivision_2_iso_code` varchar(4) DEFAULT NULL,
  `geoip_location_subdivision_2_name` varchar(1000) DEFAULT NULL,
  `geoip_location_city_name` varchar(1000) DEFAULT NULL,
  `geoip_location_metro_code` int(11) DEFAULT NULL,
  `geoip_location_postalCode` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`geoip_location_id`),
  KEY `geoip_location_city_name` (`geoip_location_city_name`(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
		zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
} 


echo "Download Zip\n";
$zipPath=$path."GeoLite2-City-CSV.zip";
@unlink($zipPath);

$link="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City-CSV&license_key=".$maxMindLicense."&suffix=zip";
 

$cmd="wget ".escapeshellarg($link)." -O ".$zipPath; 
`$cmd`;
if(!file_exists($zipPath)){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed to download zip: ".$zipPath);
}

echo "Process Zip\n";
`unzip -jo GeoLite2-City-CSV.zip`;
@unlink($path."geoip_block.csv");
@unlink($path."geoip_location.csv");
`rm GeoLite2-City-CSV.zip`;
`mv GeoLite2-City-Locations-en.csv geoip_location.csv`;
`mv GeoLite2-City-Blocks-IPv4.csv geoip_block.csv`;
if(!file_exists($path."geoip_location.csv")){
	zEmailErrorAndExit("GeoIP Import Failed", "geoip location csv missing");
}
if(!file_exists($path."geoip_block.csv")){
	zEmailErrorAndExit("GeoIP Import Failed", "geoip block csv missing");
} 
chmod($path, 0777);
chmod($path."geoip_block.csv", 0777);
chmod($path."geoip_location.csv", 0777);

echo "Load geoip_block_safe\n";
$sql="LOAD DATA INFILE '".$path."geoip_block.csv'  INTO TABLE geoip_block_safe   FIELDS    TERMINATED BY ','  OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\'	IGNORE 2 LINES";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Load geoip_location_safe\n";
$sql="LOAD DATA INFILE '".$path."geoip_location.csv'  INTO TABLE geoip_location_safe FIELDS    TERMINATED BY ','  OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '\\\\'	IGNORE 2 LINES";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

echo "Process blocks\n";
$sql="update geoip_block_safe set  
geoip_block_prefix = (substring_index(substring_index(geoip_block_network_cidr, '.', 1), '.', -1)*256)+substring_index(substring_index(geoip_block_network_cidr, '.', 2), '.', -1),
geoip_block_broadcast = (INET_ATON(substring_index(geoip_block_network_cidr, '/', 1)) + (pow(2, (32-substr(geoip_block_network_cidr, instr(geoip_block_network_cidr, '/')+1)))-1)), 
geoip_block_network = inet_aton(substring_index(geoip_block_network_cidr, '/', 1))";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}

// TODO: this could be faster if we sort by the cidr addr and then parse it, so we can insert without a loop of select statements.
$sql="SELECT * FROM geoip_block_safe group by geoip_block_prefix";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Prefix Query Failed", "Failed: ".$cmysql->error);
}
$blockLookup=array();
while($row=$r->fetch_object()){
	$blockLookup[$row->geoip_block_prefix]=true;
}
for($i=0;$i<=223;$i++){
	echo "Process missing blocks for ".$i.".0.0.0\n";
	for($n=0;$n<=256;$n++){
		$prefix=($i*256)+$n;
		if(isset($blockLookup[$prefix])){
			continue;
		}
		// lookup ip block
		$ip=$i.".".$n.".0.0"; 
		
		$blockLookup[$prefix]=true;
		
		$sql="SELECT * 
		FROM geoip_block_safe FORCE INDEX(newindex2)
		where  
		geoip_block_prefix < '".$prefix."' AND
		inet_aton('".$cmysql->real_escape_string($ip)."') >= geoip_block_network
		AND inet_aton('".$cmysql->real_escape_string($ip)."') <= geoip_block_broadcast 
		LIMIT 0,1";
		$r2=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
		if($r2===FALSE){
			zEmailErrorAndExit("GeoIP Lookup Query Failed", "Failed: ".$cmysql->error);
		}
		
		// ignore missing blocks because they are not valid ips.
		while($row2=$r2->fetch_object()){
			$sql="INSERT INTO geoip_block_safe
			SET 
			geoip_block_network_cidr='$row2->geoip_block_network_cidr',
			geoip_location_id='$row2->geoip_location_id',
			geoip_block_registered_country_geoname_id='$row2->geoip_block_registered_country_geoname_id',
			geoip_block_represented_country_geoname_id='$row2->geoip_block_represented_country_geoname_id',
			geoip_block_is_anonymous_proxy='$row2->geoip_block_is_anonymous_proxy',
			geoip_block_is_satellite_provider='$row2->geoip_block_is_satellite_provider',
			geoip_block_postal_code='$row2->geoip_block_postal_code',
			geoip_block_latitude='$row2->geoip_block_latitude',
			geoip_block_longitude='$row2->geoip_block_longitude',
			geoip_block_prefix='$prefix',
			geoip_block_network='$row2->geoip_block_network',
			geoip_block_broadcast='$row2->geoip_block_broadcast'";
			$r3=$cmysql->query($sql, MYSQLI_STORE_RESULT);  
			if($r3===FALSE){
				zEmailErrorAndExit("GeoIP Prefix Insert Query Failed", "Failed: ".$cmysql->error);
			}
			//var_dump($r3);			echo $sql;			exit;
		}
	}
} 
echo "Swap geoip tables\n";
$sql="RENAME TABLE `geoip_location_safe` to `geoip_location_temp`, `geoip_location` to `geoip_location_safe`, `geoip_location_temp` to `geoip_location`,  `geoip_block_safe` to `geoip_block_temp`, `geoip_block` to `geoip_block_safe`, `geoip_block_temp` to `geoip_block` ";
$r=$cmysql->query($sql, MYSQLI_STORE_RESULT); 
if($r===FALSE){
	zEmailErrorAndExit("GeoIP Import Failed", "Failed: ".$cmysql->error);
}
$host=`hostname`;
zEmailErrorAndExit("GeoIP Import Succeeded", "GeoIP Import Succeeded on ".$host);
//echo('done');exit; 
?>
