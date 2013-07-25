# tcl

proc TicMarksX {args} {
    set default {
	{"drawable"  "default"      "the drawable"}
	{"tics"      ""             "n1,n2,step, e.g., 0,10,2 means 0 to 10 tics, by 2s"}
	{"ticsize"   "4"            "size of tics (4 for major, 2 for minor)"}
	{"offset"    "0"            "y-value offset from default location for axis (y=0)"}
	{"anchor"    "low"          "should tics be 'lower', 'higher', or 'middle' (along the axis line)"}
	{"linecolor" "black"        "color of tic marks"}
    }
    ArgsProcessWithDashArgs TicMarksX default args use ""

    # get tic info
    parseTics $use(tics) min max step

    # parse inside, outside, or middle marks
    set y0pts [expr [DrawableGet $use(drawable) y0] + [ScaleY $use(drawable) $use(offset)]]
    switch -exact $use(anchor) {
	low {
	    set y0 [expr $y0pts + 0.5]
	    set y1 [expr $y0pts - $use(ticsize)]
	}
	high {
	    set y0 [expr $y0pts + $use(ticsize)] 
	    set y1 [expr $y0pts - 0.5]
	}
	middle { 
	    set adjust [expr $use(ticsize) / 2.0]
	    set y0 [expr $y0pts + $adjust]
	    set y1 [expr $y0pts - $adjust]
	}
	default { 
	    Abort "bad anchor: $use(anchor)" 
	}
    }

    for {set x $min} {$x <= $max} {set x [expr $x + $step]} {
	set tx [TranslateX $use(drawable) $x]
	PsLine -coord $tx,$y0:$tx,$y1 -linecolor $use(linecolor)
    }
}




    } elseif {[StringEq $use(axis) "y"]} {
	set x0 [expr [DrawableGet $use(drawable) x0] + [ScaleX $use(drawable) $use(ticoffset)]]
	set x1 [expr $x0 - $use(ticsize)]

	if {$use(tics) != ""} {
	    for {set y $min} {$y <= $max} {set y [expr $y + $step]} {
		set ty [TranslateY $use(drawable) $y]
		PsLine -coord [expr $x0+0.5],$ty:$x1,$ty -linecolor black
	    }
	}

	# now labels
	if {$labelstr != ""} {
	    for {set i 0} {$i < $labelcnt} {incr i} {
		set y [expr double($label($i,n1))]
		set labelstr $label($i,n2)
		set ty [TranslateY $use(drawable) $y]
		set xtmp [expr $x0 - $use(ticsize) - $use(ytextoff)]
		set ytmp [expr $ty - ($use(fontsize) * $use(magic))]  ;# see note below
		# note: 0.35 is a magic number that empirically works (for Helvetica)
		# is there a better way to get this number? (e.g., in postscript)
		PsText -coord $xtmp,$ytmp -text $labelstr -size $use(fontsize) -font $use(font) -color $use(fontcolor) -anchor r -rotate $use(rotate) 
	    }
	}
    } else {
	Abort "Bad axis ($use(axis)); should be x or y"
    }
