# tcl

proc Label {args} {
    set default {
	{"text"      ""       "title of the graph"}
	{"color"     "black"  "color of text"}
	{"coord"     ""       "x,y in points (native ps coordinates)"}
	{"rotate"    "0"      "angle to rotate text"}
	{"anchor"    "c"      "c, l, r: anchor text on center, left, or right"}
    }
    ArgsProcessWithDashArgs Label default args use \
	"Use this to place a text label on the screen"

    set count [ArgsParseNumbers $use(coord) coord]
    AssertEqual $count 2
    set x $coord(0)
    set y $coord(1)
    PsText -coord $x,$y -text $use(text) -rotate $use(rotate) -anchor $use(anchor) -color $use(color)
}


