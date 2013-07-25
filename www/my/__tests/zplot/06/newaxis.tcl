# tcl

proc isThisAnInt {value} {
    set nvalue [expr double(int($value))]
    if {$nvalue == $value} {
	return 1
    }
    return 0
}

proc findMajorStep {drawable axis min max} {
    set scaleType [DrawableGetScaleType $drawable $axis] 
    if [StringEqual $scaleType "category"] {
	return 1
    }
    set ticsPerInch 3.5 ;# xxx pretty random here too
    set width [expr [DrawableGetWidth $drawable ${axis}] / 72.0]
    set tics  [expr $width * $ticsPerInch]
    set step  [expr 1 + int(($max - $min) / $tics)]
    # puts stderr "findstep: d:$drawable axis:$axis min,max:$min,$max :: width:[format %.2f $width] tics:[format %.2f $tics] guess: [format %.2f $step]"
    return $step
}

proc getOppositeAxis {axis} {
    switch -exact $axis {
	x {return y}
	y {return x}
    }
    Abort "bad axis: $axis" 
}

# fill in:
#   labelbox(x,xlo)
#   labelbox(x,xhi)
#   labelbox(x,ylo)
#   labelbox(x,yhi)
# and same for y,*
proc recordLabel {use__ labelbox__ axis x y label font fontsize anchor rotate} {
    upvar $use__      use
    upvar $labelbox__ labelbox

    # height and width
    set height $use(fontsize)
    set width  [psGetStringWidth $label $fontsize]

    # get anchors
    set count [ArgsParseCommaList $anchor a]
    if {$count == 2} {
	set xanchor $a(0)
	set yanchor $a(1)
    } elseif {$count == 1} {
	set xanchor $a(0)
	set yanchor l
    } else {
	Abort "Bad anchor: $anchor"
    }

    # XXX deal with rotation XXX
    
    # now, find bounding box 
    switch -exact $xanchor {
	l { set v(xlo) [expr $x] }
	c { set v(xlo) [expr $x - ($width/2.0)] }
	r { set v(xlo) [expr $x - $width] }
    }
    switch -exact $yanchor {
	l { set v(ylo) [expr $y] }
	c { set v(ylo) [expr $y - ($height/2.0)] }
	h { set v(ylo) [expr $y - $height] }
    }
    set v(xhi) [expr $v(xlo) + $width]
    set v(yhi) [expr $v(ylo) + $height]

    # PsLine -coord "$v(xlo),$v(ylo) : $v(xlo),$v(yhi) : $v(xhi),$v(yhi) : $v(xhi),$v(ylo)" -closepath t -linecolor yellowgreen

    if [info exists labelbox($axis,xlo)] {
	foreach value {xlo ylo} {
	    if {$v($value) < $labelbox($axis,$value)} {
		set labelbox($axis,$value) $v($value)
	    }
	}
	foreach value {xhi yhi} {
	    if {$v($value) > $labelbox($axis,$value)} {
		set labelbox($axis,$value) $v($value)
	    }
	}
    } else {
	foreach value {xlo xhi ylo yhi} {
	    set labelbox($axis,$value) $v($value)
	}
    }

    # PsBox -coord "$labelbox($axis,xlo),$labelbox($axis,ylo) : $labelbox($axis,xhi),$labelbox($axis,yhi)" -linecolor red -linewidth 0.25
}

