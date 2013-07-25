#! /usr/bin/tclsh

# namespace relevant
variable _c

proc psAddfont {font} {
    variable _c
    # make sure fonts are legal
    if {[lsearch -exact $_c(allfonts) $font] == -1} {
	Abort "bad font: $font"
    }

    # add to font list
    if {[lsearch -exact $_c(fontlist) $font] == -1} {
	set _c(fontlist) [list $_c(fontlist) $font]
    }
}

proc psColor {c} {
    if {[string compare [string index $c 0] "%"] == 0} {
	# this is a raw color, of the form: %r,g,b
	# where r,g,b are each between 0 and 1 and can be decimal
	return [split [lindex [split $c %] 1] ","]
    }
    variable _c
    return [ArgsSwitch $_c(colors) $c "Bad color choice"]
}

proc psLast {type value} {
    return 0 ;# XXX NOT IN USE, DOES NOT WORK RIGHT NOW
    variable _last
    if {[info exists _last($type)] == 0} {
	# doesn't exist, so init it and return 0
	set _last($type) $value 
	return 0
    }
    # exists: does it match?
    if {[StringEq $_last($type) $value]} {
	return 1
    } 
    set _last($type) $value
    return 0
}

# 
# postscript commands
# 
proc psSetcolor {c} {
    AssertEqual [llength $c] 3
    AssertIsNumber [lindex $c 0]
    AssertIsNumber [lindex $c 1]
    AssertIsNumber [lindex $c 2]
    
    puts "$c setrgbcolor"
}

proc psSetlinewidth {lw} {
    AssertIsNumber $lw
    puts "$lw setlinewidth"
}

proc psSetlinecap {lc} {
    AssertIsNumber $lc
    puts "$lc setlinecap"
}

proc psSetdash {d} {
    set len [llength $d]
    for {set i 0} {$i < $len} {incr i} {
	AssertIsNumber [lindex $d $i]
    }
    # should probably allow people to set the offset (currently 0)
    puts "\[$d\] 0 setdash"
}

proc psMoveto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    puts "$x $y m"
}

proc psLineto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    puts "$x $y l"
}

proc psNewpath {} {
    puts "newpath"
}

proc psClosepath {} {
    puts "closepath"
}

proc psFill {} {
    puts "fill"
}

proc psStroke {} {
    puts "stroke"
}

proc psGsave {} {
    puts "gsave"
    variable _c
    incr _c(gsaveCnt)
}

proc psGrestore {} {
    puts "grestore"
    variable _c
    incr _c(grestoreCnt)
}

proc psArc {x y r ba ea} {
    AssertIsNumber $x
    AssertIsNumber $y
    AssertIsNumber $r
    AssertIsNumber $ba
    AssertIsNumber $ea
    # xxx could be more sophisticated here
    puts "$x $y $r $ba $ea arc"
}

proc psClip {} {
    puts "clip"
}

proc psRotate {angle} {
    AssertIsNumber $angle
    puts "$angle rotate"
}

proc psSetfont {face size} {
    # could check fonts here, but already do elsewhere
    AssertIsNumber $size
    puts "($face) findfont $size scalefont setfont"
}

proc psShow {text anchor} {
    puts "($text)"
    switch -exact $anchor {
	"c" { puts "cshow" }
	"l" { puts "lshow" }
	"r" { puts "rshow" }
	default { puts "bad anchor: $anchor"; exit 1 }
    }
}

# could just use built in rectangle command in postscript
proc psRectangle {x1 y1 x2 y2} {
    AssertIsNumber $x1
    AssertIsNumber $x2
    AssertIsNumber $y1
    AssertIsNumber $y2
    psMoveto $x1 $y1
    psLineto $x1 $y2
    psLineto $x2 $y2
    psLineto $x2 $y1 
}

# 
# high-level postscript commands
# 
proc psCanvasDefined {} {
    variable _c
    return $_c(defined)
}

proc psCanvasWidth {} {
    variable _c
    return $_c(width)
}

proc psCanvasHeight {} {
    variable _c
    return $_c(height)
}

