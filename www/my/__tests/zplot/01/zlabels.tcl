# tcl

proc Title {args} {
    set default {
	{"placement" "center" "center,left,right,manual"}
	{"text"      ""       "title of the graph"}
	{"x"         "0"      "with manual placement, use this as x location"}
	{"y"         "0"      "with manual placement, use this as y location"}
    }
    ArgsProcessWithDashArgs Title default args use

    global _d

    # xxx - needs more work
    set x [expr ($_d(dwidth)/2.0) + $_d(x0)]
    set y [expr $_d(dheight) + $_d(y0) + 15.0 ]
    
    if {[string compare $use(placement) "manual"] == 0} {
	set x $use(x)
	set y $use(y)
    }

    RawText -coord $x,$y -text $use(text) -size 12 
}

proc Label {args} {
    set default {
	{"text"      ""       "title of the graph"}
	{"style"     "x"      "x label, y label, right y label, etc."}
    }
    ArgsProcessWithDashArgs Label default args use

    global _d

    if {[seq $use(style) "y"]} {
	set x [expr 10.0]
	set y [expr ($_d(dheight)/2.0) + $_d(y0)]
	set r 90
    } else {
	set x [expr ($_d(dwidth)/2.0) + $_d(x0)]
	set y [expr 5.0]
	set r 0
    }

    RawText -coord $x,$y -text $use(text) -rotate $r -anchor c
}


