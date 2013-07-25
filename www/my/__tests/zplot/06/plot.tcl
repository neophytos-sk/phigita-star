# tcl

# 
# get the lo point (could be from a field, from a single value, or default: the min of yrange)
# 
proc tableGetLoFieldY {use__ row} {
    upvar $use__ use
    if {$use(ylofield) != ""} {
	return [__TableGetVal $use(table) $use(ylofield) $row]
    } else {
	if {$use(yloval) == ""} {
	    # THIS SHOULD BE TRANSLATABLE (i.e., not mapped)
	    return [DrawableGetVirtualMin $use(drawable) y]
	} else {
	    return $use(yloval)
	}
    }
}

proc tableGetLoFieldX {use__ row} {
    upvar $use__ use
    if {$use(xlofield) != ""} {
	return [__TableGetVal $use(table) $use(xlofield) $row]
    } else {
	if {$use(xloval) == ""} {
	    # THIS SHOULD BE TRANSLATABLE (i.e., not mapped)
	    return [DrawableGetVirtualMin $use(drawable) x]
	} else {
	    return $use(xloval)
	}
    }
}

proc limit {value min max} {
    if {$value < $min} {
	return $min
    } elseif {$value > $max} {
	return $max
    } else {
	return $value
    }
}

#
# exported plot functions
#
proc PlotFunction {args} {
    set default {
	{"drawable"   "default"   "name of the drawable area"}
	{"func"       "default"   "describe the function, using the variable x to express f(x) (e.g., linear would be {\$x}, whereas a simple parabola would be {\$x * \$x})"}
	{"range"      "0,10"      "the x-range the function should be plotted over, in xmin,xmax form"}
	{"step"       "1"         "given the range of xmin to xmax, step determines at which x values the function is evaluated and a line is drawn to; thus, the more ups and downs the function has, the smaller step that should be chosen"}
	{"linewidth"  "1"         "the linewidth to use"}
	{"linecolor"  "black"     "the color of the line"}
	{"linedash"   "0"         "the dash pattern (if non-zero)"}
    }
    ArgsProcessWithDashArgs PlotFunction default args use \
	"Use PlotFunction to plot a function right onto a drawable. The function should simply use the variable \$x wherever it needs to in order to express the desired function. For example, to plot y = x, the caller should pass the following flag: -func \{\$x\}. The caller should place curly braces around the function to prevent the Tcl interpreter from interpreting what is inside of the braces before it is passed to the PlotFunction routine."

    set count [ArgsParseCommaList $use(range) range]
    AssertEqual $count 2
    set min  $range(0)
    set max  $range(1)
    set step $use(step)
    
    # get first point
    set x $min
    set y [eval "expr $use(func)"]
    set lineList "[Translate $use(drawable) x $x],[Translate $use(drawable) y $y]"
    for {set x [expr $min+$step]} {$x <= $max} {set x [expr $x+$step]} {
	# now iterate and plot the rest of the points
	set y [eval "expr $use(func)"]
	set lineList "$lineList : [Translate $use(drawable) x $x],[Translate $use(drawable) y $y]"
    }

    # now draw the line
    PsLine -coord $lineList -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash)
}

proc setAnchorAndPlace {use__ anchor__ place__ y1 y2} {
    upvar $use__    use
    upvar $anchor__ anchor
    upvar $place__  place

    if {$y2 < $y1} {
	# this is an upside down bar, so switch position of anchor and 'place'
	if [StringEqual $use(labelplace) "i"] {
	    set place "+3"
	} else {
	    set place "-3"
	}
    } else {
	# normal bar (not upside down)
	if [StringEqual $use(labelplace) "i"] {
	    set place "-3"
	} else {
	    set place "+3"
	}
    }

    if {$use(labelanchor) == ""} {
	# autospecifying the anchor
	if {$place < 0} {
	    set anchor "c,h"
	} else {
	    set anchor "c,l"
	}
    } else {
	set anchor $use(labelanchor)
    }
}

