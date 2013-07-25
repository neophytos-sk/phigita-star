# tcl

proc PlotFunction {args} {
    set default {
	{"drawable"   "root"      "name of the drawable area"}
	{"func"       ""          "describe the function, using the variable x to express f(x) (e.g., linear would be {\$x}, whereas a simple parabola would be {\$x * \$x})"}
	{"range"      "0,10"      "the x-range the function should be plotted over, in xmin,xmax form"}
	{"step"       "1"         "given the range of xmin to xmax, step determines at which x values the function is evaluated and a line is drawn to; thus, the more ups and downs the function has, the smaller step that should be chosen"}
	{"linewidth"  "1.0"       "the linewidth to use"}
	{"linecolor"  "black"     "the color of the line"}
	{"linedash"   "0"         "the dash pattern (if non-zero)"}
    }
    ArgsProcessWithDashArgs PlotFunction default args use \
	"Use PlotFunction to plot a function right onto a drawable. The function should simply use the variable \$x wherever it needs to in order to express the desired function. For example, to plot y = x, the caller should pass the following flag: -func \{\$x\}. The caller should place curly braces around the function to prevent the Tcl interpreter from interpreting what is inside of the braces before it is passed to the PlotFunction routine."

    set count [ArgsParseNumbers $use(range) range]
    AssertEqual $count 2
    set min  $range(0)
    set max  $range(1)
    set step $use(step)
    
    # get first point
    set x $min
    set y [eval "expr $use(func)"]
    set lineList "[Translate $use(drawable) x $x] [Translate $use(drawable) y $y]"
    for {set x [expr $min+$step]} {$x <= $max} {set x [expr $x+$step]} {
	# now iterate and plot the rest of the points
	set y [eval "expr $use(func)"]
	set lineList "$lineList : [Translate $use(drawable) x $x] [Translate $use(drawable) y $y]"
    }

    # now draw the line
    PsLine -coord $lineList -linecolor $use(linecolor) -linewidth $use(linewidth) -linedash $use(linedash)
}

proc PlotVerticalBars {args} {
    set default {
	{"drawable"   "root"      "name of the drawable area"}
	{"table"      ""          "name of table to use"}
	{"xfield"     "x"         "table column with x data"}
	{"yfield"     "y"         "table column with y data"}
	{"ylofield"   ""          "if specified, table column with ylo data; use if bars don't start at y=0"}
	{"barwidth"   "1"         "bar width"}
	{"linecolor"  "black"     "color of the line"}
	{"linewidth"  "1"         "width of the line"}
	{"fill"       "false"     "fill the box or not"} 
	{"fillcolor"  "gray"      "fill color (if used)"}
	{"fillstyle"  "solid"     "solid, boxes, circles, ..."}
	{"fillparams" "2,4"       "any params that the fill style needs"}
	{"labelfield" ""          "if specified, table column with labels for each bar"}
	{"rotate"     "0.0"       "rotate labels"}
	{"anchor"     "c"         "center 'c' or right 'r' or left 'l' x-alignment for label text, or 'c,l', 'c,m', or 'c,h' for x and y alignment of text (l - low, m - middle, h - high alignment in y direction)"}
	{"place"      "n"         "(n) place label just below top of bar, (s) top above bar, ..."}
	{"font"       "Helvetica" "if using labels, what font should be used"}
	{"fontsize"   "6.0"       "if using labels, font for label"}
	{"fontcolor"  "black"     "if using labels, what color font should be used"}
	{"legend"     ""          "add this entry to the legend"}
    }    
    ArgsProcessWithDashArgs PlotVerticalBars default args use \
	"Use this to plot vertical bars on a drawable. "
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(xfield) $r]
	set y [TableGetVal $use(table) $use(yfield) $r]
	if {$use(ylofield) != ""} {
	    set ylo [TableGetVal $use(table) $use(ylofield) $r]
	} else {
	    set ylo [DrawableGet $use(drawable) ymin]
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

	if {$use(labelfield) != ""} {
	    set label [TableGetVal $use(table) $use(labelfield) $r]
	    set xlabel [expr $x1 + ($barwidth/2.0)]
	    switch -exact $use(place) {
		s { set ylabel [expr [Translate $use(drawable) y $y] - $use(fontsize)] }
		n { set ylabel [expr [Translate $use(drawable) y $y] + 3] }
		default { Abort "Should be n or s for north or south of yvalue"}
	    }
	    PsText -coord $xlabel,$ylabel -text $label -anchor $use(anchor) -rotate $use(rotate) \
		-font $use(font) -size $use(fontsize) -color $use(fontcolor) 
	}
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord \"COORDX \[expr COORDY-(HEIGHT/2.0)] : \[expr COORDX+WIDTH] \[expr COORDY+(HEIGHT/2.0)]\" -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillparams $use(fillparams) -linewidth 0.25 -linecolor $use(linecolor)"
    }
}

