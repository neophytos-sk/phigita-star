#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "filled.eps" -width 3.5 -height 2.75 -units inches

# read in the file into a table called bar1
Table -table line1 -file "data.flines1"
Table -table line2 -file "data.flines2"

# this defines one particular drawing area (default name: "root")
set xrange [TableGetRange -table line1,line2 -column x,x]
set ymax   [TableGetMax -table line1,line2 -column y,y]

# make drawable
Drawable -xrange $xrange -yrange 0,$ymax

# now plot filled region first, then line on top of it (for both gray area behind and then blue on top)
PlotVerticalFill -table line1 -xfield x -yfield y -fillstyle solid -fillcolor lgray
PlotLines -table line1 -xfield x -yfield y -linecolor dgray 

PlotVerticalFill -table line2 -xfield x -yfield y -fillstyle solid -fillcolor lblue
PlotLines -table line2 -xfield x -yfield y -linecolor dblue 

# axes?
AxisTicsLabels 

# all done
PsRender -file Output/filled.eps


