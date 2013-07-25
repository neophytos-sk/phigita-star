# tcl

proc Circle {args} {
    set default {
	{"drawable"   "default"     "the drawable; if 'canvas', just draw onto canvas directly (no translation)"}
	{"coord"      "0,0"         "x1,y1"}
	{"radius"     "1"           "radius of circle"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"   "3"           "object size in pattern"}
	{"fillskip"   "4"           "space between objects in pattern"}
	{"bgcolor"     ""           "if not empty, make the polyground have this color background"}
    }

    ArgsProcessWithDashArgs Circle default args use \
	"Use this routine to draw a circle. Can be used to fill in a background or other accoutrement."

    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2
    set x1 [Translate $use(drawable) x $coord(0)]
    set y1 [Translate $use(drawable) y $coord(1)]

    PsCircle -coord $x1,$y1 \
	-radius $use(radius) -linecolor $use(linecolor) -linewidth $use(linewidth) \
	-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
	-fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
}


proc Box {args} {
    set default {
	{"drawable"   "default"     "the drawable; if 'canvas', just draw onto canvas directly (no translation)"}
	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"linedash"   "0"           "dash pattern for line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"   "3"           "object size in pattern"}
	{"fillskip"   "4"           "space between objects in pattern"}
	{"bgcolor"    ""            "if not empty, background color for this box"}
    }
    ArgsProcessWithDashArgs Box default args use \
	"Use this routine to draw a box. Can be used to fill in a background or other accoutrement."

    set count [ArgsParseItemPairList $use(coord) coord]
    AssertEqual $count 2
    set tx1 [Translate $use(drawable) x $coord(0,n1)]
    set ty1 [Translate $use(drawable) y $coord(0,n2)]
    set tx2 [Translate $use(drawable) x $coord(1,n1)]
    set ty2 [Translate $use(drawable) y $coord(1,n2)]

    PsBox -coord "$tx1,$ty1 : $tx2,$ty2" \
	-linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
	-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
	-fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
}

proc Line {args} {
    set default {
	{"drawable"       "default"     "the drawable; if 'canvas', just draw onto canvas directly"}
	{"coord"          ""            "x1,y1: ... :xn,yn"}
	{"linecolor"      "black"       "color of the line"}
	{"linewidth"      "1"           "width of the line"}
	{"linedash"       "0"           "define dashes for the line: how many points the dash is turned on for, then how many off, etc."}
	{"closepath"      "false"       "whether to close the path or not"}
	{"arrow"          "false"       "add an arrowhead at end"}
	{"arrowheadlength" "4"          "length of the arrowhead"}
	{"arrowheadwidth"  "3"          "width of the arrowhead"}
	{"arrowlinecolor" "black"       "linecolor of the arrowhead"}
	{"arrowlinewidth" "0.5"         "linewidth of the arrowhead"}
	{"arrowfill"      "true"        "fill the arrowhead"}
	{"arrowfillcolor" "black"       "the color to fill the arrowhead with"}
	{"arrowstyle"     "normal"      "types of arrowheads: normal is only one right now"}
    }
    ArgsProcessWithDashArgs Line default args use \
	"Use this to draw a line on a drawable. The most basic thing to specify is a list of points the line must be drawn through: x1,y1:x2,y2:...:xn,yn. 'closepath' is a postscript feature that should only be used when drawing a closed path and you wish for the line corners to match up; see a postscript manual for details. Lots of other options are available, including the color and width of the line, whether the line should be dashed, and whether to add an arrow at the end of the line (and its associated options). "
    set d $use(drawable)

    # translate each and every coord, then reassemble and pass to PsLine to do the real work
    AssertNotEqual $use(coord) ""
    set count [ArgsParseItemPairList $use(coord) coord]
    AssertGreaterThan $count 0
    set ucoord "[Translate $d x $coord(0,n1)],[Translate $d y $coord(0,n2)]"
    for {set i 1} {$i < $count} {incr i} {
	set ucoord "$ucoord : [Translate $d x $coord($i,n1)],[Translate $d y $coord($i,n2)]"
    }

    # call the beast of a function: PsLine
    PsLine -coord $ucoord -linecolor $use(linecolor) -linewidth $use(linewidth) \
	-closepath $use(closepath) -linedash $use(linedash) \
	-arrow $use(arrow) -arrowheadlength $use(arrowheadlength) -arrowheadwidth $use(arrowheadwidth) \
	-arrowlinecolor $use(arrowlinecolor) -arrowlinewidth $use(arrowlinewidth) \
	-arrowfill $use(arrowfill) -arrowfillcolor $use(arrowfillcolor) \
	-arrowstyle $use(arrowstyle)
}

