#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "scatter1.eps" -width 300 -height 300

# read in the file into a table called bar1
Table -table scatter -file "data.scatter1"
TableAddColumns -table scatter -columns zero -value 0.0

# this defines one particular drawing area
Drawable -xrange 0,80 -yrange 0,80 -xoff 10 -yoff 10 -width 285 -height 285

# add a single red line for the function y = x
PlotFunction -func {$x} -range 0,80 -step 10 -linewidth 0.25 -linecolor gray

# now plot the data
PlotPoints -table scatter -xfield x -yfield y -style triangle -linewidth 0.0 -size 3.0 -fill t -fillcolor red
PlotPoints -table scatter -xfield x -yfield zero -style vline -linecolor black -linewidth 0.25 -size 3.0
PlotPoints -table scatter -xfield zero -yfield y -style hline -linecolor black -linewidth 0.25 -size 3.0

# now, add axis (no tics, no labels)
AxesTicsLabels -labels f -majortics f -linewidth 0.25

# all done
PsRender -file scatter1.eps



