ns_cache_create xo_map_server_cache 200000

return

::xotcl::THREAD create GIS {

    package require Mapscript

    Class MapServer -parameter {
	{tileWidth 128}
	{tileHeight 128}
	{metaWidth 2}
	{metaHeight 2}
	{metaBuffer 0}
	{szCacheDir "/web/data/maps/tmp-cache/"}
	{szMetaDir "/web/data/maps/tmp-meta/"}
	{szImageExtension "png"}
	{szImageHeader "image/png"}
	{szMapName Cyprus}
	{szMapFile "/web/data/maps/cyprus.map"}
	{anScales "1500000 750000 300000 150000 75000 30000 15000"}
	{szMapImageFormat "PNG"}
    }

    MapServer instproc ensureMetaImage { scale } {
	my instvar szMetaDir
	set szMetaImg t.${metaTop}.l.${metaLeft}.${szImageExtension}
	ns_cache_eval -expires 0 -timeout 0 -- xo_map_cache szMetaImg:${szMetaImg} {
	    if { ![file exists ${szMetaDir}/${szMetaImg}] } {
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
		${oImg} save ${szMetaDir}/${szMetaImg}
		::mapscript::msFreeImage ${oImg}
		set oColor [$oMap cget -imagecolor]
		$oMap -delete
	    }
	}

    }

    MapServer instproc generateTileImage {top left scale} {
	my instvar szCacheDir szImageExtension tileWidth tileHeight metaWidth metaHeight metaBuffer

	set szTileId "t.${top}.l.${left}"
	set szCacheFile [file normalize "${szCacheDir}/${szTileId}.${szImageExtension}"]

	set metaLeft [expr { int(floor( (${left})/(${tileWidth}*${metaWidth}) )) * ${tileWidth} * ${metaWidth} }]
	set metaTop  [expr { int(floor( (${top})/(${tileHeight}*${metaHeight}) )) * ${tileHeight} *${metaHeight} }]
	set szMetaTileId t.${metaTop}.l.${metaLeft}
	set metaLeft [expr { ${metaLeft} - ${metaBuffer} }]
	set metaTop  [expr { ${metaTop} - ${metaBuffer} }]

	my ensureMetaImage

    } 

    



} -persistent 1

MS proc generateTile {top left scale} {
    my do generateTile $top $left $scale
}