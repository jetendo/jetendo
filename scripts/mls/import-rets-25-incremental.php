<?php
require(get_cfg_var("jetendo_scripts_path")."mls/import-rets-incremental.php");
zDownloadRetsData(25, true);
?>