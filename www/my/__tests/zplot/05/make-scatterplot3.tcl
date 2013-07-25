#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title scatterplot5.eps -width 300 -height 300 

# read in the file into a table called bar1
Table -table scatter -file "data.scatterplot3"

# this defines one particular drawing area (default name: "root")
Drawable -xrange 0,80 -yrange 0,80 -xoff 30 -yoff 30 -width 260 -height 260

# axes (uses default drawable, 'root')
AxisTicsLabels -ylabelstep 10 -yticstep 10 -xlabelstep 10 -xticstep 10

# add a gray line
Line -coord 0,0:80,80 -linewidth 0.25 -linecolor gray

# now plot the data (uses default drawable, 'root')
PlotPoints -table scatter -xfield c0 -yfield c1 \
    -style circle -linewidth 0.25 -fill t -fillcolor pink -size 5
TableAddColumns -table scatter -columns textA -value A
PlotPoints -table scatter -xfield c0 -yfield c1 -style label -labelfield textA -fontsize 6.0

PlotPoints -table scatter -xfield c1 -yfield c2 \
    -style circle -linewidth 0.25 -fill t -fillcolor yellow -size 5
TableAddColumns -table scatter -columns textB -value B
PlotPoints -table scatter -xfield c1 -yfield c2 -style label -labelfield textB -fontsize 6.0

# all done
PsRender -file Output/scatterplot3.eps



