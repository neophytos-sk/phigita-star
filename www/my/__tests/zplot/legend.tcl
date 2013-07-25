# tcl

variable _legend

proc LegendAdd {args} {
    set default {
	{"text"       ""          "text for the legend"}
	{"entry"      ""          "entry number: which legend entry this should be"}
	{"picture"    ""          "code to add the picture to the legend: COORDX and COORDY should be used to specify the lower-left point of the picture key; WIDTH and HEIGHT should be used to specify the width and height of the picture. "}
    }
    ArgsProcessWithDashArgs LegendAdd default args use \
	"Internal command used to add some info about a legend to the legend list. If 'entry' is specified, this will add the text (if any) to the existing text in that spot, and also add the picture to the list of pictures to be drawn for this entry. If 'entry' is not specified, simply use the current counter and add this to the end of the list."

    variable _legend

    if {$use(entry) == ""} {
	if {[info exists _legend(count)] == 0} {
	    set _legend(count) 0
	}
	# puts stderr "legend adding $_legend(count):: $use(text) :: $use(picture)"
	set _legend($_legend(count),text)    $use(text)
	set _legend($_legend(count),picture) $use(picture)
	incr _legend(count)
    } else {
	# XXX
	# don't quite feel like doing this now ...
    }
}

proc replace {string indexStr newStr} {
    set start 0
    set result [string map "$indexStr $newStr" $string]
    # puts stderr "replacing '$indexStr' with '$newStr' in original '$string' --> $result"
    return $result
}

proc Legend {args} {
    set default {
	{"drawable"     "default"   "which drawable to place this on (canvas can be specified too)"}
	{"coord"        ""          "where to place the legend (lower left point)"}
	{"style"        "right"     "which side to place the text on, right or left?"}
	{"width"        "10"        "width of the picture to be drawn in the legend"}
	{"height"       "10"        "height of the picture to be drawn in the legend"}
	{"vskip"        "3"         "number of points to skip when moving to next legend entry"}
	{"hspace"       "4"         "space between pictures and text"}
	{"down"         "t"         "go downward from starting spot when building the legend; false goes upward"}
	{"skipnext"     ""          "if non-empty, how many rows of legend to print before skipping to a new column"}
	{"skipspace"    "25"        "how much to move over if the -skipnext option is used to start the next column"}
	{"font"         "Helvetica" "which font face to use"}
	{"fontsize"     "10"        "size of font of legend"}
	{"fontcolor"    "black"     "color of font"}
    }
    ArgsProcessWithDashArgs Legend default args use \
	"Use this to draw a legend given the current entries in the legend. Lots of options are available, including: XXX."

    variable _legend
    
    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2
    set x  [drawableTranslate $use(drawable) x $coord(0)]
    set y  [drawableTranslate $use(drawable) y $coord(1)]
    set w  $use(width)
    set h  $use(height)

    if {$w < $h} {
	set min $w
    } else {
	set min $h
    }

    set overcounter 0
    for {set i 0} {$i < $_legend(count)} {incr i} {
	switch -exact $use(style) {
	    left  { 
		set cx [expr $x+$use(hspace)+($w/2.0)] 
		set tx $x
	    }
	    right { 
		set cx [expr $x+($w/2.0)] 
		set tx [expr $x+$w+$use(hspace)]
	    }
	}

	# PsCircle -coord $tx,$y -linecolor blue -radius 1 ;# x for text
	# PsCircle -coord $cx,$y -linecolor red -radius 1  ;# x for pictures

	# make replacements for coordinates in legend pictures
	set mapped [string map "__Xx $cx __Yy $y __Ww $w __Hh $h __Mm $min __W2 [expr $w/2.0] __H2 [expr $h/2.0] __M2 [expr $min/2.0] __Xmm [expr $cx-($min/2.0)] __Xpm [expr $cx+($min/2.0)] __Ymm [expr $y-($min/2.0)] __Ypm [expr $y+($min/2.0)] __Xmw [expr $cx-($w/2.0)] __Xpw [expr $cx+($w/2.0)] __Ymh [expr $y-($h/2.0)] __Yph [expr $y+($h/2.0)]" $_legend($i,picture)]
	# puts "  BEFORE $_legend($i,picture)"
	# puts "  AFTER  $mapped"

	switch -exact $use(style) {
	    left {
		PsText -coord $tx,$y -anchor r,c -text $_legend($i,text) \
		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
		eval $mapped
	    }
	    right {
		eval $mapped
		PsText -coord $tx,$y -anchor l,c -text $_legend($i,text) \
		    -font $use(font) -color $use(fontcolor) -size $use(fontsize)
	    }
	    default {
		Abort "Bad style: $use(style): try right or left"
	    }
	}
	if [True $use(down)] {
	    set y [expr $y - $use(height) - $use(vskip)]
	} else {
	    set y [expr $y + $use(height) + $use(vskip)]
	}

	if {$use(skipnext) != ""} {
	    incr overcounter
	    if {$overcounter >= $use(skipnext)} {
		set x  [expr $x + $use(skipspace)]
		set y  [drawableTranslate $use(drawable) y $coord(1)]
		set overcounter 0
	    } 
	}
    }
}

