<?php
/**********************************************************************
 * $Id: kaRouting.php,v 1.11 2007/01/29 13:58:16 lbecchi Exp $
 * 
 *  purpose: generic system to connect ka-map to 
 *  Orkney pgRouting (www.postlbs.org), kaRouting module (Bug 1643)
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

  //define("MAPFILE","/home/kappu/www/routingj/maps/routing1.map");
  

  $conStr = $kaRoute['pgConn'];

  

  //check if the session is on
  if (isset($_GET['sessionId']))
  {
  	 $sessionId=trim($_GET['sessionId']);
 	   session_id($sessionId);
  }
  else  $sessionId=session_id(); 
 
  /*Destroy old cache dir*/
  if (is_dir($szBaseCacheDir."/sessions/".$sessionId."/Routing/"))
   remove_directory($szBaseCacheDir."/sessions/".$sessionId."/Routing/");


  $start=0;
  $end=0;
  
  if($HTTP_GET_VARS["start"])
  {
    $start=$HTTP_GET_VARS["start"];
  	$aStart=explode("|",$start);
  }
  if($HTTP_GET_VARS["end"])
  {
    $end=$HTTP_GET_VARS["end"];
  	$aEnd=explode("|",$end);
  }
  if($HTTP_GET_VARS["extent"]){
    $extents=$HTTP_GET_VARS["extent"];
    $aExtents=explode("|",$extents);
  }
  $delta=$kaRoute['buffer'] ;
  /* getting start and end points id*/
  /* select the nearest extremity of the nearest segement */
  $sql="select source,distance(startPoint(the_geom),geometryfromtext( 'POINT(".$aStart[0]." ".$aStart[1].")', -1)) AS dist2 FROM $kaRoute[myGraphTable] , (SELECT gid , distance(the_geom, geometryfromtext( 'POINT(".$aStart[0] ." ".$aStart[1].")', -1)) AS dist FROM $kaRoute[myGraphTable] WHERE the_geom && expand(geometryfromtext( 'POINT(".$aStart[0] ." ".$aStart[1].")', -1),".$delta.") ORDER BY dist LIMIT 1) as foo WHERE $kaRoute[myGraphTable].gid=foo.gid union select target,distance(endPoint(the_geom),geometryfromtext( 'POINT(".$aStart[0] ." ".$aStart[1].")', -1)) AS dist2 FROM $kaRoute[myGraphTable] , (SELECT gid , distance(the_geom, geometryfromtext( 'POINT(".$aStart[0] ." ".$aStart[1].")', -1)) AS dist FROM $kaRoute[myGraphTable] WHERE the_geom && expand(geometryfromtext( 'POINT(".$aStart[0] ." ".$aStart[1].")', -1),".$delta.") ORDER BY dist LIMIT 1) as foo WHERE $kaRoute[myGraphTable].gid=foo.gid order by dist2 limit 1;";
//echo("<br> $sql");  
    if(isset($_REQUEST['debug'])) $dbcon = pg_connect( $conStr );
    else @$dbcon = pg_connect( $conStr );
    
  if( $dbcon )
  {
    if(isset($_REQUEST['debug'])) echo "<p>sql: $sql</p>";
  	if(isset($_REQUEST['debug'])) $res = pg_query($dbcon,$sql );
    else @$res = pg_query($dbcon,$sql );
    @$rowCount = pg_num_rows( $res );
    
    if($res)
    {
      while( $row = pg_fetch_row($res) )
      {
        $start = $row[0];
  
      }
    }
  }
  $sql="select source,distance(startPoint(the_geom),geometryfromtext( 'POINT(".$aEnd[0]." ".$aEnd[1].")', -1)) AS dist2 FROM $kaRoute[myGraphTable] , (SELECT gid , distance(the_geom, geometryfromtext( 'POINT(".$aEnd[0] ." ".$aEnd[1].")', -1)) AS dist FROM $kaRoute[myGraphTable] WHERE the_geom && expand(geometryfromtext( 'POINT(".$aEnd[0] ." ".$aEnd[1].")', -1),".$delta.") ORDER BY dist LIMIT 1) as foo WHERE $kaRoute[myGraphTable].gid=foo.gid union select target,distance(endPoint(the_geom),geometryfromtext( 'POINT(".$aEnd[0] ." ".$aEnd[1].")', -1)) AS dist2 FROM $kaRoute[myGraphTable] , (SELECT gid , distance(the_geom, geometryfromtext( 'POINT(".$aEnd[0] ." ".$aEnd[1].")', -1)) AS dist FROM $kaRoute[myGraphTable] WHERE the_geom && expand(geometryfromtext( 'POINT(".$aEnd[0] ." ".$aEnd[1].")', -1),".$delta.") ORDER BY dist LIMIT 1) as foo WHERE $kaRoute[myGraphTable].gid=foo.gid order by dist2 limit 1;";
//echo("<br> $sql"); 
 if( $dbcon )
  {
    if(isset($_REQUEST['debug'])) echo "<p>sql: $sql</p>";
  	if(isset($_REQUEST['debug'])) $res = pg_query($dbcon,$sql );
    else @$res = pg_query($dbcon,$sql );
    @$rowCount = pg_num_rows( $res );
    if($res)
    {
      while( $row = pg_fetch_row($res) )
      {
        $end = $row[0];
      }
    }
  }
 // echo("$start $end");
  /*clear session route table*/
  $sql="DELETE FROM kroute WHERE sessionid='".$sessionId."';";  
  if( $dbcon )
  {
    if(isset($_REQUEST['debug'])) echo "<p>sql: $sql</p>";
  	if(isset($_REQUEST['debug'])) $res = pg_query($dbcon,$sql );
    else @$res = pg_query($dbcon,$sql );
  }
  /*create peth in db kroute*/
  $sql="INSERT INTO kroute (the_geom, sessionid, date) SELECT Collect(GeometryN(the_geom,1)) As geom, 
'".$sessionId."' as id , current_date As dd  FROM $kaRoute[myGraphTable] 
,(SELECT  * from shortest_path_astar('SELECT gid as id, source::int4,target::int4,
 $kaRoute[costColumn]::double precision as cost, $kaRoute[reverseCostColumn]::double precision as reverse_cost, x1, y1, x2, y2 
FROM $kaRoute[myGraphTable]', $start,$end , $kaRoute[directed], $kaRoute[has_reverse_cost])) as foo where gid=foo.edge_id;"; 
 /* $sql ="INSERT INTO kroute (the_geom , sessionid, date)
         SELECT  Collect(GeometryN(the_geom,1)), '".$sessionId."' as id ,current_date As dd   from shortest_path_astar2_as_geometry_internal_id('$kaRoute[myGraphTable]',$start,$end, $aExtents[0] ,$aExtents[1] , $aExtents[2], $aExtents[3]);";*/
  //echo("<br> $sql");
  if( $dbcon )
  {
  	if(isset($_REQUEST['debug'])) echo "<p>sql: $sql</p>";
    if(isset($_REQUEST['debug'])) $res = pg_query($dbcon,$sql );
    else @$res = pg_query($dbcon,$sql );
  }
  echo "this.sessionid='$sessionId';this.route=true";
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

