<?php
/**********************************************************************
 *
 * $Id: kaXML2.php,v 1.1 2007/01/25 16:03:29 lbecchi Exp $
 *
 * purpose: a kml connector for Google earth (Bug 1644)
 *
 * author: Daniel Muller  (daniel@geomatic.ch) and Lorenzo Becchi (ominiverdi.org)
 *
 * TODO:
 *
 *   - many things
 *
 **********************************************************************
 *
 * Copyright (c) 2007, Geomatic.ch
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
 *
 **********************************************************************/

  if(isset($_REQUEST['debug'])) 
  error_reporting ( E_ALL );
  else error_reporting( E_ERROR );
  
 //include Ka-Map config 
include_once( '../../../include/config.php' );

//debug string
$error = array();

//open current mapfile
if (!extension_loaded('MapScript')) {
	if(!dl($szPHPMapScriptModule)) die('no mapscript available');;
} 
	

  $oMap = ms_newMapObj($szMapFile);

  
$extent = isset( $_REQUEST['e'] ) ? intval($_REQUEST['e']) : $oMap->extent->minx.",".$oMap->extent->miny.",".$oMap->extent->maxx.",".$oMap->extent->maxy ;
$scale = isset( $_REQUEST['s'] ) ? $_REQUEST['s'] : $anScales[0];
$group = isset( $_REQUEST['g'] ) ? $_REQUEST['g'] : "__base__";
  

list($minx,$miny,$maxx,$maxy)=explode(",",$extent);


if (!in_array($scale,$anScales)) {
	$error[]="Invalid scale";
}
if ($minx=="" || $miny=="" || $maxx=="" || $maxy=="") {
	$error[]="Invalid extents";
}
if ($minx>$maxx || $miny>$maxy) {
	$error[]="Invalid extents";
}

$inchesPerUnit = array(1, 12, 63360.0, 39.3701, 39370.1, 4374754);


$oMap = ms_newMapObj($szMapFile);

//here I have to check layers and groups

$cellSize=$scale/($oMap->resolution*$inchesPerUnit[$oMap->units]);
$drawOrder=ceil(1/$scale*100000);

//figure out on wich tile the top left point lies on
$tlpX = $minx/$cellSize;
$tlpY = (-1)*$maxy/$cellSize;
$tlTileX = floor($tlpX/$tileWidth)*$tileWidth;
$tlTileY = floor($tlpY/$tileHeight)*$tileHeight;

//figure out on wich tile the bottom right point lies on
$brpX = $maxx/$cellSize;
$brpY = (-1)*$miny/$cellSize;
$brTileX = floor($brpX/$tileWidth)*$tileWidth;
$brTileY = floor($brpY/$tileHeight)*$tileHeight;

/* Top left coords */

list($gTop,$gLeft)=PixToGeo($tlTileY,$tlTileX);
list($gBottom,$gRight)=PixToGeo($brTileY+$tileHeight,$brTileX+$tileWidth);
/*$gTop=round($gTop);
$gBottom=round($gBottom);
$gLeft=round($gLeft);
$gRight=round($gRight);
*/

$groupProj = '';

$nLayers = $oMap->numlayers;
for($layerIndex = 0; $layerIndex < $nLayers; ++$layerIndex) {
	$oLayer = $oMap->getLayer($layerIndex);
	if($oLayer->group == '') {
		$oLayer->set('group', '__base__');
	}
	if($group == $oLayer->group ) $groupProj = $oLayer->getProjection();
}

if(!$groupProj) $groupProj =  $oMap->getProjection();




$oProjO = ms_newprojectionobj($groupProj);
$tProjO = ms_newprojectionobj('+init=epsg:4326');



$geoTopLeftO =   ms_newpointobj();
$geoTopLeftO->setXY($gLeft,$gTop);
$geoTopLeftO->project($oProjO,$tProjO);
$geoBottomRightO =   ms_newpointobj();
$geoBottomRightO->setXY($gBottom,$gRight);
$geoBottomRightO->project($oProjO,$tProjO);

$gtleft = $geoTopLeftO->x;
$gttop = $geoTopLeftO->y; 
$gtright =  $geoBottomRightO->x;
$gtbottom =  $geoBottomRightO->y;
/*list($gtleft,$gttop)=$oWGS->xyztolbh($gTop,$gLeft,500);
list($gtright,$gtbottom)=$oWGS->xyztolbh($gBottom,$gRight,500);*/

//number of tiles I have in my extention
$nbTilesWidth=($brTileX-$tlTileX+$tileWidth)/$tileWidth;
$nbTilesHeight=($brTileY-$tlTileY+$tileHeight)/$tileHeight;

//width of one tile in projected unit (dd)
$WGSTileWidth=($gtright-$gtleft)/$nbTilesWidth;
$WGSTileHeight=($gtbottom-$gttop)/$nbTilesHeight;

