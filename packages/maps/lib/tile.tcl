#ad_maybe_redirect_for_registration

set path [acs_root_dir]/packages/maps/lib/
source ${path}/config.tcl


ad_page_contract {
    @author Neophytos Demetriou
} {
    {t:integer "0"}
    {l:integer "0"}
    {s:integer "15000000"}
}

#ns_log notice "t=$t l=$l s=$s"

set top ${t}
set left ${l}
set scale ${s}

set szTileId "s.${scale}.t.${top}.l.${left}"
set szCacheFile [file normalize "${szCacheDir}/${szTileId}.${szImageExtension}"]

set comment {
 * the tile renderer accepts several parameters and returns a tile image from
 * the cache, creating the tile only if necessary.
 *
 * all requests include the pixel location of the request at a certain scale
 * and this script figures out the geographic location of the tile from the
 * scale assuming that 0,0 in pixels is 0,0 in geographic units
 *
 * Request parameters are:
 *
 * map: the name of the map to use.  This is handled by config.php.
#'map='+currentMap+'&t='+t+'&l='+l+'&w='+tileWidth+'&h='+tileHeight+'&s='+nScale+szForce
 *
 * t: top pixel position
 * l: left pixel position
 * s: scale
 * g: (optional) comma-delimited list of group names to draw
 * layers: (optional) comma-delimited list of layers to draw
 * force: optional.  If set, force redraw of the meta tile.  This was added to
 *        help with invalid images sometimes being generated.
 * tileid: (optional) can be used instead of t+l to specify the tile coord.,
 *         useful in regenerating the cache
}


# * Calculate the metatile's top-left corner coordinates.
# * Include the $metaBuffer around the metatile to account for various
# * rendering issues happening around the edge of a map

set metaLeft [expr { int(floor( (${left})/(${tileWidth}*${metaWidth}) )) * ${tileWidth} * ${metaWidth} }]
set metaTop  [expr { int(floor( (${top})/(${tileHeight}*${metaHeight}) )) * ${tileHeight} *${metaHeight} }]
set szMetaTileId s.${scale}.t.${metaTop}.l.${metaLeft}
set metaLeft [expr { ${metaLeft} - ${metaBuffer} }]
set metaTop  [expr { ${metaTop} - ${metaBuffer} }]

set szMetaImg s.${scale}.t.${metaTop}.l.${metaLeft}.${szImageExtension}
ns_cache_eval -expires 30 -- xo_map_server_cache szMetaImg:${szMetaImg} {
    if { ![file exists ${szCacheFile}] || ${force_p} } {
	if { ![file exists ${szMetaDir}/${szMetaImg}] || ${force_p} } {
	    #catch { file delete -force -- ${szMetaDir}/${szMetaImg} }
	    set oMap [::mapscript::mapObj -args ${szMapFile}]
	    # Metatile width/height include 2x the metaBuffer value
	    ${oMap} setSize [expr { ${tileWidth} * ${metaWidth} + 2*${metaBuffer} }] [expr { ${tileHeight} * ${metaHeight} + 2*${metaBuffer} }]
	    # Tell MapServer to not render labels inside the metaBuffer area
	    # * (new in 4.6)
	    # * TODO: Until MapServer bugs 1353/1355 are resolved, we need to
	    # * pass a negative value for labelcache_map_edge_buffer
	    ${oMap} setMetaData labelcache_map_edge_buffer [expr { -${metaBuffer} }]

	    array set inchesPerUnit [list 0 1 1 12 2 63360.0 3 39.3701 4 39370.1 5 4374754]
	    set geoWidth  [expr { ${scale}/([${oMap} cget -resolution]*$inchesPerUnit([${oMap} cget -units])) }]
	    set geoHeight [expr { ${scale}/([${oMap} cget -resolution]*$inchesPerUnit([${oMap} cget -units])) }]

	    # draw the metatile
	    set minx [expr { ${metaLeft} * ${geoWidth} }]
	    set maxx [expr { ${minx} + ${geoWidth} * [${oMap} cget -width] }]
	    set maxy [expr { -1 * ${metaTop} * ${geoHeight} }]
	    set miny [expr { ${maxy} - ${geoHeight} * [${oMap} cget -height] }]
	    
	    set nLayers [${oMap} cget -numlayers]
	    ${oMap} setExtent ${minx} ${miny} ${maxx} ${maxy}
	    ${oMap} selectOutputFormat ${szMapImageFormat}

	    ########### groups or layers code HERE

	    set oImg [${oMap} draw]
	    #catch { file delete -force -- ${szMetaDir}/${szMetaImg} }
	    ${oImg} save ${szMetaDir}/${szMetaImg}
	    ::mapscript::msFreeImage ${oImg}
	    set oColor [$oMap cget -imagecolor]
	    ##$oMap -delete
	}
    }
}

ns_cache_eval -expires 30 -- xo_map_server_cache szCacheFile:${szCacheFile} {

    if { ![file exists ${szCacheFile}] || ${force_p} } {
	set oGDImg [gd::createFromPng ${szMetaDir}/${szMetaImg}]

	for { set j 0 } { ${j} < ${metaHeight} } { incr j } {
	    for { set i 0 } { ${i} < ${metaWidth} } { incr i } {
		set oTile [gd::create ${tileWidth} ${tileHeight}]

		# Allocate BG color for the tile (in case the metatile has transparent BG)
		#gd::colorAllocate ${oTile} [${oColor} cget -red] [${oColor} cget -green] [${oColor} cget -blue]
		gd::colorAllocate ${oTile} 156 178 205

		set tileTop  [expr { ${j}*${tileHeight} + ${metaBuffer} }]
		set tileLeft [expr { ${i}*${tileWidth} + ${metaBuffer} }]
		gd::copy ${oTile} ${oGDImg} 0 0 ${tileLeft} ${tileTop} ${tileWidth} ${tileHeight}

		set szTileImg s.${scale}.t.[expr { int(${metaTop}+${tileTop}) }].l.[expr { int(${metaLeft}+${tileLeft}) }].${szImageExtension}

		#catch { file delete -force -- ${szCacheDir}/${szTileImg} }
		gd::writePng ${oTile} ${szCacheDir}/${szTileImg}
		gd::destroy ${oTile}
	    }
	}

	gd::destroy ${oGDImg}

    }
}

#ad_returnfile_background 200 ${szImageHeader} ${szCacheFile}
ns_returnfile 200 ${szImageHeader} ${szCacheFile}