# tcl

proc Line {args} {
    set default {
	{"drawable"       "root"        "the drawable; if 'canvas', just draw onto canvas directly"}
	{"coord"          ""            "x1,y1: ... :xn,yn"}
	{"linecolor"      "black"       "color of the line"}
	{"linewidth"      "1"           "width of the line"}
	{"closepath"      "false"       "whether to close the path or not"}
	{"linedash"       "0"           "define dashes for the line: how many points the dash is turned on for, then how many off, etc."}
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
    set count [ArgsParseNumbersList $use(coord) coord]
    AssertGreaterThan $count 0
    set ucoord "[Translate $d x $coord(0,n1)] [Translate $d y $coord(0,n2)]"
    for {set i 1} {$i < $count} {incr i} {
	set ucoord "$ucoord : [Translate $d x $coord($i,n1)] [Translate $d y $coord($i,n2)]"
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
	{"drawable"  "root"      "drawable, if appropriate; if 'canvas', just label the canvas"}
	{"text"      ""          "text to place on graph"}
	{"font"      "Helvetica" "font face label"}
	{"fontsize"  "10"        "font size of label"}
	{"color"     "black"     "color of text"}
	{"coord"     ""          "x,y (native ps coordinates by default)"}
	{"rotate"    "0"         "angle to rotate text"}
	{"anchor"    "c"         "c, l, r: anchor text on center, left, or right"}
	{"xshift"    "0"         "move label left or right (-x or +x)"}
	{"yshift"    "0"         "move label up or down (+x or -x)"}
    }
    ArgsProcessWithDashArgs LabelCanvas default args use \
	"Use this to place a text label on the canvas. Units are in raw canvas coordinates."

    set count [ArgsParseNumbers $use(coord) coord]
    AssertEqual $count 2
    set x $coord(0)
    set y $coord(1)

    set tx [expr [Translate $use(drawable) x $x] + $use(xshift)]
    set ty [expr [Translate $use(drawable) y $y] + $use(yshift)]
    PsText -coord $tx,$ty -text $use(text) -size $use(fontsize) -font $use(font) \
	-rotate $use(rotate) -anchor $use(anchor) -color $use(color)
}


