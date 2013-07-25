# tcl

proc PlotVerticalBars {args} {
    set default {
	{"drawable"   "root"     "name of the drawable area"}
	{"table"      ""         "name of table to use"}
	{"x"          "x"        "table column with x data"}
	{"y"          "y"        "table column with y data"}
	{"ylo"        ""         "if specified, table column with ylo data; use if bars don't start at y=0"}
	{"style"      ""         "style to use; supplants args below"}
	{"barwidth"   "1"        "bar width"}
	{"linecolor"  "black"    "color of the line"}
	{"linewidth"  "1"        "width of the line"}
	{"fill"       "false"    "fill the box or not"} 
	{"fillcolor"  "gray"     "fill color (if used)"}
	{"fillstyle"  "solid"    "solid, boxes, circles, ..."}
	{"fillparams" ""         "any params that the fill style needs"}
	{"legend"     ""         "add this entry to the legend"}
    }    
    ArgsProcessWithDashArgs PlotVerticalBars default args use \
	"Use this to plot vertical bars on a drawable. "
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(x) $r]
	set y [TableGetVal $use(table) $use(y) $r]
	if {$use(ylo) != ""} {
	    set ylo [TableGetVal $use(table) $use(ylo) $r]
	} else {
	    set ylo 0.0
	}

	set barwidth [Scale $use(drawable) x $use(barwidth)]

	set x1 [expr [Translate $use(drawable) x $x] - ($barwidth/2.0)]
	set y1 [Translate $use(drawable) y $ylo]
	set x2 [expr $x1 + $barwidth]
	set y2 [Translate $use(drawable) y $y] 

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2 \
	    -linecolor  $use(linecolor) \
	    -linewidth  $use(linewidth) \
	    -fill       $use(fill) \
	    -fillcolor  $use(fillcolor) \
	    -fillstyle  $use(fillstyle) \
	    -fillparams $use(fillparams)
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord COORDX,COORDY:\[expr COORDX+WIDTH],\[expr COORDY+HEIGHT] -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillparams $use(fillparams) -linewidth 0.25 -linecolor $use(linecolor)"
    }
}

proc PlotHorizontalBars {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"xlo"        ""            "if specified, column with xlo data; use if bars don't start at x=0"}
	{"y"          "y"           "table column with y data"}
	{"style"      ""            "style to use; supplants args below"}
	{"barwidth"   "1"           "bar width"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "gray"        "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" ""            "any params that the fill style needs"}
	{"legend"     ""            "add this entry to the legend"}
    }    
    ArgsProcessWithDashArgs PlotHorizontalBars default args use ""
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(x) $r]
	set y [TableGetVal $use(table) $use(y) $r]
	if {$use(xlo) != ""} {
	    set xlo [TableGetVal $use(table) $use(xlo) $r]
	} else {
	    set xlo 0.0
	}

	set barwidth [Scale $use(drawable) y $use(barwidth)]

	set x1 [Translate $use(drawable) x $xlo]
	set y1 [expr [Translate $use(drawable) y $y] - ($barwidth/2.0)]
	set x2 [Translate $use(drawable) x $x]
	set y2 [expr [Translate $use(drawable) y $y] + ($barwidth/2.0)]

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2 \
	    -linecolor  $use(linecolor) \
	    -linewidth  $use(linewidth) \
	    -fill       $use(fill) \
	    -fillcolor  $use(fillcolor) \
	    -fillstyle  $use(fillstyle) \
	    -fillparams $use(fillparams)
    }
}

proc PlotVerticalIntervals {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""           "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"ylo"        "ylo"         "table column with ylo data"}
	{"yhi"        "yhi"         "table column with ylo data"}
	{"align"      "c"           "c - center, l - left, r - right, n - none"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of all lines"}
	{"devwidth"   "3"           "width of little marker on top"}
    }
    ArgsProcessWithDashArgs PlotDevs default args use ""
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set ylo [TableGetVal $use(table) $use(ylo) $r]
	set yhi [TableGetVal $use(table) $use(yhi) $r]

	set xp   [Translate $use(drawable) x $x]
	set ylop [Translate $use(drawable) y $ylo]
	set yhip [Translate $use(drawable) y $yhi]

	set dw   [expr $use(devwidth) / 2.0]
	set hlw  [expr $use(linewidth) / 2.0]

	switch -exact $use(align) {
	    c {
		PsLine -coord "$xp $ylop : $xp $yhip" \
		-linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    l {
		PsLine -coord "[expr $xp-$dw+$hlw] $ylop : [expr $xp-$dw+$hlw] $yhip" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    r {
		PsLine -coord "[expr $xp+$dw-$hlw] $ylop : [expr $xp+$dw-$hlw] $yhip" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    n {
		# no little lines on top and bottom
	    }
	    default {
		Abort "Bad alignment ($use(align): should be c, l, or r"
	    }
	}

	# vertical line between two end marks
	PsLine -coord "[expr $xp-$dw] $yhip : [expr $xp+$dw] $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $ylop : [expr $xp+$dw] $ylop" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)

    }
}

proc PlotHeat {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"y"          "y"           "table column with y data"}
	{"heat"       "heat"        "table column with heat data"}
	{"width"      "1"           "width of each rectangle"}
	{"height"     "1"           "height of each rectangle"}
	{"divisor"    "1"           "how much to divide heat value by"}
	{"label"      "false"       "if true, add labels to each heat region"}
    }
    ArgsProcessWithDashArgs PlotHeat default args use \
	"Use this to plot a heat map. A heat map takes x,y,heat triples and plots a gray-shaded box with darkness proportional to (heat/divisor) and of size (width by height) at each (x,y) coordinate"
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set y   [TableGetVal $use(table) $use(y) $r]

	set tx   [Translate $use(drawable) x $x]
	set ty   [Translate $use(drawable) y $y]

	set val  [TableGetVal $use(table) $use(heat) $r]
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
	    PsText -anchor c -text [format "%3.0f" $val] -coord [expr $tx+($w/2.0)],[expr $ty+($h/2.0)] -size 6.0 -color orange
	}

    }
}

proc PlotPoints {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"y"          "y"           "table column with y data"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of lines used to draw point"}
	{"style"      "x"           "box,circle,filledcircle,x,triangle,filledtriangle,..."}
	{"size"       "2"           "size of marker"}
	{"legend"     ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotPoints default args use ""
    AssertNotEqual $use(table) ""
    set s $use(size)

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set y   [TableGetVal $use(table) $use(y) $r]

	set x   [Translate $use(drawable) x $x]
	set y   [Translate $use(drawable) y $y]

	switch -exact $use(style) {
	    "box"      { PsBox -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
			     -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "circle"   { PsCircle -coord $x,$y -radius $use(size) \
			     -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "filledcircle" { PsCircle -coord $x,$y -radius $use(size) \
			     -linecolor $use(linecolor) -linewidth $use(linewidth) -fill t -fillcolor $use(linecolor) }
	    "x"        { PsLine -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
			     -linecolor $use(linecolor) -linewidth $use(linewidth) 
		        PsLine -coord "[expr $x-$s] [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
			     -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "triangle" { XXX }
	    default {
		Abort "bad choice of point style: $use(style)"
	    }
	}
    }

    if {$use(legend) != ""} {
	# XXX - need to finish this implementation
	switch -exact $use(style) {
	    "box"    { LegendAdd -text $use(legend) -picture "" }
	    "circle" { LegendAdd -text $use(legend) -picture "" }
	    "x"      { LegendAdd -text $use(legend) -picture "" }
	}
    }

}