# lots of guesses as to where xtitle, ytitle, and overall title will go
# these will later get adjusted by doLabels and doTics, so as to avoid
# the problem of writing the titles over the labels and tics (surprise)
proc doTitleInit {use__ title__ labelbox__ t__} {
    upvar $use__      use
    upvar $title__    title
    upvar $labelbox__ labelbox
    upvar $t__        t

    # some space between titles and the nearest text to them; 3 is randomly chosen
    set offset 3.0

    if {$use(title) != ""} {
	set title(title,y) [expr $t(yrange,max) + $offset]
	# XXX: if the xtitle exists, and its labelstyle is 'in', and it is high enough
	#      it may run into the title, then what?
	switch -exact $use(titleplace) {
	    c {
		set title(title,x)      [expr ($t(xrange,min) + $t(xrange,max)) / 2.0]
		set title(title,anchor) c,l
	    }
	    l {
		set title(title,x)      [expr $t(xrange,min) + $offset]
		set title(title,anchor) l,l
	    }
	    r {
		set title(title,x)      [expr $t(xrange,max) - $offset]
		set title(title,anchor) r,l
	    }
	    default { Abort "Bad titleanchor: Must be c, l, or r" }
	}
	# allow user override of this option, of course
	if {$use(titleanchor) != ""} {
	    set title(title,anchor) $use(titleanchor)
	}
    }

    if {$use(ytitle) != ""} {
	switch -exact $use(labelstyle) {
	    in  { 
		set title(ytitle,x) [expr $t(yaxis,pos) + $offset]
		set yanchor         h
	    }
	    out { 
		set title(ytitle,x) [expr $t(yaxis,pos) - $offset]
		set yanchor         l
	    }
	    default { Abort "bad labelstyle" }
	}
	
	switch -exact $use(ytitleplace) {
	    c {
		set title(ytitle,y)      [expr ($t(yrange,max) + $t(yrange,min)) / 2.0] 
		set xanchor              c
	    }
	    l {
		set title(ytitle,y)      [expr $t(yrange,min) + $offset]
		set xanchor              l
	    }
	    u {
		set title(ytitle,y)      [expr $t(yrange,max) - $offset]
		set xanchor              r
	    }
	    default { Abort "Bad titleanchor: Must be c, l, or u" }
	}
	# allow user override of this option, of course
	if {$use(ytitleanchor) != ""} {
	    set title(ytitle,anchor) $use(ytitleanchor)
	} else {
	    set title(ytitle,anchor) $xanchor,$yanchor
	}

	# try to move ytitle based on labelbox(y,*)
	if [True $use(labels)] {
	    if [StringEqual $use(labelstyle) out] {
		if {($title(ytitle,x) >= $labelbox(y,xlo))} {
		    set title(ytitle,x) [expr $labelbox(y,xlo) - $offset]
		}
	    } 
	    if [StringEqual $use(labelstyle) in] {
		if {($title(ytitle,x) <= $labelbox(y,xhi))} {
		    set title(ytitle,x) [expr $labelbox(y,xhi) + $offset]
		}
	    } 
	}
    }

    if {$use(xtitle) != ""} {
	switch -exact $use(labelstyle) {
	    in  { 
		set title(xtitle,y) [expr $t(xaxis,pos) + $offset]
		set yanchor         l
	    }
	    out { 
		set title(xtitle,y) [expr $t(xaxis,pos) - $offset]
		set yanchor         h
	    }
	    default { Abort "bad labelstyle" }
	}

	switch -exact $use(xtitleplace) {
	    c {
		set title(xtitle,x)      [expr ($t(xrange,min) + $t(xrange,max)) / 2.0]
		set xanchor              c
	    }
	    l {
		set title(xtitle,x)      [expr $t(xrange,min) + $offset]
		set xanchor              l
	    }
	    r {
		set title(xtitle,x)      [expr $t(xrange,max) - $offset]
		set xanchor              r
	    }
	    default { Abort "Bad titleanchor: Must be c, l, or r" }
	}
	# allow user override of this option, of course
	if {$use(xtitleanchor) != ""} {
	    set title(xtitle,anchor) $use(xtitleanchor)
	} else {
	    set title(xtitle,anchor) $xanchor,$yanchor
	}

	if [True $use(labels)] {
	    if {($title(xtitle,y) >= $labelbox(x,ylo))} {
		set title(xtitle,y) [expr $labelbox(x,ylo) - $offset]
	    }
	}
    }
}