proc PlotVerticalBars {args} {
    set default {
	{"drawable"      "default"   "name of the drawable area"}
	{"table"         "default"   "name of table to use"}
	{"xfield"        "x"         "table column with x data"}
	{"yfield"        "y"         "table column with y data"}
	{"ylofield"      ""          "if specified, table column with ylo data; use if bars don't start at the minimum of the range"}
	{"yloval"        ""          "if there is no ylofield, use this single value to fill down to; if empty, just use the min of y-range"}
	{"limit"        "t"          "if true, limit values to the drawable; if not, let values go beyond the range of the drawable"}
	{"barwidth"      "1"         "bar width"}
	{"cluster"       "0,1"       "should be of the form n,m; thus, each x-axis data point actually will have 'm' bars plotted upon it; 'n' specifies which cluster of the 'm' this one is (from 0 to m-1); width of each bar is 'barwidth/m'; normal bar plots (without clusters) are just the default, '0,1'"}
	{"linecolor"     "black"     "color of the line"}
	{"linewidth"     "0.25"      "width of the line; set to 0 if you don't want a surrounding line on the box"}
	{"fill"          "false"     "fill the box or not"} 
	{"fillcolor"     "gray"      "fill color (if used)"}
	{"fillstyle"     "solid"     "solid, boxes, circles, ..."}
	{"fillsize"      "3"         "size of object in pattern"}
	{"fillskip"      "4"         "space between object in pattern"}
	{"bgcolor"       ""         "color background for the bar; empty means none (patterns may be see through)"}
	{"labelfield"    ""          "if specified, table column with labels for each bar"}
	{"labelformat"   "%s"        "use this format for the labels; can prepend and postpend arbitrary text"}
	{"labelrotate"   "0"         "rotate labels"}
	{"labelanchor"   ""          "text anchor if using a labelfield; empty means use a best guess"}
	{"labelplace"    "o"         "place label (o) outside of bar or (i) inside of bar"}
	{"labelshift"    "0,0"       "shift text in x,y direction"}
	{"labelfont"     "Helvetica" "if using labels, what font should be used"}
	{"labelsize"     "10.0"      "if using labels, font for label"}
	{"labelcolor"    "black"     "if using labels, what color font should be used"}
	{"labelbgcolor"  ""          "if specified, fill this color in behind each text item"}
	{"legend"        ""          "add this entry to the legend"}
    }    
    ArgsProcessWithDashArgs PlotVerticalBars default args use \
	"Use this to plot vertical bars on a drawable. A basic plot will specify the table, xfield, and yfield. Bars will be drawn from the minimum of the range to the y value found in the table. If the bars should start at some value other than the minimum of the range (for example, when the yaxis extends below zero, or you are building a stacked bar chart), two options are available: ylofield and yloval. ylofield specifies a column of a table that has the low values for each bar, i.e., a bar will be drawn at the value specifed by the xfield starting at the ylofield value and going up to the yfield value. yloval can be used instead when there is just a single low value to draw all bars down to. Some other interesting options: labelfield, which lets you add a label to each bar by giving a column of labels (use rotate, anchor, place, font, fontsize, and fontcolor flags to control details of the labels); barwidth, which determines how wide each bar is in the units of the x-axis; linecolor, which determines the color of the line surrounding the box, and linewidth, which determines its thickness (or 0 to not have one); and of course the color and fill of the bar, as determined by fillcolor, fillstyle, and fillsize and fillskip."
    AssertNotEqual $use(table) ""

    set count [ArgsParseCommaList $use(cluster) cluster]
    AssertEqual $count 2
    set n        [expr double($cluster(0))]
    set clusters [expr double($cluster(1))]
    AssertGreaterThanOrEqual $n 0
    AssertLessThan $n $clusters

    set barwidth  [Scale $use(drawable) x $use(barwidth)]
    set ubarwidth [expr $barwidth / $clusters]

    set count [ArgsParseCommaList $use(labelshift) shift]
    AssertEqual $count 2

    if [True $use(limit)] {
	set xmax [DrawableGetVirtualMax $use(drawable) x]
	set xmin [DrawableGetVirtualMin $use(drawable) x]
	set ymax [DrawableGetVirtualMax $use(drawable) y]
	set ymin [DrawableGetVirtualMin $use(drawable) y]
    }
    

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x   [__TableGetVal $use(table) $use(xfield) $r]
	set y   [__TableGetVal $use(table) $use(yfield) $r]
	set ylo [tableGetLoFieldY use $r]

	if [True $use(limit)] {
	    # THIS ONLY WORKS FOR NUMERIC VALUES, not CATEGORIES
	    # skip if x is out of bounds
	    if {($x < $xmin) || ($x > $xmax)} {
		continue
	    } 
	    if {($y < $ymin) && ($ylo < $ymin)} {
		continue
	    }
	    if {($y > $ymax) && ($ylo > $ymax)} {
		continue
	    }
	    set y   [limit $y $ymin $ymax]
	    set ylo [limit $ylo $ymin $ymax]
	}

	set x1 [expr [Translate $use(drawable) x $x] - ($barwidth/2.0) + ($ubarwidth * $n)]
	set y1 [Translate $use(drawable) y $ylo]
	set x2 [expr $x1 + ($barwidth/$clusters)]
	set y2 [Translate $use(drawable) y $y] 

	# auto set anchor, etc.
	setAnchorAndPlace use anchor place $y1 $y2

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2 -linecolor  $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor  $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)

	if {$use(labelfield) != ""} {
	    set label  [format $use(labelformat) [__TableGetVal $use(table) $use(labelfield) $r]]
	    set xlabel [expr $x1 + ($barwidth/2.0) + $shift(0)]
	    set ylabel [expr [Translate $use(drawable) y $y] + $place + $shift(1)]
	    PsText -coord $xlabel,$ylabel -text $label -anchor $anchor -rotate $use(labelrotate) \
		-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor) -bgcolor $use(labelbgcolor)
	}
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmm,__Ymm:__Xpm,__Ypm -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -linewidth [expr $use(linewidth)/4.0] -linecolor $use(linecolor)"
    }
}