proc Label {args} {
    set default {
	{"drawable"  "default"   "drawable, if appropriate; if 'canvas', just label the canvas"}
	{"text"      ""          "text to place on graph"}
	{"font"      "Helvetica" "font face label"}
	{"fontsize"  "10"        "font size of label"}
	{"color"     "black"     "color of text"}
	{"coord"     ""          "x,y (native ps coordinates by default)"}
	{"rotate"    "0"         "angle to rotate text"}
	{"anchor"    "c"         "c, l, r: anchor text on center, left, or right"}
	{"shift"     "0,0"       "x,y: move label left or right (-x or +x), up or down (+y or -y)"}
	{"bgcolor"    ""          "if not empty, put background behind the text of this color"}
    }
    ArgsProcessWithDashArgs Label default args use \
	"Use this to place a text label on the canvas. Units are in raw canvas coordinates."

    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2

    set scount [ArgsParseCommaList $use(shift) shift]
    AssertEqual $scount 2

    set tx [expr [Translate $use(drawable) x $coord(0)] + $shift(0)]
    set ty [expr [Translate $use(drawable) y $coord(1)] + $shift(1)]
    PsText -coord $tx,$ty -text $use(text) -size $use(fontsize) -font $use(font) \
	-rotate $use(rotate) -anchor $use(anchor) -color $use(color) -bgcolor $use(bgcolor)
}

proc reverse {s} {
    set s   [split $s ":"]
    set len [llength $s]
    set r   ""
    for {set i [expr $len-1]} {$i >= 0} {incr i -1} {
	set e [lindex $s $i]
	if {$r == ""} {
	    set r $e
	} else {
	    set r "$r : $e"
	}
    }
    return $r
}

proc GraphBreak {args} {
    set default {
	{"drawable"  "default"   "drawable, if appropriate; if 'canvas', just label the canvas"}
	{"coord"     ""          "starting x,y of graphbreak"}
	{"width"     "4"         "width of a single break element"}
	{"height"    "4"         "height of a single break element"}
	{"gap"       "4"         "gap between each line in break"}
	{"elements"  "4"         "number of breaks to draw"}
	{"linewidth" "1"         "width of the line"}
	{"linecolor" "black"     "line color"}
	{"bgcolor"   "white"     "if non-empty, fill in the break w/ this color"}
    }
    ArgsProcessWithDashArgs GraphBreak default args use \
	"Use this to draw a break symbol on a graph. Particularly useful for separating two drawables of the same graph that have a break in the y-axis. Limits: Only for y-axis right now."

    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2
    set ty [Translate $use(drawable) y $coord(1)]

    set halfwidth [expr ($use(elements)/2.0) * $use(width)]

    # make points of top line
    set j 0
    foreach ty "$ty [expr $ty-$use(gap)]" {
	set tx [expr [Translate $use(drawable) x $coord(0)] - $halfwidth]
	set clist($j) ""
	for {set i 0} {$i <= $use(elements)} {incr i} {
	    set x $tx
	    if {[expr $i % 2] == 1} {
		set y [expr $ty + $use(height)]
	    } else {
		set y [expr $ty]
	    }
	    if {$clist($j) != ""} {
		set clist($j) "$clist($j) : $x,$y"
	    } else {
		set clist($j) "$x,$y"
	    }
	    set tx [expr $tx + $use(width)]
	}
	incr j
    }

    if {$use(bgcolor) != ""} {
	PsPolygon -coord "$clist(0) : [reverse $clist(1)]" -linewidth 0 -bgcolor $use(bgcolor) 
    }
    PsLine -coord $clist(0) -linewidth $use(linewidth) -linecolor $use(linecolor)
    PsLine -coord $clist(1) -linewidth $use(linewidth) -linecolor $use(linecolor)
}