#
# EXPORTED FUNCTIONS
#
proc PsInit {program version} {
    variable _c

    # generic program info
    set _c(program)  $program
    set _c(version)  $version

    # date
    set _c(date)     [clock format [clock seconds]]

    # about this document
    set _c(defined)  0

    # set legal fonts
    set _c(fontlist) "Helvetica"
    set _c(allfonts) "Helvetica Helvetica-Bold Helvetica-Italic TimesRoman TimesRoman-Bold TimesRoman-Italic Courier Courier-Bold Courier-Italic"

    set _c(gsaveCnt)    0
    set _c(grestoreCnt) 0

    set _c(colors) {
	{ {black}                   {0.00 0.00 0.00} }
	{ {white}                   {1.00 1.00 1.00} }
	{ {verydarkgray vdgray vdg} {0.10 0.10 0.10} }
	{ {darkgray dgray dg}       {0.25 0.25 0.25} }
	{ {gray}                    {0.50 0.50 0.50} }
	{ {lightgray lgray }        {0.75 0.75 0.75} }
	{ {verylightgray vlgray}    {0.90 0.90 0.90} }
	{ {blue}                    {0.00 0.00 1.00} }
	{ {darkblue dblue}          {0.00 0.00 0.50} }
	{ {red}                     {1.00 0.00 0.00} }
	{ {darkred dred}            {0.50 0.00 0.00} }
	{ {green}                   {0.00 1.00 0.00} }
	{ {darkgreen dgreen}        {0.00 0.50 0.00} }
	{ {yellow}                  {1.00 1.00 0.00} }
	{ {lightyellow lyellow}     {1.00 1.00 0.39} }
	{ {orange}                  {1.00 0.50 0.00} }
	{ {lightorange lorange}     {1.00 0.80 0.2} }
    }
}

proc PsCanvas {args} {
    set default {
	{"program"    "zplot"       "name of program that created this postscript"}
	{"version"    "1.0.0"       "version number of program"}
	{"title"      "default.eps" "name of eps file"}
	{"width"      "300"         "width of drawing canvas"}
	{"height"     "240"         "height of drawing canvas"}
	{"units"      "points"      "points (1/72 of an inch) or inches"}
    }
    ArgsProcessWithDashArgs PsCanvas default args use ""

    # init variables
    PsInit $use(program) $use(version)

    # which units?
    switch -exact $use(units) {
	"points" { 
	    set w $use(width)
	    set h $use(height)
	} 
	"inches" {
	    set w [expr $use(width) * 72.0]
	    set h [expr $use(height) * 72.0]
	}
	default {
	    Abort "PsCanvas: units must be 'points' or 'inches'"
	}
    }

    variable _c
    set _c(defined) 1
    set _c(width)   $w
    set _c(height)  $h
    set _c(title)   $use(title)
    Dputs "Canvas: title:$use(title) dimensions:$_c(width)x$_c(height)"

    # generic eps header
    puts "%!PS-Adobe-3.0"
    puts "%%Title: $use(title)"
    puts "%%Creator: $_c(program) version $_c(version)"
    puts "%%CreationDate: $_c(date)"
    puts "%%DocumentFonts: (atend)"
    puts "%%BoundingBox: 0 0 $w $h"
    puts "%%Orientation: Portrait"
    puts "%%EndComments"

    # zdraw dictionary
    puts "% zdraw dictionary"
    puts "/zdict 256 dict def"
    puts "zdict begin"
    puts "/cpx 0 def"
    puts "/cpy 0 def"
    puts "/recordcp {currentpoint /cpy exch def /cpx exch def} bind def"
    puts "/m {moveto} bind def"
    puts "/l {lineto} bind def"
    puts "/mr {rmoveto} bind def"
    puts "/lr {rlineto} bind def"
    puts "/lshow {show recordcp} def"
    puts "/rshow {dup stringwidth pop neg 0 mr show recordcp} def"
    puts "/cshow {dup stringwidth pop -2 div 0 mr show recordcp} def"
    puts "end"
    puts "zdict begin"
}