proc PlotHorizontalBars {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"yfield"     "y"           "table column with y data"}
	{"xlofield"   ""            "if specified, column with xlo data; use if bars don't start at x=0"}
	{"xloval"     ""            "if there is no xlofield, use this single value to fill down to; if empty, just use the min of x-range"}
	{"style"      ""            "style to use; supplants args below"}
	{"barwidth"   "1"           "bar width"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "gray"        "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillsize"      "3"         "size of object in pattern"}
	{"fillskip"      "4"         "space between object in pattern"}
	{"bgcolor"     ""            "color background for the bar; empty means none (patterns may be see through)"}
	{"legend"     ""            "add this entry to the legend"}
    }    
    # XXX - should add label ability to horizontal bars too
    ArgsProcessWithDashArgs PlotHorizontalBars default args use ""
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x   [__TableGetVal $use(table) $use(xfield) $r]
	set y   [__TableGetVal $use(table) $use(yfield) $r]
	set xlo [tableGetLoFieldX use $r]

	set barwidth [Scale $use(drawable) y $use(barwidth)]

	set x1 [Translate $use(drawable) x $xlo]
	set y1 [expr [Translate $use(drawable) y $y] - ($barwidth/2.0)]
	set x2 [Translate $use(drawable) x $x]
	set y2 [expr [Translate $use(drawable) y $y] + ($barwidth/2.0)]

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2  -linecolor  $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -bgcolor $use(bgcolor)
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmm,__Ymm:__Xpm,__Ypm -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize   $use(fillsize) -fillskip   $use(fillskip) -linewidth [expr $use(linewidth)/4.0] -linecolor $use(linecolor)"
    }
}

