#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot3a.eps -width 300 -height 300 

# read in the file into a table called bar1
Table -table scatter -file "data.scatterplot3"

# this defines one particular drawing area
Drawable -xrange 0,80 -yrange 0,80 -coord 30,30 -dimensions 260,260

# axes
AxesTicsLabels -yauto ,,10 -xauto ,,10

# add a gray line
Line -coord 0,0:80,80 -linewidth 0.25 -linecolor gray

# now plot the data
PlotPoints -table scatter -xfield c0 -yfield c1 \
    -sizefield c2 -sizediv 3.0 \
    -style circle -linewidth 0.0 -fill t -fillcolor salmon
PlotPoints -table scatter -xfield c0 -yfield c1 \
    -sizefield c2 -sizediv 3.0 \
    -style circle -linewidth 0.25 

# all done
PsRender -file scatterplot3a.eps

