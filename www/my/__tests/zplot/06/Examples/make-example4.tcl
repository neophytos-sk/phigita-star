#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# input the library
source zplot.tcl
namespace import Zplot::*

# describe the drawing surface
PsCanvas -title "example4.eps" -width 300 -height 200

# make a drawable region for a graph
Drawable -xrange 0,6 -yrange 0,11 -width 210

# make some axes
AxesTicsLabels -title "Lots of Patterns" -xtitle "The X-Axis" -ytitle "The Y-Axis"  -yauto 0,10,2

# plot the points
Table -table b1 -file "b1.data"
Table -table b2 -file "b2.data"
Table -table b3 -file "b3.data"
Table -table b4 -file "b4.data"
Table -table b5 -file "b5.data"
PlotVerticalBars -table b5 -xfield x -yfield y -fill t -fillcolor darkgray -bgcolor white -barwidth 0.9 -legend Stuff -linewidth 0.5
PlotVerticalBars -table b4 -xfield x -yfield y -fill t -fillstyle dline1 -bgcolor white -barwidth 0.9 -legend Things -linewidth 0.5
PlotVerticalBars -table b3 -xfield x -yfield y -fill t -fillcolor lightgray -bgcolor white -barwidth 0.9 -legend Junk -linewidth 0.5
PlotVerticalBars -table b2 -xfield x -yfield y -fill t -fillstyle triangle -bgcolor white -barwidth 0.9 -fillsize 4 -fillskip 2 -legend Yards -linewidth 0.5
PlotVerticalBars -table b1 -xfield x -yfield y -fill t -fillcolor mintcream -bgcolor white -barwidth 0.9 -legend Dogs -linewidth 0.5

Legend -coord 6,8 -down t -width 15 -height 15

# finally, output the graph to a file
PsRender -file "example4.eps"
