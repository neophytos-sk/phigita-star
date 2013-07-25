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
TableLoad -table line1 -file "data.flines1"
TableLoad -table line2 -file "data.flines2"

# this defines one particular drawing area (default name: "root")
set xrange [TableGetRange -table line1,line2 -column x,x]
set ymax   [TableGetMax -table line1,line2 -column y,y]

# make drawable
Drawable -xrange $xrange -yrange 0,$ymax

# axes?
AxisTicsLabels 

# now plot the data
PlotLines -table line1 -x x -y y -linecolor dgray -fill t -fillstyle solid -fillcolor lgray
PlotLines -table line2 -x x -y y -linecolor dblue -fill t -fillstyle solid -fillcolor lblue

# all done
PsRender


