#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# input the library
source zplot.tcl
namespace import Zplot::*

# describe the drawing surface
PsCanvas -title "example1.eps" -width 3in -height 2.4in

# load some data
Table -table t -file "file.data"

# make a drawable region for a graph
Drawable -xrange 0,10 -yrange 0,10

# make some axes
AxesTicsLabels -title "A Sample Graph" -xtitle "The X-Axis" -ytitle "The Y-Axis"

# plot the points
PlotPoints -table t -xfield x -yfield y -style triangle -linecolor red -fill t -fillcolor red

# finally, output the graph to a file
PsRender -file "example1.eps"
