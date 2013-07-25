# tcl

#
# BarPlot
# 
proc BarPlot {args} {
    set default {
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
    }    
    ArgsProcessWithDashArgs BarPlot default args use    

    # check for style
    if {$use(style) != ""} {
	StyleGet $use(style) use
    }

    # data
    for {set r 0} {$r < [TableGetRows $use(table)]} {incr r} {
	set x [TableGetVal $use(table) $use(x) $r]
	set y [TableGetVal $use(table) $use(y) $r]

	set barwidth [ScaleX $use(barwidth)]

	set x1 [expr [TranslateX $x] - ($barwidth/2.0)]
	set y1 [TranslateY 0.0]
	set x2 [expr $x1 + $barwidth]
	set y2 [TranslateY $y] 

	# make the arg list and call the box routine
	RawBox -coord $x1,$y1:$x2,$y2 \
	       -linecolor  $use(linecolor) \
	       -linewidth  $use(linewidth) \
	       -fill       $use(fill) \
	       -fillcolor  $use(fillcolor) \
	       -fillstyle  $use(fillstyle) \
	       -fillparams $use(fillparams)
    }
}