proc doTitleFini {use__ title__ labelbox__ t__} {
    upvar $use__      use
    upvar $title__    title
    upvar $labelbox__ labelbox
    upvar $t__        t

    # finish up
    if {$use(title) != ""} {
	set count [ArgsParseCommaList $use(titleshift) shift]
	AssertEqual $count 2
	PsText -coord [expr $shift(0)+$title(title,x)],[expr $shift(1)+$title(title,y)] -text $use(title) \
	    -font $use(titlefont) -size $use(titlesize) -color $use(titlecolor) \
	    -anchor $title(title,anchor) -bgcolor $use(titlebgcolor) -rotate $use(titlerotate)
    }

    if {$use(ytitle) != ""} {
	set count [ArgsParseCommaList $use(ytitleshift) shift]
	AssertEqual $count 2
	PsText -coord [expr $shift(0)+$title(ytitle,x)],[expr $shift(1)+$title(ytitle,y)] -text $use(ytitle) \
	    -font $use(ytitlefont) -size $use(ytitlesize) -color $use(ytitlecolor) \
	    -anchor $title(ytitle,anchor) -bgcolor $use(ytitlebgcolor) -rotate $use(ytitlerotate)
    }

    if {$use(xtitle) != ""} {
	set count [ArgsParseCommaList $use(xtitleshift) shift]
	AssertEqual $count 2
	PsText -coord [expr $shift(0)+$title(xtitle,x)],[expr $shift(1)+$title(xtitle,y)] -text $use(xtitle) \
	    -font $use(xtitlefont) -size $use(xtitlesize) -color $use(xtitlecolor) \
	    -anchor $title(xtitle,anchor) -bgcolor $use(xtitlebgcolor) -rotate $use(xtitlerotate)
    }
}

proc doTitle  {use__ labelbox__ t__} {
    upvar $use__      use
    upvar $labelbox__ labelbox
    upvar $t__        t

    doTitleInit use title labelbox t
    doTitleFini use title labelbox t
}

# this pulls everything out into a usable format
proc doUnpackDescription {use__ axis labels__ rangemin rangemax} {
    upvar $use__    use
    upvar $labels__ labels

    # pull out vars that are axis dependent (why, well, just to make the code a little more readable)
    set uauto   $use(${axis}auto)
    set umanual $use(${axis}manual)
    set uformat $use(${axis}labelformat)
    set utimes  $use(${axis}labeltimes)

    # now, unpack label and tic info
    if {$umanual != ""} {
	# if manual is not empty, use it (override auto)
	set labels(cnt) [ArgsParseItemPairList $umanual labels]
    } else {
	# manual is empty --> use auto description
	set count [ArgsParseCommaList $uauto auto]
	AssertEqual $count 3
	# expecting min, max, step
	if {$auto(0) == ""} {
	    set r(label,min) $rangemin
	} else {
	    set r(label,min) $auto(0)
	}

	if {$auto(1) == ""} {
	    set r(label,max) $rangemax
	} else {
	    set r(label,max) $auto(1)
	}

	if {$auto(2) == ""} {
	    # XXX ;# this assumes that rangemin, max are linear values, whereas they MIGHT NOT BE
	    # more proper to: take virtual values, map them to linear, figure out what to do then
	    set r(label,step) [findMajorStep $use(drawable) $axis $rangemin $rangemax]
	} else {
	    set r(label,step) $auto(2)
	}

	# here, we are supposed to figure out how to format the labels on the axis
	# challenge: may be one of many types
	# right now, base on scale type:
	#   if category --> use %s
	#   if anything else --> figure out if %d makes sense, otherwise use %f
	if {$uformat == ""} {
	    # XXX have to do different things depending on the scaleType
	    set scaleType [DrawableGetScaleType $use(drawable) $axis] 
	    if [StringEqual $scaleType "category"] {
		set uformat "%s"
	    } else {
		# this means we have to guess; is it an integer, or a float?
		set test 0
		foreach v "min max step" {
		    if {! [isThisAnInt [expr $utimes * $r(label,$v)]]} {
			incr test
		    }
		}
		if {$test > 0} {
		    # if it's a float, how many decimal points do we need?
		    # XXX -- need to better compute how many XXX we need
		    set uformat "%.1f"
		} else {
		    set uformat "%i"
		}
	    }
	}
	
	# fill in array 'labels' with (n1=position,n2=label) pairs
	# these are used by doTics and doLabels to draw tics and labels at the specified spots
	set i     0
	set scale [DrawableGetScaleType $use(drawable) $axis]
	foreach v [DrawableGetRangeIterator $use(drawable) $axis $r(label,min) $r(label,max) $r(label,step)] {
	    # DrawableGetRangeIterator returns a set of virtual positions
	    set labels($i,n1) $v

	    # label: treat category type different than other numerical types (e.g., no multiply by u(xtimes) or u(ytimes) field)
	    if [StringEqual $scale "category"] {
		# category type: should NOT multiply by umul
		set labels($i,n2) [format $uformat $v]
	    } else {
		# here, look for %i or %d 
		# if you see it, cast result with int(), otherwise just take in raw form
		#   (otherwise, if you say try to print a float (like 3.34) as a %d, Tcl will barf)
		set uformatptr [string index $uformat [expr [string length $uformat] - 1]]
		if {[StringEqual $uformatptr "d"] || [StringEqual $uformatptr "i"]} {
		    set labels($i,n2) [format $uformat [expr int($v * $utimes)]]
		} else {
		    set labels($i,n2) [format $uformat [expr ($v * $utimes)]]
		}
	    }

	    # i is the index into the labels array, hence important
	    incr i
	}
	set labels(cnt) $i
    }
}

