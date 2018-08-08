<?php  
function recursiveSearchForSiteCompile($folder, $pattern) {
	$filter = array('.git', 'zcompiled', 'tinymce', 'tiny_mce');
    //$ite = new RecursiveIteratorIterator($dir);
    $ite = new RecursiveIteratorIterator(
		new RecursiveCallbackFilterIterator(
			new RecursiveDirectoryIterator(
				$folder,
				RecursiveDirectoryIterator::SKIP_DOTS
			),
			function ($fileInfo, $key, $iterator) use ($filter) {
				return $fileInfo->isFile() || !in_array($fileInfo->getBaseName(), $filter);
			}
		)
	);
    $files = new RegexIterator($ite, $pattern, RegexIterator::MATCH);//, RegexIterator::GET_MATCH);
    $fileList = array();
    foreach($files as $file) {
    	array_push($fileList, $file->getPathname());
    }
    return $fileList;
}
function compileSiteFiles($row, &$arrDebug=array()){ 
	$siteInstallPath=zGetDomainInstallPath($row["site_short_domain"]);
	$siteWritableInstallPath=zGetDomainWritableInstallPath($row["site_short_domain"]);

	$arrMD5=array();
	$logDir=get_cfg_var("jetendo_log_path");
	$jsMD5Path=$logDir."deploy/compile-md5-site-".$row["site_short_domain"].".txt";

	// fix gitignore
	$ignoreFile=$siteInstallPath.".gitignore";
	if(file_exists($ignoreFile)){
		$arrLine=explode("\n", file_get_contents($ignoreFile));
		$match=false;
		for($i=0;$i<count($arrLine);$i++){
			if(trim($arrLine[$i])=="zcompiled"){
				$match=true;
				break;
			}
		}
		if(!$match){
			file_put_contents($ignoreFile, "zcompiled\n".implode("\n", $arrLine));
		}
	}else{
		file_put_contents($ignoreFile, "__zdeploy-*.txt\nzcompiled\n*.sublime-workspace\n.DS_Store");
	}
	
	if(file_exists($jsMD5Path)){
		$oldMD5Hash=md5_file($jsMD5Path);
		$arrMD5Old=explode("\n", file_get_contents($jsMD5Path));
	}else{
		$oldMD5Hash="";
		$arrMD5Old=array();

	}
	$arrNewLookup=array();
	$arrOldLookup=array();
	$versionString="/zv".date("YmdHis")."/";

	foreach($arrMD5Old as $line){
		if(trim($line) == ""){
			continue;
		}
		$arrLine=explode("\t", $line);
		if(count($arrLine) == 2){
			$arrOldLookup[$arrLine[0]]=$arrLine[1];
		}
	}
	$arrCompile=array();
	$arrNewFile=array();
	$a=recursiveSearchForSiteCompile($siteInstallPath, '/.*\.(css)$/'); //|js

	foreach($a as $currentSourcePath){
		$path=dirname($currentSourcePath);
		array_push($arrCompile, $currentSourcePath);
		$arrNewLookup[$currentSourcePath]=md5_file($currentSourcePath);
		array_push($arrNewFile, $currentSourcePath."\t".$arrNewLookup[$currentSourcePath]);
	}
	$fp=fopen($jsMD5Path, "w");
	fwrite($fp, implode("\n", $arrNewFile));
	fclose($fp);
	if(count($arrCompile)){ 
		if($oldMD5Hash == "" || md5_file($jsMD5Path) != $oldMD5Hash){
			for($i=0;$i<count($arrCompile);$i++){
				$currentSourcePath=$arrCompile[$i];

				if(isset($arrOldLookup[$currentSourcePath]) && $arrNewLookup[$currentSourcePath] == $arrOldLookup[$currentSourcePath]){ 
					continue;
				}
				$path=dirname($currentSourcePath);
				$newFilePath=str_replace($siteInstallPath, $siteInstallPath."zcompiled/", $currentSourcePath);

				$newPath=str_replace($siteInstallPath, $siteInstallPath."zcompiled/", $path);
				$out=file_get_contents($currentSourcePath); 
				if(substr($newFilePath, strlen($newFilePath)-4, 4) == ".css"){
					$out=str_replace("url(/", "url(/z~~~v/", $out);
					$out=str_replace("url('/", "url('/z~~~v/", $out);
					$out=str_replace('url("/', 'url("/z~~~v/', $out);
					$out=str_replace('/z~~~v/zv/', '/z~~~v/', $out);
					$out=str_replace("/z~~~v//", "//", $out);
					$out=str_replace("/z~~~v/", $versionString, $out);
				}
				$out=str_replace("/zv/", $versionString, $out);
				if(!is_dir($newPath)){
					mkdir($newPath, 0777, true);
				}
				if(file_exists($newFilePath)){
					unlink($newFilePath);
				}
				// automatically has correct permissions
				file_put_contents($newFilePath, $out);
				array_push($arrDebug, "compiled:".$currentSourcePath."\n");
			}  
		}
	} 
	return true;
}
function compileAllPackages(&$arrDebug=array()){
	$rootPath=get_cfg_var('jetendo_root_path');
	$jsPath=$rootPath."public/javascript/";
	
	$a=glob($jsPath."jetendo/*");
	// everything
	//array_push($a, $jsPath.'jquery/balupton-history/scripts/uncompressed/json2.js');
	$isCompiled=compileJS($a, "jetendo-no-listing.js", $arrDebug);
	if(!$isCompiled){
		return false;
	}
	
	// no listing
	$arrListing=glob($jsPath."jetendo-listing/*");
	$a=array_merge($a, $arrListing);
	$isCompiled=compileJS($a, "jetendo.js", $arrDebug);
	if(!$isCompiled){
		return false;
	}
	return true;
}
function compileJS($arrFiles, $outputFileName, &$arrDebug=array()){
	// manually list the files we want to compress
	$rootPath=get_cfg_var("jetendo_root_path");
	$sourcePath=$rootPath."public/javascript/";
	$compilePath=$rootPath."public/javascript-compiled/";
	$arrLog=array("compileJS started at ".date('l jS \of F Y h:i:s A'));
	
	$versionString="/zv".date("YmdHis")."/";

	$arrMD5=array();
	$logDir=get_cfg_var("jetendo_log_path");
	$jsMD5Path=$logDir."deploy/compile-md5-".$outputFileName.".txt";
	if(file_exists($jsMD5Path)){
		$oldMD5Hash=md5_file($jsMD5Path);
	}else{
		$oldMD5Hash="";
	}
	$arrCompile=array();
	$arrNewFile=array();
	for($i=0;$i<count($arrFiles);$i++){
		$currentSourcePath=$arrFiles[$i];
		array_push($arrCompile, escapeshellarg($currentSourcePath));
		array_push($arrNewFile, $currentSourcePath."\t".md5_file($currentSourcePath));
	}
	$fp=fopen($jsMD5Path, "w");
	fwrite($fp, implode("\n", $arrNewFile));
	fclose($fp);
	if(count($arrCompile)){
		if(md5_file($jsMD5Path) != $oldMD5Hash){
			if(file_exists($compilePath.$outputFileName)){
				//$oldMd5=md5_file($compilePath.$outputFileName);
				unlink($compilePath.$outputFileName);
			}else{
				//$oldMd5="";
			}

			// isCompiled
			$cmd="java -jar ".$rootPath."scripts/closure-compiler.jar  --js ".implode(" --js ", $arrCompile)." --create_source_map ".$compilePath.$outputFileName.".map --source_map_format=V3 --js_output_file ".$compilePath.$outputFileName." 2>&1";
			array_push($arrLog, $cmd."\n");
			echo $cmd."\n\n";
			$r=`$cmd`;
			array_push($arrDebug, "Response: ".$r);
			if(trim($r) != ""){
				array_push($arrLog, "Compilation failed and requires manual corrections to the javascript.");
				array_push($arrDebug, "Compilation failed and requires manual corrections to the javascript. 1");
				@unlink($jsMD5Path);
				return false;
			}
			array_push($arrLog, $r."\n\n");
			if(!file_exists($compilePath.$outputFileName)){
				array_push($arrLog, "Compilation failed and requires manual corrections to the javascript.");
				array_push($arrDebug, "Compilation failed and requires manual corrections to the javascript. 2");
				unlink($jsMD5Path);
				return false;
			}else{
				file_put_contents($compilePath.$outputFileName, $data="//# sourceMappingURL=".$outputFileName.".map\n".str_replace("/zv/", $versionString, file_get_contents($compilePath.$outputFileName)));
				file_put_contents($compilePath.$outputFileName.".map", str_replace($rootPath."public/", "/z/", str_replace("/zv/", $versionString, file_get_contents($compilePath.$outputFileName.".map"))));
			}

			$arrOutput=array();
			for($i=0;$i<count($arrCompile);$i++){
				$c=substr($arrCompile[$i], 1, strlen($arrCompile[$i])-2);
				$n=file_get_contents($c);
				array_push($arrOutput, "\n/* ".$c." */\n".$n);
			}
			$uncompressedPath=$compilePath.str_replace(".js", ".combined.js", $outputFileName);
			file_put_contents($uncompressedPath, implode("\n", $arrOutput));
		}
	}
	$fp=fopen(get_cfg_var("jetendo_log_path")."deploy/compile-js-css-log.txt", "a");
	fwrite($fp, implode("\n", $arrLog)."\n");
	fclose($fp);
	return true;
}
?>