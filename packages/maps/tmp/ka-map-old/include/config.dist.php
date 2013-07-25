<?php
/****************************************************************************** 
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! configuration file
 *
 * $Id: config.dist.php,v 1.3 2005/09/23 12:04:26 pspencer Exp $
 *
 * configuring kaMap ... each section has its own description below 
 *****************************************************************************/
 
/****************************************************************************** 
 * basic system configuration
 *
 * kaMap! uses PHP/MapScript and the PHP GD extension to
 * render tiles, and uses PHP/MapScript to generate initialization parameters
 * a legend, and a keymap from the selected map file.
 *
 * Make sure to set the correct module names for your PHP extensions.
 *
 * WINDOWS USERS: you will likely need to use php_gd2.dll instead of php_gd.dll
 */
$szPHPMapScriptModule = 'php_mapscript_46.'.PHP_SHLIB_SUFFIX;
$szPHPGDModule = 'php_gd.'.PHP_SHLIB_SUFFIX;

/****************************************************************************** 
 * tile generation parameters
 *
 * kaMap! generates tiles to load in the client application by first rendering
 * larger areas from the map file and then slicing them up into smaller tiles.
 * This approach reduces the overhead of loading PHP/MapScript and PHP GD and 
 * drawing the map file.  These larger areas are referred to as metaTiles in
 * the code.  You can set the size of both the small tiles and the metaTiles
 * here.  A reasonable size for the small tiles seems to be 200 pixels square.
 * Smaller tiles seem to cause problems in client browsers by causing too many
 * images to be created and thus slowing performance of live dragging.  Larger
 * tiles take longer to download to the client and are inefficient.
 *
 * The number of smaller tiles that form a metaTile can also be configured.
 * This parameter allows tuning of the tile generator to ensure optimal
 * performance and for label placement.  MapServer will produce labels only
 * within a rendered area.  If the area is too small then features may be
 * labelled multiple times.  If the area is too large, it may exceed MapServer,s
 * maximum map size (by default 2000x2000) or be too resource-intensive on the
 * server, ultimately reducing performance.
 */
$tileWidth = 200;
$tileHeight =200;
$metaWidth = 5;
$metaHeight = 5;
/* $metaBuffer = Buffer size in pixels to add around metatiles to avoid 
 * rendering issues along the edge of the map image
 */
$metaBuffer = 10;  
    
/****************************************************************************** 
 * in-image debugging information - tile location, outlines etc.
 * to use this, you need to remove images from your cache first.  This also
 * affects the meta tiles - if debug is on, they are not deleted.
 */
$bDebug = false;
 
/****************************************************************************** 
 * aszMapFiles - an array of map files available to the application.  How this
 * is used is determined by the application.  Each map file is entered into
 * this array as a key->value pair.
 *
 * The key is the name to be used by the tile caching system to store cached
 * tiles within the base cache directory.  This key should be a single word
 * that uniquely identifies the map.
 *
 * The value associated with each key is an array of three values.  The first
 * value is a human-readable name to be presented to the user (should the
 * application choose to do so) and the second value is the path to the map
 * file.  It is assumed that the map file is fully configured for use with
 * MapServer/MapScript as no error checking or setting of values is done.  The 
 * third value is an array of scale values for zooming.
 */
 
$aszMapFiles = array(
  "gmap"   => array( "GMap", "../../gmap-ms40/htdocs/gmap75.map",
                     array( 15000000, 7500000, 3000000, 1000000 ),
                     "PNG")

/* Add more elements to this array to offer multiple mapfiles */

);

/****************************************************************************** 
 * figure out which map file to use and set up the necessary variables for
 * the rest of the code to use.  This does need to be done on every page load
 * unfortunately.
 *
 * szMap should be set to the default map file to use but can change if
 * this script is called with map=<mapname>. 
 */
$szMap = 'gmap';

/****************************************************************************** 
 * kaMap! caching
 * 
 * this is the directory within which kaMap! will create its tile cache.  The
 * directory does NOT have to be web-accessible, but it must be writable by the
 * web-server-user and allow creation of both directories AND files.
 *
 * the tile caching system will create a separate subdirectory within the base
 * cache directory for each map file.  Within the cache directory for each map
 * file, directories will be created for each group of layers.  Within the group
 * directories, directories will be created at each of the configured scales
 * for the application (see mapfile configuration above.)
 */
$szBaseCacheDir =  "/tmp/kacache/";

