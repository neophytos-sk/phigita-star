#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

set colors [PsColors]
set count [llength $colors]

# define the canvas
PsCanvas -title "colors.eps" -width [expr 0.2 * $count] -height 2.75 -units inches

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
set x 1
foreach c $colors {
    Table -table $c -columns x,y,label
    TableAddRow $c "x $x : y 10 : label $c"
    incr x
}

# this defines one particular drawing area (default name: "root")
Drawable -xrange "0 $x" -yrange "0 15" -xoff 40

# plot some data, for goodness sake
foreach c $colors {
    PlotVerticalBars -table $c -xfield x -yfield y -labelfield label -barwidth 0.9 -fill t -fillcolor $c -linewidth 0.0 -rotate 90 -anchor l,c -place n
}

# axis
AxisTicsLabels

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "The Colors of Zplot"
Label -drawable canvas -coord [Location -type "ylabel"] -text "No Particular Measure" -rotate 90 -xshift 5
Label -drawable canvas -coord [Location -type "xlabel"] -text "Color" -yshift -5

# and finally, render it all
PsRender -file Output/colors.eps


