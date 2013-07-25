<?php
/*
 * compress a javascript file by removing whitespace and optionally 
 * modifying variable and function names
 */
include( '../include/config.php' );
clearstatcache();
if (!isset($_REQUEST['name']))
{
    echo "alert( 'name not set when requesting compressed javascript file' );";
    exit;
}
$file = $_REQUEST['name'];
//TODO: clean $_REQUEST['name']


$bCompress = false;
if (!file_exists($file.".js"))
{
    echo "alert( 'requested file does not exist: ".$_REQUEST['name']."');";
    exit;
}
if ((isset($_REQUEST['compress']) && $_REQUEST['compress'] != 'no') || !isset($_REQUEST['compress']))
{
    /* create the main cache directory if necessary */
    $szScriptCacheDir = $szBaseCacheDir."/scripts";
    if (!@is_dir($szScriptCacheDir))
        makeDirs($szScriptCacheDir);
    
    //file exists at this point.  Check if the compressed version exists
    if (isset($_REQUEST['force']) && $_REQUEST['force'] == 'true')
    {
        $bCompress = true;
    }
    else if (!file_exists($szScriptCacheDir."/".$file.".cjs"))
    {
        $bCompress = true;
    }
    else
    {
        //if it does exist, check the timestamp file
        if (!file_exists( $szScriptCacheDir."/".$file.".ts"))
        {
            $bCompress = true;
        }
        else
        {
            $ts = file_get_contents( $szScriptCacheDir."/".$file.".ts" );
            if ($ts != filemtime($file.".js"))
            {
                $bCompress = true;
            }
        }
    }
    
    if ($bCompress)
    {
        compressJS( $file.".js",  
                   $szScriptCacheDir."/".$file.".cjs",
                   $szScriptCacheDir."/".$file.".ts");
    }

    $h = fopen($szScriptCacheDir."/".$file.".cjs", "r");
}
else
{
    $h = fopen($file.".js", "r" );
}
fpassthru($h);
fclose($h);
exit;

function compressJS( $szJSfile, $szCJSfile, $szTSfile )
{
    $szContents = file_get_contents($szJSfile);
    
    $aSearch = array('/\/\/.*/', // c++ style comments - //something
                     '/\/\*.*\*\//sU', // c style comments - /* something */
                     '/\s{2,}/s', //2 or more spaces down to one space
                     '/\n/', //newlines removed
                     '/\s=/', //space =
                     '/=\s/', // = space
                     );
    
    $aReplace = array( '',
                       '',
                       ' ',
                       '',
                       '=',
                       '=',
                       
                      );
    //remove c++ comments
    $szContents = preg_replace( $aSearch, $aReplace, $szContents );
    
    $fh = fopen($szCJSfile, "w");
    fwrite( $fh, $szContents);
    fclose($fh);
    $ts = filemtime($szJSfile);
    $fh = fopen($szTSfile, "w");
    fwrite($fh, $ts);
    fclose($fh);
}
?>
