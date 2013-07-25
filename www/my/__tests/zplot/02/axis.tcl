# tcl

proc Axis {args} {
    set default {
	{"drawable"   "default"  "the relevant drawable"}
	{"axis"       "x"        "x or y axis"}
	{"range"      ""         "min and max values to draw line between, empty means do whole range"}
	{"linecolor"  "black"    "color of axis line"}
	{"linewidth"  "1"        "width of axis line"}
	{"dash"       ""         "dash parameters"}
	{"offset"     "n"        "n or p, with n meaning 'left' or 'bottom', and p meaning 'right' or 'top', depending on x or y axis"}
    }
    ArgsProcessWithDashArgs Axis default args use ""

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

    if {[StringEq $use(axis) "x"]} {
	set min [TranslateX $use(drawable) $min]
	set max [TranslateX $use(drawable) $max]
	if {[StringEq $use(offset) "n"]} {
	    set y [TranslateY $use(drawable) 0.0]
	} else {
	    set y [TranslateY $use(drawable) [DrawableGet $use(drawable) ymax]]
	}
	PsLine -coord "[expr $min-0.5] $y : [expr $max+0.5] $y" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)
    } else {
	set min [TranslateY $use(drawable) $min]
	set max [TranslateY $use(drawable) $max]
	if {[StringEq $use(offset) "n"]} {
	    set x [TranslateX $use(drawable) 0.0]
	} else {
	    set x [TranslateX $use(drawable) [DrawableGet $use(drawable) xmax]]
	}
	PsLine -coord "$x [expr $min-0.5] : $x [expr $max+0.5]" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth) -dash $use(dash)

    }

    # DEBUG -- draw bounding box too (for testing)
    # PsLine -coord 0,0:0,239:299,239:299,0 -closepath t -linecolor black -linewidth 1
}

proc Tics {args} {
    set default {
	{"drawable"  "default"      "the drawable"}
	{"xmajor"    ""             "x major tics, auto?"}
    }
    ArgsProcessWithDashArgs Tics 

    TicMarksX -tics 0,6,1 
    TicMarksX -tics 0,6,0.25 -ticsize 2 
    TicMarksY -tics -10,25,5 

}

proc parseTics {ticsarg min__ max__ step__} {
    upvar $min__  min
    upvar $max__  max
    upvar $step__ step

    if {$ticsarg != ""} {
	set cnt [ArgsParseNumbers $ticsarg tics]
	AssertEqual $cnt 3
	set min  $tics(0)
	set max  $tics(1)
	set step $tics(2)
    } else {
	Abort "Need tic marks, didn't get any"
    }
}

proc getOppositeAxis {axis} {
    switch -exact $axis {
	x {return y}
	y {return x}
    }
    Abort "bad axis: $axis" 
}


proc TicLabels {args} {
    set default {
	{"drawable"  "default"      "the drawable"}
	{"axis"      "x"            "axis: x or y"}
	{"range"     ""             "start tics at n1, end at n2"}
	{"step"      ""             "space between tic marks"}
	{"label"     ""             "empty: use range,step; else, list like this 'x1,label:x2,label:...'"}
	{"rotate"    "0"            "rotation of labels"}
	{"font"      "Helvetica"    "font to use (if any)"}
	{"fontsize"  "10"           "font size of labels (if any)"}
	{"fontcolor" "black"        "font color"}
	{"offset"    "0"            "offset in units from 0-value location for axis"}
	{"yshift"    "0"            "offset in pts of text (y axis)"}
	{"xshift"    "0"            "offset in pts of text (x axis)"}
	{"ticsize"   "4"            "size of tics beneath axis"}
    }
    ArgsProcessWithDashArgs TicLabels default args use \
	"Use this to label the tic marks along a particular axis." 

    # get range info
    if {$use(label) == ""} {
	# use must have specified range and step
	set count [ArgsParseNumbers $use(range) range]
	AssertEqual $count 2
	set min $range(0)
	set max $range(1)
	set step $use(step)

	set labelstr "$min,$min"
	for {set i [expr $min+$step]} {$i <= $max} {set i [expr $i + $step]} {
	    set labelstr "$labelstr : $i,$i"
	}
    } else {
	# manual: needs to be in usual number list form
	set labelstr $use(label)
    }

    # pull labels out of labelstr (numeric,label)
    set labelcnt [ArgsParseNumbersList $labelstr label]
    AssertNotEqual $labelcnt -1

    # what is opposite axis?
    set otherAxis [getOppositeAxis $use(axis)]

    # take 0 value of other axis (e.g., y0 for x axis), add offset, subtract ticsize
    set otherVal [expr [DrawableGet $use(drawable) ${otherAxis}0] + \
		  [Scale $use(drawable) $use(axis) $use(offset)] - $use(ticsize)]

    for {set i 0} {$i < $labelcnt} {incr i} {
	set val  [expr double($label($i,n1))]
	set tVal [Translate $use(drawable) $use(axis) $val]
	set labelstr $label($i,n2)
	switch -exact $use(axis) {
	    x { set tOtherVal [expr $otherVal - $use(fontsize)]
		PsText -coord $tVal,$tOtherVal -text $labelstr -size $use(fontsize) -font $use(font) -color $use(fontcolor) -anchor c -rotate $use(rotate) } 
	    y { set tVal [expr $tVal - (0.3 * $use(fontsize))] ;# this is a magic adjustment for yshift
		set tOtherVal [expr $otherVal - 2]
		PsText -coord $tOtherVal,$tVal -text $labelstr -size $use(fontsize) -font $use(font) -color $use(fontcolor) -anchor r -rotate $use(rotate) } 
	}
	
    }
}

proc TicMarks {args} {
    set default {
	{"drawable"  "default"      "the drawable"}
	{"axis"      "x"            "which direction, x or y?"}
	{"range"     ""             "start tics at n1, end at n2"}
	{"step"      ""             "space between tic marks"}
	{"ticsize"   "4"            "size of tics (4 for major, 2 for minor)"}
	{"offset"    "0"            "offset from default location for axis"}
	{"anchor"    "low"          "should tics be on 'low', 'high', or 'middle' "}
	{"linecolor" "black"        "color of tic marks"}
	{"linewidth" "1"            "width of tic marks"}
    }
    ArgsProcessWithDashArgs TicMarks default args use ""

    # get range info
    set count [ArgsParseNumbers $use(range) range]
    AssertEqual $count 2
    set min $range(0)
    set max $range(1)
    set step $use(step)
    
    # what is opposite axis?
    set otherAxis [getOppositeAxis $use(axis)]

    # parse inside, outside, or middle marks
    set pts [expr [DrawableGet $use(drawable) ${otherAxis}0] + \
 		  [Scale $use(drawable) $otherAxis $use(offset)]]
    switch -exact $use(anchor) {
	low { 
	    set p0 [expr $pts + 0.5]
	    set p1 [expr $pts - $use(ticsize)]
	}
	high {
	    set p0 [expr $pts + $use(ticsize)] 
	    set p1 [expr $pts - 0.5]
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



