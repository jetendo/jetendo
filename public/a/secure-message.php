<?php
// i'll need to grab some data from database to make this work on other sites.

$devEmailTo=get_cfg_var("jetendo_developer_email_to");
$devEmailFrom=get_cfg_var("jetendo_developer_email_from");
set_time_limit(3000);
error_reporting(E_ALL);
function zo($var, $default=''){
	if(isset($_GET[$var])){
		return $_GET[$var];
	}else if(isset($_POST[$var])){
		return $_POST[$var];
	}else{
		return $default;
	}
}
$action=zo('action','list');
//request.zos.template.setTemplate("client.cfm");
$npasscode=zo('npasscode','');
$publicUser=true;	
$shortDomain=str_replace(".", "_", str_replace("www.","", str_replace(".".get_cfg_var("jetendo_test_domain"), "", $_SERVER['HTTP_HOST'])));

if($_SERVER['SERVER_PORT'] != '443' && strpos($_SERVER['HTTP_HOST'], ".".get_cfg_var("jetendo_test_domain")) === FALSE){
	echo "Requires SSL";exit;
}
echo '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Secure Message</title>
<style>
body,table{ font-family:Verdana, arial,sans-serif; font-size:13px; line-height:16px;}
</style>
</head>

<body>';
$privatehomedir=get_cfg_var("jetendo_sites_writable_path").$shortDomain."/"; 
if($privatehomedir == ""){
	die("This web site doesn't have a privatehomedir which is required for the secure message system.");
	exit;
}
if($action == "sendtoclient"){
    $eBody='Hello,

To send a secure message or file to us, please click the link below and enter the password provided in this email.
'.get_cfg_var("jetendo_company_domain").'/z/a/secure-message.php

Password: '.get_cfg_var('jetendo_company_upload_password').'

Why use this secure message system?
1) Your data is encrypted via a 128-bit or higher SSL connection.
2) You can send very large files up to 2 gigabytes.
3) Replaces sending a FAX: You can scan and send high quality PDFs or other files electronically.
4) The files will be deleted from the server promptly after downloading them for added security.
5) Easier then FTP and doesn\'t require any extra software.

We offer this since email is not a secure way to send sensitive information or large files.

------------------------
'.get_cfg_var("jetendo_company_name").'
'.get_cfg_var("jetendo_company_domain").'
'.get_cfg_var("jetendo_company_phone");
	mail(zo('email1',false),"How to send a secure message to ".$_SERVER['HTTP_HOST'], $eBody, "From: <".$devEmailTo.">\nReply-To: \"Error\" <".$devEmailTo.">\nX-Mailer: php" );
	echo "Email sent to ".zo('email1',false);
	exit;
		
}
if($publicUser==false){
    echo '<a href="/member/">Back to Member Area</a> /<br /><br />
    <h2>Password is "sendtobruce"</h2>
<form action="'.$_SERVER['SCRIPT_NAME'].'" method="get">
<input type="hidden" name="requesttimeout" value="3000" />
<input type="hidden" name="action" value="sendtoclient" />
Email: <input type="text" name="email1" value="" size="50" /> <input type="submit" name="Submit1" value="Send Secure Message Link" />
</form>
<br />
<br />';
}
if(zo('zlogout',false) !== false){
	echo '<h2>You have been logged out.</h2>';
}

