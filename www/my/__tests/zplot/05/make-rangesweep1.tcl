#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

# source the library
source libs.tcl
namespace import Zplot::*

# define the canvas
PsCanvas -title "rangesweep1.eps" -width 4 -height 2.5 -units inches

# read in the data
Table -table rangesweep -file data.rangesweep1

# make a drawable 
Drawable -xrange "-20 80" -yrange "0 1" -width [expr [PsCanvasInfo -info width] - 50]

# now plot the data
PlotVerticalFill -table rangesweep -xfield c0 -yfield c2 -ylofield c1 -fillcolor lblue
PlotLines -table rangesweep -xfield c0 -yfield c1 -linecolor blue
PlotLines -table rangesweep -xfield c0 -yfield c2 -linecolor blue

# axes
AxisTicsLabels -yticstep 0.2 -ylabelstep 0.2 -xlabelstep 20 -xticstep 20

# make some grid marks
for {set y 0.2} {$y <= 1.0} {set y [expr $y + 0.2]} {
    Line -coord "-20 $y : 80 $y" -linedash 4,2 -linecolor orange -linewidth 0.5
}

# some labels
Line -coord "0 0.65 : 0 0.4" -arrow t 
Line -coord "64 0.4 : 64 0.63" -arrow t 
Label -coord "0 0.67" -text "F1" -rotate 90 -anchor l,c -fontsize 6.0 -font Helvetica-Bold
Label -coord "64 0.38" -text "F2" -rotate 90 -anchor r,c -fontsize 6.0 -font Helvetica-Bold

# labels
Label -drawable canvas -coord [Location -type "xlabel"] -text "Temperature (c)" \
    -font Helvetica-Bold -yshift -4

# all done
PsRender -file Output/rangesweep1.eps



