#! /usr/bin/tclsh

# generic program info
set _c(program)  "zdraw"
set _c(version)  "1.0.0"

# date
set _c(date)     [clock format [clock seconds]]

# about this document
set _c(width)    300
set _c(height)   240
set _c(title)    "default.eps"

# set legal fonts
set _c(fontlist) "Helvetica"
set _c(allfonts) "Helvetica Helvetica-Bold Helvetica-Italic TimesRoman TimesRoman-Bold TimesRoman-Italic Courier Courier-Bold Courier-Italic"

proc true {b} {
    switch -exact $b {
	"t"    { return 1 }
	"T"    { return 1 }
	"true" { return 1 }
	"True" { return 1 }
	"TRUE" { return 1 }
    }
    return 0
}

proc false {b} {
    switch -exact $b {
	"f"     { return 1 }
	"F"     { return 1 }
	"false" { return 1 }
	"False" { return 1 }
	"FALSE" { return 1 }
    }
    return 0
}


proc addfont {font} {
    global _c
    # make sure fonts are legal
    if {[lsearch -exact $_c(allfonts) $font] == -1} {
	Abort "bad font: $font"
    }

    # add to font list
    if {[lsearch -exact $_c(fontlist) $font] == -1} {
	set _c(fontlist) [list $_c(fontlist) $font]
    }
}

proc PsHeader {title width height} {
    global _c
    
    # xxx
    set _c(width)  $width
    set _c(height) $height

    # generic eps header
    puts "%!PS-Adobe-3.0"
    puts "%%Title: $title"
    puts "%%Creator: $_c(program) version $_c(version)"
    puts "%%CreationDate: $_c(date)"
    puts "%%DocumentFonts: (atend)"
    puts "%%BoundingBox: 0 0 $width $height"
    puts "%%Orientation: Portrait"
    puts "%%EndComments"

    # zdraw dictionary
    puts "% zdraw dictionary"
    puts "/zdict 256 dict def"
    puts "zdict begin"
    puts "/m {moveto} bind def"
    puts "/l {lineto} bind def"
    puts "/mr {rmoveto} bind def"
    puts "/lr {rlineto} bind def"
    puts "/lshow { show } def"
    puts "/rshow { dup stringwidth pop neg 0 mr show } def"
    puts "/cshow { dup stringwidth pop -2 div 0 mr show } def"
    puts "/lbshow { show } def"
    puts "/rbshow { dup stringwidth pop neg 0 mr show } def"
    puts "/cbshow { dup stringwidth pop -2 div 0 mr show } def"
    puts "/lmshow { dup stringwidth -2 div 0 exch mr pop show } def"
    puts "/rmshow { dup stringwidth -2 div 0 exch mr neg 0 mr show } def"
    puts "/cmshow { dup stringwidth -2 div 0 exch mr -2 div 0 mr show } def"
    puts "/ltshow { dup stringwidth neg 0 exch mr pop show } def"
    puts "/rtshow { dup stringwidth neg div 0 exch mr neg 0 mr show } def"
    puts "/ctshow { dup stringwidth neg div 0 exch mr -2 div 0 mr show } def"
    puts "end"
    puts "zdict begin"
}


proc color {c} {
    if {[string compare [string index $c 0] "%"] == 0} {
	# this is a raw color, of the form: %r,g,b
	# where r,g,b are each between 0 and 1 and can be decimal
	return [split [lindex [split $c %] 1] ","]
    }
    switch -regexp $c {
	"black"                   { return "0 0 0" }
	"white"                   { return "1 1 1" }
	"dgray|darkgray"          { return "0.25 0.25 0.25" }
	"gray"                    { return "0.5 0.5 0.5" }
	"lgray|lightgray"         { return "0.75 0.75 0.75" }
	"rlgray|reallylightgray"  { return "0.9 0.9 0.9" }
	"b|blue"                  { return "0 0 1" }
	"db|dblue|darkblue"       { return "0 0 0.5" }
	"r|red"                   { return "1 0 0" }
	"dred|darkred"            { return "0.5 0 0" }
	"g|green"                 { return "0 1 0" }
	"dgreen|darkgreen"        { return "0 0.5 0" }
	"orange"                  { return "1 0.5 0" }
	default  { Abort "color: bad color $c" }
    }
    
}

# 
# postscript commands
# 
proc setcolor {c} {
    puts "$c setrgbcolor"
}

proc setlinewidth {lw} {
    puts "$lw setlinewidth"
}

proc setlinecap {lc} {
    puts "$lc setlinecap"
}

proc setdash {d} {
    puts "\[$d\] 0 setdash"
}

proc moveto {x y} {
    puts "$x $y m"
}

proc lineto {x y} {
    puts "$x $y l"
}

proc newpath {} {
    puts "newpath"
}

proc closepath {} {
    puts "closepath"
}

proc fill {} {
    puts "fill"
}

proc stroke {} {
    puts "stroke"
}

proc gsave {} {
    puts "gsave"
}

proc grestore {} {
    puts "grestore"
}

proc arc {x y r ba ea} {
    puts "$x $y $r $ba $ea arc"
}

proc clip {} {
    puts "clip"
}