proc toggleStyle {style} {
    if [StringEqual $style "in"] {
	return "out"
    } elseif [StringEqual $style "out"] {
	return "in"
    } else {
	return "centered"
    }
}


proc doLabels {use__ labels__ axis axispos ticstyle labelbox__} {
    upvar $use__      use
    upvar $labels__   labels
    upvar $labelbox__ labelbox

    # how much space between fonts and tics, basically
    set offset 3.0 

    # set t(pt) to the place where labels should be drawn
    #   for yaxis, this is the x position of the labels
    #   for xaxis, this is the y position of the labels
    # t(pt) thus does not changed and is used to draw each of the labels
    if [StringEqual $use(labelstyle) "out"] {
	set xanchor c,h
	set yanchor r,c
	switch -exact $ticstyle {
	    in       { set t(pt) [expr $axispos - $offset] }
	    out      { set t(pt) [expr $axispos - $use(ticmajorsize) - $offset] }
	    centered { set t(pt) [expr $axispos - ($use(ticmajorsize)/2.0) - $offset] }
	}
    }
    if [StringEqual $use(labelstyle) "in"] {
	set xanchor c,l
	set yanchor l,c
	switch -exact $ticstyle {
	    in       { set t(pt) [expr $axispos + $use(ticmajorsize) + $offset] }
	    out      { set t(pt) [expr $axispos + $offset] }
	    centered { set t(pt) [expr $axispos + ($use(ticmajorsize)/2.0) + $offset] }
	}
    }

    # allow intelligent override, otherwise provide solid guess as to label placement
    if {$use(xlabelanchor) == ""} {
	set use(xlabelanchor) $xanchor
    }
    if {$use(ylabelanchor) == ""} {
	set use(ylabelanchor) $yanchor
    }

    # draw the labels
    for {set i 0} {$i < $labels(cnt)} {incr i} {
	set label $labels($i,n2)
	
	# see if this is an "empty" label; if so, don't draw it
	set index [string compare -length [string length [drawableGetEmptyMarker]] $label [drawableGetEmptyMarker]]
	if {$index == 0} {
	    # this is an empty label, thus do not draw to screen
	    set label ""
	}

	set v     $labels($i,n1)
	set t(v)  [Translate $use(drawable) $axis $v]
	switch -exact $axis {
	    x { 
		set count [ArgsParseCommaList $use(xlabelshift) shift]
		AssertEqual $count 2
		set x [expr $t(v)+$shift(0)]
		set y [expr $t(pt)+$shift(1)]
		PsText -coord $x,$y -text "$label" \
		    -font $use(font) -size $use(fontsize) -color $use(fontcolor) \
		    -anchor $use(xlabelanchor) -rotate $use(xlabelrotate) -bgcolor $use(xlabelbgcolor)

		# record where text is s.t. later title positions are properly placed 
		recordLabel use labelbox x $x $y $label $use(font) $use(fontsize) $use(xlabelanchor) $use(xlabelrotate)
	    }
	    y {
		set count [ArgsParseCommaList $use(ylabelshift) shift]
		AssertEqual $count 2
		set x [expr $t(pt)+$shift(0)]
		set y [expr $t(v)+$shift(1)]
		PsText -coord $x,$y -text "$label" \
		    -font $use(font) -size $use(fontsize) -color $use(fontcolor) \
		    -anchor $use(ylabelanchor) -rotate $use(ylabelrotate) -bgcolor $use(ylabelbgcolor)

		# record where text is s.t. later title positions are properly placed 
		recordLabel use labelbox y $x $y $label $use(font) $use(fontsize) $use(ylabelanchor) $use(ylabelrotate)
	    }
	}
    }
}


