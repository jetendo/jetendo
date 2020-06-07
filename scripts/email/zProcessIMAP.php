<?php
class zProcessIMAP{
	var $messageLimit; // only download 5 messages every 3 seconds per imap account.
	var $timeout; // seconds
	var $timeStart;
	var $logDir;


	function processEmailAddressList($list, $accountEmail){

		$arrList=explode(",", $list);
		$arrEmail=array();
		for($i=0;$i<count($arrList);$i++){
			$arrCurrentList=explode("<", $arrList[$i]);
			if(count($arrCurrentList) == 2){
				$arrEnd=explode(">", $arrCurrentList[1]);
				$temp=array(
					"name"=>trim($arrCurrentList[0]),
					"email"=>trim($arrEnd[0])
				);
			}else{ 
				$temp=array(
					"name"=>"",
					"email"=>trim($arrList[$i])
				);
			}
	 
			$arrPart1=explode("@", $temp["email"]);
			if(count($arrPart1) <= 1){
				continue;
			}
			$arrPart2=explode("+", $arrPart1[0]);
			if(count($arrPart2)==2){
				$tempEmail=$arrPart2[0]."@".$arrPart1[1];
				if($tempEmail==$accountEmail){
					$temp["plusId"]=$arrPart2[1];
					$temp["originalEmail"]=$temp["email"];
					$temp["email"]=$tempEmail;
				}
			}
			array_push($arrEmail, $temp);
		}
		return $arrEmail;
	}

	function processEmailData(&$message, &$account){

		$message["subject"]="";
		if(isset($message["headers"]["parsed"]["Subject"])){
			$message["subject"]=$message["headers"]["parsed"]["Subject"];
		}  
		$message['plusId']='';
		$message["from"]=array();
		$message["to"]=array();
		$message["cc"]=array();
		//$message["bcc"]=array(); 
		if(isset($message["headers"]["parsed"]["From"])){
			$tempFrom=$this->processEmailAddressList($message["headers"]["parsed"]["From"], $account["imap_account_user"]);
			$message["from"]=$tempFrom[0];
		}
		if(isset($message["headers"]["parsed"]["To"])){
			$message["to"]=$this->processEmailAddressList($message["headers"]["parsed"]["To"], $account["imap_account_user"]);
		}
		if(isset($message["headers"]["parsed"]["Cc"])){
			$message["cc"]=$this->processEmailAddressList($message["headers"]["parsed"]["Cc"], $account["imap_account_user"]);
		}
		/*
		if(isset($message["headers"]["parsed"]["Bcc"])){
			$message["bcc"]=$this->processEmailAddressList($message["headers"]["parsed"]["Bcc"]);
		}  
		*/


		if(isset($message["headers"]["parsed"]["Delivered-To"])){
			$deliveredTo=$this->processEmailAddressList($message["headers"]["parsed"]["Delivered-To"], $account["imap_account_user"]);
			if(isset($deliveredTo["plusId"])){
				$message['plusId']=$deliveredTo["plusId"];
			}
		}
		if($message['plusId']==''){
			// find the plus id in the to address list instead.

			for($i=0;$i<count($message["to"]);$i++){
				// check for address to match 
				if(isset($message["to"][$i]["plusId"])){
					if($message["to"][$i]["email"] == $account["imap_account_user"]){
						// set plusId
						$message['plusId']=$message["to"][$i]["plusId"];
						break;
					}
				}
			}
		}
		if($message['plusId']==''){
			// find the plus id in the cc address list instead.
			for($i=0;$i<count($message["cc"]);$i++){
				// check for address to match 
				if(isset($message["cc"][$i]["plusId"])){
					if($message["cc"][$i]["email"] == $account["imap_account_user"]){
						// set plusId
						$message['plusId']=$message["cc"][$i]["plusId"];
						break;
					}
				}
			}
		}
		// if the plusId is still missing, then this email must have been sent directly to this email address without a plus id which is ok
	 
		if(!isset($message['html'])){
			$message['html']='';
		}
		if(!isset($message['text'])){
			$message['text']='';
		}
		if(!isset($message['headers'])){
			$message['headers']='';
		}
		if(!isset($message['html'])){
			$message['html']='';
		}
		if(!isset($message['text'])){
			$message['text']='';
		}

		$message['files']=array();
		$message['size']=0;
		foreach($message['attachments'] as $key=>$file){
			$message['size']+=$file["size"];
	        $tempFile=array(
	        	"size"=>$file["size"], //: 292427,
	            "filePath"=>$file["path"], // "\/var\/jetendo-server\/custom-secure-scripts\/imap-images\/cbenckacbifelmnn1.png",
	        	"fileName"=> $file["name"]
	        ); 
			array_push($message['files'], $tempFile);
		} 
		$message['size']+=strlen($message["headers"]["raw"]);
		$message['size']+=strlen($message["html"]);
		$message['size']+=strlen($message["text"]);

		return $message;
	}
	function logIMAPError($message){ 
		fwrite($this->logFilePointer, $message."\n");
		echo($message."\n");
	}