proc rotate {angle} {
    puts "$angle rotate"
}

proc setfont {face size} {
    puts "($face) findfont $size scalefont setfont"
}

proc show {text anchor} {
    puts "($text)"
    switch -exact $anchor {
	"c" { puts "cshow" }
	"l" { puts "lshow" }
	"r" { puts "rshow" }
	default { puts "bad anchor: $anchor"; exit 1 }
    }
}

proc rectangle {x1 y1 x2 y2} {
    moveto $x1 $y1
    lineto $x1 $y2
    lineto $x2 $y2
    lineto $x2 $y1 
}

# 
# high-level postscript commands
# 
proc PsCanvas {args} {
    set default {
	{"title"      "default.eps" "name of eps file"}
	{"width"      "300"         "width of drawing canvas"}
	{"height"     "240"         "height of drawing canvas"}
    }
    ArgsProcessWithDashArgs Canvas default args use ""

    # make the header
    PsHeader $use(title) $use(width) $use(height)
}

proc PsRender {} {
    global _c

    # generic eps trailer
    puts "% zdraw epilogue"
    puts "end"
    puts "showpage"
    puts "%%Trailer"
    puts "%%DocumentFonts: $_c(fontlist)"

}

proc PsLine {args} {
    set default {
	{"coord"     "0,0:0,0"     "x1,y1: ... :xn,yn"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
	{"linecap"   "0"           "linecap: 0, 1, or 2"}
	{"closepath" "false"       "whether to close the path or not"}
	{"dash"      "0"           "define dashes for the line"}
    }
    ArgsProcessWithDashArgs PsLine default args use ""

    # start the path
    gsave
    newpath

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    moveto $coords(0,n1) $coords(0,n2) 
    for {set p 1} {$p < $count} {incr p} {
	lineto $coords($p,n1) $coords($p,n2) 
    }
    if [true $use(closepath)] {
	closepath
    }
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)
    setlinecap $use(linecap)
    if {$use(dash) != 0} {
	setdash $use(dash)
    }
    stroke
    grestore
}

proc PsBox {args} {
    set default {
	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs box default args use ""

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    AssertEqual $count 2

    set x1 $coords(0,n1)
    set y1 $coords(0,n2)
    set x2 $coords(1,n1)
    set y2 $coords(1,n2)

    # do filled one first
    # we are doing this twice but probably don't have to...
    gsave
    if [true $use(fill)] {
	if {[string compare $use(fillstyle) solid] == 0} {
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; 
	    setcolor [color $use(fillcolor)]; fill
	} elseif {[string compare $use(fillstyle) hlines] == 0} {
	    set all   [split $use(fillparams) ","]
	    set width [lindex $all 0]
	    set skip  [lindex $all 1]
	    # set clipping space
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; clip
	    # now, draw the lines
	    setlinewidth $width
	    setcolor [color $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$width]} {
		newpath
		rectangle $x1 $cy $x2 [expr $cy+$width] 
		closepath; fill; stroke
	    }
	    
	} elseif {[string compare $use(fillstyle) vlines] == 0} {
	    set all   [split $use(fillparams) ","]
	    set width [lindex $all 0]
	    set skip  [lindex $all 1]
	    # set clipping space
	    newpath; rectangle $x1 $y1 $x2 $y2; closepath; clip
	    # now, draw the lines
	    setlinewidth $width
	    setcolor [color $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$width]} {
		newpath
		rectangle $cx $y1 [expr $cx+$width] $y2
		closepath; fill; stroke
	    }
	} else {
	    puts stderr "bad fill style: $use(fillstyle)"
	    exit 1
	}
    }
    grestore

    # start the path
    gsave
    newpath

    # now do the movetos and closepath
    rectangle $x1 $y1 $x2 $y2
    closepath

    # colors and 
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)

    # finish up
    stroke
    grestore
}

proc PsCircle {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"radius"    "1"           "radius of circle"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
    }
    ArgsProcessWithDashArgs circle default args use ""

    # start the path
    gsave
    newpath

    # pull out each element of the path
    set xy [split $use(coord) ","]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]

    # now do the movetos and closepath
    arc $x $y $use(radius) 0 360

    # colors and 
    setcolor [color $use(linecolor)]
    setlinewidth $use(linewidth)

    # finish up
    stroke
    grestore
}

proc PsText {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"color"     "black"       "color of text"}
	{"text"      "text"        "the text on the canvas"}
	{"font"      "Helvetica"   "which font: Helvetica, TimesRoman, Courier"}
	{"size"      "10"          "size of the type face"}
	{"rotate"    "0"           "angle of rotation"}
	{"anchor"    "c"           "l (left), c (center), r (right)"}
    }
    ArgsProcessWithDashArgs PsText default args use ""

    addfont $use(font)
    
    set s [split $use(coord) ","]
    set x [lindex $s 0]
    set y [lindex $s 1]

    gsave
    newpath
    setcolor [color $use(color)]
    setfont $use(font) $use(size)
    moveto $x $y
    if {$use(rotate) != 0} {
	rotate $use(rotate)
    }
    show $use(text) $use(anchor)
    stroke
    grestore
}