proc doTics {use__ labels__ axis axispos ticstyle ticsize title__} {
    upvar $use__    use
    upvar $labels__ labels
    upvar $title__  title

    # calculate disposition of tics based on user preference
    switch -exact $ticstyle {
	in {
	    set t(hi) [expr $axispos + $ticsize]
	    set t(lo) $axispos
	}
	out {
	    set t(hi) $axispos
	    set t(lo) [expr $axispos - $ticsize]
	}
	centered {
	    set t(hi) [expr $axispos + ($ticsize/2.0)]
	    set t(lo) [expr $axispos - ($ticsize/2.0)]
	}
    }

    # draw the tic marks AT EACH LABEL in labels array
    for {set i 0} {$i < $labels(cnt)} {incr i} {
	set v    $labels($i,n1)
	set t(v) [Translate $use(drawable) $axis $v]
	switch -exact $axis {
	    x { 
		PsLine -coord "$t(v),$t(lo):$t(v),$t(hi)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    y {
		PsLine -coord "$t(lo),$t(v):$t(hi),$t(v)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	}
    }
}

proc AxesTicsLabels {args} {
    set default {
	{"drawable"      "default"    "the relevant drawable"}

	{"linecolor"     "black"      "color of axis line"}
	{"linewidth"     "1"          "width of axis line"}
	{"linedash"      "0"          "dash parameters; will make axes dashed, but not tic marks"}

	{"style"         "xy"         "which axes to draw: 'xy', 'x', 'y', 'box' are options"}
	{"labelstyle"    "out"        "are labels 'in' or 'out'? for xaxis, 'out' means below/'in' above; for yaxis, 'out' means left/'in' right"}
	{"ticstyle"      "out"        "are tics 'in', 'out', or 'centered'? (inside the axes, outside the axes, or centered upon the axes)"}

	{"axis"          "true"       "whether to draw the actual axes or not"}
	{"labels"        "true"       "whether to put labels on or not; useful to set to false, for example, when "}
	{"majortics"     "true"       "whether to put majortics on axes or not"}
	{"minortics"     "false"      "whether to put minortics on axes or not"}

	{"xaxisrange"    ""           "min and max values to draw xaxis between; empty means whole range"}
	{"yaxisrange"    ""           "min and max values to draw yaxis between; empty means whole range"}
	{"xaxisposition" ""           "which y value x-axis is located at; if empty, min of range; ignored by 'box' style"}
	{"yaxisposition" ""           "which x value y-axis is located at; if empty, min of range; ignored by 'box' style"}

	{"xauto"         ",,"         "'x1,x2,step' (will put labels and major tics from x1 to x2 with step between each); can leave any of these empty and the routine will fill in a guess (either the min or max of the range, or a guess for the step), e.g., 0,,2 means start at 0, fill in the max of the xrange for a max value, and set the step to 2. The default is to guess all of these values"}
	{"xmanual"       ""           "just specify location of labels/major tics all by hand with a list of form: 'x1,label1:x2,label2:...'"}
	{"yauto"         ",,"         "similar to xauto, but for the yaxis"}
	{"ymanual"       ""           "similar to xmanual, but for the yaxis"}

	{"ticmajorsize"  "4"          "size of the major tics"}
	{"ticminorsize"  "2.5"        "size of the minor tics"}

	{"xticminorcnt"  "2"          "how many minor tics per major tic (x axis)"}
	{"yticminorcnt"  "2"          "how many minor tics per major tic (y axis)"}

	{"font"          "Helvetica"  "font to use (if any)"}
	{"fontsize"      "10"         "font size of labels (if any)"}
	{"fontcolor"     "black"      "font color"}

	{"xlabelbgcolor"  ""           "if non-empty, put a background colored square behind the xlabels"}
	{"ylabelbgcolor"  ""           "just like xbgcolor, but for ylabels"}

	{"xlabelrotate"   "0"          "use specified rotation for x labels"}
	{"ylabelrotate"   "0"          "use specified rotation for y labels"}

	{"xlabelanchor"   ""           "text anchor for labels along the x axis; empty means routine should guess"}
	{"ylabelanchor"   ""           "same as xanchor, but for labels along the y axis"}

	{"xlabelformat"   ""           "format string to use for xlabels; e.g., %i or %d for integers, %f for floats, %.1f for floats with one decimal point, etc.; empty (the default) implies the routine's best guess; can also use this to add decoration to the label, e.g., '%i %%' will add a percent sign to each integer label, and so forth"}
	{"ylabelformat"   ""           "similar to xformat, but for ylabels"}

	{"xlabeltimes"   "1"          "what to multiple xlabel by; e.g., if 10, 1->10, 2->20, etc., if 0.1, 1->0.1, etc."}
	{"ylabeltimes"   "1"          "similar to xmul, but for ylabels"}

	{"xlabelshift"   "0,0"        "shift xlabels left/right, up/down (e.g., +4,-3 -> shift right 4, shift down 3)"}
	{"ylabelshift"   "0,0"        "similar to xshift, but for ylabels"}

	{"xtitle"        ""           "title along the x axis"}
	{"xtitlefont"    "Helvetica"  "xtitle font to use"}
	{"xtitlesize"    "10"         "xtitle font size"}
	{"xtitlecolor"   "black"      "xtitle font color"}
	{"xtitleplace"   "c"          "c - center, l - left, r - right"}
	{"xtitlecoord"   ""           "coordinates of title; if empty, use best guess (can micro-adjust with -titleshift)"}
	{"xtitleshift"   "0,0"        "use this to micro-adjust the placement of the title"}
	{"xtitlerotate"  "0"          "how much to rotate the title"}
	{"xtitleanchor"  ""           "how to anchor the text; empty means we will guess"}
	{"xtitlebgcolor" ""           "if not-empty, put this color behind the title"}

	{"ytitle"        ""           "title along the y axis"}
	{"ytitlefont"    "Helvetica"  "ytitle font to use"}
	{"ytitlesize"    "10"         "ytitle font size"}
	{"ytitlecolor"   "black"      "ytitle font color"}
	{"ytitleplace"   "c"          "c - center, l - lower, u - upper"}
	{"ytitlecoord"   ""           "coordinates of title; if empty, use best guess (can micro-adjust with -titleshift)"}
	{"ytitleshift"   "0,0"        "use this to micro-adjust the placement of the title"}
	{"ytitlerotate"  "90"         "how much to rotate the title"}
	{"ytitleanchor"  ""           "how to anchor the text; empty means we will guess"}
	{"ytitlebgcolor" ""           "if not-empty, put this color behind the title"}

	{"title"         ""           "title along the y axis"}
	{"titlefont"     "Helvetica"  "title font to use"}
	{"titlesize"     "10"         "title font size"}
	{"titlecolor"    "black"      "title font color"}
	{"titleplace"    "c"          "c - center, l - left, r - right"}
	{"titleshift"    "0,0"        "use this to micro-adjust the placement of the title"}
	{"titlerotate"   "0"          "how much to rotate the title"}
	{"titleanchor"   ""           "how to anchor the text; empty means we will guess"}
	{"titlebgcolor"  ""           "if not-empty, put this color behind the title"}
    }
    ArgsProcessWithDashArgs AxesTicsLabels default args use \
	"Use this to draw some axes. It is supposed to be simpler and easier to use than the older package. We will see about that..."

    # get min and max of ranges
    # this is done in the VIRTUAL space
    #   thus, must be Translated to get to points we can draw 
    set r(xrange,min) [DrawableGetVirtualMin $use(drawable) x]
    set r(xrange,max) [DrawableGetVirtualMax $use(drawable) x]
    set r(yrange,min) [DrawableGetVirtualMin $use(drawable) y]
    set r(yrange,max) [DrawableGetVirtualMax $use(drawable) y]

    # figure out where axes will go
    if {$use(xaxisposition) != ""} {
	set r(xaxis,pos) $use(xaxisposition)
    } else {
	set r(xaxis,pos) $r(yrange,min)
    }
    if {$use(yaxisposition) != ""} {
	set r(yaxis,pos) $use(yaxisposition)
    } else {
	set r(yaxis,pos) $r(xrange,min)
    }

    # find out ranges of each axis
    if {$use(xaxisrange) != ""} {
	set count [ArgsParseCommaList $use(xaxisrange) xrange]
	AssertEqual $count 2
	set r(xaxis,min) $xrange(0)
	set r(xaxis,max) $xrange(1)
    } else {
	set r(xaxis,min) $r(xrange,min)
	set r(xaxis,max) $r(xrange,max)
    }
    if {$use(yaxisrange) != ""} {
	set count [ArgsParseCommaList $use(yaxisrange) yrange]
	AssertEqual $count 2
	set r(yaxis,min) $yrange(0)
	set r(yaxis,max) $yrange(1)
    } else {
	set r(yaxis,min) $r(yrange,min)
	set r(yaxis,max) $r(yrange,max)
    }

    # translate each of these values into points
    foreach v "xaxis,min xaxis,max xrange,min xrange,max yaxis,pos" {
	set t($v) [Translate $use(drawable) x $r($v)]
	# puts "translating: $v --> $t($v)"
    }
    foreach v "yaxis,min yaxis,max yrange,min yrange,max xaxis,pos" {
	set t($v) [Translate $use(drawable) y $r($v)]
	# puts "translating: $v :: $r($v) --> $t($v)"
    }

    # adjust for linewidths
    set half [expr $use(linewidth)/2.0]
    foreach min "xaxis,min yaxis,min" {
	set t($min) [expr $t($min) - $half]
    }
    foreach max "xaxis,max yaxis,max" {
	set t($max) [expr $t($max) + $half]
    }

    AssertIsMemberOf $use(style) "x y xy box"

    # first, draw axis lines
    #   these basically take the min and max of each virtual range
    #   and draw lines to connect them (depending on whether x, y, xy, or box is preferred)
    if [True $use(axis)] {
	switch -exact $use(style) {
	    x {
		PsLine -coord "$t(xaxis,min),$t(xaxis,pos):$t(xaxis,max),$t(xaxis,pos)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
	    }
	    y {
		PsLine -coord "$t(yaxis,pos),$t(yaxis,min):$t(yaxis,pos),$t(yaxis,max)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
	    }
	    xy {
		PsLine -coord "$t(xaxis,min),$t(xaxis,pos):$t(xaxis,max),$t(xaxis,pos)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
		PsLine -coord "$t(yaxis,pos),$t(yaxis,min):$t(yaxis,pos),$t(yaxis,max)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
	    }
	    box {
		PsLine -coord "$t(xaxis,min),$t(yrange,min):$t(xaxis,max),$t(yrange,min)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
		PsLine -coord "$t(xrange,min),$t(yaxis,min):$t(xrange,min),$t(yaxis,max)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
		PsLine -coord "$t(xaxis,min),$t(yrange,max):$t(xaxis,max),$t(yrange,max)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
		PsLine -coord "$t(xrange,max),$t(yaxis,min):$t(xrange,max),$t(yaxis,max)" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) 
	    }
	}
    }

    # get description of which tics, labels to make
    doUnpackDescription use x xlabels $r(xrange,min) $r(xrange,max) 
    doUnpackDescription use y ylabels $r(yrange,min) $r(yrange,max) 

    # now, tic marks
    if [True $use(majortics)] {
	AssertIsMemberOf $use(ticstyle) "in out centered"
	
	switch -exact $use(style) {
	    x {
		doTics use xlabels x $t(xaxis,pos) $use(ticstyle) $use(ticmajorsize) label
	    }
	    y {
		doTics use ylabels y $t(yaxis,pos) $use(ticstyle) $use(ticmajorsize) label
	    }
	    xy {
		doTics use xlabels x $t(xaxis,pos) $use(ticstyle) $use(ticmajorsize) label
		doTics use ylabels y $t(yaxis,pos) $use(ticstyle) $use(ticmajorsize) label
	    }
	    box {
		doTics use xlabels x $t(yrange,min) $use(ticstyle) $use(ticmajorsize) label
		doTics use ylabels y $t(xrange,min) $use(ticstyle) $use(ticmajorsize) label
		doTics use xlabels x $t(yrange,max) [toggleStyle $use(ticstyle)] $use(ticmajorsize) label
		doTics use ylabels y $t(xrange,max) [toggleStyle $use(ticstyle)] $use(ticmajorsize) label
	    }
	}
    }

    # minor tics
    if [True $use(minortics)] {
	# calculate x positions for x-axis minortics
	# XXX
	Abort "minor tics not implemented"
	set c 0
	for {set i 0} {$i < [expr $xlabels(cnt)-1]} {incr i} {
	    for {set j 0} {$j < $use(xminorratio)} {incr j} {
		set xminorlabels($c,n1) [expr $xlabels($i,n1) + (($xlabels([expr $i+1],n1) - $xlabels($i,n1)) / $use(xminorratio))]
		# puts "$c :: $xminorlabels($c,n1)"
		incr c
	    }
	}
	set xminorlabels(cnt) $i
	
	switch -exact $use(style) {
	    x {
		doTics use xminorlabels x $t(xaxis,pos) $use(ticstyle) $use(ticminorsize) label
	    }
	    y {
		doTics use yminorlabels y $t(yaxis,pos) $use(ticstyle) $use(ticminorsize) label
	    }
	    xy {
		doTics use xminorlabels x $t(xaxis,pos) $use(ticstyle) $use(ticminorsize) label
		doTics use yminorlabels y $t(yaxis,pos) $use(ticstyle) $use(ticminorsize) label
	    }
	    box {
		doTics use xminorlabels x $t(yrange,min) $use(ticstyle) $use(ticminorsize) label
		doTics use yminorlabels y $t(xrange,min) $use(ticstyle) $use(ticminorsize) label
		doTics use xminorlabels x $t(yrange,max) [toggleStyle $use(ticstyle)] $use(ticminorsize) label
		doTics use yminorlabels y $t(xrange,max) [toggleStyle $use(ticstyle)] $use(ticminorsize) label
	    }
	}
    }

    # now, labels
    if [True $use(labels)] {
	switch -exact $use(style) {
	    x {
		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
	    }
	    y {
		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
	    }
	    xy {
		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
	    }
	    box {
		doLabels use xlabels x $t(xaxis,pos) $use(ticstyle) labelbox
		doLabels use ylabels y $t(yaxis,pos) $use(ticstyle) labelbox
	    }
	}
    }

    # finally, do the three titles: overall title, yaxis title, xaxis title
    doTitle use labelbox t
}

# does the work for Grid
proc doGrid {use__ uaxis ustep urange} {
    upvar $use__ use

    AssertNotEqual $ustep {}
    set otherAxis [getOppositeAxis $uaxis]

    # autoextract ranges
    if {$urange == ""} {
	# THIS SHOULD BE TRANSLATABLE
	set range(0) [DrawableGetVirtualMin $use(drawable) $uaxis]
	set range(1) [DrawableGetVirtualMax $use(drawable) $uaxis]
    } else {
	set count [ArgsParseCommaList $urange range]
	AssertEqual $count 2
    }

    # THIS SHOULD BE TRANSLATABLE
    # finally, draw some grid marks
    set otherMin [DrawableGetVirtualMin $use(drawable) $otherAxis]
    set otherMax [DrawableGetVirtualMax $use(drawable) $otherAxis]

    # iterate over the range
    foreach v [DrawableGetRangeIterator $use(drawable) $uaxis $range(0) $range(1) $ustep] {
	switch -exact $uaxis {
	    x {
		Line -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
		    -coord $v,$otherMin:$v,$otherMax
	    } 
	    y {
		Line -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash) \
		    -coord $otherMin,$v:$otherMax,$v
	    }
	}
    }
}

