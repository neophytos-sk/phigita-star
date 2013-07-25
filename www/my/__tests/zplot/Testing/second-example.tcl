#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# input the library
source zplot.tcl
namespace import Zplot::*

# describe the drawing surface
PsCanvas -title "second-example.eps" -width 3in -height 2.4in

# load some data
Table -table t -file "file.data"

Table -table thi -columns x,y,ylo,yhi
TableSelect -from t -to thi -where {$y > 5}

# make a drawable region for a graph
Drawable -xrange 0,10 -yrange 0,10

# make some axes
AxesTicsLabels -title "Using Table Selection" -xtitle "The X-Axis" -ytitle "The Y-Axis"

# plot the points
PlotPoints -table t -xfield x -yfield y -style triangle -linecolor red -fill t -fillcolor red
PlotPoints -table thi -xfield x -yfield y -style circle -linecolor green -size 5 -linewidth 2

# finally, output the graph to a file
PsRender -file "second-example.eps"
