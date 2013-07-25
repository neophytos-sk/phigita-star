#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

Debug 1 table
Debug 1 plot

# define the canvas
PsCanvas -title "scatter.eps" -width 3.5 -height 2.75 -units inches

# read in the file into a table called bar1
TableLoad -table scatter -file "data.scatter"

# this defines one particular drawing area (default name: "root")
Drawable -xrange 0,3 -yrange -2,0.5

# axes (uses default drawable, 'root')
AxisTicsLabels 

# now plot the data (uses default drawable, 'root')
PlotPoints -table scatter -x x -y y -style filledcircle -linecolor red -linewidth 0.0 -size 0.25

# all done
PsRender 


