#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# input the library
source zplot.tcl
namespace import Zplot::*

# describe the drawing surface
PsCanvas -title "example3.eps" -width 300 -height 200

# load some data
Table -table t -file "file.data"

# make a drawable region for a graph
Drawable -xrange 0,10 -yrange 0,10 -width 230

# make a drawable region for a graph
Drawable -drawable second -xrange 0,10 -yrange 0,20 -width 230

# make some axes
AxesTicsLabels -title "Multiple Y Axes" -xtitle "The X-Axis" -ytitle "The Y-Axis" 
AxesTicsLabels -drawable second -style y -ytitle "Second Y-Axis" -labelstyle in -yaxisposition 10 -yauto ,,4 -ticstyle in

# plot the points
PlotPoints -table t -xfield x -yfield y -style triangle -linecolor red -fill t -fillcolor red
PlotPoints -drawable second -table t -xfield x -yfield y -style triangle -linecolor green -fill t -fillcolor green




# finally, output the graph to a file
PsRender -file "example3.eps"
