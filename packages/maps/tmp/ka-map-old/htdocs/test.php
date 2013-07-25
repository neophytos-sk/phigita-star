<?php
//tile.php - create tiles ...

$top = $_REQUEST['t'];
$left = $_REQUEST['l'];
$width = $_REQUEST['w'];
$height = $_REQUEST['h'];
$scale = $_REQUEST['s'];

if (!extension_loaded('MapScript'))
{
    dl('php_mapscript.'.PHP_SHLIB_SUFFIX );
}
if (!extension_loaded('gd'))
{
    dl('php_gd.'.PHP_SHLIB_SUFFIX);
}

$oImg = imagecreate( $width, $height );

$randColor = imagecolorallocate( $oImg, rand(128, 255), rand(128,255), rand(128,255) );
$black = imagecolorallocate($oImg, 0, 0, 0);
imagefill($oImg, 0, 0, $randColor );
imagestring ( $oImg, 3, 10, 10, $top." x ".$left, $black );
// make sure this thing doesn't cache
//header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
//header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
//header("Cache-Control: no-store, no-cache, must-revalidate");
//header("Cache-Control: post-check=0, pre-check=0", false);
//header("Pragma: no-cache");
header("Content-type: image/png");
imagepng($oImg);
?>
