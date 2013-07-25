#! /usr/bin/tclsh

# namespace relevant
variable _ps

# 
# this is a complete hack, and can be very wrong depending on the fontface
# (which it should clearly be dependent upon)
# the problem, of course: only the ps interpreter really knows
# how wide the string is: e.g., put the string on the stack and call 'stringwidth'
# but of course, we don't want to have to invoke that to get the result (a pain)
# we could build in a table that has all the answers for supported fonts (Helvetica, TimesRoman, etc.)
# but that is a complete pain as well
# so, for now, we just make a rough guess based on the length of the string and the size of the font
# 

proc psGetStringWidth {str fontsize} {
    variable _ps

    set len [string length $str]
    set sum 0.0
    for {set i 0} {$i < $len} {incr i} {
	set c [string index $str $i]
	if [string match {[A-HJ-Z234567890]} $c] {
	    set add 0.69
	} elseif [string match {[abcdeghkmnopqrsuvwxyz1I]} $c] {
	    set add 0.54
	} elseif [string match {[.fijlt]} $c] {
	    set add 0.3
	} elseif {[string compare $c "-"] == 0} {
	    set add 0.3
	} else {
	    # be conservative for all others
	    set add 0.65
	}
	# puts "s:$c --> $add"
	set sum [expr $sum + $add]
    }
    return [expr $fontsize * $sum]

    # DEAD CODE
    if {[info exists _ps(guess)] == 0} {
	set _ps(guess) 0.50
    } else {
	set _ps(guess) [expr $_ps(guess) + 0.02]
    }
    puts "guess: $_ps(guess)"
    return [expr $len * ($fontsize * $_ps(guess))]
}

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
    return [string trim [ArgsSwitch $_ps(colors) $c "Bad color choice"]]
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
    variable _ps
    # set _ps(comment) 1
    if {[info exists _ps(comment)]} {
	if {$_ps(comment) == 1} {
	    psPuts "% $str"
	}
    }
}

proc psSetcolor {c} {
    AssertEqual [llength $c] 3
    AssertIsNumber [lindex $c 0]
    AssertIsNumber [lindex $c 1]
    AssertIsNumber [lindex $c 2]
    
    # setrgbcolor
    psPuts "$c sc"
}

proc psSetlinewidth {lw} {
    AssertIsNumber $lw
    # psPuts "$lw setlinewidth"
    psPuts "$lw slw"
}

proc psSetlinecap {lc} {
    AssertIsNumber $lc
    # psPuts "$lc setlinecap"
    psPuts "$lc slc"
}

proc psSetlinejoin {lj} {
    AssertIsNumber $lj
    # psPuts "$lj setlinecap"
    psPuts "$lj slj"
}

# expects a list that describes the dash pattern
proc psSetdash {d} {
    set n [ArgsParseCommaList $d dashes]
    AssertIsNumber $dashes(0)
    set dashList $dashes(0)
    for {set i 1} {$i < $n} {incr i} {
	AssertIsNumber $dashes($i)
	set dashList "$dashList $dashes($i)"
    }
    # should probably allow people to set the offset (currently 0)
    psPuts "\[$dashList\] 0 sd"
}

proc psMoveto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "[format %.2f $x] [format %.2f $y] m"
}

proc psRmoveto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "[format %.2f $x] [format %.2f $y] mr"
}

proc psLineto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "[format %.2f $x] [format %.2f $y] l"
}

proc psRlineto {x y} {
    AssertIsNumber $x
    AssertIsNumber $y
    psPuts "[format %.2f $x] [format %.2f $y] lr"
}

proc psNewpath {} {
    # psPuts "newpath"
    psPuts "np"
}

proc psClosepath {} {
    # psPuts "closepath"
    psPuts "cp"
}

proc psFill {} {
    # psPuts "fill"
    psPuts "fl"
}

proc psStroke {} {
    # psPuts "stroke"
    psPuts "st"
}

proc psGsave {} {
    # psPuts "gsave"
    psPuts "gs"
    variable _ps
    incr _ps(gsaveCnt)
}

