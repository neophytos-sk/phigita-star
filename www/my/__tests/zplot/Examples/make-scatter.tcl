#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "scatter.eps" -width 3.5in -height 2.75in

# read in the file into a table called bar1
Table -table scatter -file "data.scatter"

# this defines one particular drawing area
Drawable -xrange 0,3 -yrange -2,0.5

# Grid
Grid -xstep 1 -ystep 1 -linedash 2,4

# lots of axes 
AxesTicsLabels -style xy -xaxisposition 0.0 -xauto 1,,1 -labels f
AxesTicsLabels -style x -majortics f -axis f -xauto ,,1 
AxesTicsLabels -style y -majortics f -axis f -ylabelformat "%i"

# now plot the data (uses default drawable, 'root')
PlotPoints -table scatter -xfield x -yfield y \
    -style circle -linecolor red -linewidth 0.0 -size 0.25 -fill t -fillcolor red

Label -coord 0.5,-0.5 -text MADDY -color red
Label -coord 0.5,-1.5 -text ANNA -color darkblue

# all done
PsRender -file scatter.eps



