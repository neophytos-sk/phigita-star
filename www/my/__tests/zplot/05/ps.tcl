#! /usr/bin/tclsh

# namespace relevant
variable _ps

proc psAddfont {font} {
    variable _ps
    # make sure fonts are legal
    if {[lsearch -exact $_ps(allfonts) $font] == -1} {
	Abort "bad font: $font"
    }

    # add to font list
    if {[lsearch -exact $_ps(fontlist) $font] == -1} {
	set _ps(fontlist) [list $_ps(fontlist) $font]
    }
}

proc psColor {c} {
    if {[string compare [string index $c 0] "%"] == 0} {
	# this is a raw color, of the form: %r,g,b
	# where r,g,b are each between 0 and 1 and can be decimal
	return [split [lindex [split $c %] 1] ","]
    }
    variable _ps
    return [ArgsSwitch $_ps(colors) $c "Bad color choice"]
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
proc psComment {str} {
    psPuts "% $str"
}

proc psSetcolor {c} {
    AssertEqual [llength $c] 3
    AssertIsNumber [lindex $c 0]
    AssertIsNumber [lindex $c 1]
    AssertIsNumber [lindex $c 2]
    
    psPuts "$c setrgbcolor"
}

proc psSetlinewidth {lw} {
    AssertIsNumber $lw
    psPuts "$lw setlinewidth"
}

proc psSetlinecap {lc} {
    AssertIsNumber $lc
    psPuts "$lc setlinecap"
}

# expects a list that describes the dash pattern
proc psSetdash {d} {
    set n [ArgsParseNumbers $d dashes]
    AssertIsNumber $dashes(0)
    set dashList $dashes(0)
    for {set i 1} {$i < $n} {incr i} {
	AssertIsNumber $dashes($i)
	set dashList "$dashList $dashes($i)"
    }
    # should probably allow people to set the offset (currently 0)
    psPuts "\[$dashList\] 0 setdash"
}

proc psMoveto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "$x $y m"
}

proc psRmoveto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "$x $y mr"
}

proc psLineto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "$x $y l"
}

proc psRlineto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "$x $y lr"
}

proc psNewpath {} {
    psPuts "newpath"
}

proc psClosepath {} {
    psPuts "closepath"
}

proc psFill {} {
    psPuts "fill"
}

proc psStroke {} {
    psPuts "stroke"
}

proc psGsave {} {
    psPuts "gsave"
    variable _ps
    incr _ps(gsaveCnt)
}

proc psGrestore {} {
    psPuts "grestore"
    variable _ps
    incr _ps(grestoreCnt)
}

proc psArc {x y r ba ea} {
    AssertIsNumber $x
    AssertIsNumber $y
    AssertIsNumber $r
    AssertIsNumber $ba
    AssertIsNumber $ea
    # xxx could be more sophisticated here
    psPuts "$x $y $r $ba $ea arc"
}

proc psClip {} {
    psPuts "clip"
}

proc psRotate {angle} {
    AssertIsNumber $angle
    psPuts "$angle rotate"
}

proc psSetfont {face size} {
    # could check fonts here, but already do elsewhere
    AssertIsNumber $size
    psPuts "($face) findfont $size scalefont setfont"
}

