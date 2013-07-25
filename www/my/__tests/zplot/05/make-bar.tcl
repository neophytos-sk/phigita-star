#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "bar.eps" -width 3.5 -height 2.75 -units inches

# read in the file into a table called bar (without schema, columns automatically named c0 and c1)
Table -table bar -file "data.bar"

# this defines one particular drawing area (default name: "root")
set xmax [TableGetMax -column c0 -table bar]
set ymax [TableGetMax -column c1 -table bar]
Drawable -xrange "0 [expr $xmax+1]" -yrange "0 [expr $ymax+2]" -xoff 30

# axis
AxisTicsLabels

# plot some data, for goodness sake
PlotVerticalBars -table bar -xfield c0 -yfield c1 -barwidth 0.9 -fill t -fillcolor dred -fillstyle \line -fillparams 2,4 -legend "Widgets" -labelfield c1 

# draw a legend
Legend -coord 190,170 -height 10 -width 10 -fontsize 10.0 

# labels
Label -drawable canvas -coord [Location -type "title"]  -text "A Bar Plot"
Label -drawable canvas -coord [Location -type "ylabel"] -text "Height (cm)" -rotate 90 -xshift 5
Label -drawable canvas -coord [Location -type "xlabel"] -text "Measured Thing" -yshift -5

# and finally, render it all
PsRender -file Output/bar.eps