	function process(){ 

		$logPath=get_cfg_var("jetendo_log_path")."imap-process-errors.txt";
		$this->logFilePointer=fopen($logPath, "w");
		$this->messageLimit=5; // only download X messages every 30 seconds per imap account.
		$this->timeout=250; // seconds
		$this->timeStart=microtimeFloat();
		$this->imapCheckTimeout=30; // seconds
		if(zIsTestServer()){
			$this->readonly=true; // set to false to test run the real delete/expunge code.
		}else{
			$this->readonly=false;
		}

		$cmysql=new mysqli(get_cfg_var("jetendo_mysql_default_host"),get_cfg_var("jetendo_mysql_default_user"), get_cfg_var("jetendo_mysql_default_password"), get_cfg_var("jetendo_datasource")); 

		$sitesWritablePath=get_cfg_var("jetendo_sites_writable_path");

		$arrAccount=array();
		$testDomain=get_cfg_var("jetendo_test_domain"); 
		$arrIMAP=array();
		while(true){
			$siteResult=$cmysql->query("select * from site, imap_account WHERE 
				imap_account_active=1 and 
				site.site_id = imap_account.site_id and 
				site.site_active=1 and 
				site_deleted=0 and 
				imap_account_deleted=0", MYSQLI_STORE_RESULT);
			if($cmysql->error != ""){ 
				logIMAPError("Check IMAP DB Error: ".$cmysql->error); 
				exit;
			}
			$stopChecking=false;
			while($account=$siteResult->fetch_array(MYSQLI_ASSOC)){
				if(!isset($arrIMAPDate[$account["imap_account_id"]])){
					$arrIMAPDate[$account["imap_account_id"]]=microtimeFloat();
				}else{
					if(microtimeFloat() - $arrIMAPDate[$account["imap_account_id"]] < $this->imapCheckTimeout){ 
						continue;
					}else{
						$arrIMAPDate[$account["imap_account_id"]]=microtimeFloat();
					}
				}

				$thedomainpath=str_replace("www.", "", str_replace(".".$testDomain, "", $account["site_short_domain"]));
				$sitePath=$sitesWritablePath.str_replace(".","_",$thedomainpath)."/zuploadsecure/email-attachments/";
				if(!is_dir($sitePath)){
					mkdir($sitePath, 0770);
				}
				$requireLogin=true;
				if(isset($arrIMAP[$account["imap_account_id"]])){ 
					$myIMAP=$arrIMAP[$account["imap_account_id"]];
					$requireLogin=false;
				}else{
					$myIMAP=new zMailClient();
					$myIMAP->setFilePath($sitePath);
				}

				$ssl=false;
				if($account["imap_account_ssl"] == "1"){
					$ssl=true;
				}
				$host=$account["imap_account_host"]; 
				$user=$account["imap_account_user"];
				$pass=$account["imap_account_pass"];
				$port=$account["imap_account_port"];
				$folder="INBOX";
				if($requireLogin){
					$rsLogin=$myIMAP->login($host, $port, $user, $pass, $folder, $ssl, $this->readonly);  
					if(!$rsLogin["success"]){
						$this->logIMAPError($rsLogin["errorMessage"]." host:".$host." user:".$user."\n");
						exit;
					}
					$messageRange="";
				}else{
					$rsCheck=$myIMAP->check(); 
					//var_dump($rsCheck);
					if(!$rsCheck["success"]){
						$rsLogin=$myIMAP->login($host, $port, $user, $pass, $folder, $ssl, $this->readonly);  
						if(!$rsLogin["success"]){
							$this->logIMAPError($rsLogin["errorMessage"]." host:".$host." user:".$user."\n");
							continue;
						}
					}else{
						if($rsCheck["messageCount"] == 0){
							continue;
						}else{
							$messageRange="1:".min($this->messageLimit, $rsCheck["messageCount"]);
						}
					}
				}
				

				// 6 is html only
				// 5 is plain + file
				// 4 is multiple embedded images + multiple attached + html + plain
				// 3 is plain only
				// 2 is html + plain text
				// 1 is html + plain in different place
				// 0 is html + plain text

				// if you call this with nothing, it will pull all of the emails starting from one.  
				// need a way to call with only the newer messages, i.e. start index
				/*$arrMessage=$myIMAP->listMessagesSinceMessage(2);
				var_dump($arrMessage);
				exit;*/
				$rsMessages=$myIMAP->listMessages($messageRange, $this->messageLimit); // TODO: delete number when done    // test 4 which has no attachments.  and test plain text only email and html only email
				if(!$rsMessages["success"]){
					$this->logIMAPError("listMessages failed: ".$rsMessages["errorMessage"]);
					$stopChecking=true;
					break;
				}
				//var_dump($rsMessages["messages"]);exit;
				foreach($rsMessages["messages"] as $msgId=>$msg){  
					echo('Processing message id:'.$msgId."\n");
					// $msgId matches the index specific or the offset from FIRST/oldest mail starting with 0
					// queue message to be downloaded individually in queue_pop table
					//echo('<h2>Downloading email #'.$msgId.' parsed plus address:'.$msg['plusId'].'</h2>');
					//var_dump($msg);		exit;

					$uid="";
					if(isset($msg['data']['message_id']) && $msg['data']['message_id'] != ""){
						$uid=$msg['data']['message_id'];
					}else if(isset($msg['data']['uid']) && $msg['data']['uid'] != ""){
						$uid=$msg['data']['uid'];
					}   
					if($this->readonly){
						$sql="SELECT queue_pop_id FROM queue_pop WHERE 
						site_id='".$cmysql->real_escape_string($account["site_id"])."' and 
						imap_account_id='".$cmysql->real_escape_string($account["imap_account_id"])."' and 
						queue_pop_message_uid='".$cmysql->real_escape_string($uid)."' and 
						queue_pop_deleted='".$cmysql->real_escape_string(0)."'";
 
						$queuePopCheck=$cmysql->query($sql, MYSQLI_STORE_RESULT);
						if($queuePopCheck===FALSE){
							$this->logIMAPError("queuePopCheck failed");
						}else{
							if($queuePopCheck->num_rows != 0){
								// it is safe to ignore this in readonly mode
								//$this->logIMAPError("Message already stored: ".$uid);
								continue;
							}
						}
					}
					$rsMessage=$myIMAP->getFullMessage($msgId);   
					if(!$rsMessage["success"]){
						$this->logIMAPError("getFullMessage failed: ".$rsMessage["errorMessage"]);
						continue;
					}
					$mysqlMessageDate=date('Y-m-d H:i:s');
					if(isset($msg['data']['date'])){
						$messageDate = DateTime::createFromFormat( 'D, d M Y H:i:s O', $msg['data']['date']); 
						if($messageDate !== FALSE){
							$mysqlMessageDate=$messageDate->format( 'Y-m-d H:i:s');
						}
					}
					// there are sometimes invalid UTF-8 characters, which had to be converted like this:
					$message=mb_convert_encoding($rsMessage["message"], "UTF-8", "UTF-8");
			  		$message=$this->processEmailData($message, $account);

					// var_dump($message);exit; 
					$dataObj=new stdClass(); 
					$dataObj->headers=$message["headers"];
					$dataObj->from=$message['from'];
					$dataObj->to=$message['to'];
					$dataObj->cc=$message['cc'];
					//$dataObj->bcc=$message['bcc'];
					$dataObj->subject=$message['subject'];
					$dataObj->html=$message['html'];
					$dataObj->text=$message['text'];
					$dataObj->files=$message['files']; 
					$dataObj->plusId=$message['plusId']; 
					$dataObj->size=$message['size'];
					$dataObj->date=$mysqlMessageDate;

					/*
					// possibly useful someday:
					$msg["flagged"]
				    $msg["answered"]
				    $msg["deleted"]
				    $msg["seen"]
				    $msg["draft"]
					*/
				    // var_dump($dataObj);
					$messageJson=json_encode($dataObj,  JSON_PRETTY_PRINT); 
					if($messageJson===FALSE){
						zEmailErrorAndExit("json_encode failed on imap import", "json_encode failed on imap import.  Error message was: #json_last_error_msg()#.  IMAP Email importing will continue to fail for all sites until the developer addresses the reason json_encode is failing in order to avoid data loss.  No lead emails were marked for deletion.", false);
					}
					// var_dump(json_last_error_msg());exit;
					// var_dump($messageJson);		exit; 
					$sql="INSERT INTO queue_pop SET site_id='".$cmysql->real_escape_string($account["site_id"])."',
					imap_account_id='".$cmysql->real_escape_string($account["imap_account_id"])."',
					queue_pop_message_uid='".$cmysql->real_escape_string($uid)."',
					queue_pop_created_datetime='".$cmysql->real_escape_string($mysqlMessageDate)."',
					queue_pop_updated_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s'))."',
					queue_pop_scheduled_processing_datetime='".$cmysql->real_escape_string(date('Y-m-d H:i:s'))."', 
					queue_pop_message_json='".$cmysql->real_escape_string($messageJson)."',
					queue_pop_process_fail_count='".$cmysql->real_escape_string(0)."',
					queue_pop_process_retry_interval_seconds='".$cmysql->real_escape_string(60)."',
					queue_pop_deleted='".$cmysql->real_escape_string(0)."'";

					//echo("\n\n".$sql."\n\n");
					//break;
					$r2=$cmysql->query($sql, MYSQLI_STORE_RESULT);
					$deleteMessage=true;
					if($r2===FALSE){
						if(stristr($cmysql->error, "duplicate")){
							// duplicate key error, safe to ignore.
						}else{
							$deleteMessage=false;
							$this->logIMAPError("Failed to store email in queue_pop | site_id=".$account["site_id"]." | imap_account_id=".$account["imap_account_id"]."\nfatal db error:".$cmysql->error); 
							break;
						}
					} 
					if(!$this->readonly && $deleteMessage){
						$rsDelete=$myIMAP->deleteMessage($msgId);
						//echo("delete:".$msgId); var_dump($rsDelete);
						if(!$rsDelete["success"]){
							$this->logIMAPError("Failed to deleteMessage: ".$rsDelete["errorMessage"]);
						}
					}
				}
				if(!$this->readonly){
					$rsExpunge=$myIMAP->expungeMessages();
					//echo("expunge");	var_dump($rsExpunge);
					if(!$rsExpunge["success"]){
						$this->logIMAPError("Failed to deleteMessage: ".$rsExpunge["errorMessage"]);
					}
				}
				
				$arrIMAP[$account["imap_account_id"]]=$myIMAP;  

				if(microtimeFloat() - $this->timeStart > $this->timeout){
					//echo "Script timeout reached: ".$this->timeout. " seconds\n";
					$stopChecking=true;
					break;
				} 
				if(zIsTestServer()){
					echo('Aborting on test server since it is readonly and will never download more then '.$this->messageLimit.' messages.');
					$stopChecking=true;
				}
			}  
			// there needs to be an another loop to force this script to check accounts multiple times.
			sleep(10); // wait to avoid too many operations
			// echo microtimeFloat() - $this->timeStart;exit;
			if(microtimeFloat() - $this->timeStart > $this->timeout){
				//echo "Script timeout reached: ".$this->timeout. " seconds\n";
				$stopChecking=true;
				break;
			} 
			if($stopChecking){
				break;
			}
		}
		foreach($arrIMAP as $id=>$connection){
			$connection->close();
		}
		fclose($this->logFilePointer);
	}
}
?>