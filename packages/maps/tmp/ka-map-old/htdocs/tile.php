<?php
/***************************************************************************** 
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! tile renderer
 *
 * $Id: tile.php,v 1.30 2005/11/16 16:46:09 pspencer Exp $
 *
 * simple tile renderer for kaMap! 
 *****************************************************************************
 *
 * the tile renderer accepts several parameters and returns a tile image from
 * the cache, creating the tile only if necessary.
 *
 * all requests include the pixel location of the request at a certain scale
 * and this script figures out the geographic location of the tile from the
 * scale assuming that 0,0 in pixels is 0,0 in geographic units
 * 
 * Request parameters are:
 *
 * map: the name of the map to use.  This is handled by config.php.
 * 
 * t: top pixel position
 * l: left pixel position
 * s: scale
 * g: (optional) comma-delimited list of group names to draw
 * layers: (optional) comma-delimited list of layers to draw
 * force: optional.  If set, force redraw of the meta tile.  This was added to
 *        help with invalid images sometimes being generated.
 * tileid: (optional) can be used instead of t+l to specify the tile coord.,
 *         useful in regenerating the cache
 */

include_once( '../include/config.php' );

/* create the main cache directory if necessary */
if (!@is_dir($szMapCacheDir))
    makeDirs($szMapCacheDir);

/* get the various request parameters 
 * also need to make sure inputs are clean, especially those used to
 * build paths and filenames
 */

$top = isset( $_REQUEST['t'] ) ? intval($_REQUEST['t']) : 0;
$left = isset( $_REQUEST['l'] ) ? intval($_REQUEST['l']) : 0;
$scale = isset( $_REQUEST['s'] ) ? intval($_REQUEST['s']) : $anScales[0];
$bForce = isset($_REQUEST['force'])? true : false;
$groups = isset( $_REQUEST['g'] ) ? $_REQUEST['g'] : "";
$layers = isset( $_REQUEST['layers'] ) ? $_REQUEST['layers'] : "";

// dynamic imageformat ----------------------------------------------
//use the function in config.php to set the output format
//if (isset($_REQUEST['i']))
//    setOutputFormat( $_REQUEST['i'] );
//----------------------------------------------------------------

/* tileid=t#####l#### can be used instead of t+l parameters. Useful in
 * regenerating the cache for instance.
 */
if (isset( $_REQUEST['tileid']) &&
    preg_match("/t(-?\d+)l(-?\d+)/", $_REQUEST['tileid'], $aMatch) )
{
    $top = intval($aMatch[1]);
    $left = intval($aMatch[2]);
}

/* Calculate the metatile's top-left corner coordinates.
 * Include the $metaBuffer around the metatile to account for various
 * rendering issues happening around the edge of a map
 */
$metaLeft = floor( ($left)/($tileWidth*$metaWidth) ) * $tileWidth * $metaWidth;
$metaTop = floor( ($top)/($tileHeight*$metaHeight) ) * $tileHeight *$metaHeight;
$szMetaTileId = "t".$metaTop."l".$metaLeft;
$metaLeft -= $metaBuffer;
$metaTop -= $metaBuffer;

/* caching is done by scale value, then groups and layers and finally metatile
 * and tile id. Create a new directory if necessary
 */
$szGroupDir = $groups != "" ? normalizeString($groups) : "def"; 
$szLayerDir = $layers != "" ? normalizeString($layers) : "def"; 

$szCacheDir = $szMapCacheDir."/".$scale."/".$szGroupDir."/".$szLayerDir."/".$szMetaTileId;
if (!@is_dir($szCacheDir))
    makeDirs($szCacheDir);

/* resolve cache hit - clear the os stat cache if necessary */
$szTileId = "t".$top."l".$left;
$szCacheFile = $szCacheDir."/".$szTileId.$szImageExtension;
clearstatcache();

$szMetaDir = $szCacheDir."/meta";
if (!@is_Dir($szMetaDir))
    makeDirs($szMetaDir);

/* simple locking in case there are several requests for the same meta
   tile at the same time - only draw it once to help with performance */
