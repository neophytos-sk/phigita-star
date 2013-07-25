#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "logplot.eps" -width 300 -height 245 

# read in the file into a table called bar1
Table -table logplot -file "data.logplot"

# this defines one particular drawing area
Drawable -xrange 0.5,6.5 -yrange .1,100 -yscale log10 -xscale linear

# axes
AxisTicsLabels -ylabelstep 10 -yticstep 10

# now plot the data 
PlotLines -table logplot -xfield c0 -yfield c1 -linewidth 0.25 -linecolor red
PlotPoints -table logplot -xfield c0 -yfield c1 \
    -style circle -linecolor red -linewidth 0.0 -size 1.0 -fill t -fillcolor red

# all done
PsRender -file Output/logplot.eps



