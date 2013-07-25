# tcl

# some of our own routines
proc TranslateY {y} {
    global _d
    return [expr $_d(y0) + [ScaleY $y]]
}

proc TranslateX {x} {
    global _d
    return [expr $_d(x0) + [ScaleX $x]]
}

proc ScaleY {y} {
    global _d
    return [expr $y * ($_d(dheight) / $_d(yrange))]
}

proc ScaleX {x} {
    global _d
    return [expr $x * ($_d(dwidth) / $_d(xrange))]
}

proc Canvas {args} {
    set default {
	{"width"      "300"   "width of drawing canvas"}
	{"height"     "240"   "height of drawing canvas"}
	{"x0"          "30"   "x starting point"}
	{"y0"          "30"   "y starting point"}
	{"drawwidth"  "240"   "width of drawing area"}
	{"drawheight" "180"   "height of drawing area"}
    }
    ArgsProcessWithDashArgs Canvas default args use

    # make some assurances
    if {[expr $use(drawheight)+$use(y0)] > $use(height)} {
	puts stderr "drawing area improper: drawheight ($use(drawheight)) + y0 ($use(y0)) should be less than height ($use(height))"
	exit 1
    }
    if {[expr $use(drawwidth)+$use(x0)] > $use(width)} {
	puts stderr "drawing area improper: drawwidth ($use(drawwidth)) + x0 ($use(x0)) should be less than height ($use(width))"
	exit 1
    }

    # make the header
    Header $use(width) $use(height)

    # record others for posterity
    global _d

    set _d(x0)       [expr 1.0 * $use(x0)]
    set _d(y0)       [expr 1.0 * $use(y0)]
    set _d(dwidth)   [expr 1.0 * $use(drawwidth)]
    set _d(dheight)  [expr 1.0 * $use(drawheight)]
    set _d(width)    $use(width)
    set _d(height)   $use(height)
}


proc Axis {args} {
    global _d
    set default {
	{"xrange" "0 1" "the x range"}
	{"yrange" "0 1" "the y range"}
    }
    ArgsProcessWithDashArgs Axis default args use

    puts stderr "Hello, parsing $use(xrange)"
    set xcount [ArgsParseNumbers $use(xrange) xrange]
    puts stderr "xcount: $xcount"
    AssertEqual $xcount 2
    set _d(xmin) $xrange(0)
    set _d(xmax) $xrange(1)
    set _d(xrange) [expr $_d(xmax) - $_d(xmin)]

    set ycount [ArgsParseNumbers $use(yrange) yrange]
    AssertEqual $ycount 2
    set _d(ymin) $yrange(0)
    set _d(ymax) $yrange(1)
    set _d(yrange) [expr $_d(ymax) - $_d(ymin)]

    # draw the basic axes
    RawLine -coord [expr $_d(dwidth)+$_d(x0)+0.5],$_d(y0):$_d(x0),$_d(y0):$_d(x0),[expr $_d(y0)+$_d(dheight)+0.5] -linecolor black -linewidth 1

    # DEBUG -- draw bounding box too (for testing)
    RawLine -coord 0,0:0,239:299,239:299,0 -closepath t -linecolor black -linewidth 1
}

# XXX - needs to be real, do real arg processing
proc Tics {args} {
    set default {
	"style"    "x"      "which axis: x or y"
	"major"    "0,10,2" "0 to 10 major tics, by 2s"
	"numlabel" "0,10,2" "numeric label, 0 to 10, by 2s"
	"minor"    "1,9,2"  "minor tics at 1 to 9, by 2s"
    }
    ArgsProcessWithDashArgs Tics default args use

    # XXX -- args ignored, so far...
    global _d

    # get major tic marks
    set cnt [ArgsParseNumbers $use(major) tics]
    AssertEqual $cnt 3
    set min  $tics(0)
    set max  $tics(1)
    set step $tics(2)

    # draw x or y
    if {[seq $use(style) "x"]} {
	set ty $_d(y0)
	for {set x $min} {$x <= $max} {set x [expr $x + $step]} {
	    set tx [TranslateX $x]
	    set y0 $ty
	    set y1 [expr $ty-3]
	    RawLine -coord $tx,$y0:$tx,$y1 -linecolor black

	    # for each one of these, a label too
	    set ytmp [expr $y1-10]
	    RawText -coord $tx,$ytmp -text $x -size 10
	}
    }

    if {[seq $use(style) "y"]} {
	set tx $_d(x0)
	for {set y $min} {$y <= $max} {set y [expr $y + $step]} {
	    set ty [TranslateY $y]
	    set x0 $tx
	    set x1 [expr $tx-3]
	    RawLine -coord $x0,$ty:$x1,$ty -linecolor black

	    # for each one of these, a label too
	    RawText -coord [expr $tx-5],[expr $ty-3.5] -text $y -size 10 -anchor r
	}
    }
}

