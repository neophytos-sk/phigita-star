# tcl

variable _legend

proc LegendAdd {args} {
    set default {
	{"text"       ""          "text for the legend"}
	{"picture"    ""          "code to add the picture to the legend"}
    }
    ArgsProcessWithDashArgs LegendAdd default args use \
	"Internal command used to add some info about a legend to the legend list"

    variable _legend
    if {[info exists _legend(count)] == 0} {
	set _legend(count) 0
    }
    # puts stderr "legend adding $_legend(count):: $use(text) :: $use(picture)"
    set _legend($_legend(count),text)    $use(text)
    set _legend($_legend(count),picture) $use(picture)
    incr _legend(count)
}

proc replace {string indexStr newStr} {
    set start 0
    set result [string map "$indexStr $newStr" $string]
    # puts stderr "replacing '$indexStr' with '$newStr' in original '$string' --> $result"
    return $result
}

proc Legend {args} {
    set default {
	{"coord"       ""          "where to place the legend (lower left point)"}
	{"width"       "10"        "width of the picture to be drawn in the legend"}
	{"height"      "10"        "height of the picture to be drawn in the legend"}
	{"skip"        "3"         "number of points to skip when moving to next legend entry"}
	{"fontsize"    "10"        "size of font of legend"}
	{"fontcolor"   "black"     "color of font"}
	{"font"        "Helvetica" "which font face to use"}
    }
    ArgsProcessWithDashArgs Legend default args use \
	"Use this to draw a legend given the current entries in the legend"

    variable _legend
    
    set count [ArgsParseNumbers $use(coord) coord]
    AssertEqual $count 2
    set x $coord(0)
    set y $coord(1)
    set space 2.0
    
    for {set i 0} {$i < $_legend(count)} {incr i} {
	# PICTURE should have a COORDX COORDY WIDTH and HEIGHT in it, to be replaced here
	eval [string map "COORDX $x COORDY $y WIDTH $use(width) HEIGHT $use(height)" $_legend($i,picture)]

	# text too
	PsText -coord [expr $x+$use(width)+$space],$y -anchor l -text $_legend($i,text) \
	    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
	
	# update y positioning
	set y [expr $y + $use(height) + $use(skip)]
    }
}

