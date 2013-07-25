set path [acs_root_dir]/packages/maps/lib/
source ${path}/config.tcl


ad_page_contract {
    @author Neophytos Demetriou
} {
    ll:trim,notnull,optional
    {s:integer,notnull,optional "300000"}
}

set nScale $s
if { ${nScale} > [lindex ${anScales} 0] } {
    set nScale [lindex ${anScales} 0]
}

## find closest valid scale (that is larger than this one)
foreach theScale [lreverse ${anScales}] {
    if { ${nScale} <= ${theScale} } {
        set nScale ${theScale}
        break;
    }
}


set __MAP_INIT_JS__ "myKaMap.ALLOW_DEFAULT_CENTER_POINT=true;"

if { [info exists ll] } {
    lassign [split $ll {,}] lon lat
    if { [string is double -strict $lon] && [string is double -strict $lat] } {
	# do something here
	set __MAP_INIT_JS__ "myKaMap.ALLOW_DEFAULT_CENTER_POINT=false;myKaMap.zoomTo(${lon},${lat},${nScale});"
    }
}



set html [subst -nocommands -nobackslashes {
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Maps</title>

<script type="text/javascript" src="http://maps.phigita.net/lib/data/kaMap-all.js"></script>
<script type="text/javascript">
var myKaMap = myKaNavigator = myKaZoomer = null;
function myOnLoad()
{
    initDHTMLAPI();
    myKaMap = new kaMap( 'viewport' );
//    var myKaScalebar = new kaScalebar( myKaMap, 'scalebar' );
//    var myKaLegend = new kaLegend( myKaMap, 'legend', false );
//    var myKaKeymap = new kaKeymap( myKaMap, 'keymap' );
    myKaMap.registerForEvent( KAMAP_INITIALIZED, null, myInitialized );
    myKaMap.registerForEvent( KAMAP_MAP_INITIALIZED, null, myMapInitialized );
//    myKaMap.registerForEvent( KAMAP_SCALE_CHANGED, null, myScaleChanged );
//    myKaMap.registerForEvent( KAMAP_QUERY, null, myQuery );
    
    myKaNavigator = new kaNavigator( myKaMap );
    myKaNavigator.activate();
    
//    myKaQuery = new kaQuery( myKaMap, KAMAP_RECT_QUERY );
    myKaZoomer = new kaZoomer(myKaMap);
    drawPage();
    myKaMap.initialize();
}

/**
 * event handler for KAMAP_INITIALIZED.
 *
 * at this point, we know what map files are available and we have
 * access to them.
 */
function myInitialized()
{
return
    //get list of maps and populate the maps select box
    var aMaps = myKaMap.getMaps();
    var oSelect = document.forms[0].maps;
    var j = 0;
    var opt = new Option( 'select a map', '', true, true );
    oSelect[j++] = opt;
    for(var i in aMaps)
    {
        oSelect[j++] = new Option(aMaps[i].title,aMaps[i].name,false,false);
    }

}

function myMapInitialized( eventID, mapName )
{
    //update the scales select
    var currentMap = myKaMap.getCurrentMap();


    //add marker

    var lon; // x-coordinate
    var lat; // y-coordinate
    myCanvas = myKaMap.createDrawingCanvas(500);
    var marker1 = document.createElement('img');
    marker1.src='/graphics/marker.png';
    var marker2 = document.createElement('img');
    marker2.src='/graphics/marker.png';
    var marker3 = document.createElement('img');
    marker3.src='/graphics/marker.png';

    var dx =-Math.floor(marker3.width/2);
    var dy =-marker3.height;
    lon=33.3666667;
    lat=35.1666667;
    //myKaMap.addMarkerGeo(myCanvas,lon,lat,marker1,dx,dy);
    lon=32.4166667; //32.4083333;
    lat=34.7666667; //34.7583333;
    //myKaMap.addObjectGeo(myCanvas,lon,lat,marker2);
    lon=32.40723252296448;
    lat=34.75387052988518;
    //(33.429859, 35.126413)
    //var marker3 = document.createElement('img');
    //marker3.src='/graphics/marker.png';
    //myKaMap.addObjectGeo(myCanvas,lon,lat,marker3);
    //lon=33.429859;
    //lat=35.126413;

    ${__MAP_INIT_JS__}

    //myKaMap.addMarkerGeo(myCanvas,lon,lat,marker3,dx,dy);

}


function drawPage()
{
    var browserWidth = getInsideWindowWidth();
    var browserHeight = getInsideWindowHeight();
    
    var viewport = getRawObject('viewport');
    
    viewport.style.width = browserWidth + "px";
    viewport.style.height = browserHeight + "px";
    myKaMap.resize();
}
</script>
<style type="text/css">
body {
  margin: 0px;
  padding: 0px;
  background-color: #d9d9d9;
  overflow: hidden;
}

#viewport {
  position: relative;
  width: 100%;
  height: 100%;
  background-color: #f0f0f0;
  overflow: hidden;
  cursor: move;
}

#toolbar {
  position: absolute;
  top: 0px;
  left: 0px;
  height: 27px;
  width: 100%;
  z-index:3;
  cursor: auto;
  font-family: arial;
  font-size: 14px;
  font-weight: bold;
  background-color: #d9d9d9;
}