proc psGrestore {} {
    # psPuts "grestore"
    psPuts "gr"
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
    switch -exact $anchor {
	"c" { psPuts "($text) cshow" }
	"l" { psPuts "($text) lshow" }
	"r" { psPuts "($text) rshow" }
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
        { {            aliceblue } { 0.94 0.97 1.00 } }
        { {         antiquewhite } { 0.98 0.92 0.84 } }
        { {                 aqua } { 0.00 1.00 1.00 } }
        { {           aquamarine } { 0.50 1.00 0.83 } }
        { {                azure } { 0.94 1.00 1.00 } }
        { {                beige } { 0.96 0.96 0.86 } }
        { {               bisque } { 1.00 0.89 0.77 } }
        { {                black } { 0.00 0.00 0.00 } }
        { {       blanchedalmond } { 1.00 0.92 0.80 } }
        { {                 blue } { 0.00 0.00 1.00 } }
        { {           blueviolet } { 0.54 0.17 0.89 } }
        { {                brown } { 0.65 0.16 0.16 } }
        { {            burlywood } { 0.87 0.72 0.53 } }
        { {            cadetblue } { 0.37 0.62 0.63 } }
        { {           chartreuse } { 0.50 1.00 0.00 } }
        { {            chocolate } { 0.82 0.41 0.12 } }
        { {                coral } { 1.00 0.50 0.31 } }
        { {       cornflowerblue } { 0.39 0.58 0.93 } }
        { {             cornsilk } { 1.00 0.97 0.86 } }
        { {              crimson } { 0.86 0.08 0.24 } }
        { {                 cyan } { 0.00 1.00 1.00 } }
        { {             darkblue } { 0.00 0.00 0.55 } }
        { {             darkcyan } { 0.00 0.55 0.55 } }
        { {        darkgoldenrod } { 0.72 0.53 0.04 } }
        { {             darkgray } { 0.66 0.66 0.66 } }
        { {            darkgreen } { 0.00 0.39 0.00 } }
        { {            darkkhaki } { 0.74 0.72 0.42 } }
        { {          darkmagenta } { 0.55 0.00 0.55 } }
        { {       darkolivegreen } { 0.33 0.42 0.18 } }
        { {           darkorange } { 1.00 0.55 0.00 } }
        { {           darkorchid } { 0.60 0.20 0.80 } }
        { {              darkred } { 0.55 0.00 0.00 } }
        { {           darksalmon } { 0.91 0.59 0.48 } }
        { {         darkseagreen } { 0.55 0.74 0.56 } }
        { {        darkslateblue } { 0.28 0.24 0.55 } }
        { {        darkslategray } { 0.18 0.31 0.31 } }
        { {        darkturquoise } { 0.00 0.87 0.82 } }
        { {           darkviolet } { 0.58 0.00 0.83 } }
        { {             deeppink } { 1.00 0.08 0.58 } }
        { {          deepskyblue } { 0.00 0.75 1.00 } }
        { {              dimgray } { 0.41 0.41 0.41 } }
        { {           dodgerblue } { 0.12 0.56 1.00 } }
        { {            firebrick } { 0.70 0.13 0.13 } }
        { {          floralwhite } { 1.00 0.98 0.94 } }
        { {          forestgreen } { 0.13 0.55 0.13 } }
        { {              fuchsia } { 1.00 0.00 1.00 } }
        { {            gainsboro } { 0.86 0.86 0.86 } }
        { {           ghostwhite } { 0.97 0.97 1.00 } }
        { {                 gold } { 1.00 0.84 0.00 } }
        { {            goldenrod } { 0.85 0.65 0.13 } }
        { {                 gray } { 0.50 0.50 0.50 } }
        { {                green } { 0.00 0.50 0.00 } }
        { {          greenyellow } { 0.68 1.00 0.18 } }
        { {             honeydew } { 0.94 1.00 0.94 } }
        { {              hotpink } { 1.00 0.41 0.71 } }
        { {            indianred } { 0.80 0.36 0.36 } }
        { {               indigo } { 0.29 0.00 0.51 } }
        { {                ivory } { 1.00 1.00 0.94 } }
        { {                khaki } { 0.94 0.90 0.55 } }
        { {             lavender } { 0.90 0.90 0.98 } }
        { {        lavenderblush } { 1.00 0.94 0.96 } }
        { {            lawngreen } { 0.49 0.99 0.00 } }
        { {         lemonchiffon } { 1.00 0.98 0.80 } }
        { {            lightblue } { 0.68 0.85 0.90 } }
        { {           lightcoral } { 0.94 0.50 0.50 } }
        { {            lightcyan } { 0.88 1.00 1.00 } }
        { { lightgoldenrodyellow } { 0.98 0.98 0.82 } }
        { {           lightgreen } { 0.56 0.93 0.56 } }
        { {            lightgrey } { 0.83 0.83 0.83 } }
        { {            lightpink } { 1.00 0.71 0.76 } }
        { {          lightsalmon } { 1.00 0.63 0.48 } }
        { {        lightseagreen } { 0.13 0.70 0.67 } }
        { {         lightskyblue } { 0.53 0.81 0.98 } }
        { { lightslategray lightgray } { 0.47 0.53 0.60 } }
        { {       lightsteelblue } { 0.69 0.77 0.87 } }
        { {          lightyellow } { 1.00 1.00 0.88 } }
        { {                 lime } { 0.00 1.00 0.00 } }
        { {            limegreen } { 0.20 0.80 0.20 } }
        { {                linen } { 0.98 0.94 0.90 } }
        { {              magenta } { 1.00 0.00 1.00 } }
        { {               maroon } { 0.50 0.00 0.00 } }
        { {     mediumaquamarine } { 0.40 0.80 0.67 } }
        { {           mediumblue } { 0.00 0.00 0.80 } }
        { {         mediumorchid } { 0.73 0.33 0.83 } }
        { {         mediumpurple } { 0.58 0.44 0.86 } }
        { {       mediumseagreen } { 0.24 0.70 0.44 } }
        { {      mediumslateblue } { 0.48 0.41 0.93 } }
        { {    mediumspringgreen } { 0.00 0.98 0.60 } }
        { {      mediumturquoise } { 0.28 0.82 0.80 } }
        { {      mediumvioletred } { 0.78 0.08 0.52 } }
        { {         midnightblue } { 0.10 0.10 0.44 } }
        { {            mintcream } { 0.96 1.00 0.98 } }
        { {            mistyrose } { 1.00 0.89 0.88 } }
        { {             moccasin } { 1.00 0.89 0.71 } }
        { {          navajowhite } { 1.00 0.87 0.68 } }
        { {                 navy } { 0.00 0.00 0.50 } }
        { {              oldlace } { 0.99 0.96 0.90 } }
        { {            olivedrab } { 0.42 0.56 0.14 } }
        { {               orange } { 1.00 0.65 0.00 } }
        { {            orangered } { 1.00 0.27 0.00 } }
        { {               orchid } { 0.85 0.44 0.84 } }
        { {        palegoldenrod } { 0.93 0.91 0.67 } }
        { {            palegreen } { 0.60 0.98 0.60 } }
        { {        paleturquoise } { 0.69 0.93 0.93 } }
        { {        palevioletred } { 0.86 0.44 0.58 } }
        { {           papayawhip } { 1.00 0.94 0.84 } }
        { {            peachpuff } { 1.00 0.85 0.73 } }
        { {                 peru } { 0.80 0.52 0.25 } }
        { {                 pink } { 1.00 0.78 0.80 } }
        { {                 plum } { 0.87 0.63 0.87 } }
        { {           powderblue } { 0.69 0.88 0.90 } }
        { {               purple } { 0.50 0.00 0.50 } }
        { {                  red } { 1.00 0.00 0.00 } }
        { {            rosybrown } { 0.74 0.56 0.56 } }
        { {            royalblue } { 0.25 0.41 0.88 } }
        { {          saddlebrown } { 0.55 0.27 0.07 } }
        { {               salmon } { 0.98 0.50 0.45 } }
        { {           sandybrown } { 0.96 0.64 0.38 } }
        { {             seagreen } { 0.18 0.55 0.34 } }
        { {             seashell } { 1.00 0.96 0.93 } }
        { {               sienna } { 0.63 0.32 0.18 } }
        { {               silver } { 0.75 0.75 0.75 } }
        { {              skyblue } { 0.53 0.81 0.92 } }
        { {            slateblue } { 0.42 0.35 0.80 } }
        { {                 snow } { 1.00 0.98 0.98 } }
        { {          springgreen } { 0.00 1.00 0.50 } }
        { {            steelblue } { 0.27 0.51 0.71 } }
        { {                  tan } { 0.82 0.71 0.55 } }
        { {                 teal } { 0.00 0.50 0.50 } }
        { {              thistle } { 0.85 0.75 0.85 } }
        { {               tomato } { 1.00 0.39 0.28 } }
        { {            turquoise } { 0.25 0.88 0.82 } }
        { {               violet } { 0.93 0.51 0.93 } }
        { {                wheat } { 0.96 0.87 0.70 } }
        { {                white } { 1.00 1.00 1.00 } }
        { {           whitesmoke } { 0.96 0.96 0.96 } }
        { {               yellow } { 1.00 1.00 0.00 } }
        { {          yellowgreen } { 0.60 0.80 0.20 } }
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

# expect things of this form:
#   X in  -> X inches
#   Xin   -> X inches
#   X i   -> X inches
#   Xi    -> X inches
#   X pts -> X points
#   Xpts -> X points
#   X p  -> X points
#   Xp   -> X points
#   X    -> X points
# NOTE: X can have a decimal value
proc psParsePoints {value numeric__ units__} {
    upvar $numeric__ numeric
    upvar $units__   units
    # should be of form number,...,number,letter,...,letter
    set value [string trim $value]
    set numbers 1
    set endOfNum [string length $value]
    for {set i 0} {$i < [string length $value]} {incr i} {
	set c [string index $value $i]
	if {([string is integer $c] == 0) && ([string compare $c "-"] != 0) && ([string compare $c "."] != 0)} {
	    set endOfNum $i
	    break
	}
    }
    set numeric [string range $value 0 [expr $endOfNum-1]]
    set units   [string trim [string range $value $endOfNum end]]
}

proc psConvertToPoints {value} {
    psParsePoints $value result units
    if {[StringEqual $units "i"] || [StringEqual $units "in"] || [StringEqual $units "inches"]} {
	set value [expr $result * 72.0]
    } else {
	set value $result
    }
    return $value
}
  

proc PsCanvas {args} {
    set default {
	{"program"    "zplot"       "name of program that created this postscript"}
	{"version"    "1.0.0"       "version number of program"}
	{"title"      "default.eps" "name of eps file"}
	{"width"      "300"         "width of drawing canvas; in inches (e.g., '7in' or '7i') or points (e.g., '7pts' or '7p' or '7')"}
	{"height"     "240"         "height of drawing canvas"}
    }
    ArgsProcessWithDashArgs PsCanvas default args use ""
    AssertEqual [info exists _ps(defined)] 0

    # init variables
    psInit $use(program) $use(version)

    # which units?
    psParsePoints $use(width) w units
    if {[StringEqual $units "i"] || [StringEqual $units "in"] || [StringEqual $units "inches"]} {
	set w [expr $w * 72.0]
    }
    psParsePoints $use(height) h units
    if {[StringEqual $units "i"] || [StringEqual $units "in"] || [StringEqual $units "inches"]} {
	set h [expr $h * 72.0]
    }

    variable _ps
    set _ps(defined)   1
    set _ps(width)     $w
    set _ps(height)    $h
    set _ps(title)     $use(title)
    set _ps(firstLine) "%!PS-Adobe-2.0 EPSF-2.0"

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
    psPuts "/np {newpath} bind def"
    psPuts "/cp {closepath} bind def"
    psPuts "/st {stroke} bind def"
    psPuts "/fl {fill} bind def"
    psPuts "/gs {gsave} bind def"
    psPuts "/gr {grestore} bind def"
    psPuts "/slw {setlinewidth} bind def"
    psPuts "/slc {setlinecap} bind def"
    psPuts "/slj {setlinejoin} bind def"
    psPuts "/sc  {setrgbcolor} bind def"
    psPuts "/sd  {setdash} bind def"
    psPuts "/triangle {pop pop pop} bind def"  ;# XXX -- not implemented (yet) -- expects x y size on stack
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
	{"linejoin"       "0"           "linejoin: 0, 1, or 2 (see postscript manual for details)"}
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
    psComment "PsLine:: [ArgsPrint use]"

    # save the context to begin
    psGsave

    # first, draw the line, one component at a time
    set count [ArgsParseItemPairList $use(coord) coords]
    psNewpath
    psMoveto $coords(0,n1) $coords(0,n2) 
    for {set p 1} {$p < $count} {incr p} {
	psLineto $coords($p,n1) $coords($p,n2) 
    }
    if [True $use(closepath)] {
	psClosepath
    }
    if {[StringEqual $use(linecolor) "black"] == 0} {
	psSetcolor [psColor $use(linecolor)]
    }
    if {$use(linewidth) != 1} {
	psSetlinewidth $use(linewidth)
    }
    if {$use(linecap) != 0} {
	psSetlinecap $use(linecap)
    }
    if {$use(linejoin) != 0} {
	psSetlinejoin $use(linejoin)
    }
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
	{"fillstyle"  "solid"       "solid,hline,vline,dline1,dline2,circle,square,..."}
	{"fillsize"   "3"           "size of the pattern object"}
	{"fillskip"   "4"           "space between each object in pattern"}
    }
    ArgsProcessWithDashArgs psMakePattern default args use \
	"Use this to fill a rectangular region with one of many specified patterns."

    # bound box
    set count [ArgsParseItemPairList $use(coord) xy]
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
	    set size  $use(fillsize)
	    set skip  $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0
	    psSetlinewidth $size
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
		psNewpath
		psRectangle $x1 $cy $x2 [expr $cy+$size] 
		psClosepath
		psFill
		psStroke
	    }
	}
	"vline" {
	    set size  $use(fillsize)
	    set skip  $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0
	    psSetlinewidth $size
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$size]} {
		psNewpath
		psMoveto $cx $y1
		psLineto $cx $y2
		psStroke
	    } 
	}
	"dline1" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetlinewidth $size
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
		psNewpath
		psMoveto $x1 $cy
		psLineto $x2 [expr ($x2-$x1)+$cy]
		psStroke
	    } 
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx+$skip+$size]} {
		psNewpath
		psMoveto $cx $y1
		psLineto [expr $cx+($y2-$y1)] $y2
		psStroke
	    } 
	}
	"dline2" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetlinewidth $size
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cy $y1} {$cy <= $y2} {set cy [expr $cy+$skip+$size]} {
		psNewpath
		psMoveto $x2 $cy
		psLineto $x1 [expr ($x2-$x1)+$cy]
		psStroke
	    } 
	    for {set cx $x2} {$cx >= $x1} {set cx [expr $cx-($skip+$size)]} {
		psNewpath
		psMoveto $cx $y1
		psLineto [expr $cx-($y2-$y1)] $y2
		psStroke
	    } 
	}
	"circle" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
		    psNewpath
		    psArc $cx $cy $size 0 360
		    psFill
		    psStroke
		}
	    }
	}
	"square" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
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
	"triangle" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
		    psNewpath
		    psMoveto [expr $cx-$size/2.0] $cy 
		    psLineto [expr $cx+$size/2.0] $cy 
		    psLineto $cx [expr $cy+$size]
		    psClosepath
		    psFill
		    psStroke
		}
	    }
	}
	"utriangle" {
	    set size $use(fillsize)
	    set skip $use(fillskip)
	    psMakeBoxBigger x1 y1 x2 y2 10.0 
	    psSetcolor [psColor $use(fillcolor)]
	    for {set cx $x1} {$cx <= $x2} {set cx [expr $cx + $size + $skip]} {
		for {set cy $y1} {$cy <= $y2} {set cy [expr $cy + $size + $skip]} {
		    psNewpath
		    psMoveto [expr $cx-$size/2.0] [expr $cy+$size]
		    psLineto [expr $cx+$size/2.0] [expr $cy+$size]
		    psLineto $cx $cy 
		    psClosepath
		    psFill
		    psStroke
		}
	    }
	}
	default {
	    puts stderr "bad fill style: $use(fillstyle)"
	    Abort "should be one of 'solid', 'vline', 'hline', 'dline1', 'dline2', 'circle', 'square'"
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
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"   "3"           "size of object in pattern"}
	{"fillskip"   "4"           "space between object in pattern"}
	{"bgcolor"    ""            "if not empty, make the polyground have this color background"}
    }
    ArgsProcessWithDashArgs PsPolygon default args use ""
    psComment "PsPolygon:: [ArgsPrint use]"

    # pull out each element of the path
    set count [ArgsParseItemPairList $use(coord) coords]
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
    if {$use(bgcolor) != ""} {
	psGsave
	psMoveto $coords(0,n1) $coords(0,n2) 
	for {set p 1} {$p < $count} {incr p} {
	    psLineto $coords($p,n1) $coords($p,n2) 
	}
	psClosepath
	psSetcolor [psColor $use(bgcolor)]
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
	psMakePattern -coord "$minX,$minY : $maxX,$maxY" -fillcolor $use(fillcolor) \
	    -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
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
	if {$use(linecap) != 0} {
	    psSetlinecap $use(linecap)
	}
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
	{"linedash"   "0"           "dash of the line"}
	{"linecap"    "0"           "cap of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"   "3"           "size of object in pattern"}
	{"fillskip"   "4"           "space between object in pattern"}
	{"bgcolor"     ""            "if not empty, background color for this box"}
    }
    ArgsProcessWithDashArgs PsBox default args use ""
    psComment "PsBox:: [ArgsPrint use]"

    # pull out each element of the path
    set count [ArgsParseItemPairList $use(coord) coords]
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
    if {$use(bgcolor) != ""} {
	psGsave
	psMakePattern -coord "$x1,$y1 : $x2,$y2" -fillcolor $use(bgcolor) -fillstyle solid 
	psGrestore
    }

    # do filled one first
    if [True $use(fill)] {
	psGsave
	psClipbox $x1 $y1 $x2 $y2
	psMakePattern -coord "$x1,$y1 : $x2,$y2" -fillcolor $use(fillcolor) \
	    -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
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
	if {$use(linedash) != 0} {
	    psSetdash $use(linedash)
	}
	if {$use(linedash) != 0} {
	    psSetdash $use(linedash)
	}
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
	{"linedash"   "0"           "dash pattern of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "black"       "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"   "3"           "size of object in pattern"}
	{"fillskip"   "4"           "space between object in pattern"}
	{"bgcolor"     ""            "if not empty, make the polyground have this color background"}
    }
    ArgsProcessWithDashArgs PsCircle default args use ""
    psComment "PsCircle:: [ArgsPrint use]"

    # pull out each element of the path
    set xy [split $use(coord) ","]
    set x  [lindex $xy 0]
    set y  [lindex $xy 1]
    set r  $use(radius)

    # if the background should be filled, do that here
    if {$use(bgcolor) != ""} {
	psGsave
	psNewpath
	psArc $x $y $use(radius) 0 360
	psSetcolor [psColor $use(bgcolor)]
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
	psMakePattern -coord "[expr $x-$r],[expr $y-$r] : [expr $x+$r],[expr $y+$r]" \
	    -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)
	psGrestore
    }

    # make the circle outline now
    if {$use(linewidth) > 0} {
	psGsave
	psNewpath
	psArc $x $y $use(radius) 0 360
	psSetcolor [psColor $use(linecolor)]
	psSetlinewidth $use(linewidth)
	if {$use(linedash) != 0} {
	    psSetdash $use(linedash)
	}
	psStroke
	psGrestore
    }
}

