<?php 
// note gmail accounts have imap disabled by default, you must go to settings and forwarding/imap to enable.  the other gmail settings left as default are fine.

// gmail also has an allow lesssecureapps feature now that must be enabled https://myaccount.google.com/lesssecureapps

// usage - run this via command line only:
// php /var/jetendo-server/jetendo/scripts/email/imap.php > /var/jetendo-server/custom-secure-scripts/imap-images/email-result.html
require("/var/jetendo-server/jetendo/scripts/library.php"); 
require("zMailClient.php"); 
require("zProcessIMAP.php"); 
// no longer needed:
//require("/var/jetendo-server/custom-secure-scripts/email-config.php");

// schedule as cron that runs for 5 minutes at most.
// this number is set higher in case a download takes slightly longer.
set_time_limit(350);

// TODO: if an imap account check fails, continue to the next account instead of hard failure.
 
function microtimeFloat()
{
    list($usec, $sec) = explode(" ", microtime());
    return ((float)$usec + (float)$sec);
} 
// on test server, it will not delete the messages after reading them
$myProcessImap=new zProcessIMAP();
$myProcessImap->process();

//echo("\nDone");
?> 