$szLockFile = $szMetaDir."/lock_".$metaTop."_".$metaLeft;
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
        if (!extension_loaded('gd'))
        {
            dl( $szPHPGDModule);
        }
        
        if (!@is_Dir($szMetaDir))
            makeDirs($szMetaDir);    
        
        $oMap = ms_newMapObj($szMapFile);
               
        /* Metatile width/height include 2x the metaBuffer value */
        $oMap->set('width', $tileWidth * $metaWidth + 2*$metaBuffer);
        $oMap->set('height', $tileHeight * $metaHeight + 2*$metaBuffer);
        
        /* Tell MapServer to not render labels inside the metaBuffer area
         * (new in 4.6) 
         * TODO: Until MapServer bugs 1353/1355 are resolved, we need to
         * pass a negative value for "labelcache_map_edge_buffer"
         */
        $oMap->setMetadata("labelcache_map_edge_buffer", -$metaBuffer);

        $inchesPerUnit = array(1, 12, 63360.0, 39.3701, 39370.1, 4374754);
        $geoWidth = $scale/($oMap->resolution*$inchesPerUnit[$oMap->units]);
        $geoHeight = $scale/($oMap->resolution*$inchesPerUnit[$oMap->units]);
        
        /* draw the metatile */
        $minx = $metaLeft * $geoWidth;
        $maxx = $minx + $geoWidth * $oMap->width;
        $maxy = -1 * $metaTop * $geoHeight;
        $miny = $maxy - $geoHeight * $oMap->height;
        
        $nLayers = $oMap->numlayers;
        $oMap->setExtent($minx,$miny,$maxx,$maxy);
        $oMap->selectOutputFormat( $szMapImageFormat );               
        $aszLayers = array();
        if ($groups || $layers)
        {
            /* Draw only specified layers instead of default from mapfile*/
            if ($layers)
            {
                $aszLayers = explode(",", $layers);
            }

            if ($groups)
            {
                $aszGroups = explode(",", $groups);
            }

            for($i=0;$i<$nLayers;$i++)
            {
                $oLayer = $oMap->getLayer($i);
                if (($aszGroups && in_array($oLayer->group,$aszGroups)) ||
                    ($aszLayers && in_array($oLayer->name,$aszLayers)) ||
                    ($aszGroups && $oLayer->group == '' && 
                     in_array( "__base__", $aszGroups)))
                {
                    $oLayer->set("status", MS_ON );
                }
                else
                {
                    $oLayer->set("status", MS_OFF );
                }
            }
            //need transparency if groups or layers are used
            $oMap->outputformat->set("transparent", MS_ON );
        }
        else
        {
            $oMap->outputformat->set("transparent", MS_OFF );
        }

        
        $szMetaImg = $szMetaDir."/t".$metaTop."l".$metaLeft.$szImageExtension;
        $oImg = $oMap->draw();
        $oImg->saveImage($szMetaImg);
        $oImg->free();
        eval("\$oGDImg = ".$szMapImageCreateFunction."('".$szMetaImg."');");
        if ($bDebug)
        {
            $blue = imagecolorallocate($oGDImg, 0, 0, 255);
            imagerectangle($oGDImg, 0, 0, $tileWidth * $metaWidth - 1, $tileHeight * $metaHeight - 1, $blue );
        }
        for($i=0;$i<$metaWidth;$i++)
        {
            for ($j=0;$j<$metaHeight;$j++)
            {
                eval("\$oTile = ".$szImageCreateFunction."( ".$tileWidth.",".$tileHeight." );");
                // Allocate BG color for the tile (in case the metatile has transparent BG)
                $nTransparent = imagecolorallocate($oTile, $oMap->imagecolor->red, $oMap->imagecolor->green, $oMap->imagecolor->blue);
                //if ($oMap->outputformat->transparent == MS_ON)
                //{
                    imagecolortransparent( $oTile,$nTransparent);
                //}
                $tileTop = $j*$tileHeight + $metaBuffer;
                $tileLeft = $i*$tileWidth + $metaBuffer;
                imagecopy( $oTile, $oGDImg, 0, 0, $tileLeft, $tileTop, $tileWidth, $tileHeight );
                /* debugging stuff */
                if ($bDebug)
                {
                    $black = imagecolorallocate($oTile, 1, 1, 1);
                    $green = imagecolorallocate($oTile, 0, 128, 0 );
                    $red = imagecolorallocate($oTile, 255, 0, 0);
                    imagerectangle( $oTile, 1, 1, $tileWidth-2, $tileHeight-2, $green ); 
                    imageline( $oTile, 0, $tileHeight/2, $tileWidth-1, $tileHeight/2, $red);
                    imageline( $oTile, $tileWidth/2, 0, $tileWidth/2, $tileHeight-1, $red);
                    imagestring ( $oTile, 3, 10, 10, ($metaLeft+$tileLeft)." x ".($metaTop+$tileTop), $black );
                    imagestring ( $oTile, 3, 10, 30, ($minx+$i*$geoWidth)." x ".($maxy - $j*$geoHeight), $black );
                }
                $szTileImg = $szCacheDir."/t".($metaTop+$tileTop)."l".($metaLeft+$tileLeft).$szImageExtension;
                eval("$szImageOutputFunction( \$oTile, '".$szTileImg."' );");
                imagedestroy($oTile);
                $oTile = null;
            }
        }
        if ($oGDImg != null)
        {   
            imagedestroy($oGDImg);
            $oGDImg = null;
        }
        if (!$bDebug)
        {
            unlink( $szMetaImg );
        }
    }
    //release the exclusive lock
    flock($fpLockFile, LOCK_UN );
}

//acquire shared lock for reading to prevent a problem that could occur
//if a tile exists but is only partially generated.
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
