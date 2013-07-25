<?php
/******************************************************************************
 * $Id: init.php,v 1.20 2005/09/23 12:29:48 pspencer Exp $
 ******************************************************************************
 * Copyright (c) 2005, DM Solutions Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************
 * kaMap! session initialization file
 *
 * This file is called from the kaMap! module using XMLHttpRequest.  The result
 * is evaluated as javascript and should initialize the kaMap! instance with
 * the map files and various related information about them.  This script
 * should only be called once per session.  To retrieve specific information
 * about a map when selecting or re-initializing, call initMap.php
 *
 * Parameters that this script accepts are:
 *
 * map=<map name> - used to specify a map to start up with.  If not set, the
 * default map file from the config.php file will be used.  If set, it will
 * check to see if the requested map name exists in the config file and use
 * if it does.
 *
 *
 *****************************************************************************/
include_once( '../include/config.php' );

if (!extension_loaded('MapScript'))
{
    dl( $szPHPMapScriptModule );
}

$szResult = '/*init*/'; //leave this in so the js code can detect errors
foreach($aszMapFiles as $key => $aszMapFile)
{
    $oMap = ms_newMapObj( $aszMapFile[1] );
    $szResult .= "aszScales=new Array(".implode(",", $aszMapFile[2]).");";
    $aGroups = array();
    
    /* 
     * for this version, I have chosen to use groups to turn layers on and off
     * a special group called __base__ is created to hold all ungrouped layers
     * This group cannot be turned on/off in the interface (or at least not
     * using the default legend template
     */
    $szLayers = '';
    for($i=0; $i<$oMap->numlayers; $i++)
    {
        $oLayer = $oMap->getLayer($i);
        if ($oLayer->group != '')
        {
            if (!isset($aGroups[$oLayer->group]))
            {
                $aGroups[$oLayer->group] = 0;
                $status = ($oLayer->status!=MS_OFF)?'true':'false';
                $opacity = $oLayer->getMetaData( 'opacity' );
                
                /* dynamic imageformat */
                $imageformat = $oLayer->getMetaData( 'imageformat' );
                if ($imageformat == '')
                   $imageformat = $oMap->imagetype; //imagetype is depracated, must use detection of php_mapscript version
                /* dynamic imageformat */
                
                /* queryable */
                $szQueryable = "false";
                if ($oLayer->getMetaData( "queryable" ) != "")
                {
                    if (strcasecmp($oLayer->getMetaData("queryable"), "true") == 0)
                    {
                        $szQueryable = "true";
                    }
                }
                
                                
                if ($opacity == '')
                    $opacity = 100;
                $szLayers .= "map.addLayer(new _layer( '".$oLayer->group."', ".$status.", ".$opacity.", '".$imageformat."',".$szQueryable."));"; //added imageformat parameter
            }
        }
        else if (!isset($aGroups['__base__']))
        {
            $aGroups['__base__'] = 0;
            $szLayers .= "map.addLayer( new _layer( '__base__', true, 100 ) );";
        }

    }
    
    $units = $oMap->units;
    $szResult .= "var map = new _map( '".$key."', '".$aszMapFile[0].
                                      "', 0, ".$units.", aszScales);";
    $szResult .= "map.setDefaultExtents(".$oMap->extent->minx.",".
                                          $oMap->extent->miny.",".
                                          $oMap->extent->maxx.",".
                                          $oMap->extent->maxy.");";
    if ($oMap->getMetaData( "max_extents") != '')
    {
        $szResult .= "map.setMaxExtents(".$oMap->getMetaData("max_extents").");";
    }
    $szResult .= "map.setBackgroundColor('rgb(".$oMap->imagecolor->red.",".$oMap->imagecolor->green.",".$oMap->imagecolor->blue.")');";
    $szResult .= $szLayers;
    
    if (isset($_GET['extents']) && $szMap == $key)
    {
        $szResult .= "map.setCurrentExtents(".$_GET['extents'].");";
    }
    if (isset($_GET['centerPoint']) && $szMap == $key)
    {
        $szResult .= "map.aZoomTo=new Array(".$_GET['centerPoint'].");";
    }
    
    $szResult .= "map.resolution = ".$oMap->resolution.";";
    
    $szResult .= "this.addMap( map );";

}    
$szResult .= "this.tileWidth=$tileWidth;";
$szResult .= "this.tileHeight=$tileHeight;";

//default values for scripts that work with this backend:

//echo '<pre>';
//print_r($_SERVER);
//echo '</pre>';

$szURL = 'http';
if (isset($_SERVER['HTTPS'])&& strcasecmp($_SERVER['HTTPS'], 'off') != 0 ) $szURL .= "s";
$szURL .= ":";
$szURL .= "//";
if (isset($_SERVER['HTTP_X_FORWARDED_HOST']))
    $szURL .= $_SERVER['HTTP_X_FORWARDED_HOST'];
else
{
    $szURL .= $_SERVER['HTTP_HOST'];
    if (!strpos($szURL,':')) 
    {  // check to make sure port is not already in SERVER_HOST variable
         if (isset($_SERVER['SERVER_PORT']) && $_SERVER['SERVER_PORT'] != '80')
               $szURL .= ":".$_SERVER['SERVER_PORT'];
    }
}

if( isset( $_SERVER['REQUEST_URI'] ) )
{
    if ((substr($szURL, -1, 1) != '/') &&
        (substr($_SERVER['REQUEST_URI'],0,1) != '/'))
    {
        $szURL .= "/";
    }
    $szURL .= dirname($_SERVER['REQUEST_URI'])."/";
}
else
{
    if ((substr($szURL, -1, 1) != '/') &&
        (substr($_SERVER['PHP_SELF'],0,1) != '/'))
    {
        $szURL .= "/";
    }
    $szURL .= dirname($_SERVER['PHP_SELF'])."/";
}

$szResult .= "this.server = '".$szURL."';";
$szResult .= "this.tileURL = 'tile.php';";

$szResult .= "this.selectMap('$szMap');";
echo $szResult;
?>
