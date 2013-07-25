# tcl

variable _legend

proc LegendAdd {args} {
    set default {
	{"text"       ""          "text for the legend"}
	{"picture"    ""          "code to add the picture to the legend: COORDX and COORDY should be used to specify the lower-left point of the picture key; WIDTH and HEIGHT should be used to specify the width and height of the picture. "}
    }
    ArgsProcessWithDashArgs LegendAdd default args use \
	"Internal command used to add some info about a legend to the legend list. "

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
	{"coord"        ""          "where to place the legend (lower left point)"}
	{"drawable"     "root"      "which drawable to place this on (canvas can be specified too)"}
	{"style"        "right"     "which side to place the text on, right or left?"}
	{"width"        "10"        "width of the picture to be drawn in the legend"}
	{"height"       "10"        "height of the picture to be drawn in the legend"}
	{"vskip"        "3"         "number of points to skip when moving to next legend entry"}
	{"hspace"       "4"         "space between pictures and text"}
	{"down"         "t"         "go downward from starting spot when building the legend; false goes upward"}
	{"font"         "Helvetica" "which font face to use"}
	{"fontsize"     "10"        "size of font of legend"}
	{"fontcolor"    "black"     "color of font"}
    }
    ArgsProcessWithDashArgs Legend default args use \
	"Use this to draw a legend given the current entries in the legend. Lots of options are available, including: XXX."

    variable _legend
    
    set count [ArgsParseNumbers $use(coord) coord]
    AssertEqual $count 2
    set x  [Translate $use(drawable) x $coord(0)]
    set y  [Translate $use(drawable) y $coord(1)]
    set w  $use(width)
    set h  $use(height)

    for {set i 0} {$i < $_legend(count)} {incr i} {
	switch -exact $use(style) {
	    left {
		PsText -coord $x,$y -anchor r,c -text $_legend($i,text) \
		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
		eval [string map "COORDX [expr $x+$use(hspace)] COORDY $y WIDTH $w HEIGHT $use(height)" $_legend($i,picture)]
	    }
	    right {
		eval [string map "COORDX $x COORDY $y WIDTH $w HEIGHT $use(height)" $_legend($i,picture)]
		PsText -coord [expr $x+$use(width)+$use(hspace)],$y -anchor l,c -text $_legend($i,text) \
		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
	    }
	    default {
		Abort "Bad style: $use(style): try right or left"
	    }
	}
	if [True $use(down)] {
	    set y [expr $y + $use(height) + $use(vskip)]
	} else {
	    set y [expr $y - $use(height) - $use(vskip)]
	}
    }
}

