<?php
/******************************************************************************
 *
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! keymap generator
 *
 * This file is called from the kaMap! module using XMLHttpRequest.  The result
 * is a URL to the generated keymap image.
 * 
 * $Id: keymap.php,v 1.8 2005/11/16 16:45:31 pspencer Exp $
 *
 *****************************************************************************/
include_once('../include/config.php');

if (!extension_loaded('MapScript'))
{
    dl( $szPHPMapScriptModule );
}

$oMap = ms_newMapObj($szMapFile);

if (isset($_GET['loadImage']) && $_GET['loadImage']=='true')
{
    $img = $oMap->reference->image;
    
    if (substr($img, 0, 1) != '/' && substr($img,1,1) != ':')
    {
        $img = realpath( dirname(__FILE__)."/".dirname($szMapFile)."/".$img );
    }
    else
    {
        $img = realpath( $img );
    }
    //TODO: make this sensitive to the image extension
    header( 'Content-type: image/png');
    readfile($img);
    exit;
}
/*
$webDir = $oMap->web->imagepath;
$webURL = $oMap->web->imageurl;

if (substr ($webURL, strlen ($webURL) - 1) == "/")
 $webURL = substr ($webURL, 0, strlen ($webURL) - 1);

$ext  = array_pop(explode('.', $img));
$filename = basename($img, '.'.$ext);
$tmpName = md5($img).".".$ext;

if (!file_exists($webDir."/".$tmpName))
{
    copy($img, $webDir."/".$tmpName);
}
$imgurl = $webURL."/".$tmpName;
*/
$extent = $oMap->reference->extent->minx.",". 
          $oMap->reference->extent->miny.",".
          $oMap->reference->extent->maxx.",".
          $oMap->reference->extent->maxy;
$width = $oMap->reference->width;
$height = $oMap->reference->height;

//determine keymap.php url :(

$szURL = 'http';
if (isset($_SERVER['HTTPS'])&& strcasecmp($_SERVER['HTTPS'], 'off') != 0 )
    $szURL .= "s";
$szURL .= "://";
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

$szResult = "this.aExtents = new Array(".$extent.");";
$szResult .= "this.imgSrc = '".$szURL."keymap.php?loadImage=true';";
$szResult .= "this.imgWidth = ".$width.";";
$szResult .= "this.imgHeight = ".$height.";";
echo $szResult;
?>