proc PlotHorizontalBars {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"yfield"     "y"           "table column with y data"}
	{"xlofield"   ""            "if specified, column with xlo data; use if bars don't start at x=0"}
	{"style"      ""            "style to use; supplants args below"}
	{"barwidth"   "1"           "bar width"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of the line"}
	{"fill"       "false"       "fill the box or not"} 
	{"fillcolor"  "gray"        "fill color (if used)"}
	{"fillstyle"  "solid"       "solid, boxes, circles, ..."}
	{"fillparams" "2,4"         "any params that the fill style needs"}
	{"legend"     ""            "add this entry to the legend"}
    }    
    # XXX - should add label ability to horizontal bars too
    ArgsProcessWithDashArgs PlotHorizontalBars default args use ""
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(xfield) $r]
	set y [TableGetVal $use(table) $use(yfield) $r]
	if {$use(xlofield) != ""} {
	    set xlo [TableGetVal $use(table) $use(xlofield) $r]
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
	{"table"      ""            "name of table to use"}
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

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(xfield) $r]
	set ylo [TableGetVal $use(table) $use(ylofield) $r]
	set yhi [TableGetVal $use(table) $use(yhifield) $r]

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
		Abort "Bad alignment ($use(align): should be c, l, r, or n"
	    }
	}

	# vertical line between two end marks
	PsLine -coord "[expr $xp-$dw] $yhip : [expr $xp+$dw] $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $ylop : [expr $xp+$dw] $ylop" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
    }
}

proc PlotHorizontalIntervals {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
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

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set y   [TableGetVal $use(table) $use(yfield) $r]
	set xlo [TableGetVal $use(table) $use(xlofield) $r]
	set xhi [TableGetVal $use(table) $use(xhifield) $r]

	set yp   [Translate $use(drawable) y $y]
	set xlop [Translate $use(drawable) x $xlo]
	set xhip [Translate $use(drawable) x $xhi]

	set dw   [expr $use(devwidth) / 2.0]
	set hlw  [expr $use(linewidth) / 2.0]

	switch -exact $use(align) {
	    c {
		PsLine -coord "$xlop $yp : $xhip $yp" \
		-linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    l {
		PsLine -coord "$xlop [expr $yp-$dw+$hlw] : $xhip [expr $yp-$dw+$hlw] " \
		    -linecolor $use(linecolor) -linewidth $use(linewidth)
	    }
	    u {
		PsLine -coord "$xlop [expr $yp+$dw-$hlw] : $xhip [expr $yp+$dw-$hlw] " \
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
	PsLine -coord "$xhip [expr $yp-$dw] : $xhip [expr $yp+$dw] " \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "$xlop [expr $yp-$dw] : $xlop [expr $yp+$dw] " \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)

    }
}

proc PlotHeat {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"yfield"     "y"           "table column with y data"}
	{"hfield"     "heat"        "table column with heat data"}
	{"width"      "1"           "width of each rectangle"}
	{"height"     "1"           "height of each rectangle"}
	{"divisor"    "1"           "how much to divide heat value by"}
	{"label"      "false"       "if true, add labels to each heat region reflecting count value"}
	{"fontcolor"  "orange"      "if using labels, what color font should be used"}
	{"fontsize"   "6.0"         "if using labels, what font size should be used"}
	{"font"       "Helvetica"   "if using labels, what font should be used"}
    }
    # XXX - default is to use hfield as label field -- does this make sense?
    ArgsProcessWithDashArgs PlotHeat default args use \
	"Use this to plot a heat map. A heat map takes x,y,heat triples and plots a gray-shaded box with darkness proportional to (heat/divisor) and of size (width by height) at each (x,y) coordinate"
    AssertNotEqual $use(table) ""

    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(xfield) $r]
	set y   [TableGetVal $use(table) $use(yfield) $r]

	set tx   [Translate $use(drawable) x $x]
	set ty   [Translate $use(drawable) y $y]

	set val  [TableGetVal $use(table) $use(hfield) $r]
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
	    PsText -anchor c -text [format "%3.0f" $val] -coord [expr $tx+($w/2.0)],[expr $ty+($h/2.0)] -size $use(fontsize) -color $use(fontcolor)
	}

    }
}