proc PlotVerticalIntervals {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"ylofield"   "ylo"         "table column with ylo data"}
	{"yhifield"   "yhi"         "table column with yhi data"}
	{"align"      "c"           "c - center, l - left, r - right, n - none"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of all lines"}
	{"devwidth"   "3"           "width of interval marker on top"}
    }
    ArgsProcessWithDashArgs PlotVerticalIntervals default args use \
	"Use this to plot interval markers in the y direction. The x column has the x value for each interval, and draws the interval between the ylo and yhi column values. The marker can take on many forms, as specified by the 'align' flag. Note the 'b' type in particular, which can be used to assemble box plots. "
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x   [__TableGetVal $use(table) $use(xfield) $r]
	set ylo [__TableGetVal $use(table) $use(ylofield) $r]
	set yhi [__TableGetVal $use(table) $use(yhifield) $r]

	set xp   [Translate $use(drawable) x $x]
	set ylop [Translate $use(drawable) y $ylo]
	set yhip [Translate $use(drawable) y $yhi]

	set dw   [expr $use(devwidth) / 2.0]
	set hlw  [expr $use(linewidth) / 2.0]

	switch -exact $use(align) {
	    c {
		PsLine -coord "$xp,$ylop : $xp,$yhip" \
		-linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    l {
		PsLine -coord "[expr $xp-$dw+$hlw],$ylop : [expr $xp-$dw+$hlw],$yhip" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    r {
		PsLine -coord "[expr $xp+$dw-$hlw],$ylop : [expr $xp+$dw-$hlw],$yhip" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    n {
		# no little lines on top and bottom
	    }
	    default {
		Abort "Bad alignment ($use(align): should be c, l, r, or n"
	    }
	}

	# vertical line between two end marks
	PsLine -coord "[expr $xp-$dw],$yhip : [expr $xp+$dw],$yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw],$ylop : [expr $xp+$dw],$ylop" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
    }
}

proc PlotHorizontalIntervals {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"yfield"     "y"           "table column with x data"}
	{"xlofield"   "xlo"         "table column with xlo data"}
	{"xhifield"   "xhi"         "table column with xhi data"}
	{"align"      "c"           "c - center, u - upper, l - lower, n - none"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of all lines"}
	{"devwidth"   "3"           "width of interval marker on top"}
    }
    ArgsProcessWithDashArgs PlotHorizontalIntervals default args use \
	"Use this to plot interval markers in the x direction. The y column has the y value for each interval, and draws the interval between the ylo and yhi column values. The marker can take on many forms, as specified by the 'align' flag. Note the 'b' type in particular, which can be used to assemble box plots. "
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set y   [__TableGetVal $use(table) $use(yfield) $r]
	set xlo [__TableGetVal $use(table) $use(xlofield) $r]
	set xhi [__TableGetVal $use(table) $use(xhifield) $r]

	set yp   [Translate $use(drawable) y $y]
	set xlop [Translate $use(drawable) x $xlo]
	set xhip [Translate $use(drawable) x $xhi]

	set dw   [expr $use(devwidth) / 2.0]
	set hlw  [expr $use(linewidth) / 2.0]

	switch -exact $use(align) {
	    c {
		PsLine -coord "$xlop,$yp : $xhip,$yp" \
		-linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    l {
		PsLine -coord "$xlop,[expr $yp-$dw+$hlw] : $xhip,[expr $yp-$dw+$hlw] " \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    u {
		PsLine -coord "$xlop,[expr $yp+$dw-$hlw] : $xhip,[expr $yp+$dw-$hlw] " \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    n {
		# no little lines
	    }
	    default {
		Abort "Bad alignment ($use(align): should be c, l, or r"
	    }
	}

	# vertical line between two end marks
	PsLine -coord "$xhip,[expr $yp-$dw] : $xhip,[expr $yp+$dw] " \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "$xlop,[expr $yp-$dw] : $xlop,[expr $yp+$dw] " \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)

    }
}

proc PlotHeat {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"yfield"     "y"           "table column with y data"}
	{"hfield"     "heat"        "table column with heat data"}
	{"width"      "1"           "width of each rectangle"}
	{"height"     "1"           "height of each rectangle"}
	{"divisor"    "1"           "how much to divide heat value by"}
	{"label"      "false"       "if true, add labels to each heat region reflecting count value"}
	{"labelfont"  "Helvetica"   "if using labels, what font should be used"}
	{"labelcolor" "orange"      "if using labels, what color font should be used"}
	{"labelsize"  "6.0"         "if using labels, what font size should be used"}
    }
    # XXX - default is to use hfield as label field -- does this make sense?
    ArgsProcessWithDashArgs PlotHeat default args use \
	"Use this to plot a heat map. A heat map takes x,y,heat triples and plots a gray-shaded box with darkness proportional to (heat/divisor) and of size (width by height) at each (x,y) coordinate"
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x   [__TableGetVal $use(table) $use(xfield) $r]
	set y   [__TableGetVal $use(table) $use(yfield) $r]

	set tx   [Translate $use(drawable) x $x]
	set ty   [Translate $use(drawable) y $y]

	set val  [__TableGetVal $use(table) $use(hfield) $r]
	set heat [expr $val / double($use(divisor))]

	set w    [Scale $use(drawable) x $use(width)]
	set h    [Scale $use(drawable) y $use(height)]

	# absence of color is black (0,0,0)
	set scolor [expr 1.0 - $heat]
	set color  "%$scolor,$scolor,$scolor"
	# puts stderr "val:$val heat:$heat --> $color"

	# make the arg list and call the box routine
	PsBox -coord "$tx,$ty : [expr $tx+$w],[expr $ty+$h]" \
	    -linecolor  "" -linewidth 0 -fill t -fillcolor $color -fillstyle solid 

	# puts stderr "plotting HEAT: x,y->$x,$y heat->$heat width:$use(width)($w)  height:$use(height)($h)"
	if {[True $use(label)]} {
	    PsText -anchor c -text [format "%3.0f" $val] -coord [expr $tx+($w/2.0)],[expr $ty+($h/2.0)] \
		-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor)
	}

    }
}


