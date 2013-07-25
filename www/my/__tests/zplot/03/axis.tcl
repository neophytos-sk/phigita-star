# tcl

proc getOppositeAxis {axis} {
    switch -exact $axis {
	x {return y}
	y {return x}
    }
    Abort "bad axis: $axis" 
}

proc Axis2 {args} {
    set default {
	{"drawable"        "root"         "the relevant drawable"}
	# axis info
	{"xrange"          ""             "min and max values to draw line between; empty means whole range"}
	{"yrange"          ""             "min and max values to draw line between; empty means whole range"}
	{"xlocation"       ""             "y-value of x axis; empty implies it will be at minimum of range"}
	{"ylocation"       ""             "x-value of y axis; empty implies it will be at minimum of range"}
	# all lines of axis stuff
	{"linecolor"       "black"        "color of axis line"}
	{"linewidth"       "1"            "width of axis line"}
	{"dash"            ""             "dash parameters"}
	# xlabel stuff
	{"xlabel"          ""             "empty: use range,step; else, list of form: 'x1,label:x2,label:...'"}
	{"xlabelrange"     ""             "start tics at n1, end at n2"}
	{"xlabelstep"      ""             "space between tic marks"}
	{"xlabelrotate"    "0"            "rotation of labels"}
	{"xlabelfont"      "Helvetica"    "font to use (if any)"}
	{"xlabelfontsize"  "10"           "font size of labels (if any)"}
	{"xlabelfontcolor" "black"        "font color"}
	{"xlabeloffset"    "0"            "offset in units from 0-value location for axis"}
	{"xlabelticsize"   "4"            "size of tics on the axis where these labels are being placed"}
	{"xlabelyshift"    "0"            "offset in pts of text (y axis)"}
	{"xlabelxshift"    "0"            "offset in pts of text (x axis)"}
	# ylabel stuff
	{"ylabel"          ""             "empty: use range,step; else, list of form: 'x1,label:x2,label:...'"}
	{"ylabelrange"     ""             "start tics at n1, end at n2"}
	{"ylabelstep"      ""             "space between tic marks"}
	{"ylabelrotate"    "0"            "rotation of labels"}
	{"ylabelfont"      "Helvetica"    "font to use (if any)"}
	{"ylabelfontsize"  "10"           "font size of labels (if any)"}
	{"ylabelfontcolor" "black"        "font color"}
	{"ylabeloffset"    "0"            "offset in units from 0-value location for axis"}
	{"ylabelyshift"    "0"            "offset in pts of text (y axis)"}
	{"ylabelxshift"    "0"            "offset in pts of text (x axis)"}
	# tic mark stuff
	{"xticrange"       ""             "start xtics at n1, end at n2; empty implies whole range"}
	{"xticstep"        ""             "units between xtic marks"}
	{"xticsize"        "4"            "size of xtics"}
	{"xticanchor"      "low"          "should xtics be on 'low', 'high', or 'middle' "}
	# tic mark stuff
	{"yticrange"       ""             "start ytics at n1, end at n2; empty implies whole range"}
	{"yticstep"        ""             "units between ytic marks"}
	{"yticsize"        "4"            "size of ytics"}
	{"yticanchor"      "low"          "should ytics be on 'low', 'high', or 'middle' "}
    }
    ArgsProcessWithDashArgs Axis2 default args use \
	"Use this to draw axes, ticmarks, and ticlabels."

    # first x axis
    Axis -axis x -drawable $use(drawable) \
	-range $use(xrange) -location $use(xlocation) \
	-linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash) \
	-extend "[expr $use(linewidth)/2.0] [expr $use(linewidth)/2.0]"

    # then y axis
    Axis -axis y -drawable $use(drawable) \
	-range $use(yrange) -location $use(ylocation) \
	-linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash) \
	-extend "[expr $use(linewidth)/2.0] [expr $use(linewidth)/2.0]"

    # now some tic marks


    # now some labels
    
}


