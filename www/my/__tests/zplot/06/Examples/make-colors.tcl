#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

set colors [PsColors]
set count [llength $colors]

# define the canvas
PsCanvas -title "colors.eps" -width [expr 0.04*$count]in -height 2.75in 

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
set x 1
foreach c $colors {
    Table -table $c -columns x,y,label
    TableAddRow -table $c -data "x,$x : y,10 : label,$c"
    incr x
}

# this defines one particular drawing area
Drawable -xrange "0,$x" -yrange "0,15" -xoff 30

# plot some data, for goodness sake
foreach c $colors {
    PlotVerticalBars -table $c -xfield x -yfield y -labelfield label -barwidth 0.9 -fill t -fillcolor $c -linewidth 0.0 \
	-labelrotate 90 -labelanchor l,c -labelplace o -labelsize 4.0
}

# axis
AxesTicsLabels -xtitle "The Colors of Zplot" -ytitle "No Particular Measure" -title "Colors"

# and finally, render it all
PsRender -file colors.eps