$kml='<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://earth.google.com/kml/2.1">
<Document>
	<name>ka-map layer</name>
';

if (count($error)) {
	foreach ($avGroups as $groups) {
		$kml.="<Folder>\n";
		$kml.="<name>".$groups."</name>\n";
		$ny=0;
		for ($cTileY=$tlTileY;$cTileY<=$brTileY;$cTileY+=$tileHeight) {
			$nx=0;
			for ($cTileX=$tlTileX;$cTileX<=$brTileX;$cTileX+=$tileWidth) {
				$tileargs="map=".$szMap."&t=".$cTileY."&l=".$cTileX."&s=".$scale."&g=".$groups;
				$aLayersIdx = $oMap->getLayersIndexByGroup($groups);
				$oLayer = $oMap->getLayer($aLayersIdx[0]);
				$imageformat="";
				$imageformat = $oLayer->getMetaData('imageformat');
				if($imageformat == "") {
					$imageformat = $oMap->imagetype;
				}
				$tileargs.="&i=".strtoupper($imageformat);
				$tileSource = strtolower($oLayer->getMetaData('tile_source'));
				if ($tileSource == 'nocache') {
					$tileurl="/ka-map/tile_nocache.php?".$tileargs;
				}
				elseif ($tileSource == 'cache') {
					$metaLeft = floor($cTileX/($tileWidth * $metaWidth)) * $tileWidth * $metaWidth;
					$metaTop = floor($cTileY/($tileHeight * $metaHeight)) * $tileHeight * $metaHeight;
					$szMetaTileId = 't'.$metaTop.'l'.$metaLeft;
					$szGroupDir = $groups != "" ? normalizeString($groups) : "def";
					$szLayerDir = $layers != "" ? normalizeString($layers) : "def";
					$tileFolder='';
					$tileFolder=$oLayer->getMetaData('tile_folder');
					if ($tileFolder=="") $tileFolder=$szMap;

					$szCacheDir = $szBaseWebCache.$tileFolder."/".$scale."/".$szGroupDir."/".$szLayerDir."/".$szMetaTileId;
					$tileId = "t".$cTileY."l".$cTileX;
					$szImageExtension = str_replace("e","",strtolower($imageformat));
					$tileurl = $szCacheDir."/".$tileId.".".$szImageExtension;
				}
				else {
					$tileurl="/ka-map/tile.php?".$tileargs;
				}
				$tileurl="http://".$_SERVER[SERVER_NAME].$tileurl;

				/*
				list($gTop,$temp)=PixToGeo($cTileY,$cTileX+round($tileWidth/2));
				list($gBottom,$temp)=PixToGeo($cTileY+$tileHeight+3,$cTileX+round($tileWidth/2));
				list($temp,$gLeft)=PixToGeo($cTileY+round($tileHeight/2),$cTileX);
				list($temp,$gRight)=PixToGeo($cTileY+round($tileHeight/2),$cTileX+$tileWidth);
				//list($gTop,$gLeft)=PixToGeo($cTileY,$cTileX);
				//list($gBottom,$gRight)=PixToGeo($cTileY+$tileHeight,$cTileX+$tileWidth);
				$gTop=round($gTop);
				$gBottom=round($gBottom);
				$gLeft=round($gLeft);
				$gRight=round($gRight);
				list($tleft,$ttop)=$oWGS->xyztolbh($gTop,$gLeft,0);
				list($tright,$tbottom)=$oWGS->xyztolbh($gBottom,$gRight,0);
				*/

				$ttop=$gttop+$ny*$WGSTileHeight;
				$tbottom=$gttop+($ny+1)*$WGSTileHeight;
				$tleft=$gtleft+$nx*$WGSTileWidth;
				$tright=$gtleft+($nx+1)*$WGSTileWidth;
				$kml.='<GroundOverlay>
	<name>Orthophoto by Swissgeo.ch</name>
	<drawOrder>'.$drawOrder.'</drawOrder>
	<Icon>
		<href><![CDATA['.$tileurl.']]></href>
		<viewBoundScale>1</viewBoundScale>
	</Icon>
	<LatLonBox>
		<north>'.$ttop.'</north>
		<south>'.$tbottom.'</south>
		<east>'.$tright.'</east>
		<west>'.$tleft.'</west>
	</LatLonBox>
</GroundOverlay>
';
			$nx++;
			}
		$ny++;
		}
		$kml.="</Folder>\n";
	}
}
else {
	$kml.='<description>'.utf8_encode(implode("<br/>",$error)).'</description>
	';
}
$kml.='</Document>
</kml>';
Header("Content-Type: text/xml");
print $kml;

function PixToGeo($pX,$pY) {
	global $cellSize;
	$gX = -1 * $pX * $cellSize;
	$gY = $pY * $cellSize;
	return Array($gX,$gY);
}



?>