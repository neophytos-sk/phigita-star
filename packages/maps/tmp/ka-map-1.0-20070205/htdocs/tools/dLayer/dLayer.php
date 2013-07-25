<?php
/**********************************************************************
 * $Id: dLayer.php,v 1.3 2007/01/26 15:31:55 lbecchi Exp $
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

  session_start();
  //ERROR HANDLING
  if(isset($_REQUEST['debug'])) error_reporting ( E_ALL );
  else error_reporting( E_ERROR );
  
  include_once( '../../../include/config.php' );
  /* bug 1253 - root permissions required to delete cached files */
  $orig_umask = umask(0);

  
  
  if (!extension_loaded('MapScript')) dl( $szPHPMapScriptModule );



  
  
  //check if the session is on
  if (isset($_GET['sessionId'])){
  	 $sessionId=trim($_GET['sessionId']);
  	   session_id($sessionId);
  }
  else  $sessionId=session_id(); 
  
  
  
   if(isset($_REQUEST['name'])) $name= $_REQUEST['name'];
   else{
    $szResult= 'alert ("name param required");';
    echo $szResult;
    die;
  }
  
    
   if(isset($_REQUEST['extent'])) $extent= $_REQUEST['extent'];
   else{
    $szResult= 'alert ("extent param required");';
    echo $szResult;
    die;
  }
  

if(isset($_REQUEST['sldUrl'])) $sldUrl= $_REQUEST['sldUrl'];
   else{
    $szResult= 'alert ("sldUrl  param required");';
    echo $szResult;
    die;
  }
  
if(isset($_REQUEST['layers'])) $layers= $_REQUEST['layers'];
   else{
    $szResult= 'alert ("layers param required");';
    echo $szResult;
    die;
  }
  
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
    $oMap->selectOutputFormat( 'PNG' );//changed from $szMapImageFormat 
	$oMap->imagecolor->setRGB( -1,-1,-1);
	$oMap->outputformat->set("transparent", MS_ON );
  

  /*Destroy old cache dir*/
  $queryCacheDir = $szBaseCacheDir."/sessions/".$sessionId."/dLayer/";
  if (is_dir($queryCacheDir))
   remove_directory($queryCacheDir);
   
  //Build query sys cache directory!!
  $szQueryCacheDir=$szBaseCacheDir."/sessions/".$sessionId."/dLayer/".$szMap."/".$name."/"; 
  /* create the main sessionID cache directory if necessary */
  if (!@is_dir($szQueryCacheDir))
    makeDirs($szQueryCacheDir);

   $layersNames = $oMap->getAllLayerNames();

   foreach (explode(',',$layers) as $layer){
   		foreach($layersNames as $mapLayer){
   			//echo "$mapLayer==$layer<br>";
   			$tempLayer = $oMap->getLayerByName($mapLayer);
			$tempLayer->set('status', MS_OFF );
   			if($mapLayer==$layer) {
   				$tempLayer = $oMap->getLayerByName($layer);
   				$tempLayer->set('group',$name);
   				$tempLayer->set('status', MS_ON );
   				
   			} 
   		}
   }
   


	$mapPath = $szQueryCacheDir."dLayer.map";
	if(isset($_REQUEST['debug']))echo "$mapPath;";
	$oMap->save($mapPath);
	$_SESSION['dMapPath'] = $mapPath ;
	
	
   
   
   
  echo "this.sessionid='$sessionId';dResult=true";
  
  
  
function remove_directory($dir) {
       $dir_contents = myScandir($dir);
       foreach ($dir_contents as $item) {
           if (is_dir($dir.$item) && $item != '.' && $item != '..') {
               remove_directory($dir.$item.'/');
           }
           elseif (file_exists($dir.$item) && $item != '.' && $item != '..') {
               unlink($dir.$item);
           }
       }
       rmdir($dir);
   }
   

 	function myScandir($dir){
 		$dirhandle = opendir($dir);
 		$dir_contents = array();
		while(( $file = readdir($dirhandle)) !== false)
		{
			if (( $file != "." )&&( $file != ".."))
			{
				$dir_contents[] = $file;
			}
		}
		return $dir_contents;
			
 	}
?>

