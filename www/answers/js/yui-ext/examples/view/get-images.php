<?
$dir = "images/thumbs/";
require_once('../../../../build/JSON.php');

$images = array();
$d = dir($dir);
while($name = $d->read()){
    if(!preg_match('/\.(jpg|gif|png)$/', $name)) continue;
    $size = filesize($dir.$name);
    $lastmod = filemtime($dir.$name)*1000;
    $images[] = array('name'=>$name, 'size'=>$size, 
			'lastmod'=>$lastmod, 'url'=>$dir.$name);
}
$d->close();
$o = array('images'=>$images);
$json = new Services_JSON();
echo $json->encode($o);
?>