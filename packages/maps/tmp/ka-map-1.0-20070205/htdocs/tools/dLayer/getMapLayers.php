<?php
/**********************************************************************
 * $Id: getMapLayers.php,v 1.1 2007/01/26 14:26:26 lbecchi Exp $
 * 
 * purpose: tool to create layers on the fly (bug 1646)
 * 
 *  author: Andrea Cappugi & Lorenzo Becchi
 *
 * 
 *
 * TODO:
 *
 * 
 *
 **********************************************************************
 *
 * Copyright (c) 2006, ominiverdi.org
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

  //ERROR HANDLING
  if(isset($_REQUEST['debug'])) error_reporting ( E_ALL );
  else error_reporting( E_ERROR );
  
  include_once( '../../../include/config.php' );
  
  
  if (!extension_loaded('MapScript')) dl( $szPHPMapScriptModule );


if(isset($_REQUEST['map'])) $map= $_REQUEST['map'];
   else{
    $szResult= 'alert ("map param required");';
    echo $szResult;
    die;
  }
  
  if (isset($map) && isset($aszMapFiles[$map]))
{
    $szMap = $map;
}

$szMapCacheDir = $szBaseCacheDir.$szMap;
$szMapName = $aszMapFiles[$szMap]['title'];
$szMapFile = $aszMapFiles[$szMap]['path'];




  //should be forced by map
    $oMap = ms_newMapObj($szMapFile);
  
   $layersNames = $oMap->getAllLayerNames();

   $i=0;
    echo "layers='";
    
   		foreach($layersNames as $mapLayer){
   			echo $mapLayer;
   			if($i!=count($layersNames)-1) echo ",";
   			$i++;
	   }
  
   echo "';";
   
   
 
  
  ?>