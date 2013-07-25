<?php
/******************************************************************************
 *
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! scalebar generator
 *
 * This file is called from the kaMap! module using XMLHttpRequest.  The result
 * is a URL to the generated scalebar image.
 * 
 * $Id: scalebar.php,v 1.6 2005/09/09 15:36:40 pspencer Exp $
 *
 *****************************************************************************/
include_once('../include/config.php');

$szScalebarCacheDir = $szMapCacheDir."/scalebars";

/* create the main cache directory if necessary */
if (!@is_dir($szScalebarCacheDir))
    makeDirs($szScalebarCacheDir);

/* get the various request parameters 
 * also need to make sure inputs are clean, especially those used to
 * build paths and filenames
 */
$bForce = isset($_REQUEST['force'])? true : false;
$scale = isset( $_REQUEST['scale'] ) ? intval($_REQUEST['scale']) : $anScales[0];

/* resolve cache hit - clear the os stat cache if necessary */
$szCacheFile = $szScalebarCacheDir."/".$scale.$szImageExtension;
clearstatcache();


/* simple locking in case there are several requests for the same meta
   tile at the same time - only draw it once to help with performance */
$szLockFile = $szCacheFile.".lock";
$fpLockFile = fopen($szLockFile, "a+");
clearstatcache();

if (!file_exists($szCacheFile) || $bForce)
{
    flock($fpLockFile, LOCK_EX);
    fwrite($fpLockFile, ".");
    
    //check once more to see if the cache file was created while waiting for
    //the lock
    clearstatcache();
    if (!file_exists($szCacheFile) || $bForce)
    {

        if (!extension_loaded('MapScript'))
        {
            dl( $szPHPMapScriptModule );
        }

        $oMap = ms_newMapObj($szMapFile);
        $oPoint = ms_newPointObj( );
        $oPoint->setXY($oMap->width/2, $oMap->height/2 );
        $oMap->zoomScale( $scale, $oPoint, $oMap->width, $oMap->height, $oMap->extent );

        $oImg = $oMap->drawScalebar();

        $oImg->saveImage($szCacheFile);
        $oImg->free();

    }
}

//acquire shared lock for reading to prevent a problem that could occur
//if the scalebar exists but is only partially generated.
flock($fpLockFile, LOCK_SH);

$h = fopen($szCacheFile, "r");
header("Content-Type: ".$szImageHeader);
header("Content-Length: " . filesize($szCacheFile));
header("Expires: " . date( "D, d M Y H:i:s GMT", time() + 31536000 ));
header("Cache-Control: max-age=31536000, must-revalidate" );
fpassthru($h);
fclose($h);

//release lock
fclose($fpLockFile);
exit;

?>