proc PsText {args} {
    set default {
	{"coord"      "0,0"         "x1,y1"}
	{"text"       "text"        "the text on the canvas"}
	{"font"       "Helvetica"   "which font: Helvetica, TimesRoman, Courier"}
	{"color"      "black"       "color of text"}
	{"size"       "10"          "size of the type face"}
	{"rotate"     "0"           "angle of rotation"}
	{"anchor"     "c"           "the x-directional anchor: l (left), c (center), r (right); or, if you need y-directional alignment too: something,l (low), something,c (center), "}
	{"bgcolor"    ""           "if non-empty, fill the background of the text with this color, then draw text upon it"}
	{"bgborder"   "1"          "if filling the background, how much of a border to have around the text?"}
    }
    ArgsProcessWithDashArgs PsText default args use \
	"Use this routine to place text on the canvas. Most options are obvious (the expected coordinate pair, color, text, font, size (the size of the font), rotation (which way the text should be rotated), but the anchor can be a bit confusing. Basically, the anchor determines where, relative to the coordinate pair (x,y), the text should be placed. Simple anchoring includes left (l), center (c), or right (r), which determines whether the text starts at the x position specified (left), ends at x (right), or is centered on the x (center). Adding a second anchor (xanchor,yanchor) specifies a y position anchoring as well. The three options there are low (l), which is the default if none is specified, high (h), and middle (m), again all determining the placement of the text relative to the y coordinate specified. "
    psComment "PsText:: [ArgsPrint use]"

    psAddfont $use(font)

    # pull our coords
    set count [ArgsParseCommaList $use(coord) coord]
    AssertEqual $count 2
    set x $coord(0)
    set y $coord(1)

    # pull out anchors
    set count [ArgsParseCommaList $use(anchor) anchor]
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

    # XXX - this is just a bit ugly and messy, sorry postscript
    if {$use(bgcolor) != ""} {
	psNewpath
	psSetcolor [psColor $use(bgcolor)]
	psSetfont $use(font) $use(size)
	psMoveto $x $y
	if {$use(rotate) != 0} {
	    psGsave
	    psRotate $use(rotate)
	}
	# now, adjust based on yanchor
	switch -exact $yanchor {
	    l { } 
	    c { psRmoveto 0 [expr -0.36 * $use(size)] } 
	    h { psRmoveto 0 [expr -0.72 * $use(size)] } 
	    default { Abort "yanchor should be: l, c, or h" }
	}
	# now, adjust based on xanchor
	switch -exact $xanchor {
	    l { psPuts "($use(text)) stringwidth pop dup" } 
	    c { psPuts "($use(text)) stringwidth pop dup -2 div 0 rmoveto dup" } 
	    r { psPuts "($use(text)) stringwidth pop dup -1 div 0 rmoveto dup" } 
	    default { Abort "xanchor should be: l, c, or r" }
	}	
	# now get width of string and draw the box
	psPuts "-$use(bgborder) -$use(bgborder) rmoveto"                      ;# move to left-bottom including borders
	psPuts "[expr 2 * $use(bgborder)] add 0 rlineto"                      ;# add border*2 to the width (on the stack) and move over
	psPuts "0 [expr (0.72 * $use(size)) + (2 * $use(bgborder))] rlineto"  ;# move a line up by the height of characters + border
	psPuts "neg [expr -2 * $use(bgborder)] add 0 rlineto"                 ;# move back down and closepath to finish
	psClosepath 
	psFill 
	if {$use(rotate) != 0} {
	    psGrestore
	}
    }

    # now, just draw the text
    psNewpath
    psSetcolor [psColor $use(color)]
    if {$use(bgcolor) == ""} {
	psSetfont $use(font) $use(size)
    }
    psMoveto $x $y
    if {$use(rotate) != 0} {
	psGsave
	psRotate $use(rotate)
    }
    # 0.36: a magic adjustment to center text in y direction
    # based on years of postscript experience, only change if you actually
    # know something about how this works, unlike me
    switch -exact $yanchor {
	l { } 
	c { psRmoveto 0 [expr -0.36 * $use(size)] } 
	h { psRmoveto 0 [expr -0.72 * $use(size)] } 
	default { Abort "yanchor should be: l, c, or h" }
    }
    # need to mark parens specially in postscript (as they are normally used to mark strings)
    set text [string map { ( \\( ) \\) } $use(text)]
    # puts "text: $use(text) --> $text"
    psShow $text $xanchor
    if {$use(rotate) != 0} {
	psGrestore
    }
    psStroke

    psGrestore
}

