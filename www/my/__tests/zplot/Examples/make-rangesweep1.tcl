#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source zplot.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "rangesweep1.eps" -width 4in -height 2.5in

# read in the data
Table -table rangesweep -file data.rangesweep1

# make a drawable 
Drawable -xrange "-20,80" -yrange "0,1" -dimensions [expr [PsCanvasInfo -info width] - 50],

# now plot the data
PlotVerticalFill -table rangesweep -xfield c0 -yfield c2 -ylofield c1 -fillcolor lightblue
PlotLines -table rangesweep -xfield c0 -yfield c1 -linecolor blue
PlotLines -table rangesweep -xfield c0 -yfield c2 -linecolor blue

# axes
AxesTicsLabels -yauto ,,0.2 -xauto ,,20 -xtitle "Temperature (c)" -xtitlefont Helvetica-Bold

# make some grid marks
Grid -x f -yrange 0.2,1.0 -ystep 0.2 -linedash 4,2 -linecolor orange -linewidth 0.5

# some labels
Line -coord "0,0.65 : 0,0.4" -arrow t 
Line -coord "64,0.4 : 64,0.63" -arrow t 
Label -coord "0,0.67" -text "F1" -rotate 90 -anchor l,c -fontsize 6.0 -font Helvetica-Bold
Label -coord "64,0.38" -text "F2" -rotate 90 -anchor r,c -fontsize 6.0 -font Helvetica-Bold

# all done
PsRender -file rangesweep1.eps



