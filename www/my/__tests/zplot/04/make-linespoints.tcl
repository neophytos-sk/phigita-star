#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# debugging
Debug 1 ps 
Debug 1 table

# define the canvas
PsCanvas -title "line.eps" -width 3.5 -height 2.75 -units inches

# read in the file into a table called bar1
TableLoad -table line1 -file "data.line1"
TableLoad -table line2 -file "data.line2"

# this defines one particular drawing area (default name: "root")
set xrange [TableGetRange -table line1,line2 -column x,x]
set yrange [TableGetRange -table line1,line2 -column y,y]

Drawable -xrange $xrange -yrange $yrange

# now plot the data
PlotLines -table line1 -x x -y y -linecolor orange
PlotLines -table line2 -x x -y y -linecolor lblue
PlotPoints -table line1 -x x -y y -linecolor black -style x -linewidth 0.5
PlotPoints -table line2 -x x -y y -linecolor black -style x -linewidth 0.5

# axes?
AxisTicsLabels 

# all done
PsRender


