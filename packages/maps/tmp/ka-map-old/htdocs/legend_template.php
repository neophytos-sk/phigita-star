<?php
/******************************************************************************
 *
 * Copyright DM Solutions Group Inc 2005.  All rights reserved.
 *
 * kaMap! legend template generator
 *
 * This file is called from the kaMap! module using XMLHttpRequest.  The result
 * is HTML contents to be placed in the legend <div> element.
 * 
 * $Id: legend_template.php,v 1.5 2005/09/09 14:16:45 pspencer Exp $
 *
 *****************************************************************************/
include_once('../include/config.php');

$groups = isset( $_REQUEST['g'] ) ? $_REQUEST['g'] : "";
$layers = isset( $_REQUEST['layers'] ) ? $_REQUEST['layers'] : "";

if (!extension_loaded('MapScript'))
{
    dl( $szPHPMapScriptModule );
}

$oMap = ms_newMapObj($szMapFile);
$oMap->legend->set( "template", dirname(__FILE__)."/legend_template.html" );
for($i=0;$i<$oMap->numlayers;$i++)
{
    $oLayer = $oMap->getLayer($i);
    if ($oLayer->group == '')
    {
        $oLayer->set('group', '__base__');
        $oLayer->setMetaData( 'hide_checkbox', '1' );
        $oLayer->setMetaData( 'group_title', 'Base Layers' );
    }
    else
        $oLayer->setMetaData( "group_title", $oLayer->group );
}

$szResult = $oMap->processLegendTemplate(array());
$szHeader = <<<EOT
<style type="text/css">
.legendClassLabel {
  font-family: arial;
  font-size: 11px;
  font-weight: normal;
}


.legendGroupLabel {
  font-family: arial;
  font-size: 11px;
  font-weight: bold;
}
.legendGroup {
  background-color: #d4d4d4;
  border-top: 1px solid #ffffff;
  border-left: 1px solid #ffffff;
  border-bottom: 1px solid #666666;
  margin-bottom: 0px;
}

.legendHeader {
  background-color: #a9a9a9;
  border-top: 1px solid #ffffff;
  border-left: 1px solid #ffffff;
  border-bottom: 1px solid #666666;
  
  margin-bottom: 0px;
  padding-left: 2px;
  font-family: arial;
  font-size: 12px;
  font-weight: bold;
}

a.legendHref {
    font-family: arial;
    font-size: 10px;
    font-weight: bold;
    text-decoration: none;
    color: #ffffff;
}

a.legendHref:link {

}

a.legendHref:active {

}

a.legendHref:hover {
    color: #eeeeee;
}
</style>
<div class="legendHeader">
<table cellspacing="0" cellpadding="2" width="100%">
<tr>
  <td>Layers</td>
  <td align="right">
<a class="legendHref" href="javascript:void(0)" onclick="goExpanderManager.expandAll( ); return false;"><img src="images/expand.png" border="0" alt="expand all" title="expand all"></a>
<a class="legendHref" href="javascript:void(0)" onclick="goExpanderManager.collapseAll( ); return false;"><img src="images/collapse.png" border="0"  alt="collapse all" title="collapse all"></a>
  </td>
</tr>
</table>
</div>
EOT;
echo $szHeader.$szResult."</table></div>";
?>
