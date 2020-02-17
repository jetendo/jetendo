<?php
require("library.php");
// cron job for mlsgrid import - once a minute all day
// */1 * * * * /usr/bin/php /var/jetendo-server/jetendo/scripts/mlsgrid.php >/dev/null 2>&1

if(zIsTestServer()){
	$domain=get_cfg_var("jetendo_test_admin_domain");
}else{
	$domain=get_cfg_var("jetendo_admin_domain");
}
$link=$domain."/z/listing/tasks/mls-grid/cron";

`/usr/bin/wget -q -O /dev/null $link &`;
?>