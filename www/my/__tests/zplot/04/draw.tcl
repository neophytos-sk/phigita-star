# tcl

proc Line {args} {
    set default {
	{"drawable"  "root"        "the drawable; if 'canvas', just draw onto canvas directly"}
	{"coord"     ""            "x1,y1: ... :xn,yn"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
	{"linecap"   "0"           "linecap: 0, 1, or 2"}
	{"closepath" "false"       "whether to close the path or not"}
	{"dash"      "0"           "define dashes for the line"}
    }
    ArgsProcessWithDashArgs Line default args use ""
    set d $use(drawable)

    AssertNotEqual $use(coord) ""
    set count [ArgsParseNumbersList $use(coord) coord]
    AssertGreaterThan $count 0
    set ucoord "[Translate $d x $coord(0,n1)] [Translate $d y $coord(0,n2)]"
    for {set i 1} {$i < $count} {incr i} {
	set ucoord "$ucoord : [Translate $d x $coord($i,n1)] [Translate $d y $coord($i,n2)]"
    }

    PsLine -coord $ucoord -linecolor $use(linecolor) -linewidth $use(linewidth) -linecap $use(linecap) -closepath $use(closepath) -dash $use(dash)
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