proc Grid {args} {
    set default {
	{"drawable"   "default"    "the relevant drawable"}
	{"linecolor"  "black"      "color of axis line"}
	{"linewidth"  "0.5"        "width of axis line"}
	{"linedash"   "0"          "dash parameters; will make axes dashed, but not tic marks"}
	{"x"          "true"       "specify false to turn off grid in x direction (vertical lines)"}
	{"y"          "true"       "specify false to turn off grid in y direction (horizontal lines)"}
	{"xrange"     ""           "empty means whole range, otherwise a 'y1,y2' as beginning and end of the  range to draw vertical lines upon"}
	{"xstep"      ""           "how much space to skip between each grid line; if log scale, this will be used in a multiplicative way"}
	{"yrange"     ""           "empty means whole range, otherwise a 'x1,x2' as beginning and end of the  range to draw horizontal lines upon"}
	{"ystep"      ""           "how much space to skip between each grid line; if log scale, this will be used in a multiplicative way"}
    }
    ArgsProcessWithDashArgs Grid default args use \
	"Use this to draw a grid onto "

    # do the work in each direction
    if [True $use(x)] {
	doGrid use x $use(xstep) $use(xrange)
    }
    if [True $use(y)] {
	doGrid use y $use(ystep) $use(yrange)
    }
}