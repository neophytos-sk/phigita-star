<?

$fh = fopen("dhtml-suite-for-applications.js","r");
$data = fread($fh,filesize("dhtml-suite-for-applications.js"));
fclose($fh);
# /*[FILE_START:dhtmlsuite-contextMenu.js] */
$chunks = explode("/*[FILE_START:",$data);

for($no=0;$no<count($chunks);$no++){
	$endPos = strpos($chunks[$no],"]");
	$filename = substr($chunks[$no],0,$endPos);
	echo $filename . "<br>";	
	
	$startposfile = strpos($chunks[$no],"\n");
	$chunks[$no] = substr($chunks[$no],$startposfile);
	$chunks[$no] = trim($chunks[$no]);
	if($filename){
		$fh2 = fopen("separateFiles/$filename","w");
		fwrite($fh2,$chunks[$no]);
		fclose($fh2);
	}
	
	
}

#strippedVersions


?>