proc PlotPoints {args} {
    set default {
	{"drawable"     "default"     "name of the drawable area"}
	{"table"        "default"     "name of table to use"}
	{"xfield"       "x"           "table column with x data"}
	{"yfield"       "y"           "table column with y data"}
	{"size"         "2"           "overall size of marker; used unless sizefield is specified"}
	{"style"        "xline"       "label,hline,vline,plusline,xline,dline1,dline2,square,circle,triangle,utriangle,diamond,star,asterisk"}
	{"sizefield"    ""            "if specified, table column with sizes for each point"}
	{"sizediv"      "1"           "if using sizefield, use sizediv to scale each value (sizefield gets divided by sizediv to determine the size of the point)"}
	{"linecolor"    "black"       "color of the line of the marker"}
	{"linewidth"    "1"           "width of lines used to draw the marker"}
	{"fill"         "f"           "for some shapes, filling makes sense; if desired, mark this true"}
	{"fillcolor"    "black"       "if filling, use this fill color"}
	{"fillstyle"    "solid"       "if filling, which fill style to use"}
	{"fillsize"      "3"         "size of object in pattern"}
	{"fillskip"      "4"         "space between object in pattern"}
	{"labelfield"   ""            "if specified, table column with labels for each point"}
	{"labelrotate"  "0"           "if using labels, rotate labels"}
	{"labelanchor"  "c,c"         "if using labels, center 'c' or right 'r' or left 'l' x-alignment for label text, or 'xanchor,l', 'xanchor,c', or 'xanchor,h' for x and y alignment of text (l - low, c - center, h - high alignment in y direction)"}
	{"labelplace"  "c"           "if using labels, place text: (c) centered on point, (s) below point, (n) above point, (w) west of point, (e) east of point"}
	{"labelshift"   "0,0"         "shift text in x,y direction"}
	{"labelfont"    "Helvetica"   "if using labels, what font should be used"}
	{"labelsize"    "6.0"         "if using labels, font for label"}
	{"labelcolor"   "black"       "if using labels, what color font should be used"}
	{"labelbgcolor" ""            "if using labels, put a background color behind each"}
	{"legend"       ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotPoints default args use \
	"Use this to draw some points on a drawable. There are some obvious parameters: which drawable, which table, which x and y columns from the table to use, the color of the point, its linewidth, and the size of the marker. 'style' is a more interesting parameter, allowing one to pick a box, circle, horizontal line (hline), and 'x' that marks the spot, and so forth. However, if you set 'style' to label, PlotPoints will instead use a column from the table (as specified by the 'label' flag) to plot an arbitrary label at each (x,y) point. Virtually all the rest of the flags pertain to these text labels: whether to rotate them, how to anchor them, how to place them, font, size, and color. " 
    AssertNotEqual $use(table) ""

    set t1 [clock clicks -milliseconds]

    set count [ArgsParseCommaList $use(labelshift) shift]
    AssertEqual $count 2

    # timing notes: 
    #   just getting values :   30ms / 2000pts
    #   + translation       :  130ms / 2000pts
    #   + filledcircle      : 1014ms / 2000pts (or 2pts/ms -- ouch!)
    #   + box               :  350ms / 2000pts 
    #   + switchstatement   : 1030ms / 2000pts 
    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x [Translate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]
	set y [Translate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]
	if {$use(sizefield) == ""} {
	    # empty -> a single size should be used
	    set s $use(size)
	} else {
	    # non-empty -> sizefield should be used (i.e., ignore use(size))
	    set s [expr [__TableGetVal $use(table) $use(sizefield) $r] / $use(sizediv)]
	}

	if [StringEqual $use(style) "label"] {
		AssertNotEqual $use(labelfield) ""
		set label [__TableGetVal $use(table) $use(labelfield) $r]
		switch -exact $use(labelplace) {
		    c { }
		    s { set y [expr $y - $use(labelsize)] }
		    n { set y [expr $y + $use(labelsize)] }
		    w { set x [expr $x - $s - 2.0] }
		    e { set x [expr $x + $s + 2.0] }
		    default { Abort "bad 'place' flag ($use(flag)); should be c, s, n, w, or e" }
		}
		PsText -coord [expr $x+$shift(0)],[expr $y+$shift(1)] -text $label \
		    -anchor $use(labelanchor) -rotate $use(labelrotate) \
		    -font $use(labelfont) -size $use(labelsize) \
		    -color $use(labelcolor) -bgcolor $use(labelbgcolor)
		
	} else {
	    PsShape -style $use(style) -x $x -y $y -size $s \
		-linecolor $use(linecolor) -linewidth $use(linewidth) \
		-fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		-fillsize $use(fillsize) -fillskip $use(fillskip) 
	}
    }

    set t2 [clock clicks -milliseconds]
    Dputs table "PlotPoints: Plotted [TableGetNumRows -table $use(table)] points in [expr ($t2-$t1)] ms :: [ArgsPrint use]"

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsShape -style $use(style) -x __Xx -y __Yy -size __M2 -linecolor $use(linecolor) -linewidth $use(linewidth) -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip)" 
    }
}