proc PsShape {args} {
    set default {
	{"style"        ""            "the possible shapes"}
	{"x"            ""            "x position of shape"}
	{"y"            ""            "y position of shape"}
	{"size"         ""            "size of shape"}
	{"linecolor"    "black"       "color of the line of the marker"}
	{"linewidth"    "1"           "width of lines used to draw the marker"}
	{"fill"         "f"           "for some shapes, filling makes sense; if desired, mark this true"}
	{"fillcolor"    "black"       "if filling, use this fill color"}
	{"fillstyle"    "solid"       "if filling, which fill style to use"}
	{"fillsize"      "3"         "size of object in pattern"}
	{"fillskip"      "4"         "space between object in pattern"}
    }
    ArgsProcessWithDashArgs PsShape default args use \
	"Use this to draw a shape on the plotting surface. Lots of possibilities, including square, circle, triangle, utriangle, plusline, hline, vline, xline, dline1, dline2, diamond, asterisk, ..."

    # pull out some params
    set x $use(x)
    set y $use(y)
    set s $use(size)

    switch -exact $use(style) {
	"square" { 
	    PsBox -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize $use(fillsize) -fillskip $use(fillskip) 
	    }
	"circle" { 
	    PsCircle -coord $x,$y -radius $s \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
	    }
	"triangle" {
	    PsPolygon -coord "[expr $x-$s],[expr $y-$s] : $x,[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
	    }
	"utriangle" {
	    PsPolygon -coord "[expr $x-$s],[expr $y+$s] : $x,[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
	}
	"plusline" { 
	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" -linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"xline" { 
	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"dline1" { 
	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"dline2" { 
	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"hline" { 
	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"vline" { 
	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	"diamond" {
	    PsPolygon -coord "[expr $x-$s],$y : $x,[expr $y+$s] : [expr $x+$s],$y : $x,[expr $y-$s] " \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
	}
	"star" {
	    XXX
	    PsPolygon -coord "[expr $x-$s],[expr $y-$s] : $x,[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize   $use(fillsize) -fillskip   $use(fillskip) 
	}
	"asterisk" {
	    PsLine -coord "[expr $x-$s],[expr $y-$s] : [expr $x+$s],[expr $y+$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	    PsLine -coord "[expr $x-$s],[expr $y+$s] : [expr $x+$s],[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	    PsLine -coord "[expr $x-$s],$y : [expr $x+$s],$y" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	    PsLine -coord "$x,[expr $y+$s] : $x,[expr $y-$s]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) 
	}
	default {
	    Abort "bad choice of point style: $use(style)"
	}
    }
}


# probably shouldn't use this a lot
proc PsRaw {args} {
    set default {
	{"raw"     ""      "raw postscript string to add into the output; DO NOT USE UNLESS A SUPER PRO"}
    }
    ArgsProcessWithDashArgs PsRaw default args use
    psComment "PsRaw:: [ArgsPrint use]"
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

proc psSimpleCodeGen {fd} {
    variable psCounter 
    variable psArray
    variable _ps

    # ORIG CODE - DEAD
    for {set i 0} {$i < $psCounter} {incr i} {
	puts $fd $psArray($i)
	set psArray($i) ""
    }
    set psCounter 0
}

# XXX -- this is incomplete, don't use it yet
proc psOptimizingCodeGen {fd} {
    variable psCounter 
    variable psArray
    variable _ps

    # is printing on ...
    set on 0
    set n 0

    # read in first context
    for {set i 0} {$i < $psCounter} {incr i} {
	set curr $psArray($i)

	if [StringEqual $curr "gs"] {
	    set on 1
	}

	if {$on} {
	    puts "printing $i:$curr"
	    set currArray($n) $curr
	    incr n
	}

	if [StringEqual $curr "gr"] {
	    puts "BREAK"
	    break
	}

	# zero out ps array
	# set psArray($i) ""
    }

    set currCnt $n

    # mark which lines constitute the environment
    puts "First one has $currCnt entries"
    for {set i 0} {$i < $currCnt} {incr i} {
	set cmd [lindex $currArray($i) [expr [llength $currArray($i)] - 1]]
	switch -exact $cmd {
	    slw { puts -nonewline "ENVIRONMENT :: " }
	}
	puts "FIRST: $i $currArray($i)"
	
    }
    

    # environment consists of 
    

    # put actual thing to be rendered into a different array
    for {set i 0} {$i < $psCounter} {incr i} {
	set curr $psArray($i)

	# OUTPUT (for now)
	puts $fd $curr

	# zero out ps array
	set psArray($i) ""
    }
    set psCounter 0
    
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

    psSimpleCodeGen $fd
    # psOptimizingCodeGen $fd
}
