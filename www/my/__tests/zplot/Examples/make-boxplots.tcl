#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl; namespace import Zplot::*

# define the canvas
PsCanvas -title "line.eps" -width 3.5in -height 2.75in 

# read in the file into a table called bar1
Table -table line1 -file "data.line1"
Table -table line2 -file "data.line2"

# this defines one particular drawing area
set xrange [TableGetRange -table line1,line2 -column x,x]
set yrange [TableGetRange -table line1,line2 -column y,y]

Drawable -xrange $xrange -yrange $yrange

# now plot the data
PlotLines -table line1 -xfield x -yfield y -linecolor orange
PlotLines -table line2 -xfield x -yfield y -linecolor lightblue
PlotPoints -table line1 -xfield x -yfield y -linecolor black -style square -linewidth 0.5
PlotPoints -table line2 -xfield x -yfield y -linecolor black -style xline -linewidth 0.5

# axes?
AxesTicsLabels 
PsRender -file "boxplots.eps"