proc doLabel {use__ x y row shiftx shifty offset} {
    upvar $use__ use
    set label  [__TableGetVal $use(table) $use(labelfield) $row]
    set labelx [expr $x + $shiftx]
    set labely [expr $y + $offset + $shifty]
    PsText -coord $labelx,$labely -text $label -anchor $use(labelanchor) \
	-font $use(labelfont) -size $use(labelsize) -color $use(labelcolor) -rotate $use(labelrotate) \
	-bgcolor $use(labelbgcolor)
}

# XXX - should be PlotHorizontalLines
proc PlotLines {args} {
    set default {
	{"drawable"    "default"     "name of the drawable area"}
	{"table"       "default"     "name of table to use"}
	{"xfield"      "x"           "table column with x data"}
	{"yfield"      "y"           "table column with y data"}
	{"stairstep"   "false"       "plot the data in a stairstep manner"}
	{"linecolor"   "black"       "color of the line of the marker"}
	{"linewidth"   "1"           "width of lines used to draw the marker"}
	{"linedash"    "0"           "use dashes for this line (0 means no dashes)"}
	{"labelfield"  ""            "if specified, table column with labels for each point in line"}
	{"labelplace"  "n"           "place the labels n (north) of the line, or s (south)"}
	{"labelfont"   "Helvetica"   "font for labels"}
	{"labelsize"   "8"           "font size for labels"}
	{"labelcolor"  "black"       "font color for labels"}
	{"labelanchor" "c"           "anchor for the text"}
	{"labelrotate" "0"           "rotate the text this much"}
	{"labelshift"  "0,0"         "how much to shift the text"}
	{"labelbgcolor" ""            "if not empty, put this background color behind each text marking"}
	{"legend"       ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotLines default args use \
	"Use this function to plot lines. It is one of the simplest routines there is -- basically, it takes the x and y fields and plots a line through them. It does NOT sort them, though, so you might need to do that first if you want the line to look pretty. The usual line arguments can be used, including color, width, and dash pattern. "
    AssertNotEqual $use(table) ""

    # get some things straight before looping
    AssertIsMemberOf $use(labelplace) "n s"
    switch -exact $use(labelplace) {
	n { set offset +3 }
	s { set offset -3 }
    }

    psGsave
    psNewpath

    # get text shifts for labelfield
    set cnt [ArgsParseCommaList $use(labelshift) shift]
    AssertEqual $cnt 2

    # XXX: nothing is drawn if there is just ONE point -- is this bad?
    set x [Translate $use(drawable) x [__TableGetVal $use(table) $use(xfield) 0]]  
    set y [Translate $use(drawable) y [__TableGetVal $use(table) $use(yfield) 0]]
    if {$use(labelfield) != ""} {
	doLabel use $x $y 0 $shift(0) $shift(1) $offset
    }
    set lasty $y
    psMoveto $x $y

    for {set r 1} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set x [Translate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]
	set y [Translate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]

	# label the point, if desired
	if {$use(labelfield) != ""} {
	    doLabel use $x $y $r $shift(0) $shift(1) $offset
	}
	if [True $use(stairstep)] {
	    psLineto $x $lasty
	}
	psLineto $x $y
	set lasty $y
    }

    psSetcolor [psColor $use(linecolor)]
    psSetlinewidth $use(linewidth)
    if {$use(linedash) != 0} {
	psSetdash $use(linedash)
    }
    psStroke
    psGrestore

    # now do legend stuff
    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsLine -coord __Xmw,__Yy:__Xpw,__Yy -linewidth $use(linewidth) -linecolor $use(linecolor)"
    }
}


