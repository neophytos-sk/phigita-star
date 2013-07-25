# tcl

proc PlotBar {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"x"          "x"           "table column with x data"}
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
    ArgsProcessWithDashArgs PlotBar default args use ""

    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(x) $r]
	set y [TableGetVal $use(table) $use(y) $r]

	set barwidth [ScaleX $use(drawable) $use(barwidth)]

	set x1 [expr [TranslateX $use(drawable) $x] - ($barwidth/2.0)]
	set y1 [TranslateY $use(drawable) 0.0]
	set x2 [expr $x1 + $barwidth]
	set y2 [TranslateY $use(drawable) $y] 

	# make the arg list and call the box routine
	PsBox -coord $x1,$y1:$x2,$y2 \
	    -linecolor  $use(linecolor) \
	    -linewidth  $use(linewidth) \
	    -fill       $use(fill) \
	    -fillcolor  $use(fillcolor) \
	    -fillstyle  $use(fillstyle) \
	    -fillparams $use(fillparams)
    }

    # legend
    #if {$use(legend)} {
	# LegendAdd ""
    #}
}

# this could be generalized to plot intervals
# should also work in x and y directions (left-right intervals, not just up-down)
# should also allow some different looks, e.g.:
#    "normal"    |--|
#    "lower"     |__|
#    "upper"     (upside down lower)
# 
proc PlotDevs {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"ylo"        "ylo"         "table column with ylo data"}
	{"yhi"        "yhi"         "table column with ylo data"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of all lines"}
	{"devwidth"   "3"           "width of little marker on top"}
    }
    ArgsProcessWithDashArgs PlotDevs default args use ""

    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set ylo [TableGetVal $use(table) $use(ylo) $r]
	set yhi [TableGetVal $use(table) $use(yhi) $r]

	set xp   [TranslateX $use(drawable) $x]
	set ylop [TranslateY $use(drawable) $ylo]
	set yhip [TranslateY $use(drawable) $yhi]

	set dw   [expr $use(devwidth) / 2.0]

	PsLine -coord "$xp $ylop : $xp $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $yhip : [expr $xp+$dw] $yhip" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)
	PsLine -coord "[expr $xp-$dw] $ylop : [expr $xp+$dw] $ylop" \
	    -linecolor $use(linecolor) -linewidth $use(linewidth)

    }
}



proc PlotPoints {args} {
    set default {
	{"drawable"   "default"     "name of the drawable area"}
	{"table"      "default"     "name of table to use"}
	{"x"          "x"           "table column with x data"}
	{"y"          "y"           "table column with y data"}
	{"linecolor"  "black"       "color of the line"}
	{"linewidth"  "1"           "width of lines used to draw point"}
	{"style"      "x"           "point,circle,box,star,..."}
	{"size"       "2"           "size of marker"}
    }
    ArgsProcessWithDashArgs PlotPoints default args use ""

    set s $use(size)

    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x   [TableGetVal $use(table) $use(x) $r]
	set y   [TableGetVal $use(table) $use(y) $r]

	set x   [Translate $use(drawable) x $x]
	set y   [Translate $use(drawable) y $y]

	switch -exact $use(style) {
	    "box"    { PsBox -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
			   -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "circle" { PsCircle -coord $x,$y -radius $use(size) \
			   -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    "x"      { PsLine -coord "[expr $x-$s] [expr $y-$s] : [expr $x+$s] [expr $y+$s]" \
			   -linecolor $use(linecolor) -linewidth $use(linewidth) 
		       PsLine -coord "[expr $x-$s] [expr $y+$s] : [expr $x+$s] [expr $y-$s]" \
			   -linecolor $use(linecolor) -linewidth $use(linewidth) }
	    
	}

    }
}


