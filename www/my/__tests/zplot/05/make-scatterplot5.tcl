#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot5.eps -width 300 -height 300 

# read in the file (x, y, misc, state)
Table -table scatter -file "data.scatterplot5"

# this defines one particular drawing area (default name: "root")
Drawable -xrange 0,80 -yrange 0,80 -xoff 30 -yoff 30 -width 260 -height 260

# axes (uses default drawable, 'root')
AxisTicsLabels -ylabelstep 10 -yticstep 10 -xlabelstep 10 -xticstep 10

# add a single diagonal line
PlotFunction -func {$x} -range 0,80 -step 10 -linewidth 0.25 -linecolor gray

# now plot the intervals and points
PlotPoints -table scatter -xfield x -yfield y -style label -labelfield state -fontsize 9.0
# PlotPoints -table scatter -x x -y y -style circle -linewidth 0.0 -fillcolor red -size 1.0

# all done
PsRender -file Output/scatterplot5.eps