proc Axis {args} {
    set default {
	{"drawable"   "root"     "the relevant drawable"}
	{"axis"       "x"        "x or y axis"}
	{"range"      ""         "min and max values to draw line between; empty means do whole range"}
	{"location"   ""         "where to place axis; -1 implies it will be at minimum of range"}
	{"linecolor"  "black"    "color of axis line"}
	{"linewidth"  "1"        "width of axis line"}
	{"dash"       ""         "dash parameters"}
	{"extend"     "0.5,0.5"  "extend axis this far left/down,right/up to meet properly with other axis"}
    }
    ArgsProcessWithDashArgs Axis default args use ""
    AssertEqual [psCanvasDefined] 1

    if {$use(range) == ""} {
	# must automatically fetch the range of these from drawable
	set min [DrawableGet $use(drawable) $use(axis)min]
	set max [DrawableGet $use(drawable) $use(axis)max]
    } else {
	set count [ArgsParseNumbers $use(range) range]
	AssertEqual $count 2
	set min $range(0)
	set max $range(1)
    }

    set count [ArgsParseNumbers $use(extend) extend]
    AssertEqual $count 2

    switch -exact $use(axis) {
	x {
	    set tmin [Translate $use(drawable) x $min]
	    set tmax [Translate $use(drawable) x $max]
	    if {$use(location) == ""} {
		set y [Translate $use(drawable) y [DrawableGet $use(drawable) ymin]]
	    } else {
		set y [Translate $use(drawable) y $use(location)]
	    }
	    PsLine -coord "[expr $tmin-$extend(0)] $y : [expr $tmax+$extend(1)] $y" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)
	}
	y {
	    set tmin [Translate $use(drawable) y $min]
	    set tmax [Translate $use(drawable) y $max]
	    if {$use(location) == ""} {
		set x [Translate $use(drawable) x [DrawableGet $use(drawable) xmin]]
	    } else {
		set x [Translate $use(drawable) x $use(location)]
	    }
	    PsLine -coord "$x [expr $tmin-$extend(0)] : $x [expr $tmax+$extend(1)]" \
		-linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)
	} 
	default {
	    Abort "Axis: bad axis specification ($use(axis))"
	}
    }
    # DEBUG -- draw bounding box too (for testing)
    # PsLine -coord 0,0:0,239:299,239:299,0 -closepath t -linecolor black -linewidth 1
}

proc parseLabel {urange ustep ulabel label__ labelcnt__} {
    upvar $label__ label
    upvar $labelcnt__ labelcnt

    # get range info
    if {$ulabel == ""} {
	# use must have specified range and step
	set count [ArgsParseNumbers $urange range]
	AssertEqual $count 2
	set min $range(0)
	set max $range(1)
	set step $ustep

	set labelstr "$min,$min"
	for {set i [expr $min+$step]} {$i <= $max} {set i [expr $i + $step]} {
	    set labelstr "$labelstr : $i,$i"
	}
    } else {
	# manual: needs to be in usual number list form
	set labelstr $ulabel
    }

    # pull labels out of labelstr (numeric,label)
    set labelcnt [ArgsParseNumbersList $labelstr label]
    AssertNotEqual $labelcnt -1
}