/*****  END OF CONFIGURABLE STUFF - unless you know what you are doing   *****/

if (isset($_REQUEST['map']) && isset($aszMapFiles[$_REQUEST['map']]))
{
    $szMap = $_REQUEST['map'];
}

$szMapCacheDir = $szBaseCacheDir.$szMap."/";
$szMapName = $aszMapFiles[$szMap][0];
$szMapFile = $aszMapFiles[$szMap][1];
$anScales = $aszMapFiles[$szMap][2];
setOutputFormat($aszMapFiles[$szMap][3]);
/****************************************************************************** 
 * output format of the map and resulting tiles
 *
 * The output format used with MapServer can greatly affect appearance and
 * performance.  It is recommended to use an 8 bit format such as PNG
 *
 * NOTE: the tile caching code in tile.php is not configurable here.  It
 * currently assumes that it is outputting 8bit PNG files.  If you change to
 * PNG24 here then you will need to update tile.php to use the gd function
 * imagecreatetruecolor.  If you change the output format to jpeg then
 * you would need to change imagepng() to imagejpeg().  A nice enhancement
 * would be to make that fully configurable from here.
 */
function setOutputFormat($szFormat)
{
    switch($szFormat) {
        case "PNG24":
            $GLOBALS['szMapImageFormat'] = 'PNG24'; //mapscript format name
            $GLOBALS['szMapImageCreateFunction'] = "imagecreatefrompng"; // appropriate GD function
            $GLOBALS['szImageExtension'] = '.png'; //file extension
            $GLOBALS['szImageCreateFunction'] = "imagecreatetruecolor"; //or imagecreatetruecolor if PNG24 ...
            $GLOBALS['szImageOutputFunction'] = "imagepng"; //or imagegif, imagejpeg ...
            $GLOBALS['szImageHeader'] = 'image/png'; //the content-type of the image        
            break;
        case "GIF":
            $GLOBALS['szMapImageFormat'] = 'GIF'; //mapscript format name
            $GLOBALS['szMapImageCreateFunction'] = "imagecreatefromgif"; // appropriate GD function
            $GLOBALS['szImageExtension'] = '.gif'; //file extension
            $GLOBALS['szImageCreateFunction'] = "imagecreate"; //or imagecreatetruecolor if PNG24 ...
            $GLOBALS['szImageOutputFunction'] = "imagegif"; //or imagegif, imagejpeg ...
            $GLOBALS['szImageHeader'] = 'image/gif'; //the content-type of the image        
            break;
        case "JPEG":
            $GLOBALS['szMapImageFormat'] = 'JPEG'; //mapscript format name
            $GLOBALS['szMapImageCreateFunction'] = "imagecreatefromjpeg"; // appropriate GD function
            $GLOBALS['szImageExtension'] = '.jpg'; //file extension
            $GLOBALS['szImageCreateFunction'] = "imagecreatetruecolor"; //or imagecreatetruecolor if PNG24 ...
            $GLOBALS['szImageOutputFunction'] = "imagejpeg"; //or imagegif, imagejpeg ...
            $GLOBALS['szImageHeader'] = 'image/jpeg'; //the content-type of the image        
            break;
        case "PNG":
            $GLOBALS['szMapImageFormat'] = 'PNG'; //mapscript format name
            $GLOBALS['szMapImageCreateFunction'] = "imagecreatefrompng"; // appropriate GD function
            $GLOBALS['szImageExtension'] = '.png'; //file extension
            $GLOBALS['szImageCreateFunction'] = "imagecreate"; //or imagecreatetruecolor if PNG24 ...
            $GLOBALS['szImageOutputFunction'] = "imagepng"; //or imagegif, imagejpeg ...
            $GLOBALS['szImageHeader'] = 'image/png'; //the content-type of the image        
            break;
    }
}

/**
 * create all directories in a directory tree - found on the php web site
 * under the mkdir function ...
 */
function makeDirs($strPath, $mode = 0777)
{
   return is_dir($strPath) or ( makeDirs(dirname($strPath), $mode) and mkdir($strPath, $mode) );
}

/**
 * This function replaces all special characters in the given string.
 *
 * @param szString string - The string to convert.
 *
 * @return string converted
 */
function normalizeString($szString)
{
    // Normalize string by replacing all special characters
    // e.g.    "http://my.host.com/cgi-bin/mywms?"
    // becomes "http___my_host_com_cgi_bin_mywms_"
    return preg_replace("/(\W)/", "_", $szString);
}
?>