proc psShow {text anchor} {
    psPuts "($text)"
    switch -exact $anchor {
	"c" { psPuts "cshow" }
	"l" { psPuts "lshow" }
	"r" { psPuts "rshow" }
	default { Abort "bad anchor: $anchor" }
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
    variable _ps
    return $_ps(defined)
}

proc psCanvasWidth {} {
    variable _ps
    return $_ps(width)
}

proc psCanvasHeight {} {
    variable _ps
    return $_ps(height)
}

#
# EXPORTED FUNCTIONS
#
proc PsCanvasInfo {args} {
    set default {
	{"info"          ""         "pass in field you wish to get info about: width,height"}
    }
    ArgsProcessWithDashArgs PsCanvasInfo default args use \
	"Use this to get info about the defined canvas. Current options to -info are 'width', which returns the width of the canvas in points, or 'height', which returns the height. "
    AssertEqual [psCanvasDefined] 1
    
    switch -exact $use(info) {
	width  { return [psCanvasWidth] }
	height { return [psCanvasHeight] }
	default { Abort "Bad parameter to PsCanvasInfo: $use(info)" }
    }
}

proc psInit {program version} {
    variable _ps

    if {[info exists _ps(init)]} {
	return
    }
    set _ps(init)     1

    # generic program info
    set _ps(program)  $program
    set _ps(version)  $version

    # date
    set _ps(date)     [clock format [clock seconds]]

    # about this document
    set _ps(defined)  0

    # set legal fonts
    set _ps(fontlist) "Helvetica"
    set _ps(allfonts) "Helvetica Helvetica-Bold Helvetica-Italic TimesRoman TimesRoman-Bold TimesRoman-Italic Courier Courier-Bold Courier-Italic"

    set _ps(gsaveCnt)    0
    set _ps(grestoreCnt) 0

    set _ps(colors) {
	{ {black}                   {0.00 0.00 0.00} }
	{ {white}                   {1.00 1.00 1.00} }
	{ {gray}                    {0.50 0.50 0.50} }
	{ {lightgray lgray}         {0.75 0.75 0.75} }
	{ {verylightgray vlgray}    {0.90 0.90 0.90} }
	{ {verydarkgray vdgray vdg} {0.10 0.10 0.10} }
	{ {darkgray dgray dg}       {0.25 0.25 0.25} }
	{ {blue}                    {0.00 0.00 1.00} }
	{ {lightblue lblue}         {0.60 0.60 1.00} }
	{ {darkblue dblue}          {0.20 0.00 0.40} }
	{ {pink}                    {1.00 0.60 0.80} }
	{ {salmon}                  {0.80 0.60 0.60} }
	{ {lightred lred}           {1.00 0.20 0.20} }
	{ {red}                     {1.00 0.00 0.00} }
	{ {darkred dred}            {0.50 0.00 0.00} }
	{ {green}                   {0.00 1.00 0.00} }
	{ {lightgreen lgreen}       {0.60 1.00 0.60} }
	{ {darkgreen dgreen}        {0.00 0.50 0.00} }
	{ {yellow}                  {1.00 1.00 0.00} }
	{ {lightyellow lyellow}     {1.00 1.00 0.39} }
	{ {orange}                  {1.00 0.50 0.00} }
	{ {darkorange dorange}      {0.80 0.20 0.00} }
	{ {lightorange lorange}     {1.00 0.80 0.20} }
	{ {purple}                  {0.40 0.00 0.40} }
	{ {brown}                   {0.60 0.40 0.00} }
    }
}

proc PsColors {} {
    variable _ps
    psInit "" ""
    set colorlist ""
    foreach entry $_ps(colors) {
	set color [lindex [lindex $entry 0] 0]
	if {$colorlist == ""} {
	    set colorlist $color 
	} else {
	    set colorlist "$colorlist $color"
	}
    }
    return $colorlist
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
    AssertEqual [info exists _ps(defined)] 0

    # init variables
    psInit $use(program) $use(version)

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

    variable _ps
    set _ps(defined)   1
    set _ps(width)     $w
    set _ps(height)    $h
    set _ps(title)     $use(title)
    set _ps(firstLine) "%!PS-Adobe-2.0"

    # generic eps header
    psPuts $_ps(firstLine)
    psPuts "%%Title: $use(title)"
    psPuts "%%Creator: $_ps(program) version $_ps(version)"
    psPuts "%%CreationDate: $_ps(date)"
    psPuts "%%DocumentFonts: (atend)"
    psPuts "%%BoundingBox: 0 0 $w $h"
    psPuts "%%Orientation: Portrait"
    psPuts "%%EndComments"

    # zdraw dictionary
    psPuts "% zdraw dictionary"
    psPuts "/zdict 256 dict def"
    psPuts "zdict begin"
    psPuts "/cpx 0 def"
    psPuts "/cpy 0 def"
    psPuts "/recordcp {currentpoint /cpy exch def /cpx exch def} bind def"
    psPuts "/m {moveto} bind def"
    psPuts "/l {lineto} bind def"
    psPuts "/mr {rmoveto} bind def"
    psPuts "/lr {rlineto} bind def"
    psPuts "/lshow {show recordcp} def"
    psPuts "/rshow {dup stringwidth pop neg 0 mr show recordcp} def"
    psPuts "/cshow {dup stringwidth pop -2 div 0 mr show recordcp} def"
    psPuts "end"
    psPuts "zdict begin"

    Dputs ps "Canvas: [ArgsPrint use]"
}

proc PsRender {args} {
    set default {
	{"file"     "stdout"     "the file to print postscript to; stdout means stdout though"}
    }
    ArgsProcessWithDashArgs PsRender default args use \
	"Use this routine to print out all the postscript commands you've been queueing up to a file or 'stdout' (default)."

    # do some checks
    variable _ps
    AssertEqual $_ps(gsaveCnt) $_ps(grestoreCnt)

    # generic eps trailer
    psPuts "% zdraw epilogue"
    psPuts "end"
    psPuts "showpage"
    psPuts "%%Trailer"
    psPuts "%%DocumentFonts: $_ps(fontlist)"

    # and now, dump it all
    if {[StringEqual $use(file) "stdout"] == 0} {
	set fd [open $use(file) w]
	psPutsDump $fd
	close $fd
    } else {
	psPutsDump stdout
    }
}

proc PsLine {args} {
    set default {
	{"coord"          "0,0:0,0"     "x1,y1: ... :xn,yn"}
	{"linecolor"      "black"       "color of the line"}
	{"linewidth"      "1"           "width of the line"}
	{"linecap"        "0"           "linecap: 0, 1, or 2 (see postscript manual for details)"}
	{"linedash"       "0"           "define dashes for the line"}
	{"closepath"      "false"       "whether to close the path or not"}
	{"arrow"          "false"       "add an arrowhead at end"}
	{"arrowheadlength" "4"          "length of the arrowhead"}
	{"arrowheadwidth" "3"           "width of the arrowhead"}
	{"arrowlinecolor" "black"       "linecolor of the arrowhead"}
	{"arrowlinewidth" "0.5"         "linewidth of the arrowhead"}
	{"arrowfill"      "true"        "fill the arrowhead"}
	{"arrowfillcolor" "black"       "the color to fill the arrowhead with"}
	{"arrowstyle"     "normal"      "types of arrowheads: normal is only one right now"}
    }
    ArgsProcessWithDashArgs PsLine default args use ""
    psComment "PsLine coords: $use(coord) arrow: $use(arrow)"

    # save the context to begin
    psGsave

    # first, draw the line, one component at a time
    set count [ArgsParseNumbersList $use(coord) coords]
    psNewpath
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
    if {$use(linedash) != 0} {
	psSetdash $use(linedash)
    }
    psStroke

    # now, do the arrow 
    if [True $use(arrow)] {
	set sx    $coords([expr $count-2],n1)
	set sy    $coords([expr $count-2],n2)
	set ex    $coords([expr $count-1],n1)
	set ey    $coords([expr $count-1],n2)
	# use the last line segment to compute the orthogonal vectors for the arrowhead

	set vx    [expr ($ex-$sx)]
	set vy    [expr ($ey-$sy)]
	set hypot [expr hypot($vx,$vy)]
	# get angle of last line segment
	set angle [expr (360.0*asin($vy/$hypot))/(4.0*acos(0))]

	set aw    [expr $use(arrowheadwidth)/2.0]
	set al    $use(arrowheadlength)

	for {set i 0} {$i < 2} {incr i} {
	    psGsave

	    psNewpath
	    psMoveto $ex $ey
	    psRotate $angle
	    psRlineto 0 $aw
	    psRlineto $al [expr -$aw]
	    psRlineto [expr -$al] [expr -$aw]
	
	    psClosepath
	    if {$i == 1} {
		psSetcolor [psColor $use(arrowlinecolor)]
		psSetlinewidth $use(arrowlinewidth)
		psStroke
	    } else {
		psSetcolor [psColor $use(arrowfillcolor)]
		psFill
	    }
	    psGrestore
	}
    }

    # restore context at end
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
	{"fillstyle"  "solid"       "solid,hline,vline,/line,\line,circle,square,..."}
	{"fillparams" "2,4"         "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs psMakePattern default args use \
	"Use this to fill a rectangular region with one of many specified patterns."

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
	"hline" {
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
	"vline" {
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
	"/line" {
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
	"\line" {
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
	"circle" {
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
	"square" {
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
	    Abort "should be one of 'solid', 'vline', 'hline', '/line', '\line', 'circle', 'square'"
	}
    }
}

proc PsPolygon {args} {
    set default {
	{"coord"      ""            "x1,y1:...:xn,yn"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"linecap"    "0"           "linecap: 0, 1, or 2 (see postscript manual for details)"}
	{"linedash"   "0"           "define dashes for the line; 0 means solid line"}
	{"background" ""            "if not empty, make the polyground have this color background"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" "2,4"         "any params that the fill style needs"}
    }
    ArgsProcessWithDashArgs PsPolygon default args use ""

    # pull out each element of the path
    set count [ArgsParseNumbersList $use(coord) coords]
    AssertGreaterThan $count 0

    # find minx,miny and maxx,maxy
    set minX $coords(0,n1) 
    set minY $coords(0,n2) 
    set maxX $minX
    set maxY $minY
    for {set p 1} {$p < $count} {incr p} {
	if {$coords($p,n1) < $minX} {
	    set minX $coords($p,n1)
	}
	if {$coords($p,n2) < $minY} {
	    set minY $coords($p,n2)
	}
	if {$coords($p,n1) > $maxX} {
	    set maxX $coords($p,n1)
	}
	if {$coords($p,n2) > $maxY} {
	    set maxY $coords($p,n2)
	}
    }

    # if the background should be filled, do that here
    if {$use(background) != ""} {
	psGsave
	psMoveto $coords(0,n1) $coords(0,n2) 
	for {set p 1} {$p < $count} {incr p} {
	    psLineto $coords($p,n1) $coords($p,n2) 
	}
	psClosepath
	psSetcolor [psColor $use(background)]
	psFill
	psGrestore
    }

    # do filled one first
    if {[True $use(fill)]} {
	# need to draw proper path to then clip it
	psGsave
	psMoveto $coords(0,n1) $coords(0,n2) 
	for {set p 1} {$p < $count} {incr p} {
	    psLineto $coords($p,n1) $coords($p,n2) 
	}
	psClosepath
	psClip
	# use minimal x,y pair and max x.y pair to determine patternbox
	psMakePattern -coord "$minX $minY : $maxX $maxY" -fillcolor $use(fillcolor) \
	    -fillstyle $use(fillstyle) -fillparams $use(fillparams)
	psGrestore
    }

    # now draw outline of polygon
    if {$use(linewidth) > 0} {
	psGsave
	psMoveto $coords(0,n1) $coords(0,n2) 
	for {set p 1} {$p < $count} {incr p} {
	    psLineto $coords($p,n1) $coords($p,n2) 
	}
	psClosepath
	psSetcolor [psColor $use(linecolor)]
	psSetlinewidth $use(linewidth)
	psSetlinecap $use(linecap)
	if {$use(linedash) != 0} {
	    psSetdash $use(linedash)
	}
	psStroke
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
	{"fillparams" "2,4"         "any params that the fill style needs"}
	{"background" ""            "if not empty, background color for this box"}
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
	{"coord"      "0,0"         "x1,y1"}
	{"radius"     "1"           "radius of circle"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" "2,4"         "any params that the fill style needs"}
	{"background" ""            "if not empty, make the polyground have this color background"}
    }
    ArgsProcessWithDashArgs PsCircle default args use ""

    # pull out each element of the path
    set xy [split $use(coord) ","]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]
    set r  $use(radius)

    # if the background should be filled, do that here
    if {$use(background) != ""} {
	psGsave
	psNewpath
	psArc $x $y $use(radius) 0 360
	psSetcolor [psColor $use(background)]
	psFill
	psGrestore
    }

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
    if {$use(linewidth) > 0} {
	psGsave
	psNewpath
	psArc $x $y $use(radius) 0 360
	psSetcolor [psColor $use(linecolor)]
	psSetlinewidth $use(linewidth)
	psStroke
	psGrestore
    }
}

proc PsText {args} {
    set default {
	{"coord"     "0,0"         "x1,y1"}
	{"color"     "black"       "color of text"}
	{"text"      "text"        "the text on the canvas"}
	{"font"      "Helvetica"   "which font: Helvetica, TimesRoman, Courier"}
	{"size"      "10"          "size of the type face"}
	{"rotate"    "0"           "angle of rotation"}
	{"anchor"    "c"           "the x-directional anchor: l (left), c (center), r (right); or, if you need y-directional alignment too: something,l (low), something,c (center), "}
	{"yanchor"   "l"           "the y-directional anchor: l (low), c (center), h (high)"}
    }
    ArgsProcessWithDashArgs PsText default args use \
	"Use this routine to place text on the canvas. Most options are obvious (the expected coordinate pair, color, text, font, size (the size of the font), rotation (which way the text should be rotated), but the anchor can be a bit confusing. Basically, the anchor determines where, relative to the coordinate pair (x,y), the text should be placed. Simple anchoring includes left (l), center (c), or right (r), which determines whether the text starts at the x position specified (left), ends at x (right), or is centered on the x (center). Adding a second anchor (xanchor,yanchor) specifies a y position anchoring as well. The three options there are low (l), which is the default if none is specified, high (h), and middle (m), again all determining the placement of the text relative to the y coordinate specified. "

    psAddfont $use(font)

    # pull our coords
    set count [ArgsParseNumbers $use(coord) coord]
    AssertEqual $count 2
    set x $coord(0)
    set y $coord(1)

    # pull out anchors
    set count [ArgsParseNumbers $use(anchor) anchor]
    if {$count == 1} {
	# just one anchor, assume it is the x anchor
	set xanchor $anchor(0)
	set yanchor "l"
    } elseif {$count == 2} {
	# two anchors
	set xanchor $anchor(0)
	set yanchor $anchor(1)
    } else {
	Abort "Bad anchor: $use(anchor)"
    }

    psGsave
    psNewpath
    psSetcolor [psColor $use(color)]
    psSetfont $use(font) $use(size)
    psMoveto $x $y
    if {$use(rotate) != 0} {
	psGsave
	psRotate $use(rotate)
    }
    # XXX -- .36: a magic adjustment to center text in y direction
    switch -exact $yanchor {
	l { } 
	c { psRmoveto 0 [expr -0.36 * $use(size)] } 
	h { psRmoveto 0 [expr -0.72 * $use(size)] } 
	default { Abort "yanchor should be: l, c, or h" }
    }
    psShow $use(text) $xanchor
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
	psPuts $use(raw)
    }
}

variable psCounter 0
variable psArray   

proc psPuts {str} {
    variable psCounter 
    variable psArray
    set psArray($psCounter) $str
    incr psCounter 1
}

proc psPutsDump {fd} {
    variable psCounter 
    variable psArray
    variable _ps
    if {$psCounter > 0} {
	if {[StringEqual $psArray(0) $_ps(firstLine)] == 0} {
	    Abort "First line of postscript looks wrong: Did you call PsCanvas first in your script?"
	}
    }
    for {set i 0} {$i < $psCounter} {incr i} {
	puts $fd $psArray($i)
	set psArray($i) ""
    }
    set psCounter 0
}