#reference {
  position: absolute;
  width: 262px;
  top: 27px;
  right: 0px;
  z-index: 2;
  background-color: #d9d9d9;
  cursor: auto;
}

#legend {
  position: relative;
  width: 250px;
  height: 150px;
  border: 1px solid #000000;
  overflow: auto;
}

#keymap {
  position: relative;
  width: 250px;
  height: 150px;
  border: 1px solid #000000;
  overflow: hidden;
}

#scalebar {
  position: relative;
  width: 250px;
  height: 33px;
  border: 1px solid #000000;
}


.bevelInset {
  border-top: 1px solid #666666;
  border-left: 1px solid #666666;
  border-right: 1px solid #ffffff;
  border-bottom: 1px solid #ffffff;
}

.bevelOutset {
  border-top: 1px solid #ffffff;
  border-left: 1px solid #ffffff;
  border-right: 1px solid #666666;
  border-bottom: 1px solid #666666;
}


.label {
  font-family: arial;
  font-size: 11px;
  font-weight: normal;
}


.value {
  font-family: arial;
  font-size: 11px;
  font-weight: bold;
}

input {
  font-family: arial;
  font-size: 12px;
  font-weight: normal;
}

select {
  font-family: arial;
  font-size: 12px;
  font-weight: normal;
  width: 150px;
}

a { 
  text-decoration: none; 
  font-family: arial;
  font-size: 10px;
  color: #000033;
}

a:link {}
a:hover {}
a:active {}
a:visited {}

#map_permalink a {
font-size:10px;
position:absolute;
right:3px;
top:3px;
z-index:2;
border:1px solid #666666;
font-weight:bold;
padding:2px;
background:#cccccc;
opacity:0.5; filter: alpha(opacity=50); -moz-opacity: 0.5;
}

#map_permalink a:hover { 
opacity:1; filter: alpha(opacity=100); -moz-opacity: 1;
}

#copyright {
  font-size:10px;
  position: absolute;
  right: 3px;
  bottom: 3px;
  z-index: 2;

}

#kaLogo {
  position: absolute;
  right: 3px;
  bottom: 3px;
  z-index: 2;

}

.kaLegendTitle {
  border-top: 1px solid #ffffff;
  border-left: 1px solid #ffffff;
  border-bottom: 1px solid #666666;
  border-right: 1px solid #666666;
  padding: 2px;
  font-family: arial;
  font-size: 12px;
  font-weight: bold;

}