proc PlotVerticalFill {args} {
    set default {
	{"drawable"    "default"     "name of the drawable area"}
	{"table"       "default"     "name of table to use"}
	{"xfield"      "x"           "table column with x data"}
	{"yfield"      "y"           "table column with y data"}
	{"ylofield"    ""            "if not empty, use this table column to fill down to this value"}
	{"yloval"      ""            "if there is no ylofield, use this single value to fill down to; if empty, just use the min of y-range"}
	{"fillcolor"   "gray"        "fill color (if used)"}
	{"fillstyle"   "solid"       "solid, boxes, circles, ..."}
	{"fillsize"      "3"         "size of object in pattern"}
	{"fillskip"      "4"         "space between object in pattern"}
	{"legend"      ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotVerticalFill default args use \
	"Use this function to fill a vertical region between either the values in yfield and the minimum of the y-range (default), the yfield values and the values in the ylofield, or the yfield values and a single yloval. Any pattern and color combination can be used to fill the filled space. "
    AssertNotEqual $use(table) ""

    # get first point
    set xlast   [Translate $use(drawable) x [__TableGetVal $use(table) $use(xfield) 0]]  
    set ylast   [Translate $use(drawable) y [__TableGetVal $use(table) $use(yfield) 0]]
    set ylolast [Translate $use(drawable) y [tableGetLoFieldY use 0]]
    
    # now, get rest of points
    for {set r 1} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	# get the new points
	set xcurr   [Translate $use(drawable) x [__TableGetVal $use(table) $use(xfield) $r]]  
	set ycurr   [Translate $use(drawable) y [__TableGetVal $use(table) $use(yfield) $r]]
	set ylocurr [Translate $use(drawable) y [tableGetLoFieldY use $r]]

	# draw the stinking polygon between the last pair of points and the current points
	psComment "PsPolygon $xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr"
	PsPolygon -coord "$xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr" \
	    -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
	    -fillsize $use(fillsize) -fillskip $use(fillskip) \
	    -linewidth 0.1 -linecolor $use(fillcolor)
	# xxx - make a little bit of linewidth so as to overlap neighboring regions
	# the alternate is worse: having to draw one huge polygon

	# move last points to current points
	set xlast   $xcurr
	set ylast   $ycurr
	set ylolast $ylocurr
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord __Xmw,__Ymh:__Xpw,__Yph -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillsize $use(fillsize) -fillskip $use(fillskip) -linewidth 0.1 -linecolor $use(fillcolor)"
    }

}