proc TicLabels {args} {
    set default {
	{"drawable"  "root"         "the drawable"}
	{"axis"      "x"            "x or y axis"}
	{"range"     ""             "start tics at n1, end at n2"}
	{"step"      ""             "space between tic marks"}
	{"label"     ""             "empty: use range,step; else, list like this 'x1,label:x2,label:...'"}
	{"rotate"    "0"            "rotation of labels"}
	{"font"      "Helvetica"    "font to use (if any)"}
	{"fontsize"  "10"           "font size of labels (if any)"}
	{"fontcolor" "black"        "font color"}
	{"offset"    "0"            "offset in units from 0-value location for axis"}
	{"ticsize"   "4"            "size of tics on the axis where these labels are being placed"}
	{"yshift"    "0"            "offset in pts of text (y axis)"}
	{"xshift"    "0"            "offset in pts of text (x axis)"}
    }
    ArgsProcessWithDashArgs TicLabels default args use \
	"Use this to label the tic marks along a particular axis." 
    AssertEqual [psCanvasDefined] 1

    # do this
    parseLabel $use(range) $use(step) $use(label) label labelcnt

    switch -exact $use(axis) {
	x {
	    # take 0 value of other axis (e.g., y0 for x axis), add offset, subtract ticsize
	    set ybase  [expr [DrawableGet $use(drawable) ymin] + $use(offset)]
	    set tybase [Translate $use(drawable) y $ybase]
	    set y      [expr  $tybase - $use(ticsize) + $use(yshift)]

	    # compute vshift, anchors, etc.
	    set xshift 0.0
	    set yshift [expr -$use(fontsize)]
	    set anchor c

	    if {$use(rotate) == 90} {
		set xshift [expr 0.36 * $use(fontsize)] ;# .36: a magic adjustment to center text 
		set yshift -2.0
		set anchor r
	    }

	    # draw labels
	    for {set i 0} {$i < $labelcnt} {incr i} {
		set x  [expr double($label($i,n1))]
		set tx [expr [Translate $use(drawable) x $x] + $use(xshift) + $xshift]
		set ty [expr $y + $yshift]
		set labelstr $label($i,n2)
		PsText -coord $tx,$ty -text $labelstr -size $use(fontsize) \
		    -font $use(font) -color $use(fontcolor) -anchor $anchor -rotate $use(rotate) 
	    }
	}
	y {
	    # take 0 value of other axis (e.g., y0 for x axis), add offset, subtract ticsize
	    set xbase  [expr [DrawableGet $use(drawable) xmin] + $use(offset)]
	    set txbase [Translate $use(drawable) x $xbase]
	    set x      [expr $txbase - $use(ticsize) + $use(xshift)]

	    set xshift -2.0
	    set yshift [expr -0.36 * $use(fontsize)] ;# .36: a magic adjustment to center text 
	    set anchor r

	    if {$use(rotate) == 90} {
		set xshift -2.0
		set yshift 0.0
		set anchor c
	    }

	    for {set i 0} {$i < $labelcnt} {incr i} {
		set y [expr double($label($i,n1))]
		set ty [expr [Translate $use(drawable) y $y] + $use(yshift) + $yshift]
		set tx [expr $x + $xshift]
		set labelstr $label($i,n2)
		PsText -coord $tx,$ty -text $labelstr -size $use(fontsize) \
		    -font $use(font) -color $use(fontcolor) -anchor $anchor -rotate $use(rotate) 
	    }
	}
	default {
	    Abort "bad axis: $use(axis)"
	}
    }
}

proc TicMarks {args} {
    set default {
	{"drawable"      "root"         "the drawable"}
	{"axis"          "x"            "which direction, x or y?"}
	{"range"         ""             "start tics at n1, end at n2"}
	{"step"          ""             "space between tic marks"}
	{"ticsize"       "4"            "size of tics (4 for major, 2 for minor)"}
	{"offset"        "0"            "offset from default location for axis"}
	{"anchor"        "low"          "should tics be on 'low', 'high', or 'middle' "}
	{"linecolor"     "black"        "color of tic marks"}
	{"linewidth"     "1"            "width of tic marks"}
	{"extend"        "0.5"          "extend tic this much onto axis it is on"}
    }
    ArgsProcessWithDashArgs TicMarks default args use ""
    AssertEqual [psCanvasDefined] 1

    # what is opposite axis?
    set otherAxis [getOppositeAxis $use(axis)]

    # parse inside, outside, or middle marks
    set axisMin [DrawableGet $use(drawable) ${otherAxis}min]
    set base [expr $axisMin + $use(offset)]
    set pts  [Translate $use(drawable) $otherAxis $base]

    # puts "% DEBUG TicMarks :: [ArgsPrint use]"
    if {$use(range) == ""} {
	set min [DrawableGet $use(drawable) $use(axis)min]
	set max [DrawableGet $use(drawable) $use(axis)max]
    } else {
	# get range info
	set count [ArgsParseNumbers $use(range) range]
	AssertEqual $count 2
	set min $range(0)
	set max $range(1)
	set step $use(step)
    }
    
    switch -exact $use(anchor) {
	low { 
	    set p0 [expr $pts + $use(extend)]
	    set p1 [expr $pts - $use(ticsize)]
	}
	high {
	    set p0 [expr $pts + $use(ticsize)] 
	    set p1 [expr $pts - $use(extend)]
	}
	middle { 
	    set adjust [expr $use(ticsize) / 2.0]
	    set p0 [expr $pts + $adjust]
	    set p1 [expr $pts - $adjust]
	}
	default { 
	    Abort "bad anchor: $use(anchor), use low, high, middle" 
	}
    }

    for {set val $min} {$val <= $max} {set val [expr $val + $step]} {
	set fixed [Translate $use(drawable) $use(axis) $val]
	switch -exact $use(axis) {
	    x { PsLine -coord $fixed,$p0:$fixed,$p1 -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    y { PsLine -coord $p0,$fixed:$p1,$fixed -linecolor $use(linecolor) -linewidth $use(linewidth) }
	}
    }
}