proc PlotPoints {args} {
    set default {
	{"drawable"   "root"        "name of the drawable area"}
	{"table"      ""            "name of table to use"}
	{"xfield"     "x"           "table column with x data"}
	{"yfield"     "y"           "table column with y data"}
	{"labelfield" ""            "if specified, table column with labels for each point"}
	{"sizefield"  ""            "if specified, table column with sizes for each point"}
	{"sizediv"    "1"           "if using sizefield, use sizediv to scale each value (sizefield gets divided by sizediv to determine the size of the point)"}
	{"linecolor"  "black"       "color of the line of the marker"}
	{"linewidth"  "1"           "width of lines used to draw the marker"}
	{"style"      "xline"       "label,hline,vline,plusline,xline,/line,\line,square,circle,triangle,utriangle"}
	{"fill"       "f"           "for some shapes, filling makes sense; if desired, mark this true"}
	{"fillcolor"  "black"       "if filling, use this fill color"}
	{"fillstyle"  "solid"       "if filling, which fill style to use"}
	{"fillparams" "2,4"         "if filling with a pattern, use these params to determine patterns characteristics"}
	{"size"       "2"           "overall size of marker; used unless sizefield is specified"}
	{"rotate"     "0.0"         "if using labels, rotate labels"}
	{"anchor"     "c,c"         "if using labels, center 'c' or right 'r' or left 'l' x-alignment for label text, or 'xanchor,l', 'xanchor,c', or 'xanchor,h' for x and y alignment of text (l - low, c - center, h - high alignment in y direction)"}
	{"place"      "c"           "if using labels, place text: (c) centered on point, (s) below point, (n) above point, (w) west of point, (e) east of point"}
	{"font"       "Helvetica"   "if using labels, what font should be used"}
	{"fontsize"   "6.0"         "if using labels, font for label"}
	{"fontcolor"  "black"       "if using labels, what color font should be used"}
	{"legend"     ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotPoints default args use \
	"Use this to draw some points on a drawable. There are some obvious parameters: which drawable, which table, which x and y columns from the table to use, the color of the point, its linewidth, and the size of the marker. 'style' is a more interesting parameter, allowing one to pick a box, circle, horizontal line (hline), and 'x' that marks the spot, and so forth. However, if you set 'style' to label, PlotPoints will instead use a column from the table (as specified by the 'label' flag) to plot an arbitrary label at each (x,y) point. Virtually all the rest of the flags pertain to these text labels: whether to rotate them, how to anchor them, how to place them, font, size, and color. " 
    AssertNotEqual $use(table) ""

    set t1 [clock clicks -milliseconds]

    # timing notes: 
    #   just getting values :   30ms / 2000pts
    #   + translation       :  130ms / 2000pts
    #   + filledcircle      : 1014ms / 2000pts (or 2pts/ms -- ouch!)
    #   + box               :  350ms / 2000pts 
    #   + switchstatement   : 1030ms / 2000pts 
    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [Translate $use(drawable) x [TableGetVal $use(table) $use(xfield) $r]]
	set y [Translate $use(drawable) y [TableGetVal $use(table) $use(yfield) $r]]
	if {$use(sizefield) == ""} {
	    # empty -> a single size should be used
	    set s $use(size)
	} else {
	    # non-empty -> sizefield should be used (i.e., ignore use(size))
	    set s [expr [TableGetVal $use(table) $use(sizefield) $r] / $use(sizediv)]
	}

	switch -exact $use(style) {
	    "label" {
		AssertNotEqual $use(labelfield) ""
		set label [TableGetVal $use(table) $use(labelfield) $r]
		switch -exact $use(place) {
		    c { }
		    s { set y [expr $y - $use(fontsize)] }
		    n { set y [expr $y + $use(fontsize)] }
		    w { set x [expr $x - $s - 2.0] }
		    e { set x [expr $x + $s + 2.0] }
		    default { Abort "bad 'place' flag ($use(flag)); should be c, s, n, w, or e" }
		}
		PsText -coord $x,$y -text $label -anchor $use(anchor) -rotate $use(rotate) \
		    -font $use(font) -size $use(fontsize) -color $use(fontcolor)
		
	    }
	    "square" { 
		PsBox -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) \
		    -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		    -fillparams $use(fillparams)
	    }
	    "circle" { 
		PsCircle -coord $x,$y -radius $s \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) \
		    -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		    -fillparams $use(fillparams)
	    }
	    "triangle" {
		PsPolygon -coord "[expr $x-$s] [expr $y-$s] : $x [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) \
		    -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		    -fillparams $use(fillparams)
	    }
	    "utriangle" {
		PsPolygon -coord "[expr $x-$s] [expr $y+$s] : $x [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) \
		    -fill $use(fill) -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) \
		    -fillparams $use(fillparams)
	    }
	    "plusline" { 
		PsLine -coord "[expr $x-$s] $y : [expr $x+$s] $y" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
		PsLine -coord "$x [expr $y+$s] : $x [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    "xline" { 
		PsLine -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
		PsLine -coord "[expr $x-$s] [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    "/line" { 
		PsLine -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    "\line" { 
		PsLine -coord "[expr $x-$s] [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    "hline" { 
		AssertNotEqual [True $use(fill)] 1
		PsLine -coord "[expr $x-$s] $y : [expr $x+$s] $y" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    "vline" { 
		AssertNotEqual [True $use(fill)] 1
		PsLine -coord "$x [expr $y+$s] : $x [expr $y-$s]" \
		    -linecolor $use(linecolor) -linewidth $use(linewidth) 
	    }
	    default {
		Abort "bad choice of point style: $use(style)"
	    }
	}
    }

    set t2 [clock clicks -milliseconds]
    Dputs table "PlotPoints: Plotted [TableGetNumRows $use(table)] points in [expr ($t2-$t1)] ms :: [ArgsPrint use]"

    if {$use(legend) != ""} {
	# XXX - need to finish this implementation
	switch -exact $use(style) {
	    "box"          { LegendAdd -text $use(legend) -picture "" }
	    "circle"       { LegendAdd -text $use(legend) -picture "" }
	    "filledcircle" { LegendAdd -text $use(legend) -picture "" }
	    "x"            { LegendAdd -text $use(legend) -picture "" }
	}
    }

}

# XXX - should be PlotHorizontalLines
proc PlotLines {args} {
    set default {
	{"drawable"    "root"        "name of the drawable area"}
	{"table"       ""            "name of table to use"}
	{"xfield"      "x"           "table column with x data"}
	{"yfield"      "y"           "table column with y data"}
	{"linecolor"   "black"       "color of the line of the marker"}
	{"linewidth"   "1"           "width of lines used to draw the marker"}
	{"linedash"    "0"           "use dashes for this line (0 means no dashes)"}
	{"legend"      ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotLines default args use \
	"Use this function to plot lines. It is one of the simplest routines there is -- basically, it takes the x and y fields and plots a line through them. It does NOT sort them, though, so you might need to do that first if you want the line to look pretty. The usual line arguments can be used, including color, width, and dash pattern. "
    AssertNotEqual $use(table) ""

    psGsave
    psNewpath

    set x [Translate $use(drawable) x [TableGetVal $use(table) $use(xfield) 0]]  
    set y [Translate $use(drawable) y [TableGetVal $use(table) $use(yfield) 0]]
    psMoveto $x $y

    for {set r 1} {$r < [TableGetNumRows $use(table)]} {incr r} {
	set x [Translate $use(drawable) x [TableGetVal $use(table) $use(xfield) $r]]  
	set y [Translate $use(drawable) y [TableGetVal $use(table) $use(yfield) $r]]
	psLineto $x $y
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
	LegendAdd -text $use(legend) -picture "PsLine -coord \"COORDX COORDY: \[expr COORDX+WIDTH] COORDY\" -linewidth $use(linewidth) -linecolor $use(linecolor)"
    }
}

# get the lo point (could be from a field, from a single value, or default: the min of yrange)
proc tableGetLoField {use__ row} {
    upvar $use__ use
    if {$use(ylofield) != ""} {
	return [Translate $use(drawable) y [TableGetVal $use(table) $use(ylofield) $row]]
    } else {
	if {$use(yloval) == ""} {
	    return [Translate $use(drawable) y [DrawableGet $use(drawable) ymin]]
	} else {
	    return [Translate $use(drawable) y $use(yloval)]
	}
    }
    Abort "tableGetLoField should never get this far"
}

proc PlotVerticalFill {args} {
    set default {
	{"drawable"    "root"        "name of the drawable area"}
	{"table"       ""            "name of table to use"}
	{"xfield"      "x"           "table column with x data"}
	{"yfield"      "y"           "table column with y data"}
	{"ylofield"    ""            "if not empty, use this table column to fill down to this value"}
	{"yloval"      ""            "if there is no ylofield, use this single value to fill down to; if empty, just use the min of y-range"}
	{"fillcolor"   "gray"        "fill color (if used)"}
	{"fillstyle"   "solid"       "solid, boxes, circles, ..."}
	{"fillparams"  "2,4"         "any params that the fill style needs"}
	{"legend"      ""            "add this entry to the legend"}
    }
    ArgsProcessWithDashArgs PlotVerticalFill default args use \
	"Use this function to fill a vertical region between either the values in yfield and the minimum of the y-range (default), the yfield values and the values in the ylofield, or the yfield values and a single yloval. Any pattern and color combination can be used to fill the filled space. "
    AssertNotEqual $use(table) ""

    # get first point
    set xlast   [Translate $use(drawable) x [TableGetVal $use(table) $use(xfield) 0]]  
    set ylast   [Translate $use(drawable) y [TableGetVal $use(table) $use(yfield) 0]]
    set ylolast [tableGetLoField use 0]
    
    # now, get rest of points
    for {set r 1} {$r < [TableGetNumRows $use(table)]} {incr r} {
	# get the new points
	set xcurr   [Translate $use(drawable) x [TableGetVal $use(table) $use(xfield) $r]]  
	set ycurr   [Translate $use(drawable) y [TableGetVal $use(table) $use(yfield) $r]]
	set ylocurr [tableGetLoField use $r]

	# draw the stinking polygon between the last pair of points and the current points
	psComment "PsPolygon $xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr"
	PsPolygon -coord "$xlast,$ylolast : $xlast,$ylast : $xcurr,$ycurr : $xcurr,$ylocurr" \
	    -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillparams $use(fillparams) \
	    -linewidth 0.1 -linecolor $use(fillcolor)
	# xxx - make a little bit of linewidth so as to overlap neighboring regions
	# the alternate is worse: having to draw one huge polygon

	# move last points to current points
	set xlast   $xcurr
	set ylast   $ycurr
	set ylolast $ylocurr
    }

    if {$use(legend) != ""} {
	LegendAdd -text $use(legend) -picture "PsBox -coord \"COORDX \[expr COORDY-(HEIGHT/2.0)] : \[expr COORDX+WIDTH] \[expr COORDY+(HEIGHT/2.0)]\" -fill t -fillcolor $use(fillcolor) -fillstyle $use(fillstyle) -fillparams $use(fillparams) -linewidth 0.1 -linecolor $use(fillcolor)"
    }

}

