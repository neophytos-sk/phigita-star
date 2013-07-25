#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot5.eps -width 300 -height 300 

# read in the file into a table called bar1
Table -table scatter -file "data.scatterplot3"

# this defines one particular drawing area
Drawable -xrange 0,80 -yrange 0,80 -dimensions 260,260

# axes
AxesTicsLabels -yauto ,,10 -xauto ,,10 

# add a gray line
Line -coord 0,0:80,80 -linewidth 0.25 -linecolor gray

# now plot the data
PlotPoints -table scatter -xfield c0 -yfield c1 \
    -style circle -linewidth 0.25 -fill t -fillcolor pink -size 5
TableAddColumns -table scatter -columns textA -value A
PlotPoints -table scatter -xfield c0 -yfield c1 -style label -labelfield textA -labelsize 6.0

PlotPoints -table scatter -xfield c1 -yfield c2 \
    -style circle -linewidth 0.25 -fill t -fillcolor yellow -size 5
TableAddColumns -table scatter -columns textB -value B
PlotPoints -table scatter -xfield c1 -yfield c2 -style label -labelfield textB -labelsize 6.0

# all done
PsRender -file scatterplot3.eps