proc PsRender {} {
    variable _c

    # do some checks
    AssertEqual $_c(gsaveCnt) $_c(grestoreCnt)

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
    psGsave
    psNewpath

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    psMoveto $coords(0,n1) $coords(0,n2) 
    for {set p 1} {$p < $count} {incr p} {
	psLineto $coords($p,n1) $coords($p,n2) 
    }
    if [True $use(closepath)] {
	psClosepath
    }
    psSetcolor [psColor $use(linecolor)]
    psSetlinewidth $use(linewidth)
    psSetlinecap $use(linecap)
    if {$use(dash) != 0} {
	psSetdash $use(dash)
    }
    psStroke
    psGrestore
}

proc psClipbox {x1 y1 x2 y2} {
    psNewpath
    psRectangle $x1 $y1 $x2 $y2
    psClosepath
    psClip
}

proc psMakeBoxBigger {x1__ y1__ x2__ y2__ delta} {
    upvar $x1__ x1
    upvar $x2__ x2
    upvar $y1__ y1
    upvar $y2__ y2

    AssertGreaterThanOrEqual $x2 $x1
    AssertGreaterThanOrEqual $y2 $y1

    set x1 [expr $x1 - $delta]
    set y1 [expr $y1 - $delta]
    set x2 [expr $x2 + $delta]
    set y2 [expr $y2 + $delta]
}

proc psMakePattern {args} {
    set default {
	{"coord"      "0,0:0,0"     "x1,y1:x2,y2"}
	{"fillcolor"  "black"       "fill color"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" "2,2"         "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs psMakePattern default args use \
	"Use this to fill a region with one of many specified patterns."

    # bound box
    set count [ArgsParseNumbersList $use(coord) xy]
    AssertEqual $count 2
    set x1 $xy(0,n1)
    set y1 $xy(0,n2)
    set x2 $xy(1,n1)
    set y2 $xy(1,n2)

    switch -exact $use(fillstyle) {
	"solid" {
	    psNewpath
	    psRectangle $x1 $y1 $x2 $y2
	    psClosepath
	    psSetcolor [psColor $use(fillcolor)]
	    psFill
	}
	"hlines" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set width $params(0)
	    set skip  $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0
	    psSetlinewidth $width
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$width]} {
		psNewpath
		psRectangle $x1 $cy $x2 [expr $cy+$width] 
		psClosepath
		psFill
		psStroke
	    }
	}
	"vlines" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set width $params(0)
	    set skip  $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0
	    psSetlinewidth $width
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$width]} {
		psNewpath
		psMoveto $cx $y1
		psLineto $cx $y2
		psStroke
	    } 
	}
	"diaglines" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set width $params(0)
	    set skip  $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetlinewidth $width
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$width]} {
		psNewpath
		psMoveto $x1 $cy
		psLineto $x2 [expr ($x2-$x1)+$cy]
		psStroke
	    } 
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$width]} {
		psNewpath
		psMoveto $cx $y1
		psLineto [expr $cx+($y2-$y1)] $y2
		psStroke
	    } 
	}
	"diaglines2" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set width $params(0)
	    set skip  $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetlinewidth $width
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$width]} {
		psNewpath
		psMoveto $x2 $cy
		psLineto $x1 [expr ($x2-$x1)+$cy]
		psStroke
	    } 
	    for {set cx $x2} {$cx >= $x1} {set cx [expr $cx-($skip+$width)]} {
		psNewpath
		psMoveto $cx $y1
		psLineto [expr $cx-($y2-$y1)] $y2
		psStroke
	    } 
	}
	"circles" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set radius $params(0)
	    set skip   $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $radius + $skip]} {
		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $radius + $skip]} {
		    psNewpath
		    psArc $cx $cy $radius 0 360
		    psFill
		    psStroke
		}
	    }
	}
	"squares" {
	    set count [ArgsParseNumbers $use(fillparams) params]
	    set size $params(0)
	    set skip $params(1)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
		    psNewpath
		    psRectangle $cx $cy [expr $cx+$size] [expr $cy+$size]
		    psFill
		    psStroke
		}
	    }
	}
	default {
	    puts stderr "bad fill style: $use(fillstyle)"
	    Abort "should be one of 'solid', 'vlines', 'hlines', 'diaglines', 'diaglines2', 'circles', 'squares'"
	}
    }
}