if($npasscode != get_cfg_var("jetendo_company_upload_password")){
	echo '<h2>Send Secure Message to '.get_cfg_var("jetendo_company_name").'</h2>
<h2>Please Login:</h2>
<form action="/z/index.php?method=secure-message" method="post">
Password: <input type="password" name="npasscode" autocomplete="off" value="" /> <input type="submit" name="Submit1" value="Login" />
</form>';
	$action="login";
}else{
	if($action == "upload"){
		$filePath=$privatehomedir.'client-upload/';
		$dirName=date('Ymdhis');
		for($i=1;$i <= 20;$i++){
			$tempDirName=$dirName."-".$i;
			if(is_dir($filePath.$tempDirName) == false){
				$dirName=$tempDirName;
				break;
			}
		}
		$filePath=$filePath.$dirName."/";
		mkdir($filePath);
		$arrFiles=array();
		for($i=1;$i <= 5;$i++){
			$curFile="content_file".$i;
			if(isset($_FILES[$curFile]) && $_FILES[$curFile]["tmp_name"] != ""){
				$curFile2=$filePath.$_FILES[$curFile]['name'];
				$fileName1=$_FILES[$curFile]['name'];
				$g=1;
				while(file_exists($curFile2)){
					$curFile2=$filePath.$g."_".$_FILES[$curFile]['name'];
					$fileName1=$g."_".$_FILES[$curFile]['name'];
					$g++;
				}
				if($curFile2 != ""){
					$r=move_uploaded_file($_FILES[$curFile]['tmp_name'], $curFile2);
					if($r=== FALSE){
						echo 'Failed to upload file '.$i.'.  Please try again or call us at 386-405-4643.';
						exit;
					}else{
						array_push($arrFiles,$fileName1);
					}
				}
			}
		} 
		$securemessage='Don\'t forget to review images for copyright infringement with the sender.
		
		Client Name: '.zo('content_client_name').'
Client Email: '.zo('content_client_email').'

Client Description:
'.zo('content_summary');
		$f=fopen($filePath."~securemessage.txt", 'w');
		fwrite($f,$securemessage);
		fclose($f);
		array_push($arrFiles,"~securemessage.txt");
		
		$eBody='Secure message sent to '.$_SERVER['HTTP_HOST'].'

Message ID: '.$dirName.'
File Count: '.count($arrFiles).' file(s).

Login to client upload area to download the file(s):
';
		for($i=0;$i < count($arrFiles);$i++){
			$eBody.='File '.($i+1).': '.$arrFiles[$i].'
		';
		}
	
		$r=mail($devEmailTo,"Secure message sent to ".$_SERVER['HTTP_HOST'], $eBody, "From: <".$devEmailFrom.">\nReply-To: \"Error\" <".$devEmailFrom.">\nX-Mailer: php" );
		if(!$r){
			echo '<h2>Email notification failed</h2><p>Please contact us via email to check our secure upload repository.</p>';
		}
		$cEmail=zo('content_client_email');
		if($cEmail != ''){
			$r=mail($cEmail,"Secure message sent to ".$_SERVER['HTTP_HOST'], $eBody, "From: <".$devEmailFrom.">\nReply-To: \"Error\" <".$devEmailFrom.">\nX-Mailer: php" );
			if(!$r){
				echo '<h2>Email confirmation to yourself failed</h2><p>Please contact us via email to verify your upload was successful.</p>';
			}
		}
		echo '<h1>Transfer complete<br /><br />Your secure message has been delivered.  ID:'.$dirName.'</h1><p>You can send another message below or close this window.</p>';
		exit;
	}
}


if($action == "list"){
	echo '<h2>Send Secure Message to '.$_SERVER['HTTP_HOST'].'</h2>';
	echo '<p>Use this form to upload up to 5 large files at a time. You may upload 1 gigabyte or less at a time.</p>

<h2>We must obey copyright law.</h2>
<p>If you are sending art that contains third party images, you must provide purchase receipts or link to the license for any free images.  Your documentation should include the purchase urls, image ids, and original copies of the purchased art or it will not be accepted.</p>
Please do not close your browser until the confirmation message is displayed.</p>
		
	<form name="form" id="form" action="/z/index.php?method=secure-message&requesttimeout=3000&action=upload&npasscode='.urlencode($npasscode).'" method="post" enctype="multipart/form-data"> 
		<table cellspacing="0" cellpadding="5" class="table-list">
		<tr>
		<th>Your Name</th>
		<td><input type="text" size="50" name="content_client_name" value="';
		if(trim(zo('content_client_name','')) == ""){
			echo 'Client';
		}else{
			echo htmlentities(zo('content_client_name'));
		}
		echo '">
		</td>
		</tr>
		<tr>
		<th>Your Email</th>
		<td><input type="text" size="50" name="content_client_email" value="'.htmlentities(zo('content_client_email')).'"> (Used to identify you and send you a confirmation email)
		</td>
		</tr>
		<tr>
		<th width="100">File Upload 1</th>
		<td><input type="file" name="content_file1" />
		</td>
		</tr>
		<tr>
		<th width="100">File Upload 2</th>
		<td><input type="file" name="content_file2" />
		</td>
		</tr>
		<tr>
		<th width="100">File Upload 3</th>
		<td><input type="file" name="content_file3" />
		</td>
		</tr>
		<tr>
		<th width="100">File Upload 4</th>
		<td><input type="file" name="content_file4" />
		</td>
		</tr>
		<tr>
		<th width="100">File Upload 5</th>
		<td><input type="file" name="content_file5" />
		</td>
		</tr>
		<tr> 
		<th valign="top">Secure Message:<br />
(Optional)</th>
		  <td valign="top">
			<textarea name="content_summary" cols="50" rows="10"></textarea>
		 </td>
		</tr>
		<tr><th>&nbsp;</th>
		<td>
        <script>
		/* <![CDATA[ */ function hideSubmitButton(){
			var d2=document.getElementById("tempMessageDiv2");
			d2.style.display="none";
			var d=document.getElementById("tempMessageDiv");
			d.style.display="block";
		} /* ]]> */
		</script>
        <div id="tempMessageDiv" style="display:none; font-weight:bold;">Uploading...Please wait several minutes for your upload to complete.<br />
<br />
The screen will say "Transfer complete" in large writing when it is done.<br /><br /></div>
<div id="tempMessageDiv2">
		<button type="submit" name="submitPage" value="submitPage" onClick="hideSubmitButton();" style="padding:10px;">Send Secure Message</button> <button type="button" name="submitPage" value="submitPage" onClick="window.location.href=\''.$_SERVER['SCRIPT_NAME'].'?zlogout=1\';" style="padding:10px;">Log Out</button></div></td></tr>
		</table>
	  </form>
	  ';
}
echo '</body></html>';
?>
