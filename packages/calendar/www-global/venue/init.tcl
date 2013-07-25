set path [acs_root_dir]/packages/maps/lib/
source ${path}/config.tcl

ad_page_contract {
    @author Neophytos Demetriou
} {
    vpw:naturalnum,optional
    vph:naturalnum,optional
}



set comment {
    /*
    * passed the following:
    *
    * vpw - viewport width
    * vph - viewport height
    *
    * need to calculate the following:
    *
    * nScale
    * tileWidth
    * tileHeight
    * nLayers
    * aScales
    * aszLayers - eventually
    * 
    * nCurrentTop
    * nCurrentLeft
    * xOffset
    * yOffset
    */
}


set oMap [::mapscript::mapObj -args ${szMapFile}]

if { [info exists vpw] } {
    set w [expr { ${vpw} + 2 * ${tileWidth} }]
} else {
    set w [${oMap} cget -width]
}

if { [info exists vph] } {
    set h [expr { ${vph} + 2 * ${tileHeight} }]
} else {
    set h [${oMap} cget -height]
}


${oMap} setSize ${w} ${h}

set rectPtr [${oMap} cget -extent]
set minX [${rectPtr} cget -minx]
set minY [${rectPtr} cget -miny]
set maxX [${rectPtr} cget -maxx]
set maxY [${rectPtr} cget -maxy]

ns_log notice "minX=$minX minY=$minY maxX=$maxX maxY=$maxY rectPtr=$rectPtr"
#set nScale [${oMap} cget -scale]
set nScale 300000

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

## now have to zoom to this scale
set cX  [expr { (${minX} + ${maxX}) / 2 }]
set cY  [expr { (${minY} + ${maxY}) / 2 }]

ns_log notice "units=[$oMap cget -units]"

array set inchesPerUnit [list 0 1 1 12 2 63360.0 3 39.3701 4 39370.1 5 4374754]
set cellSize [expr { ${nScale}/([${oMap} cget -resolution]* $inchesPerUnit([${oMap} cget -units])) }]

set minX [expr { ${cX} - (${w}/2)*${cellSize} }]
set minY [expr { ${cY} - (${h}/2)*${cellSize} }]
set maxX [expr { ${cX} + (${w}/2)*${cellSize} }]
set maxY [expr { ${cY} + (${h}/2)*${cellSize} }]
${oMap} setExtent ${minX} ${minY} ${maxX} ${maxY}

set pixelWidth  [expr { (${maxX} - ${minX})/([${oMap} cget -width])  }]
set pixelHeight [expr { (${maxY} - ${minY})/([${oMap} cget -height]) }]

set pixelLeft [expr { ${minX}/${pixelWidth}     }]
set pixelTop  [expr { -1*${maxY}/${pixelHeight} }]

##clamp to a tile
set nCurrentTop  [expr { (round(${pixelTop}/${tileHeight} +0.5) * ${tileHeight}) }]
set nCurrentLeft [expr { (round(${pixelLeft}/${tileWidth} +0.5) * ${tileWidth})  }]

set szLayers "map.addLayer( new _layer( '__base__', true, 100 ) );"


set szResult "/* leave this here */"
append szResult "aszScales=new Array([join ${anScales} ","]);"
append szResult "nScale=${nScale};"
append szResult "nCurrentLeft=${nCurrentLeft};"
append szResult "nCurrentTop=${nCurrentTop};"


set units [${oMap} cget -units]


append szResult "var map = new _map( '${szMap}', '${szMap}', 0, ${units}, aszScales);";
append szResult "map.setDefaultExtents(${minX}, ${minY}, ${maxX}, ${maxY});"
append szResult ${szLayers}
if { [info exists extents] } {
    append szResult "map.setCurrentExtents(${extents});";
}


append szResult "map.resolution = [${oMap} cget -resolution];"

append szResult "this.addMap( map );"
append szResult "this.tileWidth=${tileWidth};"
append szResult "this.tileHeight=${tileHeight};"
#append szResult "this.currentMap='${szMap}';"
append szResult "this.server = '${szURL}';"
append szResult "this.tileURL='tile';"
append szResult "this.selectMap('${szMap}');"
#append szResult "this.currentScale=$currentScale;"
#append szResult "alert(aszScales\[map.currentScale\]);"



set default_longitude 33.3667
set default_latitude 35.1667
set lon [::util::coalesce [ad_conn UL_LNG] $default_longitude]
set lat [::util::coalesce [ad_conn UL_LAT] $default_latitude]
set centerpoint "${lon},${lat},${nScale}"
#set centerpoint "32.40723252296448,34.75387052988518,${nScale}"

if { [info exists centerpoint] } {
    append szResult "if (this.ALLOW_DEFAULT_CENTER_POINT) { map.aZoomTo=new Array('${centerpoint}');this.zoomTo(${centerpoint});}"
}


append szResult "aMapFiles = new Array();";
append szGroups "aGroups = new Array();";

set comment {
foreach($aszMapFiles as $key => $aszMapFile)
{
    $szResult .= "aMapFiles['$key']='".$aszMapFile[0]."';";
    $oMap = ms_newMapObj( $aszMapFile[1] );
    $aGroups = $oMap->getAllGroupNames();
    $szGroups .= "aGroups['$key'] = new Array('".(implode("','", $aGroups))."');";
}
$szResult .= $szGroups;
}

#ns_log notice szResult=$szResult
doc_return 200 text/plain ${szResult}