.kaLegendLayer {
  border-top: 1px solid #ffffff;
  border-left: 1px solid #ffffff;
  border-bottom: 1px solid #666666;
  border-right: 1px solid #666666;
  padding: 2px;
  font-family: arial;
  font-size: 12px;
}
</style>
</head>
<body onload="myOnLoad();" onresize="drawPage();">
<div id="viewport">

<div id="map_permalink"><a href="http://maps.phigita.net/" onclick="prompt('Paste link in email or IM',this.href);return false;" onmouseover="var c=myKaMap.getCenter();this.href='http://maps.phigita.net/?ll='+myKaMap.pixToGeo(c[0],c[1])+'&s='+myKaMap.getCurrentScale();"><span>Link to this page</span></a></div>

<div id="copyright">&copy;2008 <a target="_blank" href="http://www.phigita.net/">phigita.net</a> - Map data &copy;2008 <a target="_blank" href="http://www.openstreetmap.com/">OpenStreetMap</a></div>

</div>
</body>
</html>
}]

doc_return 200 text/html $html


set COMMENT {
/**
 * event handler for KAMAP_MAP_INITIALIZED
 *
 * the scales are put into a select ... this will be used for zooming
 */ 
function myMapInitialized( eventID, mapName )
{
    // initialized a new map: mapName
    //make sure the map is selected ... 
/*
    var oSelect = document.forms[0].maps;
    if (oSelect.options[oSelect.selectedIndex].value != mapName)
    {
        for(var i = 0; i < oSelect.options.length; i++ )
        {
            if (oSelect.options[i].value == mapName)
            {
                oSelect.options[i].selected = true;
                break;
            }
        }
    }
  */  
    //update the scales select
    var currentMap = myKaMap.getCurrentMap();
    var scales = currentMap.getScales();
    oSelect = document.forms[0].scales;
    while( oSelect.options[0] ) oSelect.options[0] = null;
    j=0;
    for(var i in scales)
    {
        oSelect.options[j++] = new Option("1:"+scales[i],scales[i],false,false);
    }


    //add marker

    var lon; // x-coordinate
    var lat; // y-coordinate
    myCanvas = myKaMap.createDrawingCanvas(500);
    var marker1 = document.createElement('img');
    marker1.src='/graphics/marker.png';
    var marker2 = document.createElement('img');
    marker2.src='/graphics/marker.png';
    var marker3 = document.createElement('img');
    marker3.src='/graphics/marker.png';

    var dx =-Math.floor(marker3.width/2);
    var dy =-marker3.height;
    lon=33.3666667;
    lat=35.1666667;
    //myKaMap.addMarkerGeo(myCanvas,lon,lat,marker1,dx,dy);
    lon=32.4166667; //32.4083333;
    lat=34.7666667; //34.7583333;
    //myKaMap.addObjectGeo(myCanvas,lon,lat,marker2);
    lon=32.40723252296448;
    lat=34.75387052988518;
    //(33.429859, 35.126413)
    //var marker3 = document.createElement('img');
    //marker3.src='/graphics/marker.png';
    //myKaMap.addObjectGeo(myCanvas,lon,lat,marker3);
    //lon=33.429859;
    //lat=35.126413;
    //myKaMap.zoomTo(lon,lat);
    //myKaMap.addMarkerGeo(myCanvas,lon,lat,marker3,dx,dy);

}


/**
 * called when the map selection changes due to the user selecting a new map.  
 * By calling myKaMap.selectMap, this triggers the KAMAP_MAP_INITIALIZED event 
 * after the new map is initialized which, in turn, causes testMapInitialized 
 * to be called
 */
function mySetMap( name )
{
    myKaMap.selectMap( name );
}

/**
 * called when kaMap tells us the scale has changed
 */
function myScaleChanged( eventID, scale )
{
    //todo: update scale select and enable/disable zoomin/zoomout
    var oSelect = document.forms[0].scales;
    for (var i=0; i<oSelect.options.length; i++)
    {
        if (oSelect.options[i].value == scale)
        {
            oSelect.options[i].selected = true;
            document.forms[0].zoomout.disabled = (i==0);
            document.forms[0].zoomin.disabled = (i==oSelect.options.length - 1);
        }
    }


}


/**
 * called when the user changes scales.  This will cause the map to zoom to
 * the new scale and trigger a bunch of events, including:
 * KAMAP_SCALE_CHANGED
 * KAMAP_EXTENTS_CHANGED
 */
function mySetScale( scale )
{
    myKaMap.zoomToScale( scale );

}

function myQuery( eventID, queryType, coords )
{

    var szLayers = '';
    var layers = myKaMap.getCurrentMap().getQueryableLayers();
    for (var i=0;i<layers.length;i++)
    {
        szLayers = szLayers + "," + layers[i].name;
    }
    alert( "QUERY: " + queryType + " " + coords + " on layers " + szLayers );
}

function myZoomIn()
{
    myKaMap.zoomIn();
}

function myZoomOut()
{
    myKaMap.zoomOut();
}

function toggleReference(obj)
{
    if (obj.innerHTML == 'hide reference')
    {
        obj.innerHTML = 'show reference';
        var d = getObject('reference');
        d.top = "-356px";
    }
    else
    {
        obj.innerHTML = 'hide reference';
        var d = getObject('reference');
        d.top = "0px";
    }
}

function dialogToggle( href, szObj )
{
    var obj = getObject(szObj);
    if (obj.display == 'none')
    {
        obj.display = 'block';
        href.childNodes[0].src = 'images/dialog_shut.png';
        
    }
    else
    {
        obj.display = 'none';
        href.childNodes[0].src = 'images/dialog_open.png';
    }
}




<script type="text/javascript" src="js/DHTMLapi.js"></script>
<script type="text/javascript" src="js/xhr.js"></script>
<!-- <script type="text/javascript" src="js/jsExpander.js"></script> -->
<script type="text/javascript" src="js/kaMap.js"></script>
<script type="text/javascript" src="js/kaKeymap.js"></script>
<!-- <script type="text/javascript" src="js/kaScalebar.js"></script> -->
<!-- <script type="text/javascript" src="js/kaLegend.js"></script> -->
<script type="text/javascript" src="js/kaTool.js"></script>
<script type="text/javascript" src="js/wz_dragdrop.js"></script> 
<script type="text/javascript" src="js/kaZoomer.js"></script> 
<!-- <script type="text/javascript" src="js/kaQuery.js"></script> -->
<!-- <script type="text/javascript" src="js/wmsLayer.js"></script> -->

<a href="http://maps.phigita.net/" onclick="prompt('Paste link in email or IM',this.href);return false;" onmouseover="var c=myKaMap.getCenter();this.href='http://maps.phigita.net/?ll='+myKaMap.pixToGeo(c[0],c[1]);"><span>Link to this page</span></a>
    <div id="toolbar" class="bevelOutset">
    <form style="display:inline;">
    <table border="0" cellspacing="0" cellpadding="2" width="100%">
    <tr>
    <td>&nbsp;</td>
    <td><input type="button" name="zoomin" value="Zoom In" onclick="myZoomIn()"><select name="scales" onchange="mySetScale(this.options[this.selectedIndex].value)"></select>&nbsp;<input type="button" name="zoomout" value="Zoom Out" onclick="myZoomOut()"></td>
    <td><a href="http://maps.phigita.net/" onclick="prompt('Paste link in email or IM',this.href);return false;" onmouseover="var c=myKaMap.getCenter();this.href='http://maps.phigita.net/?ll='+myKaMap.pixToGeo(c[0],c[1]);"><span>Link to this page</span></a></td>
    <td><img src="/graphics/spacer.png"></td>
    </tr>
    </table>
    </form>
    </div>
}