#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "scatter2.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar1
Table -table scatter -file "data.scatter2"

# this defines one particular drawing area
Drawable -xrange 0,3 -yrange -2,0.5

# axes
AxisTicsLabels -ylocation 0.0

# now plot the data
PlotLines -table scatter -xfield x -yfield y -linewidth 0.25
PlotPoints -table scatter -xfield x -yfield y \
    -style circle -linecolor red -linewidth 0.0 -size 1.0 -fill t -fillcolor red

# all done
PsRender -file Output/scatter2.eps



