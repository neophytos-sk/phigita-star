<?php
/******************************************************************************
 *
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! legend generator
 *
 * This file is called from the kaMap! module using XMLHttpRequest.  The result
 * is a URL to the generated legend image.
 * 
 * $Id: legend.php,v 1.6 2005/09/09 14:16:45 pspencer Exp $
 *
 *****************************************************************************/
include_once('../include/config.php');

if (!extension_loaded('MapScript'))
{
    dl( $szPHPMapScriptModule );
}

$groups = isset( $_REQUEST['g'] ) ? $_REQUEST['g'] : "";
$layers = isset( $_REQUEST['layers'] ) ? $_REQUEST['layers'] : "";

$oMap = ms_newMapObj($szMapFile);
$oPoint = ms_newPointObj( );
$oPoint->setXY($oMap->width/2, $oMap->height/2 );
$oMap->zoomScale( $_REQUEST['scale'], $oPoint, $oMap->width, $oMap->height, $oMap->extent );

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
    $nLayers = $oMap->numlayers;
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
}
header( 'Content-type: image/png' );
$oImg = $oMap->drawLegend();

$szURL = $oImg->saveImage("");
?>