proc PsPolygon {args} {
    set default {
	{"coord"      ""            "x1,y1:...:xn,yn"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs PsPolygon default args use ""

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    # XXX

    # if the background should be filled, do that here
    # XXX

    # do filled one first
    if [True $use(fill)] {
	psGsave
	# XXX: need to draw proper path to then clip it
	# XXX clip
	# XXX: find minimal x,y pair and max x.y pair to determine patternbox
	psMakePattern -coord "$x1 $y1 : $x2 $y2" -fillcolor $use(fillcolor) \
	    -fillstyle $use(fillstyle) -fillparams $use(fillparams)
	psGrestore
    }

    
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
	{"background" ""            "background color for this box"}
    }
    ArgsProcessWithDashArgs PsBox default args use ""

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    AssertEqual $count 2

    set x1 $coords(0,n1)
    set y1 $coords(0,n2)
    set x2 $coords(1,n1)
    set y2 $coords(1,n2)

    # the code assumes y2 is bigger than y1, so switch them if need be
    if {$y1 > $y2} {
	set tmp $y2
	set y2 $y1
	set y1 $tmp
    }

    # if the background should be filled, do that here
    if {$use(background) != ""} {
	psGsave
	psMakePattern -coord "$x1 $y1 : $x2 $y2" -fillcolor $use(background) -fillstyle solid 
	psGrestore
    }

    # do filled one first
    if [True $use(fill)] {
	psGsave
	psClipbox $x1 $y1 $x2 $y2
	psMakePattern -coord "$x1 $y1 : $x2 $y2" -fillcolor $use(fillcolor) \
	    -fillstyle $use(fillstyle) -fillparams $use(fillparams)
	psGrestore
    }

    # draw outline box
    if {$use(linewidth) > 0} {
	psGsave
	psNewpath
	psRectangle $x1 $y1 $x2 $y2
	psClosepath
	psSetcolor [psColor $use(linecolor)]
	psSetlinewidth $use(linewidth)
	psStroke
	psGrestore
    }
}

proc PsCircle {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"radius"    "1"           "radius of circle"}
	{"linecolor" "black"       "color of the line"}
	{"linewidth" "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs PsCircle default args use ""

    # pull out each element of the path
    set xy [split $use(coord) ","]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]
    set r  $use(radius)

    # if the background should be filled, do that here
    # XXX

    # do fill first
    if [True $use(fill)] {
	psGsave
	psNewpath
	psArc $x $y $use(radius) 0 360
	psClosepath
	psClip
	psMakePattern -coord "[expr $x-$r] [expr $y-$r] : [expr $x+$r] [expr $y+$r]" \
	    -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillparams $use(fillparams)
	psGrestore
    }

    # make the circle outline now
    psGsave
    psNewpath
    psArc $x $y $use(radius) 0 360
    psSetcolor [psColor $use(linecolor)]
    psSetlinewidth $use(linewidth)
    psStroke
    psGrestore
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

    psAddfont $use(font)
    
    set s [split $use(coord) ","]
    set x [lindex $s 0]
    set y [lindex $s 1]

    psGsave
    psNewpath
    psSetcolor [psColor $use(color)]
    psSetfont $use(font) $use(size)
    psMoveto $x $y
    if {$use(rotate) != 0} {
	psGsave
	psRotate $use(rotate)
    }
    psShow $use(text) $use(anchor)
    if {$use(rotate) != 0} {
	psGrestore
    }
    psStroke
    psGrestore
}

# probably shouldn't use this a lot
proc PsRaw {args} {
    set default {
	{"raw"     ""      "raw postscript string to add into the output; DO NOT USE UNLESS A SUPER PRO"}
    }
    ArgsProcessWithDashArgs PsRaw default args use
    if {$use(raw) != ""} {
	puts $use(raw)
    }
}



